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
  
  final _countdownController = TextEditingController(text: '5');
  final _workController = TextEditingController(text: '5');
  final _restController = TextEditingController(text: '1');
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
    _countdownController.dispose();
    _workController.dispose();
    _restController.dispose();
    _cyclesController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_selectedType == TimerType.countdown) {
      final minutes = int.tryParse(_countdownController.text) ?? 5;
      _timerService.startCountdownTimer(minutes * 60);
    } else {
      final workMinutes = int.tryParse(_workController.text) ?? 5;
      final restMinutes = int.tryParse(_restController.text) ?? 1;
      final cycles = int.tryParse(_cyclesController.text) ?? 0;
      _timerService.startIntervalTimer(
        workSeconds: workMinutes * 60,
        restSeconds: restMinutes * 60,
        totalCycles: cycles,
      );
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: state.isInitial ? _startTimer : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('開始'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
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
                      onPressed: !state.isInitial ? _stopTimer : null,
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
        TextFormField(
          controller: _countdownController,
          decoration: const InputDecoration(
            labelText: '時間（分）',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          enabled: state.isInitial,
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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _workController,
                decoration: const InputDecoration(
                  labelText: 'トレーニング（分）',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: state.isInitial,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _restController,
                decoration: const InputDecoration(
                  labelText: '休憩（分）',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: state.isInitial,
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