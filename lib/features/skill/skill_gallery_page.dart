import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/models/level.dart';
import '../../data/models/skill.dart';
import '../../state/providers.dart';

/// 技能墙/成就册：网格展示 24 个技能，已解锁=彩色+照片，未解锁=灰色锁头。
class SkillGalleryPage extends ConsumerWidget {
  const SkillGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final photoMap = ref.watch(photoMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '皓皓的技能墙  (${progress.unlockedSkills.length}/24)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded, size: 30),
          onPressed: () => context.go('/'),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemCount: kAllSkills.length,
        itemBuilder: (context, i) {
          final skill = kAllSkills[i];
          final unlocked = progress.isSkillUnlocked(skill.id);
          final photoPath = photoMap[skill.id];
          return _SkillTile(
            skill: skill,
            unlocked: unlocked,
            photoPath: photoPath,
          );
        },
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  final Skill skill;
  final bool unlocked;
  final String? photoPath;
  const _SkillTile({
    required this.skill,
    required this.unlocked,
    required this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primaryFor(skill.theme);
    final hasPhoto =
        unlocked && photoPath != null && File(photoPath!).existsSync();

    return Container(
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked ? color : Colors.black12,
          width: 2.5,
        ),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox.expand(
                child: hasPhoto
                    ? Image.file(File(photoPath!), fit: BoxFit.cover)
                    : Container(
                        color: unlocked
                            ? color.withOpacity(0.12)
                            : Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: Text(
                          unlocked ? skill.badgeEmoji : '🔒',
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unlocked ? skill.title : '未解锁',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: unlocked ? color : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
