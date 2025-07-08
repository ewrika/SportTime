//
//  SettingsManager.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var userImage: UIImage? {
        didSet {
            if let image = userImage {
                saveUserImage(image)
            }
        }
    }
    
    init() {
        self.soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.userImage = loadUserImage()
        
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            self.soundEnabled = true
            self.notificationsEnabled = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    func saveUserImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: "userImage")
            DispatchQueue.main.async {
                self.userImage = image
                self.objectWillChange.send()
            }
        }
    }
    
    func loadUserImage() -> UIImage? {
        if let data = UserDefaults.standard.data(forKey: "userImage") {
            return UIImage(data: data)
        }
        return nil
    }
    
    func clearUserImage() {
        UserDefaults.standard.removeObject(forKey: "userImage")
        DispatchQueue.main.async {
            self.userImage = nil
            self.objectWillChange.send()
        }
    }
}
