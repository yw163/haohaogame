/// 照片自动填充规则（确定性，无需家长上传）。
///
/// 规则：
/// - 全局第 1..72 关：按顺序使用 photo_000 .. photo_071，每关 1 张。
/// - 第 73 关起：用基于关卡序号的伪随机「不规则」挑选，
///   并且约 1/3 的关卡同时展示 2 张照片（并排滑稽效果）。
class PhotoPlan {
  final List<int> indices; // 要展示的照片下标（1 或 2 个）
  final bool funnyDouble; // 是否双图滑稽展示
  const PhotoPlan(this.indices, this.funnyDouble);
}

class PhotoAssigner {
  final int photoCount; // 可用照片总数（如 72）
  const PhotoAssigner(this.photoCount);

  /// 确定性伪随机（避免使用 Random，保证每次结果一致）。
  int _hash(int n) {
    var x = (n * 2654435761) & 0x7fffffff;
    x ^= (x >> 13);
    x = (x * 1274126177) & 0x7fffffff;
    x ^= (x >> 16);
    return x & 0x7fffffff;
  }

  /// 给定全局关卡序号（1 起），返回该关要展示的照片计划。
  PhotoPlan planFor(int globalIndex) {
    if (photoCount <= 0) return const PhotoPlan([], false);

    // 前 72 关：顺序单图
    if (globalIndex <= photoCount) {
      return PhotoPlan([globalIndex - 1], false);
    }

    // 之后：不规则挑选
    final h = _hash(globalIndex);
    final first = h % photoCount;

    // 约 1/3 关卡展示双图（滑稽并排）
    final isDouble = (h % 3 == 0);
    if (!isDouble) {
      return PhotoPlan([first], false);
    }

    var second = _hash(globalIndex * 7 + 13) % photoCount;
    if (second == first) second = (second + 1) % photoCount;
    return PhotoPlan([first, second], true);
  }

  String assetPath(int photoIndex) =>
      'assets/photos/photo_${photoIndex.toString().padLeft(3, '0')}.jpg';
}
