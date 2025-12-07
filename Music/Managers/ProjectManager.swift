//
//  ProjectManager.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation
import AVFoundation

/// 项目管理错误
enum ProjectManagerError: LocalizedError {
    case projectNotFound
    case saveFailed
    case loadFailed
    case deleteFailed
    case exportFailed
    
    var errorDescription: String? {
        switch self {
        case .projectNotFound:
            return "项目不存在"
        case .saveFailed:
            return "保存项目失败"
        case .loadFailed:
            return "加载项目失败"
        case .deleteFailed:
            return "删除项目失败"
        case .exportFailed:
            return "导出音频失败"
        }
    }
}

/// 项目持久化管理器
@MainActor
final class ProjectManager: ObservableObject {
    // MARK: - Published Properties
    
    /// 所有项目列表
    @Published var projects: [Project] = []
    
    // MARK: - Private Properties
    
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    // MARK: - Initialization
    
    init() {
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.dateEncodingStrategy = .iso8601
        self.jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        
        loadAllProjects()
    }
    
    // MARK: - CRUD Operations
    
    /// 创建新项目
    func createProject(name: String) throws -> Project {
        let project = Project(name: name)
        
        // 创建项目目录
        let projectDir = FileManager.projectDirectory(for: project.id)
        try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)
        
        // 保存项目元数据
        try saveProject(project)
        
        // 添加到列表
        projects.append(project)
        
        print("[ProjectManager] 创建项目：\(name)")
        
