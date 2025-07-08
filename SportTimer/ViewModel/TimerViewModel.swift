//
//  TimerViewModel.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import Foundation
import SwiftUI
import AVFAudio

class TimerViewModel: ObservableObject {
    @Published var elapsedTime: Int = 0
    @Published var totalTime: Int = 0
    @Published var isRunning: Bool = false
    @Published var isCompleted: Bool = false
    
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
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
        isRunning = true
        isCompleted = false
        if soundEnabled {
            playSound("start")
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.elapsedTime += 1
            }
        }
    }
    
    func pauseTimer(soundEnabled: Bool = true) {
        isRunning = false
        timer?.invalidate()
        timer = nil
        if soundEnabled {
            playSound("pause")
        }
    }
    
    func stopTimer(soundEnabled: Bool = true) {
        isRunning = false
        isCompleted = true
        timer?.invalidate()
        timer = nil
        if soundEnabled {
            playSound("stop")
        }
    }
    
    func resetTimer() {
        elapsedTime = 0
        totalTime = 0
        isRunning = false
        isCompleted = false
        timer?.invalidate()
        timer = nil
    }
    
    private func playSound(_ soundName: String) {
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
    }
}
