import 'level.dart';

/// 技能（成就徽章）。每过一关解锁一个。
/// 解锁后展示家长上传的「皓皓搞笑照片」；没传则用默认 emoji 占位。
class Skill {
  final String id;
  final LevelTheme theme;
  final String title; // 技能名，如「加法小超人」
  final String subtitle; // 副标题/夸奖语
  final String badgeEmoji; // 徽章图标
  final int order; // 展示顺序（与关卡序对应）

  const Skill({
    required this.id,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.badgeEmoji,
    required this.order,
  });
}

/// 内置技能定义表（24 个，与 24 关一一对应）。
/// 命名孩子化、有荣誉感，部分嵌入「皓皓」增强代入感。
const List<Skill> kAllSkills = [
  // —— 数学 12 个（二年级难度）——
  Skill(id: 's01', theme: LevelTheme.math, title: '加法小超人', subtitle: '两位数相加难不倒我', badgeEmoji: '➕', order: 1),
  Skill(id: 's02', theme: LevelTheme.math, title: '减法小魔术师', subtitle: '两位数相减真轻松', badgeEmoji: '➖', order: 2),
  Skill(id: 's03', theme: LevelTheme.math, title: '进位高手', subtitle: '满十进一全搞定', badgeEmoji: '🔼', order: 3),
  Skill(id: 's04', theme: LevelTheme.math, title: '退位高手', subtitle: '借一当十不出错', badgeEmoji: '🔽', order: 4),
  Skill(id: 's05', theme: LevelTheme.math, title: '乘法口诀王', subtitle: '九九口诀倒背如流', badgeEmoji: '✖️', order: 5),
  Skill(id: 's06', theme: LevelTheme.math, title: '平分大师', subtitle: '除法平分样样行', badgeEmoji: '➗', order: 6),
  Skill(id: 's07', theme: LevelTheme.math, title: '形状侦探', subtitle: '图形和角都认得', badgeEmoji: '🔷', order: 7),
  Skill(id: 's08', theme: LevelTheme.math, title: '测量小能手', subtitle: '米和厘米分得清', badgeEmoji: '📏', order: 8),
  Skill(id: 's09', theme: LevelTheme.math, title: '时间小达人', subtitle: '时分钟表全看懂', badgeEmoji: '🕐', order: 9),
  Skill(id: 's10', theme: LevelTheme.math, title: '解题王', subtitle: '应用题难不倒皓皓', badgeEmoji: '🧠', order: 10),
  Skill(id: 's11', theme: LevelTheme.math, title: '规律破解王', subtitle: '下一个数我知道', badgeEmoji: '🔁', order: 11),
  Skill(id: 's12', theme: LevelTheme.math, title: '数学小博士', subtitle: '皓皓数学全通关！', badgeEmoji: '🎓', order: 12),
  // —— 宇宙 12 个 ——
  Skill(id: 's13', theme: LevelTheme.space, title: '太阳系向导', subtitle: '八大行星我熟', badgeEmoji: '🪐', order: 13),
  Skill(id: 's14', theme: LevelTheme.space, title: '恒星观察员', subtitle: '太阳是颗大恒星', badgeEmoji: '☀️', order: 14),
  Skill(id: 's15', theme: LevelTheme.space, title: '月亮研究员', subtitle: '月亮圆缺我懂', badgeEmoji: '🌙', order: 15),
  Skill(id: 's16', theme: LevelTheme.space, title: '行星排序官', subtitle: '远近排得明白', badgeEmoji: '📏', order: 16),
  Skill(id: 's17', theme: LevelTheme.space, title: '巨人行星猎手', subtitle: '找到了最大的木星', badgeEmoji: '🟠', order: 17),
  Skill(id: 's18', theme: LevelTheme.space, title: '光环鉴赏家', subtitle: '土星的光环真美', badgeEmoji: '💍', order: 18),
  Skill(id: 's19', theme: LevelTheme.space, title: '见习宇航员', subtitle: '会穿宇航服啦', badgeEmoji: '👨‍🚀', order: 19),
  Skill(id: 's20', theme: LevelTheme.space, title: '星座连线师', subtitle: '北斗七星连得上', badgeEmoji: '✨', order: 20),
  Skill(id: 's21', theme: LevelTheme.space, title: '昼夜守护者', subtitle: '白天黑夜怎么来', badgeEmoji: '🌗', order: 21),
  Skill(id: 's22', theme: LevelTheme.space, title: '四季魔法师', subtitle: '春夏秋冬的秘密', badgeEmoji: '🍂', order: 22),
  Skill(id: 's23', theme: LevelTheme.space, title: '太空探险家', subtitle: '宇宙趣事知道多', badgeEmoji: '🛰️', order: 23),
  Skill(id: 's24', theme: LevelTheme.space, title: '宇宙小院士', subtitle: '皓皓宇宙百科毕业！', badgeEmoji: '🏆', order: 24),
];

Skill skillById(String id) =>
    kAllSkills.firstWhere((s) => s.id == id, orElse: () => kAllSkills.first);
