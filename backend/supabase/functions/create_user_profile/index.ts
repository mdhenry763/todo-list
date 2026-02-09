import { Logger } from "../_shared/logger.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

console.log("Hello from Functions!");

Deno.serve(async (req) => {
  const component = "User Creation";
  Logger.infoStructured("user creation request received", component, {
    key: "method",
    value: req.method,
  });
  try {
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ message: "Method not allowed" }), {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ message: "Authorization required" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: { headers: { Authorization: authHeader } },
      },
    );

    // Get authenticated user
    const { data: { user: authUser }, error: authError } = await supabase.auth
      .getUser();

    if (authError || !authUser) {
      return new Response(JSON.stringify({ message: "Invalid auth token" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Check if user already exists
    const { data: existingUser, error: checkError } = await supabase
      .from("profiles")
      .select("id")
      .eq("id", authUser.id)
      .single();

    if (checkError && checkError.code !== "PGRST116") {
      return new Response(
        JSON.stringify({
          message: "Database error",
          error: checkError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (existingUser) {
      return new Response(JSON.stringify({ message: "User already exists" }), {
        status: 409,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Parse request body
    const {
      full_name,
      profile_image_url,
      ultimate_goal,
      email
    } = await req.json();

    // Validate required fields
    if (!full_name?.trim()) {
      return new Response(
        JSON.stringify({ message: "Full name is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (!profile_image_url?.trim()) {
      return new Response(
        JSON.stringify({ message: "Profile image URL is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (!ultimate_goal?.trim()) {
      return new Response(JSON.stringify({ message: "Ultimate goal is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Prepare user data - simple booleans only
    const userData = {
      id: authUser.id,
      email: authUser.email || authUser.user_metadata?.phone || email || null,
      full_name: full_name.trim(),
      profile_image_url: profile_image_url?.trim() || null,
      ultimate_goal: ultimate_goal.trim(),
    };

    // Insert user
    const { data: user, error: insertError } = await supabase
      .from("profiles")
      .insert(userData)
      .select()
      .single();

    if (insertError) {
      return new Response(
        JSON.stringify({
          message: "Failed to create user",
          error: insertError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    return new Response(
      JSON.stringify({
        message: "User created successfully",
        user: {
          id: user.id,
          full_name: user.full_name,
          email: user.email,
          profile_image_url: user.profile_image_url,
          ultimate_goal: user.ultimate_goal,
        },
      }),
      {
        status: 201,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({
        message: "Internal server error",
        error: err ?? "Failed",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/create_user_profile' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
