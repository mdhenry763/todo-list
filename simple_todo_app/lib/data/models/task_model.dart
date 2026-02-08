import 'package:intl/intl.dart';

enum TaskStatus { pending, inProgress, completed }

enum TaskPriority { low, medium, high, urgent }

class Task {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final DateTime? dueTime;
  final int progressPercentage;
  final TaskStatus status;
  final TaskPriority priority;
  final List<SubTask> subTasks;
  final List<String> attachments;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.dueDate,
    this.dueTime,
    this.progressPercentage = 0,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    this.subTasks = const [],
    this.attachments = const [],
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'] as String) 
          : null,
      dueTime: json['due_time'] != null 
          ? DateTime.parse(json['due_time'] as String) 
          : null,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      subTasks: (json['sub_tasks'] as List<dynamic>?)
              ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'due_time': dueTime?.toIso8601String(),
      'progress_percentage': progressPercentage,
      'status': status.name,
      'priority': priority.name,
      'sub_tasks': subTasks.map((e) => e.toJson()).toList(),
      'attachments': attachments,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDueDate {
    if (dueDate == null) return '';
    return DateFormat('MMM dd, yyyy').format(dueDate!);
  }

  String get formattedDueTime {
    if (dueTime == null) return '';
    return DateFormat('h:mm a').format(dueTime!);
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now()) && status != TaskStatus.completed;
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  int get completedSubTasksCount {
    return subTasks.where((st) => st.isCompleted).length;
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? dueTime,
    int? progressPercentage,
    TaskStatus? status,
    TaskPriority? priority,
    List<SubTask>? subTasks,
    List<String>? attachments,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      subTasks: subTasks ?? this.subTasks,
      attachments: attachments ?? this.attachments,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SubTask {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final int orderIndex;

  SubTask({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isCompleted,
    required this.orderIndex,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool,
      orderIndex: json['order_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'is_completed': isCompleted,
      'order_index': orderIndex,
    };
  }

  SubTask copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    int? orderIndex,
  }) {
    return SubTask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}