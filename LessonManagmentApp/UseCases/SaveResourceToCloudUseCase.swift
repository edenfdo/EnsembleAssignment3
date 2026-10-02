//
//  SaveResourceToCloudUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 2/10/2026.
//

import Foundation
import Supabase
import UniformTypeIdentifiers

enum SaveResourceToCloudError: Error {
    case studentProfileNotFound
    case lessonNotFound
}

struct SaveResourceToCloudUseCase {

    private let resourceRepository:
        SupabaseResourceRepository

    private let userRepository:
        SupabaseUserRepository

    private let lessonRepository:
        SupabaseLessonRepository

    init(
        resourceRepository:
            SupabaseResourceRepository,
        userRepository:
            SupabaseUserRepository,
        lessonRepository:
            SupabaseLessonRepository
    ) {
        self.resourceRepository =
            resourceRepository

        self.userRepository =
            userRepository

        self.lessonRepository =
            lessonRepository
    }

    // uploads a resource file and saves its metadata to Supabase
    func execute(
        resource: Resource,
        studentEmail: String,
        fileData: Data
    ) async throws {

        let authenticatedTeacher =
            try await SupabaseService.client.auth.user()

        guard let studentProfile =
            try await userRepository.getProfile(
                email: studentEmail
            )
        else {
            throw SaveResourceToCloudError
                .studentProfileNotFound
        }

        // checks that an optional linked lesson exists in Supabase
        if let lessonID =
            resource.lessonID {

            let cloudLessons =
                try await lessonRepository.getLessons()

            guard cloudLessons.contains(
                where: {
                    $0.id == lessonID
                }
            )
            else {
                throw SaveResourceToCloudError
                    .lessonNotFound
            }
        }

        let storagePath =
            "\(authenticatedTeacher.id.uuidString.lowercased())/" +
            "\(studentProfile.id.uuidString.lowercased())/" +
            "\(resource.id.uuidString.lowercased())/" +
            resource.fileName

        let fileExtension =
            URL(
                fileURLWithPath: resource.fileName
            )
            .pathExtension

        let contentType =
            UTType(
                filenameExtension: fileExtension
            )?
            .preferredMIMEType
            ?? "application/octet-stream"

        // uploads the actual PDF or image
        try await resourceRepository.uploadFile(
            data: fileData,
            storagePath: storagePath,
            contentType: contentType
        )

        let cloudResource =
            SupabaseResource(
                id: resource.id,
                title: resource.title,
                studentID: studentProfile.id,
                teacherID: authenticatedTeacher.id,
                lessonID: resource.lessonID,
                fileName: resource.fileName,
                fileType: resource.fileType.rawValue,
                storagePath: storagePath,
                createdAt: resource.datePosted
            )

        do {

            // saves the resource metadata after the file upload succeeds
            try await resourceRepository.addResource(
                cloudResource
            )

        } catch {

            // removes the uploaded file if the database save fails
            try? await resourceRepository.deleteFile(
                storagePath: storagePath
            )

            throw error
        }
    }
}
