# 乐起 App - 目录结构说明

## 📁 整体架构

本项目采用 **MVVM 架构 + 功能模块化** 的组织方式，支持良好的可扩展性。

```
Music/
├── MusicApp.swift                    # App 入口
├── LaunchScreen.storyboard           # 系统启动屏幕
│
├── Models/                           # 数据模型层
│   ├── AppSettings.swift             # 应用设置模型
│   ├── ProjectModel.swift            # 项目模型
│   ├── States.swift                  # 状态定义
│   └── TrackModel.swift              # 音轨模型
│
├── ViewModels/                       # 视图模型层（按功能模块组织）
│   ├── Launch/                       # 启动模块 ViewModels
│   ├── Project/                      # 项目管理模块 ViewModels
│   │   └── ProjectListViewModel.swift
│   ├── Recording/                    # 录音模块 ViewModels
│   │   └── MainViewModel.swift
│   └── Settings/                     # 设置模块 ViewModels
│
├── Views/                            # 视图层（按功能模块组织）
│   ├── Launch/                       # 启动相关视图
│   │   ├── ContentView.swift         # 主容器视图
│   │   └── LaunchScreenView.swift    # 启动动画视图
│   ├── Project/                      # 项目管理视图
│   │   └── ProjectListView.swift     # 项目列表
│   ├── Recording/                    # 录音相关视图
│   │   └── MainView.swift            # 主录音界面
│   ├── Settings/                     # 设置相关视图
│   └── Common/                       # 通用视图组件
│       ├── Components/               # 可复用组件
│       │   ├── RecordButton.swift
│       │   └── TrackCardView.swift
│       └── Sheets/                   # 弹出视图
│           ├── ExportView.swift
│           └── TrackDetailSheet.swift
│
├── Managers/                         # 业务管理器
│   ├── AudioEngineManager.swift      # 音频引擎管理
│   ├── AudioExporter.swift           # 音频导出
│   ├── MetronomeManager.swift        # 节拍器管理
│   ├── ProjectRepository.swift       # 项目数据仓库
│   ├── SettingsManager.swift         # 设置管理
│   └── UndoManager.swift             # 撤销管理
│
├── Extensions/                       # Swift 扩展
│   └── FileManager+Extensions.swift  # FileManager 扩展
│
├── Utilities/                        # 工具类
│   ├── ColorTheme.swift              # 颜色主题
│   └── LocalizedString.swift         # 本地化字符串
│
├── Assets.xcassets/                  # 资源目录（按类型组织）
│   ├── Icons/                        # 图标资源
│   │   ├── AppIcon.appiconset/       # App 图标
│   │   └── LaunchIcon.imageset/      # 启动图标
│   ├── Images/                       # 图片资源
│   │   └── （未来添加：背景图、装饰图等）
│   └── Colors/                       # 颜色资源
│       └── AccentColor.colorset/     # 强调色
│
├── Resources/                        # 非 Assets 资源（按类型组织）
│   ├── Videos/                       # 视频资源（如教程视频、宣传视频）
│   ├── Audio/                        # 音频资源（如预设音效、示例音频）
│   ├── Fonts/                        # 自定义字体
│   └── Data/                         # 数据文件（如 JSON、CSV 等）
│
├── en.lproj/                         # 英文本地化
│   ├── InfoPlist.strings
│   └── Localizable.strings
│
└── zh-Hans.lproj/                    # 简体中文本地化
    ├── InfoPlist.strings
    └── Localizable.strings
```

---

## 🎯 设计原则

### 1. **功能模块化**
- Views 和 ViewModels 按功能模块组织（Launch、Project、Recording、Settings）
- 每个模块独立，便于团队协作和代码维护
- 通用组件放在 `Views/Common/` 下

