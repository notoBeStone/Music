//
//  LocalizedString.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation

/// 本地化字符串管理
/// 提供类型安全的本地化字符串访问
enum LocalizedString {
    
    // MARK: - Project List
    
    enum ProjectList {
        static let title = NSLocalizedString("project_list.title", comment: "Project list navigation title")
        static let emptyTitle = NSLocalizedString("project_list.empty.title", comment: "Empty state title")
        static let emptyMessage = NSLocalizedString("project_list.empty.message", comment: "Empty state message")
        static let emptyCreateButton = NSLocalizedString("project_list.empty.create_button", comment: "Create project button in empty state")
        
        enum Create {
            static let title = NSLocalizedString("project_list.create.title", comment: "Create project sheet title")
            static let nameLabel = NSLocalizedString("project_list.create.name_label", comment: "Project name label")
            static let namePlaceholder = NSLocalizedString("project_list.create.name_placeholder", comment: "Project name placeholder")
            static let cancel = NSLocalizedString("project_list.create.cancel", comment: "Cancel button")
            static let confirm = NSLocalizedString("project_list.create.confirm", comment: "Create confirm button")
        }
        
        enum Card {
            static let tracks = NSLocalizedString("project_list.card.tracks", comment: "Tracks label")
            static let modified = NSLocalizedString("project_list.card.modified", comment: "Modified label")
        }
        
        enum Menu {
            static let open = NSLocalizedString("project_list.menu.open", comment: "Open menu item")
            static let duplicate = NSLocalizedString("project_list.menu.duplicate", comment: "Duplicate menu item")
            static let delete = NSLocalizedString("project_list.menu.delete", comment: "Delete menu item")
            static let options = NSLocalizedString("project_list.menu.options", comment: "Project options")
        }
    }
    
    // MARK: - Recording
    
    enum Recording {
        static let title = NSLocalizedString("recording.title", comment: "Recording view title")
        static let bpmLabel = NSLocalizedString("recording.bpm.label", comment: "BPM label")
        static let metronome = NSLocalizedString("recording.metronome", comment: "Metronome label")
        static let emptyTitle = NSLocalizedString("recording.empty.title", comment: "No tracks empty title")
        static let emptyMessage = NSLocalizedString("recording.empty.message", comment: "No tracks empty message")
        
        enum Controls {
            static let cancel = NSLocalizedString("recording.controls.cancel", comment: "Cancel recording button")
            static let recording = NSLocalizedString("recording.controls.recording", comment: "Recording status text")
        }
        
        enum Hint {
            static let recordNew = NSLocalizedString("recording.hint.record_new", comment: "Hint to record new track")
            static let start = NSLocalizedString("recording.hint.start", comment: "Hint to start recording")
            static let maxTracks = NSLocalizedString("recording.hint.max_tracks", comment: "Max tracks reached message")
        }
        
        enum Menu {
            static let export = NSLocalizedString("recording.menu.export", comment: "Export audio menu item")
            static let settings = NSLocalizedString("recording.menu.settings", comment: "Project settings menu item")
        }
    }
    
    // MARK: - Track
    
    enum Track {
        enum Delete {
            static let title = NSLocalizedString("track.delete.title", comment: "Delete track alert title")
            static func message(_ trackName: String) -> String {
                String(format: NSLocalizedString("track.delete.message", comment: "Delete track alert message"), trackName)
            }
            static let confirm = NSLocalizedString("track.delete.confirm", comment: "Delete confirm button")
            static let cancel = NSLocalizedString("track.delete.cancel", comment: "Delete cancel button")
        }
        
        static let soloLabel = NSLocalizedString("track.solo.label", comment: "Solo button label")
    }
    
    // MARK: - Metronome
    
    enum Metronome {
        static let label = NSLocalizedString("metronome.label", comment: "Metronome label")
        static func bpm(_ value: Int) -> String {
            String(format: NSLocalizedString("metronome.bpm", comment: "BPM with value"), value)
        }
    }
    
    // MARK: - Playback
    
    enum Playback {
        static let play = NSLocalizedString("playback.play", comment: "Play button")
        static let pause = NSLocalizedString("playback.pause", comment: "Pause button")
        static let stop = NSLocalizedString("playback.stop", comment: "Stop button")
    }
    
