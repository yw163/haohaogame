import 'package:flutter/material.dart';
import '../data/models/level.dart';

/// 儿童化主题：圆润、明亮、大字。五大学科各有色板。
class AppColors {
  static const correct = Color(0xFF4CC95E);
  static const wrong = Color(0xFFFF6B6B);
  static const star = Color(0xFFFFC93C);
  static const bg = Color(0xFFFFFBF2);
  static const ink = Color(0xFF3A3A4A);

  static Color primaryFor(Subject s) => switch (s) {
        Subject.math => const Color(0xFFFF8A3D), // 橙
        Subject.space => const Color(0xFF5B6CE0), // 蓝紫
        Subject.physics => const Color(0xFF2BB6A8), // 青绿
        Subject.fun => const Color(0xFFEF5DA8), // 粉
        Subject.poetry => const Color(0xFF9B6B3D), // 古卷棕
      };

  static Color lightFor(Subject s) => switch (s) {
        Subject.math => const Color(0xFFFFE0C2),
        Subject.space => const Color(0xFFD9DEFF),
        Subject.physics => const Color(0xFFC6F0EA),
        Subject.fun => const Color(0xFFFFD6EC),
        Subject.poetry => const Color(0xFFEAD9C2),
      };
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFFFF8A3D),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
