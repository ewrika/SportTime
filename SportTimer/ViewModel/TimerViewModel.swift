//
//  TimerViewModel.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import Foundation
import SwiftUI
import AVFAudio

@MainActor
class TimerViewModel: ObservableObject {
    @Published var elapsedTime: Int = 0
    @Published var totalTime: Int = 0
    @Published var isRunning: Bool = false
    @Published var isCompleted: Bool = false
    
    private var timerTask: Task<Void, Never>?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private let backgroundQueue = DispatchQueue(label: "com.sporttimer.background", qos: .utility)
    
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(elapsedTime) / Double(totalTime)
    }
    
    var formattedElapsedTime: String {
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let seconds = elapsedTime % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func startTimer(soundEnabled: Bool = true) {
        guard !isRunning else { return }
        
        isRunning = true
        isCompleted = false
        
        // Запрашиваем фоновое выполнение
        beginBackgroundTask()
        
        if soundEnabled {
            Task {
                await playSound("start")
            }
        }
        
        // Создаем async task для таймера
        timerTask = Task {
            while !Task.isCancelled && isRunning {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
                
                if !Task.isCancelled && isRunning {
                    await MainActor.run {
                        self.elapsedTime += 1
                    }
                }
            }
        }
    }
    
    func pauseTimer(soundEnabled: Bool = true) {
        guard isRunning else { return }
        
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
        
        endBackgroundTask()
        
        if soundEnabled {
            Task {
                await playSound("pause")
            }
        }
    }
    
    func stopTimer(soundEnabled: Bool = true) {
        isRunning = false
        isCompleted = true
        
        timerTask?.cancel()
        timerTask = nil
        
        endBackgroundTask()
        
        if soundEnabled {
            Task {
                await playSound("stop")
            }
        }
    }
    
    func resetTimer() {
        timerTask?.cancel()
        timerTask = nil
        
        elapsedTime = 0
        totalTime = 0
        isRunning = false
        isCompleted = false
        
        endBackgroundTask()
    }
    
    // MARK: - Background Task Management
    
    private func beginBackgroundTask() {
        backgroundQueue.async {
            self.backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.endBackgroundTask()
            }
        }
    }
    
    private func endBackgroundTask() {
        backgroundQueue.async {
            if self.backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = .invalid
            }
        }
    }
    
    // MARK: - Sound Management
    
    private func playSound(_ soundName: String) async {
        await withCheckedContinuation { continuation in
            // Выполняем воспроизведение звука в фоновом потоке
            DispatchQueue.global(qos: .userInitiated).async {
                switch soundName {
                case "start":
                    AudioServicesPlaySystemSound(1103)
                case "pause":
                    AudioServicesPlaySystemSound(1104)
                case "stop":
                    AudioServicesPlaySystemSound(1105)
                default:
                    break
                }
                continuation.resume()
            }
        }
    }
    
    deinit {
        timerTask?.cancel()
        
        // Завершаем фоновую задачу синхронно
        backgroundQueue.sync {
            if backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTask)
                backgroundTask = .invalid
            }
        }
    }
}
