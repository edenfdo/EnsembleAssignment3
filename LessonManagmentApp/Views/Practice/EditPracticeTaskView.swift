//
//  EditPracticeTaskView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 3/10/2026.
//

import SwiftUI

struct EditPracticeTaskView: View {

    let teacher: User
    let task: PracticeTask

    @ObservedObject var viewModel: TeacherPracticeViewModel

    @Environment(\.dismiss)
    private var dismiss

    @State private var title: String
    @State private var taskDescription: String

    @State private var selectedStudentID: UUID?
    @State private var selectedLessonID: UUID?

    @State private var dueDate: Date

    @State private var errorMessage = ""
    @State private var isSaving = false

    init(
        teacher: User,
        task: PracticeTask,
        viewModel: TeacherPracticeViewModel
    ) {
        self.teacher = teacher
        self.task = task
        self.viewModel = viewModel

        _title =
            State(
                initialValue: task.title
            )

        _taskDescription =
            State(
                initialValue: task.taskDescription
            )

        _selectedStudentID =
            State(
                initialValue: task.studentID
            )

        _selectedLessonID =
            State(
                initialValue: task.lessonID
            )

        _dueDate =
            State(
                initialValue:
                    task.dueDate ?? Date()
            )
    }

    var body: some View {

        NavigationStack {

            Form {

                Section("Task Details") {

                    TextField(
                        "Task Title",
                        text: $title
                    )

                    TextField(
                        "Description",
                        text: $taskDescription,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }


                Section("Student") {

                    Picker(
                        "Student",
                        selection: $selectedStudentID
                    ) {

                        ForEach(
                            viewModel.students
                        ) { student in

                            Text(student.name)
                                .tag(
                                    Optional(
                                        student.id
                                    )
                                )
                        }
                    }
                }


                Section("Lesson") {

                    if let studentID =
                        selectedStudentID {

                        let studentLessons =
                            viewModel.lessonsForStudent(
                                studentID: studentID
                            )

                        if studentLessons.isEmpty {

                            Text(
                                "No lessons available for this student."
                            )
                            .foregroundStyle(.secondary)

                        } else {

                            Picker(
                                "Lesson",
                                selection:
                                    $selectedLessonID
                            ) {

                                Text("Select Lesson")
                                    .tag(UUID?.none)

                                ForEach(
                                    studentLessons
                                ) { lesson in

                                    Text(
                                        lessonDisplayName(
                                            lesson
                                        )
                                    )
                                    .tag(
                                        Optional(
                                            lesson.id
                                        )
                                    )
                                }
                            }
                        }

                    } else {

                        Text(
                            "Select a student first."
                        )
                        .foregroundStyle(.secondary)
                    }
                }


                Section("Due Date") {

                    if let lesson =
                        selectedLesson {

                        let minimumDueDate =
                            lesson.date
                                .addingTimeInterval(
                                    60
                                )

                        DatePicker(
                            "Due Date",
                            selection: $dueDate,
                            in: minimumDueDate...,
                            displayedComponents: [
                                .date,
                                .hourAndMinute
                            ]
                        )

                        Text(
                            "Due date must be after the lesson."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    } else {

                        DatePicker(
                            "Due Date",
                            selection: $dueDate,
                            displayedComponents: [
                                .date,
                                .hourAndMinute
                            ]
                        )
                        .disabled(true)

                        Text(
                            "Select a lesson before choosing a due date."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }


                if !errorMessage.isEmpty {

                    Section {

                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }


                Section {

                    Button {

                        updateTask()

                    } label: {

                        Text(
                            isSaving
                            ? "Saving..."
                            : "Save Changes"
                        )
                        .fontWeight(.semibold)
                        .frame(
                            maxWidth: .infinity
                        )
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle(
                "Edit Practice Task"
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
                    .disabled(isSaving)
                }
            }

            // A different student may have different lessons.
            .onChange(
                of: selectedStudentID
            ) {

                // Only clear the lesson if the currently
                // selected lesson doesn't belong to the
                // newly selected student.
                if let studentID =
                    selectedStudentID {

                    let studentLessons =
                        viewModel.lessonsForStudent(
                            studentID: studentID
                        )

                    if !studentLessons.contains(
                        where: {
                            $0.id ==
                                selectedLessonID
                        }
                    ) {
                        selectedLessonID = nil
                    }
                }

                errorMessage = ""
            }

            .onChange(
                of: selectedLessonID
            ) {

                errorMessage = ""

                if let lesson =
                    selectedLesson {

                    // Don't overwrite the existing due date
                    // when the edit screen first appears.
                    if dueDate <= lesson.date {

                        dueDate =
                            lesson.date
                                .addingTimeInterval(
                                    3600
                                )
                    }
                }
            }
        }
    }


    private var selectedLesson: Lesson? {

        guard let selectedLessonID
        else {
            return nil
        }

        return viewModel.lessons.first {
            $0.id == selectedLessonID
        }
    }


    private func updateTask() {

        errorMessage = ""

        guard !title
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
        else {

            errorMessage =
                "Please enter a task title."

            return
        }

        guard let studentID =
            selectedStudentID
        else {

            errorMessage =
                "Please select a student."

            return
        }

        guard let lessonID =
            selectedLessonID
        else {

            errorMessage =
                "Please select a lesson."

            return
        }

        Task {

            isSaving = true

            do {

                try await viewModel.updateTask(
                    task,
                    title: title,
                    description:
                        taskDescription,
                    studentID:
                        studentID,
                    lessonID:
                        lessonID,
                    dueDate:
                        dueDate,
                    teacherID:
                        teacher.id
                )

                isSaving = false
                dismiss()

            } catch AssignPracticeTaskError.invalidDueDate {

                isSaving = false

                errorMessage =
                    "Due date must be after the lesson date."

            } catch AssignPracticeTaskError.lessonNotFound {

                isSaving = false

                errorMessage =
                    "The selected lesson could not be found."

            } catch AssignPracticeTaskError.missingTitle {

                isSaving = false

                errorMessage =
                    "Please enter a task title."

            } catch SavePracticeTaskToCloudError.studentProfileNotFound {

                isSaving = false

                errorMessage =
                    "The selected student's cloud profile could not be found."

            } catch SavePracticeTaskToCloudError.lessonNotFound {

                isSaving = false

                errorMessage =
                    "This lesson has not been synced to the cloud yet."

            } catch {

                isSaving = false

                errorMessage =
                    "Unable to update the practice task."

                print(
                    "Failed to update practice task: \(error)"
                )
            }
        }
    }


    private func lessonDisplayName(
        _ lesson: Lesson
    ) -> String {

        let date =
            lesson.date.formatted(
                date: .abbreviated,
                time: .shortened
            )

        return "\(lesson.title) - \(date)"
    }
}
