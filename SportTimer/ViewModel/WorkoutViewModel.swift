//
//  WorkoutViewModel.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let viewContext: NSManagedObjectContext
    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext, persistenceController: PersistenceController = .shared) {
        self.viewContext = context
        self.persistenceController = persistenceController
        
        // Подписываемся на изменения в контексте
        setupContextObservers()
        
        // Загружаем данные при инициализации
        Task {
            await fetchWorkouts()
        }
    }
    
    // MARK: - Core Data Operations
    
    func fetchWorkouts() async {
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
            self.error = "Ошибка при загрузке тренировок: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addWorkout(type: WorkoutType, duration: Int32, notes: String? = nil) async {
        do {
            try await persistenceController.performBackgroundTaskAsync { context in
                let workout = Workout(context: context)
                workout.id = UUID()
                workout.type = type.rawValue
                workout.duration = duration
                workout.date = Date()
                workout.notes = notes
                
                // Сохраняем изменения в этом же контексте
                try context.save()
            }
            
            // Обновляем UI в главном потоке
            await fetchWorkouts()
            
        } catch {
            self.error = "Ошибка при сохранении тренировки: \(error.localizedDescription)"
        }
    }
    
    func deleteWorkout(_ workout: Workout) async {
        let objectID = workout.objectID
        
        do {
            try await persistenceController.performBackgroundTaskAsync { context in
                if let workoutToDelete = try context.existingObject(with: objectID) as? Workout {
                    context.delete(workoutToDelete)
                    try context.save()
                }
            }
            
            // Обновляем UI в главном потоке
            await fetchWorkouts()
            
        } catch {
            self.error = "Ошибка при удалении тренировки: \(error.localizedDescription)"
        }
    }
    
    func deleteWorkouts(_ workouts: [Workout]) async {
        let objectIDs = workouts.map { $0.objectID }
        
        do {
            try await persistenceController.performBackgroundTaskAsync { context in
                for objectID in objectIDs {
                    if let workoutToDelete = try context.existingObject(with: objectID) as? Workout {
                        context.delete(workoutToDelete)
                    }
                }
                try context.save()
            }
            
            // Обновляем UI в главном потоке
            await fetchWorkouts()
            
        } catch {
            self.error = "Ошибка при удалении тренировок: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Search Operations
    
    func searchWorkouts(query: String) async -> [Workout] {
        guard !query.isEmpty else { return workouts }
        
        do {
            let request: NSFetchRequest<Workout> = Workout.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
            
            // Создаем предикат для поиска
            let predicate = NSPredicate(format: "notes CONTAINS[cd] %@ OR type CONTAINS[cd] %@", query, query)
            request.predicate = predicate
            
            return try await viewContext.perform {
                try self.viewContext.fetch(request)
            }
        } catch {
            self.error = "Ошибка при поиске: \(error.localizedDescription)"
            return []
        }
    }
    
    func filterWorkouts(by type: WorkoutType? = nil, dateRange: DateRange = .all) async -> [Workout] {
        do {
            let request: NSFetchRequest<Workout> = Workout.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
            
            var predicates: [NSPredicate] = []
            
            // Фильтр по типу
            if let type = type {
                predicates.append(NSPredicate(format: "type == %@", type.rawValue))
            }
            
            // Фильтр по дате
            if dateRange != .all {
                let dateRangePredicate = dateRange.predicate
                predicates.append(dateRangePredicate)
            }
            
            if !predicates.isEmpty {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }
            
            return try await viewContext.perform {
                try self.viewContext.fetch(request)
            }
        } catch {
            self.error = "Ошибка при фильтрации: \(error.localizedDescription)"
            return []
        }
    }
    
    // MARK: - Helper Methods
    
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
    
    // MARK: - Context Observers
    
    private func setupContextObservers() {
        // Подписываемся на изменения в контексте
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self = self else { return }
                
                // Обновляем данные при изменениях
                Task {
                    await self.fetchWorkouts()
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.removeAll()
    }
} 
