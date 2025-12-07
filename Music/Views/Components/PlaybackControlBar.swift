//
//  PlaybackControlBar.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import SwiftUI

/// 播放控制栏
struct PlaybackControlBar: View {
    // MARK: - Properties
    
    let isPlaying: Bool
    let currentTime: TimeInterval
    let duration: TimeInterval
    let onPlayPause: () -> Void
    let onStop: () -> Void
    
    // MARK: - Computed Properties
    
    private var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    private var formattedCurrentTime: String {
        formatTime(currentTime)
    }
    
    private var formattedDuration: String {
        formatTime(duration)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 12) {
            // 进度条
            ZStack(alignment: .leading) {
                // 背景
                RoundedRectangle(cornerRadius: 4)
                    .fill(ColorTheme.inputBackground)
                    .frame(height: 8)
                
                // 进度
                RoundedRectangle(cornerRadius: 4)
                    .fill(ColorTheme.primaryGradient)
                    .frame(width: max(0, CGFloat(progress) * UIScreen.main.bounds.width - 64), height: 8)
            }
            
            // 时间显示
            HStack {
                Text(formattedCurrentTime)
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
                    .monospacedDigit()
                
                Spacer()
                
                Text(formattedDuration)
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
                    .monospacedDigit()
            }
            
            // 控制按钮
            HStack(spacing: 20) {
                // 停止按钮
                Button(action: onStop) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ColorTheme.textPrimary)
                        .frame(width: 50, height: 50)
                        .background(ColorTheme.inputBackground)
                        .cornerRadius(25)
                }
                
                // 播放/暂停按钮
                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color.white)
                        .frame(width: 70, height: 70)
                        .background(ColorTheme.primaryGradient)
                        .cornerRadius(35)
                        .shadow(color: ColorTheme.primary.opacity(0.5), radius: 10, x: 0, y: 5)
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(ColorTheme.cardBackground)
        .cornerRadius(20)
    }
    
    // MARK: - Private Methods
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VStack(spacing: 40) {
        PlaybackControlBar(
            isPlaying: false,
            currentTime: 0,
            duration: 8.0,
            onPlayPause: {},
            onStop: {}
        )
        
        PlaybackControlBar(
            isPlaying: true,
            currentTime: 3.5,
            duration: 8.0,
            onPlayPause: {},
            onStop: {}
        )
    }
    .padding()
    .background(ColorTheme.background)
}

