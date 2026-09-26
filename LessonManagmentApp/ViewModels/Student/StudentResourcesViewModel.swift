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

    // creates the view model with access to resource and lesson data
    init(
        resourceRepository: ResourceRepository,
        lessonRepository: LessonRepository
    ) {

        self.resourceRepository = resourceRepository
        self.lessonRepository = lessonRepository
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
}
