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

    // true when the student must change their temporary password
    let isForcedChange: Bool

    // used after a forced password change is completed
    let onPasswordChanged: (() -> Void)?

    // allows the user to leave the forced password screen safely
    let onLogout: (() -> Void)?

    @Environment(\.dismiss)
    private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var showSuccessAlert = false

    init(
        user: User,
        viewModel: SettingsViewModel,
        isForcedChange: Bool = false,
        onPasswordChanged: (() -> Void)? = nil,
        onLogout: (() -> Void)? = nil
    ) {

        self.user = user

        self._viewModel =
            ObservedObject(
                wrappedValue: viewModel
            )

        self.isForcedChange =
            isForcedChange

        self.onPasswordChanged =
            onPasswordChanged

        self.onLogout =
            onLogout
    }

    var body: some View {

        NavigationStack {

            Form {

                if isForcedChange {

                    Section {

                        Text(
                            "You're currently using a temporary password. Create a new password before continuing."
                        )
                        .foregroundStyle(.secondary)
                    }
                }

                Section("Password") {

                    SecureField(
                        isForcedChange
                            ? "Temporary password"
                            : "Current password",
                        text: $currentPassword
                    )
                    .textContentType(.password)

                    SecureField(
                        "New password",
                        text: $newPassword
                    )
                    .textContentType(.newPassword)

                    SecureField(
                        "Confirm new password",
                        text: $confirmPassword
                    )
                    .textContentType(.newPassword)
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

                        Task {

                            let success =
                                await viewModel.changePassword(
                                    user: user,
                                    currentPassword:
                                        currentPassword,
                                    newPassword:
                                        newPassword,
                                    confirmPassword:
                                        confirmPassword
                                )

                            if success {
                                showSuccessAlert = true
                            }
                        }

                    } label: {

                        Text("Change Password")
                            .fontWeight(.semibold)
                            .frame(
                                maxWidth: .infinity
                            )
                    }
                }

                if isForcedChange {

                    Section {

                        Button(
                            "Sign Out",
                            role: .destructive
                        ) {
                            onLogout?()
                        }
                    }
                }
            }
            .navigationTitle(
                isForcedChange
                    ? "Create New Password"
                    : "Change Password"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {

                if !isForcedChange {

                    ToolbarItem(
                        placement: .topBarLeading
                    ) {

                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .alert(
                "Password Changed Successfully",
                isPresented: $showSuccessAlert
            ) {
                Button("Continue") {

                    if isForcedChange {
                        onPasswordChanged?()
                    } else {
                        dismiss()
                    }
                }
            } message: {
                Text(
                    "Your password has been updated successfully."
                )
            }
        }
    }
}
