//
//  CircularProgressView.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI

struct CircularProgressView: View {
    let formattedTime: String
    let isRunning: Bool
    let progress: Double
    let totalTime: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.standard) {
            ZStack {
                // Фоновый круг
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 250, height: 250)
                
                // Прогресс круг (опционально, если нужен таймер обратного отсчета)
                if totalTime > 0 {
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(color, lineWidth: 8)
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                }
                
                // Время в центре
                VStack {
                    Text(formattedTime)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.textPrimaryColor)
                    
                    Text(isRunning ? "Тренировка" : "Готов к старту")
                        .font(.bodyFont)
                        .foregroundColor(.textSecondaryColor)
                }
            }
            .padding(.vertical, Spacing.standard)
        }
    }
}

#Preview {
    CircularProgressView(
        formattedTime: "15:30",
        isRunning: true,
        progress: 0.6,
        totalTime: 3600,
        color: .primaryColor
    )
    .padding()
} 