//
//  TeacherPracticeViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine

final class TeacherPracticeViewModel: ObservableObject {

    @Published var tasks: [PracticeTask] = []
    @Published var students: [User] = []
    @Published var lessons: [Lesson] = []

    private let practiceTaskRepository: PracticeTaskRepository
    private let userRepository: UserRepository
    private let lessonRepository: LessonRepository

    // creates the view model with access to practice task, user and lesson data
    init(
        practiceTaskRepository: PracticeTaskRepository,
        userRepository: UserRepository,
        lessonRepository: LessonRepository
    ) {
        self.practiceTaskRepository = practiceTaskRepository
        self.userRepository = userRepository
        self.lessonRepository = lessonRepository
    }

    // loads the teacher's students, lessons and practice tasks
    func loadData(
        teacherID: UUID
    ) {

        students =
            userRepository.getStudents()

        lessons =
            lessonRepository
                .getLessons(
                    forTeacherID: teacherID
                )
                .sorted {
                    $0.date < $1.date
                }

        tasks =
            practiceTaskRepository
                .getAllTasks()
                .filter {
                    $0.teacherID == teacherID
                }
    }

    // creates a practice task and links it to the selected lesson
    func assignTask(
        title: String,
        description: String,
        studentID: UUID,
        teacherID: UUID,
        lessonID: UUID,
        dueDate: Date?
    ) -> Bool {

        guard let lesson = lessons.first(
            where: {
                $0.id == lessonID
            }
        ) else {
            return false
        }

        // ensures the due date occurs after the linked lesson
        if let dueDate = dueDate {

            guard dueDate > lesson.date else {
                return false
            }
        }

        let task = PracticeTask(
            id: UUID(),
            title: title,
            description: description,
            studentID: studentID,
            teacherID: teacherID,
            lessonID: lessonID,
            dueDate: dueDate,
            isCompleted: false
        )

        practiceTaskRepository.addTask(
            task
        )

        loadData(
            teacherID: teacherID
        )

        return true
    }

    // finds the student assigned to a specific practice task
    func studentForTask(
        _ task: PracticeTask
    ) -> User? {

        students.first {
            $0.id == task.studentID
        }
    }

    // finds lessons assigned to a specific student
    func lessonsForStudent(
        studentID: UUID
    ) -> [Lesson] {

        lessons.filter {
            $0.studentID == studentID
        }
    }
}
