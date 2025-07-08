//
//  TimerView.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI
import CoreData
import AVFoundation
import AudioToolbox

struct TimerView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @StateObject private var timerViewModel = TimerViewModel()
    @StateObject private var settingsManager = SettingsManager()
    @State private var selectedWorkoutType: WorkoutType = .cardio
    @State private var notes: String = ""
    @State private var showingCompletedAlert = false

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: Spacing.standard) {
                WorkoutTypeSelector(selectedWorkoutType: $selectedWorkoutType)
                
                CircularProgressView(
                    formattedTime: timerViewModel.formattedElapsedTime,
                    isRunning: timerViewModel.isRunning,
                    progress: timerViewModel.progress,
                    totalTime: timerViewModel.totalTime,
                    color: selectedWorkoutType.color
                )
                
                TimerControlButtons(
                    isRunning: timerViewModel.isRunning,
                    isCompleted: timerViewModel.isCompleted,
                    elapsedTime: timerViewModel.elapsedTime,
                    onPlayPause: {
                        if timerViewModel.isRunning {
                            timerViewModel.pauseTimer(soundEnabled: settingsManager.soundEnabled)
                        } else {
                            timerViewModel.startTimer(soundEnabled: settingsManager.soundEnabled)
                        }
                    },
                    onStop: {
                        stopTimer()
                    }
                )
                
                notesSection
                
                Spacer()
            }
            .padding(.horizontal, Spacing.standard)
            .background(Color.backgroundColor)
            .navigationTitle("Таймер")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }

        }
        .alert("Тренировка завершена!", isPresented: $showingCompletedAlert) {
            Button("OK") {
                resetTimer()
            }
        } message: {
            Text("Тренировка длилась \(timerViewModel.formattedElapsedTime)")
        }
        .onAppear {
            Task {
                await viewModel.fetchWorkouts()
            }
        }
    }
    

    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Заметки о тренировке")
                .font(.subtitleFont)
                .foregroundColor(.textPrimaryColor)
            
            TextEditor(text: $notes)
                .frame(height: 100)
                .padding(Spacing.small)
                .background(Color.white)
                .cornerRadius(CornerRadius.card)
                .cardShadow()
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Actions
    private func stopTimer() {
        if timerViewModel.elapsedTime > 0 {
            Task {
                await viewModel.addWorkout(
                    type: selectedWorkoutType,
                    duration: Int32(timerViewModel.elapsedTime),
                    notes: notes.isEmpty ? nil : notes
                )
            }
            showingCompletedAlert = true
        }
        timerViewModel.stopTimer(soundEnabled: settingsManager.soundEnabled)
    }
    
    private func resetTimer() {
        timerViewModel.resetTimer()
        notes = ""
    }
}



#Preview {
    TimerView(context: PersistenceController.preview.container.viewContext)
} 
