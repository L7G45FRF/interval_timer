import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/timer_state.dart';
import '../services/timer_service.dart';
import '../services/notification_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late TimerService _timerService;
  late NotificationService _notificationService;
  
  // カウントダウン用
  final _countdownMinutesController = TextEditingController(text: '0');
  final _countdownSecondsController = TextEditingController(text: '0');
  
  // インターバル用
  final _workMinutesController = TextEditingController(text: '0');
  final _workSecondsController = TextEditingController(text: '0');
  final _restMinutesController = TextEditingController(text: '0');
  final _restSecondsController = TextEditingController(text: '0');
  final _cyclesController = TextEditingController(text: '3');
  
  TimerType _selectedType = TimerType.countdown;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _timerService = TimerService(notificationService: _notificationService);
  }

  @override
  void dispose() {
    _timerService.dispose();
    _notificationService.dispose();
    _countdownMinutesController.dispose();
    _countdownSecondsController.dispose();
    _workMinutesController.dispose();
    _workSecondsController.dispose();
    _restMinutesController.dispose();
    _restSecondsController.dispose();
    _cyclesController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_selectedType == TimerType.countdown) {
      final minutes = _parseTimeInput(_countdownMinutesController.text, 0);
      final seconds = _parseTimeInput(_countdownSecondsController.text, 0);
      final totalSeconds = minutes * 60 + seconds;
      if (totalSeconds > 0) {
        _timerService.startCountdownTimer(totalSeconds);
      }
    } else {
      final workMinutes = _parseTimeInput(_workMinutesController.text, 0);
      final workSeconds = _parseTimeInput(_workSecondsController.text, 0);
      final restMinutes = _parseTimeInput(_restMinutesController.text, 0);
      final restSeconds = _parseTimeInput(_restSecondsController.text, 0);
      final cycles = _parseTimeInput(_cyclesController.text, 0);
      final workTotalSeconds = workMinutes * 60 + workSeconds;
      final restTotalSeconds = restMinutes * 60 + restSeconds;
      if (workTotalSeconds > 0 && restTotalSeconds > 0 && cycles > 0) {
        _timerService.startIntervalTimer(
          workSeconds: workTotalSeconds,
          restSeconds: restTotalSeconds,
          totalCycles: cycles,
        );
      }
    }
  }

  bool _canStartTimer() {
    if (_selectedType == TimerType.countdown) {
      final minutes = _parseTimeInput(_countdownMinutesController.text, 0);
      final seconds = _parseTimeInput(_countdownSecondsController.text, 0);
      return (minutes * 60 + seconds) > 0;
    } else {
      final workMinutes = _parseTimeInput(_workMinutesController.text, 0);
      final workSeconds = _parseTimeInput(_workSecondsController.text, 0);
      final restMinutes = _parseTimeInput(_restMinutesController.text, 0);
      final restSeconds = _parseTimeInput(_restSecondsController.text, 0);
      final cycles = _parseTimeInput(_cyclesController.text, 0);
      return (workMinutes * 60 + workSeconds) > 0 && 
             (restMinutes * 60 + restSeconds) > 0 && 
             cycles > 0;
    }
  }

  int _parseTimeInput(String input, int defaultValue) {
    // 空文字列の場合は0を返す
    if (input.trim().isEmpty) {
      return 0;
    }
    // パース可能な場合はその値を、不可能な場合はデフォルト値を返す
    return int.tryParse(input) ?? defaultValue;
  }

  void _handleFieldFocusLost(TextEditingController controller) {
    if (controller.text.trim().isEmpty) {
      controller.text = '0';
    }
    FocusScope.of(context).unfocus(); // キーボードを閉じる
    setState(() {}); // UI更新をトリガー
  }


  void _adjustTime(TextEditingController controller, int increment) {
    final currentValue = _parseTimeInput(controller.text, 0);
    final newValue = (currentValue + increment).clamp(0, 999);
    controller.text = newValue.toString();
    setState(() {});
  }

  void _clearTime(TextEditingController minutesController, TextEditingController secondsController) {
    minutesController.text = '0';
    secondsController.text = '0';
    setState(() {});
  }

  Widget _buildTimeControls({
    required TextEditingController minutesController,
    required TextEditingController secondsController,
    required bool enabled,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // 分の入力とコントロール
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      // 分 ダウンボタン
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: enabled ? () => _adjustTime(minutesController, -5) : null,
                          icon: const Icon(Icons.remove),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 分 入力フィールド
                      Expanded(
                        child: TextFormField(
                          controller: minutesController,
                          decoration: const InputDecoration(
                            labelText: '分',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          enabled: enabled,
                          onChanged: (_) => setState(() {}),
                          onEditingComplete: () => _handleFieldFocusLost(minutesController),
                          onFieldSubmitted: (_) => _handleFieldFocusLost(minutesController),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 分 アップボタン
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: enabled ? () => _adjustTime(minutesController, 5) : null,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 秒の入力とコントロール
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      // 秒 ダウンボタン
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: enabled ? () => _adjustTime(secondsController, -10) : null,
                          icon: const Icon(Icons.remove),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 秒 入力フィールド
                      Expanded(
                        child: TextFormField(
                          controller: secondsController,
                          decoration: const InputDecoration(
                            labelText: '秒',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          enabled: enabled,
                          onChanged: (_) => setState(() {}),
                          onEditingComplete: () => _handleFieldFocusLost(secondsController),
                          onFieldSubmitted: (_) => _handleFieldFocusLost(secondsController),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 秒 アップボタン
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: enabled ? () => _adjustTime(secondsController, 10) : null,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // クリアボタン
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: enabled ? () => _clearTime(minutesController, secondsController) : null,
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('クリア'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  void _pauseTimer() {
    _timerService.pauseTimer();
  }

  void _resumeTimer() {
    _timerService.resumeTimer();
  }

  void _stopTimer() {
    _timerService.stopTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('インターバルタイマー'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 画面タップでキーボードを閉じる
        child: StreamBuilder<TimerState>(
          stream: _timerService.stateStream,
          initialData: _timerService.currentState,
          builder: (context, snapshot) {
            final state = snapshot.data!;
            
            return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
            child: Column(
              children: [
                // タイマー表示（最上部に配置）
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _getTimerColor(state),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.formattedTime,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (state.isInterval) ...[
                        const SizedBox(height: 4),
                        Text(
                          state.currentPhase == TimerPhase.work ? 'トレーニング' : '休憩',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        if (state.totalCycles > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${state.currentCycle}/${state.totalCycles} サイクル',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // コントロールボタン
                Column(
                  children: [
                    // 開始ボタン（大きめ）
                    if (state.isInitial)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: _canStartTimer() ? _startTimer : null,
                          icon: const Icon(Icons.play_arrow, size: 28),
                          label: const Text(
                            '開始',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canStartTimer() ? Colors.green : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    
                    // その他のボタン（通常サイズ）
                    if (!state.isInitial) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: state.isRunning ? _pauseTimer : null,
                            icon: const Icon(Icons.pause),
                            label: const Text('一時停止'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: state.isPaused ? _resumeTimer : null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('再開'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _stopTimer,
                            icon: const Icon(Icons.stop),
                            label: const Text('停止'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // タイマー選択
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'タイマーの種類',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<TimerType>(
                                title: const Text('カウントダウン', style: TextStyle(fontSize: 14)),
                                value: TimerType.countdown,
                                groupValue: _selectedType,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                dense: true,
                                onChanged: state.isInitial ? (value) {
                                  setState(() {
                                    _selectedType = value!;
                                  });
                                } : null,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<TimerType>(
                                title: const Text('インターバル', style: TextStyle(fontSize: 14)),
                                value: TimerType.interval,
                                groupValue: _selectedType,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                dense: true,
                                onChanged: state.isInitial ? (value) {
                                  setState(() {
                                    _selectedType = value!;
                                  });
                                } : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // 設定
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _selectedType == TimerType.countdown 
                        ? _buildCountdownSettings(state)
                        : _buildIntervalSettings(state),
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

  Widget _buildCountdownSettings(TimerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'カウントダウン設定',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTimeControls(
          minutesController: _countdownMinutesController,
          secondsController: _countdownSecondsController,
          enabled: state.isInitial,
          label: '',
        ),
      ],
    );
  }

  Widget _buildIntervalSettings(TimerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'インターバル設定',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTimeControls(
          minutesController: _workMinutesController,
          secondsController: _workSecondsController,
          enabled: state.isInitial,
          label: 'トレーニング時間',
        ),
        const SizedBox(height: 16),
        _buildTimeControls(
          minutesController: _restMinutesController,
          secondsController: _restSecondsController,
          enabled: state.isInitial,
          label: '休憩時間',
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cyclesController,
          decoration: const InputDecoration(
            labelText: 'サイクル数（0で無限）',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          enabled: state.isInitial,
          onChanged: (_) => setState(() {}),
          onEditingComplete: () => _handleFieldFocusLost(_cyclesController),
          onFieldSubmitted: (_) => _handleFieldFocusLost(_cyclesController),
        ),
      ],
    );
  }

  Color _getTimerColor(TimerState state) {
    if (state.isFinished) {
      return Colors.green;
    } else if (state.isRunning) {
      if (state.isInterval) {
        return state.currentPhase == TimerPhase.work 
            ? Colors.red 
            : Colors.blue;
      }
      return Colors.blue;
    } else if (state.isPaused) {
      return Colors.orange;
    }
    return Colors.grey;
  }
}