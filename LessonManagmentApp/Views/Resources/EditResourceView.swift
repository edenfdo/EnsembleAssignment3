//
//  EditResourceView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 13/9/2026.
//


import SwiftUI
import UniformTypeIdentifiers

struct EditResourceView: View {

    let resource: Resource
    let teacher: User

    @ObservedObject var viewModel:
        TeacherResourcesViewModel

    @Environment(\.dismiss)
    private var dismiss

    @State private var title: String

    @State private var selectedFileURL: URL?

    @State private var showFileImporter = false

    @State private var errorMessage = ""

    // pre-fills the edit form with the existing resource title
    init(
        resource: Resource,
        teacher: User,
        viewModel: TeacherResourcesViewModel
    ) {

        self.resource = resource
        self.teacher = teacher
        self.viewModel = viewModel

        _title = State(
            initialValue: resource.title
        )
    }

    var body: some View {

        NavigationStack {

            Form {

                Section(
                    "Resource Details"
                ) {

                    TextField(
                        "Resource title",
                        text: $title
                    )
                }

                Section(
                    "Current File"
                ) {

                    HStack(
                        spacing: 12
                    ) {

                        Image(
                            systemName:
                                resource.fileType == .pdf
                                ? "doc.fill"
                                : "photo.fill"
                        )
                        .foregroundStyle(
                            .blue
                        )

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text(
                                resource.fileName
                            )
                            .fontWeight(
                                .medium
                            )

                            Text(
                                resource.fileType == .pdf
                                ? "PDF"
                                : "Image"
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )
                        }
                    }
                }

                Section(
                    "Replace File"
                ) {

                    if let selectedFileURL {

                        VStack(
                            alignment: .leading,
                            spacing: 6
                        ) {

                            Text(
                                "New file selected"
                            )
                            .fontWeight(
                                .medium
                            )

                            Text(
                                selectedFileURL
                                    .lastPathComponent
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )
                        }
                    }

                    Button {

                        showFileImporter = true

                    } label: {

                        Label(
                            selectedFileURL == nil
                            ? "Choose Replacement File"
                            : "Choose Different File",
                            systemImage:
                                "paperclip"
                        )
                    }

                    if selectedFileURL != nil {

                        Button(
                            role: .destructive
                        ) {

                            selectedFileURL =
                                nil

                        } label: {

                            Text(
                                "Remove Selected Replacement"
                            )
                        }
                    }

                    Text(
                        "If you do not choose a new file, the current file will remain unchanged."
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }

                if !errorMessage.isEmpty {

                    Section {

                        Text(
                            errorMessage
                        )
                        .foregroundStyle(
                            .red
                        )
                    }
                }

                Section {

                    Button {

                        saveChanges()

                    } label: {

                        Text(
                            "Save Changes"
                        )
                        .fontWeight(
                            .semibold
                        )
                        .frame(
                            maxWidth:
                                .infinity
                        )
                    }
                    .disabled(
                        title
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                }
            }

            .navigationTitle(
                "Edit Resource"
            )

            .navigationBarTitleDisplayMode(
                .inline
            )

            .toolbar {

                ToolbarItem(
                    placement:
                        .topBarLeading
                ) {

                    Button(
                        "Cancel"
                    ) {

                        dismiss()
                    }
                }
            }

            .fileImporter(
                isPresented:
                    $showFileImporter,
                allowedContentTypes: [
                    .pdf,
                    .image
                ],
                allowsMultipleSelection:
                    false
            ) { result in

                // stores the replacement file selected by the teacher
                switch result {

                case .success(
                    let urls
                ):

                    selectedFileURL =
                        urls.first

                    errorMessage = ""

                case .failure(
                    let error
                ):

                    errorMessage =
                        "Unable to select file: \(error.localizedDescription)"
                }
            }
        }
    }

    // validates the title and updates the resource with any selected replacement file
    private func saveChanges() {

        let cleanedTitle =
            title.trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        guard !cleanedTitle.isEmpty
        else {

            errorMessage =
                "Please enter a resource title."

            return
        }

        do {

            // updates the resource and replaces the file only if a new file was selected
            try viewModel.updateResource(
                resource: resource,
                title: cleanedTitle,
                selectedFileURL:
                    selectedFileURL,
                teacherID:
                    teacher.id
            )

            dismiss()

        } catch {

            errorMessage =
                "Unable to update resource: \(error.localizedDescription)"
        }
    }
}
