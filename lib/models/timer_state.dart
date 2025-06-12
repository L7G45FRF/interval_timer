enum TimerStatus { initial, running, paused, finished }

enum TimerType { countdown, interval }

class TimerState {
  const TimerState({
    required this.duration,
    required this.status,
    required this.type,
    this.intervalWorkDuration = 0,
    this.intervalRestDuration = 0,
    this.currentPhase = TimerPhase.work,
    this.currentCycle = 0,
    this.totalCycles = 0,
  });

  final int duration; // 現在の残り時間（秒）
  final TimerStatus status;
  final TimerType type;
  
  // インターバルタイマー用の設定
  final int intervalWorkDuration; // トレーニング時間（秒）
  final int intervalRestDuration; // 休憩時間（秒）
  final TimerPhase currentPhase; // 現在のフェーズ
  final int currentCycle; // 現在のサイクル数
  final int totalCycles; // 総サイクル数（0の場合は無限）

  TimerState copyWith({
    int? duration,
    TimerStatus? status,
    TimerType? type,
    int? intervalWorkDuration,
    int? intervalRestDuration,
    TimerPhase? currentPhase,
    int? currentCycle,
    int? totalCycles,
  }) {
    return TimerState(
      duration: duration ?? this.duration,
      status: status ?? this.status,
      type: type ?? this.type,
      intervalWorkDuration: intervalWorkDuration ?? this.intervalWorkDuration,
      intervalRestDuration: intervalRestDuration ?? this.intervalRestDuration,
      currentPhase: currentPhase ?? this.currentPhase,
      currentCycle: currentCycle ?? this.currentCycle,
      totalCycles: totalCycles ?? this.totalCycles,
    );
  }

  String get formattedTime {
    final int minutes = duration ~/ 60;
    final int seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isInitial => status == TimerStatus.initial;
  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isFinished => status == TimerStatus.finished;
  bool get isCountdown => type == TimerType.countdown;
  bool get isInterval => type == TimerType.interval;
}

enum TimerPhase { work, rest }