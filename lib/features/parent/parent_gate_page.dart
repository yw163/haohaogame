import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../state/providers.dart';

/// 家长门：双层防孩子。
/// 1) 先答一道两位数乘法（孩子算不出，家长能算）
/// 2) 若已设置 PIN，再输入 4 位 PIN；未设置则首次进入时设置。
class ParentGatePage extends ConsumerStatefulWidget {
  const ParentGatePage({super.key});

  @override
  ConsumerState<ParentGatePage> createState() => _ParentGatePageState();
}

class _ParentGatePageState extends ConsumerState<ParentGatePage> {
  // 第一层：算术
  late int _a;
  late int _b;
  final _mathCtrl = TextEditingController();
  bool _mathPassed = false;

  // 第二层：PIN
  final _pinCtrl = TextEditingController();
  final _pinConfirmCtrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final r = Random();
    _a = 12 + r.nextInt(80); // 两位数
    _b = 11 + r.nextInt(8);
  }

  @override
  void dispose() {
    _mathCtrl.dispose();
    _pinCtrl.dispose();
    _pinConfirmCtrl.dispose();
    super.dispose();
  }

  void _checkMath() {
    if (int.tryParse(_mathCtrl.text.trim()) == _a * _b) {
      setState(() {
        _mathPassed = true;
        _error = null;
      });
    } else {
      setState(() => _error = '答案不对，请家长操作');
    }
  }

  Future<void> _checkPin() async {
    final storage = ref.read(storageProvider);
    final pin = _pinCtrl.text.trim();

    if (!storage.hasPin) {
      // 首次设置
      if (pin.length != 4) {
        setState(() => _error = '请设置 4 位数字密码');
        return;
      }
      if (pin != _pinConfirmCtrl.text.trim()) {
        setState(() => _error = '两次输入不一致');
        return;
      }
      await storage.setPin(pin);
      if (mounted) context.go('/parent');
      return;
    }

    // 校验
    if (pin == storage.parentPin) {
      if (mounted) context.go('/parent');
    } else {
      setState(() => _error = '密码错误');
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageProvider);
    final settingPin = !storage.hasPin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('家长入口'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👨‍👩‍👧 家长验证',
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('为防止小朋友误入，请家长完成验证',
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 24),
                if (!_mathPassed) ...[
                  Text('请计算：$_a × $_b = ?',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _mathCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24),
                    decoration: const InputDecoration(
                      hintText: '输入答案',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _checkMath(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkMath,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mathPrimary),
                    child: const Text('下一步',
                        style: TextStyle(color: Colors.white)),
                  ),
                ] else ...[
                  Text(
                    settingPin ? '设置 4 位家长密码' : '请输入家长密码',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pinCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, letterSpacing: 8),
                    decoration: const InputDecoration(
                      hintText: '••••',
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (settingPin)
                    TextField(
                      controller: _pinConfirmCtrl,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, letterSpacing: 8),
                      decoration: const InputDecoration(
                        hintText: '再输一次',
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkPin,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.spacePrimary),
                    child: Text(settingPin ? '设置并进入' : '进入',
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(color: AppColors.wrong)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
