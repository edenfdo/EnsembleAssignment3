//
//  LessonRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/8/2026.
//

import Foundation

protocol LessonRepository {

    func getAllLessons() -> [Lesson]

    func getLessons(forStudentID studentID: UUID) -> [Lesson]

    func getLessons(forTeacherID teacherID: UUID) -> [Lesson]

    func addLesson(_ lesson: Lesson)
    
    func updateLesson(
        _ lesson: Lesson
    )
    
    func deleteLesson(
        _ lesson: Lesson
    )
}
