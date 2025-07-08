//
//  SettingsManager.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsManager: ObservableObject {
    @Published var soundEnabled: Bool = true {
        didSet {
            Task {
                await saveSetting(key: "soundEnabled", value: soundEnabled)
            }
        }
    }
    
    @Published var notificationsEnabled: Bool = true {
        didSet {
            Task {
                await saveSetting(key: "notificationsEnabled", value: notificationsEnabled)
            }
        }
    }
    
    @Published var userImage: UIImage? = nil {
        didSet {
            Task {
                await saveUserImage(userImage)
            }
        }
    }
    
    @Published var isLoading = false
    @Published var error: String?
    
    private let userDefaults = UserDefaults.standard
    private let imageQueue = DispatchQueue(label: "com.sporttimer.imageprocessing", qos: .utility)
    
    init() {
        Task {
            await loadSettings()
        }
    }
    
    // MARK: - Settings Management
    
    private func loadSettings() async {
        isLoading = true
        
        do {
            // Загружаем настройки в фоновом потоке
            let settings = await withTaskGroup(of: (String, Any).self) { group in
                var results: [String: Any] = [:]
                
                group.addTask {
                    let soundEnabled = self.userDefaults.bool(forKey: "soundEnabled")
                    return ("soundEnabled", soundEnabled)
                }
                
                group.addTask {
                    let notificationsEnabled = self.userDefaults.bool(forKey: "notificationsEnabled")
                    return ("notificationsEnabled", notificationsEnabled)
                }
                
                group.addTask {
                    let userImage = await self.loadUserImageAsync()
                    return ("userImage", userImage as Any)
                }
                
                for await result in group {
                    results[result.0] = result.1
                }
                
                return results
            }
            
            // Обновляем UI в главном потоке
            self.soundEnabled = settings["soundEnabled"] as? Bool ?? true
            self.notificationsEnabled = settings["notificationsEnabled"] as? Bool ?? true
            self.userImage = settings["userImage"] as? UIImage
            
            // Устанавливаем значения по умолчанию при первом запуске
            if !userDefaults.bool(forKey: "hasLaunchedBefore") {
                self.soundEnabled = true
                self.notificationsEnabled = true
                userDefaults.set(true, forKey: "hasLaunchedBefore")
            }
            
        } catch {
            self.error = "Ошибка при загрузке настроек: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func saveSetting<T>(key: String, value: T) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                self.userDefaults.set(value, forKey: key)
                continuation.resume()
            }
        }
    }
    
    // MARK: - Image Management
    
    private func loadUserImageAsync() async -> UIImage? {
        return await withCheckedContinuation { continuation in
            imageQueue.async {
                if let data = self.userDefaults.data(forKey: "userImage") {
                    let image = UIImage(data: data)
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    private func saveUserImage(_ image: UIImage?) async {
        await withCheckedContinuation { continuation in
            imageQueue.async {
                if let image = image {
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        self.userDefaults.set(data, forKey: "userImage")
                    }
                } else {
                    self.userDefaults.removeObject(forKey: "userImage")
                }
                
                continuation.resume()
            }
        }
    }
    
    func clearUserImage() async {
        await withCheckedContinuation { continuation in
            imageQueue.async {
                self.userDefaults.removeObject(forKey: "userImage")
                continuation.resume()
            }
        }
        
        // Обновляем UI в главном потоке
        self.userImage = nil
    }
    
    // MARK: - Bulk Operations
    
    func resetAllSettings() async {
        isLoading = true
        
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                let domain = Bundle.main.bundleIdentifier!
                self.userDefaults.removePersistentDomain(forName: domain)
                self.userDefaults.synchronize()
                continuation.resume()
            }
        }
        
        // Восстанавливаем значения по умолчанию
        self.soundEnabled = true
        self.notificationsEnabled = true
        self.userImage = nil
        
        isLoading = false
    }
    
    func exportSettings() async -> [String: Any] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                let settings: [String: Any] = [
                    "soundEnabled": self.soundEnabled,
                    "notificationsEnabled": self.notificationsEnabled,
                    "hasUserImage": self.userImage != nil
                ]
                continuation.resume(returning: settings)
            }
        }
    }
}
