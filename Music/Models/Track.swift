//
//  Track.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation

/// 音轨数据模型
struct Track: Identifiable, Codable {
    /// 唯一标识符
    let id: UUID
    
    /// 音轨名称
    var name: String
    
    /// 音频文件相对路径
    var filePath: String
    
    /// 音量（0.0 - 1.0）
    var volume: Float
    
    /// 声像（-1.0 左 到 1.0 右）
    var pan: Float
    
    /// 是否静音
    var isMuted: Bool
    
    /// 是否独奏
    var isSolo: Bool
    
    /// 音轨颜色索引（用于从 ColorTheme 获取颜色）
    var colorIndex: Int
    
    /// 创建时间
    let createdAt: Date
    
    /// 修改时间
    var modifiedAt: Date
    
    /// 初始化
    init(
        id: UUID = UUID(),
        name: String,
        filePath: String,
        volume: Float = 0.8,
        pan: Float = 0.0,
        isMuted: Bool = false,
        isSolo: Bool = false,
        colorIndex: Int = 0,
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.filePath = filePath
        self.volume = volume
        self.pan = pan
        self.isMuted = isMuted
        self.isSolo = isSolo
        self.colorIndex = colorIndex
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

// MARK: - Track Extensions

extension Track {
    /// 获取完整的文件URL
    func fullURL(in projectDirectory: URL) -> URL {
        return projectDirectory.appendingPathComponent(filePath)
    }
    
    /// 是否应该播放（考虑静音和独奏状态）
    func shouldPlay(hasSoloTracks: Bool) -> Bool {
        if isMuted {
            return false
        }
        if hasSoloTracks {
            return isSolo
        }
        return true
    }
}

