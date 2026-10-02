//
//  PracticeViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 6/9/2026.
//

import Foundation
import Combine

class PracticeViewModel: ObservableObject {

    @Published var practiceTasks: [PracticeTask] = []
    @Published var lessons: [Lesson] = []

    private let practiceTaskRepository: PracticeTaskRepository
    private let lessonRepository: LessonRepository

    private let syncStudentPracticeTasksUseCase:
        SyncStudentPracticeTasksUseCase
    
    private let updatePracticeTaskCompletionUseCase:
        UpdatePracticeTaskCompletionUseCase
    
    // creates the view model with access to practice task and lesson data
    init(
        practiceTaskRepository: PracticeTaskRepository,
        lessonRepository: LessonRepository,
        userRepository: UserRepository
    ) {

        self.practiceTaskRepository =
            practiceTaskRepository

        self.lessonRepository =
            lessonRepository
        
        self.syncStudentPracticeTasksUseCase =
            SyncStudentPracticeTasksUseCase(
                cloudPracticeTaskRepository:
                    SupabasePracticeTaskRepository(),
                cloudUserRepository:
                    SupabaseUserRepository(),
                localPracticeTaskRepository:
                    practiceTaskRepository,
                localUserRepository:
                    userRepository
            )
        
        self.updatePracticeTaskCompletionUseCase =
            UpdatePracticeTaskCompletionUseCase(
                practiceTaskRepository:
                    SupabasePracticeTaskRepository()
            )
    }

    // synchronises cloud practice tasks before loading local data
    func syncTasks(
        studentID: UUID
    ) async {

        do {
            try await syncStudentPracticeTasksUseCase.execute(
                localStudentID: studentID
            )

            loadTasks(
                for: studentID
            )

        } catch {
            print(
                "Failed to sync student practice tasks: \(error)"
            )

            loadTasks(
                for: studentID
            )
        }
    }
    
    // loads the student's practice tasks and lessons
    func loadTasks(
        for studentID: UUID
    ) {

        practiceTasks =
            practiceTaskRepository
                .getTasks(
                    forStudentID: studentID
                )

        lessons =
            lessonRepository
                .getLessons(
                    forStudentID: studentID
                )
    }

    // toggles a task's completion status locally and updates Supabase
    func toggleTaskCompletion(
        _ task: PracticeTask
    ) {

        task.isCompleted.toggle()

        practiceTaskRepository.updateTask(
            task
        )

        let newCompletionStatus =
            task.isCompleted

        Task {
            do {
                try await updatePracticeTaskCompletionUseCase.execute(
                    taskID: task.id,
                    isCompleted: newCompletionStatus
                )
            } catch {
                print(
                    "Failed to update practice task completion: \(error)"
                )
            }
        }
    }

    // calculates the number of completed practice tasks
    var completedTaskCount: Int {

        practiceTasks
            .filter {
                $0.isCompleted
            }
            .count
    }

    // calculates the student's practice progress as a value between 0 and 1
    var progress: Double {

        guard !practiceTasks.isEmpty else {
            return 0
        }

        return Double(
            completedTaskCount
        )
        /
        Double(
            practiceTasks.count
        )
    }

    // finds the lesson linked to a specific practice task
    func lessonForTask(
        _ task: PracticeTask
    ) -> Lesson? {

        lessons.first {
            $0.id == task.lessonID
        }
    }
}
