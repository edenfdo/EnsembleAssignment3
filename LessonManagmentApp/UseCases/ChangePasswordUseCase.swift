//
//  ChangePasswordUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/9/2026.
//

import Foundation
import Supabase
import Auth


enum ChangePasswordError: Error {

    case incorrectCurrentPassword
    case passwordTooShort
    case passwordsDoNotMatch
}


struct ChangePasswordUseCase {

    private let userRepository: UserRepository


    // creates the use case with access to user data
    init(
        userRepository: UserRepository
    ) {

        self.userRepository =
            userRepository
    }


    // changes a user's Supabase password while enforcing password rules
    func execute(
        user: User,
        currentPassword: String,
        newPassword: String,
        confirmPassword: String
    ) async throws {

        // ensures the new password meets the minimum length
        guard newPassword.count >= 6 else {

            throw ChangePasswordError
                .passwordTooShort
        }

        // ensures both new password entries match
        guard newPassword == confirmPassword else {

            throw ChangePasswordError
                .passwordsDoNotMatch
        }

        let normalizedEmail =
            user.email
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        do {

            try await SupabaseService.client.auth.signIn(
                email: normalizedEmail,
                password: currentPassword
            )

        } catch {

            throw ChangePasswordError
                .incorrectCurrentPassword
        }

        // changes the password stored by Supabase Auth
        try await SupabaseService.client.auth.update(
            user: UserAttributes(
                password: newPassword
            )
        )

        // tells the server that the required password change is complete
        try await SupabaseService.client
            .functions
            .invoke(
                "complete-password-change"
            )
    }
}
