import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../../state/providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3E0), Color(0xFFE8ECFF)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 装饰星球
              const Positioned(top: 20, right: 40, child: Text('🪐', style: TextStyle(fontSize: 60))),
              const Positioned(bottom: 30, left: 30, child: Text('🚀', style: TextStyle(fontSize: 54))),
              const Positioned(top: 90, left: 60, child: Text('⭐', style: TextStyle(fontSize: 34))),

              // 家长入口（右上角小齿轮）
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  iconSize: 34,
                  icon: const Icon(Icons.settings, color: Colors.black38),
                  onPressed: () => context.push('/parent-gate'),
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 72)),
                    const SizedBox(height: 8),
                    const Text(
                      '皓皓闯关',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '数学 · 宇宙 大冒险',
                      style: TextStyle(fontSize: 22, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    _ProgressChip(
                      cleared: progress.clearedCount,
                      stars: progress.totalStars,
                    ),
                    const SizedBox(height: 28),
                    BigButton(
                      label: '开始闯关',
                      emoji: '🎮',
                      color: AppColors.mathPrimary,
                      fontSize: 30,
                      onTap: () => context.push('/map'),
                    ),
                    const SizedBox(height: 16),
                    BigButton(
                      label: '我的技能墙',
                      emoji: '🏅',
                      color: AppColors.spacePrimary,
                      fontSize: 26,
                      onTap: () => context.push('/skills'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  final int cleared;
  final int stars;
  const _ProgressChip({required this.cleared, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '已通关 $cleared / 24    ⭐ x $stars',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
