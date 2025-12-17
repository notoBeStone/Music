//
//  AudioExporter.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation
import AVFoundation

/// 音频导出格式
enum AudioExportFormat {
    case wav
    case m4a
    case mp3
    
    var fileExtension: String {
        switch self {
        case .wav: return "wav"
        case .m4a: return "m4a"
        case .mp3: return "mp3"
        }
    }
    
    var displayName: String {
        switch self {
        case .wav: return LocalizedString.Export.wav
        case .m4a: return LocalizedString.Export.m4a
        case .mp3: return LocalizedString.Export.mp3
        }
    }
}

/// 音频导出管理器
final class AudioExporter {
    // MARK: - Singleton
    
    static let shared = AudioExporter()
    
    // MARK: - Private Properties
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 导出项目混音
    func exportMixdown(
        project: ProjectModel,
        format: AudioExportFormat = .m4a,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // 创建导出目录
                let exportDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("Exports")
                
                if !FileManager.default.fileExists(atPath: exportDir.path) {
                    try FileManager.default.createDirectory(at: exportDir, withIntermediateDirectories: true)
                }
                
                // 生成导出文件名
                let timestamp = Int(Date().timeIntervalSince1970)
                let fileName = "\(project.name)_\(timestamp).\(format.fileExtension)"
                let exportURL = exportDir.appendingPathComponent(fileName)
                
                // 混音所有轨道
                try self.mixTracks(project: project, outputURL: exportURL, format: format)
                
                DispatchQueue.main.async {
                    completion(.success(exportURL))
                    print("[AudioExporter] 导出成功：\(fileName)")
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("[AudioExporter] 导出失败：\(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// 混音所有轨道
    private func mixTracks(project: ProjectModel, outputURL: URL, format: AudioExportFormat) throws {
        let projectDir = FileManager.projectDirectory(for: project.id)
        let sampleRate: Double = 48000.0
        let channels: AVAudioChannelCount = 2
        
        // 创建音频格式
        guard let audioFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: channels,
            interleaved: false
        ) else {
            throw NSError(domain: "AudioExporter", code: -1, userInfo: [NSLocalizedDescriptionKey: LocalizedString.Exporter.formatCreationFailed])
        }
        
        // 计算总长度（帧数）
        let totalFrames = AVAudioFrameCount(project.loopLength * sampleRate)
        
        // 创建混音缓冲区
        guard let mixBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: totalFrames) else {
            throw NSError(domain: "AudioExporter", code: -2, userInfo: [NSLocalizedDescriptionKey: LocalizedString.Exporter.bufferCreationFailed])
        }
        
        mixBuffer.frameLength = totalFrames
        
        // 清空缓冲区
        if let leftChannel = mixBuffer.floatChannelData?[0],
           let rightChannel = mixBuffer.floatChannelData?[1] {
            memset(leftChannel, 0, Int(totalFrames) * MemoryLayout<Float>.size)
            memset(rightChannel, 0, Int(totalFrames) * MemoryLayout<Float>.size)
        }
        
        // 混合所有音轨
        for track in project.tracks where track.hasAudio && !track.muted {
            guard let filePath = track.filePath else { continue }
            
            let trackURL = projectDir.appendingPathComponent(filePath)
            
            guard FileManager.default.fileExists(atPath: trackURL.path) else {
                print("[AudioExporter] 音轨文件不存在：\(filePath)")
                continue
            }
            
            // 读取音轨文件
            let trackFile = try AVAudioFile(forReading: trackURL)
            
            // 读取音频数据
            let trackFrameCount = min(AVAudioFrameCount(trackFile.length), totalFrames)
            guard let trackBuffer = AVAudioPCMBuffer(pcmFormat: trackFile.processingFormat, frameCapacity: trackFrameCount) else {
                continue
            }
            
            try trackFile.read(into: trackBuffer, frameCount: trackFrameCount)
            trackBuffer.frameLength = trackFrameCount
            
            // 转换格式（如果需要）
            let converter = AVAudioConverter(from: trackFile.processingFormat, to: audioFormat)
            guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: trackFrameCount) else {
                continue
            }
            
            var error: NSError?
            converter?.convert(to: convertedBuffer, error: &error) { inNumPackets, outStatus in
                outStatus.pointee = .haveData
                return trackBuffer
            }
            
            if let error = error {
                print("[AudioExporter] 格式转换失败：\(error.localizedDescription)")
                continue
            }
            
            // 混合到主缓冲区
            mixAudioBuffer(convertedBuffer, into: mixBuffer, volume: track.volume, pan: track.pan)
            
            print("[AudioExporter] 混合音轨：\(track.name)")
        }
        
        // 写入文件
        try writeBuffer(mixBuffer, to: outputURL, format: format)
    }
    
    /// 混合缓冲区
    private func mixAudioBuffer(_ source: AVAudioPCMBuffer, into destination: AVAudioPCMBuffer, volume: Float, pan: Float) {
        guard let srcLeft = source.floatChannelData?[0],
              let srcRight = source.floatChannelData?[1] ?? source.floatChannelData?[0],
              let dstLeft = destination.floatChannelData?[0],
              let dstRight = destination.floatChannelData?[1] else {
            return
        }
        
        let frameCount = min(source.frameLength, destination.frameLength)
        
        // 计算左右声道增益
        let leftGain = volume * (1.0 - max(0, pan))
        let rightGain = volume * (1.0 + min(0, pan))
        
        for i in 0..<Int(frameCount) {
            dstLeft[i] += srcLeft[i] * leftGain
            dstRight[i] += srcRight[i] * rightGain
        }
    }
    
    /// 写入缓冲区到文件
    private func writeBuffer(_ buffer: AVAudioPCMBuffer, to url: URL, format: AudioExportFormat) throws {
        let settings: [String: Any]
        
        switch format {
        case .wav:
            settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: buffer.format.sampleRate,
                AVNumberOfChannelsKey: buffer.format.channelCount,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false
            ]
        case .m4a:
            settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: buffer.format.sampleRate,
                AVNumberOfChannelsKey: buffer.format.channelCount,
                AVEncoderBitRateKey: 256000
            ]
        case .mp3:
            // MP3 需要使用 lame 库或其他编码器，这里先使用 M4A
            settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: buffer.format.sampleRate,
                AVNumberOfChannelsKey: buffer.format.channelCount,
                AVEncoderBitRateKey: 320000
            ]
        }
        
        // 创建输出文件
        let outputFile = try AVAudioFile(
            forWriting: url,
            settings: settings,
            commonFormat: .pcmFormatInt16,
            interleaved: true
        )
        
        // 写入数据
        try outputFile.write(from: buffer)
        
        print("[AudioExporter] 写入文件：\(url.lastPathComponent)")
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
