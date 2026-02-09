import { Logger } from "../_shared/logger.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getAuthenticatedUser } from "../_shared/auth.ts";

Deno.serve(async (req) => {
  const component = "Create Task";

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    Logger.infoStructured("Create task request received", component, {
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
    const {
      title,
      description,
      due_date,
      due_time,
      priority,
      category,
    } = await req.json();

    // Validate required fields
    if (!title?.trim()) {
      return new Response(
        JSON.stringify({ message: "Title is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (!description?.trim()) {
      return new Response(
        JSON.stringify({ message: "Description is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Validate priority if provided
    const validPriorities = ["low", "medium", "high", "urgent"];
    if (priority && !validPriorities.includes(priority)) {
      return new Response(
        JSON.stringify({ message: "Invalid priority value" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Create task
    const now = new Date().toISOString();
    const taskData = {
      user_id: userId,
      title: title.trim(),
      description: description.trim(),
      due_date: due_date || null,
      due_time: due_time || null,
      progress_percentage: 0,
      status: "pending",
      priority: priority || "medium",
      category: category?.trim() || null,
      attachments: [],
      created_at: now,
      updated_at: now,
    };

    const { data: task, error: insertError } = await supabase
      .from("tasks")
      .insert(taskData)
      .select()
      .single();

    if (insertError) {
      Logger.error("Failed to create task", component, insertError);
      return new Response(
        JSON.stringify({
          message: "Failed to create task",
          error: insertError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    Logger.infoStructured("Task created successfully", component, {
      key: "taskId",
      value: task.id,
    });

    return new Response(
      JSON.stringify({
        message: "Task created successfully",
        task,
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