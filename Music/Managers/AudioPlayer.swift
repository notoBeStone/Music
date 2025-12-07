//
//  AudioPlayer.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation
import AVFoundation

/// 音频播放错误
enum AudioPlayerError: LocalizedError {
    case fileNotFound
    case playbackFailed
    case invalidAudioFile
    case engineNotStarted
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "音频文件不存在"
        case .playbackFailed:
            return "播放失败"
        case .invalidAudioFile:
            return "无效的音频文件"
        case .engineNotStarted:
            return "音频引擎未启动"
        }
    }
}

/// 单个音轨播放器
final class TrackPlayer {
    let track: Track
    let playerNode: AVAudioPlayerNode
    let audioFile: AVAudioFile
    
    var volume: Float {
        get { playerNode.volume }
        set { playerNode.volume = newValue }
    }
    
    var pan: Float {
        get { playerNode.pan }
        set { playerNode.pan = newValue }
    }
    
    init(track: Track, audioFile: AVAudioFile) {
        self.track = track
        self.audioFile = audioFile
        self.playerNode = AVAudioPlayerNode()
        
        // 初始化音量和声像
        self.playerNode.volume = track.volume
        self.playerNode.pan = track.pan
    }
}

/// 音频播放管理器（多轨同步播放）
final class AudioPlayer: ObservableObject {
    // MARK: - Published Properties
    
    /// 当前播放位置（秒）
    @Published var currentTime: TimeInterval = 0.0
    
    /// 是否正在播放
    @Published var isPlaying: Bool = false
    
    // MARK: - Private Properties
    
    private let engine: AVAudioEngine
    private var trackPlayers: [UUID: TrackPlayer] = [:]
    private var displayLink: CADisplayLink?
    private let loopLength: TimeInterval
    private var startTime: TimeInterval = 0
    private var pauseTime: TimeInterval = 0
    
    // MARK: - Initialization
    
    init(engine: AVAudioEngine, loopLength: TimeInterval) {
        self.engine = engine
        self.loopLength = loopLength
    }
    
    deinit {
        stop()
    }
    
    // MARK: - Public Methods
    
    /// 加载音轨
    func loadTrack(_ track: Track, fileURL: URL) throws {
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw AudioPlayerError.fileNotFound
        }
        
        // 加载音频文件
        let audioFile = try AVAudioFile(forReading: fileURL)
        
        // 创建音轨播放器
        let trackPlayer = TrackPlayer(track: track, audioFile: audioFile)
        
        // 连接到音频引擎
        engine.attach(trackPlayer.playerNode)
        engine.connect(
            trackPlayer.playerNode,
            to: engine.mainMixerNode,
            format: audioFile.processingFormat
        )
        
        // 存储播放器
        trackPlayers[track.id] = trackPlayer
        
        print("[AudioPlayer] 加载音轨：\(track.name)")
    }
    
    /// 卸载音轨
    func unloadTrack(_ trackId: UUID) {
        guard let trackPlayer = trackPlayers[trackId] else { return }
        
        // 停止播放
        trackPlayer.playerNode.stop()
        
        // 断开连接
        engine.detach(trackPlayer.playerNode)
        
        // 移除播放器
        trackPlayers.removeValue(forKey: trackId)
        
        print("[AudioPlayer] 卸载音轨：\(trackPlayer.track.name)")
    }
    
    /// 卸载所有音轨
    func unloadAllTracks() {
        let trackIds = Array(trackPlayers.keys)
        for trackId in trackIds {
            unloadTrack(trackId)
        }
    }
    
    /// 开始播放
    func play() throws {
        guard !trackPlayers.isEmpty else {
            print("[AudioPlayer] 没有可播放的音轨")
            return
        }
        
        // 确保引擎已启动
        if !engine.isRunning {
            try engine.start()
        }
        
        // 计算开始时间
        if pauseTime > 0 {
            startTime = CACurrentMediaTime() - pauseTime
        } else {
            startTime = CACurrentMediaTime()
        }
        
        // 调度所有音轨播放
        scheduleAllTracks()
        
        // 启动所有播放器
        for trackPlayer in trackPlayers.values {
            if !trackPlayer.playerNode.isPlaying {
                trackPlayer.playerNode.play()
            }
        }
        
        isPlaying = true
        startDisplayLink()
        
        print("[AudioPlayer] 开始播放 (\(trackPlayers.count) 个音轨)")
    }
    
    /// 暂停播放
    func pause() {
        for trackPlayer in trackPlayers.values {
            trackPlayer.playerNode.pause()
        }
        
        pauseTime = currentTime
        isPlaying = false
        stopDisplayLink()
        
        print("[AudioPlayer] 暂停播放")
    }
    
    /// 停止播放
    func stop() {
        for trackPlayer in trackPlayers.values {
            trackPlayer.playerNode.stop()
        }
        
        currentTime = 0.0
        startTime = 0.0
        pauseTime = 0.0
        isPlaying = false
        stopDisplayLink()
        
        print("[AudioPlayer] 停止播放")
    }
    
    /// 设置音轨音量
    func setVolume(_ volume: Float, for trackId: UUID) {
        trackPlayers[trackId]?.volume = volume
    }
    
    /// 设置音轨声像
    func setPan(_ pan: Float, for trackId: UUID) {
        trackPlayers[trackId]?.pan = pan
    }
    
    /// 设置音轨静音
    func setMuted(_ muted: Bool, for trackId: UUID) {
        trackPlayers[trackId]?.volume = muted ? 0.0 : (trackPlayers[trackId]?.track.volume ?? 0.8)
    }
    
    // MARK: - Private Methods
    
    /// 调度所有音轨播放（循环播放）
    private func scheduleAllTracks() {
        for trackPlayer in trackPlayers.values {
            scheduleTrack(trackPlayer)
        }
    }
    
    /// 调度单个音轨播放
    private func scheduleTrack(_ trackPlayer: TrackPlayer) {
        let audioFile = trackPlayer.audioFile
        
        // 计算当前应该从哪里开始播放
        let framePosition = AVAudioFramePosition(currentTime * audioFile.processingFormat.sampleRate)
        let frameLength = AVAudioFrameCount(audioFile.length - framePosition)
        
        // 调度播放（循环）
        trackPlayer.playerNode.scheduleSegment(
            audioFile,
            startingFrame: framePosition,
            frameCount: frameLength,
            at: nil
        ) { [weak self] in
            // 播放完成后，如果还在播放状态，重新调度
            if self?.isPlaying == true {
                self?.scheduleTrack(trackPlayer)
                trackPlayer.playerNode.play()
            }
        }
    }
    
    /// 启动显示链接（用于更新播放位置）
    private func startDisplayLink() {
        guard displayLink == nil else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(updatePlaybackPosition))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    /// 停止显示链接
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    /// 更新播放位置
    @objc private func updatePlaybackPosition() {
        let elapsed = CACurrentMediaTime() - startTime
        currentTime = elapsed.truncatingRemainder(dividingBy: loopLength)
    }
}

