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
}
