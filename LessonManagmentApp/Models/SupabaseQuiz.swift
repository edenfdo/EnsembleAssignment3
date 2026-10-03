//
//  SupabaseQuiz.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 3/10/2026.
//

import Foundation

struct SupabaseQuiz: Decodable {
    let id: UUID
    let title: String
    let description: String
    let estimatedTime: String
    let questions: [SupabaseQuizQuestion]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case estimatedTime = "estimated_time"
        case questions = "quiz_questions"
    }
}

struct SupabaseQuizQuestion: Decodable {
    let id: UUID
    let imagePath: String
    let answers: [String]
    let correctAnswer: String
    let questionOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case imagePath = "image_path"
        case answers
        case correctAnswer = "correct_answer"
        case questionOrder = "question_order"
    }
}
