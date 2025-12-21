//
//  ContentView.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import SwiftUI

/// 主视图容器
struct ContentView: View {
    // MARK: - State
    
    @State private var isShowingLaunchScreen = true
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 主视图
            ProjectListView()
                .opacity(isShowingLaunchScreen ? 0 : 1)
            
            // 启动屏幕
            if isShowingLaunchScreen {
                LaunchScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            // 启动屏幕显示时长（1.5秒）
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isShowingLaunchScreen = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
