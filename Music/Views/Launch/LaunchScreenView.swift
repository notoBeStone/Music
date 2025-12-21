//
//  LaunchScreenView.swift
//  Music
//
//  启动屏幕视图
//

import SwiftUI

/// 启动屏幕视图
struct LaunchScreenView: View {
    // MARK: - State
    
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0.0
    @State private var waveOffset: CGFloat = 0
    
    // MARK: - Properties
    
    /// 获取 App 显示名称
    private var appDisplayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ??
        "Music"
    }
    
    /// 获取 App 版本号
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    ColorTheme.background,
                    ColorTheme.backgroundSecondary,
                    ColorTheme.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 动态波浪背景效果
            WaveShape(offset: waveOffset)
                .fill(
                    LinearGradient(
                        colors: [
                            ColorTheme.primary.opacity(0.1),
                            ColorTheme.primaryVariant.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .ignoresSafeArea()
            
            // 主内容
            VStack(spacing: 30) {
                // App 图标
                ZStack {
                    // 发光效果
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    ColorTheme.primary.opacity(0.3),
                                    ColorTheme.primary.opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    // App 图标
                    Image("LaunchIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .cornerRadius(28)
                        .shadow(
                            color: ColorTheme.primary.opacity(0.3),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                // App 名称
                VStack(spacing: 8) {
                    Text(appDisplayName)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Text("v\(appVersion)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(ColorTheme.textSecondary)
                        .tracking(2)
                }
                .opacity(opacity)
                
                // 加载指示器
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(ColorTheme.primary)
                            .frame(width: 8, height: 8)
                            .scaleEffect(scale > 0.9 ? 1.0 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: scale
                            )
                    }
                }
                .opacity(opacity)
                .padding(.top, 20)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Animations
    
    /// 启动动画
    private func startAnimations() {
        // 图标缩放和淡入动画
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // 波浪动画
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            waveOffset = 400
        }
    }
}

// MARK: - Wave Shape

/// 波浪形状
struct WaveShape: Shape {
    var offset: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midHeight = height * 0.5
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / 50
            let sine = sin(relativeX + offset / 50)
            let y = midHeight + sine * 30
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Preview

#Preview {
    LaunchScreenView()
}
