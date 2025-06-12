import 'dart:async';
import '../models/timer_state.dart';
import 'notification_service.dart';

class TimerService {
  TimerService({required this.notificationService});

  final NotificationService notificationService;
  Timer? _timer;
  TimerState _state = const TimerState(
    duration: 0,
    status: TimerStatus.initial,
    type: TimerType.countdown,
  );

  Stream<TimerState> get stateStream => _stateController.stream;
  final StreamController<TimerState> _stateController = StreamController<TimerState>.broadcast();

  TimerState get currentState => _state;

  void startCountdownTimer(int seconds) {
    _state = TimerState(
      duration: seconds,
      status: TimerStatus.running,
      type: TimerType.countdown,
    );
    _emitState();
    _startTimer();
  }

  void startIntervalTimer({
    required int workSeconds,
    required int restSeconds,
    int totalCycles = 0, // 0は無限
  }) {
    _state = TimerState(
      duration: workSeconds,
      status: TimerStatus.running,
      type: TimerType.interval,
      intervalWorkDuration: workSeconds,
      intervalRestDuration: restSeconds,
      currentPhase: TimerPhase.work,
      currentCycle: 1,
      totalCycles: totalCycles,
    );
    _emitState();
    _startTimer();
  }

  void pauseTimer() {
    _timer?.cancel();
    _state = _state.copyWith(status: TimerStatus.paused);
    _emitState();
  }

  void resumeTimer() {
    if (_state.isPaused) {
      _state = _state.copyWith(status: TimerStatus.running);
      _emitState();
      _startTimer();
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _state = const TimerState(
      duration: 0,
      status: TimerStatus.initial,
      type: TimerType.countdown,
    );
    _emitState();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.duration > 0) {
        _state = _state.copyWith(duration: _state.duration - 1);
        _emitState();
      } else {
        _handleTimerEnd();
      }
    });
  }

  void _handleTimerEnd() async {
    await notificationService.notify();

    if (_state.isCountdown) {
      _timer?.cancel();
      _state = _state.copyWith(status: TimerStatus.finished);
      _emitState();
    } else if (_state.isInterval) {
      _handleIntervalPhaseEnd();
    }
  }

  void _handleIntervalPhaseEnd() {
    if (_state.currentPhase == TimerPhase.work) {
      // ワークフェーズ終了、レストフェーズに移行
      _state = _state.copyWith(
        duration: _state.intervalRestDuration,
        currentPhase: TimerPhase.rest,
      );
      _emitState();
    } else {
      // レストフェーズ終了
      if (_state.totalCycles > 0 && _state.currentCycle >= _state.totalCycles) {
        // 設定されたサイクル数完了
        _timer?.cancel();
        _state = _state.copyWith(status: TimerStatus.finished);
        _emitState();
        return;
      }
      
      // 次のサイクルのワークフェーズに移行
      _state = _state.copyWith(
        duration: _state.intervalWorkDuration,
        currentPhase: TimerPhase.work,
        currentCycle: _state.currentCycle + 1,
      );
      _emitState();
    }
  }

  void _emitState() {
    _stateController.add(_state);
  }

  void dispose() {
    _timer?.cancel();
    _stateController.close();
  }
}