import 'package:flutter/foundation.dart' hide Category;
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/tag.dart';
import '../models/goal.dart';
import '../models/filter_type.dart';
import 'database_service.dart';
import 'notification_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Tag> _allTags = [];
  Map<int, List<SubTask>> _subtasksCache = {};
  Map<int, List<Tag>> _tagsCache = {};
  
  FilterType _currentFilter = FilterType.all;
  String _searchKeyword = '';
  Category? _categoryFilter;
  int? _tagFilter;

  // Getters
  List<Task> get allTasks => _tasks;
  List<Tag> get allTags => _allTags;
  FilterType get currentFilter => _currentFilter;
  String get searchKeyword => _searchKeyword;
  Category? get categoryFilter => _categoryFilter;
  int? get tagFilter => _tagFilter;

  // Lấy sub-tasks của 1 task
  List<SubTask> getSubTasks(int taskId) {
    return _subtasksCache[taskId] ?? [];
  }

  // Lấy tags của 1 task
  List<Tag> getTagsForTask(int taskId) {
    return _tagsCache[taskId] ?? [];
  }

  // Tính progress của sub-tasks
  double getSubTaskProgress(int taskId) {
    final subs = _subtasksCache[taskId] ?? [];
    if (subs.isEmpty) return 0;
    final done = subs.where((s) => s.isCompleted).length;
    return done / subs.length;
  }

  // Lấy số subtask "X/Y"
  String getSubTaskProgressText(int taskId) {
    final subs = _subtasksCache[taskId] ?? [];
    if (subs.isEmpty) return '';
    final done = subs.where((s) => s.isCompleted).length;
    return '$done/${subs.length}';
  }

  // Lấy task đã lọc
  List<Task> get filteredTasks {
    List<Task> result = List.from(_tasks);

    // Bỏ qua các task con (sub-tasks không hiển thị ở list chính)
    result = result.where((t) => t.parentTaskId == null).toList();

    // Lọc theo trạng thái
    switch (_currentFilter) {
      case FilterType.pending:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case FilterType.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case FilterType.today:
        final today = DateTime.now();
        result = result.where((t) {
          return t.dueDate.year == today.year &&
              t.dueDate.month == today.month &&
              t.dueDate.day == today.day;
        }).toList();
        break;
      case FilterType.overdue:
        result = result.where((t) => t.isOverdue).toList();
        break;
      case FilterType.all:
        break;
    }

    // Lọc theo danh mục
    if (_categoryFilter != null) {
      result = result.where((t) => t.category == _categoryFilter).toList();
    }

    // Lọc theo tag
    if (_tagFilter != null) {
      result = result.where((t) {
        final taskTags = _tagsCache[t.id] ?? [];
        return taskTags.any((tag) => tag.id == _tagFilter);
      }).toList();
    }

    // Lọc theo từ khóa
    if (_searchKeyword.isNotEmpty) {
      final keyword = _searchKeyword.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(keyword) ||
            t.description.toLowerCase().contains(keyword);
      }).toList();
    }

    return result;
  }

  // Thống kê
  int get totalCount =>
      _tasks.where((t) => t.parentTaskId == null).length;
  int get completedCount =>
      _tasks.where((t) => t.parentTaskId == null && t.isCompleted).length;
  int get pendingCount =>
      _tasks.where((t) => t.parentTaskId == null && !t.isCompleted).length;
  int get overdueCount =>
      _tasks.where((t) => t.parentTaskId == null && t.isOverdue).length;

  double get completionRate {
    if (totalCount == 0) return 0;
    return completedCount / totalCount;
  }

  Map<Category, int> get categoryStats {
    final stats = <Category, int>{};
    for (var category in Category.values) {
      stats[category] = _tasks
          .where((t) => t.parentTaskId == null && t.category == category)
          .length;
    }
    return stats;
  }

  // =================== LOAD DATA ===================

  Future<void> loadTasks() async {
    _tasks = await DatabaseService.instance.getAllTasks();
    await _loadAllSubTasks();
    await _loadAllTaskTags();
    notifyListeners();
  }

  Future<void> _loadAllSubTasks() async {
    _subtasksCache.clear();
    for (final task in _tasks) {
      if (task.id != null) {
        final subs =
            await DatabaseService.instance.getSubTasksByTaskId(task.id!);
        if (subs.isNotEmpty) {
          _subtasksCache[task.id!] = subs;
        }
      }
    }
  }

  Future<void> _loadAllTaskTags() async {
    _tagsCache.clear();
    for (final task in _tasks) {
      if (task.id != null) {
        final tags =
            await DatabaseService.instance.getTagsForTask(task.id!);
        if (tags.isNotEmpty) {
          _tagsCache[task.id!] = tags;
        }
      }
    }
  }

  Future<void> loadTags() async {
    _allTags = await DatabaseService.instance.getAllTags();
    notifyListeners();
  }

  // =================== TASK CRUD ===================

  Future<void> addTask(Task task,
      {List<SubTask>? subtasks, List<int>? tagIds}) async {
    final newTask = await DatabaseService.instance.createTask(task);
    _tasks.add(newTask);

    // Lưu sub-tasks
    if (subtasks != null && subtasks.isNotEmpty && newTask.id != null) {
      final savedSubs = <SubTask>[];
      for (int i = 0; i < subtasks.length; i++) {
        final sub = subtasks[i].copyWith(
          taskId: newTask.id,
          sortOrder: i,
        );
        final saved = await DatabaseService.instance.createSubTask(sub);
        savedSubs.add(saved);
      }
      _subtasksCache[newTask.id!] = savedSubs;
    }

    // Lưu tags
    if (tagIds != null && tagIds.isNotEmpty && newTask.id != null) {
      await DatabaseService.instance.setTaskTags(newTask.id!, tagIds);
      _tagsCache[newTask.id!] =
          await DatabaseService.instance.getTagsForTask(newTask.id!);
    }

    // Đặt nhắc nhở
    if (newTask.hasReminder) {
      await NotificationService.instance.scheduleReminder(newTask);
    }

    notifyListeners();
  }

  Future<void> updateTask(Task task,
      {List<SubTask>? subtasks, List<int>? tagIds}) async {
    await DatabaseService.instance.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }

    // Cập nhật sub-tasks: xóa hết rồi thêm lại
    if (subtasks != null && task.id != null) {
      await DatabaseService.instance.deleteSubTasksByTaskId(task.id!);
      final savedSubs = <SubTask>[];
      for (int i = 0; i < subtasks.length; i++) {
        final sub = subtasks[i].copyWith(
          taskId: task.id,
          sortOrder: i,
        );
        final saved = await DatabaseService.instance.createSubTask(sub);
        savedSubs.add(saved);
      }
      _subtasksCache[task.id!] = savedSubs;
    }

    // Cập nhật tags
    if (tagIds != null && task.id != null) {
      await DatabaseService.instance.setTaskTags(task.id!, tagIds);
      _tagsCache[task.id!] =
          await DatabaseService.instance.getTagsForTask(task.id!);
    }

    // Cập nhật nhắc nhở
    await NotificationService.instance.cancelReminder(task.id!);
    if (task.hasReminder && !task.isCompleted) {
      await NotificationService.instance.scheduleReminder(task);
    }

    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await DatabaseService.instance.deleteTask(id);
    await NotificationService.instance.cancelReminder(id);
    _tasks.removeWhere((t) => t.id == id);
    _subtasksCache.remove(id);
    _tagsCache.remove(id);
    notifyListeners();
  }

  // QUAN TRỌNG: Đánh dấu hoàn thành - xử lý cả recurring
  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );
    await updateTask(updated);

    // Nếu task có lặp lại và vừa được đánh dấu xong → tạo task mới cho lần lặp tiếp
    if (!task.isCompleted && task.isRecurring) {
      await _createNextRecurringTask(task);
    }

    // Cập nhật daily completion cho streak
    await _updateDailyCompletion();
  }

  // Tạo task lặp lại tiếp theo
  Future<void> _createNextRecurringTask(Task originalTask) async {
    final nextDate =
        originalTask.recurringType.getNextDate(originalTask.dueDate);

    if (nextDate == null) return;

    // Kiểm tra ngày kết thúc
    if (originalTask.recurringEndDate != null &&
        nextDate.isAfter(originalTask.recurringEndDate!)) {
      return;
    }

    // Tính reminderTime mới
    DateTime? newReminderTime;
    if (originalTask.hasReminder && originalTask.reminderTime != null) {
      final diff =
          originalTask.dueDate.difference(originalTask.reminderTime!);
      newReminderTime = nextDate.subtract(diff);
    }

    final newTask = Task(
      title: originalTask.title,
      description: originalTask.description,
      dueDate: nextDate,
      priority: originalTask.priority,
      category: originalTask.category,
      hasReminder: originalTask.hasReminder,
      reminderTime: newReminderTime,
      recurringType: originalTask.recurringType,
      recurringEndDate: originalTask.recurringEndDate,
      goalId: originalTask.goalId,
    );

    // Lấy tags của task gốc
    final originalTags = _tagsCache[originalTask.id] ?? [];
    final tagIds =
        originalTags.where((t) => t.id != null).map((t) => t.id!).toList();

    await addTask(newTask, tagIds: tagIds.isEmpty ? null : tagIds);
  }

  // Cập nhật daily completion cho streak
  Future<void> _updateDailyCompletion() async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final completedToday = _tasks.where((t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      final completed = t.completedAt!;
      return completed.year == today.year &&
          completed.month == today.month &&
          completed.day == today.day;
    }).length;

    final dueToday = _tasks.where((t) {
      return t.dueDate.year == today.year &&
          t.dueDate.month == today.month &&
          t.dueDate.day == today.day;
    }).length;

    await DatabaseService.instance.recordDailyCompletion(
      todayOnly,
      completedToday,
      dueToday,
    );
  }

  // =================== SUBTASKS ===================

  Future<void> toggleSubTask(SubTask subtask) async {
    final updated = subtask.copyWith(isCompleted: !subtask.isCompleted);
    await DatabaseService.instance.updateSubTask(updated);

    final taskSubs = _subtasksCache[subtask.taskId] ?? [];
    final index = taskSubs.indexWhere((s) => s.id == subtask.id);
    if (index != -1) {
      taskSubs[index] = updated;
      _subtasksCache[subtask.taskId] = taskSubs;
    }

    notifyListeners();
  }

  // =================== TAGS CRUD ===================

  Future<Tag> addTag(Tag tag) async {
    final newTag = await DatabaseService.instance.createTag(tag);
    _allTags.add(newTag);
    _allTags.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
    return newTag;
  }

  Future<void> updateTag(Tag tag) async {
    await DatabaseService.instance.updateTag(tag);
    final index = _allTags.indexWhere((t) => t.id == tag.id);
    if (index != -1) {
      _allTags[index] = tag;
    }
    // Cập nhật cache cho các task có tag này
    for (final entry in _tagsCache.entries) {
      final tags = entry.value;
      final tagIndex = tags.indexWhere((t) => t.id == tag.id);
      if (tagIndex != -1) {
        tags[tagIndex] = tag;
      }
    }
    notifyListeners();
  }

  Future<void> deleteTag(int id) async {
    await DatabaseService.instance.deleteTag(id);
    _allTags.removeWhere((t) => t.id == id);
    // Xóa tag khỏi tất cả task cache
    for (final entry in _tagsCache.entries) {
      entry.value.removeWhere((t) => t.id == id);
    }
    notifyListeners();
  }

  // =================== FILTERS ===================

  void setFilter(FilterType filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void setCategoryFilter(Category? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setTagFilter(int? tagId) {
    _tagFilter = tagId;
    notifyListeners();
  }

  Future<void> deleteCompletedTasks() async {
    await DatabaseService.instance.deleteCompletedTasks();
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
  }

  // =================== GOALS ===================

List<Goal> _goals = [];
List<Goal> get allGoals => _goals;

Future<void> loadGoals({bool includeArchived = false}) async {
  _goals = await DatabaseService.instance
      .getAllGoals(includeArchived: includeArchived);
  notifyListeners();
}

Future<Goal> addGoal(Goal goal) async {
  final newGoal = await DatabaseService.instance.createGoal(goal);
  _goals.add(newGoal);
  notifyListeners();
  return newGoal;
}

Future<void> updateGoal(Goal goal) async {
  await DatabaseService.instance.updateGoal(goal);
  final index = _goals.indexWhere((g) => g.id == goal.id);
  if (index != -1) {
    _goals[index] = goal;
  }
  notifyListeners();
}

Future<void> deleteGoal(int id) async {
  await DatabaseService.instance.deleteGoal(id);
  _goals.removeWhere((g) => g.id == id);
  // Xóa goalId khỏi các task thuộc goal này (cập nhật local)
  for (int i = 0; i < _tasks.length; i++) {
    if (_tasks[i].goalId == id) {
      _tasks[i] = _tasks[i].copyWith(goalId: null);
    }
  }
  notifyListeners();
}

// Lấy danh sách task của 1 goal
List<Task> getTasksForGoal(int goalId) {
  return _tasks.where((t) => t.goalId == goalId).toList();
}

// Tính progress của goal
double getGoalProgress(int goalId) {
  final tasks = getTasksForGoal(goalId);
  if (tasks.isEmpty) return 0;
  final completed = tasks.where((t) => t.isCompleted).length;
  return completed / tasks.length;
}
}