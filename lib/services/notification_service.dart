import 'package:flutter/foundation.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

class NotificationService {
  final FlutterRingtonePlayer _ringtonePlayer = FlutterRingtonePlayer();

  Future<void> notify({bool isIntervalEnd = false}) async {
    await Future.wait([_playSound(), _vibrate(isIntervalEnd: isIntervalEnd)]);
  }

  Future<void> _playSound() async {
    try {
      // flutter_ringtone_playerを使用してシステム音を再生
      await _ringtonePlayer.playNotification();
    } catch (e) {
      debugPrint('音声再生エラー: $e');
    }
  }

  Future<void> _vibrate({bool isIntervalEnd = false}) async {
    try {
      if (!kIsWeb && await Vibration.hasVibrator() == true) {
        if (isIntervalEnd) {
          // インターバル終了時：ブ〜〜ン（長い振動）
          await Vibration.vibrate(
            pattern: [0, 1000], // 1秒の長い振動
            intensities: [255], // 最大強度
          );
        } else {
          // 通常時：ブル、ブル、ブル×2回
          await Vibration.vibrate(
            pattern: [
              0, 300, 100, 300, 100, 300, // 1回目：ブル、ブル、ブル
              400, // 少し長めの休憩
              300, 100, 300, 100, 300, // 2回目：ブル、ブル、ブル
            ],
            intensities: [
              128, 255, 128, 255, 128, 255, // 1回目
              0, // 休憩
              255, 128, 255, 128, 255, // 2回目
            ],
          );
        }
      }
    } catch (e) {
      debugPrint('振動エラー: $e');
    }
  }

  void dispose() {
    // flutter_ringtone_playerは自動でリソース管理されるため、特別な処理は不要
  }
}
