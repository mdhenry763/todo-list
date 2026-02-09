import { Logger } from "../_shared/logger.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getAuthenticatedUser } from "../_shared/auth.ts";

Deno.serve(async (req) => {
  const component = "Delete Task";

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    Logger.infoStructured("Delete task request received", component, {
      key: "method",
      value: req.method,
    });

    if (req.method !== "DELETE") {
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

    // Parse request body
    const { task_id } = await req.json();

    // Validate task_id
    if (!task_id) {
      return new Response(
        JSON.stringify({ message: "Task ID is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Verify task ownership
    const { data: existingTask } = await supabase
      .from("tasks")
      .select("id, user_id")
      .eq("id", task_id)
      .single();

    if (!existingTask) {
      return new Response(
        JSON.stringify({ message: "Task not found" }),
        {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (existingTask.user_id !== userId) {
      return new Response(
        JSON.stringify({ message: "Unauthorized to delete this task" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Delete task (subtasks will be cascaded)
    const { error: deleteError } = await supabase
      .from("tasks")
      .delete()
      .eq("id", task_id);

    if (deleteError) {
      Logger.error("Failed to delete task", component, deleteError);
      return new Response(
        JSON.stringify({
          message: "Failed to delete task",
          error: deleteError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    Logger.infoStructured("Task deleted successfully", component, {
      key: "taskId",
      value: task_id,
    });

    return new Response(
      JSON.stringify({
        message: "Task deleted successfully",
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