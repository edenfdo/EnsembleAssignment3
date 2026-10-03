//
//  SyncTeacherResourcesUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 3/10/2026.
//

import Foundation

struct SyncTeacherResourcesUseCase {

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


    // synchronises the teacher's cloud resources
    // with local SwiftData
    func execute(
        localTeacherID: UUID
    ) async throws {

        let cloudResources =
            try await cloudResourceRepository
                .getResources()

        let localUsers =
            localUserRepository
                .getAllUsers()

        let previousCloudIDs =
            ResourceSyncStateService
                .getSyncedResourceIDs(
                    teacherID: localTeacherID
                )

        let currentCloudIDs =
            Set(
                cloudResources.map {
                    $0.id
                }
            )


        // adds new resources and updates existing resources
        for cloudResource in cloudResources {

            // gets the student attached to the cloud resource
            guard let cloudStudent =
                try await cloudUserRepository
                    .getProfile(
                        id: cloudResource.studentID
                    )
            else {
                continue
            }

            // finds the matching local student
            guard let localStudent =
                localUsers.first(where: {
                    $0.normalizedEmail
                    ==
                    cloudStudent.email
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .lowercased()
                })
            else {
                continue
            }


            // downloads the actual PDF or image
            // from Supabase Storage
            let fileData =
                try await cloudResourceRepository
                    .downloadFile(
                        storagePath:
                            cloudResource.storagePath
                    )


            let localResources =
                localResourceRepository
                    .getAllResources()


            if let existingResource =
                localResources.first(where: {
                    $0.id == cloudResource.id
                }) {

                // removes the old local file
                // if its name has changed
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

                // saves the latest file locally
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
                    localStudent.id

                existingResource.teacherID =
                    localTeacherID

                existingResource.lessonID =
                    cloudResource.lessonID

                existingResource.teacherName =
                    localUsers.first(where: {
                        $0.id == localTeacherID
                    })?.name
                    ?? ""

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

                // saves the downloaded file locally
                try ResourceFileStorage
                    .saveData(
                        fileData,
                        resourceID:
                            cloudResource.id,
                        fileName:
                            cloudResource.fileName
                    )

                let teacherName =
                    localUsers.first(where: {
                        $0.id == localTeacherID
                    })?.name
                    ?? ""

                let localResource =
                    Resource(
                        id: cloudResource.id,
                        title: cloudResource.title,
                        teacherID:
                            localTeacherID,
                        studentID:
                            localStudent.id,
                        lessonID:
                            cloudResource.lessonID,
                        teacherName:
                            teacherName,
                        datePosted:
                            cloudResource.createdAt,
                        fileName:
                            cloudResource.fileName,
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


        // finds resources that have since
        // been deleted from Supabase
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


        // remembers the current cloud state
        ResourceSyncStateService
            .saveSyncedResourceIDs(
                currentCloudIDs,
                teacherID: localTeacherID
            )
    }
}
