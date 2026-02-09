import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:simple_todo_app/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';

class SupabaseService extends GetxService {
  late final SupabaseClient _client;

  SupabaseClient get client => _client;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<SupabaseService> init() async {
    // Load environment variables

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
    } catch (e, stackTrace) {
      print('Sign in error: $e');

      print('Stack trace: $stackTrace');
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut(scope: SignOutScope.global);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Profile Methods
  Future<UserProfile?> getProfile(String userId) async {
    try {
      //Showing direct query for demonstration, 
      //but ideally this should be an edge function to avoid exposing the profiles table directly
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
      final response = await _client.functions.invoke(
        'create_user_profile',
        body: {
          'full_name': fullName,
          'ultimate_goal': ultimateGoal,
          'profile_image_url': profileImageUrl,
        },
      );

      if (response.status != 201) {
        throw Exception(response.data['message'] ?? 'Failed to create profile');
      }

      print('${response.data['profile']}');
      return UserProfile.fromJson(response.data['profile']);
    } catch (e, stackTrace) {
      print('Error creating profile: $e');
      print('Stack trace: $stackTrace');
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

      final now = DateTime.now();

      if (fullName != null) updateData['full_name'] = fullName;
      if (ultimateGoal != null) updateData['ultimate_goal'] = ultimateGoal;
      if (profileImageUrl != null)
        updateData['profile_image_url'] = profileImageUrl;

      final response = await _client.functions.invoke(
        'update_user_profile',
        body: {
          'user_id': userId,
          'full_name': fullName,
          'ultimate_goal': ultimateGoal,
          'profile_image_url': profileImageUrl,
          'updated_at': now.toIso8601String(),
        },
      );

      print('${response.data['profile']}');
      return UserProfile.fromJson(response.data['profile']);
    } catch (e, stackTrace) {
      print('Error updating profile: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to update profile: $e');
    }
  }

  // Task Methods
  Future<List<Task>> getTasks(String userId) async {
    try {
      final response = await _client.functions.invoke(
        'get_tasks',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        throw Exception(response.data['message'] ?? 'Failed to get tasks');
      }

      final tasks = (response.data['tasks'] as List)
          .map((task) => Task.fromJson(task))
          .toList();

      return tasks;
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
      final response = await _client.functions.invoke(
        'create_task',
        body: {
          'title': title,
          'description': description,
          'due_date': dueDate?.toIso8601String(),
          'due_time': dueTime?.toIso8601String(),
          'priority': (priority ?? TaskPriority.medium).name,
          'category': category,
        },
      );

      if (response.status != 201) {
        throw Exception(response.data['message'] ?? 'Failed to create task');
      }

      return Task.fromJson(response.data['task']);
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
      final body = <String, dynamic>{'task_id': taskId};

      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (dueDate != null) body['due_date'] = dueDate.toIso8601String();
      if (dueTime != null) body['due_time'] = dueTime.toIso8601String();
      if (progressPercentage != null) {
        body['progress_percentage'] = progressPercentage;
      }
      if (status != null) body['status'] = status.name;
      if (priority != null) body['priority'] = priority.name;
      if (category != null) body['category'] = category;

      final response = await _client.functions.invoke(
        'update_task',
        body: body,
      );

      if (response.status != 200) {
        throw Exception(response.data['message'] ?? 'Failed to update task');
      }

      return Task.fromJson(response.data['task']);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final response = await _client.functions.invoke(
        'delete_task',
        body: {'task_id': taskId},
        method: HttpMethod.delete,
      );

      if (response.status != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete task');
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // SubTask Methods using Edge Functions
  Future<SubTask> createSubTask({
    required String taskId,
    required String title,
    required int orderIndex,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'create_subtask',
        body: {'task_id': taskId, 'title': title, 'order_index': orderIndex},
      );

      if (response.status != 201) {
        throw Exception(response.data['message'] ?? 'Failed to create subtask');
      }

      return SubTask.fromJson(response.data['sub_task']);
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
      final body = <String, dynamic>{'subtask_id': subTaskId};

      if (title != null) body['title'] = title;
      if (isCompleted != null) body['is_completed'] = isCompleted;

      final response = await _client.functions.invoke(
        'update_subtask',
        body: body,
      );

      if (response.status != 200) {
        throw Exception(response.data['message'] ?? 'Failed to update subtask');
      }

      return SubTask.fromJson(response.data['sub_task']);
    } catch (e) {
      throw Exception('Failed to update subtask: $e');
    }
  }

  Future<void> deleteSubTask(String subTaskId) async {
    try {
      final response = await _client.functions.invoke(
        'delete_subtask',
        body: {'subtask_id': subTaskId},
        method: HttpMethod.delete,
      );

      if (response.status != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete subtask');
      }
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
