//
//  TeacherStudentsViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine

final class TeacherStudentsViewModel: ObservableObject {

    @Published var students: [User] = []

    private let userRepository: UserRepository
    
    private let addStudentUseCase: AddStudentUseCase

    // creates the view model with access to stored users
    init(
        userRepository: UserRepository
    ) {
        self.userRepository = userRepository
        
        self.addStudentUseCase =
                AddStudentUseCase(
                    userRepository: userRepository
                )
    }

    // loads all students from the user repository
    func loadStudents() {

        students =
            userRepository.getStudents()
    }

    // creates a student account through the add student use case
    func addStudent(
        firstName: String,
        lastName: String,
        email: String,
        password: String
    ) throws {

        try addStudentUseCase.execute(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        )

        loadStudents()
    }
    
}
