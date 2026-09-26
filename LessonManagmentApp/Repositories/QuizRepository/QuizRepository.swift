//
//  QuizRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation

protocol QuizRepository {

    func fetchQuizzes() -> [Quiz]
}
