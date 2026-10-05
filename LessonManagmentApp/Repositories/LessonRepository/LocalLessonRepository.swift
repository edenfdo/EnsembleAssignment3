//
//  LocalLessonRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/8/2026.
//

import Foundation
import SwiftData

final class LocalLessonRepository: LessonRepository {

    private let modelContext: ModelContext

    // creates the repository using the SwiftData model context
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // fetches all lessons stored in SwiftData
    func getAllLessons() -> [Lesson] {

        let descriptor = FetchDescriptor<Lesson>()

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch lessons: \(error)")
            return []
        }
    }

    // queries SwiftData for lessons assigned to the specified student
    func getLessons(
        forStudentID studentID: UUID
    ) -> [Lesson] {

        let selectedStudentID = studentID

        let descriptor = FetchDescriptor<Lesson>(
            predicate: #Predicate<Lesson> { lesson in
                lesson.studentID == selectedStudentID
            },
            sortBy: [
                SortDescriptor(\Lesson.date)
            ]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print(
                "Failed to fetch student lessons: \(error)"
            )
            return []
        }
    }

    // queries SwiftData for lessons assigned to the specified teacher
    func getLessons(
        forTeacherID teacherID: UUID
    ) -> [Lesson] {

        let selectedTeacherID = teacherID

        let descriptor = FetchDescriptor<Lesson>(
            predicate: #Predicate<Lesson> { lesson in
                lesson.teacherID == selectedTeacherID
            },
            sortBy: [
                SortDescriptor(\Lesson.date)
            ]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print(
                "Failed to fetch teacher lessons: \(error)"
            )
            return []
        }
    }

    // adds a new lesson to SwiftData and saves the change
    func addLesson(_ lesson: Lesson) {

        modelContext.insert(lesson)

        saveContext()
    }

    // saves any pending changes to the SwiftData context
    private func saveContext() {

        do {
            try modelContext.save()
        } catch {
            print("Failed to save lesson: \(error)")
        }
    }
    
    // saves changes made to an existing lesson
    func updateLesson(
        _ lesson: Lesson
    ) {

        do {

            try modelContext.save()

        } catch {

            print(
                "Failed to update lesson: \(error)"
            )
        }
    }
    
    // deletes a lesson from SwiftData and saves the change
    func deleteLesson(
        _ lesson: Lesson
    ) {

        modelContext.delete(
            lesson
        )

        do {

            try modelContext.save()

        } catch {

            print(
                "Failed to delete lesson: \(error)"
            )
        }
    }
}
