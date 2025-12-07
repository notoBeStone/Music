//
//  RecordingView.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import SwiftUI

/// 录音编辑主界面
struct RecordingView: View {
    // MARK: - Properties
    
    @StateObject private var viewModel: RecordingViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    
    init(project: Project, projectManager: ProjectManager) {
        _viewModel = StateObject(wrappedValue: RecordingViewModel(project: project, projectManager: projectManager))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 背景
            ColorTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部控制区
                topControlSection
                    .padding()
                
                Divider()
                    .background(ColorTheme.divider)
                
                // 播放控制区
                playbackSection
                    .padding()
                
                Divider()
                    .background(ColorTheme.divider)
                
                // 音轨列表
                trackListSection
                
                Divider()
                    .background(ColorTheme.divider)
                
                // 底部录音区
                recordingSection
                    .padding()
            }
        }
        .navigationTitle(viewModel.project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {}) {
                        Label("导出音频", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {}) {
                        Label("项目设置", systemImage: "gear")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(ColorTheme.textPrimary)
                }
            }
        }
        .alert("错误", isPresented: $viewModel.showingError) {
            Button("确定", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Top Control Section
    
    private var topControlSection: some View {
        HStack {
            // BPM 显示
            VStack(alignment: .leading, spacing: 4) {
                Text("BPM")
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
                
                Text("\(viewModel.project.audioSettings.bpm)")
                    .font(.title2.bold())
                    .foregroundColor(ColorTheme.textPrimary)
            }
            .padding()
            .background(ColorTheme.cardBackground)
            .cornerRadius(12)
            
            Spacer()
            
            // 节拍器按钮
            MetronomeButton(
                isEnabled: viewModel.metronomeEnabled,
                bpm: viewModel.project.audioSettings.bpm,
                action: viewModel.toggleMetronome
            )
        }
    }
    
    // MARK: - Playback Section
    
    private var playbackSection: some View {
        PlaybackControlBar(
            isPlaying: viewModel.playbackState == .playing,
            currentTime: viewModel.currentTime,
            duration: viewModel.project.audioSettings.loopLength,
            onPlayPause: viewModel.togglePlayback,
            onStop: viewModel.stop
        )
    }
    
    // MARK: - Track List Section
    
    private var trackListSection: some View {
        Group {
            if viewModel.project.tracks.isEmpty {
                emptyTrackListView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.project.tracks) { track in
                            TrackRowView(
                                track: track,
                                onVolumeChange: { volume in
                                    viewModel.updateTrackVolume(track, volume: volume)
                                },
                                onMuteToggle: {
                                    viewModel.toggleTrackMute(track)
                                },
                                onSoloToggle: {
                                    viewModel.toggleTrackSolo(track)
                                },
                                onDelete: {
                                    viewModel.deleteTrack(track)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var emptyTrackListView: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.path")
                .font(.system(size: 50))
                .foregroundColor(ColorTheme.textTertiary)
            
            Text("还没有音轨")
                .font(.headline)
                .foregroundColor(ColorTheme.textSecondary)
            
            Text("点击下方的录音按钮\n开始录制你的第一个音轨")
                .font(.caption)
                .foregroundColor(ColorTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Recording Section
    
    private var recordingSection: some View {
        VStack(spacing: 16) {
            // 录音状态指示
            if viewModel.recordingState == .recording {
                VStack(spacing: 8) {
                    // 波形显示
                    WaveformView(
                        level: viewModel.recordingLevel,
                        color: ColorTheme.recordingIndicator
                    )
                    
                    // 录音时长
                    Text(formatRecordingTime(viewModel.recordingLevel))
                        .font(.system(.title3, design: .monospaced))
                        .foregroundColor(ColorTheme.recordingIndicator)
                }
                .padding()
                .background(ColorTheme.cardBackground)
                .cornerRadius(12)
            }
            
            // 录音按钮
            HStack(spacing: 20) {
                if viewModel.recordingState == .recording {
                    // 取消按钮
                    Button(action: viewModel.cancelRecording) {
                        Text("取消")
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
                            viewModel.startRecording()
                        }
                    }
                )
            }
            
            // 提示文本
            if !viewModel.canAddTrack && viewModel.recordingState != .recording {
                Text("已达到最大音轨数量（4轨）")
                    .font(.caption)
                    .foregroundColor(ColorTheme.warning)
            } else if viewModel.recordingState == .idle {
                Text(viewModel.hasTracks ? "点按录制新音轨" : "点按开始录音")
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatRecordingTime(_ level: Float) -> String {
        let duration = viewModel.recordingLevel
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let milliseconds = Int((duration.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

#Preview {
    NavigationStack {
        RecordingView(
            project: Project(
                name: "我的项目",
                tracks: [
                    Track(name: "鼓点", filePath: "track1.wav", colorIndex: 0),
                    Track(name: "贝斯", filePath: "track2.wav", colorIndex: 1),
                    Track(name: "旋律", filePath: "track3.wav", colorIndex: 2)
                ]
            ),
            projectManager: ProjectManager()
        )
    }
}

