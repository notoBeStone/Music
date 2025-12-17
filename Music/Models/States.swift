//
//  States.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation

/// 录音状态
enum RecordingState: Equatable {
    /// 空闲状态（未录音）
    case idle
    
    /// 准备录音（倒计时中）
    case preparing
    
    /// 正在录音
    case recording
}

/// 播放状态
enum PlaybackState: Equatable {
    /// 停止
    case stopped
    
    /// 正在播放
    case playing
    
    /// 暂停
    case paused
}
