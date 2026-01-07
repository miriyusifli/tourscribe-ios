import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js";
import { GoogleGenAI } from "npm:@google/genai";
import { z } from "npm:zod";

// =============================================================================
// Constants
// =============================================================================

const MODEL_NAME = "gemini-2.5-flash";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const saveItineraryDeclaration = {
  name: "save_itinerary",
  description: "Save the confirmed itinerary with structured data. Call this when user confirms the itinerary.",
  parameters: {
    type: "object",
    properties: {
      items: {
        type: "array",
        items: {
          type: "object",
          properties: {
            name: { type: "string", description: "Exact name of the place (e.g., 'Café de Flore')" },
            textContent: { type: "string", description: "Full display text with name, address and description (e.g., 'Café de Flore, 172 Boulevard Saint-Germain, Paris - Historic café frequented by artists')" },
            address: { type: "string", description: "Full street address with number and city (e.g., '172 Boulevard Saint-Germain, Paris')" },
            item_type: { type: "string", enum: ["activity", "restaurant"], description: "Type of item: 'activity' for attractions/walks, 'restaurant' for meals" },
            start_datetime: { type: "string", description: "Start time in ISO 8601 format (e.g., '2025-09-12T09:00:00')" },
            end_datetime: { type: "string", description: "End time in ISO 8601 format (e.g., '2025-09-12T10:30:00')" },
          },
          required: ["name", "textContent", "address", "item_type", "start_datetime", "end_datetime"],
        },
      },
    },
    required: ["items"],
  },
};

// =============================================================================
// Types & Schemas
// =============================================================================

interface UserProfile {
  name: string;
  gender: string;
  interests: string[];
  birth_date: string;
}

interface PlaceResult {
  placeId: string;
  name: string;
  address: string;
  latitude: number;
  longitude: number;
}

interface ExtractedItem {
  name: string;
  textContent: string;
  address: string;
  item_type: "activity" | "restaurant";
  start_datetime: string;
  end_datetime: string;
}

interface EnrichedItem extends ExtractedItem {
  place_id: string;
  latitude: number;
  longitude: number;
}

const requestSchema = z.object({
  message: z.string().min(1),
  history: z.array(z.object({ role: z.string(), content: z.string() })).optional(),
  trip_id: z.number().int(),
  name: z.string().min(1),
  gender: z.string(),
  birth_date: z.string(),
  interests: z.array(z.string()),
});

// Service role client - only for rate limit check
const adminClient = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

// =============================================================================
// Helpers
// =============================================================================

const jsonResponse = (data: object, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });

const calculateAge = (birthDate: string): number => {
  const birth = new Date(birthDate);
  const today = new Date();
  let age = today.getFullYear() - birth.getFullYear();
  const m = today.getMonth() - birth.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) age--;
  return age;
};

// =============================================================================
// System Prompt
// =============================================================================

