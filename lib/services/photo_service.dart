import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// 家长后台照片处理：从相册选图 -> 压缩 -> 存到 app 私有目录。
/// 返回保存后的本地文件绝对路径，存进 StorageService 的照片映射。
class PhotoService {
  final ImagePicker _picker = ImagePicker();

  /// 选择并保存某个技能对应的照片。用户取消时返回 null。
  Future<String?> pickAndSaveForSkill(String skillId) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return null;

    final dir = await _photosDir();
    final destPath = '${dir.path}/skill_$skillId.jpg';

    // 压缩：长边限制，减小内存与存储占用。失败则直接复制原图。
    final result = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      destPath,
      quality: 80,
      minWidth: 1280,
      minHeight: 1280,
      format: CompressFormat.jpeg,
    );

    if (result != null) return result.path;

    // 兜底：压缩不可用时复制原文件
    final bytes = await File(picked.path).readAsBytes();
    final out = File(destPath);
    await out.writeAsBytes(bytes, flush: true);
    return out.path;
  }

  /// 删除某技能照片文件。
  Future<void> deleteForSkill(String skillId) async {
    final dir = await _photosDir();
    final f = File('${dir.path}/skill_$skillId.jpg');
    if (await f.exists()) await f.delete();
  }

  Future<Directory> _photosDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/photos');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
