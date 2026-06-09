/// 游戏进度。纯本地，存于 SharedPreferences（JSON 序列化）。
class GameProgress {
  /// 每个关卡 id -> 获得的星数（1~3）。存在即表示已通关。
  final Map<String, int> levelStars;

  /// 已解锁的技能 id 集合。
  final Set<String> unlockedSkills;

  const GameProgress({
    this.levelStars = const {},
    this.unlockedSkills = const {},
  });

  bool isLevelCleared(String levelId) => levelStars.containsKey(levelId);

  int starsFor(String levelId) => levelStars[levelId] ?? 0;

  bool isSkillUnlocked(String skillId) => unlockedSkills.contains(skillId);

  int get totalStars =>
      levelStars.values.fold(0, (sum, s) => sum + s);

  int get clearedCount => levelStars.length;

  GameProgress copyWith({
    Map<String, int>? levelStars,
    Set<String>? unlockedSkills,
  }) {
    return GameProgress(
      levelStars: levelStars ?? this.levelStars,
      unlockedSkills: unlockedSkills ?? this.unlockedSkills,
    );
  }

  Map<String, dynamic> toJson() => {
        'levelStars': levelStars,
        'unlockedSkills': unlockedSkills.toList(),
      };

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    final starsRaw = (json['levelStars'] as Map?) ?? {};
    return GameProgress(
      levelStars: starsRaw.map(
        (k, v) => MapEntry(k.toString(), (v as num).toInt()),
      ),
      unlockedSkills: ((json['unlockedSkills'] as List?) ?? [])
          .map((e) => e.toString())
          .toSet(),
    );
  }
}
