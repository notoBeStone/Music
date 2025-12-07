//
//  ProjectListView.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import SwiftUI

/// 项目列表视图
struct ProjectListView: View {
    // MARK: - Properties
    
    @StateObject private var viewModel: ProjectListViewModel
    @State private var selectedProject: Project?
    
    // MARK: - Initialization
    
    init(projectManager: ProjectManager) {
        _viewModel = StateObject(wrappedValue: ProjectListViewModel(projectManager: projectManager))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                ColorTheme.background
                    .ignoresSafeArea()
                
                if viewModel.projects.isEmpty {
                    emptyStateView
                } else {
                    projectListView
                }
            }
            .navigationTitle("我的项目")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.showCreateDialog) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(ColorTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateDialog) {
                createProjectSheet
            }
            .alert("错误", isPresented: $viewModel.showingError) {
                Button("确定", role: .cancel) { }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .navigationDestination(item: $selectedProject) { project in
                RecordingView(project: project, projectManager: viewModel.projectManager)
            }
        }
        .onAppear {
            viewModel.refreshProjects()
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundColor(ColorTheme.textTertiary)
            
            Text("还没有项目")
                .font(.title2.bold())
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("点击右上角的 + 按钮\n创建你的第一个音乐项目")
                .font(.body)
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: viewModel.showCreateDialog) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("创建项目")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(ColorTheme.primaryGradient)
                .cornerRadius(25)
                .shadow(color: ColorTheme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    // MARK: - Project List View
    
    private var projectListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.projects) { project in
                    ProjectCardView(
                        project: project,
                        onTap: {
                            selectedProject = project
                        },
                        onDelete: {
                            viewModel.deleteProject(project)
                        },
                        onDuplicate: {
                            viewModel.duplicateProject(project)
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Create Project Sheet
    
    private var createProjectSheet: some View {
        NavigationStack {
            ZStack {
                ColorTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // 图标
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(ColorTheme.primary)
                    
                    // 输入框
                    VStack(alignment: .leading, spacing: 8) {
                        Text("项目名称")
                            .font(.subheadline.bold())
                            .foregroundColor(ColorTheme.textSecondary)
                        
                        TextField("输入项目名称", text: $viewModel.newProjectName)
                            .font(.body)
                            .foregroundColor(ColorTheme.textPrimary)
                            .padding()
                            .background(ColorTheme.inputBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(ColorTheme.border, lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                }
                .padding(32)
            }
            .navigationTitle("新建项目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        viewModel.showingCreateDialog = false
                    }
                    .foregroundColor(ColorTheme.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("创建") {
                        viewModel.createProject()
                    }
                    .foregroundColor(ColorTheme.primary)
                    .bold()
                }
            }
        }
    }
}

// MARK: - Project Card View

struct ProjectCardView: View {
    let project: Project
    let onTap: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    
    @State private var showingOptions = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // 标题行
                HStack {
                    Text(project.name)
                        .font(.title3.bold())
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { showingOptions = true }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // 信息行
                HStack(spacing: 16) {
                    Label("\(project.trackCount) 轨道", systemImage: "waveform")
                    Label("\(project.audioSettings.bpm) BPM", systemImage: "metronome")
                    Label(project.formattedDuration(), systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
                
                // 时间行
                Text("修改于 \(formatDate(project.modifiedAt))")
                    .font(.caption2)
                    .foregroundColor(ColorTheme.textTertiary)
                
                // 音轨颜色预览
                if !project.tracks.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(project.tracks.prefix(8)) { track in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ColorTheme.trackColor(at: track.colorIndex))
                                .frame(height: 4)
                        }
                    }
                }
            }
            .padding(20)
            .background(ColorTheme.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog("项目选项", isPresented: $showingOptions) {
            Button("打开") {
                onTap()
            }
            
            Button("复制") {
                onDuplicate()
            }
            
            Button("删除", role: .destructive) {
                onDelete()
            }
            
            Button("取消", role: .cancel) { }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ProjectListView(projectManager: ProjectManager())
}

