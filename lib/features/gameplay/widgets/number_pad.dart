import 'package:flutter/material.dart';

/// 数字键盘输入题。孩子输入数字与正确答案比对。
class NumberPad extends StatefulWidget {
  final String correct;
  final Color color;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const NumberPad({
    super.key,
    required this.correct,
    required this.color,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<NumberPad> createState() => _NumberPadState();
}

class _NumberPadState extends State<NumberPad> {
  String _input = '';
  bool _shake = false;

  void _press(String d) {
    if (_input.length >= 4) return;
    setState(() => _input += d);
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _submit() {
    if (_input.isEmpty) return;
    if (_input == widget.correct) {
      widget.onCorrect();
    } else {
      widget.onWrong();
      setState(() => _shake = true);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() {
          _shake = false;
          _input = '';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 输入显示框
        AnimatedSlide(
          offset: _shake ? const Offset(0.03, 0) : Offset.zero,
          duration: const Duration(milliseconds: 60),
          child: Container(
            width: double.infinity,
            height: 70,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.color, width: 3),
            ),
            child: Text(
              _input.isEmpty ? '?' : _input,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: _input.isEmpty ? Colors.black26 : widget.color,
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              for (var i = 1; i <= 9; i++)
                _key('$i', () => _press('$i')),
              _key('⌫', _backspace, bg: Colors.orange.shade100),
              _key('0', () => _press('0')),
              _key('✓', _submit, bg: widget.color, fg: Colors.white),
            ],
          ),
        ),
      ],
    );
  }

  Widget _key(String label, VoidCallback onTap, {Color? bg, Color? fg}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: fg ?? Colors.black87,
          ),
        ),
      ),
    );
  }
}
