import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../utils/app_utils.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;

    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final subtasks =
            task.id != null ? provider.getSubTasks(task.id!) : [];
        final tags =
            task.id != null ? provider.getTagsForTask(task.id!) : [];
        final hasSubtasks = subtasks.isNotEmpty;
        final subProgress =
            hasSubtasks ? provider.getSubTaskProgress(task.id!) : 0.0;
        final subProgressText =
            hasSubtasks ? provider.getSubTaskProgressText(task.id!) : '';

        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => onEdit(),
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                icon: Icons.edit_outlined,
                label: 'Sửa',
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(width: 8),
              SlidableAction(
                onPressed: (_) => onDelete(),
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: 'Xóa',
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Material(
              color: AppColors.surfaceContainer(context),
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: GestureDetector(
                          onTap: onToggleComplete,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: task.isCompleted
                                  ? AppColors.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: task.isCompleted
                                    ? AppColors.primary
                                    : AppColors.outline(context),
                                width: 2,
                              ),
                            ),
                            child: task.isCompleted
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: task.isCompleted
                                          ? AppColors.textTertiary(context)
                                          : AppColors.textPrimary(context),
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                                if (task.isRecurring) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.refresh,
                                      size: 14, color: AppColors.info),
                                ],
                                if (task.hasReminder) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.notifications_outlined,
                                      size: 14, color: AppColors.primary),
                                ],
                              ],
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],

                            // Sub-tasks progress
                            if (hasSubtasks) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.checklist,
                                      size: 12,
                                      color:
                                          AppColors.textSecondary(context)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: subProgress,
                                        backgroundColor:
                                            AppColors.outline(context)
                                                .withValues(alpha: 0.2),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                AppColors.primary),
                                        minHeight: 4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    subProgressText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 8),

                            // Bottom row: category, tags, time
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _chip(
                                  context,
                                  task.category.label,
                                  task.category.color,
                                  task.category.icon,
                                ),
                                ...tags.take(2).map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: tag.color.withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '#${tag.name}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: tag.color,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )),
                                if (tags.length > 2)
                                  Text(
                                    '+${tags.length - 2}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 12,
                                  color: isOverdue
                                      ? AppColors.error
                                      : AppColors.textSecondary(context),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppDateUtils.formatFriendlyWithTime(
                                      task.dueDate),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isOverdue
                                        ? AppColors.error
                                        : AppColors.textSecondary(context),
                                    fontWeight: isOverdue
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Priority bar
                      Container(
                        width: 4,
                        height: 60,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: task.priority.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chip(BuildContext context, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}