//
//  WaveformView.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import SwiftUI

/// 波形视图（简化版）
struct WaveformView: View {
    // MARK: - Properties
    
    let level: Float
    let color: Color
    
    @State private var bars: [Float] = Array(repeating: 0, count: 30)
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<bars.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(Double(bars[index])))
                    .frame(width: 3)
            }
        }
        .frame(height: 40)
        .onChange(of: level) { _, newLevel in
            updateBars(with: newLevel)
        }
    }
    
    // MARK: - Private Methods
    
    private func updateBars(with level: Float) {
        // 移除第一个元素，添加新值到末尾（滚动效果）
        bars.removeFirst()
        bars.append(level)
    }
}

#Preview {
    VStack(spacing: 20) {
        WaveformView(level: 0.5, color: ColorTheme.waveform)
        WaveformView(level: 0.8, color: ColorTheme.accent)
        WaveformView(level: 0.3, color: ColorTheme.success)
    }
    .padding()
    .background(ColorTheme.background)
}

