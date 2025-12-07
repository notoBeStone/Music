//
//  TrackRowView.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import SwiftUI

/// 音轨行视图
struct TrackRowView: View {
    // MARK: - Properties
    
    let track: Track
    let onVolumeChange: (Float) -> Void
    let onMuteToggle: () -> Void
    let onSoloToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var volume: Float
    @State private var showingDeleteConfirmation = false
    
    // MARK: - Initialization
    
    init(
        track: Track,
        onVolumeChange: @escaping (Float) -> Void,
        onMuteToggle: @escaping () -> Void,
        onSoloToggle: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.track = track
        self.onVolumeChange = onVolumeChange
        self.onMuteToggle = onMuteToggle
        self.onSoloToggle = onSoloToggle
        self.onDelete = onDelete
        self._volume = State(initialValue: track.volume)
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            // 音轨颜色指示器
            RoundedRectangle(cornerRadius: 4)
                .fill(ColorTheme.trackColor(at: track.colorIndex))
                .frame(width: 4, height: 60)
            
            VStack(alignment: .leading, spacing: 8) {
                // 音轨名称和控制按钮
                HStack {
                    Text(track.name)
                        .font(.headline)
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Spacer()
                    
                    // Solo 按钮
                    Button(action: onSoloToggle) {
                        Text("S")
                            .font(.caption.bold())
                            .foregroundColor(track.isSolo ? ColorTheme.textInverse : ColorTheme.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(track.isSolo ? ColorTheme.accent : ColorTheme.inputBackground)
                            .cornerRadius(6)
                    }
                    
                    // 静音按钮
                    Button(action: onMuteToggle) {
                        Image(systemName: track.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(track.isMuted ? ColorTheme.textTertiary : ColorTheme.textPrimary)
                            .frame(width: 28, height: 28)
                            .background(ColorTheme.inputBackground)
                            .cornerRadius(6)
                    }
                    
                    // 删除按钮
                    Button(action: { showingDeleteConfirmation = true }) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14))
                            .foregroundColor(ColorTheme.error)
                            .frame(width: 28, height: 28)
                            .background(ColorTheme.inputBackground)
                            .cornerRadius(6)
                    }
                }
                
                // 音量控制
                HStack(spacing: 8) {
                    Image(systemName: "speaker.fill")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Slider(value: $volume, in: 0...1) { editing in
                        if !editing {
                            onVolumeChange(volume)
                        }
                    }
                    .tint(ColorTheme.trackColor(at: track.colorIndex))
                    
                    Text("\(Int(volume * 100))%")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .padding(12)
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
        .alert("删除音轨", isPresented: $showingDeleteConfirmation) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("确定要删除音轨 \"\(track.name)\" 吗？此操作无法撤销。")
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        TrackRowView(
            track: Track(name: "鼓点", filePath: "track1.wav", colorIndex: 0),
            onVolumeChange: { _ in },
            onMuteToggle: { },
            onSoloToggle: { },
            onDelete: { }
        )
        
        TrackRowView(
            track: Track(name: "贝斯", filePath: "track2.wav", isMuted: true, colorIndex: 1),
            onVolumeChange: { _ in },
            onMuteToggle: { },
            onSoloToggle: { },
            onDelete: { }
        )
        
        TrackRowView(
            track: Track(name: "旋律", filePath: "track3.wav", isSolo: true, colorIndex: 2),
            onVolumeChange: { _ in },
            onMuteToggle: { },
            onSoloToggle: { },
            onDelete: { }
        )
    }
    .padding()
    .background(ColorTheme.background)
}

