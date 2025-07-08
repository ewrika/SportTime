//
//  ProfileViewModel.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine
import UIKit

class ProfileViewModel: ObservableObject {
    @Published var userImage: UIImage?
    @Published var soundEnabled: Bool = true
    @Published var notificationsEnabled: Bool = true
    
    private let workoutViewModel: WorkoutViewModel
    private let settingsManager: SettingsManager
    
    init(workoutViewModel: WorkoutViewModel, settingsManager: SettingsManager) {
        self.workoutViewModel = workoutViewModel
        self.settingsManager = settingsManager
        
        // Подписываемся на изменения в настройках
        self.userImage = settingsManager.userImage
        self.soundEnabled = settingsManager.soundEnabled
        self.notificationsEnabled = settingsManager.notificationsEnabled
        
        // Слушаем изменения в SettingsManager
        settingsManager.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.userImage = settingsManager.userImage
                self?.soundEnabled = settingsManager.soundEnabled
                self?.notificationsEnabled = settingsManager.notificationsEnabled
            }
        }.store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - User Image Management
    func updateUserImage(_ image: UIImage?) {
        userImage = image
        if let image = image {
            settingsManager.saveUserImage(image)
        } else {
            settingsManager.clearUserImage()
        }
    }
    
    // MARK: - Settings Management
    func toggleSound() {
        settingsManager.soundEnabled.toggle()
        soundEnabled = settingsManager.soundEnabled
    }
    
    func toggleNotifications() {
        settingsManager.notificationsEnabled.toggle()
        notificationsEnabled = settingsManager.notificationsEnabled
    }
    
    // MARK: - Statistics
    func getTotalWorkouts() -> Int {
        return workoutViewModel.getTotalWorkouts()
    }
    
    func getTotalDuration() -> String {
        return workoutViewModel.formatDuration(workoutViewModel.getTotalDuration())
    }
    
    func getAverageDuration() -> String {
        let totalWorkouts = workoutViewModel.getTotalWorkouts()
        guard totalWorkouts > 0 else { return "0м" }
        
        let averageDuration = workoutViewModel.getTotalDuration() / Int32(totalWorkouts)
        return workoutViewModel.formatDuration(averageDuration)
    }
    
    func getMostPopularWorkoutType() -> String {
        let workoutTypes = workoutViewModel.workouts.compactMap { $0.type }
        let counts = Dictionary(grouping: workoutTypes, by: { $0 }).mapValues { $0.count }
        
        guard let mostPopular = counts.max(by: { $0.value < $1.value })?.key else {
            return "Нет данных"
        }
        
        return workoutViewModel.getWorkoutTypeFromString(mostPopular).displayName
    }
    
    // MARK: - Data Management
    func refreshData() {
        // Обновляем данные из базы данных
        workoutViewModel.fetchWorkouts()
        
        // Обновляем изображение пользователя
        userImage = settingsManager.userImage
    }
    
    func clearAllData() {
        // Очищаем все тренировки
        for workout in workoutViewModel.workouts {
            workoutViewModel.deleteWorkout(workout)
        }
        
        // Очищаем изображение пользователя
        settingsManager.clearUserImage()
        userImage = nil
    }
    
    // MARK: - App Info
    func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    func openSupportEmail() {
        if let url = URL(string: "mailto:egorkaomsk_2003@mail.ru") {
            UIApplication.shared.open(url)
        }
    }
} 
