import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yuhao_game/data/models/game_progress.dart';
import 'package:yuhao_game/data/models/level.dart';
import 'package:yuhao_game/data/models/question.dart';
import 'package:yuhao_game/data/photo_assigner.dart';

void main() {
  group('GameProgress', () {
    test('记录通关、统计星数、JSON 往返', () {
      var p = const GameProgress();
      expect(p.clearedCount, 0);
      p = p.copyWith(levelStars: {'math_L01': 3, 'space_L01': 2});
      expect(p.clearedCount, 2);
      expect(p.totalStars, 5);
      expect(p.isLevelCleared('math_L01'), true);
      final r = GameProgress.fromJson(json.decode(json.encode(p.toJson())));
      expect(r.levelStars, p.levelStars);
    });
  });

  group('PhotoAssigner', () {
    const a = PhotoAssigner(72);
    test('前 72 关顺序单图', () {
      expect(a.planFor(1).indices, [0]);
      expect(a.planFor(72).indices, [71]);
      expect(a.planFor(1).funnyDouble, false);
    });
    test('72 关后下标始终合法且确定性一致', () {
      for (var g = 73; g <= 100; g++) {
        final plan = a.planFor(g);
        expect(plan.indices.isNotEmpty, true);
        for (final i in plan.indices) {
          expect(i >= 0 && i < 72, true);
        }
        expect(a.planFor(g).indices, plan.indices); // 同输入同输出
      }
    });
    test('存在双图滑稽展示的关卡', () {
      final doubles =
          List.generate(100, (i) => a.planFor(i + 1)).where((p) => p.funnyDouble);
      expect(doubles.isNotEmpty, true);
    });
    test('照片数为 0 时不崩', () {
      expect(const PhotoAssigner(0).planFor(5).indices, isEmpty);
    });
  });

  group('题库 levels.json', () {
    late List<Level> levels;
    setUpAll(() {
      final raw = File('assets/data/levels.json').readAsStringSync();
      levels = (json.decode(raw) as List)
          .map((e) => Level.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.globalIndex.compareTo(b.globalIndex));
    });

    test('100 关，500 题，globalIndex 连续', () {
      expect(levels.length, 100);
      expect(levels.fold<int>(0, (s, l) => s + l.questions.length), 500);
      for (var i = 0; i < levels.length; i++) {
        expect(levels[i].globalIndex, i + 1);
      }
    });

    test('五学科各 20 关', () {
      for (final s in Subject.values) {
        expect(levels.where((l) => l.subject == s).length, 20);
      }
    });

    test('古诗词排在最后', () {
      expect(levels.last.subject, Subject.poetry);
    });

    test('每题答案都指向真实选项', () {
      for (final l in levels) {
        for (final q in l.questions) {
          if (q.type == QuestionType.numberInput) {
            expect(int.tryParse(q.correctIds.first) != null, true);
            continue;
          }
          final ids = q.options.map((o) => o.id).toSet();
          for (final c in q.correctIds) {
            expect(ids.contains(c), true,
                reason: '题 ${q.id} 答案 $c 不在选项');
          }
        }
      }
    });
  });
}
