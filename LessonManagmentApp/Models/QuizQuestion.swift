//
//  QuizQuestion.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 11/9/2026.
//

import Foundation

struct QuizQuestion: Identifiable {

    let id: UUID

    let imageName: String
    let answers: [String]
    let correctAnswer: String
}
