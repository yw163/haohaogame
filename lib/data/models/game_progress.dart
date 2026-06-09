/// 游戏进度。纯本地，存于 SharedPreferences（JSON 序列化）。
/// 现在以「关卡」为单位：通关即记录星数，照片由系统自动分配展示。
class GameProgress {
  /// 关卡 id -> 获得的星数（1~3）。存在即表示已通关。
  final Map<String, int> levelStars;

  const GameProgress({this.levelStars = const {}});

  bool isLevelCleared(String levelId) => levelStars.containsKey(levelId);
  int starsFor(String levelId) => levelStars[levelId] ?? 0;

  int get totalStars => levelStars.values.fold(0, (s, v) => s + v);
  int get clearedCount => levelStars.length;

  GameProgress copyWith({Map<String, int>? levelStars}) =>
      GameProgress(levelStars: levelStars ?? this.levelStars);

  Map<String, dynamic> toJson() => {'levelStars': levelStars};

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    final raw = (json['levelStars'] as Map?) ?? {};
    return GameProgress(
      levelStars:
          raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
    );
  }
}
