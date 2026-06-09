import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 大号弹性按钮：点击有缩放反馈 + 轻震动，适合儿童触控。
class BigButton extends StatefulWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;
  final double fontSize;

  const BigButton({
    super.key,
    required this.label,
    required this.onTap,
    this.emoji = '',
    this.color = const Color(0xFFFF8A3D),
    this.fontSize = 28,
  });

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> {
  double _scale = 1.0;

  void _down(_) => setState(() => _scale = 0.92);
  void _up(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapCancel: () => _up(null),
      onTapUp: (d) {
        _up(d);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.emoji.isNotEmpty) ...[
                Text(widget.emoji, style: TextStyle(fontSize: widget.fontSize)),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 星星行（1~3 颗），用于显示关卡评分。
class StarRow extends StatelessWidget {
  final int stars;
  final double size;
  const StarRow({super.key, required this.stars, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final on = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            on ? '⭐' : '☆',
            style: TextStyle(
              fontSize: size,
              color: on ? const Color(0xFFFFC93C) : Colors.grey,
            ),
          ),
        );
      }),
    );
  }
}
