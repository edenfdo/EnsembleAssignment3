//
//  StudentSyncStateService.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 5/10/2026.
//

import Foundation

enum StudentSyncStateService {

    private static func key(
        teacherID: UUID
    ) -> String {

        "syncedTeacherStudentEmails_\(teacherID.uuidString)"
    }

    static func getSyncedStudentEmails(
        teacherID: UUID
    ) -> Set<String> {

        let storedEmails =
            UserDefaults.standard.stringArray(
                forKey: key(
                    teacherID: teacherID
                )
            ) ?? []

        return Set(storedEmails)
    }

    static func saveSyncedStudentEmails(
        _ emails: Set<String>,
        teacherID: UUID
    ) {

        UserDefaults.standard.set(
            Array(emails),
            forKey: key(
                teacherID: teacherID
            )
        )
    }
}
