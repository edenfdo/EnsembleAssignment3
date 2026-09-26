//
//  TeacherProfileDetailsView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

struct TeacherProfileDetailsView: View {

    let name: String
    let email: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        NavigationStack {

            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {

                    profileField(
                        title: "Name",
                        value: name
                    )

                    profileField(
                        title: "Email",
                        value: email
                    )

                    profileField(
                        title: "Role",
                        value: "Teacher"
                    )
                }

                Spacer()
            }
            .padding()
            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // creates a reusable field for displaying teacher profile information
    private func profileField(
        title: String,
        value: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            .gray.opacity(0.10)
        )
        .cornerRadius(12)
    }
}
