//
//  SyncTeacherStudentsUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 3/10/2026.
//


import Foundation
import Supabase

struct SyncTeacherStudentsUseCase {

    private let cloudUserRepository:
        SupabaseUserRepository

    private let localUserRepository:
        UserRepository

    init(
        cloudUserRepository:
            SupabaseUserRepository,
        localUserRepository:
            UserRepository
    ) {
        self.cloudUserRepository =
            cloudUserRepository

        self.localUserRepository =
            localUserRepository
    }


    // synchronises the teacher's cloud students with local SwiftData
    func execute() async throws {

        // gets the authenticated teacher's Supabase ID
        let authenticatedTeacher =
            try await SupabaseService.client.auth.user()

        // gets only students belonging to this teacher
        let cloudStudents =
            try await cloudUserRepository.getStudents(
                teacherID: authenticatedTeacher.id
            )

        let localStudents =
            localUserRepository.getStudents()
        
        let previousCloudEmails =
            StudentSyncStateService
                .getSyncedStudentEmails(
                    teacherID: authenticatedTeacher.id
                )

        let currentCloudEmails =
            Set(
                cloudStudents.map {
                    $0.email
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .lowercased()
                }
            )


        for cloudStudent in cloudStudents {

            let normalizedEmail =
                cloudStudent.email
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .lowercased()

            // updates an existing local student
            if let existingStudent =
                localStudents.first(where: {
                    $0.normalizedEmail ==
                    normalizedEmail
                }) {

                existingStudent.name =
                    cloudStudent.name

                existingStudent.email =
                    cloudStudent.email

                existingStudent.normalizedEmail =
                    normalizedEmail

                localUserRepository.updateUser(
                    existingStudent
                )

            } else {

                // creates the student locally on a fresh device
                let localStudent =
                    User(
                        id: cloudStudent.id,
                        name: cloudStudent.name,
                        email: cloudStudent.email,
                        role: .student
                    )

                localUserRepository.addUser(
                    localStudent
                )
            }
        }
        // finds students that existed during the previous sync
        // but have since been deleted from Supabase
        let deletedCloudEmails =
            previousCloudEmails.subtracting(
                currentCloudEmails
            )

        for deletedEmail in deletedCloudEmails {

            if let localStudent =
                localUserRepository
                    .getStudents()
                    .first(where: {
                        $0.normalizedEmail ==
                            deletedEmail
                    }) {

                localUserRepository.deleteUser(
                    localStudent
                )
            }
        }

        // remembers the current cloud students
        // for the next sync
        StudentSyncStateService
            .saveSyncedStudentEmails(
                currentCloudEmails,
                teacherID: authenticatedTeacher.id
            )
    }
}
