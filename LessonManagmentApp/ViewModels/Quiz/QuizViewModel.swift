//
//  QuizViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine

final class QuizViewModel: ObservableObject {

    @Published var quizzes: [Quiz] = []

    private let quizRepository: QuizRepository

    // creates the view model with access to the quiz repository
    init(
        quizRepository: QuizRepository
    ) {
        self.quizRepository = quizRepository
    }

    // loads the available quizzes from the repository
    func loadQuizzes() {
        quizzes = quizRepository.fetchQuizzes()
    }

    // finds the treble clef quiz from the loaded quizzes
    var trebleQuiz: Quiz? {
        quizzes.first {
            $0.title == "Treble Clef Note Reading"
        }
    }
    
    // finds the bass clef quiz from the loaded quizzes
    var bassQuiz: Quiz? {
        quizzes.first {
            $0.title == "Bass Clef Note Reading"
        }
    }
}
