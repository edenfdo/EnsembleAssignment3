//
//  LocalUserRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import SwiftData

final class LocalUserRepository: UserRepository {

    private let modelContext: ModelContext

    // creates the repository using the SwiftData model context
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // fetches all users stored in SwiftData
    func getAllUsers() -> [User] {

        let descriptor = FetchDescriptor<User>()

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch users: \(error)")
            return []
        }
    }
    
    // returns only users with the student role
    func getStudents() -> [User] {

        getAllUsers().filter {
            $0.role == .student
        }
    }
    
    // returns only users with the teacher role
    func getTeachers() -> [User] {

        getAllUsers().filter {
            $0.role == .teacher
        }
    }

    // adds a new user to SwiftData and saves the change
    func addUser(_ user: User) {

        modelContext.insert(user)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    // saves changes made to an existing user
    func updateUser(_ user: User) {

        do {
            try modelContext.save()
        } catch {
            print(
                "Failed to update user: \(error)"
            )
        }
    }
}
