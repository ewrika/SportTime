//
//  HomeView.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @Binding var selectedTab: Int
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext, selectedTab: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(context: context))
        _selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.standard) {
                    welcomeSection
                    
                    startWorkoutSection
                    
                    recentWorkoutsSection
                }
                .padding(.horizontal, Spacing.standard)
                .padding(.top, Spacing.small)
            }
            .background(Color.backgroundColor)
            .navigationBarHidden(true)
        }
        .onAppear {
            Task {
                await viewModel.fetchWorkouts()
            }
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Добро пожаловать!")
                        .font(.titleFont)
                        .foregroundColor(.textPrimaryColor)
                    
                    Text("Готовы к тренировке?")
                        .font(.bodyFont)
                        .foregroundColor(.textSecondaryColor)
                }
                Spacer()
            }
            
            HStack(spacing: Spacing.standard) {
                StatCard(
                    title: "Всего тренировок",
                    value: "\(viewModel.getTotalWorkouts())",
                    color: .primaryColor
                )
                
                StatCard(
                    title: "Время",
                    value: viewModel.formatDuration(viewModel.getTotalDuration()),
                    color: .successColor
                )
            }
        }
        .padding(.top, Spacing.small)
    }
    
    private var startWorkoutSection: some View {
        VStack(spacing: Spacing.standard) {
            Button(action: {
                selectedTab = 1
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    Text("Начать тренировку")
                        .font(.subtitleFont)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.primaryColor, .secondaryColor]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(CornerRadius.button)
                .cardShadow()
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, Spacing.standard)
    }
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.standard) {
            HStack {
                Text("Последние тренировки")
                    .font(.subtitleFont)
                    .foregroundColor(.textPrimaryColor)
                Spacer()
            }
            
            if viewModel.getRecentWorkouts().isEmpty {
                EmptyStateView()
            } else {
                LazyVStack(spacing: Spacing.small) {
                    ForEach(viewModel.getRecentWorkouts(), id: \.id) { workout in
                        WorkoutCard(workout: workout, viewModel: viewModel)
                    }
                }
            }
        }
    }
}





#Preview {
    HomeView(context: PersistenceController.preview.container.viewContext, selectedTab: .constant(0))
}
