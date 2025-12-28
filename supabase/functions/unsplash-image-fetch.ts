// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
interface reqPayload {
  name: string;
}

/**
 * Image dimensions as constants
 */
const IMAGE_WIDTH = 1920;
const IMAGE_HEIGHT = 1080;

Deno.serve(async (req) => {
  // 1. Handle CORS for browser calls
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: { 'Access-Control-Allow-Origin': '*' } })
  }

  try {
    // 2. Get the search query from the request body or URL
    const { query } = await req.json();

    if (!query) {
      return new Response(JSON.stringify({ error: 'Query is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 3. Access environment variables (set these in Supabase Dashboard)
    const ACCESS_KEY = Deno.env.get('UNSPLASH_ACCESS_KEY');
    
    const searchParams = new URLSearchParams({
      query: query + " travel,city,nature,history",
      per_page: '1',
      orientation: 'landscape'
    });

    // 4. Fetch from Unsplash
    const response = await fetch(`https://api.unsplash.com/search/photos?${searchParams}`, {
      method: 'GET',
      headers: {
        'Authorization': `Client-ID ${ACCESS_KEY}`,
        'Accept-Version': 'v1'
      }
    });

    const data = await response.json();

    if (!data.results || data.results.length === 0) {
      return new Response(JSON.stringify({ error: 'No image found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const photo = data.results[0];

    // 5. Construct the dynamic URL with constants
    const imageUrl = `${photo.urls.raw}&w=${IMAGE_WIDTH}&h=${IMAGE_HEIGHT}&fit=crop&q=80&auto=format`;

    return new Response(
      JSON.stringify({ 
        url: imageUrl
      }),
      { 
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        status: 200 
      }
    );

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
})