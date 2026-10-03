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

    // tells the app whether the user must choose a new password
    @Published var requiresPasswordChange = false

    private let userRepository: UserRepository
    private let supabaseUserRepository =
        SupabaseUserRepository()

    // creates the view model with access to stored users
    init(
        userRepository: UserRepository
    ) {
        self.userRepository = userRepository
    }

    // authenticates with Supabase and returns the matching local user
    func login() async -> User? {

        errorMessage = ""
        requiresPasswordChange = false

        // normalises the email so spaces and capitalisation do not affect login
        let normalizedEmail =
            email
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        do {

            // authenticates the entered credentials with Supabase
            let session =
                try await SupabaseService.client.auth.signIn(
                    email: normalizedEmail,
                    password: password
                )

            // retrieves the authenticated user's profile from Supabase
            guard let profile =
                try await supabaseUserRepository.getProfile(
                    id: session.user.id
                )
            else {

                errorMessage =
                    "Your account was authenticated, but no profile was found."

                return nil
            }

            // remembers whether this user must change their password
            requiresPasswordChange =
                profile.mustChangePassword

            let users =
                userRepository.getAllUsers()

            // uses the existing local user if one is already stored
            if let existingUser =
                users.first(where: {
                    $0.normalizedEmail ==
                        normalizedEmail
                }) {

                return existingUser
            }

            // converts the Supabase role into the app's UserRole
            guard let role =
                UserRole(
                    rawValue: profile.role
                )
            else {

                errorMessage =
                    "Your account has an invalid user role."

                return nil
            }

            // creates a local representation of the Supabase user
            // without storing their Supabase password
            let newUser = User(
                id: profile.id,
                name: profile.name,
                email: profile.email,
                role: role
            )

            userRepository.addUser(
                newUser
            )

            return newUser

        } catch {

            print(
                "Login failed: \(error)"
            )

            errorMessage =
                "Unable to sign in. Please check your email and password and try again."

            return nil
        }
    }
}
