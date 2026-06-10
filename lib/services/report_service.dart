import 'package:flutter/foundation.dart' hide Category;
import '../models/task.dart';
import 'database_service.dart';

enum ReportPeriod { week, month }

class DayStats {
  final DateTime date;
  final int completed;
  final int created;
  final int total;

  DayStats({
    required this.date,
    required this.completed,
    required this.created,
    required this.total,
  });
}

class ReportData {
  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final int totalCompleted;
  final int totalCreated;
  final int totalPomodoroMinutes;
  final double completionRate;
  final List<DayStats> dailyStats;
  final Map<Category, int> categoryBreakdown;
  final Map<Priority, int> priorityBreakdown;
  final double changeFromPrevious;
  final List<String> insights;
  final DateTime? mostProductiveDay;
  final int mostProductiveCount;

  ReportData({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalCompleted,
    required this.totalCreated,
    required this.totalPomodoroMinutes,
    required this.completionRate,
    required this.dailyStats,
    required this.categoryBreakdown,
    required this.priorityBreakdown,
    required this.changeFromPrevious,
    required this.insights,
    required this.mostProductiveDay,
    required this.mostProductiveCount,
  });
}

class ReportService extends ChangeNotifier {
  ReportData? _currentReport;
  ReportPeriod _selectedPeriod = ReportPeriod.week;
  bool _isLoading = false;

  ReportData? get currentReport => _currentReport;
  ReportPeriod get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;

  Future<void> generateReport(ReportPeriod period) async {
    _isLoading = true;
    _selectedPeriod = period;
    notifyListeners();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime startDate;
    DateTime endDate = today;
    DateTime previousStart;
    DateTime previousEnd;

    if (period == ReportPeriod.week) {
      // 7 ngày gần nhất bao gồm hôm nay
      startDate = today.subtract(const Duration(days: 6));
      previousStart = startDate.subtract(const Duration(days: 7));
      previousEnd = startDate.subtract(const Duration(days: 1));
    } else {
      // 30 ngày gần nhất
      startDate = today.subtract(const Duration(days: 29));
      previousStart = startDate.subtract(const Duration(days: 30));
      previousEnd = startDate.subtract(const Duration(days: 1));
    }

    // Lấy tất cả task
    final allTasks = await DatabaseService.instance.getAllTasks();

    // Lọc task trong kỳ
    final completedInPeriod = allTasks.where((t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      return !t.completedAt!.isBefore(startDate) &&
          !t.completedAt!.isAfter(endDate.add(const Duration(days: 1)));
    }).toList();

    final createdInPeriod = allTasks.where((t) {
      return !t.createdAt.isBefore(startDate) &&
          !t.createdAt.isAfter(endDate.add(const Duration(days: 1)));
    }).toList();

    // Lọc kỳ trước
    final completedPrevious = allTasks.where((t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      return !t.completedAt!.isBefore(previousStart) &&
          !t.completedAt!.isAfter(previousEnd.add(const Duration(days: 1)));
    }).toList();

    // Tính daily stats
    final dailyStats = <DayStats>[];
    final daysCount = endDate.difference(startDate).inDays + 1;
    
    for (int i = 0; i < daysCount; i++) {
      final day = startDate.add(Duration(days: i));
      
      final completed = completedInPeriod.where((t) {
        return t.completedAt!.year == day.year &&
            t.completedAt!.month == day.month &&
            t.completedAt!.day == day.day;
      }).length;

      final created = createdInPeriod.where((t) {
        return t.createdAt.year == day.year &&
            t.createdAt.month == day.month &&
            t.createdAt.day == day.day;
      }).length;

      dailyStats.add(DayStats(
        date: day,
        completed: completed,
        created: created,
        total: completed + created,
      ));
    }

    // Tìm ngày năng suất nhất
    DateTime? mostProductiveDay;
    int mostProductiveCount = 0;
    for (final stat in dailyStats) {
      if (stat.completed > mostProductiveCount) {
        mostProductiveCount = stat.completed;
        mostProductiveDay = stat.date;
      }
    }

    // Phân loại theo category
    final categoryBreakdown = <Category, int>{};
    for (final cat in Category.values) {
      categoryBreakdown[cat] =
          completedInPeriod.where((t) => t.category == cat).length;
    }

    // Phân loại theo priority
    final priorityBreakdown = <Priority, int>{};
    for (final p in Priority.values) {
      priorityBreakdown[p] =
          completedInPeriod.where((t) => t.priority == p).length;
    }

    // Tính % thay đổi
    double change = 0;
    if (completedPrevious.isNotEmpty) {
      change = ((completedInPeriod.length - completedPrevious.length) /
              completedPrevious.length) *
          100;
    } else if (completedInPeriod.isNotEmpty) {
      change = 100;
    }

    // Tính tổng Pomodoro minutes
    final db = await DatabaseService.instance.database;
    final pomoResult = await db.rawQuery(
      'SELECT SUM(durationMinutes) as total FROM pomodoro_sessions WHERE startTime >= ? AND completed = 1 AND type = 0',
      [startDate.toIso8601String()],
    );
    final totalPomodoroMinutes =
        (pomoResult.first['total'] as int?) ?? 0;

    // Tính completion rate
    final completionRate = createdInPeriod.isEmpty
        ? 0.0
        : completedInPeriod.length / createdInPeriod.length;

    // Generate insights
    final insights = _generateInsights(
      completed: completedInPeriod.length,
      created: createdInPeriod.length,
      change: change,
      categoryBreakdown: categoryBreakdown,
      mostProductiveDay: mostProductiveDay,
      mostProductiveCount: mostProductiveCount,
      pomodoroMinutes: totalPomodoroMinutes,
      period: period,
    );

    _currentReport = ReportData(
      period: period,
      startDate: startDate,
      endDate: endDate,
      totalCompleted: completedInPeriod.length,
      totalCreated: createdInPeriod.length,
      totalPomodoroMinutes: totalPomodoroMinutes,
      completionRate: completionRate,
      dailyStats: dailyStats,
      categoryBreakdown: categoryBreakdown,
      priorityBreakdown: priorityBreakdown,
      changeFromPrevious: change,
      insights: insights,
      mostProductiveDay: mostProductiveDay,
      mostProductiveCount: mostProductiveCount,
    );

    _isLoading = false;
    notifyListeners();
  }

