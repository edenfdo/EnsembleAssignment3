//
//  SyncTeacherPracticeTasksUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 2/10/2026.
//

import Foundation

struct SyncTeacherPracticeTasksUseCase {

    private let cloudPracticeTaskRepository:
        SupabasePracticeTaskRepository

    private let cloudUserRepository:
        SupabaseUserRepository

    private let localPracticeTaskRepository:
        PracticeTaskRepository

    private let localUserRepository:
        UserRepository

    init(
        cloudPracticeTaskRepository:
            SupabasePracticeTaskRepository,
        cloudUserRepository:
            SupabaseUserRepository,
        localPracticeTaskRepository:
            PracticeTaskRepository,
        localUserRepository:
            UserRepository
    ) {
        self.cloudPracticeTaskRepository =
            cloudPracticeTaskRepository

        self.cloudUserRepository =
            cloudUserRepository

        self.localPracticeTaskRepository =
            localPracticeTaskRepository

        self.localUserRepository =
            localUserRepository
    }

    // synchronises the teacher's cloud practice tasks with local SwiftData
    func execute(
        localTeacherID: UUID
    ) async throws {

        let cloudTasks =
            try await cloudPracticeTaskRepository.getTasks()

        let localUsers =
            localUserRepository.getAllUsers()

        let previousCloudIDs =
            PracticeTaskSyncStateService.getSyncedTaskIDs(
                teacherID: localTeacherID
            )

        let currentCloudIDs =
            Set(
                cloudTasks.map {
                    $0.id
                }
            )

        // adds new tasks and updates existing cloud tasks
        for cloudTask in cloudTasks {

            guard let cloudStudent =
                try await cloudUserRepository.getProfile(
                    id: cloudTask.studentID
                )
            else {
                continue
            }

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

            let localTasks =
                localPracticeTaskRepository.getAllTasks()

            if let existingTask =
                localTasks.first(where: {
                    $0.id == cloudTask.id
                }) {

                existingTask.title =
                    cloudTask.title

                existingTask.taskDescription =
                    cloudTask.taskDescription

                existingTask.studentID =
                    localStudent.id

                existingTask.teacherID =
                    localTeacherID

                existingTask.lessonID =
                    cloudTask.lessonID

                existingTask.dueDate =
                    cloudTask.dueDate

                existingTask.isCompleted =
                    cloudTask.isCompleted

                localPracticeTaskRepository.updateTask(
                    existingTask
                )

            } else {

                let localTask =
                    PracticeTask(
                        id: cloudTask.id,
                        title: cloudTask.title,
                        description:
                            cloudTask.taskDescription,
                        studentID:
                            localStudent.id,
                        teacherID:
                            localTeacherID,
                        lessonID:
                            cloudTask.lessonID,
                        dueDate:
                            cloudTask.dueDate,
                        isCompleted:
                            cloudTask.isCompleted
                    )

                localPracticeTaskRepository.addTask(
                    localTask
                )
            }
        }

        // finds cloud tasks that have since been deleted
        let deletedCloudIDs =
            previousCloudIDs.subtracting(
                currentCloudIDs
            )

        for deletedID in deletedCloudIDs {

            if let localTask =
                localPracticeTaskRepository
                    .getAllTasks()
                    .first(where: {
                        $0.id == deletedID
                    }) {

                localPracticeTaskRepository.deleteTask(
                    localTask
                )
            }
        }

        // remembers the current cloud state for the next sync
        PracticeTaskSyncStateService.saveSyncedTaskIDs(
            currentCloudIDs,
            teacherID: localTeacherID
        )
    }
}
