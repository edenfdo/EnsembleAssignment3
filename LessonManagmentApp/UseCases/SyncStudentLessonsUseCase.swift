//
//  SyncStudentLessonsUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 1/10/2026.
//

import Foundation

struct SyncStudentLessonsUseCase {

    private let cloudLessonRepository: SupabaseLessonRepository
    private let cloudUserRepository: SupabaseUserRepository
    private let localLessonRepository: LessonRepository
    private let localUserRepository: UserRepository

    init(
        cloudLessonRepository: SupabaseLessonRepository,
        cloudUserRepository: SupabaseUserRepository,
        localLessonRepository: LessonRepository,
        localUserRepository: UserRepository
    ) {
        self.cloudLessonRepository = cloudLessonRepository
        self.cloudUserRepository = cloudUserRepository
        self.localLessonRepository = localLessonRepository
        self.localUserRepository = localUserRepository
    }

    // downloads the student's cloud lessons and saves missing lessons locally
    func execute(
        localStudentID: UUID
    ) async throws {

        let cloudLessons =
            try await cloudLessonRepository.getLessons()

        let existingLessonIDs =
            Set(
                localLessonRepository
                    .getAllLessons()
                    .map {
                        $0.id
                    }
            )

        let localUsers =
            localUserRepository.getAllUsers()

        for cloudLesson in cloudLessons {

            // avoids adding the same lesson more than once
            guard !existingLessonIDs.contains(cloudLesson.id)
            else {
                continue
            }

            guard let cloudTeacher =
                try await cloudUserRepository.getProfile(
                    id: cloudLesson.teacherID
                )
            else {
                continue
            }

            guard let localTeacher =
                localUsers.first(where: {
                    $0.normalizedEmail
                    ==
                    cloudTeacher.email
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .lowercased()
                })
            else {
                continue
            }

            let localLesson =
                Lesson(
                    id: cloudLesson.id,
                    title: cloudLesson.title,
                    date: cloudLesson.date,
                    durationMinutes: cloudLesson.durationMinutes,
                    studentID: localStudentID,
                    teacherID: localTeacher.id,
                    notes: cloudLesson.notes,
                    location: cloudLesson.location
                )

            localLessonRepository.addLesson(
                localLesson
            )
        }
    }
}
