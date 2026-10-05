//
//  SupabaseLessonRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 1/10/2026.
//

import Foundation
import Supabase

final class SupabaseLessonRepository {

    // adds a lesson to the Supabase database
    func addLesson(_ lesson: SupabaseLesson) async throws {

        try await SupabaseService.client
            .from("lessons")
            .insert(lesson)
            .execute()
    }

    // retrieves lessons available to the authenticated user
    func getLessons() async throws -> [SupabaseLesson] {

        let lessons: [SupabaseLesson] =
            try await SupabaseService.client
                .from("lessons")
                .select(
                    """
                    id,
                    title,
                    date,
                    duration_minutes,
                    student_id,
                    teacher_id,
                    notes,
                    location,
                    recurrence_type,
                    recurrence_end_date
                    """
                )
                .order(
                    "date",
                    ascending: true
                )
                .execute()
                .value

        return lessons
    }
    
    // updates an existing lesson in the Supabase database
    func updateLesson(
        _ lesson: SupabaseLesson
    ) async throws {

        try await SupabaseService.client
            .from("lessons")
            .update(lesson)
            .eq(
                "id",
                value: lesson.id.uuidString
            )
            .execute()
    }


    // deletes a lesson from the Supabase database
    func deleteLesson(
        id: UUID
    ) async throws {

        try await SupabaseService.client
            .from("lessons")
            .delete()
            .eq(
                "id",
                value: id.uuidString
            )
            .execute()
    }
}
