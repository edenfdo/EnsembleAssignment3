//
//  Quiz.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 11/9/2026.
//

import Foundation

struct Quiz: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let estimatedTime: String
    let questions: [QuizQuestion]
}
