//
//  MainView.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import SwiftUI

/// 主创作页面
struct MainView: View {
    // MARK: - Properties
    
    @StateObject private var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTrack: TrackModel?
    @State private var showingProjectMenu = false
    @State private var showingExport = false
    
    // MARK: - Initialization
    
    init(project: ProjectModel) {
        _viewModel = StateObject(wrappedValue: MainViewModel(project: project))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 背景
            ColorTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部栏
                topBar
                    .padding()
                
                Divider()
                    .background(ColorTheme.divider)
                
                // 控制区
                controlSection
                    .padding()
                
                Divider()
                    .background(ColorTheme.divider)
                
                // 轨道区域（2x2网格）
                trackGridSection
                    .padding()
                
                Spacer()
                
                Divider()
                    .background(ColorTheme.divider)
                
                // 底部录音区
                recordingSection
                    .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(LocalizedString.MainView.backToProjects)
                    }
                    .foregroundColor(ColorTheme.textPrimary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingExport = true }) {
                        Label(LocalizedString.MainView.Menu.export, systemImage: "square.and.arrow.up")
                    }
                    .disabled(viewModel.project.tracks.isEmpty)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(ColorTheme.textPrimary)
                }
            }
        }
        .sheet(item: $selectedTrack) { track in
            TrackDetailSheet(
                track: track,
                onUpdate: { updatedTrack in
                    viewModel.project.updateTrack(updatedTrack)
                },
                onDelete: {
                    viewModel.deleteTrack(track)
                    selectedTrack = nil
                }
            )
        }
        .sheet(isPresented: $showingExport) {
            ExportView(project: viewModel.project) {
                // 导出完成回调
            }
        }
        .alert(LocalizedString.Common.error, isPresented: $viewModel.showingError) {
            Button(LocalizedString.Common.ok, role: .cancel) { }
        } message: {
            if let message = viewModel.errorMessage {
                Text(message)
            }
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            // 项目名称
            Button(action: { showingProjectMenu = true }) {
                HStack(spacing: 8) {
                    Text(viewModel.project.name)
                        .font(.title2.bold())
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Control Section
    
    private var controlSection: some View {
        HStack(spacing: 20) {
            // BPM 显示
            VStack(alignment: .leading, spacing: 4) {
                Text("BPM")
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
                
                Text("\(viewModel.project.bpm)")
                    .font(.title.bold())
                    .foregroundColor(ColorTheme.textPrimary)
            }
            .padding()
            .background(ColorTheme.cardBackground)
            .cornerRadius(12)
            
            Spacer()
            
            // 播放控制
            playbackControls
            
            Spacer()
            
            // 节拍器
            Button(action: viewModel.toggleMetronome) {
                VStack(spacing: 4) {
                    Image(systemName: "metronome")
                        .font(.title2)
                        .foregroundColor(viewModel.metronomeEnabled ? ColorTheme.metronome : ColorTheme.textSecondary)
                    
                    Text(LocalizedString.MainView.metronomeLabel)
                        .font(.caption2)
                        .foregroundColor(viewModel.metronomeEnabled ? ColorTheme.metronome : ColorTheme.textSecondary)
                }
                .frame(width: 70, height: 70)
                .background(viewModel.metronomeEnabled ? ColorTheme.metronome.opacity(0.2) : ColorTheme.cardBackground)
                .cornerRadius(12)
            }
        }
    }
    
    private var playbackControls: some View {
        HStack(spacing: 15) {
            // 撤销按钮
            Button(action: viewModel.undo) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.title2)
                    .foregroundColor(viewModel.canUndo ? ColorTheme.textPrimary : ColorTheme.textTertiary)
                    .frame(width: 50, height: 50)
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(25)
            }
            .disabled(!viewModel.canUndo)
            
            // 停止按钮
            Button(action: viewModel.stop) {
                Image(systemName: "stop.fill")
                    .font(.title2)
                    .foregroundColor(ColorTheme.textPrimary)
                    .frame(width: 50, height: 50)
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(25)
            }
            
            // 播放/暂停按钮
            Button(action: viewModel.togglePlayback) {
                Image(systemName: viewModel.playbackState == .playing ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(ColorTheme.primaryGradient)
                    .cornerRadius(35)
                    .shadow(color: ColorTheme.primary.opacity(0.5), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    // MARK: - Track Grid Section
    
    private var trackGridSection: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
        
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<4) { index in
                if index < viewModel.project.tracks.count {
                    // 已有轨道
                    TrackCardView(
                        track: viewModel.project.tracks[index],
                        isRecording: viewModel.recordingTrackId == viewModel.project.tracks[index].id,
                        recordingLevel: viewModel.recordingLevel,
                        onTap: {
                            viewModel.toggleTrackMute(viewModel.project.tracks[index])
                        },
                        onLongPress: {
                            selectedTrack = viewModel.project.tracks[index]
                        }
                    )
                } else {
                    // 空轨道槽
                    EmptyTrackCard(number: index + 1)
                }
            }
        }
    }
    
    // MARK: - Recording Section
    
    private var recordingSection: some View {
        VStack(spacing: 16) {
            // 录音状态指示
            if viewModel.recordingState == .recording {
                VStack(spacing: 8) {
                    // 录音时长
                    Text(formatRecordingTime(viewModel.recordingDuration))
                        .font(.system(.title2, design: .monospaced))
                        .foregroundColor(ColorTheme.recordingIndicator)
                    
                    // 简单波形
                    HStack(spacing: 2) {
                        ForEach(0..<30, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ColorTheme.recordingIndicator.opacity(Double(viewModel.recordingLevel)))
                                .frame(width: 3, height: CGFloat.random(in: 10...40))
                        }
                    }
                    .frame(height: 40)
                }
                .padding()
                .background(ColorTheme.cardBackground)
                .cornerRadius(12)
            }
            
            // 录音按钮区域
            HStack(spacing: 20) {
                if viewModel.recordingState == .recording {
                    // 取消按钮
                    Button(action: viewModel.cancelRecording) {
                        Text(LocalizedString.MainView.Recording.cancel)
                            .font(.headline)
                            .foregroundColor(ColorTheme.textSecondary)
                            .frame(width: 80, height: 50)
                            .background(ColorTheme.inputBackground)
                            .cornerRadius(25)
                    }
                }
                
                // 主录音按钮
                RecordButton(
                    isRecording: viewModel.recordingState == .recording,
                    isEnabled: viewModel.canAddTrack || viewModel.recordingState == .recording,
                    action: {
                        if viewModel.recordingState == .recording {
                            viewModel.stopRecording()
                        } else {
                            viewModel.startRecordingNewTrack()
                        }
                    }
                )
            }
            
            // 提示文本
            if !viewModel.canAddTrack && viewModel.recordingState != .recording {
                Text(LocalizedString.MainView.Recording.maxTracks)
                    .font(.caption)
                    .foregroundColor(ColorTheme.warning)
            } else if viewModel.recordingState == .idle {
                Text(viewModel.hasTracks ? LocalizedString.MainView.Recording.hintNew : LocalizedString.MainView.Recording.hintStart)
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatRecordingTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MainView(project: ProjectModel(
            name: "我的作品",
            bpm: 120,
            loopBars: 4,
            tracks: [
                TrackModel(name: "鼓点", filePath: "track1.wav", colorHex: "#EF4444"),
                TrackModel(name: "贝斯", filePath: "track2.wav", colorHex: "#F59E0B")
            ]
        ))
    }
}
