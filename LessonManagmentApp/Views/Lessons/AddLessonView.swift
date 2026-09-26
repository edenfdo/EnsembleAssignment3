//
//  AddLessonView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

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

    @State private var repeatOption:
        LessonRepeatOption = .none

    @State private var numberOfLessons = 4
    
    @State private var showConflictAlert = false
    @State private var conflictMessage = ""
    @State private var pendingStudentID: UUID?

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
                        selection: $repeatOption
                    ) {

                        ForEach(
                            LessonRepeatOption.allCases
                        ) { option in

                            Text(
                                option.displayName
                            )
                            .tag(option)
                        }
                    }

                    if repeatOption != .none {

                        Stepper(
                            "Number of lessons: \(numberOfLessons)",
                            value: $numberOfLessons,
                            in: 2...20
                        )
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

                        Text(
                            repeatOption == .none
                            ? "Add Lesson"
                            : "Add Lessons"
                        )
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


    // validates the lesson time and adds the lesson if there is no conflict
    private func addLesson() {

        guard let selectedStudentID
        else {
            return
        }

        // checks whether the new lesson overlaps an existing lesson
        if let conflict =
            viewModel.conflictingLesson(
                startingDate: date,
                durationMinutes: durationMinutes,
                teacherID: teacher.id,
                repeatOption: repeatOption,
                numberOfLessons: numberOfLessons
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

            conflictMessage = "\(conflict.title) is already scheduled from \(conflictStart) to \(conflictEnd)."

            // stores the selected student so the lesson can still be added after the warning
            pendingStudentID = selectedStudentID

            showConflictAlert = true

            return
        }
        viewModel.addLesson(
            title: title,
            date: date,
            durationMinutes: durationMinutes,
            location: location,
            notes: notes,
            studentID: selectedStudentID,
            teacherID: teacher.id,
            repeatOption: repeatOption,
            numberOfLessons: numberOfLessons
        )

        dismiss()
    }


    // calculates the date for each repeated lesson
    private func dateForLesson(
        index: Int
    ) -> Date {

        let calendar =
            Calendar.current

        switch repeatOption {

        case .none:

            return date

        case .weekly:

            return calendar.date(
                byAdding: .weekOfYear,
                value: index,
                to: date
            ) ?? date

        case .fortnightly:

            return calendar.date(
                byAdding: .weekOfYear,
                value: index * 2,
                to: date
            ) ?? date
        }
        
    }
    
    // adds the lesson after the user chooses to ignore the conflict warning
    private func addLessonIgnoringConflict() {

        guard let studentID =
            pendingStudentID
        else {
            return
        }

        viewModel.addLesson(
            title: title,
            date: date,
            durationMinutes: durationMinutes,
            location: location,
            notes: notes,
            studentID: studentID,
            teacherID: teacher.id,
            repeatOption: repeatOption,
            numberOfLessons: numberOfLessons
        )

        dismiss()
    }
}
