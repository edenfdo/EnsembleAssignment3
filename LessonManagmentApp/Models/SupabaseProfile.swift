//
//  SupabaseProfile.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 1/10/2026.
//

import Foundation

struct SupabaseProfile: Codable {
    let id: UUID
    let name: String
    let email: String
    let role: String
    let mustChangePassword: Bool

    enum CodingKeys: String, CodingKey {
            case id
            case name
            case email
            case role
            case mustChangePassword = "must_change_password"
        }
}
