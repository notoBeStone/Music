//
//  MetronomeManager.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation
import AVFoundation

/// 节拍器管理器
@MainActor
final class MetronomeManager {
    // MARK: - Singleton
    
    static let shared = MetronomeManager()
    
    // MARK: - Private Properties
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var clickBuffer: AVAudioPCMBuffer?
    private var isPlaying: Bool = false
    private var bpm: Int = 120
    private var volume: Float = 0.5
    private var timer: Timer?
    
    private let sampleRate: Double = 48000.0
    
    // MARK: - Initialization
    
    private init() {
        setupAudioEngine()
        generateClickSound()
    }
    
    deinit {
        // deinit 不能调用 @MainActor 方法，直接清理资源
        timer?.invalidate()
        playerNode?.stop()
        audioEngine?.stop()
    }
    
    // MARK: - Public Methods
    
    /// 开始节拍器
    func start(bpm: Int, volume: Float = 0.5) {
        guard !isPlaying else { return }
        
        self.bpm = bpm
        self.volume = volume
        
        // 启动音频引擎
        do {
            try audioEngine?.start()
        } catch {
            print("[MetronomeManager] 启动音频引擎失败：\(error.localizedDescription)")
            return
        }
        
        isPlaying = true
        
        // 计算每拍间隔（秒）
        let interval = 60.0 / Double(bpm)
        
        // 启动定时器
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playClick()
        }
        
        // 立即播放第一拍
        playClick()
        
        print("[MetronomeManager] 节拍器已启动 (BPM: \(bpm))")
    }
    
    /// 停止节拍器
    func stop() {
        guard isPlaying else { return }
        
        timer?.invalidate()
        timer = nil
        
        playerNode?.stop()
        audioEngine?.stop()
        
        isPlaying = false
        
        print("[MetronomeManager] 节拍器已停止")
    }
    
    /// 更新音量
    func setVolume(_ volume: Float) {
        self.volume = volume
        playerNode?.volume = volume
    }
    
    // MARK: - Private Methods
    
    /// 配置音频引擎
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        guard let engine = audioEngine, let player = playerNode else { return }
        
        // 创建音频格式
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 2,
            interleaved: false
        )
        
        // 连接节点
        engine.attach(player)
        if let format = format {
            engine.connect(player, to: engine.mainMixerNode, format: format)
        }
        
        player.volume = volume
    }
    
    /// 生成节拍音效（使用正弦波）
    private func generateClickSound() {
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 2,
            interleaved: false
        )
        
        guard let format = format else { return }
        
        // 生成一个短促的正弦波声音（50ms）
        let duration: Float = 0.05 // 50毫秒
        let frameCount = AVAudioFrameCount(Float(sampleRate) * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
        }
        
        buffer.frameLength = frameCount
        
        // 正弦波频率（1000 Hz）
        let frequency: Float = 1000.0
        let amplitude: Float = 0.5
        
        // 生成正弦波数据
        guard let leftChannel = buffer.floatChannelData?[0],
              let rightChannel = buffer.floatChannelData?[1] else {
            return
        }
        
        for frame in 0..<Int(frameCount) {
            let time = Float(frame) / Float(sampleRate)
            
            // 正弦波值
            let sineValue = amplitude * sin(2.0 * .pi * frequency * time)
            
            // 包络（防止爆音，使用淡入淡出）
            let envelope: Float
            let fadeFrames = Int(Float(frameCount) * 0.1) // 10% 淡入淡出
            
            if frame < fadeFrames {
                // 淡入
                envelope = Float(frame) / Float(fadeFrames)
            } else if frame > Int(frameCount) - fadeFrames {
                // 淡出
                envelope = Float(Int(frameCount) - frame) / Float(fadeFrames)
            } else {
                envelope = 1.0
            }
            
            let finalValue = sineValue * envelope
            
            leftChannel[frame] = finalValue
            rightChannel[frame] = finalValue
        }
        
        clickBuffer = buffer
    }
    
    /// 播放节拍音
    private func playClick() {
        guard let buffer = clickBuffer, let player = playerNode, isPlaying else {
            return
        }
        
        // 调度播放
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        
        // 如果播放器未运行，启动它
        if !player.isPlaying {
            player.play()
        }
    }
}
