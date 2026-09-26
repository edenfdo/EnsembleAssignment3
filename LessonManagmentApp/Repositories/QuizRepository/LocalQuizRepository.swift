//
//  LocalQuizRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation

final class LocalQuizRepository: QuizRepository {
    
    // returns the locally stored hard-coded quizzes and their questions
    func fetchQuizzes() -> [Quiz] {

        // creates the questions for the treble clef quiz
        let trebleQuestions: [QuizQuestion] = [

            QuizQuestion(
                id: UUID(),
                imageName: "treble-note-c",
                answers: ["C", "D", "E", "F"],
                correctAnswer: "C"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "treble-note-d",
                answers: ["C", "D", "E", "F"],
                correctAnswer: "D"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "treble-note-e",
                answers: ["D", "E", "F", "G"],
                correctAnswer: "E"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "treble-note-f",
                answers: ["E", "F", "G", "A"],
                correctAnswer: "F"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "treble-note-g",
                answers: ["F", "G", "A", "B"],
                correctAnswer: "G"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "treble-note-a",
                answers: ["G", "A", "B", "C"],
                correctAnswer: "A"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "treble-note-b",
                answers: ["A", "B", "C", "D"],
                correctAnswer: "B"
            )
        ]

        // creates the questions for the bass clef quiz
        let bassQuestions: [QuizQuestion] = [

            QuizQuestion(
                id: UUID(),
                imageName: "bass-note-c",
                answers: ["C", "D", "E", "F"],
                correctAnswer: "C"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "bass-note-d",
                answers: ["C", "D", "E", "F"],
                correctAnswer: "D"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "bass-note-e",
                answers: ["D", "E", "F", "G"],
                correctAnswer: "E"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "bass-note-f",
                answers: ["E", "F", "G", "A"],
                correctAnswer: "F"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "bass-note-g",
                answers: ["F", "G", "A", "B"],
                correctAnswer: "G"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "bass-note-a",
                answers: ["G", "A", "B", "C"],
                correctAnswer: "A"
            ),

            QuizQuestion(
                id: UUID(),
                imageName: "bass-note-b",
                answers: ["A", "B", "C", "D"],
                correctAnswer: "B"
            )
        ]

        // creates and returns the available quizzes using the question sets above
        return [

            Quiz(
                id: UUID(),
                title: "Treble Clef Note Reading",
                description: "Practise identifying notes written in the treble clef.",
                estimatedTime: "5 min",
                questions: trebleQuestions
            ),

            Quiz(
                id: UUID(),
                title: "Bass Clef Note Reading",
                description: "Practise identifying notes written in the bass clef.",
                estimatedTime: "5 min",
                questions: bassQuestions
            )
        ]
    }
}

