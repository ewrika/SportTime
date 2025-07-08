//
//  TimerControlButtons.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI

struct TimerControlButtons: View {
    let isRunning: Bool
    let isCompleted: Bool
    let elapsedTime: Int
    let onPlayPause: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.standard) {
            // Кнопка Старт/Пауза
            Button(action: onPlayPause) {
                HStack {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                    Text(isRunning ? "Пауза" : "Старт")
                        .font(.subtitleFont)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isRunning ? Color.warningColor : Color.successColor)
                .cornerRadius(CornerRadius.button)
                .cardShadow()
            }
            .disabled(isCompleted)
            
            // Кнопка Стоп
            Button(action: onStop) {
                HStack {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                    Text("Стоп")
                        .font(.subtitleFont)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.dangerColor)
                .cornerRadius(CornerRadius.button)
                .cardShadow()
            }
            .disabled(!isRunning && elapsedTime == 0)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TimerControlButtons(
            isRunning: false,
            isCompleted: false,
            elapsedTime: 0,
            onPlayPause: {},
            onStop: {}
        )
        
        TimerControlButtons(
            isRunning: true,
            isCompleted: false,
            elapsedTime: 300,
            onPlayPause: {},
            onStop: {}
        )
    }
    .padding()
} 