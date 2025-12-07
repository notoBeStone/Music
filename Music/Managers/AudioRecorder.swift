//
//  AudioRecorder.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation
import AVFoundation

/// 音频录音错误
enum AudioRecorderError: LocalizedError {
    case recordingFailed
    case permissionDenied
    case audioSessionSetupFailed
    case invalidSettings
    
    var errorDescription: String? {
        switch self {
        case .recordingFailed:
            return "录音失败，请重试"
        case .permissionDenied:
            return "需要麦克风权限才能录音"
        case .audioSessionSetupFailed:
            return "音频系统初始化失败"
        case .invalidSettings:
            return "音频设置无效"
        }
    }
}

/// 音频录音管理器
final class AudioRecorder: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    /// 当前录音电平（0.0 - 1.0）
    @Published var currentLevel: Float = 0.0
    
    /// 录音时长
    @Published var recordingDuration: TimeInterval = 0.0
    
    /// 是否正在录音
    @Published var isRecording: Bool = false
    
    // MARK: - Private Properties
    
    private var audioRecorder: AVAudioRecorder?
    private var levelTimer: Timer?
    private var durationTimer: Timer?
    private let audioSettings: AudioSettings
    private let outputURL: URL
    
    // MARK: - Initialization
    
    init(audioSettings: AudioSettings, outputURL: URL) {
        self.audioSettings = audioSettings
        self.outputURL = outputURL
        super.init()
    }
    
    deinit {
        stop()
    }
    
    // MARK: - Public Methods
    
    /// 请求麦克风权限
    func requestPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    /// 检查麦克风权限
    func checkPermission() -> Bool {
        let status = AVAudioSession.sharedInstance().recordPermission
        return status == .granted
    }
    
    /// 准备录音
    func prepare() throws {
        // 配置音频会话
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setActive(true)
        
        // 配置录音设置
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: audioSettings.sampleRate,
            AVNumberOfChannelsKey: audioSettings.channels,
            AVLinearPCMBitDepthKey: audioSettings.bitDepth,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // 创建录音器
        audioRecorder = try AVAudioRecorder(url: outputURL, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()
    }
    
    /// 开始录音
    func start() throws {
        guard checkPermission() else {
            throw AudioRecorderError.permissionDenied
        }
        
        guard let recorder = audioRecorder else {
            try prepare()
            guard let recorder = audioRecorder else {
                throw AudioRecorderError.recordingFailed
            }
            
            recorder.record()
            isRecording = true
            startMonitoring()
            return
        }
        
        recorder.record()
        isRecording = true
        startMonitoring()
    }
    
    /// 暂停录音
    func pause() {
        audioRecorder?.pause()
        isRecording = false
        stopMonitoring()
    }
    
    /// 恢复录音
    func resume() {
        audioRecorder?.record()
        isRecording = true
        startMonitoring()
    }
    
    /// 停止录音
    func stop() {
        audioRecorder?.stop()
        isRecording = false
        stopMonitoring()
        
        // 重置状态
        currentLevel = 0.0
    }
    
    /// 取消录音并删除文件
    func cancel() {
        stop()
        audioRecorder?.deleteRecording()
        audioRecorder = nil
    }
    
    // MARK: - Private Methods
    
    /// 开始监听录音电平和时长
    private func startMonitoring() {
        // 电平监听（每秒更新 30 次）
        levelTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder else { return }
            
            recorder.updateMeters()
            let averagePower = recorder.averagePower(forChannel: 0)
            
            // 转换为线性值（0.0 - 1.0）
            let normalizedLevel = self.normalizedPowerLevel(from: averagePower)
            
            DispatchQueue.main.async {
                self.currentLevel = normalizedLevel
            }
        }
        
        // 时长监听（每秒更新一次）
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder else { return }
            
            DispatchQueue.main.async {
                self.recordingDuration = recorder.currentTime
            }
        }
    }
    
    /// 停止监听
    private func stopMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
        
        durationTimer?.invalidate()
        durationTimer = nil
    }
    
    /// 将分贝值转换为归一化的线性值
    private func normalizedPowerLevel(from decibels: Float) -> Float {
        // 分贝范围通常是 -160 dB（静音）到 0 dB（最大）
        // 转换为 0.0 到 1.0 的线性值
        let minDb: Float = -60.0
        let maxDb: Float = 0.0
        
        let clampedDb = max(minDb, min(maxDb, decibels))
        let normalized = (clampedDb - minDb) / (maxDb - minDb)
        
        return normalized
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isRecording = false
            self?.stopMonitoring()
        }
        
        if flag {
            print("[AudioRecorder] 录音完成：\(outputURL.lastPathComponent)")
        } else {
            print("[AudioRecorder] 录音失败")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.isRecording = false
            self?.stopMonitoring()
        }
        
        if let error = error {
            print("[AudioRecorder] 录音编码错误：\(error.localizedDescription)")
        }
    }
}

