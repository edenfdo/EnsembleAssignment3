//
//  PracticeTaskSyncStateService.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 2/10/2026.
//

import Foundation

enum PracticeTaskSyncStateService {

    // saves the cloud practice task IDs previously synced for a student
    static func saveSyncedTaskIDs(
        _ ids: Set<UUID>,
        studentID: UUID
    ) {

        let values =
            ids.map {
                $0.uuidString
            }

        UserDefaults.standard.set(
            values,
            forKey: key(
                studentID: studentID
            )
        )
    }

    // retrieves the cloud practice task IDs previously synced for a student
    static func getSyncedTaskIDs(
        studentID: UUID
    ) -> Set<UUID> {

        let values =
            UserDefaults.standard.stringArray(
                forKey: key(
                    studentID: studentID
                )
            )
            ?? []

        return Set(
            values.compactMap {
                UUID(
                    uuidString: $0
                )
            }
        )
    }

    
    
    // saves the cloud practice task IDs previously synced for a teacher
    static func saveSyncedTaskIDs(
        _ ids: Set<UUID>,
        teacherID: UUID
    ) {

        let values =
            ids.map {
                $0.uuidString
            }

        UserDefaults.standard.set(
            values,
            forKey: teacherKey(
                teacherID: teacherID
            )
        )
    }

    // retrieves the cloud practice task IDs previously synced for a teacher
    static func getSyncedTaskIDs(
        teacherID: UUID
    ) -> Set<UUID> {

        let values =
            UserDefaults.standard.stringArray(
                forKey: teacherKey(
                    teacherID: teacherID
                )
            )
            ?? []

        return Set(
            values.compactMap {
                UUID(
                    uuidString: $0
                )
            }
        )
    }
    
    // creates a separate storage key for each student
    private static func key(
        studentID: UUID
    ) -> String {

        "syncedPracticeTaskIDs_\(studentID.uuidString)"
    }
    
    // creates a separate storage key for each teacher
    private static func teacherKey(
        teacherID: UUID
    ) -> String {

        "syncedTeacherPracticeTaskIDs_\(teacherID.uuidString)"
    }
}
