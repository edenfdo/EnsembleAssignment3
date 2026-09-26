//
//  AddResourceView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct AddResourceView: View {
    
    let teacher: User
    
    @ObservedObject var viewModel: TeacherResourcesViewModel
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State private var selectedStudentID: UUID?
    @State private var selectedLessonID: UUID?
    @State private var title = ""
    
    @State private var selectedFileURL: URL?
    @State private var selectedFileName = ""
    
    @State private var showFileImporter = false
    
    @State private var errorMessage = ""
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                
                Section("Student") {
                    
                    Picker(
                        "Select Student",
                        selection: $selectedStudentID
                    ) {
                        
                        Text("Select a student")
                            .tag(UUID?.none)
                        
                        ForEach(viewModel.students) { student in
                            
                            Text(student.name)
                                .tag(
                                    Optional(student.id)
                                )
                        }
                    }
                }
                // clears the selected lesson when the student changes
                .onChange(
                    of: selectedStudentID
                ) {
                    selectedLessonID = nil
                }
                
                Section("Lesson") {

                    if let selectedStudentID {

                        let studentLessons =
                            viewModel.lessonsForStudent(
                                studentID: selectedStudentID
                            )

                        Picker(
                            "Attach to Lesson",
                            selection: $selectedLessonID
                        ) {

                            Text("General / No Lesson")
                                .tag(UUID?.none)

                            ForEach(
                                studentLessons,
                                id: \.id
                            ) { lesson in

                                Text(
                                    "\(lesson.title) - \(lesson.date.formatted(date: .abbreviated, time: .shortened))"
                                )
                                .tag(
                                    Optional(
                                        lesson.id
                                    )
                                )
                            }
                        }

                    } else {

                        Text(
                            "Select a student first."
                        )
                        .foregroundStyle(.secondary)
                    }
                }
                
                
                Section("Resource Details") {
                    
                    TextField(
                        "Resource title",
                        text: $title
                    )
                    
                    Button {
                        
                        showFileImporter = true
                        
                    } label: {
                        
                        HStack {
                            
                            Image(
                                systemName:
                                    "doc.badge.plus"
                            )
                            
                            Text("Choose File")
                            
                            Spacer()
                        }
                    }
                    
                    if let selectedFileURL {

                        HStack {

                            Image(
                                systemName:
                                    viewModel.determineFileType(
                                        url: selectedFileURL
                                    ) == .pdf
                                    ? "doc.fill"
                                    : "photo.fill"
                            )

                            Text(selectedFileName)
                                .lineLimit(1)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                
                if !errorMessage.isEmpty {
                    
                    Section {
                        
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                
                
                Section {
                    
                    Button {
                        
                        addResource()
                        
                    } label: {
                        
                        Text("Share Resource")
                            .fontWeight(.semibold)
                            .frame(
                                maxWidth: .infinity
                            )
                    }
                    .disabled(
                        selectedStudentID == nil
                        ||
                        title
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                        ||
                        selectedFileURL == nil
                    )
                }
            }
            .navigationTitle(
                "Add Resource"
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
    
        
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [
                .pdf,
                .image
            ],
            allowsMultipleSelection: false
        ) { result in
            
            handleFileSelection(
                result
            )
        }
    }
    
    
    
    // handles the selected file and stores its URL and file name
    private func handleFileSelection(
        _ result: Result<[URL], Error>
    ) {
        
        do {
            
            guard let url =
                    try result.get().first
            else {
                return
            }
            
            selectedFileURL = url
            selectedFileName =
            url.lastPathComponent
            
            errorMessage = ""
            
        } catch {
            
            errorMessage =
            "Unable to select file."
        }
    }
    
    
    // validates the selected student and file before saving the resource
    private func addResource() {
        
        guard
            let selectedStudentID,
            let selectedFileURL
        else {
            return
        }
        
        do {
            
            // saves the file and creates the linked resource record
            try viewModel.addResource(
                title: title,
                selectedFileURL: selectedFileURL,
                studentID: selectedStudentID,
                lessonID: selectedLessonID,
                teacher: teacher
            )
            
            dismiss()
            
        } catch {
            
            errorMessage =
            "The selected file could not be saved."
        }
    }
}
