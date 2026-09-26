//
//  UserRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation

protocol UserRepository {

    func getAllUsers() -> [User]

    func getStudents() -> [User]

    func getTeachers() -> [User]

    func addUser(_ user: User)
    
    func updateUser(_ user: User)
}
