//
//  ContentView.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/8.
//

import SwiftUI

/// 主视图容器
struct ContentView: View {
    // MARK: - Properties
    
    @EnvironmentObject private var projectManager: ProjectManager
    
    // MARK: - Body
    
    var body: some View {
        ProjectListView(projectManager: projectManager)
    }
}

#Preview {
    ContentView()
        .environmentObject(ProjectManager())
}
