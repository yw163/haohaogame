import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 平板强制横屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final storage = await StorageService.create();
  final tts = TtsService()..enabled = storage.soundOn;
  await tts.init();

  runApp(
    ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(storage),
        ttsProvider.overrideWithValue(tts),
      ],
      child: const YuhaoApp(),
    ),
  );
}

class YuhaoApp extends StatelessWidget {
  const YuhaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '皓皓闯关',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
