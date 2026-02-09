import { Logger } from "../_shared/logger.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getAuthenticatedUser } from "../_shared/auth.ts";

Deno.serve(async (req) => {
  const component = "Create SubTask";

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    Logger.infoStructured("Create subtask request received", component, {
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

    // Parse request body
    const { task_id, title, order_index } = await req.json();

    // Validate required fields
    if (!task_id) {
      return new Response(
        JSON.stringify({ message: "Task ID is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (!title?.trim()) {
      return new Response(
        JSON.stringify({ message: "Title is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Verify task ownership
    const { data: task } = await supabase
      .from("tasks")
      .select("id, user_id")
      .eq("id", task_id)
      .single();

    if (!task) {
      return new Response(
        JSON.stringify({ message: "Task not found" }),
        {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (task.user_id !== userId) {
      return new Response(
        JSON.stringify({ message: "Unauthorized to create subtask for this task" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Get order index if not provided
    let finalOrderIndex = order_index;
    if (finalOrderIndex === undefined || finalOrderIndex === null) {
      const { data: existingSubtasks } = await supabase
        .from("sub_tasks")
        .select("order_index")
        .eq("task_id", task_id)
        .order("order_index", { ascending: false })
        .limit(1);

      finalOrderIndex = existingSubtasks && existingSubtasks.length > 0
        ? existingSubtasks[0].order_index + 1
        : 0;
    }

    // Create subtask
    const subTaskData = {
      task_id,
      title: title.trim(),
      is_completed: false,
      order_index: finalOrderIndex,
    };

    const { data: subTask, error: insertError } = await supabase
      .from("sub_tasks")
      .insert(subTaskData)
      .select()
      .single();

    if (insertError) {
      Logger.error("Failed to create subtask", component, insertError);
      return new Response(
        JSON.stringify({
          message: "Failed to create subtask",
          error: insertError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    Logger.infoStructured("SubTask created successfully", component, {
      key: "subTaskId",
      value: subTask.id,
    });

    return new Response(
      JSON.stringify({
        message: "SubTask created successfully",
        sub_task: subTask,
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