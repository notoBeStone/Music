//
//  FileManager+Extensions.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import Foundation

extension FileManager {
    /// 获取项目根目录
    static var projectsDirectory: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let projectsDir = documentsDirectory.appendingPathComponent("Projects")
        
        // 确保目录存在
        if !FileManager.default.fileExists(atPath: projectsDir.path) {
            try? FileManager.default.createDirectory(at: projectsDir, withIntermediateDirectories: true)
        }
        
        return projectsDir
    }
    
    /// 获取指定项目的目录
    static func projectDirectory(for projectId: UUID) -> URL {
        let projectDir = projectsDirectory.appendingPathComponent(projectId.uuidString)
        
        // 确保目录存在
        if !FileManager.default.fileExists(atPath: projectDir.path) {
            try? FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)
        }
        
        return projectDir
    }
    
    /// 获取项目元数据文件路径
    static func projectMetadataURL(for projectId: UUID) -> URL {
        return projectDirectory(for: projectId).appendingPathComponent("project.json")
    }
    
    /// 删除项目目录
    static func deleteProject(_ projectId: UUID) throws {
        let projectDir = projectDirectory(for: projectId)
        try FileManager.default.removeItem(at: projectDir)
    }
    
    /// 获取项目中的音频文件路径
    static func trackFileURL(for projectId: UUID, trackId: UUID) -> URL {
        return projectDirectory(for: projectId).appendingPathComponent("\(trackId.uuidString).wav")
    }
    
    /// 获取临时录音文件路径
    static var temporaryRecordingURL: URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("temp_recording_\(UUID().uuidString).wav")
    }
    
    /// 计算目录大小
    static func directorySize(at url: URL) -> Int64 {
        var size: Int64 = 0
        
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    size += Int64(fileSize)
                }
            }
        }
        
        return size
    }
}

