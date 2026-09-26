//
//  Lesson.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/8/2026.
//

import Foundation
import SwiftData

@Model
final class Lesson: Identifiable {

    @Attribute(.unique)
    var id: UUID

    var title: String
    var date: Date
    var durationMinutes: Int

    var studentID: UUID
    var teacherID: UUID

    var notes: String
    var location: String
    
    // creates a lesson with all information required for scheduling and linking it to a student and teacher
    init(
            id: UUID,
            title: String,
            date: Date,
            durationMinutes: Int,
            studentID: UUID,
            teacherID: UUID,
            notes: String,
            location: String
        ) {

            self.id = id
            self.title = title
            self.date = date
            self.durationMinutes = durationMinutes
            self.studentID = studentID
            self.teacherID = teacherID
            self.notes = notes
            self.location = location
        }
}
