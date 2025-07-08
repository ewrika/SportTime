//
//  WorkoutTypeSelector.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI

struct WorkoutTypeSelector: View {
    @Binding var selectedWorkoutType: WorkoutType
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Тип тренировки")
                .font(.subtitleFont)
                .foregroundColor(.textPrimaryColor)
            
            Menu {
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedWorkoutType = type
                    }) {
                        HStack {
                            Image(systemName: type.icon)
                            Text(type.displayName)
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: selectedWorkoutType.icon)
                        .foregroundColor(selectedWorkoutType.color)
                    Text(selectedWorkoutType.displayName)
                        .font(.bodyFont)
                        .foregroundColor(.textPrimaryColor)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.textSecondaryColor)
                        .font(.caption)
                }
                .padding(Spacing.standard)
                .background(Color.white)
                .cornerRadius(CornerRadius.card)
                .cardShadow()
            }
        }
    }
}

#Preview {
    WorkoutTypeSelector(selectedWorkoutType: .constant(.cardio))
        .padding()
} 