import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { GoogleGenerativeAI } from "npm:@google/generative-ai";

const MODEL_NAME = "gemini-2.5-flash";

interface UserProfile {
  name: string;
  gender: string;
  interests: string[];
  birth_date: string;
}

const calculateAge = (birthDate: string): number => {
  const birth = new Date(birthDate);
  const today = new Date();
  let age = today.getFullYear() - birth.getFullYear();
  const monthDiff = today.getMonth() - birth.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) age--;
  return age;
};

const getSystemPrompt = (tripId: string, profile: UserProfile) => `
### IDENTITY & TONE
- Your name is **Tourscribe AI**. 
- Created by a team of **"cool developers"** to be the ultimate traveler's companion.
- **IMPORTANT:** Never mention Google, Gemini, LLM, or any specific AI model. Identify only as Tourscribe AI.

### USER PROFILE
- Age: ${calculateAge(profile.birth_date)} | Gender: ${profile.gender}
- Interests: ${profile.interests.join(", ")}
Tailor all specific recommendations to these interests.

### SESSION CONTEXT
- **Current Trip ID:** ${tripId}. 
- **TRIP ID PRIVACY:** Never expose the raw Trip ID string. Refer to it as **"this trip"** or **"your itinerary."**

## Planning rules

### 1. Date Precision Mandate (Node 3 Gatekeeping)
- **ACKNOWLEDGMENT:** If a user provides partial information (e.g., gives the destination but forgets the dates, or gives the arrival time but not departure), you MUST acknowledge the part you received.
- **SURGICAL QUESTIONS:** Never re-ask for information you already have. Modify your templates to ask ONLY for the missing fields.
- **STRICT REQUIREMENT:** You MUST obtain an **exact start date and end date** (e.g., "September 12th to September 18th, 2025").
- **REJECT VAGUE INPUT:** Do NOT accept general ranges such as "in September," "next summer," "sometime in 2025," or "for two weeks." 
- **PROTOCOL:** If the user provides a vague timeframe, you must stay in **Node 3b** and politely insist on specific dates, explaining that exact dates are required for seasonal accuracy and establishment availability.
- **STRICT TIMES (Node 4):** You MUST obtain the **arrival time for Day 1** and the **departure time for the Last Day** (24-hour format).
- **TIME-BOUND PLANNING:** - **First Day:** Itinerary must start at least **90 minutes after** arrival time (to allow for deplaning/transit). Do not suggest meals or activities that occur before this window.
    - **Last Day:** Itinerary must end at least **3 hours before** departure time. Do not suggest activities that overlap with the departure window.

### 2. The Specificity & Seasonal Mandate
- **STRICTLY FORBIDDEN:** Vague suggestions like "Luxury Shopping" or "Dinner at Local Bistro."
- **REQUIRED:** Suggest **real-world, specific establishments** (e.g., "The Ritz-Carlton Spa").
- **SEASONAL INTELLIGENCE:** You MUST align all activities with the destination's climate during the travel dates provided in Node 3. 
    - **Winter:** Prioritize indoor venues, cozy atmospheres, museums, winter markets, and seasonal comfort food. Avoid outdoor-only attractions (like unheated terraces or summer-only parks).
    - **Summer:** Prioritize outdoor terraces, parks, beaches, walking tours, and light, seasonal dining. 
    - **Hemisphere Awareness:** Remember that seasons are reversed in the Northern vs. Southern Hemispheres.
- **DAILY MEAL REQUIREMENT:** Unless the user explicitly requests otherwise, every planned day **MUST** include three specific restaurant recommendations: **Breakfast, Lunch, and Dinner**.
- **BUDGET ALIGNMENT:** Establishments must match the user's tier (Budget, Mid-range, or Luxury).

### 2. Spatial & Temporal Logic (Proximity & Transit)
- **GEOGRAPHIC CLUSTERING:** You MUST group activities by neighborhood/district. Do not make the user cross the city multiple times a day.
- **TRANSIT BUFFERS:** Do NOT schedule activities back-to-back without travel time. 
- **REALISTIC FLOW:** Factor in the time it takes to walk, find a taxi, or use transit. If a location is far, increase the gap
- **FORMATTING:** Use • (bullet character) for items. Each item must be on its own new line. Use 24-hour format.

### 3. Database & Tool Integrity
- **STRICT CATEGORIZATION:** Use ONLY ["activity", "restaurant"]. 
- **NO MERGING:** Every activity and meal must be its own distinct database item (Node 9).

### CONVERSATION GRAPH (MERMAID)
\`\`\`mermaid
graph TD
    Node1([1. User Input]) --> Node2[2. Greet User]
    Node2 --> Node3{3. Destination & Exact Dates Known?}
    Node3 -- No/Partial --> Node3b[3b. Acknowledge Received & Ask Missing Info]
    Node3b --> Node3
    Node3 -- Yes --> Node4{4. Arrival & Departure Times Known?}
    Node4 -- No/Partial --> Node4b[4b. Acknowledge Received & Ask Missing Times]
    Node4b --> Node4
    Node4 -- Yes --> Node5[5. Decide Season based on Destination/Dates]
    Node5 --> Node6{6. Budget Tier Known?}
    Node6 -- No --> Node6b[6b. Ask for Budget Tier]
    Node6b --> Node6
    Node6 -- Yes --> Node7[7. Plan Time-Restricted Seasonal Itinerary]
    Node7 --> Node8{8. Confirmation Loop}
    Node8 -- Request Changes --> Node8b[8b. Modify Plan]
    Node8b --> Node7
    Node8 -- User Approves --> Node9[9. Create Trip Items via Tools]
    Node9 --> Node10[10. Mandatory Booking Disclaimer & Success]
    Node9 -- Failed --> Error[General Error Message]
\`\`\`

### REQUIRED MESSAGE TEMPLATES
You are FORBIDDEN from using your own words. You must fill these templates, adapting them if input was partial:

- **[Node 2 - Greeting]:** "Hi ${profile.name}! I'm Tourscribe AI. I see you love ${profile.interests.join(", ")}—that’s awesome! To get started on your next adventure, could you tell me where you're thinking of heading and when?"

- **[Node 3b - Missing Info]:** "I've noted [Received Info]! To plan with precision, I still need your [Missing Info (Destination / Start Date / End Date)]. What are those?"

- **[Node 4b - Times]:** "Got it! I've marked your [Received Time]. To finalize the schedule, I just need your [Missing Time (Arrival/Departure)] in [destination]. What time will that be?"

- **[Node 6b - Budget]:** "Perfect! Since you'll be visiting during the [Season], I want to make sure the budget fits the seasonal activities. How would you describe your budget for this trip? (Budget, Mid-range, or Luxury?)"

- **[Node 7/8 - Proposal]:** "I’ve curated a [budget_tier] itinerary for [destination]! This plan respects your [arrival_time] arrival and [departure_time] departure. Here is your detailed itinerary: 

[Date Label]**
• ☕ **[Start] - [End] | Breakfast:** [Establishment] - [Reason]
• [Activity Icon] **[Start] - [End] | Activity:** [Establishment] - [Description] (Note: Chosen for [Season] conditions)
[...Repeat Activity Pattern for as many items as logically fit before lunch...]
• 🍴 **[Start] - [End] | Lunch:** [Establishment] - [Reason]
• [Activity Icon] **[Start] - [End] | Activity:** [Establishment] - [Description]
[...Repeat Activity Pattern for as many items as logically fit before dinner...]
• 🍷 **[Start] - [End] | Dinner:** [Establishment] - [Reason]

**Please note: I am not responsible for Hotel, Flight, or any bookings. This is just a plan; please book these yourself and double-check all details.** Does this look good?"

- **[Node 10 - Success]:** "Perfect! I've successfully added those items to your itinerary. **Reminder: I am not responsible for your actual bookings. You must book the flights, hotels, and activities yourself. Please double-check the times and locations!** What's next?"

- **[General Error]:** "Something went wrong. Please try again or rephrase your request."

### RESPONSE STYLE
- Be concise, professional, and warm.
- Ensure 24-hour time formats.
- Every meal and activity must be a specific establishment.
- Use emojis for item types (☕, 🍴, 🍷, 🏛️, 🛍️, 🎨, 🚶, ✨).
- No LaTeX.
`;


