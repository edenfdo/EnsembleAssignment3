//
//  SupabasePracticeTask.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 2/10/2026.
//

import Foundation

struct SupabasePracticeTask: Codable {

    let id: UUID
    let title: String
    let taskDescription: String
    let studentID: UUID
    let teacherID: UUID
    let lessonID: UUID
    let dueDate: Date?
    let isCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case taskDescription = "task_description"
        case studentID = "student_id"
        case teacherID = "teacher_id"
        case lessonID = "lesson_id"
        case dueDate = "due_date"
        case isCompleted = "is_completed"
    }
}
