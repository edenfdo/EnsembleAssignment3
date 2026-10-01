//
//  SupabaseUserRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 1/10/2026.
//

import Foundation
import Supabase

final class SupabaseUserRepository {

    // finds a Supabase profile using the user's email
    func getProfile(email: String) async throws -> SupabaseProfile? {

        let normalizedEmail =
            email
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

        let profiles: [SupabaseProfile] =
            try await SupabaseService.client
                .from("profiles")
                .select("id, name, email, role")
                .eq("email", value: normalizedEmail)
                .execute()
                .value

        return profiles.first
    }
}
