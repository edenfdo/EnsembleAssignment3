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
    case missingPassword
}


struct AddStudentUseCase {

    private let userRepository: UserRepository


    // creates the use case with access to user data
    init(
        userRepository: UserRepository
    ) {

        self.userRepository =
            userRepository
    }


    // creates a student while enforcing account creation rules
    func execute(
        firstName: String,
        lastName: String,
        email: String,
        password: String
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


        guard !password
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
        else {
            throw AddStudentError.missingPassword
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


        let fullName =
            "\(cleanedFirstName) \(cleanedLastName)"
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )


        let student = User(
            name: fullName,
            email: cleanedEmail,
            password: password,
            role: .student
        )


        userRepository.addUser(
            student
        )
    }
}
