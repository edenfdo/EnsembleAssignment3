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
    func getProfile(
        email: String
    ) async throws -> SupabaseProfile? {

        let normalizedEmail =
            email
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        let profiles: [SupabaseProfile] =
            try await SupabaseService.client //we have this/we can do this cause we have the superbase package in xcode
                .from("profiles")
                .select("id, name, email, role")
                .eq(
                    "email",
                    value: normalizedEmail
                )
                .execute()
                .value

        return profiles.first
    }

    // finds a Supabase profile using its cloud ID
    func getProfile(
        id: UUID
    ) async throws -> SupabaseProfile? {

        let profiles: [SupabaseProfile] =
            try await SupabaseService.client
                .from("profiles")
                .select("id, name, email, role")
                .eq(
                    "id",
                    value: id.uuidString
                )
                .execute()
                .value

        return profiles.first
    }
}
