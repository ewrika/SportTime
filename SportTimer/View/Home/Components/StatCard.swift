//
//  StatCard.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.secondaryTextFont)
                .foregroundColor(.textSecondaryColor)
            
            Text(value)
                .font(.subtitleFont)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.standard)
        .background(Color.white)
        .cornerRadius(CornerRadius.card)
        .cardShadow()
    }
}

#Preview {
    StatCard(
        title: "Всего тренировок",
        value: "12",
        color: .primaryColor
    )
    .padding()
} 