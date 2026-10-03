//
//  QuizQuestion.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 11/9/2026.
//

import Foundation

struct QuizQuestion: Identifiable {
    let id: UUID
    let imageData: Data
    let answers: [String]
    let correctAnswer: String

    init(
        id: UUID,
        imageData: Data,
        answers: [String],
        correctAnswer: String
    ) {
        self.id = id
        self.imageData = imageData
        self.answers = answers
        self.correctAnswer = correctAnswer
    }
}
