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
                    location
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
}
