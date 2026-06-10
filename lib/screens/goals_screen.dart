import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../services/task_provider.dart';
import '../utils/app_utils.dart';
import '../widgets/goal_card.dart';
import 'add_edit_goal_screen.dart';
import 'goal_detail_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Mục tiêu'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final goals = provider.allGoals;

          if (goals.isEmpty) {
            return _buildEmptyState();
          }

          // Tính thống kê tổng quan
          final inProgressCount = goals
              .where((g) => provider.getGoalProgress(g.id ?? 0) < 1.0)
              .length;
          final completedCount = goals
              .where((g) => provider.getGoalProgress(g.id ?? 0) >= 1.0)
              .length;

          return Column(
            key: const ValueKey('goals-list'),
            children: [
              _buildStatsCard(inProgressCount, completedCount, goals.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    return GoalCard(
                      key: ValueKey(goal.id),
                      goal: goal,
                      onTap: () => _openDetail(goal),
                      onEdit: () => _openEdit(goal),
                      onDelete: () => _confirmDelete(goal),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddEditGoalScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo mục tiêu'),
      ),
    );
  }

  Widget _buildStatsCard(int inProgress, int completed, int total) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statCol(Icons.flag_rounded, '$total', 'Tổng mục tiêu'),
          Container(width: 1, height: 40, color: Colors.white24),
          _statCol(Icons.rocket_launch_rounded, '$inProgress', 'Đang theo đuổi'),
          Container(width: 1, height: 40, color: Colors.white24),
          _statCol(Icons.verified_rounded, '$completed', 'Đã hoàn thành'),
        ],
      ),
    );
  }

  Widget _statCol(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Chưa có mục tiêu nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đặt ra các mục tiêu lớn và gắn các công việc vào để theo dõi tiến độ tốt hơn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddEditGoalScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tạo mục tiêu đầu tiên',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal)),
    );
  }

  void _openEdit(Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditGoalScreen(goal: goal)),
    );
  }

  Future<void> _confirmDelete(Goal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        title: Text('Xóa mục tiêu?',
            style: TextStyle(color: AppColors.textPrimary(context))),
        content: Text(
          'Mục tiêu "${goal.title}" sẽ bị xóa. Các công việc thuộc mục tiêu này vẫn được giữ lại.',
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

    if (confirmed == true && goal.id != null && mounted) {
      await context.read<TaskProvider>().deleteGoal(goal.id!);
    }
  }
}