const buildSystemPrompt = (tripId: number, profile: UserProfile) => `
## IDENTITY
You are **Tourscribe AI**, a travel planning assistant. Never mention Google, Gemini, or any AI model.

## USER
${profile.name} | Age ${calculateAge(profile.birth_date)} | ${profile.gender}
Interests: ${profile.interests.join(", ")}

## RULES
**Data Collection** (ask only for missing fields, acknowledge what's received):
1. Destination (specific city)
2. Exact dates (e.g., "Sep 12-18, 2025") - reject vague ranges
3. Arrival & departure times (24h format)
4. Budget: Budget / Mid-range / Luxury

**Date Interpretation:**
- Always interpret dates as future dates. If user says "April" without a year, assume the next upcoming April.
- Never create itineraries for past dates. If dates appear to be in the past, ask user to confirm future dates.
- Today's date is used as reference for determining future dates.

**Time Constraints:**
- Day 1 starts 90+ min after arrival
- Last day ends 3+ hours before departure

**Itinerary Quality:**
- Every suggestion = real establishment name (never "Local Bistro" or "Luxury Shopping")
- Only include places with 4+ star ratings
- Every day includes breakfast, lunch, dinner unless user opts out
- Match activities to season (winter→indoor, summer→outdoor; respect hemispheres)
- Group by neighborhood, include transit time between activities

**Privacy:** Refer to trip as "this trip" or "your itinerary" - never expose the trip ID (${tripId})

## FORMAT
- 24h time (14:00 not 2pm)
- Bullets: •
- Emojis: ☕ breakfast, 🍴 lunch, 🍷 dinner, 🏛️ culture, 🛍️ shopping, 🎨 art, 🚶 walking

## FLOW
Greet → Get destination/dates → Get times → Get budget → Propose itinerary → User confirms

## TEMPLATES
**Greeting:** "Hi ${profile.name}! I see you love ${profile.interests.join(", ")}. Where are you heading and when?"

**Itinerary format:**
**[Date]**
• ☕ **[HH:MM-HH:MM] Breakfast:** [Place Name] - [Why]
• 🏛️ **[HH:MM-HH:MM] Activity:** [Place Name] - [Description]
• 🍴 **[HH:MM-HH:MM] Lunch:** [Place Name] - [Why]
• 🍷 **[HH:MM-HH:MM] Dinner:** [Place Name] - [Why]

CRITICAL: Use the Google Maps tool to look up and verify the exact address for every place. Every place MUST have a real, complete street address with street name and number (e.g., "123 Main Street, Paris"). Never use vague locations like "City Center" or "Near the park". Never add generic activities like "Luxury souvenir shopping", "Explore favorite landmarks", "Stroll around", or "Explore the area" - every item must be a specific, named location. For walking activities (e.g., "Walk along the river"), always specify the starting point with a street address. If a place doesn't have a street address, do not include it.

## COMPLETION
When user confirms the itinerary (says yes, looks good, confirm, etc.), you MUST call the save_itinerary function with all itinerary items, then respond with the complete itinerary text.
`;

// =============================================================================
// Google Places API
// =============================================================================

async function searchPlaces(query: string): Promise<PlaceResult[] | null> {
  
  const res = await fetch("https://places.googleapis.com/v1/places:searchText", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": Deno.env.get("GEMINI_API_KEY")!,
      "X-Goog-FieldMask": "places.id,places.displayName,places.formattedAddress,places.location",
    },
    body: JSON.stringify({ textQuery: query, maxResultCount: 5 }),
  });

  if (!res.ok) return null;

  const data = await res.json();
  if (!data.places?.length) return null;

  return data.places.map((p: any) => ({
    placeId: p.id,
    name: p.displayName?.text,
    address: p.formattedAddress,
    latitude: p.location?.latitude,
    longitude: p.location?.longitude,
  }));
}

// =============================================================================
// Chat Handler
// =============================================================================

async function handleChat(ai: GoogleGenAI, message: string, history: any[], tripId: number, profile: UserProfile): Promise<{ text: string; items: ExtractedItem[] | null }> {
  const start = performance.now();
  
  const chatHistory = history?.map((h) => ({
    role: h.role === "user" ? "user" : "model",
    parts: [{ text: h.content }],
  })) || [];

  const chat = ai.chats.create({
    model: MODEL_NAME,
    history: chatHistory,
    config: {
      systemInstruction: buildSystemPrompt(tripId, profile),
      tools: [{ googleMaps: {} }, { functionDeclarations: [saveItineraryDeclaration] }],
    },
  });

  const response = await chat.sendMessage({ message });
  console.info(`[handleChat] ${(performance.now() - start).toFixed(0)}ms`);

  // Check for function call
  const functionCall = response.functionCalls?.[0];
  if (functionCall?.name === "save_itinerary") {
    const items = (functionCall.args as { items: ExtractedItem[] }).items;
    return { text: response.text || "", items };
  }

  return { text: response.text || "", items: null };
}

