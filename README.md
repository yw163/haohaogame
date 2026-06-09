# 皓皓闯关 🌟

为杨禹皓（皓皓）定制的 **数学 + 宇宙百科** 闯关游戏，运行于华为 MatePad 11（HarmonyOS 4.x，兼容 Android）。

每过一关解锁一个**技能徽章**，并展示家长上传的**皓皓搞笑照片**，满满成就感。

## 玩法亮点

- **24 关**：数学星球 12 关（二年级难度：两位数加减进退位、乘法口诀、除法平分、图形、长度单位、时间、应用题、找规律）+ 宇宙星球 12 关（太阳系、恒星行星、月相、行星排序、土星光环、宇航员、星座、昼夜四季等）。
- **闯关解锁**：通过一关才解锁下一关，逐关推进。
- **技能墙**：24 个成就徽章，已解锁彩色 + 照片，未解锁灰色锁头，激发收集欲。
- **语音读题**：系统中文 TTS 自动朗读题目、选项和夸奖（孩子识字不全也能玩），可点「再读一遍」。
- **温柔反馈**：答错不结束、不扣分，鼓励再试；按答错次数评 1~3 星。
- **家长后台**：算术 + PIN 双层验证防孩子误入；为每个技能上传/更换/删除照片；开关音效；重置进度。

## 技术栈

Flutter · Riverpod（状态）· go_router（路由）· shared_preferences（进度/设置）· image_picker + flutter_image_compress（照片）· flutter_tts（语音）· confetti（撒花）。

题库为 `assets/data/levels.json`，**改题不用动代码**。照片存 app 私有目录，映射存本地。纯离线，无服务器。

## 目录结构

```
lib/
├── main.dart                 # 入口：锁横屏 + 初始化服务
├── core/                     # 主题、路由
├── data/                     # 模型、题库加载、技能定义
├── services/                 # 存储、照片、TTS
├── state/providers.dart      # Riverpod providers
├── shared/widgets.dart       # 大按钮、星星
└── features/                 # home / map / gameplay / skill / parent
assets/data/levels.json       # 24 关题库
test/game_logic_test.dart     # 进度/题库/技能 校验测试
```

## 首次运行（在已装 Flutter 的电脑上）

本仓库只含 `lib/`、`assets/`、`pubspec.yaml` 等源码，**平台工程目录（android/ios/…）需生成一次**：

```bash
cd yuhao_game
flutter create .            # 生成 android/ 等平台目录（不覆盖已有 lib）
flutter pub get
flutter test                # 跑逻辑测试
flutter run                 # 连接 MatePad 调试运行
```

> 生成 `android/` 后，请把本仓库的 `android_overrides/AndroidManifest_snippet.xml` 里的权限合并进 `android/app/src/main/AndroidManifest.xml`（相册读取）。

## 打包安装到 MatePad 11

MatePad 11（HarmonyOS）支持安装 Android APK：

```bash
flutter build apk --release
# 产物：build/app/outputs/flutter-apk/app-release.apk
```

把 APK 传到平板安装即可（需在平板「设置 → 安全」允许安装未知来源应用）。
若目标为纯 HarmonyOS NEXT，需改用鸿蒙 Flutter 工具链（flutter_flutter 鸿蒙分支）重新构建，业务代码可复用。

## 家长使用指南

1. 主菜单右上角 ⚙️ → 算一道乘法 → 首次设置 4 位密码。
2. 后台逐个技能「上传」皓皓的搞笑照片（可提前全部传好）。
3. 孩子闯关解锁该技能时，会在庆祝页看到对应照片（拍立得风格）。
4. 没传照片的技能用默认 emoji 徽章占位，不影响游玩。

## 自定义题目

编辑 `assets/data/levels.json`。题型 `type`：
- `singleChoice` 单选 / `multiChoice` 多选 / `ordering` 排序 / `numberInput` 数字输入
- 选项用 `emoji` 和/或 `label`；`correctIds` 指向选项 id（排序题为正确顺序；数字输入题为答案字符串）
- `ttsText` 朗读文本，`scienceIntro` 为宇宙关的科普旁白
