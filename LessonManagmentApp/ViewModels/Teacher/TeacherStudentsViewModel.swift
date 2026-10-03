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

    private let supabaseUserRepository =
        SupabaseUserRepository()


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


    // validates the student details and creates the student account
    func addStudent(
        firstName: String,
        lastName: String,
        email: String
    ) async throws -> CreateStudentResponse {

        // validates the student's details
        try addStudentUseCase.execute(
            firstName: firstName,
            lastName: lastName,
            email: email
        )

        // creates the account through Supabase
        let student =
            try await supabaseUserRepository.createStudent(
                firstName: firstName,
                lastName: lastName,
                email: email
            )

        return student
    }
}
