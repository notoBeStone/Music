//
//  AudioSettings.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation
import AVFoundation

/// 音频设置配置
struct AudioSettings: Codable {
    /// BPM（每分钟节拍数）
    var bpm: Int
    
    /// 循环长度（秒）
    var loopLength: Double
    
    /// 采样率
    var sampleRate: Double
    
    /// 音频通道数
    var channels: Int
    
    /// 位深度
    var bitDepth: Int
    
    /// 是否启用节拍器
    var metronomeEnabled: Bool
    
    /// 节拍器音量（0.0 - 1.0）
    var metronomeVolume: Float
    
    /// 播放速度（0.5 - 2.0）
    var playbackSpeed: Float
    
    /// 默认设置
    static var `default`: AudioSettings {
        AudioSettings(
            bpm: 120,
            loopLength: 8.0,
            sampleRate: 48000.0,
            channels: 2,
            bitDepth: 16,
            metronomeEnabled: true,
            metronomeVolume: 0.5,
            playbackSpeed: 1.0
        )
    }
    
    /// 获取 AVAudioFormat
    var audioFormat: AVAudioFormat? {
        return AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: sampleRate,
            channels: AVAudioChannelCount(channels),
            interleaved: true
        )
    }
    
    /// 计算循环长度对应的帧数
    var loopLengthInFrames: AVAudioFramePosition {
        return AVAudioFramePosition(loopLength * sampleRate)
    }
}

