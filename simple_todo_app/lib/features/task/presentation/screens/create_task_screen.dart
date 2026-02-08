import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:simple_todo_app/core/constants/app_constants.dart';
import 'package:simple_todo_app/core/custom_widgets.dart/custom_button.dart';
import 'package:simple_todo_app/core/custom_widgets.dart/custom_text_field.dart';
import 'package:simple_todo_app/data/models/task_model.dart';
import '../../controllers/task_controller.dart';

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final task = Get.arguments as Task?;
    final isEdit = task != null;

    final titleController = TextEditingController(text: task?.title);
    final descriptionController = TextEditingController(text: task?.description);
    final selectedDate = Rxn<DateTime>(task?.dueDate);
    final selectedTime = Rxn<DateTime>(task?.dueTime);
    final selectedPriority = (task?.priority ?? TaskPriority.medium).obs;
    final formKey = GlobalKey<FormState>();

    Future<void> selectDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: AppColors.cardBackground,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        selectedDate.value = picked;
      }
    }

    Future<void> selectTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          selectedTime.value ?? DateTime.now(),
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: AppColors.cardBackground,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        final now = DateTime.now();
        selectedTime.value = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isEdit ? AppStrings.updateTask : AppStrings.createTask,
          style: GoogleFonts.inter(
            fontSize: AppSizes.textL,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title
              CustomTextField(
                label: AppStrings.taskTitle,
                hint: 'Enter task title',
                controller: titleController,
                prefixIcon: Iconsax.edit,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Task title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Description
              CustomTextField(
                label: AppStrings.description,
                hint: 'Enter task description',
                controller: descriptionController,
                prefixIcon: Iconsax.document_text,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Priority Selection
              Text(
                'Priority',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.textS,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Obx(() => Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = selectedPriority.value == priority;
                  Color getColor() {
                    switch (priority) {
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

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSizes.paddingS),
                      child: GestureDetector(
                        onTap: () => selectedPriority.value = priority,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingM,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? getColor().withOpacity(0.2)
                                : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            border: Border.all(
                              color: isSelected
                                  ? getColor()
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              priority.name.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: AppSizes.textXS,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? getColor()
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
              const SizedBox(height: AppSizes.paddingM),

              // Due Date
              Text(
                AppStrings.dueDate,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.textS,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.calendar,
                              color: AppColors.textSecondary,
                              size: AppSizes.iconM,
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Obx(() => Text(
                              selectedDate.value != null
                                  ? DateFormat('MMM dd, yyyy')
                                      .format(selectedDate.value!)
                                  : 'Select date',
                              style: GoogleFonts.inter(
                                fontSize: AppSizes.textM,
                                color: selectedDate.value != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: GestureDetector(
                      onTap: selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.clock,
                              color: AppColors.textSecondary,
                              size: AppSizes.iconM,
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Obx(() => Text(
                              selectedTime.value != null
                                  ? DateFormat('h:mm a')
                                      .format(selectedTime.value!)
                                  : 'Select time',
                              style: GoogleFonts.inter(
                                fontSize: AppSizes.textM,
                                color: selectedTime.value != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingXL),

              // Create/Update Button
              Obx(() => CustomButton(
                text: isEdit ? 'Update Task' : 'Create Task',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (isEdit) {
                      taskController.updateTask(
                        taskId: task.id,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        dueDate: selectedDate.value,
                        dueTime: selectedTime.value,
                        priority: selectedPriority.value,
                      );
                    } else {
                      taskController.createTask(
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        dueDate: selectedDate.value,
                        dueTime: selectedTime.value,
                        priority: selectedPriority.value,
                      );
                    }
                  }
                },
                isLoading: taskController.isLoading.value,
                icon: isEdit ? Iconsax.tick_circle : Iconsax.add_circle,
              )),
            ],
          ),
        ),
      ),
    );
  }
}