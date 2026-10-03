//
//  SettingsViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var successMessage = ""

    private let userRepository: UserRepository
    
    private let changePasswordUseCase: ChangePasswordUseCase
    private let updateStudentProfileUseCase: UpdateStudentProfileUseCase

    // creates the view model with access to stored users
    init(
        userRepository: UserRepository
    ) {
        self.userRepository = userRepository
        
        self.changePasswordUseCase =
                ChangePasswordUseCase(
                    userRepository: userRepository
                )
        
        self.updateStudentProfileUseCase =
            UpdateStudentProfileUseCase(
                localUserRepository: userRepository,
                cloudUserRepository: SupabaseUserRepository()
            )
    }

    // changes the user's password through the change password use case
    func changePassword(
        user: User,
        currentPassword: String,
        newPassword: String,
        confirmPassword: String
    ) async ->  Bool {

        errorMessage = ""
        successMessage = ""

        do {

            try await changePasswordUseCase.execute(
                user: user,
                currentPassword: currentPassword,
                newPassword: newPassword,
                confirmPassword: confirmPassword
            )

            successMessage =
                "Password changed successfully."

            return true

        } catch ChangePasswordError.incorrectCurrentPassword {

            errorMessage =
                "Current password is incorrect."

            
            return false

        } catch ChangePasswordError.passwordTooShort {

            errorMessage =
                "New password must be at least 6 characters."

            return false

        } catch ChangePasswordError.passwordsDoNotMatch {

            errorMessage =
                "New passwords do not match."

            return false

        } catch {

            errorMessage =
                "Unable to change password."

            print(
                       "Failed to change password: \(error)"
                   )
            return false
        }
    }
    
    // updates the student's profile
    func updateStudentProfile(
        user: User,
        name: String
    ) async -> Bool {

        errorMessage = ""
        successMessage = ""

        do {

            try await updateStudentProfileUseCase.execute(
                user: user,
                name: name
            )

            successMessage =
                "Profile updated successfully."

            return true

        } catch UpdateStudentProfileError.nameRequired {

            errorMessage =
                "Name is required."

            return false

        } catch {

            errorMessage =
                "Unable to update profile."

            print(
                "Failed to update profile: \(error)"
            )

            return false
        }
    }
}
