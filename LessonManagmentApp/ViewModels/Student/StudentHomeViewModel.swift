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
    @Published var practiceTasks: [PracticeTask] = []

    private let lessonRepository: LessonRepository
    private let practiceTaskRepository: PracticeTaskRepository

    // creates the view model with access to lesson and practice task data
    init(
        lessonRepository: LessonRepository,
        practiceTaskRepository: PracticeTaskRepository
    ) {
        self.lessonRepository = lessonRepository
        self.practiceTaskRepository = practiceTaskRepository
    }

    // loads the student's next upcoming lesson and practice tasks
    func loadHomeData(for studentID: UUID) {

        let studentLessons =
            lessonRepository.getLessons(forStudentID: studentID)

        // filters out past lessons and selects the closest upcoming lesson
        upcomingLesson = studentLessons
            .filter { $0.date >= Date() }
            .sorted { $0.date < $1.date }
            .first

        practiceTasks =
            practiceTaskRepository.getTasks(forStudentID: studentID)
    }
    
    // toggles a task's completion status and saves the change
    func toggleTaskCompletion(_ task: PracticeTask) {

        task.isCompleted.toggle()

        practiceTaskRepository.updateTask(task)
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
