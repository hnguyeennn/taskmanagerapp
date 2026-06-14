import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/streak_service.dart';
import '../utils/app_utils.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Thành tựu'),
      ),
      body: Consumer<StreakService>(
        builder: (context, streak, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsRow(context, streak),
                const SizedBox(height: 24),

                _sectionTitle(context, 'Chuỗi ngày 🔥'),
                ..._buildAchievementsByType(
                    streak, AchievementType.streak),
                const SizedBox(height: 16),

                _sectionTitle(context, 'Số công việc hoàn thành ⭐'),
                ..._buildAchievementsByType(
                    streak, AchievementType.totalCompleted),
                const SizedBox(height: 16),

                _sectionTitle(context, 'Pomodoro 🍅'),
                ..._buildAchievementsByType(
                    streak, AchievementType.pomodoroToday),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, StreakService streak) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statCol('🔥', '${streak.currentStreak}', 'Chuỗi hiện tại'),
          _statCol('🏆', '${streak.longestStreak}', 'Kỷ lục'),
          _statCol('✅', '${streak.totalCompleted}', 'Tổng đã làm'),
          _statCol('🍅', '${streak.pomodoroToday}', 'Pomodoro hôm nay'),
        ],
      ),
    );
  }

  Widget _statCol(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            )),
        Text(label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            )),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }

  List<Widget> _buildAchievementsByType(
      StreakService streak, AchievementType type) {
    final achievements = StreakService.allAchievements
        .where((a) => a.type == type)
        .toList();

    return achievements.map((ach) {
      final isUnlocked = streak.unlockedAchievements.contains(ach.id);
      int currentValue = 0;
      switch (ach.type) {
        case AchievementType.streak:
          currentValue = streak.longestStreak;
          break;
        case AchievementType.totalCompleted:
          currentValue = streak.totalCompleted;
          break;
        case AchievementType.pomodoroToday:
          currentValue = streak.pomodoroToday;
          break;
        case AchievementType.perfectWeek:
          currentValue = 0;
          break;
      }
      final progress = (currentValue / ach.requirement).clamp(0.0, 1.0);

      return Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnlocked
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.border(context),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.primaryLight
                      : AppColors.border(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    ach.emoji,
                    style: TextStyle(
                      fontSize: 24,
                      color: isUnlocked
                          ? null
                          : AppColors.textTertiary(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ach.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        if (isUnlocked)
                          const Icon(Icons.check_circle,
                              color: AppColors.success, size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ach.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.border(context),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isUnlocked
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$currentValue/${ach.requirement}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}