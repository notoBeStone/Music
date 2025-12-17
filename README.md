# 乐器循环录音 App

一个基于 SwiftUI 的 iOS 音乐创作应用，支持多轨循环录音、实时混音和导出功能。

## 功能特性

### 🎵 核心功能
- **多轨录音**: 最多支持 4 条音轨同时循环播放
- **边放边录**: 听着已有音轨录制新音轨，完美同步
- **实时混音**: 调整每条音轨的音量、静音、独奏
- **循环播放**: 无缝循环，边界无断点
- **节拍器**: 内置节拍器，精确 BPM 控制

### 💾 项目管理
- 创建、保存、加载多个项目
- 项目复制和删除
- 自动保存录音进度
- 撤销功能（最多 10 步）

### 📤 导出分享
- 支持 WAV、M4A、MP3 格式
- 高质量混音渲染
- 一键分享到其他应用

### 🎨 精美界面
- 深色主题设计
- 2x2 音轨网格布局
- 实时录音电平显示
- 流畅的动画效果

## 技术规格

- **平台**: iOS 17.0+
- **语言**: Swift 5.9+
- **框架**: SwiftUI, AVFoundation
- **架构**: MVVM
- **音频配置**:
  - 采样率: 48kHz
  - 位深度: 16-bit PCM
  - 延迟: ~5ms (256 samples)
  - 声道: 立体声

## 快速开始

### 运行项目
1. 使用 Xcode 15+ 打开 `Music.xcodeproj`
2. 选择目标设备（iOS 17+ 模拟器或真机）
3. 点击运行 (⌘R)
4. 允许麦克风权限

### 基本使用
1. **创建项目**: 点击 + 按钮创建新项目
2. **开始录音**: 点击红色录音按钮
3. **叠加音轨**: 录完第一条后，再次点击录音按钮录制第二条
4. **控制播放**: 使用播放/暂停/停止按钮
5. **调整音量**: 长按音轨卡片进入详情页
6. **导出作品**: 点击菜单选择导出

详细使用说明请查看 [QUICKSTART.md](QUICKSTART.md)

## 项目结构

```
Music/
├── Models/              # 数据模型
│   ├── ProjectModel.swift
│   ├── TrackModel.swift
│   ├── AppSettings.swift
│   └── States.swift
├── Managers/            # 业务管理器
│   ├── AudioEngineManager.swift    # 音频引擎核心
│   ├── MetronomeManager.swift      # 节拍器
│   ├── AudioExporter.swift         # 导出功能
│   ├── ProjectRepository.swift     # 项目持久化
│   ├── SettingsManager.swift       # 设置管理
│   └── UndoManager.swift           # 撤销管理
├── ViewModels/          # 视图模型
│   ├── MainViewModel.swift
│   └── ProjectListViewModel.swift
├── Views/               # 视图
│   ├── MainView.swift              # 主创作页面
│   ├── ProjectListView.swift       # 项目列表
│   ├── Components/                 # 可复用组件
│   └── Sheets/                     # 弹窗页面
└── Utilities/           # 工具类
    ├── ColorTheme.swift
    ├── LocalizedString.swift
    └── FileManager+Extensions.swift
```

## 开发规范

本项目严格遵循以下规范：
- ✅ 所有颜色使用 `ColorTheme`
- ✅ MVVM 架构，视图模型使用 `@MainActor`
- ✅ SwiftUI 优先，避免 UIKit
- ✅ 使用 `// MARK: -` 分隔代码区块
- ✅ 错误处理使用 `LocalizedError`
- ✅ 文件命名使用大驼峰，变量使用小驼峰

详细规范请查看 [.cursor/rules/rule.mdc](.cursor/rules/rule.mdc)

## 性能指标

- ⚡ 录音延迟: < 50ms（实际约 5.3ms）
- 🎯 多轨同步: 样本级精确对齐
- 🔄 循环播放: 无缝衔接，无断点
- 💾 内存管理: 及时释放音频资源

## 文档

- [需求文档](需求文档.md) - 完整的产品需求说明
- [快速开始](QUICKSTART.md) - 使用指南和常见问题
- [实现报告](IMPLEMENTATION_COMPLETE.md) - 详细的实现说明
- [开发规范](.cursor/rules/rule.mdc) - 代码规范和最佳实践

## 已知限制

### MVP 不包含的功能
- 高级音效（EQ、压缩、失真）
- 云同步和社区功能
- 波形精确编辑
- 虚拟乐器（鼓组、键盘）
- iPad 专用布局

### 未来改进方向
- 显示真实音频波形
- 添加更多音频效果
- 支持导入音频文件
- 支持更多音轨（8轨、16轨）
- 添加自动混音功能

## 贡献指南

欢迎提交 Issue 和 Pull Request！

在提交代码前，请确保：
1. 遵循项目的代码规范
2. 添加必要的注释
3. 测试所有功能正常工作
4. 更新相关文档

## 许可证

本项目仅供学习和参考使用。

## 联系方式

如有问题或建议，欢迎通过以下方式联系：
- 提交 GitHub Issue
- 发送邮件反馈

---

**享受音乐创作的乐趣！** 🎵🎸🎹

Made with ❤️ using Swift & SwiftUI
