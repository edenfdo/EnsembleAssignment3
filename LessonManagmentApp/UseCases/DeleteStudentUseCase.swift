//
//  DeleteStudentUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 3/10/2026.
//

import Foundation

final class DeleteStudentUseCase {

    private let localUserRepository: UserRepository
    private let localLessonRepository: LessonRepository
    private let localPracticeTaskRepository: PracticeTaskRepository
    private let localResourceRepository: ResourceRepository

    private let cloudUserRepository: SupabaseUserRepository

    init(
        localUserRepository: UserRepository,
        localLessonRepository: LessonRepository,
        localPracticeTaskRepository: PracticeTaskRepository,
        localResourceRepository: ResourceRepository,
        cloudUserRepository: SupabaseUserRepository
    ) {
        self.localUserRepository =
            localUserRepository

        self.localLessonRepository =
            localLessonRepository

        self.localPracticeTaskRepository =
            localPracticeTaskRepository

        self.localResourceRepository =
            localResourceRepository

        self.cloudUserRepository =
            cloudUserRepository
    }

    func execute(
        student: User
    ) async throws {

        // Delete from Supabase first.
        // The Edge Function removes the student's:
        // resources + Storage files,
        // practice tasks,
        // lessons,
        // profile,
        // and Auth account.
        try await cloudUserRepository.deleteStudent(
            email: student.email
        )

        // Find the student's local data.
        let resources =
            localResourceRepository.getResources(
                forStudentID: student.id
            )

        let practiceTasks =
            localPracticeTaskRepository.getTasks(
                forStudentID: student.id
            )

        let lessons =
            localLessonRepository.getLessons(
                forStudentID: student.id
            )

        // Delete locally stored resource files
        // and their SwiftData records.
        for resource in resources {

            let fileURL = resource.localFileURL

            if FileManager.default.fileExists(
                atPath: fileURL.path
            ) {
                do {
                    try FileManager.default.removeItem(
                        at: fileURL
                    )
                } catch {
                    print(
                        "Failed to delete local resource file: \(error)"
                    )
                }
            }

            localResourceRepository.deleteResource(
                resource
            )
        }

        // Delete local practice tasks.
        for task in practiceTasks {
            localPracticeTaskRepository.deleteTask(
                task
            )
        }

        // Delete local lessons.
        for lesson in lessons {
            localLessonRepository.deleteLesson(
                lesson
            )
        }

        // Finally delete the local student.
        localUserRepository.deleteUser(
            student
        )
    }
}
