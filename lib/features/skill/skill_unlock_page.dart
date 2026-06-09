import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/models/level.dart';
import '../../data/photo_assigner.dart';
import '../../shared/widgets.dart';
import '../../state/providers.dart';

/// 过关庆祝页：撒花 + 星星 + 自动分配的皓皓照片（单图或双图滑稽展示）。
class SkillUnlockPage extends ConsumerStatefulWidget {
  final Level level;
  final int stars;
  const SkillUnlockPage({super.key, required this.level, required this.stars});

  @override
  ConsumerState<SkillUnlockPage> createState() => _SkillUnlockPageState();
}

class _SkillUnlockPageState extends ConsumerState<SkillUnlockPage> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confetti.play();
      ref.read(ttsProvider).speak(
            '太棒啦！皓皓通过了${widget.level.title}！真厉害！',
          );
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primaryFor(widget.level.subject);
    final assigner = ref.watch(photoAssignerProvider);
    final plan = assigner.planFor(widget.level.globalIndex);

    return Scaffold(
      backgroundColor: AppColors.lightFor(widget.level.subject).withOpacity(0.55),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 26,
              gravity: 0.25,
              colors: const [
                AppColors.star,
                Color(0xFFFF8A3D),
                Color(0xFF5B6CE0),
                AppColors.correct,
                Color(0xFFEF5DA8),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉 闯关成功 🎉',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  StarRow(stars: widget.stars, size: 38),
                  const SizedBox(height: 14),
                  _PhotoShow(plan: plan, assigner: assigner, color: color),
                  const SizedBox(height: 10),
                  Text(
                    plan.funnyDouble ? '皓皓的双倍搞笑时刻！😝' : '皓皓真棒！📸',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BigButton(
                        label: '继续闯关',
                        emoji: '➡️',
                        color: color,
                        onTap: () =>
                            context.go('/map/${widget.level.subject.id}'),
                      ),
                      const SizedBox(width: 16),
                      BigButton(
                        label: '选学科',
                        emoji: '🗂️',
                        color: AppColors.star,
                        fontSize: 22,
                        onTap: () => context.go('/subjects'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 照片展示：1 张正放，2 张则一左一右、各带歪斜角度，做滑稽并排。
class _PhotoShow extends StatelessWidget {
  final PhotoPlan plan;
  final PhotoAssigner assigner;
  final Color color;
  const _PhotoShow(
      {required this.plan, required this.assigner, required this.color});

  @override
  Widget build(BuildContext context) {
    if (plan.indices.isEmpty) {
      return Text('🏅', style: TextStyle(fontSize: 100, color: color));
    }
    if (plan.indices.length == 1) {
      return _Polaroid(
        path: assigner.assetPath(plan.indices.first),
        angle: -0.04,
        size: 200,
      );
    }
    // 双图滑稽
    return SizedBox(
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-70, 6),
            child: _Polaroid(
                path: assigner.assetPath(plan.indices[0]),
                angle: -0.12,
                size: 160),
          ),
          Transform.translate(
            offset: const Offset(70, -6),
            child: _Polaroid(
                path: assigner.assetPath(plan.indices[1]),
                angle: 0.12,
                size: 160),
          ),
        ],
      ),
    );
  }
}

class _Polaroid extends StatelessWidget {
  final String path; // asset 路径
  final double angle;
  final double size;
  const _Polaroid(
      {required this.path, required this.angle, required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: size,
                height: size,
                child: Image.asset(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF1F1F1),
                    alignment: Alignment.center,
                    child: const Text('📷', style: TextStyle(fontSize: 60)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text('皓皓',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
