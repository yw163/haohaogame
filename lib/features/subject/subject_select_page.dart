import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/models/level.dart';
import '../../state/providers.dart';

/// 学科卡片选择页：5 张大卡片，点进去看该学科的关卡地图。
class SubjectSelectPage extends ConsumerWidget {
  const SubjectSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bySubject = ref.watch(levelsBySubjectProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择学科', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded, size: 30),
          onPressed: () => context.go('/'),
        ),
      ),
      body: bySubject.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (map) {
          return GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(20),
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            childAspectRatio: 1.05,
            children: Subject.values.map((s) {
              final levels = map[s] ?? [];
              final cleared =
                  levels.where((l) => progress.isLevelCleared(l.id)).length;
              return _SubjectCard(
                subject: s,
                total: levels.length,
                cleared: cleared,
                onTap: () => context.push('/map/${s.id}'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final int total;
  final int cleared;
  final VoidCallback onTap;
  const _SubjectCard({
    required this.subject,
    required this.total,
    required this.cleared,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primaryFor(subject);
    final done = total > 0 && cleared >= total;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.lightFor(subject), Colors.white],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(subject.emoji, style: const TextStyle(fontSize: 56)),
                if (done)
                  const Positioned(
                    right: 0, top: 0,
                    child: Text('🏆', style: TextStyle(fontSize: 24)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subject.title,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              subject.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '$cleared / $total 关',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
