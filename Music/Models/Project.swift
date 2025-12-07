//
//  Project.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation

/// 项目数据模型
struct Project: Identifiable, Codable {
    /// 唯一标识符
    let id: UUID
    
    /// 项目名称
    var name: String
    
    /// 音轨列表
    var tracks: [Track]
    
    /// 音频设置
    var audioSettings: AudioSettings
    
    /// 创建时间
    let createdAt: Date
    
    /// 修改时间
    var modifiedAt: Date
    
    /// 初始化
    init(
        id: UUID = UUID(),
        name: String,
        tracks: [Track] = [],
        audioSettings: AudioSettings = .default,
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.tracks = tracks
        self.audioSettings = audioSettings
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

// MARK: - Project Extensions

extension Project {
    /// 项目总时长（基于循环长度）
    var duration: TimeInterval {
        return audioSettings.loopLength
    }
    
    /// 音轨数量
    var trackCount: Int {
        return tracks.count
    }
    
    /// 是否有独奏轨道
    var hasSoloTracks: Bool {
        return tracks.contains { $0.isSolo }
    }
    
    /// 可以添加新轨道（最多4轨，MVP版本）
    var canAddTrack: Bool {
        return tracks.count < 4
    }
    
    /// 添加新轨道
    mutating func addTrack(_ track: Track) {
        guard canAddTrack else { return }
        tracks.append(track)
        modifiedAt = Date()
    }
    
    /// 删除轨道
    mutating func removeTrack(at index: Int) {
        guard index >= 0 && index < tracks.count else { return }
        tracks.remove(at: index)
        modifiedAt = Date()
    }
    
    /// 删除轨道（通过ID）
    mutating func removeTrack(id: UUID) {
        tracks.removeAll { $0.id == id }
        modifiedAt = Date()
    }
    
    /// 更新轨道
    mutating func updateTrack(_ track: Track) {
        if let index = tracks.firstIndex(where: { $0.id == track.id }) {
            tracks[index] = track
            modifiedAt = Date()
        }
    }
    
    /// 格式化时长显示
    func formattedDuration() -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

