//
//  TeacherResourcesViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine
import UniformTypeIdentifiers

final class TeacherResourcesViewModel: ObservableObject {

    @Published var resources: [Resource] = []
    @Published var students: [User] = []
    
    @Published var lessons: [Lesson] = []
    
    private let lessonRepository: LessonRepository

    private let resourceRepository: ResourceRepository
    private let userRepository: UserRepository
    
    private let saveResourceToCloudUseCase:
        SaveResourceToCloudUseCase

    // creates the view model with access to resource, user and lesson data
    init(
        resourceRepository: ResourceRepository,
        userRepository: UserRepository,
        lessonRepository: LessonRepository
    ) {
        self.resourceRepository = resourceRepository
        self.userRepository = userRepository
        self.lessonRepository = lessonRepository
        
        self.saveResourceToCloudUseCase =
            SaveResourceToCloudUseCase(
                resourceRepository:
                    SupabaseResourceRepository(),
                userRepository:
                    SupabaseUserRepository(),
                lessonRepository:
                    SupabaseLessonRepository()
            )
    }

    // loads the teacher's students, lessons and resources
    func loadData(
        teacherID: UUID
    ) {

        students =
            userRepository.getStudents()

        lessons =
            lessonRepository
                .getLessons(
                    forTeacherID: teacherID
                )
                .sorted {
                    $0.date < $1.date
                }

        resources =
            resourceRepository
                .getResources(
                    forTeacherID: teacherID
                )
                .sorted {
                    $0.datePosted > $1.datePosted
                }
    }

    // saves a selected file locally and uploads the resource to Supabase
    func addResource(
        title: String,
        selectedFileURL: URL,
        studentID: UUID,
        lessonID: UUID?,
        teacher: User
    ) async throws {

        guard let student =
            students.first(where: {
                $0.id == studentID
            })
        else {
            return
        }

        let resourceID = UUID()

        // gains temporary access to the selected file
        let accessing =
            selectedFileURL
                .startAccessingSecurityScopedResource()

        // stops file access when this function finishes
        defer {
            if accessing {
                selectedFileURL
                    .stopAccessingSecurityScopedResource()
            }
        }

        // reads the file while security-scoped access is available
        let fileData =
            try Data(
                contentsOf: selectedFileURL
            )

        // copies the selected file into the app's local storage
        let savedFileName =
            try ResourceFileStorage
                .saveFile(
                    from: selectedFileURL,
                    resourceID: resourceID
                )

        let fileType =
            determineFileType(
                url: selectedFileURL
            )

        let resource =
            Resource(
                id: resourceID,
                title: title,
                teacherID: teacher.id,
                studentID: studentID,
                lessonID: lessonID,
                teacherName: teacher.name,
                datePosted: Date(),
                fileName: savedFileName,
                fileType: fileType
            )

        // saves the resource locally
        resourceRepository.addResource(
            resource
        )

        loadData(
            teacherID: teacher.id
        )

        // uploads the file and resource metadata to Supabase
        try await saveResourceToCloudUseCase.execute(
            resource: resource,
            studentEmail: student.email,
            fileData: fileData
        )
    }

    // finds the student assigned to a specific resource
    func studentForResource(
        _ resource: Resource
    ) -> User? {

        students.first {
            $0.id == resource.studentID
        }
    }

    // determines whether the selected resource is a PDF or image
    func determineFileType(
        url: URL
    ) -> ResourceFileType {

        if url.pathExtension
            .lowercased() == "pdf" {

            return .pdf
        }

        return .image
    }
    
    // finds lessons assigned to a specific student
    func lessonsForStudent(
        studentID: UUID
    ) -> [Lesson] {

        lessons.filter {
            $0.studentID == studentID
        }
    }
    
    // updates a resource locally and in Supabase
    func updateResource(
        resource: Resource,
        title: String,
        selectedFileURL: URL?,
        teacherID: UUID
    ) async throws {

        // updates only the title when no replacement file was selected
        guard let selectedFileURL else {

            try await saveResourceToCloudUseCase.updateTitle(
                resourceID: resource.id,
                title: title
            )

            resource.title = title

            resourceRepository.updateResource(
                resource
            )

            loadData(
                teacherID: teacherID
            )

            return
        }

        // gains temporary access to the replacement file
        let accessing =
            selectedFileURL
                .startAccessingSecurityScopedResource()

        let fileData: Data

        do {

            fileData =
                try Data(
                    contentsOf: selectedFileURL
                )

        } catch {

            if accessing {
                selectedFileURL
                    .stopAccessingSecurityScopedResource()
            }

            throw error
        }

        if accessing {
            selectedFileURL
                .stopAccessingSecurityScopedResource()
        }

        let newFileName =
            selectedFileURL.lastPathComponent

        let newFileType =
            determineFileType(
                url: selectedFileURL
            )

        let fileExtension =
            selectedFileURL.pathExtension

        let contentType =
            UTType(
                filenameExtension: fileExtension
            )?
            .preferredMIMEType
            ?? "application/octet-stream"

        // replaces the cloud file before changing the local resource
        try await saveResourceToCloudUseCase.replaceFile(
            resourceID: resource.id,
            title: title,
            fileName: newFileName,
            fileType: newFileType,
            fileData: fileData,
            contentType: contentType
        )

        let oldFileName =
            resource.fileName

        // removes Daniel's previous local file
        try ResourceFileStorage.deleteFile(
            resourceID: resource.id,
            fileName: oldFileName
        )

        // saves the replacement file locally
        try ResourceFileStorage.saveData(
            fileData,
            resourceID: resource.id,
            fileName: newFileName
        )

        resource.title = title
        resource.fileName = newFileName
        resource.fileType = newFileType

        resourceRepository.updateResource(
            resource
        )

        loadData(
            teacherID: teacherID
        )
    }
    
    // deletes the stored file and its resource record
    func deleteResource(
        _ resource: Resource,
        teacherID: UUID
    ) {

        do {

            try ResourceFileStorage.deleteFile(
                resourceID: resource.id,
                fileName: resource.fileName
            )

            resourceRepository.deleteResource(
                resource
            )

            loadData(
                teacherID: teacherID
            )

        } catch {

            print(
                "Failed to delete resource file: \(error)"
            )
        }
    }
}