  List<String> _generateInsights({
    required int completed,
    required int created,
    required double change,
    required Map<Category, int> categoryBreakdown,
    required DateTime? mostProductiveDay,
    required int mostProductiveCount,
    required int pomodoroMinutes,
    required ReportPeriod period,
  }) {
    final insights = <String>[];
    final periodText = period == ReportPeriod.week ? 'tuần' : 'tháng';

    // Insight 1: Thay đổi so với kỳ trước
    if (change > 20) {
      insights.add('🚀 Tuyệt vời! Năng suất tăng ${change.toStringAsFixed(0)}% so với $periodText trước.');
    } else if (change > 0) {
      insights.add('📈 Bạn làm việc tốt hơn $periodText trước ${change.toStringAsFixed(0)}%.');
    } else if (change < -20) {
      insights.add('📉 Năng suất giảm ${(-change).toStringAsFixed(0)}% so với $periodText trước. Hãy cố gắng lên!');
    } else if (change < 0) {
      insights.add('🔍 Năng suất giảm nhẹ ${(-change).toStringAsFixed(0)}% so với $periodText trước.');
    }

    // Insight 2: Ngày năng suất nhất
    if (mostProductiveDay != null && mostProductiveCount > 0) {
      final weekday = _getWeekdayName(mostProductiveDay.weekday);
      insights.add('⭐ Ngày năng suất nhất là $weekday (${mostProductiveDay.day}/${mostProductiveDay.month}) với $mostProductiveCount việc hoàn thành.');
    }

    // Insight 3: Danh mục nổi bật
    if (categoryBreakdown.isNotEmpty) {
      final topCategory = categoryBreakdown.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      if (topCategory.value > 0) {
        insights.add('🎯 Bạn tập trung nhiều nhất vào "${topCategory.key.label}" với ${topCategory.value} việc.');
      }
    }

    // Insight 4: Pomodoro
    if (pomodoroMinutes > 0) {
      final hours = pomodoroMinutes ~/ 60;
      final mins = pomodoroMinutes % 60;
      String timeText = '';
      if (hours > 0) timeText += '$hours giờ ';
      if (mins > 0) timeText += '$mins phút';
      insights.add('🍅 Đã tập trung tổng cộng $timeText với Pomodoro.');
    }

    // Insight 5: Completion rate
    if (created > 0 && completed > 0) {
      final rate = (completed / created * 100).toStringAsFixed(0);
      if (completed >= created) {
        insights.add('✅ Tỷ lệ hoàn thành: $rate% - Bạn đang xử lý task rất nhanh!');
      } else {
        insights.add('💡 Tỷ lệ hoàn thành: $rate%. Hãy thử chia nhỏ task để dễ hoàn thành hơn.');
      }
    }

    // Nếu không có gì làm
    if (completed == 0) {
      insights.add('💪 Hãy bắt đầu hoàn thành công việc đầu tiên của $periodText nhé!');
    }

    return insights;
  }

  String _getWeekdayName(int weekday) {
    const names = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    return names[weekday - 1];
  }
}