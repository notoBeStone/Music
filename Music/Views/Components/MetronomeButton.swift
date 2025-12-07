//
//  MetronomeButton.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import SwiftUI

/// 节拍器按钮
struct MetronomeButton: View {
    // MARK: - Properties
    
    let isEnabled: Bool
    let bpm: Int
    let action: () -> Void
    
    @State private var beatAnimation = false
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            action()
            if isEnabled {
                triggerBeatAnimation()
            }
        }) {
            HStack(spacing: 8) {
                // 节拍器图标
                Image(systemName: "metronome")
                    .font(.system(size: 20))
                    .foregroundColor(isEnabled ? ColorTheme.metronome : ColorTheme.textSecondary)
                    .scaleEffect(beatAnimation ? 1.2 : 1.0)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("节拍器")
                        .font(.caption)
                        .foregroundColor(isEnabled ? ColorTheme.textPrimary : ColorTheme.textSecondary)
                    
                    Text("\(bpm) BPM")
                        .font(.caption2)
                        .foregroundColor(ColorTheme.textTertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isEnabled
                    ? ColorTheme.metronome.opacity(0.2)
                    : ColorTheme.inputBackground
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isEnabled ? ColorTheme.metronome : ColorTheme.border,
                        lineWidth: 1
                    )
            )
        }
        .onChange(of: isEnabled) { _, newValue in
            if newValue {
                startBeatAnimation()
            }
        }
        .onAppear {
            if isEnabled {
                startBeatAnimation()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func triggerBeatAnimation() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            beatAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                beatAnimation = false
            }
        }
    }
    
    private func startBeatAnimation() {
        let interval = 60.0 / Double(bpm) // 每拍的秒数
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            if isEnabled {
                triggerBeatAnimation()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MetronomeButton(isEnabled: false, bpm: 120) {}
        MetronomeButton(isEnabled: true, bpm: 120) {}
        MetronomeButton(isEnabled: true, bpm: 95) {}
    }
    .padding()
    .background(ColorTheme.background)
}

