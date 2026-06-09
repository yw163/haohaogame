import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../state/providers.dart';

/// 家长后台：进度概览 + 设置（音效、重置进度）。
/// 照片已改为系统自动填充展示，无需家长手动上传。
class ParentDashboardPage extends ConsumerWidget {
  const ParentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final storage = ref.read(storageProvider);
    final photoCount = ref.watch(photoCountProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('家长后台'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded, size: 30),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📊 学习进度',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('已通关：${progress.clearedCount} / 100 关',
                    style: const TextStyle(fontSize: 17)),
                Text('累计获得：⭐ x ${progress.totalStars}',
                    style: const TextStyle(fontSize: 17)),
                Text('题库总量：500 题（5 学科 × 100 题）',
                    style: const TextStyle(fontSize: 15, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📸 照片展示',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  '已内置 $photoCount 张皓皓照片，闯关成功会自动展示。'
                  '前 $photoCount 关按顺序，之后随机搭配，部分关卡双图滑稽展示 😝',
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              children: [
                _SoundSwitch(storage: storage),
                const Divider(),
                ListTile(
                  leading:
                      const Icon(Icons.restart_alt, color: AppColors.wrong),
                  title: const Text('重置游戏进度'),
                  subtitle: const Text('清空所有通关记录'),
                  onTap: () => _confirmReset(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认重置进度？'),
        content: const Text('所有关卡将回到未解锁状态，此操作不可撤销。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          TextButton(
            onPressed: () async {
              await ref.read(progressProvider.notifier).reset();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child:
                const Text('确认重置', style: TextStyle(color: AppColors.wrong)),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: child,
      );
}

class _SoundSwitch extends ConsumerStatefulWidget {
  final dynamic storage;
  const _SoundSwitch({required this.storage});
  @override
  ConsumerState<_SoundSwitch> createState() => _SoundSwitchState();
}

class _SoundSwitchState extends ConsumerState<_SoundSwitch> {
  late bool _on = widget.storage.soundOn;
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('语音 / 音效'),
      secondary: const Icon(Icons.volume_up),
      value: _on,
      onChanged: (v) async {
        await widget.storage.setSoundOn(v);
        ref.read(ttsProvider).enabled = v;
        setState(() => _on = v);
      },
    );
  }
}
