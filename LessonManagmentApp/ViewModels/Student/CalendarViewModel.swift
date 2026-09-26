//
//  CalendarViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 6/9/2026.
//

import Foundation
import Combine

class CalendarViewModel: ObservableObject {

    @Published var lessons: [Lesson] = []
    @Published var selectedDate: Date = Date()
    
    @Published var practiceTasks: [PracticeTask] = []
    @Published var resources: [Resource] = []

    private let practiceTaskRepository: PracticeTaskRepository
    private let resourceRepository: ResourceRepository

    private let lessonRepository: LessonRepository

    // creates the view model with access to lesson, practice task and resource data
    init(
        lessonRepository: LessonRepository,
        practiceTaskRepository: PracticeTaskRepository,
        resourceRepository: ResourceRepository
    ) {
        self.lessonRepository = lessonRepository
        self.practiceTaskRepository = practiceTaskRepository
        self.resourceRepository = resourceRepository
    }

    // loads the student's lessons, practice tasks and resources
    func loadData(
        studentID: UUID
    ) {

        lessons =
            lessonRepository
                .getLessons(
                    forStudentID: studentID
                )

        practiceTasks =
            practiceTaskRepository
                .getTasks(
                    forStudentID: studentID
                )

        resources =
            resourceRepository
                .getResources(
                    forStudentID: studentID
                )
    }

    // finds lessons that occur on the selected date
    func lessons(for date: Date) -> [Lesson] {

        lessons.filter { lesson in
            Calendar.current.isDate(
                lesson.date,
                inSameDayAs: date
            )
        }
    }
    
    // finds practice tasks linked to a specific lesson
    func practiceTasksForLesson(
        _ lesson: Lesson
    ) -> [PracticeTask] {

        practiceTasks.filter {
            $0.lessonID == lesson.id
        }
    }

    // finds resources linked to a specific lesson
    func resourcesForLesson(
        _ lesson: Lesson
    ) -> [Resource] {

        resources.filter {
            $0.lessonID == lesson.id
        }
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
}
