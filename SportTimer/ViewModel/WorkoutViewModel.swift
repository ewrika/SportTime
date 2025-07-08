//
//  WorkoutViewModel.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import Foundation
import CoreData
import SwiftUI

class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchWorkouts()
    }
    
    func fetchWorkouts() {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
        
        do {
            workouts = try viewContext.fetch(request)
        } catch {
            print("Ошибка при загрузке тренировок: \(error)")
        }
    }
    
    func addWorkout(type: WorkoutType, duration: Int32, notes: String? = nil) {
        let workout = Workout(context: viewContext)
        workout.id = UUID()
        workout.type = type.rawValue
        workout.duration = duration
        workout.date = Date()
        workout.notes = notes
        
        do {
            try viewContext.save()
            fetchWorkouts()
        } catch {
            print("Ошибка при сохранении тренировки: \(error)")
        }
    }
    
    func deleteWorkout(_ workout: Workout) {
        viewContext.delete(workout)
        
        do {
            try viewContext.save()
            fetchWorkouts()
        } catch {
            print("Ошибка при удалении тренировки: \(error)")
        }
    }
    
    func getRecentWorkouts(count: Int = 3) -> [Workout] {
        return Array(workouts.prefix(count))
    }
    
    func getTotalWorkouts() -> Int {
        return workouts.count
    }
    
    func getTotalDuration() -> Int32 {
        return workouts.reduce(0) { $0 + $1.duration }
    }
    
    func getWorkoutTypeFromString(_ type: String) -> WorkoutType {
        return WorkoutType(rawValue: type) ?? .other
    }
    
    func formatDuration(_ duration: Int32) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        
        if minutes > 0 {
            return "\(minutes)м \(seconds)с"
        } else {
            return "\(seconds)с"
        }
    }
} 