//
//  AddLessonView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

private enum RecurrenceEndOption:
    String,
    CaseIterable,
    Identifiable {

    case never
    case onDate

    var id: String {
        rawValue
    }

    var displayName: String {

        switch self {

        case .never:
            return "Never"

        case .onDate:
            return "On Date"
        }
    }
}

struct AddLessonView: View {

    let teacher: User
    
    @ObservedObject var viewModel: TeacherCalendarViewModel

    @Environment(\.dismiss)
    private var dismiss

    @State private var selectedStudentID: UUID?

    @State private var title = "Piano Lesson"

    @State private var date = Date()
    @State private var durationMinutes = 60

    @State private var location = ""

    @State private var notes = ""

    @State private var recurrence:
        LessonRecurrence = .none

    @State private var recurrenceEnds =
        RecurrenceEndOption.never

    @State private var recurrenceEndDate =
        Calendar.current.date(
            byAdding: .month,
            value: 3,
            to: Date()
        ) ?? Date()
    
    @State private var showConflictAlert = false
    @State private var conflictMessage = ""
    @State private var pendingStudentID: UUID?
    
    @State private var isSaving = false

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
                                    Optional(
                                        student.id
                                    )
                                )
                        }
                    }
                }


                Section("Lesson Details") {

                    TextField(
                        "Lesson title",
                        text: $title
                    )

                    DatePicker(
                        "Date and Time",
                        selection: $date,
                        displayedComponents: [
                            .date,
                            .hourAndMinute
                        ]
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


                Section("Repeat") {

                    Picker(
                        "Repeat",
                        selection: $recurrence
                    ) {

                        Text("Does not repeat")
                            .tag(LessonRecurrence.none)

                        Text("Weekly")
                            .tag(LessonRecurrence.weekly)
                    }

                    if recurrence == .weekly {

                        Picker(
                            "Ends",
                            selection: $recurrenceEnds
                        ) {

                            ForEach(
                                RecurrenceEndOption.allCases
                            ) { option in

                                Text(option.displayName)
                                    .tag(option)
                            }
                        }

                        if recurrenceEnds == .onDate {

                            DatePicker(
                                "End Date",
                                selection: $recurrenceEndDate,
                                in: date...,
                                displayedComponents: .date
                            )
                        }
                    }
                }


                Section("Notes") {

                    TextField(
                        "Lesson notes",
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }


                Section {

                    Button {

                        addLesson()

                    } label: {

                        Text("Add Lesson")
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
                                in:
                                    .whitespacesAndNewlines
                            )
                            .isEmpty
                        ||
                        location
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                }
            }
            .navigationTitle(
                "Add Lesson"
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
            .alert(
                "Lesson Conflict",
                isPresented: $showConflictAlert
            ) {

                Button(
                    "Change Time",
                    role: .cancel
                ) { }

                Button(
                    "Add Anyway",
                    role: .destructive
                ) {

                    addLessonIgnoringConflict()
                }

            } message: {

                Text(
                    "\(conflictMessage)\n\nDo you still want to add this lesson?"
                )
            }
        }
    }

    // attempts to schedule the lesson and handles scheduling conflicts
    private func addLesson() {

        guard !isSaving else {
            return
        }

        guard let selectedStudentID else {
            return
        }

        isSaving = true

        Task {

            do {

                try await viewModel.addLesson(
                    title: title,
                    date: date,
                    durationMinutes: durationMinutes,
                    location: location,
                    notes: notes,
                    studentID: selectedStudentID,
                    teacherID: teacher.id,
                    recurrence: recurrence,
                    recurrenceEndDate:
                        recurrence == .weekly &&
                        recurrenceEnds == .onDate
                            ? recurrenceEndDate
                            : nil
                )

                dismiss()

            } catch ScheduleLessonError.schedulingConflict {

                // allow Add Anyway to be pressed
                isSaving = false

                pendingStudentID =
                    selectedStudentID

                if let conflict =
                    viewModel.conflictingLesson(
                        startingDate: date,
                        durationMinutes: durationMinutes,
                        teacherID: teacher.id,
                        recurrence: recurrence,
                        recurrenceEndDate:
                            recurrence == .weekly &&
                            recurrenceEnds == .onDate
                                ? recurrenceEndDate
                                : nil
                    ) {

                    let conflictStart =
                        conflict.date.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )

                    let conflictEnd =
                        conflict.date
                            .addingTimeInterval(
                                TimeInterval(
                                    conflict.durationMinutes * 60
                                )
                            )
                            .formatted(
                                date: .omitted,
                                time: .shortened
                            )

                    conflictMessage =
                        "\(conflict.title) is already scheduled from \(conflictStart) to \(conflictEnd)."
                }

                showConflictAlert = true

            } catch {

                isSaving = false

                print(
                    "Failed to schedule lesson: \(error)"
                )
            }
        }
    }
    
    // adds the lesson after the user chooses to ignore the conflict warning
    private func addLessonIgnoringConflict() {

        guard !isSaving else {
            return
        }

        guard let studentID =
            pendingStudentID
        else {
            return
        }

        isSaving = true

        Task {

            do {

                try await viewModel.addLesson(
                    title: title,
                    date: date,
                    durationMinutes: durationMinutes,
                    location: location,
                    notes: notes,
                    studentID: studentID,
                    teacherID: teacher.id,
                    recurrence: recurrence,
                    recurrenceEndDate:
                        recurrence == .weekly &&
                        recurrenceEnds == .onDate
                            ? recurrenceEndDate
                            : nil,
                    allowConflict: true
                )

                showConflictAlert = false

                // closes the Add Lesson modal
                dismiss()

            } catch {

                isSaving = false

                print(
                    "Failed to schedule lesson: \(error)"
                )
            }
        }
    }
}
