//
//  UpdatePracticeTaskCompletionUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 2/10/2026.
//

import Foundation

struct UpdatePracticeTaskCompletionUseCase {

    private let practiceTaskRepository:
        SupabasePracticeTaskRepository

    init(
        practiceTaskRepository:
            SupabasePracticeTaskRepository
    ) {
        self.practiceTaskRepository =
            practiceTaskRepository
    }

    // updates the practice task completion status in Supabase
    func execute(
        taskID: UUID,
        isCompleted: Bool
    ) async throws {

        try await practiceTaskRepository
            .updateCompletion(
                id: taskID,
                isCompleted: isCompleted
            )
    }
}
