import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tag.dart';
import '../services/task_provider.dart';
import '../utils/app_utils.dart';
import '../screens/tags_management_screen.dart';

class TagsSelector extends StatelessWidget {
  final List<int> selectedTagIds;
  final ValueChanged<List<int>> onChanged;

  const TagsSelector({
    super.key,
    required this.selectedTagIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final tags = provider.allTags;

        if (tags.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Column(
              children: [
                Icon(Icons.label_outline,
                    color: AppColors.textSecondary(context)),
                const SizedBox(height: 8),
                Text(
                  'Chưa có nhãn nào',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context)),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _openTagsManagement(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Tạo nhãn mới'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary),
                ),
              ],
            ),
          );
        }

        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...tags.map((tag) {
              final isSelected = selectedTagIds.contains(tag.id);
              return _buildTagChip(context, tag, isSelected);
            }),
            // Nút quản lý
            InkWell(
              onTap: () => _openTagsManagement(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.textSecondary(context),
                      style: BorderStyle.solid,
                      width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.settings,
                        size: 12,
                        color: AppColors.textSecondary(context)),
                    const SizedBox(width: 4),
                    Text(
                      'Quản lý',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTagChip(BuildContext context, Tag tag, bool isSelected) {
    return InkWell(
      onTap: () {
        final newIds = List<int>.from(selectedTagIds);
        if (isSelected) {
          newIds.remove(tag.id);
        } else {
          newIds.add(tag.id!);
        }
        onChanged(newIds);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? tag.color : tag.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tag.color, width: isSelected ? 0 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 12, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              '#${tag.name}',
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : tag.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTagsManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TagsManagementScreen()),
    );
  }
}