//
//  ProjectModel.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation

/// 项目数据模型
struct ProjectModel: Identifiable, Codable, Hashable {
    /// 唯一标识符
    let id: UUID
    
    /// 项目名称
    var name: String
    
    /// BPM（每分钟节拍数，范围：60 ~ 200）
    var bpm: Int
    
    /// 循环小节数（例如 2 / 4 / 8）
    var loopBars: Int
    
    /// 音轨列表
    var tracks: [TrackModel]
    
    /// 创建时间
    let createdAt: Date
    
    /// 修改时间
    var modifiedAt: Date
    
    /// 初始化
    init(
        id: UUID = UUID(),
        name: String,
        bpm: Int = 120,
        loopBars: Int = 4,
        tracks: [TrackModel] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.bpm = max(60, min(200, bpm)) // 限制范围
        self.loopBars = loopBars
        self.tracks = tracks
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

// MARK: - ProjectModel Extensions

extension ProjectModel {
    /// 计算循环长度（秒）
    /// 公式：(小节数 × 4拍/小节 × 60秒/分钟) / BPM
    var loopLength: TimeInterval {
        return Double(loopBars * 4) * 60.0 / Double(bpm)
    }
    
    /// 音轨数量
    var trackCount: Int {
        return tracks.count
    }
    
    /// 是否有独奏轨道
    var hasSoloTracks: Bool {
        return tracks.contains { $0.solo }
    }
    
    /// 是否可以添加新轨道（MVP 最多 4 轨）
    var canAddTrack: Bool {
        return tracks.count < 4
    }
    
    /// 添加音轨
    mutating func addTrack(_ track: TrackModel) {
        guard canAddTrack else { return }
        tracks.append(track)
        modifiedAt = Date()
    }
    
    /// 删除音轨（通过 ID）
    mutating func removeTrack(id: UUID) {
        tracks.removeAll { $0.id == id }
        modifiedAt = Date()
    }
    
    /// 更新音轨
    mutating func updateTrack(_ track: TrackModel) {
        if let index = tracks.firstIndex(where: { $0.id == track.id }) {
            tracks[index] = track
            modifiedAt = Date()
        }
    }
    
    /// 格式化时长显示
    func formattedDuration() -> String {
        let minutes = Int(loopLength) / 60
        let seconds = Int(loopLength) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
