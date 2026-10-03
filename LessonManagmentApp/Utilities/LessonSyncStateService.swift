//
//  LessonSyncStateService.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 1/10/2026.
//

import Foundation

enum LessonSyncStateService {

    // retrieves lesson IDs previously synced from Supabase
    static func getSyncedLessonIDs(
        studentID: UUID
    ) -> Set<UUID> {

        let key =
            "syncedLessonIDs_\(studentID.uuidString)"

        let storedIDs =
            UserDefaults.standard.stringArray(
                forKey: key
            )
            ?? []

        return Set(
            storedIDs.compactMap {
                UUID(uuidString: $0)
            }
        )
    }

    // stores the lesson IDs currently available from Supabase
    static func saveSyncedLessonIDs(
        _ lessonIDs: Set<UUID>,
        studentID: UUID
    ) {

        let key =
            "syncedLessonIDs_\(studentID.uuidString)"

        let storedIDs =
            lessonIDs.map {
                $0.uuidString
            }

        UserDefaults.standard.set(
            storedIDs,
            forKey: key
        )
    }
    
    // retrieves lesson IDs previously synced for a teacher
    static func getSyncedLessonIDs(
        teacherID: UUID
    ) -> Set<UUID> {

        let key =
            "syncedTeacherLessonIDs_\(teacherID.uuidString)"

        let storedIDs =
            UserDefaults.standard.stringArray(
                forKey: key
            )
            ?? []

        return Set(
            storedIDs.compactMap {
                UUID(uuidString: $0)
            }
        )
    }


    // stores the lesson IDs currently available
    // from Supabase for a teacher
    static func saveSyncedLessonIDs(
        _ lessonIDs: Set<UUID>,
        teacherID: UUID
    ) {

        let key =
            "syncedTeacherLessonIDs_\(teacherID.uuidString)"

        let storedIDs =
            lessonIDs.map {
                $0.uuidString
            }

        UserDefaults.standard.set(
            storedIDs,
            forKey: key
        )
    }
}
