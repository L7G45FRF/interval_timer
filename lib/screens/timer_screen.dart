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
  final _countdownMinutesController = TextEditingController(text: '5');
  final _countdownSecondsController = TextEditingController(text: '0');
  
  // インターバル用
  final _workMinutesController = TextEditingController(text: '5');
  final _workSecondsController = TextEditingController(text: '0');
  final _restMinutesController = TextEditingController(text: '1');
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
      final minutes = _parseTimeInput(_countdownMinutesController.text, 5);
      final seconds = _parseTimeInput(_countdownSecondsController.text, 0);
      final totalSeconds = minutes * 60 + seconds;
      _timerService.startCountdownTimer(totalSeconds);
    } else {
      final workMinutes = _parseTimeInput(_workMinutesController.text, 5);
      final workSeconds = _parseTimeInput(_workSecondsController.text, 0);
      final restMinutes = _parseTimeInput(_restMinutesController.text, 1);
      final restSeconds = _parseTimeInput(_restSecondsController.text, 0);
      final cycles = _parseTimeInput(_cyclesController.text, 0);
      _timerService.startIntervalTimer(
        workSeconds: workMinutes * 60 + workSeconds,
        restSeconds: restMinutes * 60 + restSeconds,
        totalCycles: cycles,
      );
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
      body: StreamBuilder<TimerState>(
        stream: _timerService.stateStream,
        initialData: _timerService.currentState,
        builder: (context, snapshot) {
          final state = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // タイマー選択
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'タイマーの種類',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<TimerType>(
                                title: const Text('カウントダウン'),
                                value: TimerType.countdown,
                                groupValue: _selectedType,
                                onChanged: state.isInitial ? (value) {
                                  setState(() {
                                    _selectedType = value!;
                                  });
                                } : null,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<TimerType>(
                                title: const Text('インターバル'),
                                value: TimerType.interval,
                                groupValue: _selectedType,
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
                
                const SizedBox(height: 16),
                
                // 設定
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _selectedType == TimerType.countdown 
                        ? _buildCountdownSettings(state)
                        : _buildIntervalSettings(state),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // タイマー表示
                Container(
                  width: double.infinity,
                  height: 200,
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
                        const SizedBox(height: 8),
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
                
                const SizedBox(height: 24),
                
                // コントロールボタン
                Column(
                  children: [
                    // 開始ボタン（大きめ）
                    if (state.isInitial)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: _startTimer,
                          icon: const Icon(Icons.play_arrow, size: 28),
                          label: const Text(
                            '開始',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
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
              ],
            ),
          );
        },
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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _countdownMinutesController,
                decoration: const InputDecoration(
                  labelText: '分',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: state.isInitial,
                onEditingComplete: () => _handleFieldFocusLost(_countdownMinutesController),
                onFieldSubmitted: (_) => _handleFieldFocusLost(_countdownMinutesController),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _countdownSecondsController,
                decoration: const InputDecoration(
                  labelText: '秒',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: state.isInitial,
                onEditingComplete: () => _handleFieldFocusLost(_countdownSecondsController),
                onFieldSubmitted: (_) => _handleFieldFocusLost(_countdownSecondsController),
              ),
            ),
          ],
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
        // トレーニング時間
        const Text(
          'トレーニング時間',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _workMinutesController,
                decoration: const InputDecoration(
                  labelText: '分',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: state.isInitial,
                onEditingComplete: () => _handleFieldFocusLost(_workMinutesController),
                onFieldSubmitted: (_) => _handleFieldFocusLost(_workMinutesController),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _workSecondsController,
                decoration: const InputDecoration(
                  labelText: '秒',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: state.isInitial,
                onEditingComplete: () => _handleFieldFocusLost(_workSecondsController),
                onFieldSubmitted: (_) => _handleFieldFocusLost(_workSecondsController),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 休憩時間
        const Text(
          '休憩時間',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _restMinutesController,
                decoration: const InputDecoration(
                  labelText: '分',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: state.isInitial,
                onEditingComplete: () => _handleFieldFocusLost(_restMinutesController),
                onFieldSubmitted: (_) => _handleFieldFocusLost(_restMinutesController),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _restSecondsController,
                decoration: const InputDecoration(
                  labelText: '秒',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: state.isInitial,
                onEditingComplete: () => _handleFieldFocusLost(_restSecondsController),
                onFieldSubmitted: (_) => _handleFieldFocusLost(_restSecondsController),
              ),
            ),
          ],
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