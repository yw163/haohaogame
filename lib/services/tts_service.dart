import 'package:flutter_tts/flutter_tts.dart';

/// 中文语音读题服务。孩子识字不全，靠系统 TTS 朗读题目、选项和夸奖。
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool enabled = true;

  Future<void> init() async {
    if (_ready) return;
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.45); // 慢一点，适合孩子
      await _tts.setPitch(1.1); // 稍高，亲切
      await _tts.setVolume(1.0);
      _ready = true;
    } catch (_) {
      _ready = false; // 设备不支持 TTS 时静默降级
    }
  }

  Future<void> speak(String text) async {
    if (!enabled || text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
