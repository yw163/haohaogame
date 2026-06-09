import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_page.dart';
import '../features/subject/subject_select_page.dart';
import '../features/map/level_map_page.dart';
import '../features/gameplay/level_play_page.dart';
import '../features/parent/parent_gate_page.dart';
import '../features/parent/parent_dashboard_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const HomePage()),
    GoRoute(path: '/subjects', builder: (c, s) => const SubjectSelectPage()),
    GoRoute(
      path: '/map/:subjectId',
      builder: (c, s) => LevelMapPage(subjectId: s.pathParameters['subjectId']!),
    ),
    GoRoute(
      path: '/play/:levelId',
      builder: (c, s) => LevelPlayPage(levelId: s.pathParameters['levelId']!),
    ),
    GoRoute(path: '/parent-gate', builder: (c, s) => const ParentGatePage()),
    GoRoute(path: '/parent', builder: (c, s) => const ParentDashboardPage()),
  ],
  errorBuilder: (c, s) => Scaffold(
    body: Center(child: Text('页面走丢啦：${s.error}')),
  ),
);
