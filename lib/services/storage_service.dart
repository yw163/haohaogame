import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/game_progress.dart';

/// 进度 + 设置的本地持久化（SharedPreferences）。
/// 照片本身不存这里，只存「技能 id -> 照片文件路径」的映射。
class StorageService {
  static const _kProgress = 'progress_v1';
  static const _kPhotos = 'skill_photos_v1';
  static const _kPin = 'parent_pin_v1';
  static const _kSound = 'sound_on_v1';
  static const _kFirstRun = 'first_run_done_v1';

  final SharedPreferences _prefs;
  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // —— 进度 ——
  GameProgress loadProgress() {
    final raw = _prefs.getString(_kProgress);
    if (raw == null) return const GameProgress();
    try {
      return GameProgress.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const GameProgress();
    }
  }

  Future<void> saveProgress(GameProgress p) async {
    await _prefs.setString(_kProgress, json.encode(p.toJson()));
  }

  Future<void> resetProgress() async {
    await _prefs.remove(_kProgress);
  }

  // —— 技能照片映射 ——
  Map<String, String> loadPhotoMap() {
    final raw = _prefs.getString(_kPhotos);
    if (raw == null) return {};
    try {
      final m = json.decode(raw) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> savePhotoMap(Map<String, String> map) async {
    await _prefs.setString(_kPhotos, json.encode(map));
  }

  // —— 家长 PIN（明文存本地，仅为防孩子误入；非安全场景）——
  String? get parentPin => _prefs.getString(_kPin);
  bool get hasPin => parentPin != null && parentPin!.isNotEmpty;
  Future<void> setPin(String pin) async => _prefs.setString(_kPin, pin);

  // —— 设置 ——
  bool get soundOn => _prefs.getBool(_kSound) ?? true;
  Future<void> setSoundOn(bool v) async => _prefs.setBool(_kSound, v);

  bool get firstRunDone => _prefs.getBool(_kFirstRun) ?? false;
  Future<void> markFirstRunDone() async => _prefs.setBool(_kFirstRun, true);
}
