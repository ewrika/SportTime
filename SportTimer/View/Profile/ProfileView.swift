//
//  ProfileView.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI
import CoreData
import PhotosUI

struct ProfileView: View {
    @StateObject private var profileViewModel: ProfileViewModel
    @State private var showingImagePicker = false
    @State private var showingDeleteAlert = false
    @State private var selectedImage: UIImage?
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        let workoutViewModel = WorkoutViewModel(context: context)
        let settingsManager = SettingsManager()
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(workoutViewModel: workoutViewModel, settingsManager: settingsManager))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.standard) {
                    avatarSection
                    
                    statisticsSection
                    
                    settingsSection
                    
                    aboutSection
                }
                .padding(.horizontal, Spacing.standard)
            }
            .background(Color.backgroundColor)
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert("Очистить все данные?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("Это действие нельзя отменить. Все тренировки будут удалены.")
        }
        .onChange(of: selectedImage) { image in
            profileViewModel.updateUserImage(image)
        }
        .onAppear {
            profileViewModel.refreshData()
        }
    }
    
    private var avatarSection: some View {
        VStack(spacing: Spacing.small) {
            Button(action: {
                showingImagePicker = true
            }) {
                if let image = profileViewModel.userImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.primaryColor, lineWidth: 3)
                        )
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.textSecondaryColor)
                }
            }
            
            Text("Нажмите, чтобы изменить фото")
                .font(.secondaryTextFont)
                .foregroundColor(.textSecondaryColor)
        }
        .padding(.vertical, Spacing.standard)
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.standard) {
            Text("Статистика")
                .font(.subtitleFont)
                .foregroundColor(.textPrimaryColor)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.standard) {
                StatisticsCard(
                    icon: "figure.run",
                    title: "Всего тренировок",
                    value: "\(profileViewModel.getTotalWorkouts())",
                    color: .primaryColor
                )
                
                StatisticsCard(
                    icon: "clock.fill",
                    title: "Общее время",
                    value: profileViewModel.getTotalDuration(),
                    color: .successColor
                )
                
                StatisticsCard(
                    icon: "calendar.badge.clock",
                    title: "Средняя длительность",
                    value: profileViewModel.getAverageDuration(),
                    color: .warningColor
                )
                
                StatisticsCard(
                    icon: "chart.bar.fill",
                    title: "Любимый тип",
                    value: profileViewModel.getMostPopularWorkoutType(),
                    color: .dangerColor
                )
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.standard) {
            Text("Настройки")
                .font(.subtitleFont)
                .foregroundColor(.textPrimaryColor)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "speaker.wave.2.fill",
                    title: "Звуки таймера",
                    color: .primaryColor
                ) {
                    Toggle("", isOn: Binding(
                        get: { profileViewModel.soundEnabled },
                        set: { _ in profileViewModel.toggleSound() }
                    ))
                        .labelsHidden()
                }
                
                Divider()
                
                SettingsRow(
                    icon: "bell.fill",
                    title: "Уведомления",
                    color: .warningColor
                ) {
                    Toggle("", isOn: Binding(
                        get: { profileViewModel.notificationsEnabled },
                        set: { _ in profileViewModel.toggleNotifications() }
                    ))
                        .labelsHidden()
                }
                
                Divider()
                
                SettingsRow(
                    icon: "trash.fill",
                    title: "Очистить все данные",
                    color: .dangerColor
                ) {
                    Button("Очистить") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.dangerColor)
                }
            }
            .background(Color.white)
            .cornerRadius(CornerRadius.card)
            .cardShadow()
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Spacing.standard) {
            Text("О приложении")
                .font(.subtitleFont)
                .foregroundColor(.textPrimaryColor)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Версия",
                    color: .primaryColor
                ) {
                    Text(profileViewModel.getAppVersion())
                        .font(.bodyFont)
                        .foregroundColor(.textSecondaryColor)
                }
                
                Divider()
                
                SettingsRow(
                    icon: "person.2.fill",
                    title: "Разработчик",
                    color: .secondaryColor
                ) {
                    Text("BrickTeam")
                        .font(.bodyFont)
                        .foregroundColor(.textSecondaryColor)
                }
                
                Divider()
                
                SettingsRow(
                    icon: "heart.fill",
                    title: "Поддержка",
                    color: .dangerColor
                ) {
                    Button("Написать") {
                        profileViewModel.openSupportEmail()
                    }
                    .foregroundColor(.primaryColor)
                }
            }
            .background(Color.white)
            .cornerRadius(CornerRadius.card)
            .cardShadow()
        }
    }
    
    
    private func clearAllData() {
        profileViewModel.clearAllData()
    }
}


#Preview {
    ProfileView(context: PersistenceController.preview.container.viewContext)
} 
