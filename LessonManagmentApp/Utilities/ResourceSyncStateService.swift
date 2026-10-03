//
//  ResourceSyncStateService.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 2/10/2026.
//

import Foundation

enum ResourceSyncStateService {

    // builds a unique key for each student's synced resources
    private static func key(
        studentID: UUID
    ) -> String {

        "syncedResourceIDs_\(studentID.uuidString)"
    }

    // retrieves resource IDs from the previous cloud sync
    static func getSyncedResourceIDs(
        studentID: UUID
    ) -> Set<UUID> {

        let storedIDs =
            UserDefaults.standard.stringArray(
                forKey: key(
                    studentID: studentID
                )
            )
            ?? []

        return Set(
            storedIDs.compactMap {
                UUID(uuidString: $0)
            }
        )
    }

    // remembers the current cloud resource IDs
    static func saveSyncedResourceIDs(
        _ resourceIDs: Set<UUID>,
        studentID: UUID
    ) {

        let storedIDs =
            resourceIDs.map {
                $0.uuidString
            }

        UserDefaults.standard.set(
            storedIDs,
            forKey: key(
                studentID: studentID
            )
        )
    }
    
    // builds a unique key for each teacher's synced resources
    private static func teacherKey(
        teacherID: UUID
    ) -> String {

        "syncedTeacherResourceIDs_\(teacherID.uuidString)"
    }


    // retrieves resource IDs from the teacher's previous cloud sync
    static func getSyncedResourceIDs(
        teacherID: UUID
    ) -> Set<UUID> {

        let storedIDs =
            UserDefaults.standard.stringArray(
                forKey: teacherKey(
                    teacherID: teacherID
                )
            )
            ?? []

        return Set(
            storedIDs.compactMap {
                UUID(uuidString: $0)
            }
        )
    }


    // remembers the current cloud resource IDs for a teacher
    static func saveSyncedResourceIDs(
        _ resourceIDs: Set<UUID>,
        teacherID: UUID
    ) {

        let storedIDs =
            resourceIDs.map {
                $0.uuidString
            }

        UserDefaults.standard.set(
            storedIDs,
            forKey: teacherKey(
                teacherID: teacherID
            )
        )
    }
}

