//
//  HistoryWorkoutCard.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI
import CoreData

struct HistoryWorkoutCard: View {
    let workout: Workout
    let viewModel: WorkoutViewModel
    
    var body: some View {
        HStack(spacing: Spacing.standard) {
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.getWorkoutTypeFromString(workout.type ?? "").displayName)
                    .font(.bodyFont)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimaryColor)
                
                Text(viewModel.formatDuration(workout.duration))
                    .font(.secondaryTextFont)
                    .foregroundColor(.textSecondaryColor)
                
                if let notes = workout.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.secondaryTextFont)
                        .foregroundColor(.textSecondaryColor)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Text(formatTime(workout.date ?? Date()))
                .font(.secondaryTextFont)
                .foregroundColor(.textSecondaryColor)
        }
        .padding(.vertical, Spacing.small)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let viewModel = WorkoutViewModel(context: context)
    
    let workout = Workout(context: context)
    workout.id = UUID()
    workout.type = "Strength"
    workout.duration = 2700 // 45 минут
    workout.date = Date()
    workout.notes = "Силовая тренировка в зале"
    
    return HistoryWorkoutCard(workout: workout, viewModel: viewModel)
        .padding()
} 
