//
//  LoginViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine
import Supabase

@MainActor
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

    // authenticates with Supabase and returns the matching local user
    func login() async -> User? {

        errorMessage = ""

        // normalises the email so spaces and capitalisation do not affect login
        let normalizedEmail =
            email
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        do {

            // authenticates the entered credentials with Supabase
            try await SupabaseService.client.auth.signIn(
                email: normalizedEmail,
                password: password
            )

            let users =
                userRepository.getAllUsers()

            // finds the local user so the existing app can continue using their details and role
            guard let matchingUser =
                users.first(where: {
                    $0.normalizedEmail == normalizedEmail
                })
            else {
                errorMessage =
                    "Your account was authenticated, but no local user profile was found."

                return nil
            }

            return matchingUser

        } catch {

            errorMessage =
                "Email or password is incorrect. Please check your details and try again."

            return nil
        }
    }
}
