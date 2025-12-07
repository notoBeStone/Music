//
//  ProjectListViewModel.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation
import SwiftUI

/// 项目列表视图模型
@MainActor
final class ProjectListViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// 项目列表
    @Published var projects: [Project] = []
    
    /// 是否显示创建项目对话框
    @Published var showingCreateDialog = false
    
    /// 新项目名称
    @Published var newProjectName = ""
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 是否显示错误提示
    @Published var showingError = false
    
    // MARK: - Private Properties
    
    let projectManager: ProjectManager
    
    // MARK: - Initialization
    
    init(projectManager: ProjectManager) {
        self.projectManager = projectManager
        self.projects = projectManager.projects
        
        // 观察 ProjectManager 的变化
        observeProjectManager()
    }
    
    // MARK: - Public Methods
    
    /// 刷新项目列表
    func refreshProjects() {
        projectManager.loadAllProjects()
        projects = projectManager.projects
    }
    
    /// 创建新项目
    func createProject() {
        guard !newProjectName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError("请输入项目名称")
            return
        }
        
        do {
            let project = try projectManager.createProject(name: newProjectName)
            projects = projectManager.projects
            
            // 重置输入
            newProjectName = ""
            showingCreateDialog = false
            
            print("[ProjectListViewModel] 创建项目成功：\(project.name)")
        } catch {
            showError("创建项目失败：\(error.localizedDescription)")
        }
    }
    
    /// 删除项目
    func deleteProject(_ project: Project) {
        do {
            try projectManager.deleteProject(project.id)
            projects = projectManager.projects
            
            print("[ProjectListViewModel] 删除项目成功：\(project.name)")
        } catch {
            showError("删除项目失败：\(error.localizedDescription)")
        }
    }
    
    /// 复制项目
    func duplicateProject(_ project: Project) {
        do {
            _ = try projectManager.duplicateProject(project.id)
            projects = projectManager.projects
            
            print("[ProjectListViewModel] 复制项目成功：\(project.name)")
        } catch {
            showError("复制项目失败：\(error.localizedDescription)")
        }
    }
    
    /// 显示创建项目对话框
    func showCreateDialog() {
        newProjectName = "新项目"
        showingCreateDialog = true
    }
    
    // MARK: - Private Methods
    
    /// 观察 ProjectManager 的变化
    private func observeProjectManager() {
        Task {
            for await _ in NotificationCenter.default.notifications(named: .projectsDidChange) {
                await MainActor.run {
                    self.projects = projectManager.projects
                }
            }
        }
    }
    
    /// 显示错误信息
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let projectsDidChange = Notification.Name("projectsDidChange")
}

