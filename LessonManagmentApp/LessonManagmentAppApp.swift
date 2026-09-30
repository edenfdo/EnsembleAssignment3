//
//  LessonManagmentAppApp.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/8/2026.
//

import SwiftUI
import SwiftData

@main
struct LessonManagmentAppApp: App {

    // requests notification permission when the app launches
    init() {
        NotificationService
           .requestPermission()
   }
    
    var body: some Scene {

        WindowGroup {
            RootView()
        }
        .modelContainer(
            for: [
                PracticeTask.self,
                User.self,
                Lesson.self,
                Resource.self
            ]
        )
    }
}
