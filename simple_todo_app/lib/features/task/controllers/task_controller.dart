import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:simple_todo_app/data/models/task_model.dart';
import 'package:simple_todo_app/data/services/supabase_service.dart';

class TaskController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final isLoading = false.obs;
  final tasks = <Task>[].obs;
  final filteredTasks = <Task>[].obs;
  
  List<Task> get todaysTasks => tasks.where((task) => task.isDueToday).toList();
  List<Task> get urgentTasks => tasks
      .where((task) => task.priority == TaskPriority.urgent && task.status != TaskStatus.completed)
      .toList();
  
  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((task) => task.status == TaskStatus.completed).length;
  int get progressPercentage => totalTasks > 0 ? ((completedTasks / totalTasks) * 100).round() : 0;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No user logged in');

      final loadedTasks = await _supabaseService.getTasks(user.id);
      tasks.value = loadedTasks;
      filteredTasks.value = loadedTasks;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTask({
    required String title,
    required String description,
    DateTime? dueDate,
    DateTime? dueTime,
    TaskPriority? priority,
    String? category,
  }) async {
    try {
      isLoading.value = true;

      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No user logged in');

      final newTask = await _supabaseService.createTask(
        userId: user.id,
        title: title,
        description: description,
        dueDate: dueDate,
        dueTime: dueTime,
        priority: priority,
        category: category,
      );

      tasks.insert(0, newTask);
      //filteredTasks.insert(0, newTask);

      Get.back();
      Get.snackbar(
        'Success',
        'Task created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create task: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTask({
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
      isLoading.value = true;

      final updatedTask = await _supabaseService.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        dueDate: dueDate,
        dueTime: dueTime,
        progressPercentage: progressPercentage,
        status: status,
        priority: priority,
        category: category,
      );

      final index = tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        tasks[index] = updatedTask;
        filteredTasks[index] = updatedTask;
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Task updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      isLoading.value = true;

      await _supabaseService.deleteTask(taskId);

      tasks.removeWhere((task) => task.id == taskId);
      filteredTasks.removeWhere((task) => task.id == taskId);

      Get.snackbar(
        'Success',
        'Task deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete task: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleTaskStatus(String taskId) async {
    final task = tasks.firstWhere((t) => t.id == taskId);
    final newStatus = task.status == TaskStatus.completed 
        ? TaskStatus.inProgress 
        : TaskStatus.completed;
    
    await updateTask(
      taskId: taskId,
      status: newStatus,
      progressPercentage: newStatus == TaskStatus.completed ? 100 : task.progressPercentage,
    );
  }

  Future<void> createSubTask({
    required String taskId,
    required String title,
  }) async {
    try {
      final task = tasks.firstWhere((t) => t.id == taskId);
      final orderIndex = task.subTasks.length;

      final newSubTask = await _supabaseService.createSubTask(
        taskId: taskId,
        title: title,
        orderIndex: orderIndex,
      );

      final updatedSubTasks = [...task.subTasks, newSubTask];
      final index = tasks.indexWhere((t) => t.id == taskId);
      
      if (index != -1) {
        tasks[index] = task.copyWith(subTasks: updatedSubTasks);
        filteredTasks[index] = task.copyWith(subTasks: updatedSubTasks);
      }

      Get.snackbar(
        'Success',
        'Subtask created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create subtask: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleSubTask(String taskId, String subTaskId) async {
    try {
      final task = tasks.firstWhere((t) => t.id == taskId);
      final subTask = task.subTasks.firstWhere((st) => st.id == subTaskId);
      
      await _supabaseService.updateSubTask(
        subTaskId: subTaskId,
        isCompleted: !subTask.isCompleted,
      );

      await loadTasks();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update subtask: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void filterTasks(String query) {
    if (query.isEmpty) {
      filteredTasks.value = tasks;
    } else {
      filteredTasks.value = tasks
          .where((task) =>
              task.title.toLowerCase().contains(query.toLowerCase()) ||
              task.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}