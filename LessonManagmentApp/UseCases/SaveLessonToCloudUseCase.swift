//
//  SaveLessonToCloudUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 1/10/2026.
//

import Foundation
import Supabase

enum SaveLessonToCloudError: Error {
    case studentProfileNotFound
}

struct SaveLessonToCloudUseCase {

    private let lessonRepository: SupabaseLessonRepository
    private let userRepository: SupabaseUserRepository

    init(
        lessonRepository: SupabaseLessonRepository,
        userRepository: SupabaseUserRepository
    ) {
        self.lessonRepository = lessonRepository
        self.userRepository = userRepository
    }

    // saves a local lesson to Supabase using the authenticated teacher and cloud student IDs
    func execute(
        lesson: Lesson,
        studentEmail: String
    ) async throws {

        let authenticatedTeacher =
            try await SupabaseService.client.auth.user()

        guard let studentProfile =
            try await userRepository.getProfile(email: studentEmail)
        else {
            throw SaveLessonToCloudError.studentProfileNotFound
        }

        let cloudLesson = SupabaseLesson(
            id: lesson.id,
            title: lesson.title,
            date: lesson.date,
            durationMinutes: lesson.durationMinutes,
            studentID: studentProfile.id,
            teacherID: authenticatedTeacher.id,
            notes: lesson.notes,
            location: lesson.location,
            recurrenceType: lesson.recurrence.rawValue,
            recurrenceEndDate: lesson.recurrenceEndDate
        )

        try await lessonRepository.addLesson(cloudLesson)
    }
    
    // updates an existing lesson in Supabase
    func update(
        lesson: Lesson,
        studentEmail: String
    ) async throws {

        let authenticatedTeacher =
            try await SupabaseService.client.auth.user()

        guard let studentProfile =
            try await userRepository.getProfile(
                email: studentEmail
            )
        else {
            throw SaveLessonToCloudError.studentProfileNotFound
        }

        let cloudLesson =
            SupabaseLesson(
                id: lesson.id,
                title: lesson.title,
                date: lesson.date,
                durationMinutes: lesson.durationMinutes,
                studentID: studentProfile.id,
                teacherID: authenticatedTeacher.id,
                notes: lesson.notes,
                location: lesson.location,
                recurrenceType: lesson.recurrence.rawValue,
                recurrenceEndDate: lesson.recurrenceEndDate
            )

        try await lessonRepository.updateLesson(
            cloudLesson
        )
    }


    // deletes an existing lesson from Supabase
    func delete(
        lessonID: UUID
    ) async throws {

        try await lessonRepository.deleteLesson(
            id: lessonID
        )
    }
}
