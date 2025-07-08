//
//  Persistence.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Создаем тестовые данные для превью
        let workoutTypes = ["Strength", "Cardio", "Yoga"]
        let durations = [1800, 3600, 2400] // 30мин, 60мин, 40мин
        
        for i in 0..<3 {
            let workout = Workout(context: viewContext)
            workout.id = UUID()
            workout.type = workoutTypes[i]
            workout.duration = Int32(durations[i])
            workout.date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            workout.notes = "Тестовая тренировка \(i + 1)"
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SportTimer")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
