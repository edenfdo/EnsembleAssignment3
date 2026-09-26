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

    // creates the view model with access to practice task and lesson data
    init(
        practiceTaskRepository: PracticeTaskRepository,
        lessonRepository: LessonRepository
    ) {

        self.practiceTaskRepository =
            practiceTaskRepository

        self.lessonRepository =
            lessonRepository
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

    // toggles a task's completion status and saves the change
    func toggleTaskCompletion(
        _ task: PracticeTask
    ) {

        task.isCompleted.toggle()

        practiceTaskRepository.updateTask(
            task
        )
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
