//
//  UpdateStudentProfileUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 3/10/2026.
//

import Foundation

final class UpdateStudentProfileUseCase {

    private let localUserRepository: UserRepository
    private let cloudUserRepository: SupabaseUserRepository

    init(
        localUserRepository: UserRepository,
        cloudUserRepository: SupabaseUserRepository
    ) {
        self.localUserRepository = localUserRepository
        self.cloudUserRepository = cloudUserRepository
    }

    func execute(
        user: User,
        name: String
    ) async throws {

        let cleanedName =
            name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanedName.isEmpty else {
            throw UpdateStudentProfileError.nameRequired
        }

        // update the student's profile in Supabase
        try await cloudUserRepository
            .updateStudentProfile(
                name: cleanedName
            )

        // update the local SwiftData user
        user.name = cleanedName

        localUserRepository.updateUser(user)
    }
}

enum UpdateStudentProfileError: Error {
    case nameRequired
}
