//
//  CalendarView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 6/9/2026.
//

import SwiftUI
import SwiftData

struct CalendarView: View {

    @StateObject var viewModel: CalendarViewModel
    @Binding var showMenu: Bool

    let studentID: UUID

    @State private var selectedLesson: Lesson?
    @State private var selectedResource: Resource?
    @State private var displayedMonth: Date = Date()
    
    @Binding var selectedSection: StudentSection


    var body: some View {

        ZStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 20) {

                    MenuBarView(
                        showMenu: $showMenu,
                        onLogoTap: {
                            selectedSection = .home
                        }
                    )

                    Text("Calendar")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    
                    LessonCalendarView(
                        selectedDate:
                            $viewModel.selectedDate,
                        displayedMonth:
                            $displayedMonth,
                        lessons:
                            viewModel.lessons
                    )

                    Text("Lessons")
                        .font(.headline)

                    let selectedLessons =
                        viewModel.lessons(
                            for: viewModel.selectedDate
                        )

                    if selectedLessons.isEmpty {

                        Text("No lessons scheduled for this day.")
                            .foregroundStyle(.secondary)

                    } else {

                        ForEach(selectedLessons) { lesson in

                            Button {
                                selectedLesson = lesson
                            } label: {

                                VStack(alignment: .leading, spacing: 10) {

                                    // Lesson title
                                    Text(lesson.title)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    // Lesson time
                                    Text(lesson.date, style: .time)
                                        .foregroundStyle(.secondary)

                                    // Lesson location
                                    Text(lesson.location)
                                        .foregroundStyle(.secondary)
                                    
                                    HStack(
                                        spacing: 20
                                    ) {

                                        HStack(
                                            spacing: 6
                                        ) {

                                            Image(
                                                systemName: "paperclip"
                                            )
                                            .foregroundStyle(.secondary)

                                            Text(
                                                "\(viewModel.resourcesForLesson(lesson).count)"
                                            )
                                            .foregroundStyle(.secondary)
                                        }

                                        HStack(
                                            spacing: 6
                                        ) {

                                            Image(
                                                systemName: "checklist"
                                            )
                                            .foregroundStyle(.secondary)

                                            Text(
                                                "\(viewModel.practiceTasksForLesson(lesson).count)"
                                            )
                                            .foregroundStyle(.secondary)
                                        }

                                        Spacer()
                                    }
                                    .font(.subheadline)
                                    
                                    // Visual cue
                                    HStack {

                                        Spacer()

                                        HStack(spacing: 5) {

                                            Text("View Details")

                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.blue)
                                    }
                                }
                                .padding()
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .background(.gray.opacity(0.15))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .onAppear {

                viewModel.loadData(
                    studentID: studentID
                )

                displayedMonth =
                    viewModel.selectedDate
            }


            if let lesson = selectedLesson {

                Color.black
                    .opacity(0.3)
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
                            .font(.headline)
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
                        onToggleTask: { task in

                            viewModel.toggleTaskCompletion(
                                task
                            )
                        },
                        // replaces the lesson details popup with the selected resource preview
                        onOpenResource: { resource in

                            selectedLesson = nil
                            selectedResource = resource
                        }
                    )
                }
                .frame(
                    maxWidth: 320,
                    maxHeight: 700
                )
                .background(
                    Color(.systemBackground)
                )
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding()
            }


            if let resource = selectedResource {

                Color.black
                    .opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {

                        selectedResource = nil
                    }

                ResourcePreviewView(
                    resource: resource,
                    subtitle:
                        "From \(resource.teacherName)",
                    onClose: {

                        selectedResource = nil
                    }
                )
                .padding()
            }
        }
    }
   
}

// creates sample lesson data and a view model for the calendar preview
private func makeCalendarPreviewViewModel(
    lessonRepository: LocalLessonRepository,
    practiceTaskRepository: LocalPracticeTaskRepository,
    resourceRepository: LocalResourceRepository,
    studentID: UUID,
    teacherID: UUID
) -> CalendarViewModel {

    let calendar = Calendar.current
    let today = Date()

    let lessonDate1 =
        calendar.date(
            byAdding: .day,
            value: 1,
            to: today
        )!

    let lessonDate2 =
        calendar.date(
            byAdding: .day,
            value: 3,
            to: today
        )!

    let lesson1 = Lesson(
        id: UUID(),
        title: "Piano Lesson",
        date: lessonDate1,
        durationMinutes: 60,
        studentID: studentID,
        teacherID: teacherID,
        notes: "Practise C major scale and bars 1–16.",
        location: "Room 3"
    )

    let lesson2 = Lesson(
        id: UUID(),
        title: "Piano Lesson",
        date: lessonDate2,
        durationMinutes: 60,
        studentID: studentID,
        teacherID: teacherID,
        notes: "Focus on rhythm and dynamics.",
        location: "Room 3"
    )

    lessonRepository.addLesson(lesson1)
    lessonRepository.addLesson(lesson2)

    return CalendarViewModel(
        lessonRepository: lessonRepository,
        practiceTaskRepository: practiceTaskRepository,
        resourceRepository: resourceRepository
    )
}

#Preview {

    @Previewable
    @State var showMenu = false
    
    @Previewable
    @State var selectedSection: StudentSection = .calendar

    let studentID = UUID()
    let teacherID = UUID()

    let container = try! ModelContainer(
        for: Lesson.self,
        PracticeTask.self,
        Resource.self,
        configurations: ModelConfiguration(
            isStoredInMemoryOnly: true
        )
    )

    let lessonRepository =
        LocalLessonRepository(
            modelContext: container.mainContext
        )
    
    let practiceTaskRepository =
        LocalPracticeTaskRepository(
            modelContext: container.mainContext
        )

    let resourceRepository =
        LocalResourceRepository(
            modelContext: container.mainContext
        )

    let viewModel =
        makeCalendarPreviewViewModel(
            lessonRepository: lessonRepository,
            practiceTaskRepository: practiceTaskRepository,
            resourceRepository: resourceRepository,
            studentID: studentID,
            teacherID: teacherID
        )

    CalendarView(
        viewModel: viewModel,
        showMenu: $showMenu,
        studentID: studentID,
        selectedSection: $selectedSection,
    )
    .modelContainer(container)
}
