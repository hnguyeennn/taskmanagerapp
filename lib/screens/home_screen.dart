import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/filter_type.dart';
import '../services/task_provider.dart';
import '../utils/app_utils.dart';
import '../widgets/task_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/m3_components.dart';
import 'add_edit_task_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 120,
            pinned: true,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(
                        color: AppColors.textPrimary(context), fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm công việc...',
                      hintStyle:
                          TextStyle(color: AppColors.textTertiary(context)),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                    onChanged: (value) {
                      context.read<TaskProvider>().setSearchKeyword(value);
                    },
                  )
                : const Text('Công việc của tôi'),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      context.read<TaskProvider>().setSearchKeyword('');
                    }
                  });
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'delete_completed') {
                    _confirmDeleteCompleted();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete_completed',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, color: AppColors.danger),
                        SizedBox(width: 12),
                        Text('Xóa các việc đã xong'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Stats overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _buildStatsCard(),
            ),
          ),

          // Streak
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: StreakCard(),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: _buildFilterChips(),
          ),

          // Task list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: _buildTaskList(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm việc'),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return M3Card(
          color: AppColors.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined,
                      color: AppColors.onPrimaryContainer, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Tổng quan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Tiến độ ${(provider.completionRate * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: provider.completionRate,
                  backgroundColor:
                      AppColors.onPrimaryContainer.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _miniStat('Tổng', provider.totalCount, Icons.list),
                  _miniStat('Đang làm', provider.pendingCount, Icons.schedule),
                  _miniStat(
                      'Hoàn thành', provider.completedCount, Icons.check_circle),
                  _miniStat('Quá hạn', provider.overdueCount, Icons.warning),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, int value, IconData icon) {
    return Builder(builder: (context) {
      return Column(
        children: [
          Icon(icon, size: 18, color: AppColors.onPrimaryContainer),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.onPrimaryContainer,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFilterChips() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: FilterType.values.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: M3FilterChip(
                  label: filter.label,
                  selected: provider.currentFilter == filter,
                  onTap: () => provider.setFilter(filter),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final tasks = provider.filteredTasks;

        if (tasks.isEmpty) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: M3EmptyState(
                icon: Icons.task_alt,
                title: 'Chưa có công việc',
                description: 'Nhấn nút "+ Thêm việc" để bắt đầu',
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onTap: () => _openDetail(task),
                onToggleComplete: () => provider.toggleComplete(task),
                onEdit: () => _openEdit(task),
                onDelete: () => _confirmDelete(task),
              );
            },
            childCount: tasks.length,
          ),
        );
      },
    );
  }

  void _openDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
  }

  void _openEdit(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task)),
    );
  }

  Future<void> _confirmDelete(Task task) async {
    final provider = context.read<TaskProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa công việc?'),
        content: Text('Bạn có chắc muốn xóa "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              foregroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteTask(task.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa công việc')),
        );
      }
    }
  }

  Future<void> _confirmDeleteCompleted() async {
    final provider = context.read<TaskProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa các việc đã hoàn thành?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              foregroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteCompletedTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa tất cả việc đã xong')),
        );
      }
    }
  }
}