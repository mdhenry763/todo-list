import { Logger } from "../_shared/logger.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getAuthenticatedUser } from "../_shared/auth.ts";

Deno.serve(async (req) => {
  const component = "Delete SubTask";

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    Logger.infoStructured("Delete subtask request received", component, {
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
    const { subtask_id } = await req.json();

    // Validate subtask_id
    if (!subtask_id) {
      return new Response(
        JSON.stringify({ message: "SubTask ID is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Verify subtask ownership through parent task
    const { data: subTask } = await supabase
      .from("sub_tasks")
      .select("id, task_id, tasks(user_id)")
      .eq("id", subtask_id)
      .single();

    if (!subTask) {
      return new Response(
        JSON.stringify({ message: "SubTask not found" }),
        {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Check ownership through the parent task
    const taskUserId = (subTask.tasks as any)?.user_id;
    if (taskUserId !== userId) {
      return new Response(
        JSON.stringify({ message: "Unauthorized to delete this subtask" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Delete subtask
    const { error: deleteError } = await supabase
      .from("sub_tasks")
      .delete()
      .eq("id", subtask_id);

    if (deleteError) {
      Logger.error("Failed to delete subtask", component, deleteError);
      return new Response(
        JSON.stringify({
          message: "Failed to delete subtask",
          error: deleteError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    Logger.infoStructured("SubTask deleted successfully", component, {
      key: "subTaskId",
      value: subtask_id,
    });

    return new Response(
      JSON.stringify({
        message: "SubTask deleted successfully",
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