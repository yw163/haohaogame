import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/game_progress.dart';
import '../data/models/level.dart';
import '../data/repositories/level_repository.dart';
import '../services/photo_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

/// —— 服务层（在 main 中通过 overrideWithValue 注入已初始化实例）——
final storageProvider = Provider<StorageService>(
  (ref) => throw UnimplementedError('storageProvider must be overridden'),
);

final ttsProvider = Provider<TtsService>((ref) {
  final tts = TtsService();
  tts.enabled = ref.watch(storageProvider).soundOn;
  return tts;
});

final photoServiceProvider = Provider<PhotoService>((ref) => PhotoService());

final levelRepositoryProvider =
    Provider<LevelRepository>((ref) => LevelRepository());

/// 全部关卡（异步加载 JSON 题库）。
final levelsProvider = FutureProvider<List<Level>>((ref) async {
  return ref.watch(levelRepositoryProvider).loadLevels();
});

/// —— 进度状态 ——
class ProgressNotifier extends StateNotifier<GameProgress> {
  final StorageService _storage;
  ProgressNotifier(this._storage) : super(_storage.loadProgress());

  /// 完成一关：记录星数（取历史最高）并解锁技能。
  Future<void> completeLevel({
    required String levelId,
    required String skillId,
    required int stars,
  }) async {
    final newStars = Map<String, int>.from(state.levelStars);
    final prev = newStars[levelId] ?? 0;
    if (stars > prev) newStars[levelId] = stars;
    if (!newStars.containsKey(levelId)) newStars[levelId] = stars;

    final newSkills = Set<String>.from(state.unlockedSkills)..add(skillId);
    state = state.copyWith(levelStars: newStars, unlockedSkills: newSkills);
    await _storage.saveProgress(state);
  }

  Future<void> reset() async {
    await _storage.resetProgress();
    state = const GameProgress();
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, GameProgress>((ref) {
  return ProgressNotifier(ref.watch(storageProvider));
});

/// —— 技能照片映射 ——
class PhotoMapNotifier extends StateNotifier<Map<String, String>> {
  final StorageService _storage;
  PhotoMapNotifier(this._storage) : super(_storage.loadPhotoMap());

  String? pathFor(String skillId) => state[skillId];

  Future<void> setPhoto(String skillId, String path) async {
    final m = Map<String, String>.from(state)..[skillId] = path;
    state = m;
    await _storage.savePhotoMap(m);
  }

  Future<void> removePhoto(String skillId) async {
    final m = Map<String, String>.from(state)..remove(skillId);
    state = m;
    await _storage.savePhotoMap(m);
  }
}

final photoMapProvider =
    StateNotifierProvider<PhotoMapNotifier, Map<String, String>>((ref) {
  return PhotoMapNotifier(ref.watch(storageProvider));
});

/// 一个关卡是否已解锁：第 1 关恒开，其余需前一关已通关。
bool isLevelUnlocked(List<Level> levels, GameProgress progress, int index) {
  if (index <= 1) return true;
  final prev = levels.firstWhere(
    (l) => l.index == index - 1,
    orElse: () => levels.first,
  );
  return progress.isLevelCleared(prev.id);
}
