//
//  ProfileView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

struct ProfileView: View {

    let user: User

    @ObservedObject var viewModel: SettingsViewModel

    @Environment(\.dismiss)
    private var dismiss

    @State private var isEditing = false
    @State private var editedName = ""
    @State private var isSaving = false
    

    var body: some View {

        NavigationStack {

            VStack(
                alignment: .leading,
                spacing: 20
            ) {

                HStack {

                    Spacer()

                    Image(
                        systemName: "person.circle.fill"
                    )
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                    Spacer()
                }

                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {

                    if isEditing {

                        VStack(
                            alignment: .leading,
                            spacing: 6
                        ) {

                            Text("Name")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            TextField(
                                "Name",
                                text: $editedName
                            )
                            .textFieldStyle(.roundedBorder)
                        }

                    } else {

                        profileRow(
                            title: "Name",
                            value: user.name
                        )
                    }

                    Divider()

                    profileRow(
                        title: "Email",
                        value: user.email
                    )

                    Divider()

                    profileRow(
                        title: "Role",
                        value: user.role.rawValue.capitalized
                    )
                }
                .padding()
                .background(
                    .gray.opacity(0.10)
                )
                .cornerRadius(14)

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {

                // LEFT SIDE — closes the Profile sheet
                ToolbarItem(
                    placement: .topBarLeading
                ) {

                    Button("Done") {
                        dismiss()
                    }
                }

                // RIGHT SIDE — switches between Edit and Save
                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    if isEditing {

                        Button("Save") {

                            Task {

                                isSaving = true

                                let success =
                                    await viewModel.updateStudentProfile(
                                        user: user,
                                        name: editedName
                                    )

                                isSaving = false

                                if success {
                                    isEditing = false
                                }
                            }
                        }
                        .disabled(isSaving)

                    } else {

                        Button("Edit") {
                            editedName = user.name
                            isEditing = true
                        }
                    }
                }
            }
        }
        .onAppear {
            editedName = user.name
        }
    }

    // creates a reusable row for displaying profile information
    private func profileRow(
        title: String,
        value: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .fontWeight(.medium)
        }
    }
}
