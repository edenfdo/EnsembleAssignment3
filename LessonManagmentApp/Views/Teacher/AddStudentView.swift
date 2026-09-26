//
//  AddStudentView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

struct AddStudentView: View {

    @State private var password = ""
    
    @ObservedObject var viewModel: TeacherStudentsViewModel
    
    @State private var showDuplicateEmailAlert = false

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
                    
                    SecureField(
                        "Password",
                        text: $password
                    )
                }

                Section {

                    Button {

                        addStudent()

                    } label: {

                        Text("Add Student")
                            .fontWeight(
                                .semibold
                            )
                            .frame(
                                maxWidth:
                                    .infinity
                            )
                    }
                    .disabled(
                        firstName
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                        ||
                        email
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                        ||
                        password
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                }
            }
            .navigationTitle(
                "Add Student"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {

                ToolbarItem(
                    placement:
                        .topBarLeading
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert(
            "Email Already Exists",
            isPresented: $showDuplicateEmailAlert
        ) {
            Button("OK", role: .cancel) {
            }
        } message: {
            Text("An account with this email address already exists.")
        }
    }
    

    // creates the student account using the entered details and closes the form
    private func addStudent() {
        let wasAdded = viewModel.addStudent(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        )

        if wasAdded {
            dismiss()
        } else {
            showDuplicateEmailAlert = true
        }
    }
}
