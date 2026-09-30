//
//  NotificationService.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/9/2026.
//

import Foundation
import UserNotifications


enum NotificationService {

    // requests permission to send notifications
    static func requestPermission() {

        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [
                    .alert,
                    .sound,
                    .badge
                ]
            ) { granted, error in

                if let error {
                    print(
                        "Notification permission error: \(error)"
                    )
                } else {
                    print(
                        "Notification permission granted: \(granted)"
                    )
                }
            }
    }


    // schedules a reminder for an upcoming practice task due date
    static func schedulePracticeTaskDue(
        title: String,
        description: String,
        dueDate: Date,
        lessonTitle: String
    ) {

        let content =
            UNMutableNotificationContent()

        content.title =
            "Practice Due Soon"

        content.body =
            "\(title) is due soon."

        content.sound =
            .default

        content.categoryIdentifier =
            "PRACTICE_TASK_DUE"

        content.userInfo = [
            "taskTitle": title,
            "taskDescription": description,
            "lessonTitle": lessonTitle,
            "dueDate": dueDate.timeIntervalSince1970
        ]

        // sends the reminder one hour before the task is due
        let reminderDate =
            dueDate.addingTimeInterval(
                -60 * 60
            )

        guard reminderDate > Date() else {
            return
        }

        let dateComponents =
            Calendar.current.dateComponents(
                [
                    .year,
                    .month,
                    .day,
                    .hour,
                    .minute
                ],
                from: reminderDate
            )

        let trigger =
            UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )

        let request =
            UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

        UNUserNotificationCenter.current()
            .add(request) { error in

                if let error {
                    print(
                        "Failed to schedule practice notification: \(error)"
                    )
                }
            }
    }
}
