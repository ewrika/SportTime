//
//  WorkoutCard.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI
import CoreData

struct WorkoutCard: View {
    let workout: Workout
    let viewModel: WorkoutViewModel
    
    var body: some View {
        HStack(spacing: Spacing.standard) {
            // Иконка типа тренировки
            VStack {
                Image(systemName: viewModel.getWorkoutTypeFromString(workout.type ?? "").icon)
                    .font(.title2)
                    .foregroundColor(viewModel.getWorkoutTypeFromString(workout.type ?? "").color)
                    .frame(width: 40, height: 40)
                    .background(
                        viewModel.getWorkoutTypeFromString(workout.type ?? "").color.opacity(0.1)
                    )
                    .cornerRadius(8)
            }
            
            // Информация о тренировке
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.getWorkoutTypeFromString(workout.type ?? "").displayName)
                    .font(.bodyFont)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimaryColor)
                
                HStack {
                    Text(viewModel.formatDuration(workout.duration))
                        .font(.secondaryTextFont)
                        .foregroundColor(.textSecondaryColor)
                    
                    Spacer()
                    
                    Text(formatDate(workout.date ?? Date()))
                        .font(.secondaryTextFont)
                        .foregroundColor(.textSecondaryColor)
                }
            }
            
            Spacer()
        }
        .padding(Spacing.standard)
        .background(Color.white)
        .cornerRadius(CornerRadius.card)
        .cardShadow()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let viewModel = WorkoutViewModel(context: context)
    
    // Создаем тестовую тренировку
    let workout = Workout(context: context)
    workout.id = UUID()
    workout.type = "Cardio"
    workout.duration = 1800 // 30 минут
    workout.date = Date()
    workout.notes = "Утренняя пробежка"
    
    return WorkoutCard(workout: workout, viewModel: viewModel)
        .padding()
} 