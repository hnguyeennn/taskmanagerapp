import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../services/streak_service.dart';
import '../utils/app_utils.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Thống kê'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCard(context, provider),
                const SizedBox(height: 16),
                _buildPomodoroCard(context),
                const SizedBox(height: 16),
                _buildCompletionChart(context, provider),
                const SizedBox(height: 16),
                _buildCategoryChart(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, TaskProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng quan',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: [
              _statBox('Tổng công việc',
                  provider.totalCount.toString(), AppColors.primary,
                  Icons.list),
              _statBox('Hoàn thành',
                  provider.completedCount.toString(), AppColors.success,
                  Icons.check_circle),
              _statBox('Đang chờ',
                  provider.pendingCount.toString(), AppColors.warning,
                  Icons.access_time),
              _statBox('Quá hạn',
                  provider.overdueCount.toString(), AppColors.danger,
                  Icons.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: color,
                  )),
              Text(label,
                  style: const TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionChart(BuildContext context, TaskProvider provider) {
    if (provider.totalCount == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
            child: Text('Chưa có dữ liệu',
                style: TextStyle(
                    color: AppColors.textSecondary(context)))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tỉ lệ hoàn thành',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  if (provider.completedCount > 0)
                    PieChartSectionData(
                      value: provider.completedCount.toDouble(),
                      title: '${provider.completedCount}',
                      color: AppColors.success,
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  if (provider.pendingCount - provider.overdueCount > 0)
                    PieChartSectionData(
                      value: (provider.pendingCount -
                              provider.overdueCount)
                          .toDouble(),
                      title:
                          '${provider.pendingCount - provider.overdueCount}',
                      color: AppColors.warning,
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  if (provider.overdueCount > 0)
                    PieChartSectionData(
                      value: provider.overdueCount.toDouble(),
                      title: '${provider.overdueCount}',
                      color: AppColors.danger,
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _legend('Hoàn thành', AppColors.success),
              _legend('Đang chờ', AppColors.warning),
              _legend('Quá hạn', AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoryChart(BuildContext context, TaskProvider provider) {
    final stats = provider.categoryStats;
    final maxCount = stats.values.isEmpty
        ? 0
        : stats.values.reduce((a, b) => a > b ? a : b);

    if (maxCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phân bố theo danh mục',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCount.toDouble() + 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= Category.values.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            Category.values[value.toInt()].label,
                            style: const TextStyle(fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups:
                    Category.values.asMap().entries.map((entry) {
                  final cat = entry.value;
                  final count = stats[cat] ?? 0;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: cat.color,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroCard(BuildContext context) {
    return Consumer<StreakService>(
      builder: (context, streak, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🍅', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Pomodoro hôm nay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${streak.pomodoroToday}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: AppColors.danger,
                        ),
                      ),
                      Text(
                        'Phiên hoàn thành',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${streak.pomodoroToday * 25}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'Phút tập trung',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
