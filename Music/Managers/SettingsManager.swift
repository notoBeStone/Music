//
//  SettingsManager.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation

/// 应用设置管理器
final class SettingsManager {
    // MARK: - Singleton
    
    static let shared = SettingsManager()
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "app_settings"
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - Initialization
    
    private init() {
        jsonEncoder.dateEncodingStrategy = .iso8601
        jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Public Methods
    
    /// 保存设置
    func saveSettings(_ settings: AppSettings) {
        do {
            let data = try jsonEncoder.encode(settings)
            userDefaults.set(data, forKey: settingsKey)
            userDefaults.synchronize()
            
            print("[SettingsManager] 设置已保存")
        } catch {
            print("[SettingsManager] 保存设置失败：\(error.localizedDescription)")
        }
    }
    
    /// 加载设置
    func loadSettings() -> AppSettings {
        guard let data = userDefaults.data(forKey: settingsKey) else {
            print("[SettingsManager] 使用默认设置")
            return .default
        }
        
        do {
            let settings = try jsonDecoder.decode(AppSettings.self, from: data)
            print("[SettingsManager] 设置已加载")
            return settings
        } catch {
            print("[SettingsManager] 加载设置失败：\(error.localizedDescription)")
            return .default
        }
    }
    
    /// 更新上次打开的项目
    func updateLastOpenedProject(_ projectId: UUID?) {
        var settings = loadSettings()
        settings.lastOpenedProjectId = projectId
        saveSettings(settings)
    }
    
    /// 更新默认 BPM
    func updateDefaultBPM(_ bpm: Int) {
        var settings = loadSettings()
        settings.defaultBPM = bpm
        saveSettings(settings)
    }
    
    /// 更新默认循环小节数
    func updateDefaultLoopBars(_ loopBars: Int) {
        var settings = loadSettings()
        settings.defaultLoopBars = loopBars
        saveSettings(settings)
    }
}
