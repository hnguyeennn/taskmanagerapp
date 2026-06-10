import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import '../services/task_provider.dart';
import '../services/streak_service.dart';
import '../services/report_service.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'goals_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'add_edit_task_screen.dart';
import 'pomodoro_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    CalendarScreen(),
    GoalsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  // Tab index mapping
  static const int _calendarIndex = 1;
  static const int _reportsIndex = 3;

  @override
  void initState() {
    super.initState();
    // Load tất cả data một lần duy nhất tại đây
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final taskProvider = context.read<TaskProvider>();
      taskProvider.loadTasks();
      taskProvider.loadGoals();
      taskProvider.loadTags();
      context.read<StreakService>().loadStats();
      context.read<ReportService>().generateReport(ReportPeriod.week);

      _initQuickActions();
    });
  }

  void _initQuickActions() {
    const QuickActions quickActions = QuickActions();

    quickActions.initialize((shortcutType) {
      if (!mounted) return;
      switch (shortcutType) {
        case 'add_task':
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
          break;
        case 'open_pomodoro':
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PomodoroScreen()),
          );
          break;
        case 'open_calendar':
          setState(() => _currentIndex = _calendarIndex);
          break;
        case 'open_reports':
          setState(() => _currentIndex = _reportsIndex);
          break;
      }
    });

    quickActions.setShortcutItems([
      const ShortcutItem(
        type: 'add_task',
        localizedTitle: 'Thêm việc mới',
      ),
      const ShortcutItem(
        type: 'open_pomodoro',
        localizedTitle: 'Mở Pomodoro',
      ),
      const ShortcutItem(
        type: 'open_calendar',
        localizedTitle: 'Xem lịch',
      ),
      const ShortcutItem(
        type: 'open_reports',
        localizedTitle: 'Xem báo cáo',
      ),
    ]).catchError((e) {
      // Ignore shortcut registration errors (e.g. icon resolution failures)
      debugPrint('Quick Actions setShortcutItems error: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Lịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Mục tiêu',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Báo cáo',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
