//
//  StudentHomeView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/8/2026.
//

import SwiftUI
import SwiftData
import Lottie

struct StudentHomeView: View {

    @StateObject var viewModel: StudentHomeViewModel

    let studentID: UUID

    @Binding var showMenu: Bool
    @Binding var selectedSection: StudentSection

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
                    
                    
                    Text("Welcome!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    
                    if let lesson = viewModel.upcomingLesson {
                        
                        VStack(
                            alignment: .leading,
                            spacing: 8
                        ) {
                            
                            Text("Upcoming Lesson")
                                .font(.headline)
                            
                            Text(lesson.title)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(
                                lesson.date,
                                style: .date
                            )
                            .foregroundStyle(.secondary)
                            
                            Text(
                                lesson.date,
                                style: .time
                            )
                            .foregroundStyle(.secondary)
                            
                            Text(lesson.location)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                
                                Spacer()
                                
                                
                                Button {
                                    
                                    selectedSection = .calendar
                                    
                                } label: {
                                    
                                    HStack(spacing: 5) {
                                        
                                        Text("View Calendar")
                                        
                                        Image(
                                            systemName:
                                                "chevron.right"
                                        )
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.blue)
                                }
                            }
                            .padding(.top, 4)
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
                        
                    } else {
                        
                        Text("No upcoming lessons")
                            .foregroundStyle(.secondary)
                    }
                                        
                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {
                        
                        Text("This Week's Progress")
                            .font(.headline)
                        
                        ProgressView(
                            value: viewModel.progress
                        )
                        
                        Text(
                            "\(Int(viewModel.progress * 100))% complete"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    
                    Text("Tasks")
                        .font(.headline)
                    
                    ForEach(viewModel.practiceTasks) { task in
                        
                        // toggles the task and plays the completion animation when it is newly completed
                        Button {
                            
                            let wasCompleted = task.isCompleted
                            
                            viewModel.toggleTaskCompletion(task)
                            
                            if !wasCompleted {
                                
                                animatingTaskID = task.id
                                
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 1.5
                                ) {
                                    animatingTaskID = nil
                                }
                            }
                            
                        } label: {
                            
                            HStack(
                                alignment: .top,
                                spacing: 12
                            ) {
                                                                
                                ZStack {
                                    
                                    if animatingTaskID == task.id {
                                        
                                        LottieView(
                                            animation: .named("taskComplete")
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

                                    if let dueDate = task.dueDate {

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
            }
                .padding()
            }

            
        .onAppear {

            viewModel.loadHomeData(
                for: studentID
            )
        }
    }
}


// creates sample lesson and task data and a view model for the student home preview
private func makeStudentHomePreviewViewModel(
    lessonRepository: LocalLessonRepository,
    practiceTaskRepository: LocalPracticeTaskRepository,
    studentID: UUID,
    teacherID: UUID
) -> StudentHomeViewModel {

    let lessonID = UUID()

    let sampleLesson = Lesson(
        id: lessonID,
        title: "Piano Lesson",
        date: Date(),
        durationMinutes: 60,
        studentID: studentID,
        teacherID: teacherID,
        notes: "Practise C major scale.",
        location: "Room 3"
    )

    lessonRepository.addLesson(sampleLesson)

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
        description: "Complete the rhythm quiz before your next lesson.",
        studentID: studentID,
        teacherID: teacherID,
        lessonID: lessonID,
        dueDate: Date().addingTimeInterval(172800),
        isCompleted: false
    )

    let task3 = PracticeTask(
        id: UUID(),
        title: "Practise bars 1–16",
        description: "Focus on accurate notes and rhythm.",
        studentID: studentID,
        teacherID: teacherID,
        lessonID: lessonID,
        dueDate: Date().addingTimeInterval(259200),
        isCompleted: false
    )

    practiceTaskRepository.addTask(task1)
    practiceTaskRepository.addTask(task2)
    practiceTaskRepository.addTask(task3)

    return StudentHomeViewModel(
        lessonRepository: lessonRepository,
        practiceTaskRepository: practiceTaskRepository
    )
}


#Preview {

    @Previewable
    @State var showMenu = false

    @Previewable
    @State var selectedSection: StudentSection = .home

    let studentID = UUID()
    let teacherID = UUID()

    let container = try! ModelContainer(
        for: PracticeTask.self,
        Lesson.self,
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

    let viewModel =
        makeStudentHomePreviewViewModel(
            lessonRepository: lessonRepository,
            practiceTaskRepository: practiceTaskRepository,
            studentID: studentID,
            teacherID: teacherID
        )

    StudentHomeView(
        viewModel: viewModel,
        studentID: studentID,
        showMenu: $showMenu,
        selectedSection: $selectedSection
    )
    .modelContainer(container)
}