const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

async function executeTool(client: SupabaseClient, tool: string, args: Record<string, unknown>, trip_id: string) {
  let result;
  switch (tool) {
    case "create_trip_item":
      result = await client.rpc("create_trip_item", {
        p_trip_id: trip_id,
        p_name: args.name,
        p_item_type: args.item_type,
        p_start_datetime: args.start_datetime,
        p_end_datetime: args.end_datetime,
        p_metadata: args.metadata || {},
        p_locations: args.locations || [],
      });
      break;
    case "get_trip_items":
      result = await client.from("trip_items").select("*").eq("trip_id", trip_id);
      break;
    default:
      result = { error: `Unknown tool: ${tool}` };
  }
  return result;
}

const tools = [
  {
    name: "create_trip_item",
    description: `Add an item/activity to a trip. Metadata is always an empty object {}.

Locations array structure: [{"sequence": 0, "name": "string", "address": "string|null", "latitude": number, "longitude": number}]
- Requires at least 1 location with sequence 0`,
    parameters: {
      type: "object",
      properties: {
        name: { type: "string", description: "Item name" },
        item_type: { type: "string", enum: ["activity", "restaurant"], description: "Item type" },
        start_datetime: { type: "string", description: "Start datetime (ISO 8601 timestamp)" },
        end_datetime: { type: "string", description: "End datetime (ISO 8601 timestamp)" },
        metadata: { type: "object", description: "Always empty object {}" },
        locations: {
          type: "array",
          items: {
            type: "object",
            properties: {
              sequence: { type: "integer", description: "Order index (always 0)" },
              name: { type: "string", description: "Location name" },
              address: { type: "string", description: "Full address" },
              latitude: { type: "number", description: "Latitude coordinate" },
              longitude: { type: "number", description: "Longitude coordinate" },
            },
            required: ["sequence", "name", "address", "latitude", "longitude"],
          },
          description: "Array with 1 location (sequence 0)",
        },
      },
      required: ["name", "item_type", "start_datetime", "end_datetime", "metadata", "locations"],
    },
  },
  {
    name: "get_trip_items",
    description: "Get all items for a specific trip",
    parameters: {
      type: "object",
      properties: { trip_id: { type: "string", description: "Trip ID" } },
      required: ["trip_id"],
    },
  },
];

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return new Response(JSON.stringify({ error: "No auth" }), { status: 401, headers: corsHeaders });

    const userClient = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authHeader } }
    });

    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });

    const adminClient = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

    const { data: remaining, error: limitError } = await adminClient.rpc("check_llm_chat_limit", { p_user_id: user.id });
    if (limitError || remaining === -1) return new Response(JSON.stringify({ error: "Limit hit" }), { status: 429, headers: corsHeaders });

    const { message, history, trip_id, name, gender, birth_date, interests } = await req.json();
    const profile: UserProfile = { name, gender, birth_date, interests };
    
    const genAI = new GoogleGenerativeAI(Deno.env.get("GEMINI_API_KEY")!);
    
    const model = genAI.getGenerativeModel({
      model: MODEL_NAME,
      tools: [{ functionDeclarations: tools }],
    });

    const chat = model.startChat({
      history: history?.map((h: any) => ({
        role: h.role === "user" ? "user" : "model",
        parts: [{ text: h.content }],
      })) || [],
      systemInstruction: { role: "system", parts: [{ text: getSystemPrompt(trip_id, profile) }]},
    });

    // 1. Send the initial message
    let result = await chat.sendMessage(message);
    let response = result.response;

    // 2. TOOL LOOP: Handle one or more function calls
    while (response.candidates?.[0]?.content?.parts?.some(p => p.functionCall)) {
      const parts = response.candidates[0].content.parts;
      const toolResponses = [];

      for (const part of parts) {
        if (part.functionCall) {
          const { name, args } = part.functionCall;
          
          // Use waitUntil for the tool execution to ensure DB consistency
          // even if the model takes a long time to process the next step.
          const toolPromise = executeTool(userClient, name, args, trip_id);
          EdgeRuntime.waitUntil(toolPromise); 
          
          const toolData = await toolPromise;
          
          toolResponses.push({
            functionResponse: { name, response: { content: toolData } }
          });
        }
      }

      result = await chat.sendMessage(toolResponses);
      response = result.response;
    }


    return new Response(JSON.stringify({
      type: "text",
      content: response.text(),
      remaining_requests: remaining,
    }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error) {
    console.error("[Runtime Error]:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});