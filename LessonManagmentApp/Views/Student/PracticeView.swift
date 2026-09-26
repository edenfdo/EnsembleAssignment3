//
//  PracticeView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 6/9/2026.
//

import SwiftUI
import SwiftData
import Lottie

struct PracticeView: View {

    @StateObject var viewModel: PracticeViewModel

    @Binding var showMenu: Bool
    @Binding var selectedSection: StudentSection

    let studentID: UUID

    @State private var animatingTaskID: UUID?

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


                    Text("Practice")
                        .font(.largeTitle)
                        .fontWeight(.bold)


                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {

                        Text("Weekly Progress")
                            .font(.headline)

                        ProgressView(
                            value: viewModel.progress
                        )

                        Text(
                            "\(viewModel.completedTaskCount) of \(viewModel.practiceTasks.count) tasks complete"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Divider()


                    Text("Your Tasks")
                        .font(.headline)

                    ForEach(
                        viewModel.practiceTasks
                    ) { task in

                        // toggles the task and plays the completion animation when it is newly completed
                        Button {

                            let wasCompleted =
                                task.isCompleted

                            viewModel
                                .toggleTaskCompletion(
                                    task
                                )

                            if !wasCompleted {

                                animatingTaskID =
                                    task.id

                                DispatchQueue.main
                                    .asyncAfter(
                                        deadline:
                                            .now() + 1.5
                                    ) {

                                        animatingTaskID =
                                            nil
                                    }
                            }

                        } label: {

                            HStack(
                                alignment: .top,
                                spacing: 12
                            ) {


                                ZStack {

                                    if animatingTaskID
                                        == task.id {

                                        LottieView(
                                            animation:
                                                .named(
                                                    "taskComplete"
                                                )
                                        )
                                        .playing()
                                        .frame(
                                            width: 32,
                                            height: 32
                                        )

                                    } else {

                                        Image(
                                            systemName:
                                                task.isCompleted
                                                ? "checkmark.circle.fill"
                                                : "circle"
                                        )
                                        .font(.title3)
                                        .foregroundStyle(
                                            task.isCompleted
                                            ? Color(
                                                red: 183 / 255,
                                                green: 41 / 255,
                                                blue: 41 / 255
                                            )
                                            : .secondary
                                        )
                                    }
                                }
                                .frame(
                                    width: 32,
                                    height: 32
                                )


                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {

                                    Text(task.title)
                                        .fontWeight(.semibold)

                                    if !task.taskDescription
                                        .trimmingCharacters(
                                            in: .whitespacesAndNewlines
                                        )
                                        .isEmpty {

                                        Text(
                                            task.taskDescription
                                        )
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    }

                                    // Lesson attached to this task
                                    if let lesson =
                                        viewModel.lessonForTask(
                                            task
                                        ) {

                                        Text(
                                            "Lesson: \(lesson.title)"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                        Text(
                                            "Lesson Date: \(lesson.date, style: .date)"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }

                                    // Due date
                                    if let dueDate =
                                        task.dueDate {

                                        Text(
                                            "Due \(dueDate, style: .date)"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()
                            }
                            .padding()
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .background(
                                .gray.opacity(0.15)
                            )
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .onAppear {

            viewModel.loadTasks(
                for: studentID
            )
        }
    }
}


// creates sample practice tasks and a view model for the practice preview
private func makePreviewPracticeViewModel(
    repository: LocalPracticeTaskRepository,
    lessonRepository: LocalLessonRepository,
    studentID: UUID,
    teacherID: UUID
) -> PracticeViewModel {

    let lessonID = UUID()

    let task1 = PracticeTask(
        id: UUID(),
        title: "Practise C Major scale",
        description: "Practise slowly with both hands.",
        studentID: studentID,
        teacherID: teacherID,
        lessonID: lessonID,
        dueDate: Date().addingTimeInterval(86400),
        isCompleted: true
    )

    let task2 = PracticeTask(
        id: UUID(),
        title: "Complete rhythm quiz",
        description:
            "Complete the rhythm quiz before your next lesson.",
        studentID: studentID,
        teacherID: teacherID,
        lessonID: lessonID,
        dueDate: Date().addingTimeInterval(172800),
        isCompleted: false
    )

    let task3 = PracticeTask(
        id: UUID(),
        title: "Practise bars 1–16",
        description:
            "Focus on accurate notes and rhythm.",
        studentID: studentID,
        teacherID: teacherID,
        lessonID: lessonID,
        dueDate: Date().addingTimeInterval(259200),
        isCompleted: false
    )

    repository.addTask(task1)
    repository.addTask(task2)
    repository.addTask(task3)

    return PracticeViewModel(
        practiceTaskRepository: repository,
        lessonRepository: lessonRepository
    )
}

#Preview {

    @Previewable
    @State var showMenu = false
    
    @Previewable
    @State var selectedSection: StudentSection = .practice
    
    let studentID = UUID()
    let teacherID = UUID()

    let container = try! ModelContainer(
        for:
            PracticeTask.self,
            Lesson.self,
        configurations:
            ModelConfiguration(
                isStoredInMemoryOnly: true
            )
    )

    let practiceTaskRepository =
        LocalPracticeTaskRepository(
            modelContext: container.mainContext
        )
    
    let lessonRepository =
        LocalLessonRepository(
            modelContext: container.mainContext
        )

    let viewModel =
        makePreviewPracticeViewModel(
            repository: practiceTaskRepository,
            lessonRepository: lessonRepository,
            studentID: studentID,
            teacherID: teacherID
        )

    PracticeView(
        viewModel: viewModel,
        showMenu: $showMenu,
        selectedSection: $selectedSection,
        studentID: studentID
    )
    .modelContainer(container)
}
