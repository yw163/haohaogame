import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/level.dart';

/// 从 assets/data/levels.json 加载全部关卡（500 题 / 100 关）。
class LevelRepository {
  List<Level>? _cache;
  int? _photoCount;

  Future<List<Level>> loadLevels() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/levels.json');
    final List<dynamic> list = json.decode(raw) as List<dynamic>;
    final levels = list
        .map((e) => Level.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.globalIndex.compareTo(b.globalIndex));
    _cache = levels;
    return levels;
  }

  /// 打包进 assets 的照片总数（assets/photos/count.txt）。
  Future<int> loadPhotoCount() async {
    if (_photoCount != null) return _photoCount!;
    try {
      final s = await rootBundle.loadString('assets/photos/count.txt');
      _photoCount = int.tryParse(s.trim()) ?? 0;
    } catch (_) {
      _photoCount = 0;
    }
    return _photoCount!;
  }

  /// 按学科分组。
  Future<Map<Subject, List<Level>>> loadBySubject() async {
    final all = await loadLevels();
    final map = <Subject, List<Level>>{};
    for (final l in all) {
      map.putIfAbsent(l.subject, () => []).add(l);
    }
    for (final v in map.values) {
      v.sort((a, b) => a.indexInSubject.compareTo(b.indexInSubject));
    }
    return map;
  }
}
