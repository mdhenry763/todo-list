import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:simple_todo_app/core/constants/app_constants.dart';
import 'package:simple_todo_app/data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final bool compact;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.compact = false,
  });

  Color _getTaskColor() {
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

  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.completed:
        return AppColors.success;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.pending:
        return AppColors.statusPending;
    }
  }

  String _getFormattedTime() {
    if (task.dueTime != null) {
      return DateFormat('h:mm a').format(task.dueTime!);
    } else if (task.dueDate != null) {
      return DateFormat('h a').format(task.dueDate!);
    }
    return '--:--';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Time on the left
              SizedBox(
                width: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getFormattedTime(),
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.textS,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main card content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  margin: EdgeInsets.all(AppSizes.paddingXS),
                  decoration: BoxDecoration(
                    color: _getTaskColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    border: Border.all(
                      color: _getTaskColor().withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Left side - Task info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              task.title,
                              style: GoogleFonts.inter(
                                fontSize: AppSizes.textM,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSizes.paddingXS),
                            
                            // Description
                            Text(
                              task.description,
                              style: GoogleFonts.inter(
                                fontSize: AppSizes.textS,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSizes.paddingS),
                            
                            // Date
                            Row(
                              children: [
                                Icon(
                                  Iconsax.calendar,
                                  size: AppSizes.iconS,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSizes.paddingXS),
                                Expanded(
                                  child: Text(
                                    task.formattedDueDate.isNotEmpty
                                        ? task.formattedDueDate
                                        : 'No due date',
                                    style: GoogleFonts.inter(
                                      fontSize: AppSizes.textXS,
                                      color: task.isOverdue
                                          ? AppColors.error
                                          : AppColors.textSecondary,
                                      fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: AppSizes.paddingM),
                      
                      // Right side - Progress percentage
                      _buildProgressCircle(),
                    ],
                  ),
                ),
              ),
            ],
          ),
           SizedBox(height: AppSizes.paddingM),
           Divider()
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: task.progressPercentage / 100,
            backgroundColor: AppColors.cardBackground,
            valueColor: AlwaysStoppedAnimation<Color>(_getTaskColor()),
            strokeWidth: 4,
          ),
          Center(
            child: Text(
              '${task.progressPercentage}%',
              style: GoogleFonts.inter(
                fontSize: AppSizes.textXS,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}