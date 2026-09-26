//
//  TeacherCalendarView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//


import SwiftUI

struct TeacherCalendarView: View {

    @Binding var showMenu: Bool
    @Binding var selectedSection: TeacherSection

    let teacher: User

    @StateObject var viewModel: TeacherCalendarViewModel

    @State private var showAddLessonSheet = false
    @State private var selectedDate = Date()
    @State private var displayedMonth = Date()
    @State private var selectedLesson: Lesson?
    
    @State private var lessonToEdit: Lesson?
    @State private var lessonToDelete: Lesson?
    @State private var showDeleteAlert = false

    private let calendar = Calendar.current

    var body: some View {

        ZStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 20
                ) {


                    MenuBarView(
                        showMenu: $showMenu,
                        onLogoTap: {
                            selectedSection = .home
                        }
                    )


                    Text("Calendar")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        "View and manage your lessons."
                    )
                    .foregroundStyle(.secondary)


                    Button {

                        showAddLessonSheet = true

                    } label: {

                        HStack {

                            Image(
                                systemName: "plus"
                            )

                            Text("Add Lesson")
                                .fontWeight(.semibold)

                            Spacer()
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .background(.blue)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)


                    LessonCalendarView(
                        selectedDate:
                            $selectedDate,
                        displayedMonth:
                            $displayedMonth,
                        lessons:
                            viewModel.lessons
                    )
                    .padding()
                    .background(
                        .gray.opacity(0.08)
                    )
                    .cornerRadius(14)
                    

                    Text(
                        selectedDate.formatted(
                            date: .complete,
                            time: .omitted
                        )
                    )
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 4)


                    if lessonsForSelectedDate.isEmpty {

                        Text(
                            "No lessons scheduled for this day."
                        )
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 10)

                    } else {

                        ForEach(
                            lessonsForSelectedDate,
                            id: \.id
                        ) { lesson in

                            lessonCard(
                                lesson
                            )
                        }
                    }

                    Spacer()
                }
                .padding()
            }


            if let lesson = selectedLesson {

                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        selectedLesson = nil
                    }

                VStack(
                    spacing: 0
                ) {

                    HStack {

                        Text("Lesson Details")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()

                        Button {

                            selectedLesson = nil

                        } label: {

                            Image(
                                systemName: "xmark"
                            )
                            .font(.title2)
                            .foregroundStyle(.blue)
                        }
                    }
                    .padding()

                    Divider()

                    LessonDetailView(
                        lesson: lesson,
                        practiceTasks:
                            viewModel.practiceTasksForLesson(
                                lesson
                            ),
                        resources:
                            viewModel.resourcesForLesson(
                                lesson
                            ),
                        onToggleTask: { _ in
                        },
                        onOpenResource: { _ in
                        }
                    )
                }
                .frame(
                    maxWidth: 500,
                    maxHeight: 700
                )
                .background(
                    Color(.systemBackground)
                )
                .cornerRadius(20)
                .shadow(radius: 20)
                .padding(30)
            }
        }

        .onAppear {

            viewModel.loadData(
                teacherID: teacher.id
            )
        }

        .sheet(
            isPresented: $showAddLessonSheet
        ) {

            AddLessonView(
                teacher: teacher,
                viewModel: viewModel
            )
        }
        .sheet(
            item: $lessonToEdit
        ) { lesson in

            EditLessonView(
                lesson: lesson,
                teacher: teacher,
                viewModel: viewModel
            )
        }
        .alert(
            "Delete Lesson?",
            isPresented: $showDeleteAlert
        ) {

            Button(
                "Cancel",
                role: .cancel
            ) {
                lessonToDelete = nil
            }

            Button(
                "Delete",
                role: .destructive
            ) {

                if let lesson = lessonToDelete {

                    viewModel.deleteLesson(
                        lesson,
                        teacherID: teacher.id
                    )
                }

                lessonToDelete = nil
            }

        } message: {

            Text(
                "Are you sure you want to delete this lesson? This action cannot be undone."
            )
        }
    }
    


    // builds the reusable card layout for each lesson
    private func lessonCard(
        _ lesson: Lesson
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            HStack {

                Text(
                    lesson.title
                )
                .font(.headline)
                .foregroundStyle(.primary)

                Spacer()

                Menu {

                    Button {

                        lessonToEdit = lesson

                    } label: {

                        Label(
                            "Edit Lesson",
                            systemImage: "pencil"
                        )
                    }

                    Button(
                        role: .destructive
                    ) {

                        lessonToDelete = lesson
                        showDeleteAlert = true

                    } label: {

                        Label(
                            "Delete Lesson",
                            systemImage: "trash"
                        )
                    }

                } label: {

                    Image(
                        systemName: "ellipsis"
                    )
                    .font(.headline)
                    .frame(
                        width: 30,
                        height: 30
                    )
                    .background(
                        Color.gray.opacity(0.12)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 8
                        )
                    )
                    .foregroundStyle(.primary)
                }
            }

            if let student =
                viewModel.studentForLesson(
                    lesson
                ) {

                HStack {

                    Image(
                        systemName: "person"
                    )

                    Text(student.name)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            HStack(
                spacing: 8
            ) {

                Image(
                    systemName: "clock"
                )
                .foregroundStyle(.secondary)

                Text(
                    "\(lesson.date.formatted(date: .omitted, time: .shortened)) – \(lesson.date.addingTimeInterval(TimeInterval(lesson.durationMinutes * 60)).formatted(date: .omitted, time: .shortened))"
                )
                .foregroundStyle(.secondary)
            }
            
            HStack {

                Image(
                    systemName: "mappin.and.ellipse"
                )

                Text(
                    lesson.location
                )
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 20) {

                HStack(spacing: 6) {

                    Image(
                        systemName: "paperclip"
                    )

                    Text(
                        "\(viewModel.resourcesForLesson(lesson).count)"
                    )
                }

                HStack(spacing: 6) {

                    Image(
                        systemName: "checklist"
                    )

                    Text(
                        "\(viewModel.practiceTasksForLesson(lesson).count)"
                    )
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            HStack {

                Spacer()

                Button {

                    selectedLesson = lesson

                } label: {

                    HStack(
                        spacing: 5
                    ) {

                        Text(
                            "View Details"
                        )

                        Image(
                            systemName: "chevron.right"
                        )
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            .gray.opacity(0.12)
        )
        .cornerRadius(14)
    }


    // filters lessons for the selected date and sorts them by time
    private var lessonsForSelectedDate:
        [Lesson] {

        viewModel.lessons
            .filter {

                calendar.isDate(
                    $0.date,
                    inSameDayAs: selectedDate
                )
            }
            .sorted {

                $0.date < $1.date
            }
    }
}
