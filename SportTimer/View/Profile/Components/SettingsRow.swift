//
//  SettingsRow.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: Content
    
    init(icon: String, title: String, color: Color, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: Spacing.standard) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.bodyFont)
                .foregroundColor(.textPrimaryColor)
            
            Spacer()
            
            content
        }
        .padding(Spacing.standard)
    }
}

#Preview {
    VStack(spacing: 0) {
        SettingsRow(
            icon: "speaker.wave.2.fill",
            title: "Звуки таймера",
            color: .primaryColor
        ) {
            Toggle("", isOn: .constant(true))
                .labelsHidden()
        }
        
        Divider()
        
        SettingsRow(
            icon: "bell.fill",
            title: "Уведомления",
            color: .warningColor
        ) {
            Toggle("", isOn: .constant(false))
                .labelsHidden()
        }
        
        Divider()
        
        SettingsRow(
            icon: "info.circle.fill",
            title: "Версия",
            color: .primaryColor
        ) {
            Text("1.0.0")
                .font(.bodyFont)
                .foregroundColor(.textSecondaryColor)
        }
    }
    .background(Color.white)
    .cornerRadius(CornerRadius.card)
    .cardShadow()
    .padding()
} 