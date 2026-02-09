import { Logger } from "../_shared/logger.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getAuthenticatedUser } from "../_shared/auth.ts";

Deno.serve(async (req) => {
  const component = "Update Task";

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    Logger.infoStructured("Update task request received", component, {
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
    const {
      task_id,
      title,
      description,
      due_date,
      due_time,
      progress_percentage,
      status,
      priority,
      category,
    } = await req.json();

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
        JSON.stringify({ message: "Unauthorized to update this task" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Build update data
    const updateData: any = {
      updated_at: new Date().toISOString(),
    };

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

    if (description !== undefined) {
      if (!description.trim()) {
        return new Response(
          JSON.stringify({ message: "Description cannot be empty" }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }
      updateData.description = description.trim();
    }

    if (due_date !== undefined) {
      updateData.due_date = due_date;
    }

    if (due_time !== undefined) {
      updateData.due_time = due_time;
    }

    if (progress_percentage !== undefined) {
      if (progress_percentage < 0 || progress_percentage > 100) {
        return new Response(
          JSON.stringify({ message: "Progress must be between 0 and 100" }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }
      updateData.progress_percentage = progress_percentage;
    }

    if (status !== undefined) {
      const validStatuses = ["pending", "inProgress", "completed"];
      if (!validStatuses.includes(status)) {
        return new Response(
          JSON.stringify({ message: "Invalid status value" }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }
      updateData.status = status;
    }

    if (priority !== undefined) {
      const validPriorities = ["low", "medium", "high", "urgent"];
      if (!validPriorities.includes(priority)) {
        return new Response(
          JSON.stringify({ message: "Invalid priority value" }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }
      updateData.priority = priority;
    }

    if (category !== undefined) {
      updateData.category = category?.trim() || null;
    }

    // Update task
    const { data: task, error: updateError } = await supabase
      .from("tasks")
      .update(updateData)
      .eq("id", task_id)
      .select()
      .single();

    if (updateError) {
      Logger.error("Failed to update task", component, updateError);
      return new Response(
        JSON.stringify({
          message: "Failed to update task",
          error: updateError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    Logger.infoStructured("Task updated successfully", component, {
      key: "taskId",
      value: task_id,
    });

    return new Response(
      JSON.stringify({
        message: "Task updated successfully",
        task,
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