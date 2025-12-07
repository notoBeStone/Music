//
//  MusicApp.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import SwiftUI
import AVFoundation

@main
struct MusicApp: App {
    // MARK: - Properties
    
    @StateObject private var projectManager = ProjectManager()
    
    // MARK: - Initialization
    
    init() {
        // 配置音频会话
        configureAudioSession()
        
        // 配置导航栏样式
        configureNavigationBarAppearance()
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(projectManager)
                .preferredColorScheme(.dark) // 强制深色模式
        }
    }
    
    // MARK: - Configuration
    
    /// 配置音频会话
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(false)
            
            print("[MusicApp] 音频会话配置成功")
        } catch {
            print("[MusicApp] 音频会话配置失败：\(error.localizedDescription)")
        }
    }
    
    /// 配置导航栏样式
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(ColorTheme.background)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(ColorTheme.textPrimary)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(ColorTheme.textPrimary)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
