//
//  SupabaseResource.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 2/10/2026.
//

import Foundation

struct SupabaseResource: Codable {
    let id: UUID
    let title: String
    let studentID: UUID
    let teacherID: UUID
    let lessonID: UUID?
    let fileName: String
    let fileType: String
    let storagePath: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case studentID = "student_id"
        case teacherID = "teacher_id"
        case lessonID = "lesson_id"
        case fileName = "file_name"
        case fileType = "file_type"
        case storagePath = "storage_path"
        case createdAt = "created_at"
    }
}
