import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_page.dart';
import '../features/map/level_map_page.dart';
import '../features/gameplay/level_play_page.dart';
import '../features/skill/skill_gallery_page.dart';
import '../features/parent/parent_gate_page.dart';
import '../features/parent/parent_dashboard_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const HomePage()),
    GoRoute(path: '/map', builder: (c, s) => const LevelMapPage()),
    GoRoute(
      path: '/play/:levelId',
      builder: (c, s) => LevelPlayPage(levelId: s.pathParameters['levelId']!),
    ),
    GoRoute(path: '/skills', builder: (c, s) => const SkillGalleryPage()),
    GoRoute(path: '/parent-gate', builder: (c, s) => const ParentGatePage()),
    GoRoute(
      path: '/parent',
      builder: (c, s) => const ParentDashboardPage(),
    ),
  ],
  errorBuilder: (c, s) => Scaffold(
    body: Center(child: Text('页面走丢啦：${s.error}')),
  ),
);
