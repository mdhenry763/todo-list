import { Logger } from "../_shared/logger.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getAuthenticatedUser } from "../_shared/auth.ts";

Deno.serve(async (req) => {
  const component = "Update SubTask";

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    Logger.infoStructured("Update subtask request received", component, {
      key: "method",
      value: req.method,
    });

    if (req.method !== "PUT" && req.method !== "PATCH") {
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
    const { subtask_id, title, is_completed } = await req.json();

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
        JSON.stringify({ message: "Unauthorized to update this subtask" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Build update data
    const updateData: any = {};

    if (title !== undefined) {
      if (!title.trim()) {
        return new Response(
          JSON.stringify({ message: "Title cannot be empty" }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }
      updateData.title = title.trim();
    }

    if (is_completed !== undefined) {
      if (typeof is_completed !== "boolean") {
        return new Response(
          JSON.stringify({ message: "is_completed must be a boolean" }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }
      updateData.is_completed = is_completed;
    }

    // Check if there's anything to update
    if (Object.keys(updateData).length === 0) {
      return new Response(
        JSON.stringify({ message: "No fields to update" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Update subtask
    const { data: updatedSubTask, error: updateError } = await supabase
      .from("sub_tasks")
      .update(updateData)
      .eq("id", subtask_id)
      .select()
      .single();

    if (updateError) {
      Logger.error("Failed to update subtask", component, updateError);
      return new Response(
        JSON.stringify({
          message: "Failed to update subtask",
          error: updateError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    Logger.infoStructured("SubTask updated successfully", component, {
      key: "subTaskId",
      value: subtask_id,
    });

    return new Response(
      JSON.stringify({
        message: "SubTask updated successfully",
        sub_task: updatedSubTask,
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