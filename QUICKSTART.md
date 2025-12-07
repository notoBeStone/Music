# 快速开始指南

## 环境要求

- macOS 14.0+
- Xcode 15.0+
- iOS 16.0+ 模拟器或真机
- Swift 5.9+

## 安装步骤

### 1. 打开项目
```bash
cd /Users/pengruilin/Document/Music
open Music.xcodeproj
```

### 2. 配置签名
在 Xcode 中：
1. 选择 `Music` target
2. 进入 `Signing & Capabilities`
3. 选择你的 Team
4. Xcode 会自动配置 Bundle Identifier

### 3. 运行项目
- 选择目标设备（推荐使用真机以测试音频功能）
- 按 `Cmd + R` 运行

## 项目结构说明

```
Music/
├── Models/              # 📦 数据模型
├── Managers/            # 🎵 音频管理器
├── ViewModels/          # 🧠 业务逻辑
├── Views/               # 🎨 用户界面
│   ├── Project/         # 项目列表
│   ├── Recording/       # 录音编辑
│   └── Components/      # UI 组件
├── Utilities/           # 🛠 工具类
└── Assets.xcassets/     # 🖼 资源文件
```

## 关键文件说明

### 核心管理器
- **AudioEngineManager.swift**: 🎛 音频引擎核心，管理所有音频操作
- **ProjectManager.swift**: 💾 项目持久化，处理文件存储

### 主界面
- **ProjectListView.swift**: 📋 项目列表，应用首页
- **RecordingView.swift**: 🎙 录音界面，核心功能界面

### 数据模型
- **Project.swift**: 项目数据
- **Track.swift**: 音轨数据

## 常见问题

### Q1: 编译错误 "Cannot find type in scope"
**A**: 确保所有文件都已添加到 target。在 File Inspector 中检查 Target Membership。

### Q2: 麦克风权限问题
**A**: 确保 Info.plist 中有 `NSMicrophoneUsageDescription` 配置。

### Q3: 音频无法播放
**A**: 
1. 检查音频会话是否正确配置
2. 在真机上测试（模拟器音频功能受限）
3. 确保已授予麦克风权限

### Q4: 构建失败
**A**: 
1. 清理构建文件夹：`Cmd + Shift + K`
2. 清理派生数据：Xcode → Preferences → Locations → Derived Data → Delete
3. 重新构建：`Cmd + B`

## 测试流程

### 基础功能测试
1. **启动应用** → 应该看到空的项目列表
2. **创建项目** → 点击 "+" 按钮，输入项目名称
3. **进入项目** → 点击项目卡片进入录音界面
4. **录制音轨** → 点击红色录音按钮，对着麦克风说话或制造声音
5. **播放测试** → 录音完成后自动播放，检查循环是否流畅
6. **叠加音轨** → 在播放时再次录音，测试多轨叠加
7. **音量控制** → 调节音轨音量滑块
8. **静音测试** → 点击静音按钮
9. **删除音轨** → 点击删除按钮

### 高级功能测试
1. **独奏功能** → 点击 "S" 按钮，只播放该轨道
2. **项目复制** → 在项目列表长按项目，选择复制
3. **项目删除** → 在项目列表长按项目，选择删除

## 调试技巧

### 查看日志
在 Xcode Console 中查看日志输出，所有重要操作都有日志记录：
```
[AudioEngineManager] 音频会话配置成功
[AudioRecorder] 录音完成：track1.wav
[ProjectManager] 保存项目：我的项目
```

### 断点调试
推荐在以下位置设置断点：
1. `AudioEngineManager.startRecording` - 录音开始
2. `AudioPlayer.play` - 播放开始
3. `ProjectManager.saveProject` - 项目保存

### 性能分析
使用 Instruments 分析：
- Time Profiler - 查看 CPU 占用
- Allocations - 查看内存使用
- Leaks - 检查内存泄漏

## 开发建议

### 添加新功能
1. 先在 Models 中定义数据结构
2. 在 Managers 中实现业务逻辑
3. 在 ViewModels 中连接 UI 和逻辑
4. 最后实现 Views

### 代码规范
- 使用 `ColorTheme` 定义颜色
- 使用 `// MARK: -` 分隔代码区块
- 添加文档注释 `///`
- 遵循 MVVM 架构

### 性能优化
- 音频操作在后台线程
- UI 更新必须在主线程
- 及时释放音频资源
- 避免在主线程做耗时操作

## 扩展开发

### 添加新音轨类型
1. 在 `Track.swift` 中添加 `trackType` 属性
2. 在 `TrackRowView.swift` 中添加类型标识
3. 在 `AudioEngineManager` 中处理不同类型

### 添加音效
1. 创建新的 `AudioEffect` 协议
2. 实现具体音效类（如 `ReverbEffect`）
3. 在 `AudioEngineManager` 中应用音效

### 添加新界面
1. 在 `Views` 目录下创建新文件
2. 创建对应的 ViewModel
3. 在 `ContentView` 或 `RecordingView` 中导航

## 资源链接

- [SwiftUI 官方文档](https://developer.apple.com/documentation/swiftui/)
- [AVFoundation 官方文档](https://developer.apple.com/documentation/avfoundation/)
- [iOS 人机界面指南](https://developer.apple.com/design/human-interface-guidelines/)

## 获取帮助

如遇到问题：
1. 查看 README.md 了解功能详情
2. 查看 IMPLEMENTATION_SUMMARY.md 了解实现细节
3. 检查 Xcode Console 的错误日志
4. 使用断点调试定位问题

---

**祝开发顺利！** 🎉

