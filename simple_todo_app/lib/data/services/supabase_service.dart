import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:simple_todo_app/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../models/task_model.dart';

class SupabaseService extends GetxService {
  late final SupabaseClient _client;

  SupabaseClient get client => _client;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<SupabaseService> init() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');

    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_PUBLIC_URL']!,
      anonKey: dotenv.env['SUPABASE_PUBLIC_KEY']!,
    );

    _client = Supabase.instance.client;
    return this;
  }

  // Auth Methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Profile Methods
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  Future<UserProfile> createProfile({
    required String userId,
    required String email,
    required String fullName,
    required String ultimateGoal,
    String? profileImageUrl,
  }) async {
    try {
      final now = DateTime.now();
      final profileData = {
        'id': userId,
        'email': email,
        'full_name': fullName,
        'ultimate_goal': ultimateGoal,
        'profile_image_url': profileImageUrl,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _client
          .from('profiles')
          .insert(profileData)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  Future<UserProfile> updateProfile({
    required String userId,
    String? fullName,
    String? ultimateGoal,
    String? profileImageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (ultimateGoal != null) updateData['ultimate_goal'] = ultimateGoal;
      if (profileImageUrl != null)
        updateData['profile_image_url'] = profileImageUrl;

      final response = await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Task Methods
  Future<List<Task>> getTasks(String userId) async {
    try {
      final response = await _client
          .from('tasks')
          .select('*, sub_tasks(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((task) => Task.fromJson(task)).toList();
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  Future<Task> createTask({
    required String userId,
    required String title,
    required String description,
    DateTime? dueDate,
    DateTime? dueTime,
    TaskPriority? priority,
    String? category,
  }) async {
    try {
      final now = DateTime.now();
      final taskData = {
        'user_id': userId,
        'title': title,
        'description': description,
        'due_date': dueDate?.toIso8601String(),
        'due_time': dueTime?.toIso8601String(),
        'progress_percentage': 0,
        'status': TaskStatus.pending.name,
        'priority': (priority ?? TaskPriority.medium).name,
        'category': category,
        'attachments': [],
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _client
          .from('tasks')
          .insert(taskData)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Task> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? dueTime,
    int? progressPercentage,
    TaskStatus? status,
    TaskPriority? priority,
    String? category,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (dueDate != null) updateData['due_date'] = dueDate.toIso8601String();
      if (dueTime != null) updateData['due_time'] = dueTime.toIso8601String();
      if (progressPercentage != null)
        updateData['progress_percentage'] = progressPercentage;
      if (status != null) updateData['status'] = status.name;
      if (priority != null) updateData['priority'] = priority.name;
      if (category != null) updateData['category'] = category;

      final response = await _client
          .from('tasks')
          .update(updateData)
          .eq('id', taskId)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _client.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // SubTask Methods
  Future<SubTask> createSubTask({
    required String taskId,
    required String title,
    required int orderIndex,
  }) async {
    try {
      final subTaskData = {
        'task_id': taskId,
        'title': title,
        'is_completed': false,
        'order_index': orderIndex,
      };

      final response = await _client
          .from('sub_tasks')
          .insert(subTaskData)
          .select()
          .single();

      return SubTask.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create subtask: $e');
    }
  }

  Future<SubTask> updateSubTask({
    required String subTaskId,
    String? title,
    bool? isCompleted,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title;
      if (isCompleted != null) updateData['is_completed'] = isCompleted;

      final response = await _client
          .from('sub_tasks')
          .update(updateData)
          .eq('id', subTaskId)
          .select()
          .single();

      return SubTask.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update subtask: $e');
    }
  }

  Future<void> deleteSubTask(String subTaskId) async {
    try {
      await _client.from('sub_tasks').delete().eq('id', subTaskId);
    } catch (e) {
      throw Exception('Failed to delete subtask: $e');
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(String userId, File file) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage.from('profiles').upload(fileName, file);

      final publicUrl = _client.storage.from('profiles').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
