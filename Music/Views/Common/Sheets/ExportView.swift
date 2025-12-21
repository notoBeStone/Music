//
//  ExportView.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import SwiftUI

/// 导出视图
struct ExportView: View {
    // MARK: - Properties
    
    let project: ProjectModel
    let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: AudioExportFormat = .m4a
    @State private var isExporting = false
    @State private var exportProgress: Double = 0.0
    @State private var exportedURL: URL?
    @State private var showingShare = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.background
                    .ignoresSafeArea()
                
                if isExporting {
                    exportingView
                } else if exportedURL != nil {
                    successView
                } else {
                    selectionView
                }
            }
            .navigationTitle(LocalizedString.ExportView.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedString.Common.cancel) {
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.textSecondary)
                    .disabled(isExporting)
                }
            }
            .sheet(isPresented: $showingShare) {
                if let url = exportedURL {
                    ShareSheet(items: [url])
                }
            }
            .alert(LocalizedString.Common.error, isPresented: $showingError) {
                Button(LocalizedString.Common.ok, role: .cancel) { }
            } message: {
                if let message = errorMessage {
                    Text(message)
                }
            }
        }
    }
    
    // MARK: - Selection View
    
    private var selectionView: some View {
        VStack(spacing: 24) {
            // 项目信息
            VStack(spacing: 8) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ColorTheme.primary)
                
                Text(project.name)
                    .font(.title2.bold())
                    .foregroundColor(ColorTheme.textPrimary)
                
                HStack(spacing: 16) {
                    Label("\(project.trackCount) 音轨", systemImage: "waveform")
                    Label(project.formattedDuration(), systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
            }
            .padding()
            
            Divider()
                .background(ColorTheme.divider)
            
            // 格式选择
            VStack(alignment: .leading, spacing: 16) {
                Text(LocalizedString.ExportView.formatLabel)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                
                ForEach([AudioExportFormat.m4a, .wav, .mp3], id: \.self) { format in
                    FormatOption(
                        format: format,
                        isSelected: selectedFormat == format,
                        onSelect: {
                            selectedFormat = format
                        }
                    )
                }
            }
            .padding()
            
            Spacer()
            
            // 导出按钮
            Button(action: startExport) {
                Text(LocalizedString.ExportView.startButton)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorTheme.primaryGradient)
                    .cornerRadius(12)
            }
            .padding()
        }
    }
    
    // MARK: - Exporting View
    
    private var exportingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ProgressView()
                .scaleEffect(2.0)
                .tint(ColorTheme.primary)
            
            Text(LocalizedString.ExportView.exporting)
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)
            
            Text(LocalizedString.ExportView.exportingMessage)
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Success View
    
    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(ColorTheme.success)
            
            Text(LocalizedString.ExportView.successTitle)
                .font(.title2.bold())
                .foregroundColor(ColorTheme.textPrimary)
            
            Text(LocalizedString.ExportView.successMessage)
                .font(.body)
                .foregroundColor(ColorTheme.textSecondary)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: { showingShare = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text(LocalizedString.ExportView.shareButton)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorTheme.primaryGradient)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    onComplete()
                    dismiss()
                }) {
                    Text(LocalizedString.ExportView.doneButton)
                        .font(.headline)
                        .foregroundColor(ColorTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorTheme.cardBackground)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Methods
    
    private func startExport() {
        isExporting = true
        
        AudioExporter.shared.exportMixdown(project: project, format: selectedFormat) { result in
            isExporting = false
            
            switch result {
            case .success(let url):
                exportedURL = url
            case .failure(let error):
                errorMessage = LocalizedString.Repository.exportFailed(error.localizedDescription)
                showingError = true
            }
        }
    }
}

// MARK: - Format Option

struct FormatOption: View {
    let format: AudioExportFormat
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.displayName)
                        .font(.headline)
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Text(formatDescription)
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? ColorTheme.primary : ColorTheme.textTertiary)
            }
            .padding()
            .background(ColorTheme.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? ColorTheme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var formatDescription: String {
        switch format {
        case .wav:
            return "无损质量，文件较大"
        case .m4a:
            return "高质量压缩，推荐"
        case .mp3:
            return "通用格式，兼容性好"
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    ExportView(
        project: ProjectModel(
            name: "我的作品",
            bpm: 120,
            loopBars: 4,
            tracks: [
                TrackModel(name: "鼓点", filePath: "track1.wav", colorHex: "#EF4444"),
                TrackModel(name: "贝斯", filePath: "track2.wav", colorHex: "#F59E0B")
            ]
        ),
        onComplete: {}
    )
}
