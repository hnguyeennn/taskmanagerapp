import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../services/task_provider.dart';
import '../utils/app_utils.dart';
import '../widgets/subtasks_editor.dart';
import '../widgets/tags_selector.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  final DateTime? presetDate;
  final int? presetGoalId;

  const AddEditTaskScreen({
    super.key,
    this.task,
    this.presetDate,
    this.presetGoalId,
  });

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late DateTime _dueDate;
  late Priority _priority;
  late Category _category;
  late bool _hasReminder;
  DateTime? _reminderTime;

  // MỚI
  RecurringType _recurringType = RecurringType.none;
  DateTime? _recurringEndDate;
  List<SubTask> _subtasks = [];
  List<int> _selectedTagIds = [];
  int? _selectedGoalId;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();

    if (_isEdit) {
      final t = widget.task!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _dueDate = t.dueDate;
      _priority = t.priority;
      _category = t.category;
      _hasReminder = t.hasReminder;
      _reminderTime = t.reminderTime;
      _recurringType = t.recurringType;
      _recurringEndDate = t.recurringEndDate;
      _selectedGoalId = t.goalId;
    } else {
      _dueDate = widget.presetDate ?? DateTime.now().add(const Duration(hours: 1));
      _priority = Priority.medium;
      _category = Category.other;
      _hasReminder = false;
      _selectedGoalId = widget.presetGoalId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isEdit && widget.task!.id != null) {
        final provider = context.read<TaskProvider>();
        setState(() {
          _subtasks = List.from(provider.getSubTasks(widget.task!.id!));
          _selectedTagIds = provider
              .getTagsForTask(widget.task!.id!)
              .where((tag) => tag.id != null)
              .map((tag) => tag.id!)
              .toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa công việc' : 'Thêm công việc'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Tiêu đề *'),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: _inputDecoration('Nhập tiêu đề công việc'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _label('Mô tả'),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: _inputDecoration('Mô tả chi tiết (tùy chọn)'),
              ),
              const SizedBox(height: 16),

              _label('Hạn hoàn thành'),
              _datePickerCard(
                icon: Icons.calendar_today,
                value: AppDateUtils.formatFull(_dueDate),
                onTap: _pickDueDate,
              ),
              const SizedBox(height: 16),

              _label('Danh mục'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Category.values.map((cat) {
                  final selected = _category == cat;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon,
                            size: 14,
                            color: selected ? Colors.white : cat.color),
                        const SizedBox(width: 4),
                        Text(cat.label),
                      ],
                    ),
                    selected: selected,
                    selectedColor: cat.color,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : cat.color,
                      fontSize: 12,
                    ),
                    side: BorderSide(color: cat.color),
                    backgroundColor: AppColors.surface(context),
                    onSelected: (_) => setState(() => _category = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              _label('Mức độ ưu tiên'),
              Row(
                children: Priority.values.map((p) {
                  final selected = _priority == p;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => setState(() => _priority = p),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? p.color
                                : AppColors.surface(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: p.color),
                          ),
                          child: Center(
                            child: Text(
                              p.label,
                              style: TextStyle(
                                color: selected ? Colors.white : p.color,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // MỚI: Sub-tasks
              _label('Công việc con'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: SubTasksEditor(
                  initialSubTasks: _subtasks,
                  taskId: widget.task?.id,
                  onChanged: (list) => setState(() => _subtasks = list),
                ),
              ),
              const SizedBox(height: 16),

              // MỚI: Tags
              _label('Nhãn'),
              TagsSelector(
                selectedTagIds: _selectedTagIds,
                onChanged: (ids) => setState(() => _selectedTagIds = ids),
              ),
              const SizedBox(height: 16),

              // MỚI: Goal selector
              _label('Mục tiêu'),
              Consumer<TaskProvider>(
                builder: (context, provider, _) {
                  final goals = provider.allGoals;
                  if (goals.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined,
                              color: AppColors.textSecondary(context), size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Chưa có mục tiêu nào',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: _selectedGoalId != null
                              ? (goals.where((g) => g.id == _selectedGoalId).isNotEmpty
                                  ? goals.firstWhere((g) => g.id == _selectedGoalId).color
                                  : AppColors.textSecondary(context))
                              : AppColors.textSecondary(context),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButton<int?>(
                            value: _selectedGoalId,
                            isExpanded: true,
                            underline: const SizedBox(),
                            dropdownColor: AppColors.surface(context),
                            hint: Text(
                              'Chọn mục tiêu (tùy chọn)',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textTertiary(context),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary(context),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Không thuộc mục tiêu nào'),
                              ),
                              ...goals.where((g) => g.id != null).map((g) {
                                return DropdownMenuItem<int?>(
                                  value: g.id,
                                  child: Row(
                                    children: [
                                      Icon(g.icon, color: g.color, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          g.title,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedGoalId = value);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // MỚI: Lặp lại
              _label('Lặp lại'),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Row(
                  children: [
                    Icon(_recurringType.icon,
                        color: _recurringType == RecurringType.none
                            ? AppColors.textSecondary(context)
                            : AppColors.primary,
                        size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<RecurringType>(
                        value: _recurringType,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: AppColors.surface(context),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary(context),
                        ),
                        items: RecurringType.values.map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(r.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _recurringType = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (_recurringType != RecurringType.none) ...[
                const SizedBox(height: 8),
                _datePickerCard(
                  icon: Icons.event_available,
                  label: 'Ngày kết thúc lặp (tùy chọn)',
                  value: _recurringEndDate != null
                      ? AppDateUtils.formatFriendly(_recurringEndDate!)
                      : 'Không giới hạn',
                  onTap: _pickRecurringEndDate,
                  onClear: _recurringEndDate != null
                      ? () => setState(() => _recurringEndDate = null)
                      : null,
                ),
              ],
              const SizedBox(height: 16),

              _label('Nhắc nhở'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Bật thông báo nhắc nhở',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary(context))),
                    ),
                    Switch(
                      value: _hasReminder,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _hasReminder = value;
                          if (value && _reminderTime == null) {
                            _reminderTime = _dueDate
                                .subtract(const Duration(minutes: 15));
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (_hasReminder) ...[
                const SizedBox(height: 8),
                _datePickerCard(
                  icon: Icons.notifications,
                  label: 'Thời gian nhắc',
                  value: _reminderTime != null
                      ? AppDateUtils.formatFull(_reminderTime!)
                      : 'Chọn thời gian',
                  onTap: _pickReminderTime,
                ),
              ],
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_isEdit ? 'Cập nhật' : 'Thêm công việc',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context))),
    );
  }

  Widget _datePickerCard({
    required IconData icon,
    String? label,
    required String value,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(label,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary(context))),
                  Text(value,
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary(context))),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                icon: Icon(Icons.close,
                    size: 18,
                    color: AppColors.textSecondary(context)),
                onPressed: onClear,
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textTertiary(context)),
      filled: true,
      fillColor: AppColors.surface(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (time == null) return;

    setState(() {
      _dueDate = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickReminderTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderTime ?? DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _reminderTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickRecurringEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recurringEndDate ??
          DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (date != null) {
      setState(() => _recurringEndDate = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      category: _category,
      isCompleted: widget.task?.isCompleted ?? false,
      hasReminder: _hasReminder,
      reminderTime: _hasReminder ? _reminderTime : null,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      recurringType: _recurringType,
      recurringEndDate: _recurringEndDate,
      parentTaskId: widget.task?.parentTaskId,
      goalId: _selectedGoalId,
      completedAt: widget.task?.completedAt,
      pomodoroCount: widget.task?.pomodoroCount ?? 0,
    );

    final provider = context.read<TaskProvider>();
    if (_isEdit) {
      await provider.updateTask(
        task,
        subtasks: _subtasks,
        tagIds: _selectedTagIds,
      );
    } else {
      await provider.addTask(
        task,
        subtasks: _subtasks,
        tagIds: _selectedTagIds,
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Đã cập nhật' : 'Đã thêm việc')),
      );
    }
  }
}