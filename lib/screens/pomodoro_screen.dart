import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pomodoro_session.dart';
import '../models/task.dart';
import '../services/pomodoro_provider.dart';
import '../utils/app_utils.dart';

class PomodoroScreen extends StatelessWidget {
  final Task? task;
  const PomodoroScreen({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text('Pomodoro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Consumer<PomodoroProvider>(
        builder: (context, pomo, _) {
          // Nếu có task được truyền vào và chưa đang chạy thì set task
          if (task != null &&
              pomo.currentTask == null &&
              pomo.state == PomodoroState.idle) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              pomo.startSession(task: task, type: PomodoroType.work);
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hiển thị task hiện tại
                if (pomo.currentTask != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.task_alt,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            pomo.currentTask!.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        if (pomo.currentTask!.pomodoroCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🍅',
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  '${pomo.currentTask!.pomodoroCount}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Label loại phiên
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getTypeColor(pomo.currentType)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getTypeIcon(pomo.currentType),
                          color: _getTypeColor(pomo.currentType),
                          size: 16),
                      const SizedBox(width: 6),
                      Text(
                        pomo.currentTypeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: _getTypeColor(pomo.currentType),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Vòng tròn đếm ngược
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CustomPaint(
                        painter: _CircleProgressPainter(
                          progress: pomo.progress,
                          color: _getTypeColor(pomo.currentType),
                          backgroundColor: AppColors.border(context),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pomo.formattedTime,
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w300,
                            color: AppColors.textPrimary(context),
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (pomo.completedWorkSessions > 0)
                          Text(
                            'Đã hoàn thành ${pomo.completedWorkSessions} phiên',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                // Các nút điều khiển
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (pomo.state == PomodoroState.running ||
                        pomo.state == PomodoroState.paused) ...[
                      _circleButton(
                        icon: Icons.stop,
                        color: AppColors.danger,
                        onPressed: () {
                          pomo.stop();
                          Navigator.pop(context);
                        },
                        size: 56,
                      ),
                      const SizedBox(width: 16),
                    ],
                    _circleButton(
                      icon: pomo.state == PomodoroState.running
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: _getTypeColor(pomo.currentType),
                      onPressed: () {
                        if (pomo.state == PomodoroState.running) {
                          pomo.pause();
                        } else if (pomo.state == PomodoroState.paused) {
                          pomo.resume();
                        } else {
                          pomo.startSession(
                            task: pomo.currentTask ?? task,
                            type: pomo.currentType,
                          );
                        }
                      },
                      size: 80,
                    ),
                    if (pomo.state == PomodoroState.running ||
                        pomo.state == PomodoroState.paused) ...[
                      const SizedBox(width: 16),
                      _circleButton(
                        icon: Icons.skip_next,
                        color: AppColors.textSecondary(context),
                        onPressed: () => pomo.skip(),
                        size: 56,
                      ),
                    ],
                  ],
                ),

                if (pomo.state == PomodoroState.completed) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hoàn thành phiên! Đang chuyển sang phiên tiếp...',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required double size,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.white, size: size * 0.5),
        ),
      ),
    );
  }

  Color _getTypeColor(PomodoroType type) {
    switch (type) {
      case PomodoroType.work:
        return AppColors.danger;
      case PomodoroType.shortBreak:
        return AppColors.success;
      case PomodoroType.longBreak:
        return AppColors.info;
    }
  }

  IconData _getTypeIcon(PomodoroType type) {
    switch (type) {
      case PomodoroType.work:
        return Icons.work;
      case PomodoroType.shortBreak:
        return Icons.coffee;
      case PomodoroType.longBreak:
        return Icons.weekend;
    }
  }

  void _showSettings(BuildContext context) {
    final pomo = context.read<PomodoroProvider>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cấu hình Pomodoro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _settingItem(
                    context,
                    label: 'Thời gian tập trung (phút)',
                    value: pomo.workMinutes,
                    min: 5,
                    max: 60,
                    onChanged: (v) {
                      setState(() {});
                      pomo.updateSettings(work: v);
                    },
                  ),
                  const SizedBox(height: 16),

                  _settingItem(
                    context,
                    label: 'Nghỉ ngắn (phút)',
                    value: pomo.shortBreakMinutes,
                    min: 1,
                    max: 30,
                    onChanged: (v) {
                      setState(() {});
                      pomo.updateSettings(shortBreak: v);
                    },
                  ),
                  const SizedBox(height: 16),

                  _settingItem(
                    context,
                    label: 'Nghỉ dài (phút)',
                    value: pomo.longBreakMinutes,
                    min: 5,
                    max: 60,
                    onChanged: (v) {
                      setState(() {});
                      pomo.updateSettings(longBreak: v);
                    },
                  ),
                  const SizedBox(height: 16),

                  _settingItem(
                    context,
                    label: 'Số phiên trước nghỉ dài',
                    value: pomo.sessionsBeforeLongBreak,
                    min: 2,
                    max: 8,
                    onChanged: (v) {
                      setState(() {});
                      pomo.updateSettings(sessionsBeforeLong: v);
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Lưu',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _settingItem(
    BuildContext context, {
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary(context))),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border(context),
          onChanged: (v) => onChanged(v.toInt()),
        ),
      ],
    );
  }
}

// Vẽ vòng tròn progress
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Vẽ background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius, bgPaint);

    // Vẽ progress
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter old) {
    return old.progress != progress || old.color != color;
  }
}