        return project
    }
    
    /// 保存项目
    func saveProject(_ project: Project) throws {
        let metadataURL = FileManager.projectMetadataURL(for: project.id)
        
        do {
            let data = try jsonEncoder.encode(project)
            try data.write(to: metadataURL)
            
            // 更新列表中的项目
            if let index = projects.firstIndex(where: { $0.id == project.id }) {
                projects[index] = project
            }
            
            print("[ProjectManager] 保存项目：\(project.name)")
        } catch {
            print("[ProjectManager] 保存项目失败：\(error.localizedDescription)")
            throw ProjectManagerError.saveFailed
        }
    }
    
    /// 加载单个项目
    func loadProject(_ projectId: UUID) throws -> Project {
        let metadataURL = FileManager.projectMetadataURL(for: projectId)
        
        guard FileManager.default.fileExists(atPath: metadataURL.path) else {
            throw ProjectManagerError.projectNotFound
        }
        
        do {
            let data = try Data(contentsOf: metadataURL)
            let project = try jsonDecoder.decode(Project.self, from: data)
            
            print("[ProjectManager] 加载项目：\(project.name)")
            
            return project
        } catch {
            print("[ProjectManager] 加载项目失败：\(error.localizedDescription)")
            throw ProjectManagerError.loadFailed
        }
    }
    
    /// 加载所有项目
    func loadAllProjects() {
        let projectsDir = FileManager.projectsDirectory
        
        guard let projectDirs = try? FileManager.default.contentsOfDirectory(
            at: projectsDir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            print("[ProjectManager] 无法读取项目目录")
            return
        }
        
        var loadedProjects: [Project] = []
        
        for projectDir in projectDirs {
            guard let projectId = UUID(uuidString: projectDir.lastPathComponent) else {
                continue
            }
            
            if let project = try? loadProject(projectId) {
                loadedProjects.append(project)
            }
        }
        
        // 按修改时间倒序排序
        loadedProjects.sort { $0.modifiedAt > $1.modifiedAt }
        
        projects = loadedProjects
        
        print("[ProjectManager] 加载了 \(projects.count) 个项目")
    }
    
    /// 删除项目
    func deleteProject(_ projectId: UUID) throws {
        do {
            try FileManager.deleteProject(projectId)
            projects.removeAll { $0.id == projectId }
            
            print("[ProjectManager] 删除项目：\(projectId)")
        } catch {
            print("[ProjectManager] 删除项目失败：\(error.localizedDescription)")
            throw ProjectManagerError.deleteFailed
        }
    }
    
    /// 重命名项目
    func renameProject(_ projectId: UUID, newName: String) throws {
        guard var project = projects.first(where: { $0.id == projectId }) else {
            throw ProjectManagerError.projectNotFound
        }
        
        project.name = newName
        project.modifiedAt = Date()
        
        try saveProject(project)
        
        print("[ProjectManager] 重命名项目：\(newName)")
    }
    
    /// 复制项目
    func duplicateProject(_ projectId: UUID) throws -> Project {
        guard let originalProject = projects.first(where: { $0.id == projectId }) else {
            throw ProjectManagerError.projectNotFound
        }
        
        // 创建新项目
        var newProject = Project(
            name: "\(originalProject.name) 副本",
            tracks: [],
            audioSettings: originalProject.audioSettings
        )
        
        // 创建项目目录
        let newProjectDir = FileManager.projectDirectory(for: newProject.id)
        try FileManager.default.createDirectory(at: newProjectDir, withIntermediateDirectories: true)
        
        // 复制音轨文件
        let originalProjectDir = FileManager.projectDirectory(for: projectId)
        
        for originalTrack in originalProject.tracks {
            let newTrack = Track(
                name: originalTrack.name,
                filePath: originalTrack.filePath,
                volume: originalTrack.volume,
                pan: originalTrack.pan,
                isMuted: originalTrack.isMuted,
                isSolo: originalTrack.isSolo,
                colorIndex: originalTrack.colorIndex
            )
            
            // 复制音频文件
            let originalFileURL = originalTrack.fullURL(in: originalProjectDir)
            let newFileURL = FileManager.trackFileURL(for: newProject.id, trackId: newTrack.id)
            
            if FileManager.default.fileExists(atPath: originalFileURL.path) {
                try FileManager.default.copyItem(at: originalFileURL, to: newFileURL)
            }
            
            newProject.tracks.append(newTrack)
        }
        
        // 保存新项目
        try saveProject(newProject)
        
        projects.append(newProject)
        
        print("[ProjectManager] 复制项目：\(newProject.name)")
        
        return newProject
    }
    
    // MARK: - Export Operations
    
    /// 导出项目为音频文件
    func exportProject(_ projectId: UUID, format: AudioExportFormat) async throws -> URL {
        guard let project = projects.first(where: { $0.id == projectId }) else {
            throw ProjectManagerError.projectNotFound
        }
        
        // 创建导出目录
        let exportDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Exports")
        
        if !FileManager.default.fileExists(atPath: exportDir.path) {
            try FileManager.default.createDirectory(at: exportDir, withIntermediateDirectories: true)
        }
        
        // 生成导出文件名
        let timestamp = Date().timeIntervalSince1970
        let fileName = "\(project.name)_\(Int(timestamp)).\(format.fileExtension)"
        let exportURL = exportDir.appendingPathComponent(fileName)
        
        // 混音所有轨道
        try await mixTracks(project: project, outputURL: exportURL, format: format)
        
        print("[ProjectManager] 导出项目：\(exportURL.lastPathComponent)")
        
        return exportURL
    }
    
    /// 混音所有轨道
    private func mixTracks(project: Project, outputURL: URL, format: AudioExportFormat) async throws {
        let projectDir = FileManager.projectDirectory(for: project.id)
        
        // 创建音频引擎
        let engine = AVAudioEngine()
        let mainMixer = engine.mainMixerNode
        
        // 加载所有音轨
        var playerNodes: [(AVAudioPlayerNode, AVAudioFile)] = []
        
        for track in project.tracks where !track.isMuted {
            let fileURL = track.fullURL(in: projectDir)
            
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                continue
            }
            
            let audioFile = try AVAudioFile(forReading: fileURL)
            let playerNode = AVAudioPlayerNode()
            
            engine.attach(playerNode)
            engine.connect(playerNode, to: mainMixer, format: audioFile.processingFormat)
            
            playerNode.volume = track.volume
            playerNode.pan = track.pan
            
            playerNodes.append((playerNode, audioFile))
        }
        
        // 配置输出格式
        guard let outputFormat = project.audioSettings.audioFormat else {
            throw ProjectManagerError.exportFailed
        }
        
        // 创建输出文件
        let outputFile = try AVAudioFile(
            forWriting: outputURL,
            settings: outputFormat.settings,
            commonFormat: .pcmFormatInt16,
            interleaved: true
        )
        
        // 启动引擎
        try engine.start()
        
        // 调度所有播放器
        for (playerNode, audioFile) in playerNodes {
            playerNode.scheduleFile(audioFile, at: nil)
            playerNode.play()
        }
        
        // 录制混音输出
        mainMixer.installTap(onBus: 0, bufferSize: 4096, format: outputFormat) { buffer, _ in
            do {
                try outputFile.write(from: buffer)
            } catch {
                print("[ProjectManager] 写入音频失败：\(error.localizedDescription)")
            }
        }
        
        // 等待播放完成
        let duration = project.audioSettings.loopLength
        try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        
        // 停止引擎
        mainMixer.removeTap(onBus: 0)
        engine.stop()
        
        print("[ProjectManager] 混音完成")
    }
}

// MARK: - Audio Export Format

enum AudioExportFormat {
    case wav
    case mp3
    case m4a
    
    var fileExtension: String {
        switch self {
        case .wav: return "wav"
        case .mp3: return "mp3"
        case .m4a: return "m4a"
        }
    }
    
    var displayName: String {
        switch self {
        case .wav: return "WAV (无损)"
        case .mp3: return "MP3 (压缩)"
        case .m4a: return "M4A (AAC)"
        }
    }
}

