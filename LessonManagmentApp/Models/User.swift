//
//  User.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/8/2026.
//

import Foundation
import SwiftData

@Model
final class User: Identifiable {

    @Attribute(.unique)
    var id: UUID

    var name: String

    var email: String

    @Attribute(.unique)
    var normalizedEmail: String

    var passwordHash: String

    var roleRawValue: String
        
    // converts the stored String value into a UserRole for use throughout the app
    var role: UserRole {
        get {
            UserRole(rawValue: roleRawValue) ?? .student
        }

        set {
            roleRawValue = newValue.rawValue
        }
    }

    // creates a user, securely storing the password as a hash and the role as a String
    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        password: String,
        role: UserRole
    ) {
        self.id = id
        self.name = name

        let cleanedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)

        self.email = cleanedEmail

        self.normalizedEmail = cleanedEmail.lowercased()

        self.passwordHash = PasswordHasher.hash(password)
        self.roleRawValue = role.rawValue
    }
}
