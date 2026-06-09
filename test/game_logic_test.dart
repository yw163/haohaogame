import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yuhao_game/data/models/game_progress.dart';
import 'package:yuhao_game/data/models/level.dart';
import 'package:yuhao_game/data/models/question.dart';
import 'package:yuhao_game/data/models/skill.dart';

void main() {
  group('GameProgress', () {
    test('记录通关、解锁技能、统计星数', () {
      var p = const GameProgress();
      expect(p.clearedCount, 0);
      expect(p.isLevelCleared('L01'), false);

      p = p.copyWith(
        levelStars: {'L01': 3, 'L02': 2},
        unlockedSkills: {'s01', 's02'},
      );
      expect(p.clearedCount, 2);
      expect(p.totalStars, 5);
      expect(p.isLevelCleared('L01'), true);
      expect(p.isSkillUnlocked('s02'), true);
      expect(p.isSkillUnlocked('s03'), false);
    });

    test('JSON 往返一致', () {
      const p = GameProgress(
        levelStars: {'L01': 3, 'L13': 1},
        unlockedSkills: {'s01', 's13'},
      );
      final restored =
          GameProgress.fromJson(json.decode(json.encode(p.toJson())));
      expect(restored.levelStars, p.levelStars);
      expect(restored.unlockedSkills, p.unlockedSkills);
    });
  });

  group('技能定义表', () {
    test('共 24 个技能，id 唯一', () {
      expect(kAllSkills.length, 24);
      final ids = kAllSkills.map((s) => s.id).toSet();
      expect(ids.length, 24);
    });

    test('数学/宇宙各 12 个', () {
      expect(kAllSkills.where((s) => s.theme == LevelTheme.math).length, 12);
      expect(kAllSkills.where((s) => s.theme == LevelTheme.space).length, 12);
    });
  });

  group('题库 levels.json', () {
    late List<Level> levels;

    setUpAll(() {
      final raw = File('assets/data/levels.json').readAsStringSync();
      final list = json.decode(raw) as List<dynamic>;
      levels = list
          .map((e) => Level.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.index.compareTo(b.index));
    });

    test('共 24 关，序号连续 1..24', () {
      expect(levels.length, 24);
      for (var i = 0; i < 24; i++) {
        expect(levels[i].index, i + 1);
      }
    });

    test('每关都引用了存在的技能', () {
      final skillIds = kAllSkills.map((s) => s.id).toSet();
      for (final l in levels) {
        expect(skillIds.contains(l.skillId), true,
            reason: '关卡 ${l.id} 的 skillId ${l.skillId} 不存在');
      }
    });

    test('选择/排序题的正确答案都指向真实选项', () {
      for (final l in levels) {
        for (final q in l.questions) {
          if (q.type == QuestionType.numberInput) {
            expect(q.correctIds.length, 1);
            expect(int.tryParse(q.correctIds.first) != null, true);
            continue;
          }
          final optIds = q.options.map((o) => o.id).toSet();
          for (final c in q.correctIds) {
            expect(optIds.contains(c), true,
                reason: '题目 ${q.id} 的正确答案 $c 不在选项中');
          }
          if (q.type == QuestionType.ordering) {
            expect(q.correctIds.length, q.options.length,
                reason: '排序题 ${q.id} 的答案数应等于选项数');
          }
        }
      }
    });
  });
}
