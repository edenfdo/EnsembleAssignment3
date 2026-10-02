//
//  SupabasePracticeTaskRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 2/10/2026.
//

import Foundation
import Supabase

final class SupabasePracticeTaskRepository {

    
    private struct CompletionUpdate: Encodable {

        let isCompleted: Bool

        enum CodingKeys: String, CodingKey {
            case isCompleted = "is_completed"
        }
    }
    
    private struct CompletionResult: Decodable {

        let id: UUID
        let isCompleted: Bool

        enum CodingKeys: String, CodingKey {
            case id
            case isCompleted = "is_completed"
        }
    }
    
    // adds a practice task to the Supabase database
    func addTask(
        _ task: SupabasePracticeTask
    ) async throws {

        try await SupabaseService.client
            .from("practice_tasks")
            .insert(task)
            .execute()
    }

    
    // retrieves practice tasks available to the authenticated user
    func getTasks() async throws -> [SupabasePracticeTask] {

        let tasks: [SupabasePracticeTask] =
            try await SupabaseService.client
                .from("practice_tasks")
                .select(
                    """
                    id,
                    title,
                    task_description,
                    student_id,
                    teacher_id,
                    lesson_id,
                    due_date,
                    is_completed
                    """
                )
                .order(
                    "due_date",
                    ascending: true
                )
                .execute()
                .value

        return tasks
    }

    // updates an existing practice task in the Supabase database
    func updateTask(
        _ task: SupabasePracticeTask
    ) async throws {

        try await SupabaseService.client
            .from("practice_tasks")
            .update(task)
            .eq(
                "id",
                value: task.id.uuidString
            )
            .execute()
    }

    // updates a practice task's completion status
    func updateCompletion(
        id: UUID,
        isCompleted: Bool
    ) async throws {

        let update =
            CompletionUpdate(
                isCompleted: isCompleted
            )

        let results: [CompletionResult] =
            try await SupabaseService.client
                .from("practice_tasks")
                .update(update)
                .eq("id", value: id.uuidString)
                .select("id, is_completed")
                .execute()
                .value

        print("Task ID sent to Supabase: \(id)")
        print("Completion sent to Supabase: \(isCompleted)")
        print("Updated rows returned: \(results.count)")

        if let result = results.first {
            print(
                "Supabase returned is_completed: \(result.isCompleted)"
            )
        }
    }
    
    // deletes a practice task from the Supabase database
    func deleteTask(
        id: UUID
    ) async throws {

        try await SupabaseService.client
            .from("practice_tasks")
            .delete()
            .eq(
                "id",
                value: id.uuidString
            )
            .execute()
    }
}
