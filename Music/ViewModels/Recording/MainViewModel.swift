//
//  MainViewModel.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation
import SwiftUI
import Combine
import AVFAudio

/// 主创作页面视图模型
@MainActor
final class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// 当前项目
    @Published var project: ProjectModel
    
    /// 录音状态
    @Published var recordingState: RecordingState = .idle
    
    /// 播放状态
    @Published var playbackState: PlaybackState = .stopped
    
    /// 当前播放位置
    @Published var currentTime: TimeInterval = 0.0
    
    /// 录音电平
    @Published var recordingLevel: Float = 0.0
    
    /// 录音时长
    @Published var recordingDuration: TimeInterval = 0.0
    
    /// 是否启用节拍器
    @Published var metronomeEnabled: Bool = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 是否显示错误
    @Published var showingError = false
    
    /// 正在录音的轨道
    @Published var recordingTrackId: UUID?
    
    /// 是否显示权限提示
    @Published var showingPermissionAlert = false
    
    // MARK: - Private Properties
    
    private let audioEngine = AudioEngineManager.shared
    private let metronome = MetronomeManager.shared
    private let repository = ProjectRepository.shared
    private let undoManager = ProjectUndoManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    /// 是否可以添加音轨
    var canAddTrack: Bool {
        return project.canAddTrack
    }
    
    /// 是否有音轨
    var hasTracks: Bool {
        return !project.tracks.isEmpty
    }
    
    /// 播放进度（0.0 ~ 1.0）
    var playbackProgress: Double {
        guard project.loopLength > 0 else { return 0 }
        return currentTime / project.loopLength
    }
    
    /// 是否可以撤销
    var canUndo: Bool {
        return undoManager.canUndo()
    }
    
    // MARK: - Initialization
    
    init(project: ProjectModel) {
        self.project = project
        self.metronomeEnabled = false
        
        // 保存初始状态
        undoManager.saveSnapshot(project)
        
        observeAudioEngine()
        setupLifecycleObservers()
    }
    
    // MARK: - Playback Control
    
    /// 切换播放/暂停
    func togglePlayback() {
        switch playbackState {
        case .stopped, .paused:
            play()
        case .playing:
            pause()
        }
    }
    
    /// 播放
    func play() {
        audioEngine.startPlayback(project: project)
    }
    
    /// 暂停
    func pause() {
        audioEngine.pausePlayback()
    }
    
    /// 停止
    func stop() {
        audioEngine.stopPlayback()
    }
    
    // MARK: - Recording Control
    
    /// 开始录音（创建新轨道）
    func startRecordingNewTrack() {
        guard canAddTrack else {
            showError(LocalizedString.ViewModel.maxTracksReached)
            return
        }
        
        // 创建新音轨
        let trackNumber = project.tracks.count + 1
        let colorIndex = project.tracks.count % 8
        let colorHex = getColorHex(at: colorIndex)
        
        let newTrack = TrackModel(
            name: "音轨 \(trackNumber)",
            colorHex: colorHex,
            sourceType: .mic
        )
        
        // 生成录音文件路径
        let fileName = "\(newTrack.id.uuidString).wav"
        let fileURL = FileManager.trackFileURL(for: project.id, trackId: newTrack.id)
        
        Task {
            do {
                // 如果有其他音轨正在播放，保持播放状态
                if hasTracks && playbackState != .playing {
                    play()
                }
                
                // 开始录音
                try await audioEngine.startRecording(to: fileURL, forTrackId: newTrack.id) { [weak self] success in
                    Task { @MainActor in
                        if success {
                            // 录音成功，添加到项目
                            var updatedTrack = newTrack
                            updatedTrack.filePath = fileName
                            self?.project.addTrack(updatedTrack)
                            self?.saveProject()
                            
                            // 重新加载播放（包含新轨道）
                            if self?.playbackState == .playing {
                                self?.stop()
                                self?.play()
                            }
                        }
                        self?.recordingTrackId = nil
                    }
                }
                
                await MainActor.run {
                    self.recordingTrackId = newTrack.id
                }
                
            } catch {
                await MainActor.run {
                    self.showError(LocalizedString.ViewModel.recordingFailed(error.localizedDescription))
                    self.recordingTrackId = nil
                }
            }
        }
    }
    
    /// 停止录音
    func stopRecording() {
        guard let trackId = recordingTrackId else { return }
        audioEngine.stopRecording(forTrackId: trackId)
    }
    
    /// 取消录音
    func cancelRecording() {
        audioEngine.cancelRecording()
        recordingTrackId = nil
    }
    
    // MARK: - Track Control
    
    /// 切换轨道静音
    func toggleTrackMute(_ track: TrackModel) {
        var updatedTrack = track
        updatedTrack.muted = !track.muted
        project.updateTrack(updatedTrack)
        
        audioEngine.updateTrackMute(trackId: track.id, muted: updatedTrack.muted)
        saveProject()
    }
    
    /// 切换轨道独奏
    func toggleTrackSolo(_ track: TrackModel) {
        var updatedTrack = track
        updatedTrack.solo = !track.solo
        project.updateTrack(updatedTrack)
        
        // 更新所有轨道的播放状态
        updateAllTracksPlaybackState()
        saveProject()
    }
    
    /// 更新轨道音量
    func updateTrackVolume(_ track: TrackModel, volume: Float) {
        var updatedTrack = track
        updatedTrack.volume = volume
        project.updateTrack(updatedTrack)
        
        audioEngine.updateTrackVolume(trackId: track.id, volume: volume)
        saveProject()
    }
    
    /// 删除轨道
    func deleteTrack(_ track: TrackModel) {
        project.removeTrack(id: track.id)
        
        // 删除音频文件
        if let filePath = track.filePath {
            let fileURL = FileManager.trackFileURL(for: project.id, trackId: track.id)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        saveProject()
        
        // 重新加载播放
        if playbackState == .playing {
            stop()
            if hasTracks {
                play()
            }
        }
    }
    
    /// 重命名轨道
    func renameTrack(_ track: TrackModel, newName: String) {
        var updatedTrack = track
        updatedTrack.name = newName
        project.updateTrack(updatedTrack)
        saveProject()
    }
    
    // MARK: - Metronome Control
    
    /// 切换节拍器
    func toggleMetronome() {
        metronomeEnabled.toggle()
        
        if metronomeEnabled {
            metronome.start(bpm: project.bpm, volume: 0.5)
        } else {
            metronome.stop()
        }
    }
    
    // MARK: - Undo Control
    
    /// 撤销
    func undo() {
        guard let previousProject = undoManager.undo() else {
            showError(LocalizedString.ViewModel.noUndo)
            return
        }
        
        // 停止当前播放/录音
        if playbackState == .playing {
            stop()
        }
        if recordingState == .recording {
            cancelRecording()
        }
        
        // 恢复到之前的状态
        project = previousProject
        saveProject()
        
        print("[MainViewModel] 撤销操作")
    }
    
    // MARK: - Project Control
    
    /// 更新 BPM
    func updateBPM(_ bpm: Int) {
        project.bpm = bpm
        saveProject()
        
        // 如果节拍器开启，更新节拍器
        if metronomeEnabled {
            metronome.stop()
            metronome.start(bpm: bpm, volume: 0.5)
        }
    }
    
    /// 更新循环小节数
    func updateLoopBars(_ loopBars: Int) {
        project.loopBars = loopBars
        saveProject()
    }
    
    // MARK: - Private Methods
    
    /// 观察音频引擎状态
    private func observeAudioEngine() {
        // 使用定时器定期更新状态
        Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.recordingState = self.audioEngine.recordingState
                self.playbackState = self.audioEngine.playbackState
                self.currentTime = self.audioEngine.currentTime
                self.recordingLevel = self.audioEngine.recordingLevel
                self.recordingDuration = self.audioEngine.recordingDuration
            }
            .store(in: &cancellables)
    }
    
    /// 设置生命周期观察者
    private func setupLifecycleObservers() {
        // 监听 App 进入后台
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleWillResignActive()
        }
        
        // 监听 App 进入前台
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleDidBecomeActive()
        }
        
        // 监听音频会话中断
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAudioInterruption(notification)
        }
    }
    
    /// 处理 App 进入后台
    private func handleWillResignActive() {
        print("[MainViewModel] App 进入后台")
        
        // 停止录音
        if recordingState == .recording {
            cancelRecording()
        }
        
        // 暂停播放（可选）
        if playbackState == .playing {
            pause()
        }
        
        // 停止节拍器
        if metronomeEnabled {
            metronome.stop()
        }
    }
    
    /// 处理 App 进入前台
    private func handleDidBecomeActive() {
        print("[MainViewModel] App 进入前台")
        
        // 恢复节拍器（如果之前开启）
        if metronomeEnabled {
            metronome.start(bpm: project.bpm, volume: 0.5)
        }
    }
    
    /// 处理音频会话中断
    private func handleAudioInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            print("[MainViewModel] 音频会话中断开始")
            // 暂停播放
            if playbackState == .playing {
                pause()
            }
            
        case .ended:
            print("[MainViewModel] 音频会话中断结束")
            // 可以选择自动恢复播放
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // 自动恢复播放（可选）
                }
            }
            
        @unknown default:
            break
        }
    }
    
    /// 更新所有轨道的播放状态
    private func updateAllTracksPlaybackState() {
        let hasSolo = project.hasSoloTracks
        
        for track in project.tracks {
            let shouldPlay = track.shouldPlay(hasSoloTracks: hasSolo)
            audioEngine.updateTrackMute(trackId: track.id, muted: !shouldPlay)
        }
    }
    
    /// 保存项目
    private func saveProject() {
        do {
            try repository.save(project)
            // 保存快照（用于撤销）
            undoManager.saveSnapshot(project)
        } catch {
            showError(LocalizedString.ViewModel.saveFailed(error.localizedDescription))
        }
    }
    
    /// 显示错误
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    
    /// 获取颜色十六进制值
    private func getColorHex(at index: Int) -> String {
        let colors = [
            "#EF4444", // 红色
            "#F59E0B", // 橙色
            "#10B981", // 绿色
            "#3B82F6", // 蓝色
            "#8B5CF6", // 紫色
            "#EC4899", // 粉色
            "#06B6D4", // 青色
            "#F97316", // 深橙色
        ]
        return colors[index % colors.count]
    }
}
