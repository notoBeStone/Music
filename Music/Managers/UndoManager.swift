//
//  UndoManager.swift
//  Music
//
//  Created by AI on 2025/12/16.
//

import Foundation

/// 操作撤销管理器（简化版）
final class ProjectUndoManager {
    // MARK: - Properties
    
    /// 历史记录栈（最多保存10个快照）
    private var history: [ProjectModel] = []
    
    /// 最大历史记录数
    private let maxHistory = 10
    
    // MARK: - Public Methods
    
    /// 保存快照
    func saveSnapshot(_ project: ProjectModel) {
        history.append(project)
        
        // 限制历史记录数量
        if history.count > maxHistory {
            history.removeFirst()
        }
        
        print("[UndoManager] 保存快照，当前历史：\(history.count)")
    }
    
    /// 撤销（返回上一个快照）
    func undo() -> ProjectModel? {
        guard history.count > 1 else {
            print("[UndoManager] 没有可撤销的操作")
            return nil
        }
        
        // 移除当前状态
        history.removeLast()
        
        // 返回上一个状态
        let previousState = history.last
        print("[UndoManager] 撤销到上一个状态")
        
        return previousState
    }
    
    /// 是否可以撤销
    func canUndo() -> Bool {
        return history.count > 1
    }
    
    /// 清空历史
    func clear() {
        history.removeAll()
        print("[UndoManager] 清空历史")
    }
    
    /// 获取历史记录数量
    var historyCount: Int {
        return history.count
    }
}
