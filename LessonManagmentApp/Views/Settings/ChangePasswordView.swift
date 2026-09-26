//
//  ChangePasswordView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

struct ChangePasswordView: View {

    let user: User

    @ObservedObject var viewModel:
        SettingsViewModel

    @Environment(\.dismiss)
    private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    var body: some View {

        NavigationStack {

            Form {

                Section("Password") {

                    SecureField(
                        "Current password",
                        text: $currentPassword
                    )

                    SecureField(
                        "New password",
                        text: $newPassword
                    )

                    SecureField(
                        "Confirm new password",
                        text: $confirmPassword
                    )
                }

                if !viewModel.errorMessage.isEmpty {

                    Section {

                        Text(
                            viewModel.errorMessage
                        )
                        .foregroundStyle(.red)
                    }
                }

                Section {

                    Button {

                        // attempts to change the password and closes the form if successful
                        let success =
                            viewModel.changePassword(
                                user: user,
                                currentPassword:
                                    currentPassword,
                                newPassword:
                                    newPassword,
                                confirmPassword:
                                    confirmPassword
                            )

                        if success {

                            dismiss()
                        }

                    } label: {

                        Text("Change Password")
                            .fontWeight(.semibold)
                            .frame(
                                maxWidth: .infinity
                            )
                    }
                }
            }
            .navigationTitle(
                "Change Password"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {

                ToolbarItem(
                    placement: .topBarLeading
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
