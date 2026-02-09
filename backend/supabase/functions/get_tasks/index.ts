import { Logger } from "../_shared/logger.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getAuthenticatedUser } from "../_shared/auth.ts";

Deno.serve(async (req) => {
  const component = "Get Tasks";

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    Logger.infoStructured("Get tasks request received", component, {
      key: "method",
      value: req.method,
    });

    if (req.method !== "GET") {
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

    // Get tasks with subtasks
    const { data: tasks, error: tasksError } = await supabase
      .from("tasks")
      .select("*, sub_tasks(*)")
      .eq("user_id", userId)
      .order("due_date", { ascending: true, nullsFirst: false });

    if (tasksError) {
      Logger.error("Failed to get tasks", component, tasksError);
      return new Response(
        JSON.stringify({
          message: "Failed to get tasks",
          error: tasksError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    Logger.infoStructured("Tasks retrieved successfully", component, {
      key: "count",
      value: tasks?.length || 0,
    });

    return new Response(
      JSON.stringify({
        message: "Tasks retrieved successfully",
        tasks: tasks || [],
      }),
      {
        status: 200,
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