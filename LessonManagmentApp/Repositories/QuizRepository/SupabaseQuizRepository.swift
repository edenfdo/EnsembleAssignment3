//
//  SupabaseQuizRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 3/10/2026.
//


import Foundation
import Supabase
import Storage

final class SupabaseQuizRepository: QuizRepository {

    func fetchQuizzes() async throws -> [Quiz] {

        // Fetch quizzes and their questions from the database
        let cloudQuizzes: [SupabaseQuiz] =
            try await SupabaseService.client
                .from("quizzes")
                .select("""
                    id,
                    title,
                    description,
                    estimated_time,
                    quiz_questions (
                        id,
                        image_path,
                        answers,
                        correct_answer,
                        question_order
                    )
                """)
                .execute()
                .value

        var quizzes: [Quiz] = []

        for cloudQuiz in cloudQuizzes {

            var questions: [QuizQuestion] = []

            // Make sure questions appear in the correct order
            let sortedQuestions = cloudQuiz.questions.sorted {
                $0.questionOrder < $1.questionOrder
            }

            for cloudQuestion in sortedQuestions {

                // Download the actual note image from Supabase Storage
                let imageData = try await SupabaseService.client
                    .storage
                    .from("quiz-images")
                    .download(path: cloudQuestion.imagePath)

                let question = QuizQuestion(
                    id: cloudQuestion.id,
                    imageData: imageData,
                    answers: cloudQuestion.answers,
                    correctAnswer: cloudQuestion.correctAnswer
                )

                questions.append(question)
            }

            let quiz = Quiz(
                id: cloudQuiz.id,
                title: cloudQuiz.title,
                description: cloudQuiz.description,
                estimatedTime: cloudQuiz.estimatedTime,
                questions: questions
            )

            quizzes.append(quiz)
        }

        return quizzes
    }
}
