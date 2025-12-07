//
//  RecordingViewModel.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation
import SwiftUI

/// 录音编辑视图模型
@MainActor
final class RecordingViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// 当前项目
    @Published var project: Project
    
    /// 录音状态
    @Published var recordingState: RecordingState = .idle
    
    /// 播放状态
    @Published var playbackState: PlaybackState = .stopped
    
    /// 当前播放位置
    @Published var currentTime: TimeInterval = 0.0
    
    /// 录音电平
    @Published var recordingLevel: Float = 0.0
    
    /// 是否启用节拍器
    @Published var metronomeEnabled: Bool
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 是否显示错误提示
    @Published var showingError = false
    
    /// 准备录音的音轨
    @Published var trackToRecord: Track?
    
    // MARK: - Private Properties
    
    private let audioEngine: AudioEngineManager
    private let projectManager: ProjectManager
    
    // MARK: - Computed Properties
    
    /// 播放进度（0.0 - 1.0）
    var playbackProgress: Double {
        guard project.audioSettings.loopLength > 0 else { return 0 }
        return currentTime / project.audioSettings.loopLength
    }
    
    /// 格式化当前时间
    var formattedCurrentTime: String {
        formatTime(currentTime)
    }
    
    /// 格式化总时长
    var formattedDuration: String {
        formatTime(project.audioSettings.loopLength)
    }
    
    /// 是否可以添加音轨
    var canAddTrack: Bool {
        return project.canAddTrack
    }
    
    /// 是否有音轨
    var hasTracks: Bool {
        return !project.tracks.isEmpty
    }
    
    // MARK: - Initialization
    
    init(project: Project, projectManager: ProjectManager) {
        self.project = project
        self.projectManager = projectManager
        self.audioEngine = AudioEngineManager(project: project)
        self.metronomeEnabled = project.audioSettings.metronomeEnabled
        
        observeAudioEngine()
    }
    
    // MARK: - Playback Control
    
    /// 播放/暂停
    func togglePlayback() {
        switch playbackState {
        case .stopped:
            play()
        case .playing:
            pause()
        case .paused:
            play()
        }
    }
    
    /// 播放
    func play() {
        do {
            try audioEngine.play()
        } catch {
            showError("播放失败：\(error.localizedDescription)")
        }
    }
    
    /// 暂停
    func pause() {
        audioEngine.pause()
    }
    
    /// 停止
    func stop() {
        audioEngine.stop()
    }
    
    // MARK: - Recording Control
    
    /// 开始录音
    func startRecording() {
        guard canAddTrack else {
            showError("已达到最大音轨数量（4轨）")
            return
        }
        
        // 创建新音轨
        let trackNumber = project.tracks.count + 1
        let newTrack = Track(
            name: "音轨 \(trackNumber)",
            filePath: "\(UUID().uuidString).wav",
            colorIndex: project.tracks.count % ColorTheme.trackColors.count
        )
        
        trackToRecord = newTrack
        
        Task {
            do {
                // 如果有其他音轨，先播放它们
                if hasTracks && playbackState != .playing {
                    try audioEngine.play()
                }
                
                // 开始录音
                try await audioEngine.startRecording(for: newTrack)
                
            } catch {
                await MainActor.run {
                    showError("录音失败：\(error.localizedDescription)")
                    trackToRecord = nil
                }
            }
        }
    }
    
    /// 停止录音
    func stopRecording() {
        guard let track = trackToRecord else { return }
        
        Task {
            do {
                _ = try await audioEngine.stopRecording(for: track)
                
                // 添加到项目
                await MainActor.run {
                    project.addTrack(track)
                    saveProject()
                    trackToRecord = nil
                }
                
            } catch {
                await MainActor.run {
                    showError("停止录音失败：\(error.localizedDescription)")
                    trackToRecord = nil
                }
            }
        }
    }
    
    /// 取消录音
    func cancelRecording() {
        audioEngine.cancelRecording()
        trackToRecord = nil
    }
    
    // MARK: - Track Control
    
    /// 更新音轨音量
    func updateTrackVolume(_ track: Track, volume: Float) {
        audioEngine.setTrackVolume(volume, for: track.id)
        
        // 更新项目数据
        var updatedTrack = track
        updatedTrack.volume = volume
        project.updateTrack(updatedTrack)
        saveProject()
    }
    
    /// 切换音轨静音
    func toggleTrackMute(_ track: Track) {
        let newMutedState = !track.isMuted
        audioEngine.setTrackMuted(newMutedState, for: track.id)
        
        // 更新项目数据
        var updatedTrack = track
        updatedTrack.isMuted = newMutedState
        project.updateTrack(updatedTrack)
        saveProject()
    }
    
    /// 切换音轨独奏
    func toggleTrackSolo(_ track: Track) {
        var updatedTrack = track
        updatedTrack.isSolo = !track.isSolo
        project.updateTrack(updatedTrack)
        saveProject()
        
        // 更新所有音轨的播放状态
        updateAllTracksPlaybackState()
    }
    
    /// 删除音轨
    func deleteTrack(_ track: Track) {
        audioEngine.removeTrack(track.id)
        project.removeTrack(id: track.id)
        saveProject()
    }
    
    /// 重命名音轨
    func renameTrack(_ track: Track, newName: String) {
        var updatedTrack = track
        updatedTrack.name = newName
        project.updateTrack(updatedTrack)
        saveProject()
    }
    
    // MARK: - Settings Control
    
    /// 切换节拍器
    func toggleMetronome() {
        metronomeEnabled.toggle()
        project.audioSettings.metronomeEnabled = metronomeEnabled
        saveProject()
    }
    
    /// 更新 BPM
    func updateBPM(_ bpm: Int) {
        project.audioSettings.bpm = bpm
        saveProject()
    }
    
    // MARK: - Private Methods
    
    /// 观察音频引擎状态
    private func observeAudioEngine() {
        Task {
            while !Task.isCancelled {
                await MainActor.run {
                    self.recordingState = audioEngine.recordingState
                    self.playbackState = audioEngine.playbackState
                    self.currentTime = audioEngine.currentTime
                    self.recordingLevel = audioEngine.recordingLevel
                }
                
                try? await Task.sleep(nanoseconds: 16_000_000) // ~60fps
            }
        }
    }
    
    /// 更新所有音轨的播放状态
    private func updateAllTracksPlaybackState() {
        let hasSolo = project.hasSoloTracks
        
        for track in project.tracks {
            let shouldPlay = track.shouldPlay(hasSoloTracks: hasSolo)
            audioEngine.setTrackMuted(!shouldPlay, for: track.id)
        }
    }
    
    /// 保存项目
    private func saveProject() {
        do {
            try projectManager.saveProject(project)
        } catch {
            showError("保存项目失败：\(error.localizedDescription)")
        }
    }
    
    /// 显示错误信息
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    
    /// 格式化时间
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

