//
//  TrackDetailSheet.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import SwiftUI

/// 轨道详情弹窗
struct TrackDetailSheet: View {
    // MARK: - Properties
    
    let track: TrackModel
    let onUpdate: (TrackModel) -> Void
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var editedTrack: TrackModel
    @State private var showingDeleteConfirmation = false
    
    // MARK: - Initialization
    
    init(track: TrackModel, onUpdate: @escaping (TrackModel) -> Void, onDelete: @escaping () -> Void) {
        self.track = track
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _editedTrack = State(initialValue: track)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 音轨颜色指示
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: track.colorHex) ?? ColorTheme.primary)
                            .frame(height: 60)
                            .shadow(color: (Color(hex: track.colorHex) ?? ColorTheme.primary).opacity(0.5), radius: 10, x: 0, y: 5)
                        
                    // 名称编辑
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedString.TrackDetail.nameLabel)
                            .font(.subheadline.bold())
                            .foregroundColor(ColorTheme.textSecondary)
                        
                        TextField(LocalizedString.TrackDetail.namePlaceholder, text: $editedTrack.name)
                            .font(.body)
                            .foregroundColor(ColorTheme.textPrimary)
                            .padding()
                            .background(ColorTheme.inputBackground)
                            .cornerRadius(12)
                    }
                        
                        // 音量控制
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(LocalizedString.TrackDetail.volumeLabel)
                                    .font(.subheadline.bold())
                                    .foregroundColor(ColorTheme.textSecondary)
                                
                                Spacer()
                                
                                Text("\(Int(editedTrack.volume * 100))%")
                                    .font(.subheadline.bold())
                                    .foregroundColor(ColorTheme.textPrimary)
                            }
                            
                            Slider(value: $editedTrack.volume, in: 0...1)
                                .tint(Color(hex: track.colorHex) ?? ColorTheme.primary)
                        }
                        
                        // 开关控制
                        VStack(spacing: 16) {
                            Toggle(isOn: $editedTrack.muted) {
                                HStack {
                                    Image(systemName: "speaker.slash")
                                        .foregroundColor(ColorTheme.textSecondary)
                                    Text(LocalizedString.TrackDetail.muteLabel)
                                        .font(.subheadline)
                                        .foregroundColor(ColorTheme.textPrimary)
                                }
                            }
                            .tint(Color(hex: track.colorHex) ?? ColorTheme.primary)
                            
                            Toggle(isOn: $editedTrack.solo) {
                                HStack {
                                    Image(systemName: "headphones")
                                        .foregroundColor(ColorTheme.textSecondary)
                                    Text(LocalizedString.TrackDetail.soloLabel)
                                        .font(.subheadline)
                                        .foregroundColor(ColorTheme.textPrimary)
                                }
                            }
                            .tint(ColorTheme.accent)
                        }
                        .padding()
                        .background(ColorTheme.cardBackground)
                        .cornerRadius(12)
                        
                        // 删除按钮
                        Button(action: { showingDeleteConfirmation = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text(LocalizedString.TrackDetail.deleteButton)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorTheme.error)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(LocalizedString.TrackDetail.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedString.TrackDetail.cancel) {
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedString.TrackDetail.done) {
                        onUpdate(editedTrack)
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.primary)
                    .bold()
                }
            }
            .alert(LocalizedString.Track.Delete.title, isPresented: $showingDeleteConfirmation) {
                Button(LocalizedString.Track.Delete.cancel, role: .cancel) { }
                Button(LocalizedString.Track.Delete.confirm, role: .destructive) {
                    onDelete()
                    dismiss()
                }
            } message: {
                Text(LocalizedString.Track.Delete.message(track.name))
            }
        }
    }
}

#Preview {
    TrackDetailSheet(
        track: TrackModel(name: "鼓点", filePath: "track1.wav", colorHex: "#EF4444"),
        onUpdate: { _ in },
        onDelete: { }
    )
}
