//
//  SupabaseLesson.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 1/10/2026.
//

import Foundation

struct SupabaseLesson: Codable {

    let id: UUID
    let title: String
    let date: Date
    let durationMinutes: Int
    let studentID: UUID
    let teacherID: UUID
    let notes: String
    let location: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case date
        case durationMinutes = "duration_minutes"
        case studentID = "student_id"
        case teacherID = "teacher_id"
        case notes
        case location
    }
}
