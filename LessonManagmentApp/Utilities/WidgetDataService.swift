//
//  WidgetDataService.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/9/2026.
//

import Foundation
import WidgetKit

enum WidgetDataService {

    private static let appGroup =
        "group.com.edenfdo.LessonManagmentApp"

    private static let dataKey =
        "lessonWidgetData"

    static func save(
        role: String,
        lessons: [WidgetLessonData]
    ) {

        let snapshot =
            WidgetSnapshot(
                role: role,
                lessons: lessons
            )

        guard let data =
            try? JSONEncoder()
                .encode(snapshot)
        else {
            return
        }

        UserDefaults(
            suiteName: appGroup
        )?.set(
            data,
            forKey: dataKey
        )

        WidgetCenter.shared
            .reloadTimelines(
                ofKind: "LessonWidget"
            )
    }
}
