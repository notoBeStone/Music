//
//  ProjectRepository.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation

/// 项目仓库错误
enum ProjectRepositoryError: LocalizedError {
    case projectNotFound
    case saveFailed(Error)
    case loadFailed(Error)
    case deleteFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .projectNotFound:
            return LocalizedString.Repository.projectNotFound
        case .saveFailed(let error):
            return LocalizedString.Repository.saveFailed(error.localizedDescription)
        case .loadFailed(let error):
            return LocalizedString.Repository.loadFailed(error.localizedDescription)
        case .deleteFailed(let error):
            return LocalizedString.Repository.deleteFailed(error.localizedDescription)
        }
    }
}

/// 项目数据持久化管理器
final class ProjectRepository {
    // MARK: - Singleton
    
    static let shared = ProjectRepository()
    
    // MARK: - Private Properties
    
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    // MARK: - Initialization
    
    private init() {
        // 配置 JSON 编码器
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.dateEncodingStrategy = .iso8601
        self.jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        // 配置 JSON 解码器
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        
        // 确保项目目录存在
        ensureProjectsDirectoryExists()
    }
    
    // MARK: - Public Methods
    
    /// 保存项目
    func save(_ project: ProjectModel) throws {
        let metadataURL = FileManager.projectMetadataURL(for: project.id)
        
        do {
            let data = try jsonEncoder.encode(project)
            try data.write(to: metadataURL, options: .atomic)
            
            print("[ProjectRepository] 保存项目：\(project.name)")
        } catch {
            print("[ProjectRepository] 保存项目失败：\(error.localizedDescription)")
            throw ProjectRepositoryError.saveFailed(error)
        }
    }
    
    /// 加载单个项目
    func load(_ projectId: UUID) throws -> ProjectModel {
        let metadataURL = FileManager.projectMetadataURL(for: projectId)
        
        guard FileManager.default.fileExists(atPath: metadataURL.path) else {
            throw ProjectRepositoryError.projectNotFound
        }
        
        do {
            let data = try Data(contentsOf: metadataURL)
            let project = try jsonDecoder.decode(ProjectModel.self, from: data)
            
            print("[ProjectRepository] 加载项目：\(project.name)")
            return project
        } catch {
            print("[ProjectRepository] 加载项目失败：\(error.localizedDescription)")
            throw ProjectRepositoryError.loadFailed(error)
        }
    }
    
    /// 加载所有项目
    func loadAll() throws -> [ProjectModel] {
        let projectsDir = FileManager.projectsDirectory
        
        guard let projectDirs = try? FileManager.default.contentsOfDirectory(
            at: projectsDir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        var projects: [ProjectModel] = []
        
        for projectDir in projectDirs {
            // 确保是目录
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: projectDir.path, isDirectory: &isDirectory),
                  isDirectory.boolValue else {
                continue
            }
            
            // 解析 UUID
            guard let projectId = UUID(uuidString: projectDir.lastPathComponent) else {
                continue
            }
            
            // 尝试加载项目
            if let project = try? load(projectId) {
                projects.append(project)
            }
        }
        
        // 按修改时间倒序排序
        projects.sort { $0.modifiedAt > $1.modifiedAt }
        
        print("[ProjectRepository] 加载了 \(projects.count) 个项目")
        return projects
    }
    
    /// 删除项目
    func delete(_ projectId: UUID) throws {
        do {
            try FileManager.deleteProject(projectId)
            print("[ProjectRepository] 删除项目：\(projectId)")
        } catch {
            print("[ProjectRepository] 删除项目失败：\(error.localizedDescription)")
            throw ProjectRepositoryError.deleteFailed(error)
        }
    }
    
    /// 复制项目
    func duplicate(_ projectId: UUID, newName: String) throws -> ProjectModel {
        // 加载原项目
        let originalProject = try load(projectId)
        
        // 创建新项目
        var newProject = ProjectModel(
            name: newName,
            bpm: originalProject.bpm,
            loopBars: originalProject.loopBars,
            tracks: []
        )
        
        // 创建新项目目录
        let newProjectDir = FileManager.projectDirectory(for: newProject.id)
        let originalProjectDir = FileManager.projectDirectory(for: projectId)
        
        // 复制所有音轨文件
        for originalTrack in originalProject.tracks {
            guard let originalFilePath = originalTrack.filePath else { continue }
            
            // 创建新音轨（保留所有属性）
            var newTrack = TrackModel(
                name: originalTrack.name,
                volume: originalTrack.volume,
                pan: originalTrack.pan,
                muted: originalTrack.muted,
                solo: originalTrack.solo,
                colorHex: originalTrack.colorHex,
                sourceType: originalTrack.sourceType
            )
            
            // 生成新的文件名
            let newFilePath = "\(newTrack.id.uuidString).wav"
            newTrack.filePath = newFilePath
            
            // 复制音频文件
            let originalFileURL = originalProjectDir.appendingPathComponent(originalFilePath)
            let newFileURL = newProjectDir.appendingPathComponent(newFilePath)
            
            if FileManager.default.fileExists(atPath: originalFileURL.path) {
                try FileManager.default.copyItem(at: originalFileURL, to: newFileURL)
            }
            
            newProject.tracks.append(newTrack)
        }
        
        // 保存新项目
        try save(newProject)
        
        print("[ProjectRepository] 复制项目：\(newProject.name)")
        return newProject
    }
    
    // MARK: - Private Methods
    
    /// 确保项目目录存在
    private func ensureProjectsDirectoryExists() {
        _ = FileManager.projectsDirectory // 这会自动创建目录
    }
}
