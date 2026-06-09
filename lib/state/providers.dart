import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/game_progress.dart';
import '../data/models/level.dart';
import '../data/photo_assigner.dart';
import '../data/repositories/level_repository.dart';
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

final levelRepositoryProvider =
    Provider<LevelRepository>((ref) => LevelRepository());

/// 全部关卡。
final levelsProvider = FutureProvider<List<Level>>((ref) async {
  return ref.watch(levelRepositoryProvider).loadLevels();
});

/// 按学科分组的关卡。
final levelsBySubjectProvider =
    FutureProvider<Map<Subject, List<Level>>>((ref) async {
  return ref.watch(levelRepositoryProvider).loadBySubject();
});

/// 照片总数 + 分配器。
final photoCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(levelRepositoryProvider).loadPhotoCount();
});

final photoAssignerProvider = Provider<PhotoAssigner>((ref) {
  final count = ref.watch(photoCountProvider).valueOrNull ?? 0;
  return PhotoAssigner(count);
});

/// —— 进度状态 ——
class ProgressNotifier extends StateNotifier<GameProgress> {
  final StorageService _storage;
  ProgressNotifier(this._storage) : super(_storage.loadProgress());

  Future<void> completeLevel({
    required String levelId,
    required int stars,
  }) async {
    final newStars = Map<String, int>.from(state.levelStars);
    final prev = newStars[levelId] ?? 0;
    if (stars > prev || !newStars.containsKey(levelId)) {
      newStars[levelId] = stars > prev ? stars : prev;
    }
    if (!newStars.containsKey(levelId)) newStars[levelId] = stars;
    state = state.copyWith(levelStars: newStars);
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

/// 某关卡是否解锁：每个学科的第 1 关恒开，其余需本学科前一关已通关。
bool isLevelUnlocked(
    List<Level> subjectLevels, GameProgress progress, int indexInSubject) {
  if (indexInSubject <= 1) return true;
  final prev = subjectLevels.firstWhere(
    (l) => l.indexInSubject == indexInSubject - 1,
    orElse: () => subjectLevels.first,
  );
  return progress.isLevelCleared(prev.id);
}
