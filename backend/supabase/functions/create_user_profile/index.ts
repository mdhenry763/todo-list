import { Logger } from "../_shared/logger.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getAuthenticatedUser } from "../_shared/auth.ts";

Deno.serve(async (req) => {
  const component = "Create Profile";

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    Logger.infoStructured("Create profile request received", component, {
      key: "method",
      value: req.method,
    });

    if (req.method !== "POST") {
      return new Response(JSON.stringify({ message: "Method not allowed" }), {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Authenticate user
    const auth = await getAuthenticatedUser(req);
    if (!auth) {
      return new Response(
        JSON.stringify({ message: "Authentication required" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const { supabase, userId } = auth;

    // Check if profile already exists
    const { data: existingProfile } = await supabase
      .from("profiles")
      .select("id")
      .eq("id", userId)
      .single();

    if (existingProfile) {
      return new Response(
        JSON.stringify({ message: "Profile already exists" }),
        {
          status: 409,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Parse request body
    const { full_name, profile_image_url, ultimate_goal } = await req.json();

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

    if (!ultimate_goal?.trim()) {
      return new Response(
        JSON.stringify({ message: "Ultimate goal is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Get user email
    const { data: { user } } = await supabase.auth.getUser();

    // Create profile
    const now = new Date().toISOString();
    const profileData = {
      id: userId,
      email: user?.email || null,
      full_name: full_name.trim(),
      profile_image_url: profile_image_url?.trim() || null,
      ultimate_goal: ultimate_goal.trim(),
      created_at: now,
      updated_at: now,
    };

    const { data: profile, error: insertError } = await supabase
      .from("profiles")
      .insert(profileData)
      .select()
      .single();

    if (insertError) {
      Logger.error("Failed to create profile", component, insertError);
      return new Response(
        JSON.stringify({
          message: "Failed to create profile",
          error: insertError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    Logger.infoStructured("Profile created successfully", component, {
      key: "userId",
      value: userId,
    });

    return new Response(
      JSON.stringify({
        message: "Profile created successfully",
        profile,
      }),
      {
        status: 201,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (err) {
    Logger.error("Internal server error", component, err);
    return new Response(
      JSON.stringify({
        message: "Internal server error",
        error: err instanceof Error ? err.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});