//
//  TrackCardView.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import SwiftUI

/// 音轨卡片视图（2x2网格中的单个卡片）
struct TrackCardView: View {
    // MARK: - Properties
    
    let track: TrackModel
    let isRecording: Bool
    let recordingLevel: Float
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var pulseAnimation = false
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // 顶部：音轨名称
                HStack {
                    Text(track.name)
                        .font(.headline)
                        .foregroundColor(ColorTheme.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 状态指示器
                    statusIndicator
                }
                
                Spacer()
                
                // 中间：波形或状态显示
                if isRecording {
                    recordingWaveform
                } else if track.hasAudio {
                    audioWaveformPlaceholder
                } else {
                    emptyState
                }
                
                Spacer()
                
                // 底部：音量和静音控制
                HStack {
                    Image(systemName: track.muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.caption)
                        .foregroundColor(track.muted ? ColorTheme.textTertiary : trackColor)
                    
                    Spacer()
                    
                    Text("\(Int(track.volume * 100))%")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
            .padding()
            .frame(height: 160)
            .background(ColorTheme.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(trackColor, lineWidth: 2)
            )
            .shadow(color: trackColor.opacity(0.3), radius: isRecording ? 10 : 5, x: 0, y: 3)
            .scaleEffect(pulseAnimation && isRecording ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    onLongPress()
                }
        )
        .onAppear {
            if isRecording {
                startPulseAnimation()
            }
        }
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                startPulseAnimation()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var statusIndicator: some View {
        Group {
            if isRecording {
                Circle()
                    .fill(ColorTheme.recordingIndicator)
                    .frame(width: 8, height: 8)
            } else if track.muted {
                Image(systemName: "speaker.slash")
                    .font(.caption)
                    .foregroundColor(ColorTheme.textTertiary)
            } else if track.solo {
                Text("S")
                    .font(.caption.bold())
                    .foregroundColor(ColorTheme.accent)
            }
        }
    }
    
    private var recordingWaveform: some View {
        HStack(spacing: 2) {
            ForEach(0..<20, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .fill(ColorTheme.recordingIndicator.opacity(Double(recordingLevel)))
                    .frame(width: 3)
            }
        }
        .frame(height: 50)
    }
    
    private var audioWaveformPlaceholder: some View {
        HStack(spacing: 2) {
            ForEach(0..<20, id: \.self) { index in
                let height = CGFloat.random(in: 10...40)
                RoundedRectangle(cornerRadius: 2)
                    .fill(trackColor.opacity(0.6))
                    .frame(width: 3, height: height)
            }
        }
        .frame(height: 50)
    }
    
    private var emptyState: some View {
        VStack(spacing: 4) {
            Image(systemName: "waveform.circle")
                .font(.title)
                .foregroundColor(ColorTheme.textTertiary)
            
            Text(LocalizedString.TrackCard.empty)
                .font(.caption)
                .foregroundColor(ColorTheme.textTertiary)
        }
    }
    
    // MARK: - Computed Properties
    
    private var trackColor: Color {
        Color(hex: track.colorHex) ?? ColorTheme.primary
    }
    
    // MARK: - Methods
    
    private func startPulseAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
}

/// 空轨道卡片
struct EmptyTrackCard: View {
    let number: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle")
                .font(.largeTitle)
                .foregroundColor(ColorTheme.textTertiary)
            
            Text("音轨 \(number)")
                .font(.headline)
                .foregroundColor(ColorTheme.textSecondary)
            
            Text(LocalizedString.TrackCard.emptySlot)
                .font(.caption)
                .foregroundColor(ColorTheme.textTertiary)
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .background(ColorTheme.cardBackground.opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(ColorTheme.border, lineWidth: 1)
        )
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        TrackCardView(
            track: TrackModel(name: "鼓点", filePath: "track1.wav", colorHex: "#EF4444"),
            isRecording: false,
            recordingLevel: 0.0,
            onTap: {},
            onLongPress: {}
        )
        
        TrackCardView(
            track: TrackModel(name: "录音中", colorHex: "#F59E0B"),
            isRecording: true,
            recordingLevel: 0.7,
            onTap: {},
            onLongPress: {}
        )
        
        EmptyTrackCard(number: 3)
    }
    .padding()
    .background(ColorTheme.background)
}
