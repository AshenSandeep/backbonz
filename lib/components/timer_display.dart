import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/duration_formatter.dart';
import '../viewModels/timer_viewmodel.dart';

class TimerDisplay extends StatelessWidget {
  final Duration elapsed;
  final TimerStatus status;

  const TimerDisplay({
    super.key,
    required this.elapsed,
    required this.status,
  });

  Color get _timerColor {
    switch (status) {
      case TimerStatus.running:
        return AppColors.timerActive;
      case TimerStatus.paused:
        return AppColors.timerPaused;
      case TimerStatus.idle:
        return AppColors.timerStopped;
    }
  }

  String get _statusLabel {
    switch (status) {
      case TimerStatus.running:
        return 'TRACKING';
      case TimerStatus.paused:
        return 'PAUSED';
      case TimerStatus.idle:
        return 'READY';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circular ring around timer
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _timerColor,
              width: 4,
            ),
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: _timerColor.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              DurationFormatter.format(elapsed),
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: _timerColor,
                letterSpacing: 2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Status label below the ring
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _timerColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _statusLabel,
            style: TextStyle(
              color: _timerColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}