import 'package:flutter/material.dart';
import '../data/models/level.dart';

/// 儿童化主题：圆润、明亮、大字。两大主题各有色板。
class AppColors {
  // 数学：暖橙
  static const mathPrimary = Color(0xFFFF8A3D);
  static const mathLight = Color(0xFFFFE0C2);
  // 宇宙：深蓝紫
  static const spacePrimary = Color(0xFF5B6CE0);
  static const spaceLight = Color(0xFFD9DEFF);

  static const correct = Color(0xFF4CC95E);
  static const wrong = Color(0xFFFF6B6B);
  static const star = Color(0xFFFFC93C);

  static const bg = Color(0xFFFFFBF2);
  static const ink = Color(0xFF3A3A4A);

  static Color primaryFor(LevelTheme t) =>
      t == LevelTheme.space ? spacePrimary : mathPrimary;
  static Color lightFor(LevelTheme t) =>
      t == LevelTheme.space ? spaceLight : mathLight;
}

ThemeData buildAppTheme() {
  const seed = AppColors.mathPrimary;
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: null, // 用系统中文字体；如自备圆体字体可在此设置
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
