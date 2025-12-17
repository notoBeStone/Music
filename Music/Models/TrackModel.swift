//
//  TrackModel.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation

/// 音轨来源类型
enum TrackSourceType: String, Codable {
    case mic      // 麦克风录音
    case drum     // 虚拟鼓组（后续）
    case keys     // 虚拟键盘（后续）
    case sample   // 采样（后续）
}

/// 音轨数据模型
struct TrackModel: Identifiable, Codable, Hashable {
    /// 唯一标识符
    let id: UUID
    
    /// 音轨名称
    var name: String
    
    /// 音频文件相对路径（例如："track_uuid.wav"，nil 表示还未录音）
    var filePath: String?
    
    /// 音量（0.0 ~ 1.0）
    var volume: Float
    
    /// 声像（-1.0 左 ~ 1.0 右，MVP 暂时固定为 0）
    var pan: Float
    
    /// 是否静音
    var muted: Bool
    
    /// 是否独奏（MVP 可不实现 solo 逻辑，后续扩展）
    var solo: Bool
    
    /// 音轨颜色（用字符串存颜色，例如 "#FFAA00"）
    var colorHex: String
    
    /// 来源类型
    var sourceType: TrackSourceType
    
    /// 初始化
    init(
        id: UUID = UUID(),
        name: String,
        filePath: String? = nil,
        volume: Float = 0.8,
        pan: Float = 0.0,
        muted: Bool = false,
        solo: Bool = false,
        colorHex: String,
        sourceType: TrackSourceType = .mic
    ) {
        self.id = id
        self.name = name
        self.filePath = filePath
        self.volume = volume
        self.pan = pan
        self.muted = muted
        self.solo = solo
        self.colorHex = colorHex
        self.sourceType = sourceType
    }
}

// MARK: - TrackModel Extensions

extension TrackModel {
    /// 是否已录音
    var hasAudio: Bool {
        return filePath != nil
    }
    
    /// 是否应该播放（考虑静音和独奏状态）
    func shouldPlay(hasSoloTracks: Bool) -> Bool {
        if muted {
            return false
        }
        if hasSoloTracks {
            return solo
        }
        return true
    }
}
