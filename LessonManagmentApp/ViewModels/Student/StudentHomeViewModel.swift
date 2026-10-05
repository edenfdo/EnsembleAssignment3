//
//  HomeViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 6/9/2026.
//

import Foundation
import Combine

class StudentHomeViewModel: ObservableObject {

    @Published var upcomingLesson: Lesson?
    @Published var upcomingLessonDate: Date?
    @Published var practiceTasks: [PracticeTask] = []

    private let lessonRepository: LessonRepository
    private let practiceTaskRepository: PracticeTaskRepository
    
    private let updatePracticeTaskCompletionUseCase:
        UpdatePracticeTaskCompletionUseCase

    // creates the view model with access to lesson and practice task data
    init(
        lessonRepository: LessonRepository,
        practiceTaskRepository: PracticeTaskRepository
    ) {
        self.lessonRepository = lessonRepository
        self.practiceTaskRepository = practiceTaskRepository
        
        self.updatePracticeTaskCompletionUseCase =
            UpdatePracticeTaskCompletionUseCase(
                practiceTaskRepository:
                    SupabasePracticeTaskRepository()
            )
    }

    // loads the student's next upcoming lesson and practice tasks
    func loadHomeData(for studentID: UUID) {

        let studentLessons =
            lessonRepository.getLessons(forStudentID: studentID)

        // finds the next actual occurrence across
        // one-off and recurring lessons
        let now = Date()

        let upcomingOccurrences =
            studentLessons.compactMap { lesson
                -> (lesson: Lesson, date: Date)? in

                guard let nextDate =
                    LessonRecurrenceService
                        .nextOccurrenceDate(
                            for: lesson,
                            onOrAfter: now
                        )
                else {
                    return nil
                }

                return (
                    lesson: lesson,
                    date: nextDate
                )
            }
            .sorted {
                $0.date < $1.date
            }

        upcomingLesson =
            upcomingOccurrences.first?.lesson

        upcomingLessonDate =
            upcomingOccurrences.first?.date

        practiceTasks =
            practiceTaskRepository.getTasks(forStudentID: studentID)
    }
    
    // toggles a task's completion status locally and in Supabase
    func toggleTaskCompletion(
        _ task: PracticeTask
    ) async {

        let previousCompletion =
            task.isCompleted

        task.isCompleted.toggle()

        practiceTaskRepository.updateTask(
            task
        )

        do {

            try await updatePracticeTaskCompletionUseCase.execute(
                taskID: task.id,
                isCompleted: task.isCompleted
            )

        } catch {

            // restores the previous state if the cloud update fails
            task.isCompleted =
                previousCompletion

            practiceTaskRepository.updateTask(
                task
            )

            print(
                "Failed to update practice task completion: \(error)"
            )
        }
    }
    // calculates the student's practice progress as a value between 0 and 1
    var progress: Double {

        guard !practiceTasks.isEmpty else {
            return 0
        }

        let completedTasks =
            practiceTasks.filter { $0.isCompleted }.count

        return Double(completedTasks) /
               Double(practiceTasks.count)
    }
}
