//
//  AudioEngineManager.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation
import AVFoundation

/// 音频引擎管理器（统一管理录音和播放）
@MainActor
final class AudioEngineManager: ObservableObject {
    // MARK: - Published Properties
    
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
    
    // MARK: - Private Properties
    
    private let engine: AVAudioEngine
    private var audioPlayer: AudioPlayer?
    private var audioRecorder: AudioRecorder?
    private let project: Project
    
    // MARK: - Initialization
    
    init(project: Project) {
        self.project = project
        self.engine = AVAudioEngine()
        
        setupAudioSession()
        setupAudioPlayer()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Setup Methods
    
    /// 配置音频会话
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setPreferredSampleRate(project.audioSettings.sampleRate)
            try audioSession.setPreferredIOBufferDuration(256.0 / project.audioSettings.sampleRate) // 低延迟
            try audioSession.setActive(true)
            
            print("[AudioEngineManager] 音频会话配置成功")
        } catch {
            print("[AudioEngineManager] 音频会话配置失败：\(error.localizedDescription)")
        }
    }
    
    /// 配置音频播放器
    private func setupAudioPlayer() {
        audioPlayer = AudioPlayer(engine: engine, loopLength: project.audioSettings.loopLength)
        
        // 加载所有音轨
        loadAllTracks()
    }
    
    /// 加载所有音轨
    private func loadAllTracks() {
        let projectDir = FileManager.projectDirectory(for: project.id)
        
        for track in project.tracks {
            let fileURL = track.fullURL(in: projectDir)
            
            do {
                try audioPlayer?.loadTrack(track, fileURL: fileURL)
            } catch {
                print("[AudioEngineManager] 加载音轨失败：\(track.name) - \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Recording Methods
    
    /// 开始录音
    func startRecording(for track: Track) async throws {
        guard recordingState == .idle else {
            print("[AudioEngineManager] 已在录音中")
            return
        }
        
        // 创建临时录音文件
        let tempURL = FileManager.temporaryRecordingURL
        
        // 创建录音器
        audioRecorder = AudioRecorder(audioSettings: project.audioSettings, outputURL: tempURL)
        
        // 请求权限
        let hasPermission = await audioRecorder?.requestPermission() ?? false
        guard hasPermission else {
            throw AudioRecorderError.permissionDenied
        }
        
        // 准备并开始录音
        try audioRecorder?.prepare()
        try audioRecorder?.start()
        
        recordingState = .recording
        
        // 监听录音状态
        observeRecordingState()
        
        print("[AudioEngineManager] 开始录音：\(track.name)")
    }
    
    /// 停止录音
    func stopRecording(for track: Track) async throws -> URL {
        guard recordingState == .recording else {
            throw AudioRecorderError.recordingFailed
        }
        
        audioRecorder?.stop()
        recordingState = .idle
        
        // 获取录音文件
        guard let tempURL = audioRecorder?.outputURL else {
            throw AudioRecorderError.recordingFailed
        }
        
        // 移动到项目目录
        let projectDir = FileManager.projectDirectory(for: project.id)
        let finalURL = FileManager.trackFileURL(for: project.id, trackId: track.id)
        
        // 如果文件已存在，先删除
        if FileManager.default.fileExists(atPath: finalURL.path) {
            try FileManager.default.removeItem(at: finalURL)
        }
        
        // 移动文件
        try FileManager.default.moveItem(at: tempURL, to: finalURL)
        
        // 加载新音轨
        try audioPlayer?.loadTrack(track, fileURL: finalURL)
        
        audioRecorder = nil
        
        print("[AudioEngineManager] 录音完成：\(track.name)")
        
        return finalURL
    }
    
    /// 取消录音
    func cancelRecording() {
        audioRecorder?.cancel()
        audioRecorder = nil
        recordingState = .idle
        
        print("[AudioEngineManager] 取消录音")
    }
    
    /// 监听录音状态
    private func observeRecordingState() {
        Task { @MainActor in
            while recordingState == .recording {
                recordingLevel = audioRecorder?.currentLevel ?? 0.0
                recordingDuration = audioRecorder?.recordingDuration ?? 0.0
                
                // 检查是否达到循环长度
                if recordingDuration >= project.audioSettings.loopLength {
                    // 自动停止录音（达到循环长度）
                    audioRecorder?.stop()
                    recordingState = .idle
                    break
                }
                
                try? await Task.sleep(nanoseconds: 33_000_000) // ~30fps
            }
        }
    }
    
    // MARK: - Playback Methods
    
    /// 开始播放
    func play() throws {
        guard playbackState != .playing else { return }
        
        try audioPlayer?.play()
        playbackState = .playing
        
        // 监听播放状态
        observePlaybackState()
        
        print("[AudioEngineManager] 开始播放")
    }
    
    /// 暂停播放
    func pause() {
        guard playbackState == .playing else { return }
        
        audioPlayer?.pause()
        playbackState = .paused
        
        print("[AudioEngineManager] 暂停播放")
    }
    
    /// 停止播放
    func stop() {
        audioPlayer?.stop()
        playbackState = .stopped
        currentTime = 0.0
        
        print("[AudioEngineManager] 停止播放")
    }
    
    /// 监听播放状态
    private func observePlaybackState() {
        Task { @MainActor in
            while playbackState == .playing {
                currentTime = audioPlayer?.currentTime ?? 0.0
                try? await Task.sleep(nanoseconds: 16_000_000) // ~60fps
            }
        }
    }
    
    // MARK: - Track Control Methods
    
    /// 设置音轨音量
    func setTrackVolume(_ volume: Float, for trackId: UUID) {
        audioPlayer?.setVolume(volume, for: trackId)
    }
    
    /// 设置音轨声像
    func setTrackPan(_ pan: Float, for trackId: UUID) {
        audioPlayer?.setPan(pan, for: trackId)
    }
    
    /// 设置音轨静音
    func setTrackMuted(_ muted: Bool, for trackId: UUID) {
        audioPlayer?.setMuted(muted, for: trackId)
    }
    
    /// 删除音轨
    func removeTrack(_ trackId: UUID) {
        audioPlayer?.unloadTrack(trackId)
        
        // 删除音频文件
        let fileURL = FileManager.trackFileURL(for: project.id, trackId: trackId)
        try? FileManager.default.removeItem(at: fileURL)
        
        print("[AudioEngineManager] 删除音轨")
    }
    
    /// 重新加载音轨
    func reloadTrack(_ track: Track) throws {
        let projectDir = FileManager.projectDirectory(for: project.id)
        let fileURL = track.fullURL(in: projectDir)
        
        // 先卸载旧的
        audioPlayer?.unloadTrack(track.id)
        
        // 重新加载
        try audioPlayer?.loadTrack(track, fileURL: fileURL)
    }
    
    // MARK: - Cleanup
    
    private func cleanup() {
        stop()
        audioRecorder?.cancel()
        audioPlayer?.unloadAllTracks()
        
        if engine.isRunning {
            engine.stop()
        }
    }
}

