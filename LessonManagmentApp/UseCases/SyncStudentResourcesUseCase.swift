//
//  SyncStudentResourcesUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 2/10/2026.
//

import Foundation

struct SyncStudentResourcesUseCase {

    private let cloudResourceRepository:
        SupabaseResourceRepository

    private let cloudUserRepository:
        SupabaseUserRepository

    private let localResourceRepository:
        ResourceRepository

    private let localUserRepository:
        UserRepository

    init(
        cloudResourceRepository:
            SupabaseResourceRepository,
        cloudUserRepository:
            SupabaseUserRepository,
        localResourceRepository:
            ResourceRepository,
        localUserRepository:
            UserRepository
    ) {
        self.cloudResourceRepository =
            cloudResourceRepository

        self.cloudUserRepository =
            cloudUserRepository

        self.localResourceRepository =
            localResourceRepository

        self.localUserRepository =
            localUserRepository
    }

    // synchronises the student's cloud resources with local SwiftData
    func execute(
        localStudentID: UUID
    ) async throws {

        let cloudResources =
            try await cloudResourceRepository
                .getResources()
        print(
            "Cloud resources found: \(cloudResources.count)"
        )

        let localUsers =
            localUserRepository
                .getAllUsers()

        let previousCloudIDs =
            ResourceSyncStateService
                .getSyncedResourceIDs(
                    studentID: localStudentID
                )

        let currentCloudIDs =
            Set(
                cloudResources.map {
                    $0.id
                }
            )

        // adds new resources and updates existing cloud resources
        for cloudResource in cloudResources {
            print(
                "Syncing resource: \(cloudResource.title)"
            )
            guard let cloudTeacher =
                try await cloudUserRepository
                    .getProfile(
                        id: cloudResource.teacherID
                    )
            else {
                continue
            }

            guard let localTeacher =
                localUsers.first(where: {
                    $0.normalizedEmail
                    ==
                    cloudTeacher.email
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .lowercased()
                })
            else {
                continue
            }

            // downloads the actual PDF or image from Supabase Storage
            let fileData =
                try await cloudResourceRepository
                    .downloadFile(
                        storagePath:
                            cloudResource.storagePath
                    )
            print(
                "Downloaded resource file: \(fileData.count) bytes"
            )

            let localResources =
                localResourceRepository
                    .getAllResources()

            if let existingResource =
                localResources.first(where: {
                    $0.id == cloudResource.id
                }) {

                // removes the old local file if its name has changed
                if existingResource.fileName
                    != cloudResource.fileName {

                    try ResourceFileStorage
                        .deleteFile(
                            resourceID:
                                existingResource.id,
                            fileName:
                                existingResource.fileName
                        )
                }

                try ResourceFileStorage
                    .saveData(
                        fileData,
                        resourceID:
                            cloudResource.id,
                        fileName:
                            cloudResource.fileName
                    )

                existingResource.title =
                    cloudResource.title

                existingResource.studentID =
                    localStudentID

                existingResource.teacherID =
                    localTeacher.id

                existingResource.lessonID =
                    cloudResource.lessonID

                existingResource.teacherName =
                    localTeacher.name

                existingResource.datePosted =
                    cloudResource.createdAt

                existingResource.fileName =
                    cloudResource.fileName

                existingResource.fileType =
                    cloudResource.fileType == "pdf"
                    ? .pdf
                    : .image

                localResourceRepository
                    .updateResource(
                        existingResource
                    )

            } else {

                try ResourceFileStorage
                    .saveData(
                        fileData,
                        resourceID:
                            cloudResource.id,
                        fileName:
                            cloudResource.fileName
                    )

                let localResource =
                    Resource(
                        id: cloudResource.id,
                        title: cloudResource.title,
                        teacherID: localTeacher.id,
                        studentID: localStudentID,
                        lessonID: cloudResource.lessonID,
                        teacherName: localTeacher.name,
                        datePosted: cloudResource.createdAt,
                        fileName: cloudResource.fileName,
                        fileType:
                            cloudResource.fileType == "pdf"
                            ? .pdf
                            : .image
                    )

                localResourceRepository
                    .addResource(
                        localResource
                    )
            }
        }

        // finds cloud resources that have since been deleted
        let deletedCloudIDs =
            previousCloudIDs.subtracting(
                currentCloudIDs
            )

        for deletedID in deletedCloudIDs {

            if let localResource =
                localResourceRepository
                    .getAllResources()
                    .first(where: {
                        $0.id == deletedID
                    }) {

                try ResourceFileStorage
                    .deleteFile(
                        resourceID:
                            localResource.id,
                        fileName:
                            localResource.fileName
                    )

                localResourceRepository
                    .deleteResource(
                        localResource
                    )
            }
        }

        // remembers the current cloud state for the next sync
        ResourceSyncStateService
            .saveSyncedResourceIDs(
                currentCloudIDs,
                studentID: localStudentID
            )
    }
}
