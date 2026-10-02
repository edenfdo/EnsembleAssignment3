//
//  SupabaseResourceRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 2/10/2026.
//

import Foundation
import Supabase

final class SupabaseResourceRepository {

    private let bucketName =
        "lesson-resources"

    // adds resource metadata to Supabase
    func addResource(
        _ resource: SupabaseResource
    ) async throws {

        try await SupabaseService.client
            .from("resources")
            .insert(resource)
            .execute()
    }

    // retrieves resources available to the authenticated user
    func getResources() async throws
        -> [SupabaseResource] {

        let resources: [SupabaseResource] =
            try await SupabaseService.client
                .from("resources")
                .select(
                    """
                    id,
                    created_at,
                    title,
                    student_id,
                    teacher_id,
                    lesson_id,
                    file_name,
                    file_type,
                    storage_path
                    """
                )
                .execute()
                .value

        return resources
    }

    // updates resource metadata in Supabase
    func updateResource(
        _ resource: SupabaseResource
    ) async throws {

        try await SupabaseService.client
            .from("resources")
            .update(resource)
            .eq(
                "id",
                value: resource.id.uuidString
            )
            .execute()
    }

    // deletes resource metadata from Supabase
    func deleteResource(
        id: UUID
    ) async throws {

        try await SupabaseService.client
            .from("resources")
            .delete()
            .eq(
                "id",
                value: id.uuidString
            )
            .execute()
    }

    // uploads the resource file to Supabase Storage
    func uploadFile(
        data: Data,
        storagePath: String,
        contentType: String
    ) async throws {

        try await SupabaseService.client.storage
            .from(bucketName)
            .upload(
                storagePath,
                data: data,
                options: FileOptions(
                    contentType: contentType,
                    upsert: false
                )
            )
    }

    // downloads the resource file from Supabase Storage
    func downloadFile(
        storagePath: String
    ) async throws -> Data {

        try await SupabaseService.client.storage
            .from(bucketName)
            .download(
                path: storagePath
            )
    }

    // deletes the resource file from Supabase Storage
    func deleteFile(
        storagePath: String
    ) async throws {

        try await SupabaseService.client.storage
            .from(bucketName)
            .remove(
                paths: [
                    storagePath
                ]
            )
    }
}
