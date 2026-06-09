# -*- coding: utf-8 -*-
"""压缩皓皓照片并打包进 assets：
- 关卡照片 photo_000.jpg .. photo_071.jpg：长边 900px，质量 80
- 指定图标单独高质量导出，供生成 App 图标用
"""
import os
import glob
from PIL import Image, ImageOps

SRC = r"D:\Users\weiyang20\Desktop\皓皓照片"
OUT = os.path.join("assets", "photos")
ICON_SRC = "微信图片_20260609121134_184_31.jpg"
os.makedirs(OUT, exist_ok=True)

# 收集所有图片，按文件名排序（保证顺序稳定）
files = sorted(
    glob.glob(os.path.join(SRC, "*.jpg")) + glob.glob(os.path.join(SRC, "*.png"))
)
print(f"找到 {len(files)} 张照片")


def fit(img, max_side):
    img = ImageOps.exif_transpose(img)  # 修正手机拍摄方向
    img = img.convert("RGB")
    w, h = img.size
    scale = min(max_side / max(w, h), 1.0)
    if scale < 1.0:
        img = img.resize((int(w * scale), int(h * scale)), Image.LANCZOS)
    return img


total = 0
for i, f in enumerate(files):
    try:
        im = fit(Image.open(f), 900)
        dst = os.path.join(OUT, f"photo_{i:03d}.jpg")
        im.save(dst, "JPEG", quality=80, optimize=True)
        total += os.path.getsize(dst)
    except Exception as e:
        print("跳过", f, e)

print(f"导出 {len(files)} 张到 {OUT}，合计 {total/1048576:.1f} MB")

# 导出图标源图（正方形裁切，512px 高质量）
icon_path = os.path.join(SRC, ICON_SRC)
if os.path.exists(icon_path):
    im = ImageOps.exif_transpose(Image.open(icon_path)).convert("RGB")
    w, h = im.size
    s = min(w, h)
    im = im.crop(((w - s) // 2, (h - s) // 2, (w + s) // 2, (h + s) // 2))
    im = im.resize((512, 512), Image.LANCZOS)
    os.makedirs(os.path.join("assets", "icon"), exist_ok=True)
    im.save(os.path.join("assets", "icon", "app_icon.png"), "PNG")
    print("图标已导出 assets/icon/app_icon.png")
else:
    print("！未找到指定图标文件:", icon_path)

# 记录照片总数，供 Dart 端读取
with open(os.path.join(OUT, "count.txt"), "w") as fp:
    fp.write(str(len(files)))
print("done")
