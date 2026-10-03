//
//  AddStudentUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/9/2026.
//

import Foundation

enum AddStudentError: Error {
    case missingName
    case invalidEmail
    case emailAlreadyExists
}

struct AddStudentUseCase {

    private let userRepository: UserRepository

    // creates the use case with access to user data
    init(
        userRepository: UserRepository
    ) {
        self.userRepository = userRepository
    }

    // validates student details before an invitation is sent
    func execute(
        firstName: String,
        lastName: String,
        email: String
    ) throws {

        let cleanedFirstName =
            firstName.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanedLastName =
            lastName.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanedEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let normalizedEmail =
            cleanedEmail.lowercased()

        guard !cleanedFirstName.isEmpty
                || !cleanedLastName.isEmpty
        else {
            throw AddStudentError.missingName
        }

        guard cleanedEmail.contains("@")
                && cleanedEmail.contains(".")
        else {
            throw AddStudentError.invalidEmail
        }

        let emailAlreadyExists =
            userRepository
                .getAllUsers()
                .contains {
                    $0.normalizedEmail ==
                        normalizedEmail
                }

        guard !emailAlreadyExists else {
            throw AddStudentError.emailAlreadyExists
        }
    }
}
