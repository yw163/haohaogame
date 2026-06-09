import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/models/level.dart';
import '../../data/models/question.dart';
import '../../state/providers.dart';
import '../skill/skill_unlock_page.dart';
import 'widgets/answer_grid.dart';
import 'widgets/number_pad.dart';

class LevelPlayPage extends ConsumerStatefulWidget {
  final String levelId;
  const LevelPlayPage({super.key, required this.levelId});

  @override
  ConsumerState<LevelPlayPage> createState() => _LevelPlayPageState();
}

class _LevelPlayPageState extends ConsumerState<LevelPlayPage> {
  Level? _level;
  int _qIndex = 0;
  int _wrongCount = 0;
  bool _answered = false;
  bool _introSpoken = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final levels = await ref.read(levelsProvider.future);
    setState(() => _level = levels.firstWhere((l) => l.id == widget.levelId));
    _speak();
  }

  Question get _q => _level!.questions[_qIndex];

  void _speak() {
    final tts = ref.read(ttsProvider);
    final q = _q;
    if (q.scienceIntro != null && !_introSpoken) {
      _introSpoken = true;
      tts.speak('${q.scienceIntro!} ${q.ttsText}');
    } else {
      tts.speak(q.ttsText);
    }
  }

  void _onCorrect() {
    if (_answered) return;
    _answered = true;
    HapticFeedback.mediumImpact();
    ref.read(ttsProvider).speak('答对啦！');
    Future.delayed(const Duration(milliseconds: 650), _next);
  }

  void _onWrong() {
    setState(() => _wrongCount++);
    HapticFeedback.heavyImpact();
    ref.read(ttsProvider).speak('再想想，你一定可以的！');
  }

  void _next() {
    if (_qIndex + 1 < _level!.questions.length) {
      setState(() {
        _qIndex++;
        _answered = false;
        _introSpoken = false;
      });
      _speak();
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final stars = _wrongCount == 0 ? 3 : (_wrongCount <= 2 ? 2 : 1);
    await ref
        .read(progressProvider.notifier)
        .completeLevel(levelId: _level!.id, stars: stars);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SkillUnlockPage(level: _level!, stars: stars),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_level == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final color = AppColors.primaryFor(_level!.subject);
    final q = _q;
    final total = _level!.questions.length;

    return Scaffold(
      backgroundColor: AppColors.lightFor(_level!.subject).withOpacity(0.4),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              color: color,
              title: _level!.title,
              current: _qIndex + 1,
              total: total,
              onExit: () => context.go('/map/${_level!.subject.id}'),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _QuestionPanel(
                          question: q, color: color, onReplay: _speak),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 6,
                      child: _AnswerArea(
                        key: ValueKey(q.id),
                        question: q,
                        color: color,
                        onCorrect: _onCorrect,
                        onWrong: _onWrong,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final Color color;
  final String title;
  final int current;
  final int total;
  final VoidCallback onExit;
  const _TopBar({
    required this.color,
    required this.title,
    required this.current,
    required this.total,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.close_rounded, size: 30),
              onPressed: onExit),
          Text(title,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const Spacer(),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: current / total,
                minHeight: 14,
                backgroundColor: Colors.white,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('$current / $total',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  final Question question;
  final Color color;
  final VoidCallback onReplay;
  const _QuestionPanel(
      {required this.question, required this.color, required this.onReplay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (question.scienceIntro != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('💡 ${question.scienceIntro!}',
                  style: const TextStyle(fontSize: 16, height: 1.4)),
            ),
          if (question.emoji.isNotEmpty) ...[
            FittedBox(
                child:
                    Text(question.emoji, style: const TextStyle(fontSize: 52))),
            const SizedBox(height: 12),
          ],
          Text(
            question.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onReplay,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded, color: color, size: 26),
                  const SizedBox(width: 6),
                  Text('再读一遍',
                      style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerArea extends StatelessWidget {
  final Question question;
  final Color color;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;
  const _AnswerArea({
    super.key,
    required this.question,
    required this.color,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuestionType.numberInput:
        return NumberPad(
          correct: question.correctIds.first,
          color: color,
          onCorrect: onCorrect,
          onWrong: onWrong,
        );
      case QuestionType.singleChoice:
      case QuestionType.multiChoice:
      case QuestionType.ordering:
        return AnswerGrid(
          question: question,
          color: color,
          onCorrect: onCorrect,
          onWrong: onWrong,
        );
    }
  }
}
