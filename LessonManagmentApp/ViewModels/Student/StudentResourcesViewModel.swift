//
//  StudentResourcesViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine

final class StudentResourcesViewModel: ObservableObject {

    @Published var resources: [Resource] = []
    @Published var lessons: [Lesson] = []

    private let resourceRepository: ResourceRepository
    private let lessonRepository: LessonRepository
    
    private let syncStudentResourcesUseCase:
        SyncStudentResourcesUseCase

    // creates the view model with access to resource and lesson data
    init(
        resourceRepository: ResourceRepository,
        lessonRepository: LessonRepository,
        userRepository: UserRepository
    ) {

        self.resourceRepository = resourceRepository
        self.lessonRepository = lessonRepository
        
        self.syncStudentResourcesUseCase =
            SyncStudentResourcesUseCase(
                cloudResourceRepository:
                    SupabaseResourceRepository(),
                cloudUserRepository:
                    SupabaseUserRepository(),
                localResourceRepository:
                    resourceRepository,
                localUserRepository:
                    userRepository
            )
    }

    // loads the student's resources and lessons
    func loadResources(
        studentID: UUID
    ) {

        resources =
            resourceRepository
                .getResources(
                    forStudentID: studentID
                )

        lessons =
            lessonRepository
                .getLessons(
                    forStudentID: studentID
                )
    }
    
    // syncs cloud resources before loading the student's local resources
    func syncResources(
        studentID: UUID
    ) async {

        do {

            try await syncStudentResourcesUseCase.execute(
                localStudentID: studentID
            )

            loadResources(
                studentID: studentID
            )

        } catch {

            print(
                "Failed to sync student resources: \(error)"
            )

            // still loads existing local data if cloud sync fails
            loadResources(
                studentID: studentID
            )
        }
    }
}
