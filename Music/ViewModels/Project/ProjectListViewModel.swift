//
//  ProjectListViewModel.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation
import SwiftUI
import Combine

/// 项目列表视图模型
@MainActor
final class ProjectListViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// 项目列表
    @Published var projects: [ProjectModel] = []
    
    /// 是否显示创建对话框
    @Published var showingCreateDialog = false
    
    /// 新项目名称
    @Published var newProjectName = ""
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 是否显示错误
    @Published var showingError = false
    
    // MARK: - Private Properties
    
    private let repository = ProjectRepository.shared
    private let settings = SettingsManager.shared
    
    // MARK: - Initialization
    
    init() {
        loadProjects()
    }
    
    // MARK: - Public Methods
    
    /// 加载项目列表
    func loadProjects() {
        do {
            projects = try repository.loadAll()
            print("[ProjectListViewModel] 加载了 \(projects.count) 个项目")
        } catch {
            showError(LocalizedString.Repository.loadFailed(error.localizedDescription))
        }
    }
    
    /// 显示创建对话框
    func showCreateDialog() {
        newProjectName = "新作品 \(projects.count + 1)"
        showingCreateDialog = true
    }
    
    /// 创建项目
    func createProject() {
        guard !newProjectName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError(LocalizedString.ViewModel.nameRequired)
            return
        }
        
        let appSettings = settings.loadSettings()
        
        let project = ProjectModel(
            name: newProjectName,
            bpm: appSettings.defaultBPM,
            loopBars: appSettings.defaultLoopBars
        )
        
        do {
            // 创建项目目录
            _ = FileManager.projectDirectory(for: project.id)
            
            // 保存项目
            try repository.save(project)
            
            // 更新列表
            loadProjects()
            
            // 重置输入
            newProjectName = ""
            showingCreateDialog = false
            
            // 更新最近打开的项目
            settings.updateLastOpenedProject(project.id)
            
            print("[ProjectListViewModel] 创建项目：\(project.name)")
        } catch {
            showError(LocalizedString.Repository.saveFailed(error.localizedDescription))
        }
    }
    
    /// 删除项目
    func deleteProject(_ project: ProjectModel) {
        do {
            try repository.delete(project.id)
            loadProjects()
            
            print("[ProjectListViewModel] 删除项目：\(project.name)")
        } catch {
            showError(LocalizedString.Repository.deleteFailed(error.localizedDescription))
        }
    }
    
    /// 复制项目
    func duplicateProject(_ project: ProjectModel) {
        do {
            _ = try repository.duplicate(project.id, newName: "\(project.name) 副本")
            loadProjects()
            
            print("[ProjectListViewModel] 复制项目：\(project.name)")
        } catch {
            showError(LocalizedString.Repository.saveFailed(error.localizedDescription))
        }
    }
    
    /// 重命名项目
    func renameProject(_ project: ProjectModel, newName: String) {
        var updatedProject = project
        updatedProject.name = newName
        
        do {
            try repository.save(updatedProject)
            loadProjects()
            
            print("[ProjectListViewModel] 重命名项目：\(newName)")
        } catch {
            showError(LocalizedString.Repository.saveFailed(error.localizedDescription))
        }
    }
    
    /// 打开项目
    func openProject(_ project: ProjectModel) {
        settings.updateLastOpenedProject(project.id)
    }
    
    // MARK: - Private Methods
    
    /// 显示错误
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}
