//
//  LoginViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""

    private let userRepository: UserRepository

    // creates the view model with access to stored users
    init(
        userRepository: UserRepository
    ) {
        self.userRepository = userRepository
    }

    // validates the entered credentials and returns the matching user if successful
    func login() -> User? {

        errorMessage = ""

        // normalises the email so spaces and capitalisation do not affect login
        let normalizedEmail =
            email
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        let users =
            userRepository.getAllUsers()

        // finds a user with the matching email and verifies the entered password
        let matchingUser =
            users.first { user in
                user.normalizedEmail
                    == normalizedEmail
                &&
                PasswordHasher.verify(
                    password: password,
                    hash: user.passwordHash
                )
            }

        if let matchingUser {
            return matchingUser
        }

        errorMessage =
            "Email or password is incorrect. Please check your details and try again."

        return nil
    }
}
