import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/level.dart';

/// 从 assets/data/levels.json 加载全部关卡（只读静态题库）。
class LevelRepository {
  List<Level>? _cache;

  Future<List<Level>> loadLevels() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/levels.json');
    final List<dynamic> list = json.decode(raw) as List<dynamic>;
    final levels = list
        .map((e) => Level.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    _cache = levels;
    return levels;
  }
}