    // MARK: - Common
    
    enum Common {
        static let ok = NSLocalizedString("common.ok", comment: "OK button")
        static let cancel = NSLocalizedString("common.cancel", comment: "Cancel button")
        static let delete = NSLocalizedString("common.delete", comment: "Delete button")
        static let save = NSLocalizedString("common.save", comment: "Save button")
        static let error = NSLocalizedString("common.error", comment: "Error title")
    }
    
    // MARK: - Errors
    
    enum Error {
        enum Project {
            static let notFound = NSLocalizedString("error.project.not_found", comment: "Project not found error")
            static let saveFailed = NSLocalizedString("error.project.save_failed", comment: "Save failed error")
            static let loadFailed = NSLocalizedString("error.project.load_failed", comment: "Load failed error")
            static let deleteFailed = NSLocalizedString("error.project.delete_failed", comment: "Delete failed error")
            static let exportFailed = NSLocalizedString("error.project.export_failed", comment: "Export failed error")
        }
        
        enum Recorder {
            static let failed = NSLocalizedString("error.recorder.failed", comment: "Recording failed error")
            static let permissionDenied = NSLocalizedString("error.recorder.permission_denied", comment: "Permission denied error")
            static let sessionFailed = NSLocalizedString("error.recorder.session_failed", comment: "Session failed error")
            static let invalidSettings = NSLocalizedString("error.recorder.invalid_settings", comment: "Invalid settings error")
        }
        
        enum Player {
            static let fileNotFound = NSLocalizedString("error.player.file_not_found", comment: "File not found error")
            static let playbackFailed = NSLocalizedString("error.player.playback_failed", comment: "Playback failed error")
            static let invalidFile = NSLocalizedString("error.player.invalid_file", comment: "Invalid file error")
            static let engineNotStarted = NSLocalizedString("error.player.engine_not_started", comment: "Engine not started error")
        }
    }
    
    // MARK: - Color Theme
    
    enum ColorTheme {
        static let primary = NSLocalizedString("color_theme.primary", comment: "Primary colors label")
        static let functional = NSLocalizedString("color_theme.functional", comment: "Functional colors label")
        static let tracks = NSLocalizedString("color_theme.tracks", comment: "Track colors label")
        static let gradients = NSLocalizedString("color_theme.gradients", comment: "Gradient effects label")
        
        enum Gradient {
            static let primary = NSLocalizedString("color_theme.gradient.primary", comment: "Primary gradient label")
            static let background = NSLocalizedString("color_theme.gradient.background", comment: "Background gradient label")
        }
    }
    
    // MARK: - Export
    
    enum Export {
        static let wav = NSLocalizedString("export.format.wav", comment: "WAV format description")
        static let mp3 = NSLocalizedString("export.format.mp3", comment: "MP3 format description")
        static let m4a = NSLocalizedString("export.format.m4a", comment: "M4A format description")
    }
    
    // MARK: - Permissions
    
    enum Permission {
        static let microphoneTitle = NSLocalizedString("permission.microphone.title", comment: "Microphone permission title")
        static let microphoneMessage = NSLocalizedString("permission.microphone.message", comment: "Microphone permission message")
    }
    
    // MARK: - Track Detail
    
    enum TrackDetail {
        static let title = NSLocalizedString("track_detail.title", comment: "Track settings title")
        static let nameLabel = NSLocalizedString("track_detail.name_label", comment: "Track name label")
        static let namePlaceholder = NSLocalizedString("track_detail.name_placeholder", comment: "Track name placeholder")
        static let volumeLabel = NSLocalizedString("track_detail.volume_label", comment: "Volume label")
        static let muteLabel = NSLocalizedString("track_detail.mute_label", comment: "Mute label")
        static let soloLabel = NSLocalizedString("track_detail.solo_label", comment: "Solo label")
        static let deleteButton = NSLocalizedString("track_detail.delete_button", comment: "Delete button")
        static let cancel = NSLocalizedString("track_detail.cancel", comment: "Cancel button")
        static let done = NSLocalizedString("track_detail.done", comment: "Done button")
    }
    