### 2. **资源分类管理**
- **Assets.xcassets/**：存放编译时资源（图标、图片、颜色）
  - `Icons/`：所有图标资源
  - `Images/`：所有图片资源
  - `Colors/`：颜色资源集
- **Resources/**：存放运行时资源（视频、音频、字体、数据文件）
  - `Videos/`：教程视频、宣传视频等
  - `Audio/`：预设音效、示例音频等
  - `Fonts/`：自定义字体文件
  - `Data/`：JSON、CSV 等数据文件

### 3. **MVVM 架构**
- **Models**：纯数据模型，实现 `Codable`、`Identifiable`
- **ViewModels**：业务逻辑，使用 `ObservableObject`
- **Views**：UI 展示，只负责视图渲染
- **Managers**：跨模块的业务管理器

### 4. **扩展性支持**
- 每个功能模块都有独立的目录，添加新功能时创建新模块即可
- 资源按类型分类，便于管理和查找
- 通用组件独立，便于复用

---

## 📝 添加新功能的指南

### 添加新的功能模块（如：音效处理）

1. **创建目录结构**：
   ```bash
   mkdir -p Views/Effects
   mkdir -p ViewModels/Effects
   ```

2. **添加视图文件**：
   ```
   Views/Effects/EffectsView.swift
   Views/Effects/EffectDetailView.swift
   ```

3. **添加 ViewModel**：
   ```
   ViewModels/Effects/EffectsViewModel.swift
   ```

4. **如需要，添加 Manager**：
   ```
   Managers/EffectsManager.swift
   ```

### 添加新的图片资源

1. **在 Xcode 中**：
   - 打开 `Assets.xcassets/Images/`
   - 右键 → New Image Set
   - 拖入图片文件

2. **在代码中使用**：
   ```swift
   Image("YourImageName")
   ```

### 添加视频资源

1. **添加视频文件**：
   - 将 `.mp4` 文件放入 `Resources/Videos/`
   - 在 Xcode 中添加到项目（确保 Target Membership 勾选）

2. **在代码中使用**：
   ```swift
   if let videoURL = Bundle.main.url(forResource: "tutorial", withExtension: "mp4") {
       // 使用 AVPlayer 播放
   }
   ```

### 添加音频资源（预设音效）

1. **添加音频文件**：
   - 将音频文件放入 `Resources/Audio/`
   - 在 Xcode 中添加到项目

2. **在代码中使用**：
   ```swift
   if let audioURL = Bundle.main.url(forResource: "click", withExtension: "wav") {
       // 使用 AVAudioPlayer 播放
   }
   ```

### 添加自定义字体

1. **添加字体文件**：
   - 将 `.ttf` 或 `.otf` 文件放入 `Resources/Fonts/`
   - 在 Xcode 中添加到项目
   - 在 `Info.plist` 中添加 `Fonts provided by application` 配置

2. **在代码中使用**：
   ```swift
   Text("Hello")
       .font(.custom("YourFontName", size: 16))
   ```

---

## 🔍 目录职责说明

| 目录 | 职责 | 示例文件 |
|------|------|----------|
| `Models/` | 数据模型定义 | `ProjectModel.swift` |
| `ViewModels/` | 业务逻辑、状态管理 | `MainViewModel.swift` |
| `Views/` | UI 视图组件 | `MainView.swift` |
| `Managers/` | 跨模块业务管理 | `AudioEngineManager.swift` |
| `Extensions/` | Swift 类型扩展 | `FileManager+Extensions.swift` |
| `Utilities/` | 工具类、辅助函数 | `ColorTheme.swift` |
| `Assets.xcassets/` | 编译时资源 | 图标、图片、颜色 |
| `Resources/` | 运行时资源 | 视频、音频、字体、数据 |

---

## ⚠️ 注意事项

1. **命名规范**：
   - 文件名使用大驼峰：`MainViewModel.swift`
   - 目录名使用大驼峰：`Recording/`
   - 资源名使用小写+下划线：`app_icon.png`

2. **文件位置**：
   - View 和对应的 ViewModel 应该在同名的功能模块目录下
   - 通用组件放在 `Views/Common/` 下
   - 跨模块的管理器放在 `Managers/` 下

3. **资源管理**：
   - 图标、图片等编译时资源放在 `Assets.xcassets/`
   - 视频、大型音频等运行时资源放在 `Resources/`
   - 记得在 Xcode 中正确设置 Target Membership

4. **扩展性**：
   - 添加新功能时，优先考虑创建新的功能模块目录
   - 避免在根目录或 Common 目录堆积过多文件
   - 保持每个目录的文件数量在合理范围（建议 < 10 个）

---

## 📊 当前模块说明

### Launch 模块
- **功能**：App 启动、启动动画
- **文件**：`ContentView.swift`、`LaunchScreenView.swift`

### Project 模块
- **功能**：项目管理、项目列表
- **文件**：`ProjectListView.swift`、`ProjectListViewModel.swift`

### Recording 模块
- **功能**：主录音界面、多轨录音
- **文件**：`MainView.swift`、`MainViewModel.swift`

### Settings 模块
- **功能**：应用设置
- **状态**：待开发

### Common 模块
- **功能**：通用组件、弹出视图
- **文件**：`RecordButton.swift`、`TrackCardView.swift`、`ExportView.swift`、`TrackDetailSheet.swift`

---

## 🚀 未来扩展方向

根据需求文档，未来可能添加的模块：

1. **Effects 模块**：音效处理（EQ、压缩、失真等）
2. **Library 模块**：音频素材库、预设管理
3. **Tutorial 模块**：新手引导、教程视频
4. **Share 模块**：社区分享、云同步
5. **Editor 模块**：波形编辑、精确裁剪

每个新模块都应该创建对应的 `Views/` 和 `ViewModels/` 子目录。

---

**最后更新**：2025-12-21
