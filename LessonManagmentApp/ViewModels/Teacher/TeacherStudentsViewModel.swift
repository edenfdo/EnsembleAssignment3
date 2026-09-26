//
//  TeacherStudentsViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine

final class TeacherStudentsViewModel: ObservableObject {

    @Published var students: [User] = []

    private let userRepository: UserRepository

    // creates the view model with access to stored users
    init(
        userRepository: UserRepository
    ) {
        self.userRepository = userRepository
    }

    // loads all students from the user repository
    func loadStudents() {

        students =
            userRepository.getStudents()
    }

    // creates a new student account and saves it to the user repository
    func addStudent(
        firstName: String,
        lastName: String,
        email: String,
        password: String
    ) -> Bool {

        let normalizedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let emailAlreadyExists = userRepository
            .getAllUsers()
            .contains {
                $0.normalizedEmail == normalizedEmail
            }

        guard !emailAlreadyExists else {
            return false
        }
        
        // combines the first and last name and removes extra spaces
        let fullName = "\(firstName) \(lastName)"
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let student = User(
            name: fullName,
            email: email,
            password: password,
            role: .student
        )

        userRepository.addUser(student)
        loadStudents()

        return true
    }
    
}
