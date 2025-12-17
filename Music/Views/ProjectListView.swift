//
//  ProjectListView.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import SwiftUI

/// 项目列表视图
struct ProjectListView: View {
    // MARK: - Properties
    
    @StateObject private var viewModel = ProjectListViewModel()
    @State private var selectedProject: ProjectModel?
    
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
            .navigationTitle(LocalizedString.ProjectList.title)
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
            .alert(LocalizedString.Common.error, isPresented: $viewModel.showingError) {
                Button(LocalizedString.Common.ok, role: .cancel) { }
            } message: {
                if let message = viewModel.errorMessage {
                    Text(message)
                }
            }
            .navigationDestination(item: $selectedProject) { project in
                MainView(project: project)
            }
        }
        .onAppear {
            viewModel.loadProjects()
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundColor(ColorTheme.textTertiary)
            
            Text(LocalizedString.ProjectList.emptyTitle)
                .font(.title2.bold())
                .foregroundColor(ColorTheme.textPrimary)
            
            Text(LocalizedString.ProjectList.emptyMessage)
                .font(.body)
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: viewModel.showCreateDialog) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(LocalizedString.ProjectList.emptyCreateButton)
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
        .padding()
    }
    
    // MARK: - Project List View
    
    private var projectListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.projects) { project in
                    ProjectCard(
                        project: project,
                        onTap: {
                            viewModel.openProject(project)
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
                        Text(LocalizedString.ProjectList.Create.nameLabel)
                            .font(.subheadline.bold())
                            .foregroundColor(ColorTheme.textSecondary)
                        
                        TextField(LocalizedString.ProjectList.Create.namePlaceholder, text: $viewModel.newProjectName)
                            .font(.body)
                            .foregroundColor(ColorTheme.textPrimary)
                            .padding()
                            .background(ColorTheme.inputBackground)
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding(32)
            }
            .navigationTitle(LocalizedString.ProjectList.Create.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedString.ProjectList.Create.cancel) {
                        viewModel.showingCreateDialog = false
                    }
                    .foregroundColor(ColorTheme.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedString.ProjectList.Create.confirm) {
                        viewModel.createProject()
                    }
                    .foregroundColor(ColorTheme.primary)
                    .bold()
                }
            }
        }
    }
}

// MARK: - Project Card

struct ProjectCard: View {
    let project: ProjectModel
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
                    Label("\(project.trackCount) 音轨", systemImage: "waveform")
                    Label("\(project.bpm) BPM", systemImage: "metronome")
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
                        ForEach(project.tracks.prefix(4)) { track in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: track.colorHex) ?? ColorTheme.primary)
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
        .confirmationDialog(LocalizedString.ProjectList.Menu.options, isPresented: $showingOptions) {
            Button(LocalizedString.ProjectList.Menu.open) {
                onTap()
            }
            
            Button(LocalizedString.ProjectList.Menu.duplicate) {
                onDuplicate()
            }
            
            Button(LocalizedString.ProjectList.Menu.delete, role: .destructive) {
                onDelete()
            }
            
            Button(LocalizedString.Common.cancel, role: .cancel) { }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview

#Preview {
    ProjectListView()
}
