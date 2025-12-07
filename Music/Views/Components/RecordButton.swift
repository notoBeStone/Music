//
//  RecordButton.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import SwiftUI

/// 录音按钮
struct RecordButton: View {
    // MARK: - Properties
    
    let isRecording: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressing = false
    @State private var pulseAnimation = false
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // 外圈脉动效果（录音时）
                if isRecording {
                    Circle()
                        .fill(ColorTheme.recordingIndicator.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                }
                
                // 主按钮
                Circle()
                    .fill(isRecording ? ColorTheme.accent : ColorTheme.recordingIndicator)
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: (isRecording ? ColorTheme.accent : ColorTheme.recordingIndicator).opacity(0.5),
                        radius: isPressing ? 10 : 20,
                        x: 0,
                        y: isPressing ? 5 : 10
                    )
                    .scaleEffect(isPressing ? 0.95 : 1.0)
                
                // 内部图标
                if isRecording {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                }
            }
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressing = true
                }
                .onEnded { _ in
                    isPressing = false
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
    
    // MARK: - Private Methods
    
    private func startPulseAnimation() {
        withAnimation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
            pulseAnimation = true
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        RecordButton(isRecording: false, isEnabled: true) {
            print("开始录音")
        }
        
        RecordButton(isRecording: true, isEnabled: true) {
            print("停止录音")
        }
        
        RecordButton(isRecording: false, isEnabled: false) {
            print("禁用")
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ColorTheme.background)
}

