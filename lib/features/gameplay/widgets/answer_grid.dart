import 'package:flutter/material.dart';
import '../../../data/models/question.dart';

/// 选择/多选/排序题的答题网格。
/// - singleChoice: 点一个，对即过
/// - multiChoice: 选齐所有正确项后点「确定」判定
/// - ordering: 按点击顺序记录，点满后比对顺序
class AnswerGrid extends StatefulWidget {
  final Question question;
  final Color color;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const AnswerGrid({
    super.key,
    required this.question,
    required this.color,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<AnswerGrid> createState() => _AnswerGridState();
}

class _AnswerGridState extends State<AnswerGrid> {
  final Set<String> _selected = {}; // 多选用
  final List<String> _order = []; // 排序用（点击顺序）
  String? _flashWrongId; // 单选答错时闪红的项
  bool _shake = false;

  bool get _isOrdering => widget.question.type == QuestionType.ordering;
  bool get _isMulti => widget.question.type == QuestionType.multiChoice;

  void _tapSingle(AnswerOption o) {
    if (widget.question.correctIds.contains(o.id)) {
      widget.onCorrect();
    } else {
      setState(() => _flashWrongId = o.id);
      widget.onWrong();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _flashWrongId = null);
      });
    }
  }

  void _tapMulti(AnswerOption o) {
    setState(() {
      if (_selected.contains(o.id)) {
        _selected.remove(o.id);
      } else {
        _selected.add(o.id);
      }
    });
  }

  void _tapOrder(AnswerOption o) {
    if (_order.contains(o.id)) return;
    setState(() => _order.add(o.id));
    if (_order.length == widget.question.options.length) {
      _checkOrder();
    }
  }

  void _checkMulti() {
    final correct = widget.question.correctIds.toSet();
    if (_selected.length == correct.length &&
        _selected.containsAll(correct)) {
      widget.onCorrect();
    } else {
      _wrongFeedback();
      setState(_selected.clear);
    }
  }

  void _checkOrder() {
    final ok = _listEquals(_order, widget.question.correctIds);
    if (ok) {
      widget.onCorrect();
    } else {
      _wrongFeedback();
      setState(_order.clear);
    }
  }

  void _wrongFeedback() {
    widget.onWrong();
    setState(() => _shake = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _shake = false);
    });
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final opts = widget.question.options;
    final crossAxis = opts.length <= 2 ? 2 : (opts.length <= 4 ? 2 : 3);

    final grid = GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.5,
      ),
      itemCount: opts.length,
      itemBuilder: (context, i) {
        final o = opts[i];
        final selected = _selected.contains(o.id);
        final orderIdx = _order.indexOf(o.id);
        return _OptionTile(
          option: o,
          color: widget.color,
          selected: selected,
          orderNumber: orderIdx >= 0 ? orderIdx + 1 : null,
          flashWrong: _flashWrongId == o.id,
          onTap: () {
            if (_isOrdering) {
              _tapOrder(o);
            } else if (_isMulti) {
              _tapMulti(o);
            } else {
              _tapSingle(o);
            }
          },
        );
      },
    );

    return AnimatedSlide(
      offset: _shake ? const Offset(0.02, 0) : Offset.zero,
      duration: const Duration(milliseconds: 60),
      child: Column(
        children: [
          Expanded(child: grid),
          if (_isMulti)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: _selected.isEmpty ? null : _checkMulti,
                style: ElevatedButton.styleFrom(backgroundColor: widget.color),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('确定',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final AnswerOption option;
  final Color color;
  final bool selected;
  final int? orderNumber;
  final bool flashWrong;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.color,
    required this.selected,
    required this.orderNumber,
    required this.flashWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = flashWrong
        ? const Color(0xFFFFE0E0)
        : (selected || orderNumber != null
            ? color.withOpacity(0.18)
            : Colors.white);
    final border = flashWrong
        ? const Color(0xFFFF6B6B)
        : (selected || orderNumber != null ? color : Colors.black12);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border, width: 3),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: FittedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (option.emoji.isNotEmpty)
                        Text(option.emoji,
                            style: const TextStyle(fontSize: 44)),
                      if (option.emoji.isNotEmpty && option.label.isNotEmpty)
                        const SizedBox(width: 8),
                      if (option.label.isNotEmpty)
                        Text(
                          option.label,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (orderNumber != null)
              Positioned(
                top: 6,
                left: 6,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: color,
                  child: Text('$orderNumber',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
