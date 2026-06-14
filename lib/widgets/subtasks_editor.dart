import 'package:flutter/material.dart';
import '../models/subtask.dart';
import '../utils/app_utils.dart';

class SubTasksEditor extends StatefulWidget {
  final List<SubTask> initialSubTasks;
  final int? taskId;
  final ValueChanged<List<SubTask>> onChanged;

  const SubTasksEditor({
    super.key,
    required this.initialSubTasks,
    this.taskId,
    required this.onChanged,
  });

  @override
  State<SubTasksEditor> createState() => _SubTasksEditorState();
}

class _SubTasksEditorState extends State<SubTasksEditor> {
  late List<SubTask> _subtasks;
  final TextEditingController _newSubController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subtasks = List.from(widget.initialSubTasks);
  }

  @override
  void dispose() {
    _newSubController.dispose();
    super.dispose();
  }

  void _addSubTask() {
    final text = _newSubController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _subtasks.add(SubTask(
        taskId: widget.taskId ?? 0,
        title: text,
        sortOrder: _subtasks.length,
      ));
      _newSubController.clear();
    });
    widget.onChanged(_subtasks);
  }

  void _toggleSubTask(int index) {
    setState(() {
      _subtasks[index] = _subtasks[index].copyWith(
        isCompleted: !_subtasks[index].isCompleted,
      );
    });
    widget.onChanged(_subtasks);
  }

  void _removeSubTask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
    widget.onChanged(_subtasks);
  }

  void _reorderSubTasks(int oldIndex, int newIndex) {
    setState(() {
      final item = _subtasks.removeAt(oldIndex);
      _subtasks.insert(newIndex, item);
    });
    widget.onChanged(_subtasks);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _subtasks.where((s) => s.isCompleted).length;
    final progress = _subtasks.isEmpty ? 0.0 : completedCount / _subtasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thanh progress
        if (_subtasks.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border(context),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$completedCount/${_subtasks.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Danh sách sub-tasks (có thể kéo thả)
        if (_subtasks.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _subtasks.length,
            onReorderItem: _reorderSubTasks,
            itemBuilder: (context, index) {
              final sub = _subtasks[index];
              return Container(
                key: ValueKey('sub_$index'),
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Drag handle
                    ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_indicator,
                        color: AppColors.textTertiary(context),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    
                    // Checkbox
                    InkWell(
                      onTap: () => _toggleSubTask(index),
                      child: Container(
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
                    ),
                    const SizedBox(width: 10),
                    
                    // Tiêu đề
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
                    
                    // Nút xóa
                    IconButton(
                      icon: Icon(Icons.close,
                          size: 16, color: AppColors.textSecondary(context)),
                      onPressed: () => _removeSubTask(index),
                      constraints: const BoxConstraints(
                          minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              );
            },
          ),

        // Ô thêm sub-task mới
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newSubController,
                onSubmitted: (_) => _addSubTask(),
                style: TextStyle(
                    fontSize: 13, color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  hintText: 'Thêm công việc con...',
                  hintStyle: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary(context)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: AppColors.background(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addSubTask,
              icon: const Icon(Icons.add_circle, color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }
}