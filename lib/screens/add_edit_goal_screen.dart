import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../services/task_provider.dart';
import '../utils/app_utils.dart';

class AddEditGoalScreen extends StatefulWidget {
  final Goal? goal;
  const AddEditGoalScreen({super.key, this.goal});

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late DateTime _targetDate;
  late Color _selectedColor;
  late IconData _selectedIcon;

  bool get _isEdit => widget.goal != null;

  // Các màu có sẵn
  static const List<Color> _colors = [
    Color(0xFF6C63FF),
    Color(0xFFE53E3E),
    Color(0xFFFF9800),
    Color(0xFFFFC107),
    Color(0xFF38A169),
    Color(0xFF3182CE),
    Color(0xFF805AD5),
    Color(0xFFD53F8C),
    Color(0xFF00BCD4),
    Color(0xFF8B5CF6),
  ];

  // Các icon có sẵn
  static const List<IconData> _icons = [
    Icons.flag,
    Icons.star,
    Icons.school,
    Icons.work,
    Icons.fitness_center,
    Icons.favorite,
    Icons.book,
    Icons.code,
    Icons.attach_money,
    Icons.flight,
    Icons.home,
    Icons.brush,
    Icons.music_note,
    Icons.sports_esports,
    Icons.psychology,
    Icons.emoji_events,
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final g = widget.goal!;
      _titleController.text = g.title;
      _descController.text = g.description;
      _targetDate = g.targetDate;
      _selectedColor = g.color;
      _selectedIcon = g.icon;
    } else {
      _targetDate = DateTime.now().add(const Duration(days: 30));
      _selectedColor = AppColors.primary;
      _selectedIcon = Icons.flag;
    }
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
        title: Text(_isEdit ? 'Sửa mục tiêu' : 'Tạo mục tiêu'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview
              _buildPreview(),
              const SizedBox(height: 24),

              _label('Tên mục tiêu *'),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: _inputDecoration(
                    'VD: Học xong Flutter trong 2 tháng'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên mục tiêu';
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
                decoration:
                    _inputDecoration('Mô tả chi tiết về mục tiêu (tùy chọn)'),
              ),
              const SizedBox(height: 16),

              _label('Ngày hoàn thành'),
              InkWell(
                onTap: _pickTargetDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event,
                          color: _selectedColor, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        AppDateUtils.formatFriendly(_targetDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '· ${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _label('Màu sắc'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colors.map((color) {
                  final isSelected = _selectedColor.value == color.value;
                  return InkWell(
                    onTap: () =>
                        setState(() => _selectedColor = color),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.textPrimary(context)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              _label('Icon'),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _icons.map((icon) {
                    final isSelected = _selectedIcon.codePoint == icon.codePoint;
                    return InkWell(
                      onTap: () =>
                          setState(() => _selectedIcon = icon),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? _selectedColor
                                : AppColors.border(context),
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? _selectedColor
                              : AppColors.textSecondary(context),
                          size: 20,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_isEdit ? 'Cập nhật' : 'Tạo mục tiêu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_selectedColor, _selectedColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_selectedIcon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleController.text.isEmpty
                      ? 'Tên mục tiêu'
                      : _titleController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Hoàn thành: ${AppDateUtils.formatFriendly(_targetDate)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            color: AppColors.textPrimary(context),
          )),
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
        borderSide: BorderSide(color: _selectedColor, width: 2),
      ),
    );
  }

  Future<void> _pickTargetDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      setState(() => _targetDate = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final goal = Goal(
      id: widget.goal?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      targetDate: _targetDate,
      color: _selectedColor,
      icon: _selectedIcon,
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
    );

    final provider = context.read<TaskProvider>();
    if (_isEdit) {
      await provider.updateGoal(goal);
    } else {
      await provider.addGoal(goal);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Đã cập nhật mục tiêu' : 'Đã tạo mục tiêu'),
        ),
      );
    }
  }
}