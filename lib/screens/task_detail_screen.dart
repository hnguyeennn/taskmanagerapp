import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../services/task_provider.dart';
import '../utils/app_utils.dart';
import 'add_edit_task_screen.dart';
import 'pomodoro_screen.dart';
import '../services/streak_service.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Chi tiết'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => AddEditTaskScreen(task: task)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          // Lấy task mới nhất từ provider
          final currentTask = provider.allTasks.firstWhere(
            (t) => t.id == task.id,
            orElse: () => task,
          );
          final subtasks = provider.getSubTasks(currentTask.id ?? 0);
          final tags = provider.getTagsForTask(currentTask.id ?? 0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(currentTask),
                const SizedBox(height: 16),

                if (currentTask.description.isNotEmpty)
                  _infoCard(context, Icons.description, 'Mô tả',
                      currentTask.description,
                      AppColors.primary, AppColors.primaryLight),

                _infoCard(
                    context,
                    Icons.calendar_today,
                    'Hạn hoàn thành',
                    AppDateUtils.formatFull(currentTask.dueDate),
                    AppColors.primary,
                    AppColors.primaryLight),

                _infoCard(
                    context,
                    currentTask.category.icon,
                    'Danh mục',
                    currentTask.category.label,
                    currentTask.category.color,
                    currentTask.category.color.withValues(alpha: 0.15)),

                _infoCard(context, Icons.flag, 'Mức ưu tiên',
                    currentTask.priority.label,
                    currentTask.priority.color,
                    currentTask.priority.color.withValues(alpha: 0.15)),

                // MỚI: Hiển thị Lặp lại
                if (currentTask.isRecurring)
                  _infoCard(
                      context,
                      currentTask.recurringType.icon,
                      'Lặp lại',
                      currentTask.recurringType.label +
                          (currentTask.recurringEndDate != null
                              ? ' (đến ${AppDateUtils.formatFriendly(currentTask.recurringEndDate!)})'
                              : ''),
                      AppColors.info,
                      AppColors.info.withValues(alpha: 0.15)),

                if (currentTask.hasReminder &&
                    currentTask.reminderTime != null)
                  _infoCard(
                      context,
                      Icons.notifications_active,
                      'Nhắc nhở lúc',
                      AppDateUtils.formatFull(
                          currentTask.reminderTime!),
                      AppColors.warning,
                      AppColors.warning.withValues(alpha: 0.15)),

                // MỚI: Hiển thị Tags
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.label,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text('Nhãn',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(context),
                                )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: tags
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: tag.color.withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(color: tag.color),
                                    ),
                                    child: Text(
                                      '#${tag.name}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: tag.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],

                // MỚI: Hiển thị Sub-tasks
                if (subtasks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildSubTasksSection(context, currentTask, subtasks),
                ],

                const SizedBox(height: 24),

                // Nút Pomodoro + Hoàn thành
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PomodoroScreen(task: currentTask),
                            ),
                          );
                        },
                        icon: const Text('🍅',
                            style: TextStyle(fontSize: 18)),
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Pomodoro',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                            if (currentTask.pomodoroCount > 0)
                              Text(
                                'Đã ${currentTask.pomodoroCount} phiên',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 10),
                              ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await context
                              .read<TaskProvider>()
                              .toggleComplete(currentTask);
                          if (context.mounted) {
                            await context
                                .read<StreakService>()
                                .refresh();
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: Icon(
                          currentTask.isCompleted
                              ? Icons.undo
                              : Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          currentTask.isCompleted
                              ? 'Bỏ đánh dấu'
                              : 'Hoàn thành',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentTask.isCompleted
                              ? AppColors.warning
                              : AppColors.success,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(Task task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: task.isCompleted
              ? [AppColors.success, const Color(0xFF2F855A)]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                task.isCompleted ? Icons.check_circle : Icons.access_time,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                task.isCompleted ? 'Đã hoàn thành' : 'Đang chờ',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (task.isRecurring) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh,
                          color: Colors.white, size: 10),
                      const SizedBox(width: 2),
                      Text(
                        task.recurringType.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTasksSection(
      BuildContext context, Task task, List<SubTask> subtasks) {
    final completedCount = subtasks.where((s) => s.isCompleted).length;
    final progress = completedCount / subtasks.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Công việc con',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  )),
              const Spacer(),
              Text('$completedCount/${subtasks.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(context),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border(context),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 12),
          ...subtasks.map((sub) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () =>
                    context.read<TaskProvider>().toggleSubTask(sub),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sub.isCompleted
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: sub.isCompleted
                              ? AppColors.primary
                              : AppColors.border(context),
                          width: 1.5,
                        ),
                      ),
                      child: sub.isCompleted
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sub.title,
                        style: TextStyle(
                          fontSize: 13,
                          color: sub.isCompleted
                              ? AppColors.textSecondary(context)
                              : AppColors.textPrimary(context),
                          decoration: sub.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context, IconData icon, String label,
      String value, Color iconColor, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context))),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        title: Text('Xóa công việc?',
            style: TextStyle(color: AppColors.textPrimary(context))),
        content: Text('Bạn có chắc muốn xóa "${task.title}"?',
            style: TextStyle(color: AppColors.textSecondary(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<TaskProvider>().deleteTask(task.id!);
      if (context.mounted) Navigator.pop(context);
    }
  }
}