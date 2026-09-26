//
//  EditLessonView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 13/9/2026.
//

import SwiftUI

struct EditLessonView: View {

    let lesson: Lesson
    let teacher: User

    @ObservedObject
    var viewModel: TeacherCalendarViewModel

    @Environment(\.dismiss)
    private var dismiss

    @State private var title: String
    @State private var date: Date
    @State private var durationMinutes: Int
    @State private var location: String
    @State private var notes: String
    
    @State private var showConflictAlert = false
    @State private var conflictMessage = ""

    // pre-fills the edit form with the existing lesson details
    init(
        lesson: Lesson,
        teacher: User,
        viewModel: TeacherCalendarViewModel
    ) {

        self.lesson = lesson
        self.teacher = teacher
        self.viewModel = viewModel

        _title = State(
            initialValue: lesson.title
        )

        _date = State(
            initialValue: lesson.date
        )

        _durationMinutes = State(
            initialValue: lesson.durationMinutes
        )

        _location = State(
            initialValue: lesson.location
        )

        _notes = State(
            initialValue: lesson.notes
        )
    }

    var body: some View {

        NavigationStack {

            Form {

                Section(
                    "Lesson Details"
                ) {

                    TextField(
                        "Lesson title",
                        text: $title
                    )

                    DatePicker(
                        "Date and Time",
                        selection: $date
                    )

                    Stepper(
                        "Duration: \(durationMinutes) minutes",
                        value: $durationMinutes,
                        in: 15...180,
                        step: 15
                    )

                    TextField(
                        "Location",
                        text: $location
                    )
                }

                Section(
                    "Notes"
                ) {

                    TextField(
                        "Lesson notes",
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(
                        3...6
                    )
                }
            }
            .navigationTitle(
                "Edit Lesson"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button(
                        "Cancel"
                    ) {

                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {

                    Button(
                        "Save"
                    ) {

                        // checks for another lesson conflict while ignoring the lesson being edited
                        if let conflict =
                            viewModel.conflictingLesson(
                                startingDate: date,
                                durationMinutes:
                                    durationMinutes,
                                teacherID:
                                    teacher.id,
                                repeatOption:
                                    .none,
                                numberOfLessons: 1,
                                excludingLessonID:
                                    lesson.id
                            ) {

                            conflictMessage =
                                "This lesson overlaps with \(conflict.title)."

                            showConflictAlert = true

                        } else {

                            saveLesson()
                        }
                    }
                    .disabled(
                        title
                            .trimmingCharacters(
                                in: .whitespaces
                            )
                            .isEmpty
                    )
                }
            }
        }
        .alert(
            "Lesson Conflict",
            isPresented:
                $showConflictAlert
        ) {

            Button(
                "Change Time",
                role: .cancel
            ) { }

            Button(
                "Save Anyway",
                role: .destructive
            ) {

                saveLesson()
            }

        } message: {

            Text(
                conflictMessage
            )
        }
    }
    
    // updates the lesson with the edited values and closes the form
    private func saveLesson() {

        viewModel.updateLesson(
            lesson,
            title: title,
            date: date,
            durationMinutes:
                durationMinutes,
            location:
                location,
            notes:
                notes,
            teacherID:
                teacher.id
        )

        dismiss()
    }
}
