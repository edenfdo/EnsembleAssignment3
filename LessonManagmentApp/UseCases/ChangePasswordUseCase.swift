//
//  ChangePasswordUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/9/2026.
//

import Foundation


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


    // changes a user's password while enforcing password rules
    func execute(
        user: User,
        currentPassword: String,
        newPassword: String,
        confirmPassword: String
    ) throws {

        // checks that the current password is correct
        guard PasswordHasher.verify(
            password: currentPassword,
            hash: user.passwordHash
        ) else {

            throw ChangePasswordError
                .incorrectCurrentPassword
        }


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


        user.passwordHash =
            PasswordHasher.hash(
                newPassword
            )


        userRepository.updateUser(
            user
        )
    }
}
