import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: _getTaskColor().withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: _getTaskColor().withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: _getTaskColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Icon(
                    Iconsax.task_square,
                    color: _getTaskColor(),
                    size: AppSizes.iconM,
                  ),
                ),
                const Spacer(),
                if (!compact)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Text(
                      task.status.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.textXS,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                const SizedBox(width: AppSizes.paddingS),
                _buildProgressCircle(),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              task.title,
              style: GoogleFonts.inter(
                fontSize: compact ? AppSizes.textM : AppSizes.textL,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              task.description,
              style: GoogleFonts.inter(
                fontSize: AppSizes.textS,
                color: AppColors.textSecondary,
              ),
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!compact && task.subTasks.isNotEmpty) ...[
              const SizedBox(height: AppSizes.paddingM),
              _buildSubTasksPreview(),
            ],
            const SizedBox(height: AppSizes.paddingM),
            Row(
              children: [
                Icon(
                  Iconsax.calendar,
                  size: AppSizes.iconS,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.paddingXS),
                Text(
                  task.formattedDueDate.isNotEmpty
                      ? 'Due: ${task.formattedDueDate}'
                      : 'No due date',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.textXS,
                    color: task.isOverdue
                        ? AppColors.error
                        : AppColors.textSecondary,
                    fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle() {
    return SizedBox(
      width: 48,
      height: 48,
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

  Widget _buildSubTasksPreview() {
    final completedCount = task.completedSubTasksCount;
    final totalCount = task.subTasks.length;

    return Row(
      children: [
        Icon(
          Iconsax.tick_circle,
          size: AppSizes.iconS,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSizes.paddingXS),
        Text(
          '$completedCount/$totalCount subtasks',
          style: GoogleFonts.inter(
            fontSize: AppSizes.textXS,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}