//
//  AudioEngineManager.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation
import AVFoundation
import Combine

/// 音频引擎错误
enum AudioEngineError: LocalizedError {
    case engineNotStarted
    case recordingFailed
    case playbackFailed
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .engineNotStarted:
            return LocalizedString.AudioEngine.notStarted
        case .recordingFailed:
            return LocalizedString.AudioEngine.recordingFailed
        case .playbackFailed:
            return LocalizedString.AudioEngine.playbackFailed
        case .permissionDenied:
            return LocalizedString.AudioEngine.permissionDenied
        }
    }
}

/// 音频引擎管理器（统一管理录音和播放）
@MainActor
final class AudioEngineManager: ObservableObject {
    // MARK: - Singleton
    
    static let shared = AudioEngineManager()
    
    // MARK: - Published Properties
    
    /// 录音状态
    @Published var recordingState: RecordingState = .idle
    
    /// 播放状态
    @Published var playbackState: PlaybackState = .stopped
    
    /// 当前播放位置（秒）
    @Published var currentTime: TimeInterval = 0.0
    
    /// 录音电平（0.0 ~ 1.0）
    @Published var recordingLevel: Float = 0.0
    
    /// 录音时长（秒）
    @Published var recordingDuration: TimeInterval = 0.0
    
    // MARK: - Configuration Properties
    
    /// BPM（每分钟节拍数）
    var bpm: Int = 120
    
    /// 循环小节数
    var loopBars: Int = 4
    
    /// 采样率
    let sampleRate: Double = 48000.0
    
    // MARK: - Private Properties
    
    private let engine: AVAudioEngine
    private var currentProject: ProjectModel?
    
    // 播放相关
    private var playerNodes: [UUID: AVAudioPlayerNode] = [:]
    private var audioFiles: [UUID: AVAudioFile] = [:]
    private var playbackStartTime: TimeInterval = 0
    private var playbackTimer: Timer?
    
    // 录音相关
    private var audioRecorder: AVAudioRecorder?
    private var recordingTrackId: UUID?
    private var recordingOutputURL: URL?
    private var recordingTimer: Timer?
    private var recordingCompletion: ((Bool) -> Void)?
    
    // 循环进度回调
    var onLoopProgress: ((UUID, Double) -> Void)?
    
    // MARK: - Initialization
    
    private init() {
        self.engine = AVAudioEngine()
        setupAudioSession()
    }
    
    deinit {
        // deinit 不能调用 @MainActor 方法，直接停止引擎
        if engine.isRunning {
            engine.stop()
        }
    }
    
    // MARK: - Audio Session Setup
    
    /// 配置音频会话（初始化时调用）
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setPreferredSampleRate(sampleRate)
            try audioSession.setPreferredIOBufferDuration(256.0 / sampleRate) // 低延迟：256 samples
            try audioSession.setActive(true)
            
