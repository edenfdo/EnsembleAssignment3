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

    // synchronises the student's cloud lessons with local SwiftData
    func execute(
        localStudentID: UUID
    ) async throws {

        let cloudLessons =
            try await cloudLessonRepository.getLessons()

        let localUsers =
            localUserRepository.getAllUsers()

        let previousCloudIDs =
            LessonSyncStateService.getSyncedLessonIDs(
                studentID: localStudentID
            )

        let currentCloudIDs =
            Set(
                cloudLessons.map {
                    $0.id
                }
            )

        // adds new lessons and updates existing cloud lessons
        for cloudLesson in cloudLessons {

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

            let localLessons =
                localLessonRepository.getAllLessons()

            if let existingLesson =
                localLessons.first(where: {
                    $0.id == cloudLesson.id
                }) {

                existingLesson.title =
                    cloudLesson.title

                existingLesson.date =
                    cloudLesson.date

                existingLesson.durationMinutes =
                    cloudLesson.durationMinutes

                existingLesson.studentID =
                    localStudentID

                existingLesson.teacherID =
                    localTeacher.id

                existingLesson.notes =
                    cloudLesson.notes

                existingLesson.location =
                    cloudLesson.location

                localLessonRepository.updateLesson(
                    existingLesson
                )

            } else {

                let localLesson =
                    Lesson(
                        id: cloudLesson.id,
                        title: cloudLesson.title,
                        date: cloudLesson.date,
                        durationMinutes:
                            cloudLesson.durationMinutes,
                        studentID:
                            localStudentID,
                        teacherID:
                            localTeacher.id,
                        notes:
                            cloudLesson.notes,
                        location:
                            cloudLesson.location
                    )

                localLessonRepository.addLesson(
                    localLesson
                )
            }
        }

        // finds cloud lessons that have since been deleted
        let deletedCloudIDs =
            previousCloudIDs.subtracting(
                currentCloudIDs
            )

        for deletedID in deletedCloudIDs {

            if let localLesson =
                localLessonRepository
                    .getAllLessons()
                    .first(where: {
                        $0.id == deletedID
                    }) {

                localLessonRepository.deleteLesson(
                    localLesson
                )
            }
        }

        // remembers the current cloud state for the next sync
        LessonSyncStateService.saveSyncedLessonIDs(
            currentCloudIDs,
            studentID: localStudentID
        )
    }
}
