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
              const Positioned(top: 20, right: 40, child: Text('🪐', style: TextStyle(fontSize: 56))),
              const Positioned(bottom: 30, left: 30, child: Text('🚀', style: TextStyle(fontSize: 50))),
              const Positioned(top: 90, left: 60, child: Text('⭐', style: TextStyle(fontSize: 30))),
              const Positioned(bottom: 60, right: 80, child: Text('📜', style: TextStyle(fontSize: 40))),

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
                    const Text('🌟', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 6),
                    const Text(
                      '皓皓闯关',
                      style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink),
                    ),
                    const Text(
                      '数学 · 宇宙 · 物理 · 趣味 · 古诗词',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '已通关 ${progress.clearedCount} / 100    ⭐ x ${progress.totalStars}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 24),
                    BigButton(
                      label: '开始闯关',
                      emoji: '🎮',
                      color: const Color(0xFFFF8A3D),
                      fontSize: 30,
                      onTap: () => context.push('/subjects'),
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
