//
//  StatisticsCard.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI

struct StatisticsCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.small) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.titleFont)
                .fontWeight(.bold)
                .foregroundColor(.textPrimaryColor)
            
            Text(title)
                .font(.secondaryTextFont)
                .foregroundColor(.textSecondaryColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.standard)
        .background(Color.white)
        .cornerRadius(CornerRadius.card)
        .cardShadow()
    }
}

#Preview {
    LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
    ], spacing: 16) {
        StatisticsCard(
            icon: "figure.run",
            title: "Всего тренировок",
            value: "25",
            color: .primaryColor
        )
        
        StatisticsCard(
            icon: "clock.fill",
            title: "Общее время",
            value: "12ч 30м",
            color: .successColor
        )
    }
    .padding()
} 