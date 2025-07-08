//
//  Constants.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import Foundation
import SwiftUI

extension Color {
    static let primaryColor = Color(hex: "#007AFF")
    static let secondaryColor = Color(hex: "#FF9500")
    static let successColor = Color(hex: "#34C759")
    static let warningColor = Color(hex: "#FF9500")
    static let dangerColor = Color(hex: "#FF3B30")
    static let backgroundColor = Color(hex: "#F2F2F7")
    static let textPrimaryColor = Color(hex: "#000000")
    static let textSecondaryColor = Color(hex: "#6D6D70")
}

extension Font {
    static let titleFont = Font.system(size: 28, weight: .bold)
    static let subtitleFont = Font.system(size: 18, weight: .semibold)
    static let bodyFont = Font.system(size: 16, weight: .regular)
    static let secondaryTextFont = Font.system(size: 14, weight: .regular)
}

struct CornerRadius {
    static let card: CGFloat = 12
    static let button: CGFloat = 8
}

struct Spacing {
    static let standard: CGFloat = 16
    static let small: CGFloat = 8
}

extension View {
    func cardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        
        if hex.hasPrefix("#") {
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
        }
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255
        let b = Double(rgbValue & 0x0000FF) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Workout Types
enum WorkoutType: String, CaseIterable {
    case strength = "Strength"
    case cardio = "Cardio"
    case yoga = "Yoga"
    case stretching = "Stretching"
    case other = "Other"
    
    var displayName: String {
        switch self {
        case .strength:
            return "Силовая тренировка"
        case .cardio:
            return "Кардио"
        case .yoga:
            return "Йога"
        case .stretching:
            return "Растяжка"
        case .other:
            return "Другое"
        }
    }
    
    var icon: String {
        switch self {
        case .strength:
            return "dumbbell.fill"
        case .cardio:
            return "heart.fill"
        case .yoga:
            return "leaf.fill"
        case .stretching:
            return "figure.flexibility"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .strength:
            return .dangerColor
        case .cardio:
            return .primaryColor
        case .yoga:
            return .successColor
        case .stretching:
            return .secondaryColor
        case .other:
            return .textSecondaryColor
        }
    }
}

extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
