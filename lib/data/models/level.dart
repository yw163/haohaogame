import 'question.dart';

/// 五大学科。古诗词较难，排在最后。
enum Subject { math, space, physics, fun, poetry }

extension SubjectInfo on Subject {
  String get id => switch (this) {
        Subject.math => 'math',
        Subject.space => 'space',
        Subject.physics => 'physics',
        Subject.fun => 'fun',
        Subject.poetry => 'poetry',
      };

  /// 学科中文名
  String get title => switch (this) {
        Subject.math => '数学星球',
        Subject.space => '宇宙星球',
        Subject.physics => '物理乐园',
        Subject.fun => '趣味乐园',
        Subject.poetry => '古诗词阁',
      };

  String get shortTitle => switch (this) {
        Subject.math => '数学',
        Subject.space => '宇宙',
        Subject.physics => '物理',
        Subject.fun => '趣味',
        Subject.poetry => '古诗词',
      };

  /// 学科图标
  String get emoji => switch (this) {
        Subject.math => '🔢',
        Subject.space => '🪐',
        Subject.physics => '🧲',
        Subject.fun => '🎈',
        Subject.poetry => '📜',
      };

  /// 卡片描述
  String get description => switch (this) {
        Subject.math => '加减乘除、图形时间',
        Subject.space => '太阳系与星辰大海',
        Subject.physics => '生活里的科学道理',
        Subject.fun => '动脑筋的趣味知识',
        Subject.poetry => '小学必背古诗词（较难）',
      };
}

Subject subjectFromString(String s) {
  return Subject.values.firstWhere(
    (e) => e.id == s,
    orElse: () => Subject.math,
  );
}

/// 一个关卡：属于某学科，含若干题目，全部答完即过关。
class Level {
  final String id;
  final Subject subject;
  final int indexInSubject; // 学科内序号（1 起）
  final int globalIndex; // 全局序号（1 起，用于照片分配）
  final String title;
  final String emoji;
  final bool isBoss;
  final List<Question> questions;

  const Level({
    required this.id,
    required this.subject,
    required this.indexInSubject,
    required this.globalIndex,
    required this.title,
    required this.emoji,
    required this.isBoss,
    required this.questions,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String,
      subject: subjectFromString(json['subject'] as String),
      indexInSubject: json['indexInSubject'] as int,
      globalIndex: json['globalIndex'] as int,
      title: json['title'] as String,
      emoji: (json['emoji'] as String?) ?? '⭐',
      isBoss: (json['isBoss'] as bool?) ?? false,
      questions: ((json['questions'] as List?) ?? [])
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
