import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class NotificationService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> notify() async {
    await Future.wait([
      _playSound(),
      _vibrate(),
    ]);
  }

  Future<void> _playSound() async {
    try {
      // 簡単なビープ音を再生
      if (kIsWeb) {
        // Webの場合は短いビープ音データを使用
        const beepData = 'data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBjaK1fPTfSkDJXfH8N2QQAoUXrTp66hVFApGn+DyvmwhBjWG0vLKeCIHKn7N8+GGMQYWY7bp5KdUIgtBmuLtul4fBSuBzvLYizgYGGS57OihTgwKUqnl4q9BFAIEP2i99Ox9UQs='; 
        await _audioPlayer.play(UrlSource(beepData));
      } else {
        // モバイル・デスクトップの場合は、利用可能な音声ファイルがない場合は何もしない
        debugPrint('音声ファイルがありません - 振動のみで通知します');
      }
    } catch (e) {
      debugPrint('音声再生エラー: $e');
    }
  }

  Future<void> _vibrate() async {
    try {
      if (!kIsWeb && await Vibration.hasVibrator() == true) {
        await Vibration.vibrate(
          pattern: [
            0, 500, 100, 500, 100, 500,    // 1回目：ブル、ブル、ブル
            300,                           // 少し長めの休憩
            500, 100, 500, 100, 500,       // 2回目：ブル、ブル、ブル
            300,                           // 少し長めの休憩
            500, 100, 500, 100, 500        // 3回目：ブル、ブル、ブル
          ],
          intensities: [
            128, 255, 128, 255, 128, 255,  // 1回目
            0,                             // 休憩
            255, 128, 255, 128, 255,       // 2回目
            0,                             // 休憩
            255, 128, 255, 128, 255        // 3回目
          ],
        );
      }
    } catch (e) {
      debugPrint('振動エラー: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}