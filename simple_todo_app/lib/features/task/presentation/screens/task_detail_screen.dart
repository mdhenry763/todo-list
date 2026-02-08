import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:simple_todo_app/core/constants/app_constants.dart';
import 'package:simple_todo_app/core/custom_widgets.dart/custom_button.dart';
import 'package:simple_todo_app/data/models/task_model.dart';
import '../../controllers/task_controller.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final task = Get.arguments as Task;
    final progressValue = (task.progressPercentage / 100).obs;

    Color getTaskColor() {
      switch (task.priority) {
        case TaskPriority.urgent:
          return AppColors.error;
        case TaskPriority.high:
          return AppColors.primary;
        case TaskPriority.medium:
          return AppColors.info;
        case TaskPriority.low:
          return AppColors.success;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: getTaskColor(),
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.edit, color: Colors.white),
                onPressed: () => Get.toNamed('/create-task', arguments: task),
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, color: Colors.white),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      backgroundColor: AppColors.cardBackground,
                      title: Text(
                        'Delete Task',
                        style: GoogleFonts.inter(color: AppColors.textPrimary),
                      ),
                      content: Text(
                        'Are you sure you want to delete this task?',
                        style: GoogleFonts.inter(color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            taskController.deleteTask(task.id);
                            Get.back();
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      getTaskColor(),
                      getTaskColor().withOpacity(0.7),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.textXL,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      Row(
                        children: [
                          Icon(
                            Iconsax.calendar,
                            size: AppSizes.iconS,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: AppSizes.paddingXS),
                          Text(
                            task.formattedDueDate.isNotEmpty
                                ? '${task.formattedDueDate} ${task.formattedDueTime}'
                                : 'No due date',
                            style: GoogleFonts.inter(
                              fontSize: AppSizes.textS,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Section
                  Text(
                    'Description',
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Text(
                      task.description,
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.textM,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingL),

                  // Progress Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.textL,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Obx(() => Text(
                        '${(progressValue.value * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.textL,
                          fontWeight: FontWeight.w700,
                          color: AppColors.statusInProgress,
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Obx(() => SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                    ),
                    child: Slider(
                      value: progressValue.value,
                      onChanged: (value) => progressValue.value = value,
                      onChangeEnd: (value) {
                        taskController.updateTask(
                          taskId: task.id,
                          progressPercentage: (value * 100).toInt(),
                        );
                      },
                      activeColor: AppColors.statusInProgress,
                      inactiveColor: AppColors.cardBackground,
                    ),
                  )),
                  const SizedBox(height: AppSizes.paddingL),

                  // Sub Tasks Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sub Tasks',
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.textL,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.add_circle, color: AppColors.primary),
                        onPressed: () {
                          final controller = TextEditingController();
                          Get.dialog(
                            AlertDialog(
                              backgroundColor: AppColors.cardBackground,
                              title: Text(
                                'Add Sub Task',
                                style: GoogleFonts.inter(color: AppColors.textPrimary),
                              ),
                              content: TextField(
                                controller: controller,
                                style: GoogleFonts.inter(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Enter subtask title',
                                  hintStyle: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (controller.text.isNotEmpty) {
                                      taskController.createSubTask(
                                        taskId: task.id,
                                        title: controller.text.trim(),
                                      );
                                      Get.back();
                                    }
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  
                  // Sub Tasks List
                  Obx(() {
                    final currentTask = taskController.tasks
                        .firstWhereOrNull((t) => t.id == task.id);
                    
                    if (currentTask == null || currentTask.subTasks.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(AppSizes.paddingL),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Center(
                          child: Text(
                            'No subtasks yet',
                            style: GoogleFonts.inter(
                              fontSize: AppSizes.textS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: currentTask.subTasks.map((subTask) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => taskController.toggleSubTask(
                                  task.id,
                                  subTask.id,
                                ),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: subTask.isCompleted
                                        ? AppColors.success
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: subTask.isCompleted
                                          ? AppColors.success
                                          : AppColors.textSecondary,
                                      width: 2,
                                    ),
                                  ),
                                  child: subTask.isCompleted
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: AppSizes.paddingM),
                              Expanded(
                                child: Text(
                                  subTask.title,
                                  style: GoogleFonts.inter(
                                    fontSize: AppSizes.textM,
                                    color: subTask.isCompleted
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                    decoration: subTask.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: AppSizes.paddingXL),

                  // Complete Task Button
                  Obx(() => CustomButton(
                    text: task.status == TaskStatus.completed
                        ? 'Mark as Incomplete'
                        : 'Mark as Complete',
                    onPressed: () => taskController.toggleTaskStatus(task.id),
                    backgroundColor: task.status == TaskStatus.completed
                        ? AppColors.textSecondary
                        : AppColors.success,
                    icon: Iconsax.tick_circle,
                    isLoading: taskController.isLoading.value,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}