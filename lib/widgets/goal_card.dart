import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../services/task_provider.dart';
import '../utils/app_utils.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        // Tính progress của goal
        final goalTasks =
            provider.allTasks.where((t) => t.goalId == goal.id).toList();
        final totalTasks = goalTasks.length;
        final completedTasks =
            goalTasks.where((t) => t.isCompleted).length;
        final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
        final daysLeft =
            goal.targetDate.difference(DateTime.now()).inDays;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border(context),
              width: 0.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Icon goal
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: goal.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(goal.icon, color: goal.color, size: 22),
                        ),
                        const SizedBox(width: 12),

                        // Tiêu đề và ngày
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.event,
                                      size: 11,
                                      color: AppColors.textSecondary(
                                          context)),
                                  const SizedBox(width: 3),
                                  Text(
                                    AppDateUtils.formatFriendly(
                                        goal.targetDate),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: daysLeft < 0
                                          ? AppColors.danger
                                          : AppColors.textSecondary(context),
                                      fontWeight: daysLeft < 0
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Menu
                        if (onEdit != null || onDelete != null)
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert,
                                size: 18,
                                color: AppColors.textSecondary(context)),
                            onSelected: (value) {
                              if (value == 'edit') onEdit?.call();
                              if (value == 'delete') onDelete?.call();
                            },
                            itemBuilder: (_) => [
                              if (onEdit != null)
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 16),
                                      SizedBox(width: 8),
                                      Text('Sửa'),
                                    ],
                                  ),
                                ),
                              if (onDelete != null)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete,
                                          size: 16, color: AppColors.danger),
                                      SizedBox(width: 8),
                                      Text('Xóa',
                                          style: TextStyle(
                                              color: AppColors.danger)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),

                    if (goal.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        goal.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.border(context),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(goal.color),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: goal.color,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Text(
                          '$completedTasks/$totalTasks công việc',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        const Spacer(),
                        if (daysLeft >= 0)
                          Text(
                            'Còn $daysLeft ngày',
                            style: TextStyle(
                              fontSize: 11,
                              color: daysLeft <= 7
                                  ? AppColors.warning
                                  : AppColors.textSecondary(context),
                              fontWeight: daysLeft <= 7
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          )
                        else
                          Text(
                            'Quá hạn ${-daysLeft} ngày',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.danger,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}