//
//  ResourceRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation

protocol ResourceRepository {

    func getAllResources() -> [Resource]

    func getResources(
        forStudentID studentID: UUID
    ) -> [Resource]

    func getResources(
        forTeacherID teacherID: UUID
    ) -> [Resource]

    func addResource(
        _ resource: Resource
    )
    
    func updateResource(
        _ resource: Resource
    )
    
    func deleteResource(_ resource: Resource)
}
