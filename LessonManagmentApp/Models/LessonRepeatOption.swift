//
//  LessonRepeatOption.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/9/2026.
//

import Foundation

enum LessonRepeatOption:
    String,
    CaseIterable,
    Identifiable {

    case none
    case weekly
    case fortnightly

    var id: String {
        rawValue
    }

    // returns a user-friendly name for each repeat option
    var displayName: String {

        switch self {

        case .none:
            return "Does Not Repeat"

        case .weekly:
            return "Weekly"

        case .fortnightly:
            return "Fortnightly"
        }
    }
}
