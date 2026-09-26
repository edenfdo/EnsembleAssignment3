//
//  PracticeTask.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/8/2026.
//

import Foundation
import SwiftData

@Model
final class PracticeTask: Identifiable {

    @Attribute(.unique)
    var id: UUID

    var title: String
    var taskDescription: String

    var studentID: UUID
    var teacherID: UUID

    // every practice task belongs to a lesson
    var lessonID: UUID

    var dueDate: Date?
    var isCompleted: Bool

    // creates a practice task and links it to a student, teacher and lesson
    init(
        id: UUID,
        title: String,
        description: String,
        studentID: UUID,
        teacherID: UUID,
        lessonID: UUID,
        dueDate: Date?,
        isCompleted: Bool
    ) {
        self.id = id
        self.title = title
        self.taskDescription = description
        self.studentID = studentID
        self.teacherID = teacherID
        self.lessonID = lessonID
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }
}
