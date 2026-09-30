//
//  WidgetLessonData.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/9/2026.
//

import Foundation

struct WidgetLessonData: Codable, Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let durationMinutes: Int
    let personName: String
    let location: String
}

struct WidgetSnapshot: Codable {
    let role: String
    let lessons: [WidgetLessonData]
}
