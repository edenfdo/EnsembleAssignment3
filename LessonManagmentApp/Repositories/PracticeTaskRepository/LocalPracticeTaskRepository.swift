//
//  LocalPracticeTaskRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/8/2026.
//

import Foundation
import SwiftData

final class LocalPracticeTaskRepository: PracticeTaskRepository {

    private let modelContext: ModelContext

    // creates the repository using the SwiftData model context
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // fetches all practice tasks stored in SwiftData
    func getAllTasks() -> [PracticeTask] {

        let descriptor = FetchDescriptor<PracticeTask>()

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch practice tasks: \(error)")
            return []
        }
    }

    // returns only practice tasks assigned to the specified student
    func getTasks(
        forStudentID studentID: UUID
    ) -> [PracticeTask] {

        let allTasks = getAllTasks()

        return allTasks.filter {
            $0.studentID == studentID
        }
    }
    
    // adds a new practice task to SwiftData and saves the change
    func addTask(
        _ task: PracticeTask
    ) {

        modelContext.insert(task)

        saveContext()
    }

    // saves changes made to an existing practice task
    func updateTask(
        _ task: PracticeTask
    ) {

        saveContext()
    }

    // saves any pending changes to the SwiftData context
    private func saveContext() {

        do {
            try modelContext.save()
        } catch {
            print(
                "Failed to save practice tasks: \(error)"
            )
        }
    }
    
    // deletes a practice task from SwiftData and saves the change
    func deleteTask(
        _ task: PracticeTask
    ) {

        modelContext.delete(
            task
        )

        do {

            try modelContext.save()

        } catch {

            print(
                "Failed to delete practice task: \(error)"
            )
        }
    }
}
