//
//  TeacherResourcesViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine

final class TeacherResourcesViewModel: ObservableObject {

    @Published var resources: [Resource] = []
    @Published var students: [User] = []
    
    @Published var lessons: [Lesson] = []
    
    private let lessonRepository: LessonRepository

    private let resourceRepository: ResourceRepository
    private let userRepository: UserRepository

    // creates the view model with access to resource, user and lesson data
    init(
        resourceRepository: ResourceRepository,
        userRepository: UserRepository,
        lessonRepository: LessonRepository
    ) {
        self.resourceRepository = resourceRepository
        self.userRepository = userRepository
        self.lessonRepository = lessonRepository
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

    // saves a selected file and creates a resource linked to the chosen student and lesson
    func addResource(
        title: String,
        selectedFileURL: URL,
        studentID: UUID,
        lessonID: UUID?,
        teacher: User
    ) throws {

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

        let resource = Resource(
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

        resourceRepository.addResource(
            resource
        )

        loadData(
            teacherID: teacher.id
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
    
    // updates a resource and replaces its stored file if a new file is selected
    func updateResource(
        resource: Resource,
        title: String,
        selectedFileURL: URL?,
        teacherID: UUID
    ) throws {

        resource.title = title

        // replaces the existing file only when a new file is selected
        if let selectedFileURL {

            let accessing =
                selectedFileURL
                    .startAccessingSecurityScopedResource()

            defer {

                if accessing {
                    selectedFileURL
                        .stopAccessingSecurityScopedResource()
                }
            }

            let savedFileName =
                try ResourceFileStorage
                    .replaceFile(
                        from: selectedFileURL,
                        resourceID: resource.id,
                        oldFileName: resource.fileName
                    )

            resource.fileName =
                savedFileName

            resource.fileType =
                determineFileType(
                    url: selectedFileURL
                )
        }

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

