//
//  EmptyStateView.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: Spacing.standard) {
            Image(systemName: "figure.run")
                .font(.system(size: 50))
                .foregroundColor(.textSecondaryColor)
            
            Text("Пока нет тренировок")
                .font(.subtitleFont)
                .foregroundColor(.textSecondaryColor)
            
            Text("Нажмите \"Начать тренировку\" чтобы добавить первую")
                .font(.bodyFont)
                .foregroundColor(.textSecondaryColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(CornerRadius.card)
        .cardShadow()
    }
}

#Preview {
    EmptyStateView()
        .padding()
} 