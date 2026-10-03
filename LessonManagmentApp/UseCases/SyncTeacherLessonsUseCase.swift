//
//  SyncTeacherLessonsUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 3/10/2026.
//

import Foundation

struct SyncTeacherLessonsUseCase {

    private let cloudLessonRepository:
        SupabaseLessonRepository

    private let cloudUserRepository:
        SupabaseUserRepository

    private let localLessonRepository:
        LessonRepository

    private let localUserRepository:
        UserRepository


    init(
        cloudLessonRepository:
            SupabaseLessonRepository,
        cloudUserRepository:
            SupabaseUserRepository,
        localLessonRepository:
            LessonRepository,
        localUserRepository:
            UserRepository
    ) {
        self.cloudLessonRepository =
            cloudLessonRepository

        self.cloudUserRepository =
            cloudUserRepository

        self.localLessonRepository =
            localLessonRepository

        self.localUserRepository =
            localUserRepository
    }


    // synchronises the teacher's cloud lessons
    // with local SwiftData
    func execute(
        localTeacherID: UUID
    ) async throws {

        let cloudLessons =
            try await cloudLessonRepository.getLessons()

        let localUsers =
            localUserRepository.getAllUsers()

        let previousCloudIDs =
            LessonSyncStateService.getSyncedLessonIDs(
                teacherID: localTeacherID
            )

        let currentCloudIDs =
            Set(
                cloudLessons.map {
                    $0.id
                }
            )


        // adds new lessons and updates existing lessons
        for cloudLesson in cloudLessons {

            // gets the student attached to the cloud lesson
            guard let cloudStudent =
                try await cloudUserRepository.getProfile(
                    id: cloudLesson.studentID
                )
            else {
                continue
            }

            // finds the matching local student
            guard let localStudent =
                localUsers.first(where: {
                    $0.normalizedEmail
                    ==
                    cloudStudent.email
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


            // updates an existing local lesson
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
                    localStudent.id

                existingLesson.teacherID =
                    localTeacherID

                existingLesson.notes =
                    cloudLesson.notes

                existingLesson.location =
                    cloudLesson.location

                localLessonRepository.updateLesson(
                    existingLesson
                )

            } else {

                // creates the lesson locally
                let localLesson =
                    Lesson(
                        id: cloudLesson.id,
                        title: cloudLesson.title,
                        date: cloudLesson.date,
                        durationMinutes:
                            cloudLesson.durationMinutes,
                        studentID:
                            localStudent.id,
                        teacherID:
                            localTeacherID,
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


        // removes lessons that were deleted from Supabase
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


        // remembers the current cloud state
        LessonSyncStateService.saveSyncedLessonIDs(
            currentCloudIDs,
            teacherID: localTeacherID
        )
    }
}
