//
//  SavePracticeTaskToCloudUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 2/10/2026.
//

import Foundation
import Supabase

enum SavePracticeTaskToCloudError: Error {
    case studentProfileNotFound
    case lessonNotFound
}

struct SavePracticeTaskToCloudUseCase {

    private let practiceTaskRepository:
        SupabasePracticeTaskRepository

    private let userRepository:
        SupabaseUserRepository

    private let lessonRepository:
        SupabaseLessonRepository

    init(
        practiceTaskRepository:
            SupabasePracticeTaskRepository,
        userRepository:
            SupabaseUserRepository,
        lessonRepository:
            SupabaseLessonRepository
    ) {
        self.practiceTaskRepository =
            practiceTaskRepository

        self.userRepository =
            userRepository

        self.lessonRepository =
            lessonRepository
    }

    // saves a local practice task to Supabase using the cloud user and lesson IDs
    func execute(
        task: PracticeTask,
        studentEmail: String
    ) async throws {

        let authenticatedTeacher =
            try await SupabaseService.client.auth.user()

        guard let studentProfile =
            try await userRepository.getProfile(
                email: studentEmail
            )
        else {
            throw SavePracticeTaskToCloudError
                .studentProfileNotFound
        }

        let cloudLessons =
            try await lessonRepository.getLessons()

        guard cloudLessons.contains(where: {
            $0.id == task.lessonID
        })
        else {
            throw SavePracticeTaskToCloudError
                .lessonNotFound
        }

        let cloudTask =
            SupabasePracticeTask(
                id: task.id,
                title: task.title,
                taskDescription:
                    task.taskDescription,
                studentID:
                    studentProfile.id,
                teacherID:
                    authenticatedTeacher.id,
                lessonID:
                    task.lessonID,
                dueDate:
                    task.dueDate,
                isCompleted:
                    task.isCompleted
            )

        try await practiceTaskRepository.addTask(
            cloudTask
        )
    }
    
    // deletes a practice task from Supabase
    func delete(
        taskID: UUID
    ) async throws {

        try await practiceTaskRepository.deleteTask(
            id: taskID
        )
    }
}
