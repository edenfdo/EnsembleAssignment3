//
//  AssignPracticeTaskView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

struct AssignPracticeTaskView: View {

    let teacher: User

    @ObservedObject var viewModel: TeacherPracticeViewModel

    @Environment(\.dismiss)
    private var dismiss

    @State private var title = ""
    @State private var taskDescription = ""

    @State private var selectedStudentID: UUID?
    @State private var selectedLessonID: UUID?

    @State private var dueDate = Date()

    @State private var errorMessage = ""

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
                        "Select Student",
                        selection: $selectedStudentID
                    ) {

                        Text("Select Student")
                            .tag(UUID?.none)

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
                                "Select Lesson",
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

                        assignTask()

                    } label: {

                        Text("Assign Practice Task")
                            .fontWeight(.semibold)
                            .frame(
                                maxWidth: .infinity
                            )
                    }
                }
            }
            .navigationTitle(
                "Assign Practice Task"
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

            // clears the selected lesson when the student changes
            .onChange(
                of: selectedStudentID
            ) {

                selectedLessonID = nil
                errorMessage = ""
            }

            // resets the due date when a different lesson is selected
            .onChange(
                of: selectedLessonID
            ) {

                errorMessage = ""

                if let lesson =
                    selectedLesson {

                    dueDate =
                        lesson.date
                            .addingTimeInterval(
                                3600
                            )
                }
            }
        }
    }

    // finds the lesson currently selected by the teacher
    private var selectedLesson:
        Lesson? {

        guard let selectedLessonID
        else {

            return nil
        }

        return viewModel.lessons.first {

            $0.id ==
                selectedLessonID
        }
    }

    // validates the form and assigns the practice task to the selected lesson
    private func assignTask() {

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

        // attempts to create the task using the selected student, lesson and due date
        let success =
            viewModel.assignTask(
                title: title,
                description:
                    taskDescription,
                studentID:
                    studentID,
                teacherID:
                    teacher.id,
                lessonID:
                    lessonID,
                dueDate:
                    dueDate
            )

        if success {

            dismiss()

        } else {

            errorMessage =
                "Due date must be after the lesson date."
        }
    }

    // formats the lesson title and date for display in the lesson picker
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
