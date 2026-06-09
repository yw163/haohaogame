import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/models/game_progress.dart';
import '../../data/models/level.dart';
import '../../shared/widgets.dart';
import '../../state/providers.dart';

class LevelMapPage extends ConsumerWidget {
  const LevelMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(levelsProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('闯关地图', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded, size: 30),
          onPressed: () => context.go('/'),
        ),
      ),
      body: levelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('题库加载失败：$e')),
        data: (levels) {
          final math = levels.where((l) => l.theme == LevelTheme.math).toList();
          final space =
              levels.where((l) => l.theme == LevelTheme.space).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _ThemeHeader(
                emoji: '🔢',
                title: '数学星球',
                color: AppColors.mathPrimary,
              ),
              _LevelGrid(levels: math, all: levels, progress: progress),
              const SizedBox(height: 28),
              _ThemeHeader(
                emoji: '🪐',
                title: '宇宙星球',
                color: AppColors.spacePrimary,
              ),
              _LevelGrid(levels: space, all: levels, progress: progress),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  const _ThemeHeader({
    required this.emoji,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  final List<Level> levels;
  final List<Level> all;
  final GameProgress progress;
  const _LevelGrid({
    required this.levels,
    required this.all,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: levels.length,
      itemBuilder: (context, i) {
        final level = levels[i];
        final unlocked = isLevelUnlocked(all, progress, level.index);
        final cleared = progress.isLevelCleared(level.id);
        final stars = progress.starsFor(level.id);
        return _LevelNode(
          level: level,
          unlocked: unlocked,
          cleared: cleared,
          stars: stars,
        );
      },
    );
  }
}

class _LevelNode extends StatelessWidget {
  final Level level;
  final bool unlocked;
  final bool cleared;
  final int stars;
  const _LevelNode({
    required this.level,
    required this.unlocked,
    required this.cleared,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primaryFor(level.theme);
    return GestureDetector(
      onTap: unlocked
          ? () => context.push('/play/${level.id}')
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('先通过前一关才能解锁哦 🔒'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
      child: Opacity(
        opacity: unlocked ? 1 : 0.45,
        child: Container(
          decoration: BoxDecoration(
            color: unlocked ? AppColors.lightFor(level.theme) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cleared ? AppColors.star : color.withOpacity(0.5),
              width: cleared ? 3 : 2,
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    unlocked ? level.emoji : '🔒',
                    style: const TextStyle(fontSize: 34),
                  ),
                  if (level.isBoss && unlocked)
                    const Positioned(
                      top: -2,
                      right: -2,
                      child: Text('👑', style: TextStyle(fontSize: 18)),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${level.index}. ${level.title}',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              if (cleared)
                StarRow(stars: stars, size: 13)
              else
                const SizedBox(height: 13),
            ],
          ),
        ),
      ),
    );
  }
}
