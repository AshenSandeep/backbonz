import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';

enum TimerStatus { idle, running, paused }

// Manages brace wear timer logic.
class TimerViewModel extends GetxController {
  final SessionService _sessionService = SessionService();

  final _status = TimerStatus.idle.obs;
  final _elapsed = Duration.zero.obs;

  DateTime? _startTime;
  Duration _pausedDuration = Duration.zero;
  DateTime? _pausedAt;
  Timer? _ticker;

  TimerStatus get status => _status.value;
  Duration get elapsed => _elapsed.value;
  bool get isRunning => _status.value == TimerStatus.running;
  bool get isPaused => _status.value == TimerStatus.paused;
  bool get isIdle => _status.value == TimerStatus.idle;

  void start() {
    if (_status.value == TimerStatus.idle) {
      // Fresh start, record start timestamp
      _startTime = DateTime.now();
      _pausedDuration = Duration.zero;
    } else if (_status.value == TimerStatus.paused) {
      // Resume, accumulate paused duration
      _pausedDuration += DateTime.now().difference(_pausedAt!);
    }

    _status.value = TimerStatus.running;

    // Tick every second, recalculate elapsed from timestamps
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed.value =
          DateTime.now().difference(_startTime!) - _pausedDuration;
    });
  }

  void pause() {
    if (_status.value != TimerStatus.running) return;
    _ticker?.cancel();
    _pausedAt = DateTime.now();
    _status.value = TimerStatus.paused;
  }

  // Stop timer and save session
  Future<void> stop() async {
    if (_status.value == TimerStatus.idle) return;
    _ticker?.cancel();

    final endTime = DateTime.now();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && _startTime != null && _elapsed.value.inSeconds > 0) {
      final session = SessionModel(
        userId: user.uid,
        startTime: _startTime!,
        endTime: endTime,
        duration: _elapsed.value,
      );
      await _sessionService.saveSession(session);
    }

    _reset();
  }

  void _reset() {
    _status.value = TimerStatus.idle;
    _elapsed.value = Duration.zero;
    _startTime = null;
    _pausedDuration = Duration.zero;
    _pausedAt = null;
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}