    // MARK: - Export View
    
    enum ExportView {
        static let title = NSLocalizedString("export.title", comment: "Export title")
        static let formatLabel = NSLocalizedString("export.format_label", comment: "Format label")
        static let startButton = NSLocalizedString("export.start_button", comment: "Start export button")
        static let exporting = NSLocalizedString("export.exporting", comment: "Exporting status")
        static let exportingMessage = NSLocalizedString("export.exporting_message", comment: "Exporting message")
        static let successTitle = NSLocalizedString("export.success_title", comment: "Success title")
        static let successMessage = NSLocalizedString("export.success_message", comment: "Success message")
        static let shareButton = NSLocalizedString("export.share_button", comment: "Share button")
        static let doneButton = NSLocalizedString("export.done_button", comment: "Done button")
    }
    
    // MARK: - Main View
    
    enum MainView {
        static let backToProjects = NSLocalizedString("main.back_to_projects", comment: "Back to projects")
        
        enum Menu {
            static let export = NSLocalizedString("main.menu.export", comment: "Export menu item")
        }
        
        static let metronomeLabel = NSLocalizedString("main.metronome_label", comment: "Metronome label")
        
        enum Recording {
            static let cancel = NSLocalizedString("main.recording.cancel", comment: "Cancel recording")
            static let hintNew = NSLocalizedString("main.recording.hint_new", comment: "Hint to record new")
            static let hintStart = NSLocalizedString("main.recording.hint_start", comment: "Hint to start")
            static let maxTracks = NSLocalizedString("main.recording.max_tracks", comment: "Max tracks message")
        }
    }
    
    // MARK: - Track Card
    
    enum TrackCard {
        static let empty = NSLocalizedString("track_card.empty", comment: "Empty track")
        static let emptySlot = NSLocalizedString("track_card.empty_slot", comment: "Empty slot")
    }
    
    // MARK: - Audio Engine
    
    enum AudioEngine {
        static let notStarted = NSLocalizedString("audio_engine.not_started", comment: "Engine not started")
        static let recordingFailed = NSLocalizedString("audio_engine.recording_failed", comment: "Recording failed")
        static let playbackFailed = NSLocalizedString("audio_engine.playback_failed", comment: "Playback failed")
        static let permissionDenied = NSLocalizedString("audio_engine.permission_denied", comment: "Permission denied")
    }
    
    // MARK: - View Model
    
    enum ViewModel {
        static let noUndo = NSLocalizedString("viewmodel.no_undo", comment: "No undo")
        static let maxTracksReached = NSLocalizedString("viewmodel.max_tracks_reached", comment: "Max tracks")
        static func recordingFailed(_ error: String) -> String {
            String(format: NSLocalizedString("viewmodel.recording_failed", comment: "Recording failed"), error)
        }
        static func saveFailed(_ error: String) -> String {
            String(format: NSLocalizedString("viewmodel.save_failed", comment: "Save failed"), error)
        }
        static let nameRequired = NSLocalizedString("viewmodel.name_required", comment: "Name required")
    }
    
    // MARK: - Repository
    
    enum Repository {
        static let projectNotFound = NSLocalizedString("repository.project_not_found", comment: "Project not found")
        static func saveFailed(_ error: String) -> String {
            String(format: NSLocalizedString("repository.save_failed", comment: "Save failed"), error)
        }
        static func loadFailed(_ error: String) -> String {
            String(format: NSLocalizedString("repository.load_failed", comment: "Load failed"), error)
        }
        static func deleteFailed(_ error: String) -> String {
            String(format: NSLocalizedString("repository.delete_failed", comment: "Delete failed"), error)
        }
        static func exportFailed(_ error: String) -> String {
            String(format: NSLocalizedString("repository.export_failed", comment: "Export failed"), error)
        }
    }
    
    // MARK: - Exporter
    
    enum Exporter {
        static let formatCreationFailed = NSLocalizedString("exporter.format_creation_failed", comment: "Format creation failed")
        static let bufferCreationFailed = NSLocalizedString("exporter.buffer_creation_failed", comment: "Buffer creation failed")
    }
}


