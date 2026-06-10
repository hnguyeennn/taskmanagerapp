import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../utils/app_utils.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';
import 'task_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  // Lấy danh sách task của 1 ngày
  List<Task> _getTasksForDay(DateTime day, List<Task> allTasks) {
    return allTasks.where((task) {
      return task.parentTaskId == null &&
          task.dueDate.year == day.year &&
          task.dueDate.month == day.month &&
          task.dueDate.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Lịch'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Hôm nay',
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final allTasks = provider.allTasks;
          final selectedTasks = _selectedDay != null
              ? _getTasksForDay(_selectedDay!, allTasks)
              : <Task>[];

          return Column(
            children: [
              _buildCalendar(allTasks),
              const Divider(height: 1),
              _buildDayHeader(selectedTasks.length),
              Expanded(child: _buildTaskList(selectedTasks, provider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // Tạo task mới với ngày mặc định là ngày đang chọn
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTaskScreen(
                presetDate: _selectedDay,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm việc'),
      ),
    );
  }

  Widget _buildCalendar(List<Task> allTasks) {
    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TableCalendar<Task>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: 'vi_VN',
        eventLoader: (day) => _getTasksForDay(day, allTasks),

        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },

        // Tùy chỉnh giao diện
        availableCalendarFormats: const {
          CalendarFormat.month: 'Tháng',
          CalendarFormat.twoWeeks: '2 tuần',
          CalendarFormat.week: 'Tuần',
        },

        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary(context),
          ),
          leftChevronIcon: Icon(Icons.chevron_left,
              color: AppColors.textPrimary(context)),
          rightChevronIcon: Icon(Icons.chevron_right,
              color: AppColors.textPrimary(context)),
        ),

        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            fontSize: 12,
            color: AppColors.danger,
            fontWeight: FontWeight.w500,
          ),
        ),

        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(
              color: AppColors.danger, fontWeight: FontWeight.w500),
          defaultTextStyle: TextStyle(
              color: AppColors.textPrimary(context)),
          outsideTextStyle: TextStyle(
              color: AppColors.textTertiary(context)),
          disabledTextStyle: TextStyle(
              color: AppColors.textTertiary(context)),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          markersMaxCount: 4,
          markerDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markerSize: 5,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
        ),

        // Tùy chỉnh dot màu theo priority
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;

            // Tính số task hoàn thành / chưa
            final completedCount =
                events.where((t) => t.isCompleted).length;
            final pendingCount = events.length - completedCount;
            final hasHighPriority =
                events.any((t) => t.priority == Priority.high && !t.isCompleted);

            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasHighPriority)
                    _dot(AppColors.danger),
                  if (pendingCount > 0 && !hasHighPriority)
                    _dot(AppColors.warning),
                  if (completedCount > 0)
                    _dot(AppColors.success),
                  if (events.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        '${events.length}',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDayHeader(int taskCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface(context),
      child: Row(
        children: [
          Icon(Icons.event_note,
              size: 18, color: AppColors.textPrimary(context)),
          const SizedBox(width: 8),
          Text(
            _selectedDay != null
                ? AppDateUtils.formatFriendly(_selectedDay!)
                : 'Hôm nay',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: 8),
          if (_selectedDay != null) ...[
            Text(
              '· ${AppDateUtils.formatDayMonth(_selectedDay!)}/${_selectedDay!.year}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
          const Spacer(),
          if (taskCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$taskCount công việc',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, TaskProvider provider) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy,
                size: 70, color: AppColors.textTertiary(context)),
            const SizedBox(height: 12),
            Text(
              'Không có việc nào trong ngày này',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nhấn nút + để thêm việc',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary(context),
              ),
            ),
          ],
        ),
      );
    }

    // Sắp xếp: chưa xong trước, xong sau
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final task = sorted[index];
        return TaskCard(
          task: task,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailScreen(task: task),
              ),
            );
          },
          onToggleComplete: () => provider.toggleComplete(task),
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditTaskScreen(task: task),
              ),
            );
          },
          onDelete: () => _confirmDelete(task, provider),
        );
      },
    );
  }

  Future<void> _confirmDelete(Task task, TaskProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        title: Text('Xóa công việc?',
            style: TextStyle(color: AppColors.textPrimary(context))),
        content: Text('Bạn có chắc muốn xóa "${task.title}"?',
            style: TextStyle(color: AppColors.textSecondary(context))),
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

    if (confirmed == true && task.id != null) {
      await provider.deleteTask(task.id!);
    }
  }
}