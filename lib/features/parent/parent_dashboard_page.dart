import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/models/level.dart';
import '../../data/models/skill.dart';
import '../../state/providers.dart';

/// 家长后台：照片管理（核心）+ 设置。
class ParentDashboardPage extends ConsumerWidget {
  const ParentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final photoMap = ref.watch(photoMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('家长后台'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded, size: 30),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppColors.spaceLight.withOpacity(0.5),
            child: const Text(
              '给每个技能上传一张皓皓的搞笑照片吧！孩子闯关解锁技能时就会看到自己的照片 📸',
              style: TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: kAllSkills.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final skill = kAllSkills[i];
                return _SkillPhotoRow(
                  skill: skill,
                  photoPath: photoMap[skill.id],
                  unlocked: progress.isSkillUnlocked(skill.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageProvider);
    showDialog(
      context: context,
      builder: (ctx) {
        bool soundOn = storage.soundOn;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('设置'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('语音 / 音效'),
                  value: soundOn,
                  onChanged: (v) async {
                    await storage.setSoundOn(v);
                    ref.read(ttsProvider).enabled = v;
                    setState(() => soundOn = v);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt, color: AppColors.wrong),
                  title: const Text('重置游戏进度'),
                  subtitle: const Text('清空所有通关记录（照片保留）'),
                  onTap: () => _confirmReset(ctx, ref),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('关闭'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认重置进度？'),
        content: const Text('所有关卡和技能将回到未解锁状态，此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(progressProvider.notifier).reset();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('确认重置',
                style: TextStyle(color: AppColors.wrong)),
          ),
        ],
      ),
    );
  }
}

class _SkillPhotoRow extends ConsumerStatefulWidget {
  final Skill skill;
  final String? photoPath;
  final bool unlocked;
  const _SkillPhotoRow({
    required this.skill,
    required this.photoPath,
    required this.unlocked,
  });

  @override
  ConsumerState<_SkillPhotoRow> createState() => _SkillPhotoRowState();
}

class _SkillPhotoRowState extends ConsumerState<_SkillPhotoRow> {
  bool _busy = false;

  Future<void> _pick() async {
    setState(() => _busy = true);
    try {
      final path = await ref
          .read(photoServiceProvider)
          .pickAndSaveForSkill(widget.skill.id);
      if (path != null) {
        await ref
            .read(photoMapProvider.notifier)
            .setPhoto(widget.skill.id, path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    await ref.read(photoServiceProvider).deleteForSkill(widget.skill.id);
    await ref.read(photoMapProvider.notifier).removePhoto(widget.skill.id);
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primaryFor(widget.skill.theme);
    final path = widget.photoPath;
    final hasPhoto = path != null && File(path).existsSync();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 缩略图
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? Image.file(File(path), fit: BoxFit.cover)
                : Center(
                    child: Text(widget.skill.badgeEmoji,
                        style: const TextStyle(fontSize: 30)),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${widget.skill.order}. ${widget.skill.title}',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      widget.unlocked ? Icons.lock_open : Icons.lock_outline,
                      size: 16,
                      color: widget.unlocked ? AppColors.correct : Colors.black26,
                    ),
                  ],
                ),
                Text(
                  widget.skill.theme == LevelTheme.math ? '数学' : '宇宙',
                  style: const TextStyle(fontSize: 13, color: Colors.black45),
                ),
              ],
            ),
          ),
          if (_busy)
            const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            TextButton.icon(
              onPressed: _pick,
              icon: Icon(hasPhoto ? Icons.swap_horiz : Icons.add_a_photo,
                  size: 20),
              label: Text(hasPhoto ? '更换' : '上传'),
            ),
            if (hasPhoto)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.wrong),
                onPressed: _remove,
              ),
          ],
        ],
      ),
    );
  }
}
