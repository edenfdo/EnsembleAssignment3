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
}
