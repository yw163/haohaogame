/// 题目类型。6岁孩子尽量少打字，以点选/多选/拖拽排序为主。
enum QuestionType {
  singleChoice, // 单选：点一个正确答案
  multiChoice, // 多选：选出所有符合的
  ordering, // 排序：按顺序点击（如行星离太阳远近）
  numberInput, // 数字键盘输入（仅少数高关使用）
}

QuestionType _questionTypeFromString(String s) {
  switch (s) {
    case 'multiChoice':
      return QuestionType.multiChoice;
    case 'ordering':
      return QuestionType.ordering;
    case 'numberInput':
      return QuestionType.numberInput;
    case 'singleChoice':
    default:
      return QuestionType.singleChoice;
  }
}

/// 一个选项：用 emoji 做图（无需图片资源），label 为文字。
class AnswerOption {
  final String id;
  final String emoji; // 大图标，可为空
  final String label; // 文字标签，可为空

  const AnswerOption({
    required this.id,
    this.emoji = '',
    this.label = '',
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      id: json['id'] as String,
      emoji: (json['emoji'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
    );
  }
}

/// 一道题。
class Question {
  final String id;
  final QuestionType type;
  final String prompt; // 题干文字
  final String ttsText; // 朗读文本（孩子识字不全，靠语音）
  final String emoji; // 题干配的大 emoji，可为空
  final String? scienceIntro; // 宇宙关：提问前的科普旁白（先朗读再问）
  final List<AnswerOption> options;

  /// 正确答案的 option id 列表。
  /// - singleChoice: 1 个
  /// - multiChoice: 多个（无序）
  /// - ordering: 按正确顺序排列
  /// - numberInput: 单元素，值为正确数字的字符串
  final List<String> correctIds;

  const Question({
    required this.id,
    required this.type,
    required this.prompt,
    required this.ttsText,
    required this.options,
    required this.correctIds,
    this.emoji = '',
    this.scienceIntro,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      type: _questionTypeFromString(json['type'] as String),
      prompt: json['prompt'] as String,
      ttsText: (json['ttsText'] as String?) ?? json['prompt'] as String,
      emoji: (json['emoji'] as String?) ?? '',
      scienceIntro: json['scienceIntro'] as String?,
      options: ((json['options'] as List?) ?? [])
          .map((e) => AnswerOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctIds: ((json['correctIds'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
