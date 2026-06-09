import 'question.dart';

/// 主题分区：数学 / 宇宙。
enum LevelTheme { math, space }

LevelTheme levelThemeFromString(String s) =>
    s == 'space' ? LevelTheme.space : LevelTheme.math;

/// 一个关卡：包含若干题目，全部答完即过关。
class Level {
  final String id;
  final int index; // 在地图上的序号（1 起）
  final LevelTheme theme;
  final String title; // 关卡名，如「10以内加法」
  final String emoji; // 地图节点图标
  final bool isBoss; // BOSS 关（章节综合）
  final String skillId; // 过关解锁的技能 id
  final List<Question> questions;

  const Level({
    required this.id,
    required this.index,
    required this.theme,
    required this.title,
    required this.emoji,
    required this.isBoss,
    required this.skillId,
    required this.questions,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String,
      index: json['index'] as int,
      theme: levelThemeFromString(json['theme'] as String),
      title: json['title'] as String,
      emoji: (json['emoji'] as String?) ?? '⭐',
      isBoss: (json['isBoss'] as bool?) ?? false,
      skillId: json['skillId'] as String,
      questions: ((json['questions'] as List?) ?? [])
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
