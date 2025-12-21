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
    
    /// 主色调 - 活力橙（用于主要按钮、强调元素）
    static let primary = Color(hex: "FF6B35")!  // 活力橙
    
    /// 主色调变体 - 温暖橙
    static let primaryVariant = Color(hex: "F7931E")!  // 温暖橙
    
    /// 次要色 - 金黄色（用于辅助元素、高亮）
    static let secondary = Color(hex: "FFC857")!  // 金黄
    
    /// 强调色 - 录音红（用于录音、重要提示）
    static let accent = Color(hex: "DC2626")!  // 录音红
    
    
    // MARK: - 背景色 (Background Colors)
    
    /// 主背景色 - 深灰黑
    static let background = Color(hex: "0F0F0F")!
    
    /// 次级背景色 - 稍浅的深灰
    static let backgroundSecondary = Color(hex: "1A1A1A")!
    
    /// 卡片/面板背景色
    static let cardBackground = Color(hex: "242424")!
    
    /// 输入框/控件背景色
    static let inputBackground = Color(hex: "2A2A2A")!
    
    
    // MARK: - 文本色 (Text Colors)
    
    /// 主要文本色 - 白色
    static let textPrimary = Color(hex: "FFFFFF")!
    
    /// 次要文本色 - 浅灰色
    static let textSecondary = Color(hex: "A0A0A0")!
    
    /// 禁用/提示文本色 - 深灰色
    static let textTertiary = Color(hex: "666666")!
    
    /// 反色文本 - 黑色（用于浅色背景）
    static let textInverse = Color(hex: "000000")!
    
    
    // MARK: - 功能色 (Functional Colors)
    
    /// 成功色 - 绿色
    static let success = Color(hex: "10B981")!
    
    /// 警告色 - 橙色
    static let warning = Color(hex: "F59E0B")!
    
    /// 错误色 - 红色
    static let error = Color(hex: "EF4444")!
    
    /// 信息色 - 蓝色
    static let info = Color(hex: "3B82F6")!
    
    
    // MARK: - 音轨颜色 (Track Colors)
    
    /// 预设的音轨颜色数组（用于区分不同音轨）
    static let trackColors: [Color] = [
        Color(hex: "FF6B35")!,  // 活力橙
        Color(hex: "FFC857")!,  // 金黄
        Color(hex: "F59E0B")!,  // 橙色
        Color(hex: "FBBF24")!,  // 亮黄
        Color(hex: "EF4444")!,  // 红色
        Color(hex: "F97316")!,  // 深橙色
        Color(hex: "FDBA74")!,  // 浅橙
        Color(hex: "FB923C")!,  // 中橙
    ]
    
    /// 获取指定索引的音轨颜色
    static func trackColor(at index: Int) -> Color {
        return trackColors[index % trackColors.count]
    }
    
    
    // MARK: - 边框/分割线 (Borders & Dividers)
    
    /// 边框色
    static let border = Color(hex: "333333")!
    
    /// 分割线色
    static let divider = Color(hex: "2A2A2A")!
    
    /// 高亮边框色（用于选中状态）
    static let borderHighlight = Color(hex: "FF6B35")!
    
    
    // MARK: - 渐变 (Gradients)
    
    /// 主题渐变（橙色到金黄）
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primary, primaryVariant, secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// 日落渐变（用于背景装饰）
    static var sunsetGradient: LinearGradient {
        LinearGradient(
            colors: [
                primary.opacity(0.8),
                primaryVariant.opacity(0.6),
                secondary.opacity(0.4)
            ],
            startPoint: .top,
            endPoint: .bottom
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
    static let recordingIndicator = Color(hex: "DC2626")!
    
    /// 播放指示灯颜色（绿色）
    static let playingIndicator = Color(hex: "10B981")!
    
    /// 波形颜色（金黄色）
    static let waveform = Color(hex: "FFC857")!
    
    /// 节拍器颜色（黄色）
    static let metronome = Color(hex: "FBBF24")!
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
