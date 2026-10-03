//
//  SupabaseUserRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 1/10/2026.
//

import Foundation
import Supabase

// response returned by the create-student Edge Function
struct CreateStudentResponse: Decodable {
    let id: UUID
    let name: String
    let email: String
    let role: String
    let mustChangePassword: Bool
    let temporaryPassword: String
}

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
            // uses the shared Supabase client to access the profiles table
            try await SupabaseService.client
                .from("profiles")
                .select(
                    "id, name, email, role, must_change_password"
                )
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
                .select(
                    "id, name, email, role, must_change_password"
                )
                .eq(
                    "id",
                    value: id.uuidString
                )
                .execute()
                .value

        return profiles.first
    }
    
   
    // gets all students that belong to a specific teacher
    func getStudents(
        teacherID: UUID
    ) async throws -> [SupabaseProfile] {

        let students: [SupabaseProfile] =
            try await SupabaseService.client
                .from("profiles")
                .select(
                    "id, name, email, role, must_change_password"
                )
                .eq(
                    "role",
                    value: "student"
                )
                .eq(
                    "teacher_id",
                    value: teacherID.uuidString
                )
                .order(
                    "name",
                    ascending: true
                )
                .execute()
                .value

        return students
    }
    
    

    // creates the student account and returns its temporary password
    func createStudent(
        firstName: String,
        lastName: String,
        email: String
    ) async throws -> CreateStudentResponse {

        struct CreateStudentRequest: Encodable {
            let firstName: String
            let lastName: String
            let email: String
        }

        let request = CreateStudentRequest(
            firstName: firstName,
            lastName: lastName,
            email: email
        )

        let response: CreateStudentResponse =
            try await SupabaseService.client
                .functions
                .invoke(
                    "create-student",
                    options: FunctionInvokeOptions(
                        body: request
                    )
                )

        return response
    }
}