            print("[AudioEngineManager] 音频会话配置成功")
        } catch {
            print("[AudioEngineManager] 音频会话配置失败：\(error.localizedDescription)")
        }
    }
    
    /// 配置音频会话用于录音（录音前调用）
    private func setupAudioSessionForRecording() throws {
        let audioSession = AVAudioSession.sharedInstance()
        
        // 配置音频会话为录音模式
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setPreferredSampleRate(sampleRate)
        try audioSession.setPreferredIOBufferDuration(256.0 / sampleRate)
        
        // 激活音频会话
        try audioSession.setActive(true, options: [])
        
        print("[AudioEngineManager] 录音音频会话配置成功")
    }
    
    // MARK: - Engine Control
    
    /// 启动音频引擎（仅用于播放）
    func startEngine() throws {
        guard !engine.isRunning else {
            print("[AudioEngineManager] 引擎已在运行")
            return
        }
        
        print("[AudioEngineManager] 准备启动音频引擎...")
        
        // 确保音频会话已激活
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true, options: [])
            print("[AudioEngineManager] 音频会话已激活")
        } catch {
            print("[AudioEngineManager] 激活音频会话失败：\(error.localizedDescription)")
            throw error
        }
        
        // 准备引擎（这会初始化音频节点）
        do {
            engine.prepare()
            print("[AudioEngineManager] 引擎准备完成")
        } catch {
            print("[AudioEngineManager] 引擎准备失败：\(error.localizedDescription)")
            throw error
        }
        
        // 启动引擎
        do {
            try engine.start()
            print("[AudioEngineManager] 音频引擎已启动")
        } catch {
            print("[AudioEngineManager] 引擎启动失败：\(error.localizedDescription)")
            throw error
        }
    }
    
    /// 停止音频引擎
    func stopEngine() {
        guard engine.isRunning else { return }
        
        engine.stop()
        print("[AudioEngineManager] 音频引擎已停止")
    }
    
    // MARK: - Playback Control
    
    /// 开始播放
    func startPlayback(project: ProjectModel) {
        guard playbackState != .playing else { return }
        
        self.currentProject = project
        self.bpm = project.bpm
        self.loopBars = project.loopBars
        
        do {
            // 先加载所有音轨（连接节点到引擎）
            try loadAllTracks(project: project)
            
            // 检查是否有音轨可播放
            guard !playerNodes.isEmpty else {
                print("[AudioEngineManager] 没有可播放的音轨")
                return
            }
            
            // 再启动引擎
            try startEngine()
            
            // 开始播放所有音轨
            playAllTracks()
            
            playbackState = .playing
            playbackStartTime = CACurrentMediaTime()
            startPlaybackTimer()
            
            print("[AudioEngineManager] 开始播放 (\(playerNodes.count) 个音轨)")
        } catch {
            print("[AudioEngineManager] 播放失败：\(error.localizedDescription)")
        }
    }
    
    /// 暂停播放
    func pausePlayback() {
        guard playbackState == .playing else { return }
        
        for playerNode in playerNodes.values {
            playerNode.pause()
        }
        
        playbackState = .paused
        stopPlaybackTimer()
        
        print("[AudioEngineManager] 暂停播放")
    }
    
    /// 停止播放
    func stopPlayback() {
        // 停止所有播放器节点
        for playerNode in playerNodes.values {
            playerNode.stop()
        }
        
        // 停止引擎
        stopEngine()
        
        // 卸载所有音轨
        unloadAllTracks()
        
        playbackState = .stopped
        currentTime = 0.0
        stopPlaybackTimer()
        
        print("[AudioEngineManager] 停止播放")
    }
    
    // MARK: - Recording Control
    
    /// 开始录音
    func startRecording(to fileURL: URL, forTrackId trackId: UUID, completion: @escaping (Bool) -> Void) async throws {
        guard recordingState == .idle else {
            throw AudioEngineError.recordingFailed
        }
        
        // 请求麦克风权限
        let hasPermission = await requestMicrophonePermission()
        guard hasPermission else {
            throw AudioEngineError.permissionDenied
        }
        
        // 重新配置音频会话（确保录音模式）
        try setupAudioSessionForRecording()
        
        // 配置录音设置
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // 创建录音器
        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        
        // 更新状态
        recordingState = .recording
        recordingTrackId = trackId
        recordingOutputURL = fileURL
        recordingCompletion = completion
        recordingDuration = 0.0
        recordingLevel = 0.0
        
        // 开始监听录音
        startRecordingTimer()
        
        print("[AudioEngineManager] 开始录音：\(trackId)")
    }
    
    /// 停止录音
    func stopRecording(forTrackId trackId: UUID) {
        guard recordingState == .recording, recordingTrackId == trackId else { return }
        
        audioRecorder?.stop()
        audioRecorder = nil
        stopRecordingTimer()
        
        recordingState = .idle
        recordingLevel = 0.0
        
        // 调用完成回调
        recordingCompletion?(true)
        recordingCompletion = nil
        
        print("[AudioEngineManager] 停止录音：\(trackId)")
    }
    
    /// 取消录音
    func cancelRecording() {
        guard recordingState == .recording else { return }
        
        audioRecorder?.stop()
        audioRecorder?.deleteRecording()
        audioRecorder = nil
        stopRecordingTimer()
        
        recordingState = .idle
        recordingLevel = 0.0
        
        recordingCompletion?(false)
        recordingCompletion = nil
        
        print("[AudioEngineManager] 取消录音")
    }
    
    // MARK: - Track Control
    
    /// 更新音轨音量
    func updateTrackVolume(trackId: UUID, volume: Float) {
        playerNodes[trackId]?.volume = volume
    }
    
    /// 更新音轨静音状态
    func updateTrackMute(trackId: UUID, muted: Bool) {
        guard let playerNode = playerNodes[trackId] else { return }
        
        if muted {
            playerNode.volume = 0.0
        } else {
            // 从 project 中获取原始音量
            if let track = currentProject?.tracks.first(where: { $0.id == trackId }) {
                playerNode.volume = track.volume
            }
        }
    }
    
    // MARK: - Private Methods - Playback
    
    /// 加载所有音轨
    private func loadAllTracks(project: ProjectModel) throws {
        // 清理旧的播放器
        unloadAllTracks()
        
        let projectDir = FileManager.projectDirectory(for: project.id)
        
        print("[AudioEngineManager] 开始加载音轨，项目目录：\(projectDir.path)")
        
        for track in project.tracks where track.hasAudio {
            guard let filePath = track.filePath else { continue }
            
            let fileURL = projectDir.appendingPathComponent(filePath)
            
            // 检查文件是否存在
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("[AudioEngineManager] 音频文件不存在：\(filePath)")
                continue
            }
            
            do {
                // 加载音频文件
                let audioFile = try AVAudioFile(forReading: fileURL)
                audioFiles[track.id] = audioFile
                
                // 创建播放器节点
                let playerNode = AVAudioPlayerNode()
                playerNode.volume = track.muted ? 0.0 : track.volume
                playerNode.pan = track.pan
                
                // 连接到引擎
                engine.attach(playerNode)
                
                // 使用音频文件的格式连接节点
                let format = audioFile.processingFormat
                print("[AudioEngineManager] 连接音轨：\(track.name)，格式：\(format.sampleRate)Hz, \(format.channelCount)声道")
                
                engine.connect(playerNode, to: engine.mainMixerNode, format: format)
                
                playerNodes[track.id] = playerNode
                
                print("[AudioEngineManager] 加载音轨成功：\(track.name)")
            } catch {
                print("[AudioEngineManager] 加载音轨失败：\(track.name)，错误：\(error.localizedDescription)")
                throw error
            }
        }
        
        print("[AudioEngineManager] 共加载 \(playerNodes.count) 个音轨")
    }
    
    /// 卸载所有音轨
    private func unloadAllTracks() {
        for playerNode in playerNodes.values {
            playerNode.stop()
            engine.detach(playerNode)
        }
        
        playerNodes.removeAll()
        audioFiles.removeAll()
    }
    
    /// 播放所有音轨（循环播放）
    private func playAllTracks() {
        guard let project = currentProject else { return }
        let loopLength = project.loopLength
        
        for (trackId, playerNode) in playerNodes {
            guard let audioFile = audioFiles[trackId] else { continue }
            
            // 调度循环播放
            scheduleLoopPlayback(playerNode: playerNode, audioFile: audioFile, loopLength: loopLength)
            
            // 开始播放
            if !playerNode.isPlaying {
                playerNode.play()
            }
        }
    }
    
    /// 调度循环播放
    private func scheduleLoopPlayback(playerNode: AVAudioPlayerNode, audioFile: AVAudioFile, loopLength: TimeInterval) {
        let frameCount = AVAudioFrameCount(loopLength * sampleRate)
        let totalFrames = audioFile.length
        
        // 确保不超过文件长度
        let framesToPlay = min(frameCount, AVAudioFrameCount(totalFrames))
        
        // 调度播放
        playerNode.scheduleSegment(
            audioFile,
            startingFrame: 0,
            frameCount: framesToPlay,
            at: nil
        ) { [weak self] in
            // 播放完成后重新调度（实现循环）
            if self?.playbackState == .playing {
                self?.scheduleLoopPlayback(playerNode: playerNode, audioFile: audioFile, loopLength: loopLength)
            }
        }
    }
    
    /// 开始播放计时器
    private func startPlaybackTimer() {
        stopPlaybackTimer()
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self = self, self.playbackState == .playing else { return }
            
            let elapsed = CACurrentMediaTime() - self.playbackStartTime
            let loopLength = self.currentProject?.loopLength ?? 1.0
            self.currentTime = elapsed.truncatingRemainder(dividingBy: loopLength)
        }
    }
    
    /// 停止播放计时器
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    // MARK: - Private Methods - Recording
    
    /// 请求麦克风权限
    private func requestMicrophonePermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    /// 开始录音计时器
    private func startRecordingTimer() {
        stopRecordingTimer()
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self,
                  let recorder = self.audioRecorder,
                  self.recordingState == .recording else { return }
            
            // 更新电平
            recorder.updateMeters()
            let averagePower = recorder.averagePower(forChannel: 0)
            let normalizedLevel = self.normalizedPowerLevel(from: averagePower)
            
            Task { @MainActor in
                self.recordingLevel = normalizedLevel
                self.recordingDuration = recorder.currentTime
                
                // 检查是否达到循环长度
                if let project = self.currentProject {
                    if self.recordingDuration >= project.loopLength {
                        // 自动停止录音
                        if let trackId = self.recordingTrackId {
                            self.stopRecording(forTrackId: trackId)
                        }
                    }
                }
            }
        }
    }
    
    /// 停止录音计时器
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    /// 将分贝值转换为归一化的线性值（0.0 ~ 1.0）
    private func normalizedPowerLevel(from decibels: Float) -> Float {
        let minDb: Float = -60.0
        let maxDb: Float = 0.0
        
        let clampedDb = max(minDb, min(maxDb, decibels))
        let normalized = (clampedDb - minDb) / (maxDb - minDb)
        
        return normalized
    }
}
