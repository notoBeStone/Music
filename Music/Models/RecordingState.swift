//
//  RecordingState.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation

/// 录音状态枚举
enum RecordingState {
    /// 空闲状态
    case idle
    /// 准备录音（倒计时）
    case preparing
    /// 正在录音
    case recording
    /// 暂停录音
    case paused
}

/// 播放状态枚举
enum PlaybackState {
    /// 停止
    case stopped
    /// 正在播放
    case playing
    /// 暂停
    case paused
}

