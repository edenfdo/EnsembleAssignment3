//
//  AddStudentView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//


import SwiftUI
import UIKit

struct AddStudentView: View {

    @ObservedObject var viewModel: TeacherStudentsViewModel

    @State private var showDuplicateEmailAlert = false
    @State private var showAccountCreatedAlert = false

    @State private var isCreating = false

    @State private var temporaryPassword = ""
    @State private var createdStudentName = ""

    @Environment(\.dismiss)
    private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""

    var body: some View {

        NavigationStack {

            Form {

                Section("Student Details") {

                    TextField(
                        "First name",
                        text: $firstName
                    )

                    TextField(
                        "Last name",
                        text: $lastName
                    )

                    TextField(
                        "Email",
                        text: $email
                    )
                    .textInputAutocapitalization(
                        .never
                    )
                    .keyboardType(
                        .emailAddress
                    )
                }

                Section {

                    Button {

                        Task {
                            await createStudent()
                        }

                    } label: {

                        if isCreating {

                            ProgressView()
                                .frame(
                                    maxWidth: .infinity
                                )

                        } else {

                            Text("Create Student Account")
                                .fontWeight(
                                    .semibold
                                )
                                .frame(
                                    maxWidth: .infinity
                                )
                        }
                    }
                    .disabled(
                        (
                            firstName
                                .trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                .isEmpty
                            &&
                            lastName
                                .trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                .isEmpty
                        )
                        ||
                        email
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                        ||
                        isCreating
                    )
                }
            }
            .navigationTitle(
                "Create Student Account"
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

        // shown if the email already belongs to a local user
        .alert(
            "Email Already Exists",
            isPresented: $showDuplicateEmailAlert
        ) {
            Button("OK", role: .cancel) {
            }
        } message: {
            Text(
                "An account with this email address already exists."
            )
        }

        // shown after Supabase successfully creates the account
        .alert(
            "Student Account Created",
            isPresented: $showAccountCreatedAlert
        ) {

            Button("Copy Password & Done") {

                UIPasteboard.general.string =
                    temporaryPassword

                dismiss()
            }

        } message: {

            Text(
                """
                \(createdStudentName)'s account has been created.

                Temporary password:
                \(temporaryPassword)

                Copy this password and give it to the student. They will be asked to change it when they first log in.
                """
            )
        }
    }


    // validates the details and creates the student's Supabase account
    @MainActor
    private func createStudent() async {

        isCreating = true

        defer {
            isCreating = false
        }

        do {

            let student =
                try await viewModel.addStudent(
                    firstName: firstName,
                    lastName: lastName,
                    email: email
                )

            createdStudentName =
                student.name

            temporaryPassword =
                student.temporaryPassword

            showAccountCreatedAlert = true

        } catch AddStudentError.emailAlreadyExists {

            showDuplicateEmailAlert = true

        } catch AddStudentError.missingName {

            print(
                "Student name is required."
            )

        } catch AddStudentError.invalidEmail {

            print(
                "A valid email address is required."
            )

        } catch {

            print(
                "Failed to create student: \(error)"
            )
        }
    }
}
