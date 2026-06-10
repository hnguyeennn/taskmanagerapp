import 'package:flutter/foundation.dart';
import 'database_service.dart';

// Định nghĩa thành tựu
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requirement;
  final AchievementType type;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requirement,
    required this.type,
  });
}

enum AchievementType { streak, totalCompleted, pomodoroToday, perfectWeek }

class StreakService extends ChangeNotifier {
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalCompleted = 0;
  int _pomodoroToday = 0;
  Set<String> _unlockedAchievements = {};

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get totalCompleted => _totalCompleted;
  int get pomodoroToday => _pomodoroToday;
  Set<String> get unlockedAchievements => _unlockedAchievements;

  // Danh sách thành tựu
  static const List<Achievement> allAchievements = [
    // Streak
    Achievement(
      id: 'streak_3',
      title: 'Khởi đầu tốt',
      description: 'Hoàn thành task 3 ngày liên tiếp',
      emoji: '🔥',
      requirement: 3,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Một tuần kiên trì',
      description: 'Hoàn thành task 7 ngày liên tiếp',
      emoji: '⚡',
      requirement: 7,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_14',
      title: 'Hai tuần bền bỉ',
      description: 'Hoàn thành task 14 ngày liên tiếp',
      emoji: '💪',
      requirement: 14,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Một tháng tuyệt vời',
      description: 'Hoàn thành task 30 ngày liên tiếp',
      emoji: '🏆',
      requirement: 30,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Bậc thầy thói quen',
      description: 'Hoàn thành task 100 ngày liên tiếp',
      emoji: '👑',
      requirement: 100,
      type: AchievementType.streak,
    ),

    // Total completed
    Achievement(
      id: 'total_10',
      title: 'Người mới bắt đầu',
      description: 'Hoàn thành 10 công việc',
      emoji: '🌱',
      requirement: 10,
      type: AchievementType.totalCompleted,
    ),
    Achievement(
      id: 'total_50',
      title: 'Người chăm chỉ',
      description: 'Hoàn thành 50 công việc',
      emoji: '⭐',
      requirement: 50,
      type: AchievementType.totalCompleted,
    ),
    Achievement(
      id: 'total_100',
      title: 'Người siêng năng',
      description: 'Hoàn thành 100 công việc',
      emoji: '🌟',
      requirement: 100,
      type: AchievementType.totalCompleted,
    ),
    Achievement(
      id: 'total_500',
      title: 'Cao thủ',
      description: 'Hoàn thành 500 công việc',
      emoji: '💎',
      requirement: 500,
      type: AchievementType.totalCompleted,
    ),

    // Pomodoro
    Achievement(
      id: 'pomo_5',
      title: 'Tập trung 5 lần',
      description: 'Hoàn thành 5 phiên Pomodoro trong ngày',
      emoji: '🍅',
      requirement: 5,
      type: AchievementType.pomodoroToday,
    ),
    Achievement(
      id: 'pomo_10',
      title: 'Siêu tập trung',
      description: 'Hoàn thành 10 phiên Pomodoro trong ngày',
      emoji: '🎯',
      requirement: 10,
      type: AchievementType.pomodoroToday,
    ),

    // Perfect week
    Achievement(
      id: 'perfect_week',
      title: 'Tuần hoàn hảo',
      description: 'Hoàn thành 100% task trong 7 ngày liên tiếp',
      emoji: '✨',
      requirement: 7,
      type: AchievementType.perfectWeek,
    ),
  ];

  // Load dữ liệu streak từ database
  Future<void> loadStats() async {
    _currentStreak = await DatabaseService.instance.calculateStreak();
    _longestStreak = await _calculateLongestStreak();
    _totalCompleted = await _getTotalCompleted();
    _pomodoroToday = await _getPomodoroToday();
    _unlockedAchievements = _checkUnlockedAchievements();
    notifyListeners();
  }

  // Tính streak dài nhất
  Future<int> _calculateLongestStreak() async {
    final completions = await DatabaseService.instance.getDailyCompletions(days: 365);
    if (completions.isEmpty) return 0;

    int longest = 0;
    int current = 0;
    DateTime? lastDate;

    // Sắp xếp theo ngày tăng dần
    final sorted = List<Map<String, dynamic>>.from(completions);
    sorted.sort((a, b) =>
        (a['date'] as String).compareTo(b['date'] as String));

    for (final row in sorted) {
      if ((row['completedCount'] as int) == 0) continue;

      final dateParts = (row['date'] as String).split('-');
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      if (lastDate == null) {
        current = 1;
      } else {
        final diff = date.difference(lastDate).inDays;
        if (diff == 1) {
          current++;
        } else {
          if (current > longest) longest = current;
          current = 1;
        }
      }
      lastDate = date;
    }

    if (current > longest) longest = current;
    return longest;
  }

  Future<int> _getTotalCompleted() async {
    final db = await DatabaseService.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE isCompleted = 1',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> _getPomodoroToday() async {
    final sessions = await DatabaseService.instance.getPomodoroSessionsToday();
    return sessions.where((s) => s.type.index == 0).length;
  }

  // Kiểm tra các thành tựu đã đạt
  Set<String> _checkUnlockedAchievements() {
    final unlocked = <String>{};

    for (final ach in allAchievements) {
      bool isUnlocked = false;
      switch (ach.type) {
        case AchievementType.streak:
          isUnlocked = _longestStreak >= ach.requirement;
          break;
        case AchievementType.totalCompleted:
          isUnlocked = _totalCompleted >= ach.requirement;
          break;
        case AchievementType.pomodoroToday:
          isUnlocked = _pomodoroToday >= ach.requirement;
          break;
        case AchievementType.perfectWeek:
          // Sẽ check ở nơi khác - tạm bỏ qua
          isUnlocked = false;
          break;
      }
      if (isUnlocked) {
        unlocked.add(ach.id);
      }
    }
    return unlocked;
  }

  // Refresh stats sau mỗi action quan trọng
  Future<void> refresh() async {
    await loadStats();
  }

  // Lấy thành tựu tiếp theo cho từng loại
  Achievement? getNextStreakAchievement() {
    return allAchievements
        .where((a) =>
            a.type == AchievementType.streak &&
            !_unlockedAchievements.contains(a.id))
        .toList()
        .firstWhere((a) => true, orElse: () => allAchievements[0]);
  }
}