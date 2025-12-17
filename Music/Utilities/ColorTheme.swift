//
//  ColorTheme.swift
//  Music
//
//  Created by 彭瑞淋 on 2025/12/7.
//

import SwiftUI

/// 应用颜色主题管理
struct ColorTheme {
    
    // MARK: - 主题色 (Primary Colors)
    
    /// 主色调 - 紫色渐变起点（用于主要按钮、强调元素）
    static let primary = Color("7C3AED")  // 鲜艳的紫色
    
    /// 主色调变体 - 蓝紫色渐变终点
    static let primaryVariant = Color("3B82F6")  // 明亮的蓝色
    
    /// 次要色 - 青色（用于辅助元素、高亮）
    static let secondary = Color("06B6D4")  // 青色
    
    /// 强调色 - 粉色（用于录音、重要提示）
    static let accent = Color("EC4899")  // 粉色
    
    
    // MARK: - 背景色 (Background Colors)
    
    /// 主背景色 - 深灰黑
    static let background = Color("0F0F0F")
    
    /// 次级背景色 - 稍浅的深灰
    static let backgroundSecondary = Color("1A1A1A")
    
    /// 卡片/面板背景色
    static let cardBackground = Color("242424")
    
    /// 输入框/控件背景色
    static let inputBackground = Color("2A2A2A")
    
    
    // MARK: - 文本色 (Text Colors)
    
    /// 主要文本色 - 白色
    static let textPrimary = Color("FFFFFF")
    
    /// 次要文本色 - 浅灰色
    static let textSecondary = Color("A0A0A0")
    
    /// 禁用/提示文本色 - 深灰色
    static let textTertiary = Color("666666")
    
    /// 反色文本 - 黑色（用于浅色背景）
    static let textInverse = Color("000000")
    
    
    // MARK: - 功能色 (Functional Colors)
    
    /// 成功色 - 绿色
    static let success = Color("10B981")
    
    /// 警告色 - 橙色
    static let warning = Color("F59E0B")
    
    /// 错误色 - 红色
    static let error = Color("EF4444")
    
    /// 信息色 - 蓝色
    static let info = Color("3B82F6")
    
    
    // MARK: - 音轨颜色 (Track Colors)
    
    /// 预设的音轨颜色数组（用于区分不同音轨）
    static let trackColors: [Color] = [
        Color("EF4444"),  // 红色
        Color("F59E0B"),  // 橙色
        Color("10B981"),  // 绿色
        Color("3B82F6"),  // 蓝色
        Color("8B5CF6"),  // 紫色
        Color("EC4899"),  // 粉色
        Color("06B6D4"),  // 青色
        Color("F97316"),  // 深橙色
    ]
    
    /// 获取指定索引的音轨颜色
    static func trackColor(at index: Int) -> Color {
        return trackColors[index % trackColors.count]
    }
    
    
    // MARK: - 边框/分割线 (Borders & Dividers)
    
    /// 边框色
    static let border = Color("333333")
    
    /// 分割线色
    static let divider = Color("2A2A2A")
    
    /// 高亮边框色（用于选中状态）
    static let borderHighlight = Color("7C3AED")
    
    
    // MARK: - 渐变 (Gradients)
    
    /// 主题渐变（紫色到蓝色）
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primary, primaryVariant],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// 背景渐变（深色渐变）
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [background, backgroundSecondary],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    /// 玻璃态效果渐变
    static var glassGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.1),
                Color.white.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    
    // MARK: - 特殊效果 (Special Effects)
    
    /// 录音指示灯颜色（红色）
    static let recordingIndicator = Color("DC2626")
    
    /// 播放指示灯颜色（绿色）
    static let playingIndicator = Color("10B981")
    
    /// 波形颜色（青色）
    static let waveform = Color("06B6D4")
    
    /// 节拍器颜色（黄色）
    static let metronome = Color("FBBF24")
}


// MARK: - Color Extension

extension Color {
    /// 调整颜色亮度
    func adjustBrightness(_ amount: Double) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(
            hue: Double(hue),
            saturation: Double(saturation),
            brightness: Double(brightness) + amount,
            opacity: Double(alpha)
        )
    }
}


// MARK: - 预览

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // 主题色展示
            VStack(alignment: .leading, spacing: 10) {
                Text(LocalizedString.ColorTheme.primary)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                
                HStack(spacing: 15) {
                    ColorCard(color: ColorTheme.primary, name: "主色")
                    ColorCard(color: ColorTheme.primaryVariant, name: "主色变体")
                    ColorCard(color: ColorTheme.secondary, name: "次要色")
                    ColorCard(color: ColorTheme.accent, name: "强调色")
                }
            }
            .padding()
            .background(ColorTheme.cardBackground)
            .cornerRadius(12)
            
            // 功能色展示
            VStack(alignment: .leading, spacing: 10) {
                Text(LocalizedString.ColorTheme.functional)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                
                HStack(spacing: 15) {
                    ColorCard(color: ColorTheme.success, name: "成功")
                    ColorCard(color: ColorTheme.warning, name: "警告")
                    ColorCard(color: ColorTheme.error, name: "错误")
                    ColorCard(color: ColorTheme.info, name: "信息")
                }
            }
            .padding()
            .background(ColorTheme.cardBackground)
            .cornerRadius(12)
            
            // 音轨颜色展示
            VStack(alignment: .leading, spacing: 10) {
                Text(LocalizedString.ColorTheme.tracks)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 10) {
                    ForEach(0..<ColorTheme.trackColors.count, id: \.self) { index in
                        ColorCard(color: ColorTheme.trackColors[index], name: "音轨\(index + 1)")
                    }
                }
            }
            .padding()
            .background(ColorTheme.cardBackground)
            .cornerRadius(12)
            
            // 渐变展示
            VStack(alignment: .leading, spacing: 10) {
                Text(LocalizedString.ColorTheme.gradients)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                
                VStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ColorTheme.primaryGradient)
                        .frame(height: 60)
                        .overlay(
                            Text(LocalizedString.ColorTheme.Gradient.primary)
                                .foregroundColor(.white)
                                .font(.subheadline)
                        )
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ColorTheme.backgroundGradient)
                        .frame(height: 60)
                        .overlay(
                            Text(LocalizedString.ColorTheme.Gradient.background)
                                .foregroundColor(ColorTheme.textPrimary)
                                .font(.subheadline)
                        )
                }
            }
            .padding()
            .background(ColorTheme.cardBackground)
            .cornerRadius(12)
        }
        .padding()
    }
    .background(ColorTheme.background)
}

struct ColorCard: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 60)
                .shadow(color: color.opacity(0.5), radius: 5, x: 0, y: 2)
            
            Text(name)
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
}
