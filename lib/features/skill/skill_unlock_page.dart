import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/models/level.dart';
import '../../data/models/skill.dart';
import '../../shared/widgets.dart';
import '../../state/providers.dart';

/// 过关后的技能解锁庆祝页：撒花 + 徽章 + 皓皓的搞笑照片。
class SkillUnlockPage extends ConsumerStatefulWidget {
  final String skillId;
  final int stars;
  final LevelTheme theme;

  const SkillUnlockPage({
    super.key,
    required this.skillId,
    required this.stars,
    required this.theme,
  });

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
      final skill = skillById(widget.skillId);
      ref.read(ttsProvider).speak(
            '太棒啦！皓皓解锁了新技能：${skill.title}！${skill.subtitle}',
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
    final skill = skillById(widget.skillId);
    final photoPath = ref.watch(photoMapProvider)[widget.skillId];
    final color = AppColors.primaryFor(widget.theme);

    return Scaffold(
      backgroundColor: AppColors.lightFor(widget.theme).withOpacity(0.55),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 24,
              gravity: 0.25,
              colors: const [
                AppColors.star,
                AppColors.mathPrimary,
                AppColors.spacePrimary,
                AppColors.correct,
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
                      style: TextStyle(
                          fontSize: 34, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  StarRow(stars: widget.stars, size: 40),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 照片（拍立得风格）
                      _Polaroid(photoPath: photoPath, fallbackEmoji: skill.badgeEmoji),
                      const SizedBox(width: 24),
                      // 技能卡
                      _SkillCard(skill: skill, color: color),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BigButton(
                        label: '继续闯关',
                        emoji: '➡️',
                        color: color,
                        onTap: () => context.go('/map'),
                      ),
                      const SizedBox(width: 16),
                      BigButton(
                        label: '技能墙',
                        emoji: '🏅',
                        color: AppColors.star,
                        fontSize: 24,
                        onTap: () => context.go('/skills'),
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

class _Polaroid extends StatelessWidget {
  final String? photoPath;
  final String fallbackEmoji;
  const _Polaroid({required this.photoPath, required this.fallbackEmoji});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();
    return Transform.rotate(
      angle: -0.05,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 180,
                height: 180,
                child: hasPhoto
                    ? Image.file(File(photoPath!), fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFFF1F1F1),
                        alignment: Alignment.center,
                        child: Text(fallbackEmoji,
                            style: const TextStyle(fontSize: 90)),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            const Text('皓皓',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final Skill skill;
  final Color color;
  const _SkillCard({required this.skill, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 3),
      ),
      child: Column(
        children: [
          const Text('解锁新技能',
              style: TextStyle(fontSize: 16, color: Colors.black45)),
          const SizedBox(height: 8),
          Text(skill.badgeEmoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 8),
          Text(
            skill.title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            skill.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