// =============================================================================
// Itinerary Enrichment
// =============================================================================

async function enrichItineraryItems(items: ExtractedItem[]): Promise<EnrichedItem[]> {
  const start = performance.now();
  
  const results = await Promise.all(
    items.map(async (item) => {
      const query = `${item.name} ${item.address}`.trim();
      const places = await searchPlaces(query);
      
      if (!places?.[0]?.address) {
        console.error(`[enrichPlaces] No address found for: ${query}, skipping`);
        return null;
      }
      
      if (places.length > 1) console.warn(`[enrichPlaces] More than 1 place found for: ${query}, count: ${places.length}`);
      
      const place = places[0];
      return {
        ...item,
        address: place.address,
        place_id: place.placeId,
        latitude: place.latitude,
        longitude: place.longitude,
      };
    })
  );
  
  const validResults = results.filter((item): item is EnrichedItem => item !== null);
  console.info(`[enrichPlaces] ${validResults.length}/${items.length} valid, ${(performance.now() - start).toFixed(0)}ms`);

  return validResults;
}

// =============================================================================
// Save to Database
// =============================================================================

async function saveItineraryToDatabase(userClient: ReturnType<typeof createClient>, tripId: number, items: EnrichedItem[]) {
  const start = performance.now();
  
  const batchItems = items.map((item) => ({
    title: item.textContent,
    item_type: item.item_type,
    start_datetime: item.start_datetime,
    end_datetime: item.end_datetime,
    metadata: { place_id: item.place_id },
    locations: [{
      sequence: 1,
      name: item.name,
      address: item.address,
      place_id: item.place_id,
      latitude: item.latitude,
      longitude: item.longitude,
    }],
  }));

  const { data, error } = await userClient.rpc("create_trip_items_batch", {
    p_trip_id: tripId,
    p_items: batchItems,
  });

  if (error) {
    console.error(`[saveItinerary] Batch insert failed:`, error.message);
    throw new Error("Failed to save itinerary");
  }

  const count = (data as { count: number })?.count ?? 0;
  console.info(`[saveItinerary] ${count} items saved, ${(performance.now() - start).toFixed(0)}ms`);
  
  return count;
}

// =============================================================================
// Main Handler
// =============================================================================

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return jsonResponse({ error: "No auth" }, 401);
    
    const userClient = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authHeader } }
    });
    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) return jsonResponse({ error: "Unauthorized" }, 401);
    
    const { data: remaining, error: limitError } = await adminClient.rpc("check_llm_chat_limit", { p_user_id: user.id });
    if (limitError || remaining === -1) return jsonResponse({ error: "Limit hit" }, 429);

    const parsed = requestSchema.safeParse(await req.json());
    if (!parsed.success) {
      return jsonResponse({ error: "Invalid request" }, 400);
    }

    const { message, history = [], trip_id, name, gender, birth_date, interests } = parsed.data;
    const profile: UserProfile = { name, gender, birth_date, interests };

    const ai = new GoogleGenAI({ apiKey: Deno.env.get("GEMINI_API_KEY")! });
    const { text, items } = await handleChat(ai, message, history, trip_id, profile);

    // Continue chat if no function call (not confirmed)
    if (!items) {
      return jsonResponse({
        content: text,
        remaining_requests: 100,
      });
    }

    // Enrich itinerary items with Places API
    const structuredItems = await enrichItineraryItems(items);

    // Save to database using user's client (respects RLS)
    const savedCount = await saveItineraryToDatabase(userClient, trip_id, structuredItems);

    return jsonResponse({
      content: `Your itinerary has been saved! ${savedCount} items added to your trip.`, //TODO translation
      remaining_requests: 100,
    });
  } catch (error) {
    console.error("[Error]:", error);
    const message = error instanceof Error ? error.message : "Internal Server Error";
    return jsonResponse({ error: message }, 500);
  }
});

