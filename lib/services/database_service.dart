import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/tag.dart';
import '../models/goal.dart';
import '../models/pomodoro_session.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Tăng version để trigger migration
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // Bảng tasks - thêm các cột mới
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 1,
        category INTEGER NOT NULL DEFAULT 4,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        hasReminder INTEGER NOT NULL DEFAULT 0,
        reminderTime TEXT,
        createdAt TEXT NOT NULL,
        recurringType INTEGER NOT NULL DEFAULT 0,
        recurringEndDate TEXT,
        parentTaskId INTEGER,
        goalId INTEGER,
        completedAt TEXT,
        pomodoroCount INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Bảng sub-tasks
    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        sortOrder INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE
      )
    ''');

    // Bảng tags (nhãn tùy chỉnh)
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Bảng nối task - tag (many to many)
    await db.execute('''
      CREATE TABLE task_tags (
        taskId INTEGER NOT NULL,
        tagId INTEGER NOT NULL,
        PRIMARY KEY (taskId, tagId),
        FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE,
        FOREIGN KEY (tagId) REFERENCES tags(id) ON DELETE CASCADE
      )
    ''');

    // Bảng goals (mục tiêu)
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        targetDate TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        isArchived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Bảng pomodoro sessions
    await db.execute('''
      CREATE TABLE pomodoro_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER,
        startTime TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        type INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE SET NULL
      )
    ''');

    // Bảng streak (chuỗi ngày)
    await db.execute('''
      CREATE TABLE daily_completions (
        date TEXT PRIMARY KEY,
        completedCount INTEGER NOT NULL DEFAULT 0,
        totalCount INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Indexes
    await db.execute('CREATE INDEX idx_dueDate ON tasks(dueDate)');
    await db.execute('CREATE INDEX idx_status ON tasks(isCompleted)');
    await db.execute('CREATE INDEX idx_goalId ON tasks(goalId)');
    await db.execute('CREATE INDEX idx_subtask_taskId ON subtasks(taskId)');
  }

  // Migration từ v1 sang v2
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Thêm các cột mới vào bảng tasks
      await db.execute('ALTER TABLE tasks ADD COLUMN recurringType INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE tasks ADD COLUMN recurringEndDate TEXT');
      await db.execute('ALTER TABLE tasks ADD COLUMN parentTaskId INTEGER');
      await db.execute('ALTER TABLE tasks ADD COLUMN goalId INTEGER');
      await db.execute('ALTER TABLE tasks ADD COLUMN completedAt TEXT');
      await db.execute('ALTER TABLE tasks ADD COLUMN pomodoroCount INTEGER NOT NULL DEFAULT 0');
      
      // Tạo các bảng mới
      await db.execute('''
        CREATE TABLE subtasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          taskId INTEGER NOT NULL,
          title TEXT NOT NULL,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          sortOrder INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE
        )
      ''');
      
      await db.execute('''
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          color INTEGER NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
      
      await db.execute('''
        CREATE TABLE task_tags (
          taskId INTEGER NOT NULL,
          tagId INTEGER NOT NULL,
          PRIMARY KEY (taskId, tagId),
          FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE,
          FOREIGN KEY (tagId) REFERENCES tags(id) ON DELETE CASCADE
        )
      ''');
      
      await db.execute('''
        CREATE TABLE goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          targetDate TEXT NOT NULL,
          color INTEGER NOT NULL,
          icon INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          isArchived INTEGER NOT NULL DEFAULT 0
        )
      ''');
      
      await db.execute('''
        CREATE TABLE pomodoro_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          taskId INTEGER,
          startTime TEXT NOT NULL,
          durationMinutes INTEGER NOT NULL,
          type INTEGER NOT NULL,
          completed INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE SET NULL
        )
      ''');
      
      await db.execute('''
        CREATE TABLE daily_completions (
          date TEXT PRIMARY KEY,
          completedCount INTEGER NOT NULL DEFAULT 0,
          totalCount INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  // =================== TASKS ===================
  
  Future<Task> createTask(Task task) async {
    final db = await database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final result = await db.query('tasks', orderBy: 'dueDate ASC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<Task?> getTask(int id) async {
    final db = await database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Task.fromMap(maps.first) : null;
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update('tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getTasksByGoal(int goalId) async {
    final db = await database;
    final result = await db.query('tasks',
        where: 'goalId = ?', whereArgs: [goalId], orderBy: 'dueDate ASC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> searchTasks(String keyword) async {
    final db = await database;
    final result = await db.query('tasks',
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%'],
        orderBy: 'dueDate ASC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> deleteCompletedTasks() async {
    final db = await database;
    return await db.delete('tasks', where: 'isCompleted = ?', whereArgs: [1]);
  }

  // =================== SUBTASKS ===================
  
  Future<SubTask> createSubTask(SubTask subtask) async {
    final db = await database;
    final id = await db.insert('subtasks', subtask.toMap());
    return subtask.copyWith(id: id);
  }

  Future<List<SubTask>> getSubTasksByTaskId(int taskId) async {
    final db = await database;
    final result = await db.query('subtasks',
        where: 'taskId = ?', whereArgs: [taskId], orderBy: 'sortOrder ASC');
    return result.map((map) => SubTask.fromMap(map)).toList();
  }

  Future<int> updateSubTask(SubTask subtask) async {
    final db = await database;
    return await db.update('subtasks', subtask.toMap(),
        where: 'id = ?', whereArgs: [subtask.id]);
  }

  Future<int> deleteSubTask(int id) async {
    final db = await database;
    return await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSubTasksByTaskId(int taskId) async {
    final db = await database;
    return await db.delete('subtasks', where: 'taskId = ?', whereArgs: [taskId]);
  }

  // =================== TAGS ===================
  
  Future<Tag> createTag(Tag tag) async {
    final db = await database;
    final id = await db.insert('tags', tag.toMap());
    return tag.copyWith(id: id);
  }

  Future<List<Tag>> getAllTags() async {
    final db = await database;
    final result = await db.query('tags', orderBy: 'name ASC');
    return result.map((map) => Tag.fromMap(map)).toList();
  }

  Future<int> updateTag(Tag tag) async {
    final db = await database;
    return await db.update('tags', tag.toMap(),
        where: 'id = ?', whereArgs: [tag.id]);
  }

  Future<int> deleteTag(int id) async {
    final db = await database;
    return await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setTaskTags(int taskId, List<int> tagIds) async {
    final db = await database;
    await db.delete('task_tags', where: 'taskId = ?', whereArgs: [taskId]);
    for (final tagId in tagIds) {
      await db.insert('task_tags', {'taskId': taskId, 'tagId': tagId});
    }
  }

  Future<List<Tag>> getTagsForTask(int taskId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT t.* FROM tags t
      INNER JOIN task_tags tt ON t.id = tt.tagId
      WHERE tt.taskId = ?
    ''', [taskId]);
    return result.map((map) => Tag.fromMap(map)).toList();
  }

  // =================== GOALS ===================
  
  Future<Goal> createGoal(Goal goal) async {
    final db = await database;
    final id = await db.insert('goals', goal.toMap());
    return goal.copyWith(id: id);
  }

  Future<List<Goal>> getAllGoals({bool includeArchived = false}) async {
    final db = await database;
    final result = await db.query('goals',
        where: includeArchived ? null : 'isArchived = ?',
        whereArgs: includeArchived ? null : [0],
        orderBy: 'targetDate ASC');
    return result.map((map) => Goal.fromMap(map)).toList();
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update('goals', goal.toMap(),
        where: 'id = ?', whereArgs: [goal.id]);
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // =================== POMODORO ===================
  
  Future<PomodoroSession> createPomodoroSession(PomodoroSession session) async {
    final db = await database;
    final id = await db.insert('pomodoro_sessions', session.toMap());
    return session.copyWith(id: id);
  }

  Future<List<PomodoroSession>> getPomodoroSessionsByTask(int taskId) async {
    final db = await database;
    final result = await db.query('pomodoro_sessions',
        where: 'taskId = ?', whereArgs: [taskId], orderBy: 'startTime DESC');
    return result.map((map) => PomodoroSession.fromMap(map)).toList();
  }

  Future<List<PomodoroSession>> getPomodoroSessionsToday() async {
    final db = await database;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    
    final result = await db.query('pomodoro_sessions',
        where: 'startTime >= ? AND startTime <= ? AND completed = 1',
        whereArgs: [start, end]);
    return result.map((map) => PomodoroSession.fromMap(map)).toList();
  }

  // =================== STREAK ===================
  
  Future<void> recordDailyCompletion(DateTime date, int completed, int total) async {
    final db = await database;
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    await db.insert(
      'daily_completions',
      {'date': dateStr, 'completedCount': completed, 'totalCount': total},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getDailyCompletions({int days = 30}) async {
    final db = await database;
    return await db.query('daily_completions',
        orderBy: 'date DESC', limit: days);
  }

  Future<int> calculateStreak() async {
    final db = await database;
    final result = await db.query('daily_completions',
        where: 'completedCount > 0',
        orderBy: 'date DESC');
    
    if (result.isEmpty) return 0;
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final row in result) {
      final dateParts = (row['date'] as String).split('-');
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      
      if (lastDate == null) {
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);
        final daysDiff = todayOnly.difference(date).inDays;
        if (daysDiff > 1) return 0;
        streak = 1;
        lastDate = date;
      } else {
        final daysDiff = lastDate.difference(date).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = date;
        } else {
          break;
        }
      }
    }
    
    return streak;
  }

  // Đóng database
  Future close() async {
    final db = await database;
    db.close();
  }
}