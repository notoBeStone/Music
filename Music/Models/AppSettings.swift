//
//  AppSettings.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation

/// 应用全局设置
struct AppSettings: Codable {
    /// 上次打开的项目 ID
    var lastOpenedProjectId: UUID?
    
    /// 默认 BPM
    var defaultBPM: Int
    
    /// 默认循环小节数
    var defaultLoopBars: Int
    
    /// 初始化
    init(
        lastOpenedProjectId: UUID? = nil,
        defaultBPM: Int = 120,
        defaultLoopBars: Int = 4
    ) {
        self.lastOpenedProjectId = lastOpenedProjectId
        self.defaultBPM = defaultBPM
        self.defaultLoopBars = defaultLoopBars
    }
    
    /// 默认设置
    static var `default`: AppSettings {
        return AppSettings(
            lastOpenedProjectId: nil,
            defaultBPM: 120,
            defaultLoopBars: 4
        )
    }
}
