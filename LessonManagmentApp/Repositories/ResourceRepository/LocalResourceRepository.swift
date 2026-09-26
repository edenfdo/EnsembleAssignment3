//
//  LocalResourceRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import SwiftData

final class LocalResourceRepository:
    ResourceRepository {

    private let modelContext: ModelContext

    // creates the repository using the SwiftData model context
    init(
        modelContext: ModelContext
    ) {
        self.modelContext = modelContext
    }

    // fetches all resources stored in SwiftData
    func getAllResources()
    -> [Resource] {

        let descriptor =
            FetchDescriptor<Resource>()

        do {

            return try modelContext.fetch(
                descriptor
            )

        } catch {

            print(
                "Failed to fetch resources: \(error)"
            )

            return []
        }
    }
    
    // returns only resources assigned to the specified student
    func getResources(
        forStudentID studentID: UUID
    ) -> [Resource] {

        getAllResources().filter {
            $0.studentID == studentID
        }
    }

    // returns only resources assigned by the specified teacher
    func getResources(
        forTeacherID teacherID: UUID
    ) -> [Resource] {

        getAllResources().filter {
            $0.teacherID == teacherID
        }
    }

    // adds a new resource to SwiftData and saves the change
    func addResource(
        _ resource: Resource
    ) {

        modelContext.insert(
            resource
        )

        saveContext()
    }

    // saves any pending changes to the SwiftData context
    private func saveContext() {

        do {

            try modelContext.save()

        } catch {

            print(
                "Failed to save resource: \(error)"
            )
        }
    }
    
    // saves changes made to an existing resource
    func updateResource(
        _ resource: Resource
    ) {

        do {
            try modelContext.save()
        } catch {
            print(
                "Failed to update resource: \(error)"
            )
        }
    }
    
    // deletes a resource from SwiftData and saves the change
    func deleteResource(
        _ resource: Resource
    ) {

        modelContext.delete(
            resource
        )

        do {

            try modelContext.save()

        } catch {

            print(
                "Failed to delete resource: \(error)"
            )
        }
    }
}
