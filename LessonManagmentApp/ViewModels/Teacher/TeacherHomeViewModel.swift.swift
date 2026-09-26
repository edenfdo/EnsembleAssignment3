//
//  TeacherHomeViewModel.swift.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 13/9/2026.
//

import Foundation
import Combine

final class TeacherHomeViewModel: ObservableObject {

    @Published var todaysLessons: [Lesson] = []
    @Published var students: [User] = []

    private let lessonRepository: LessonRepository
    private let userRepository: UserRepository

    // creates the view model with access to lesson and user data
    init(
        lessonRepository: LessonRepository,
        userRepository: UserRepository
    ) {
        self.lessonRepository = lessonRepository
        self.userRepository = userRepository
    }

    // loads today's lessons for the teacher and sorts them by time
    func loadTodaysLessons(
        teacherID: UUID
    ) {

        students =
            userRepository.getStudents()

        todaysLessons =
            lessonRepository
                .getLessons(
                    forTeacherID: teacherID
                )
                .filter {
                    Calendar.current.isDateInToday(
                        $0.date
                    )
                }
                .sorted {
                    $0.date < $1.date
                }
    }

    // finds the student assigned to a specific lesson
    func studentForLesson(
        _ lesson: Lesson
    ) -> User? {

        students.first {
            $0.id == lesson.studentID
        }
    }
}
