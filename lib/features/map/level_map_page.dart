import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/models/game_progress.dart';
import '../../data/models/level.dart';
import '../../shared/widgets.dart';
import '../../state/providers.dart';

/// 单个学科的关卡地图（20 关）。
class LevelMapPage extends ConsumerWidget {
  final String subjectId;
  const LevelMapPage({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = subjectFromString(subjectId);
    final bySubject = ref.watch(levelsBySubjectProvider);
    final progress = ref.watch(progressProvider);
    final color = AppColors.primaryFor(subject);

    return Scaffold(
      backgroundColor: AppColors.lightFor(subject).withOpacity(0.35),
      appBar: AppBar(
        title: Text('${subject.emoji} ${subject.title}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 30),
          onPressed: () => context.go('/subjects'),
        ),
      ),
      body: bySubject.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (map) {
          final levels = map[subject] ?? [];
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: levels.length,
            itemBuilder: (context, i) {
              final level = levels[i];
              final unlocked =
                  isLevelUnlocked(levels, progress, level.indexInSubject);
              final cleared = progress.isLevelCleared(level.id);
              final stars = progress.starsFor(level.id);
              return _LevelNode(
                level: level,
                color: color,
                unlocked: unlocked,
                cleared: cleared,
                stars: stars,
              );
            },
          );
        },
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final Level level;
  final Color color;
  final bool unlocked;
  final bool cleared;
  final int stars;
  const _LevelNode({
    required this.level,
    required this.color,
    required this.unlocked,
    required this.cleared,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unlocked
          ? () => context.push('/play/${level.id}')
          : () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('先通过前一关才能解锁哦 🔒'),
                  duration: Duration(seconds: 1),
                ),
              ),
      child: Opacity(
        opacity: unlocked ? 1 : 0.45,
        child: Container(
          decoration: BoxDecoration(
            color: unlocked ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cleared ? AppColors.star : color.withOpacity(0.5),
              width: cleared ? 3 : 2,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(unlocked ? level.emoji : '🔒',
                  style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 2),
              Text(
                '第${level.indexInSubject}关',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 2),
              if (cleared) StarRow(stars: stars, size: 12)
              else const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
