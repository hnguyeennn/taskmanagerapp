import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tag.dart';
import '../services/task_provider.dart';
import '../utils/app_utils.dart';

class TagsManagementScreen extends StatefulWidget {
  const TagsManagementScreen({super.key});

  @override
  State<TagsManagementScreen> createState() => _TagsManagementScreenState();
}

class _TagsManagementScreenState extends State<TagsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text('Quản lý nhãn'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final tags = provider.allTags;

          if (tags.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.label_outline,
                      size: 80, color: AppColors.textTertiary(context)),
                  const SizedBox(height: 16),
                  Text('Chưa có nhãn nào',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary(context))),
                  const SizedBox(height: 8),
                  Text('Nhấn + để tạo nhãn đầu tiên',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary(context))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: tag.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.label, color: tag.color),
                  ),
                  title: Text('#${tag.name}',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary(context))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            size: 18,
                            color: AppColors.textSecondary(context)),
                        onPressed: () => _showTagDialog(tag: tag),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 18, color: AppColors.danger),
                        onPressed: () => _confirmDelete(tag),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showTagDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showTagDialog({Tag? tag}) {
    final controller = TextEditingController(text: tag?.name ?? '');
    Color selectedColor = tag?.color ?? AppColors.primary;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface(context),
              title: Text(
                tag == null ? 'Tạo nhãn mới' : 'Sửa nhãn',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: TextStyle(
                        color: AppColors.textPrimary(context)),
                    decoration: InputDecoration(
                      hintText: 'Tên nhãn (vd: cấp_bách)',
                      prefixText: '#',
                      filled: true,
                      fillColor: AppColors.background(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Màu sắc',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorPalette.map((color) {
                      final isSelected =
                          selectedColor.value == color.value;
                      return InkWell(
                        onTap: () => setDialogState(
                            () => selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.textPrimary(context)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;

                    final provider = context.read<TaskProvider>();
                    if (tag == null) {
                      await provider.addTag(Tag(
                        name: name,
                        color: selectedColor,
                      ));
                    } else {
                      await provider.updateTag(tag.copyWith(
                        name: name,
                        color: selectedColor,
                      ));
                    }
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Lưu',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(Tag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        title: Text('Xóa nhãn?',
            style: TextStyle(color: AppColors.textPrimary(context))),
        content: Text(
          'Nhãn "${tag.name}" sẽ bị xóa khỏi tất cả các công việc.',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
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

    if (confirmed == true && tag.id != null && mounted) {
      await context.read<TaskProvider>().deleteTag(tag.id!);
    }
  }

  // Bảng màu cho tag
  static const List<Color> _colorPalette = [
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
    Color(0xFF14B8A6),
    Color(0xFF718096),
  ];
}