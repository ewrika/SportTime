//
//  ProfileViewModel.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let viewContext: NSManagedObjectContext
    private let persistenceController: PersistenceController
    
    init(context: NSManagedObjectContext, persistenceController: PersistenceController = .shared) {
        self.viewContext = context
        self.persistenceController = persistenceController
        
        Task {
            await loadWorkouts()
        }
    }
    
    func loadWorkouts() async {
        isLoading = true
        error = nil
        
        do {
            let request: NSFetchRequest<Workout> = Workout.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
            
            let fetchedWorkouts = try await viewContext.perform {
                try self.viewContext.fetch(request)
            }
            
            workouts = fetchedWorkouts
            
        } catch {
            self.error = "Ошибка при загрузке данных: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func clearAllData() async {
        isLoading = true
        error = nil
        
        do {
            try await persistenceController.performBackgroundTaskAsync { context in
                let request: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                
                try context.execute(deleteRequest)
                try context.save()
            }
            
            // Обновляем локальные данные
            workouts = []
            
        } catch {
            self.error = "Ошибка при очистке данных: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Statistics
    
    func getTotalWorkouts() -> Int {
        return workouts.count
    }
    
    func getTotalDuration() -> Int32 {
        return workouts.reduce(0) { $0 + $1.duration }
    }
    
    func getTotalDurationThisWeek() -> Int32 {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return workouts.filter { workout in
            guard let date = workout.date else { return false }
            return date >= startOfWeek
        }.reduce(0) { $0 + $1.duration }
    }
    
    func getTotalDurationThisMonth() -> Int32 {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        
        return workouts.filter { workout in
            guard let date = workout.date else { return false }
            return date >= startOfMonth
        }.reduce(0) { $0 + $1.duration }
    }
    
    func getMostPopularWorkoutType() -> WorkoutType {
        let workoutTypes = workouts.compactMap { workout in
            WorkoutType(rawValue: workout.type ?? "")
        }
        
        let typeCounts = Dictionary(grouping: workoutTypes) { $0 }
            .mapValues { $0.count }
        
        return typeCounts.max(by: { $0.value < $1.value })?.key ?? .other
    }
    
    func formatDuration(_ duration: Int32) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else if minutes > 0 {
            return "\(minutes)м"
        } else {
            return "\(duration)с"
        }
    }
} 
