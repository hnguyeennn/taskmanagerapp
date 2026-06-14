import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/pomodoro_session.dart';
import '../models/task.dart';
import 'database_service.dart';
import 'notification_service.dart';

enum PomodoroState { idle, running, paused, completed }

class PomodoroProvider extends ChangeNotifier {
  // Cấu hình mặc định
  int workMinutes = 25;
  int shortBreakMinutes = 5;
  int longBreakMinutes = 15;
  int sessionsBeforeLongBreak = 4;

  // State
  PomodoroState _state = PomodoroState.idle;
  PomodoroType _currentType = PomodoroType.work;
  int _remainingSeconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  int _completedWorkSessions = 0;
  Task? _currentTask;
  Timer? _timer;
  DateTime? _sessionStartTime;

  // Getters
  PomodoroState get state => _state;
  PomodoroType get currentType => _currentType;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  int get completedWorkSessions => _completedWorkSessions;
  Task? get currentTask => _currentTask;
  bool get isRunning => _state == PomodoroState.running;
  bool get isPaused => _state == PomodoroState.paused;

  // Tính progress 0.0 - 1.0
  double get progress {
    if (_totalSeconds == 0) return 0;
    return 1.0 - (_remainingSeconds / _totalSeconds);
  }

  // Format thời gian "MM:SS"
  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get currentTypeLabel {
    switch (_currentType) {
      case PomodoroType.work:
        return 'Tập trung làm việc';
      case PomodoroType.shortBreak:
        return 'Nghỉ ngắn';
      case PomodoroType.longBreak:
        return 'Nghỉ dài';
    }
  }

  // Bắt đầu phiên mới
  void startSession({Task? task, PomodoroType? type}) {
    _currentTask = task;
    _currentType = type ?? PomodoroType.work;

    switch (_currentType) {
      case PomodoroType.work:
        _totalSeconds = workMinutes * 60;
        break;
      case PomodoroType.shortBreak:
        _totalSeconds = shortBreakMinutes * 60;
        break;
      case PomodoroType.longBreak:
        _totalSeconds = longBreakMinutes * 60;
        break;
    }

    _remainingSeconds = _totalSeconds;
    _sessionStartTime = DateTime.now();
    _state = PomodoroState.running;
    _startTimer();
    notifyListeners();
  }

  // Tạm dừng
  void pause() {
    if (_state != PomodoroState.running) return;
    _timer?.cancel();
    _state = PomodoroState.paused;
    notifyListeners();
  }

  // Tiếp tục
  void resume() {
    if (_state != PomodoroState.paused) return;
    _state = PomodoroState.running;
    _startTimer();
    notifyListeners();
  }

  // Bỏ qua phiên hiện tại
  void skip() {
    _timer?.cancel();
    _onSessionEnd(completed: false);
  }

  // Dừng hẳn
  void stop() {
    _timer?.cancel();
    _state = PomodoroState.idle;
    _remainingSeconds = _totalSeconds;
    _currentTask = null;
    _sessionStartTime = null;
    notifyListeners();
  }

  // Đổi cấu hình thời gian
  void updateSettings({
    int? work,
    int? shortBreak,
    int? longBreak,
    int? sessionsBeforeLong,
  }) {
    if (work != null) workMinutes = work;
    if (shortBreak != null) shortBreakMinutes = shortBreak;
    if (longBreak != null) longBreakMinutes = longBreak;
    if (sessionsBeforeLong != null) {
      sessionsBeforeLongBreak = sessionsBeforeLong;
    }

    // Nếu đang ở trạng thái idle thì cập nhật ngay
    if (_state == PomodoroState.idle) {
      _totalSeconds = workMinutes * 60;
      _remainingSeconds = _totalSeconds;
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _onSessionEnd(completed: true);
      }
    });
  }

  Future<void> _onSessionEnd({required bool completed}) async {
    // Lưu session vào database
    if (_sessionStartTime != null) {
      final session = PomodoroSession(
        taskId: _currentTask?.id,
        startTime: _sessionStartTime!,
        durationMinutes: (_totalSeconds - _remainingSeconds) ~/ 60,
        type: _currentType,
        completed: completed,
      );
      await DatabaseService.instance.createPomodoroSession(session);

      // Nếu là phiên work hoàn thành → tăng pomodoroCount của task
      if (completed && _currentType == PomodoroType.work && _currentTask != null) {
        _completedWorkSessions++;

        if (_currentTask?.id != null) {
          final updatedTask = _currentTask!.copyWith(
            pomodoroCount: _currentTask!.pomodoroCount + 1,
          );
          await DatabaseService.instance.updateTask(updatedTask);
          _currentTask = updatedTask;
        }
      }
    }

    // Gửi thông báo kết thúc phiên
    if (completed) {
      await _showCompletionNotification();
    }

    _state = PomodoroState.completed;
    notifyListeners();

    // Tự động chuyển sang phiên tiếp theo sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (_state == PomodoroState.completed) {
        _autoStartNext();
      }
    });
  }

  void _autoStartNext() {
    PomodoroType nextType;
    if (_currentType == PomodoroType.work) {
      // Sau phiên work, đến giờ nghỉ
      if (_completedWorkSessions % sessionsBeforeLongBreak == 0 &&
          _completedWorkSessions > 0) {
        nextType = PomodoroType.longBreak;
      } else {
        nextType = PomodoroType.shortBreak;
      }
    } else {
      // Sau phiên nghỉ, quay lại làm việc
      nextType = PomodoroType.work;
    }

    // Reset về idle, chuẩn bị cho phiên mới
    _currentType = nextType;
    switch (nextType) {
      case PomodoroType.work:
        _totalSeconds = workMinutes * 60;
        break;
      case PomodoroType.shortBreak:
        _totalSeconds = shortBreakMinutes * 60;
        break;
      case PomodoroType.longBreak:
        _totalSeconds = longBreakMinutes * 60;
        break;
    }
    _remainingSeconds = _totalSeconds;
    _state = PomodoroState.idle;
    notifyListeners();
  }

  Future<void> _showCompletionNotification() async {
    String title;
    String body;

    switch (_currentType) {
      case PomodoroType.work:
        title = 'Hoàn thành phiên làm việc!';
        body = _currentTask != null
            ? '✅ ${_currentTask!.title} - Đã hoàn thành $workMinutes phút tập trung'
            : '✅ Đã hoàn thành $workMinutes phút tập trung. Nghỉ ngơi thôi!';
        break;
      case PomodoroType.shortBreak:
        title = 'Hết giờ nghỉ ngắn';
        body = 'Sẵn sàng cho phiên tập trung tiếp theo?';
        break;
      case PomodoroType.longBreak:
        title = 'Hết giờ nghỉ dài';
        body = 'Quay lại làm việc nào!';
        break;
    }

    await NotificationService.instance.showPomodoroComplete(
      title: title,
      body: body,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}