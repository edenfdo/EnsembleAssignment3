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
    static func requestPermission() async {

        do {

            let granted =
                try await UNUserNotificationCenter.current()
                    .requestAuthorization(
                        options: [
                            .alert,
                            .sound,
                            .badge
                        ]
                    )

            print(
                "Notification permission granted: \(granted)"
            )

        } catch {

            print(
                "Notification permission error: \(error)"
            )
        }
    }


    // creates a stable notification identifier for a practice task
    private static func practiceTaskNotificationID(
        taskID: UUID
    ) -> String {

        "practice-task-\(taskID.uuidString)"
    }


    // schedules a reminder one hour before a practice task is due
    static func schedulePracticeTaskDue(
        taskID: UUID,
        title: String,
        dueDate: Date
    ) {


        let identifier =
            practiceTaskNotificationID(
                taskID: taskID
            )

        let content =
            UNMutableNotificationContent()

        content.title =
            "Practice Due Soon"

        content.body =
            "\(title) is due in one hour."

        content.sound =
            .default
        
        content.categoryIdentifier =
            "PRACTICE_TASK_DUE"

        content.categoryIdentifier =
            "PRACTICE_TASK_DUE"

        content.userInfo = [
            "taskID": taskID.uuidString,
            "taskTitle": title,
            "dueDate": dueDate.timeIntervalSince1970
        ]

        // sends the reminder one hour before the task is due
        let reminderDate =
            dueDate.addingTimeInterval(
                -60 * 60
            )

        // does not schedule a reminder if the reminder time has already passed
        guard reminderDate > Date() else {

            cancelPracticeTaskDue(
                taskID: taskID
            )

            return
        }

//        let dateComponents =
//            Calendar.current.dateComponents(
//                [
//                    .year,
//                    .month,
//                    .day,
//                    .hour,
//                    .minute
//                ],
//                from: reminderDate
//            )
//
//        let trigger =
//            UNCalendarNotificationTrigger(
//                dateMatching: dateComponents,
//                repeats: false
//            )
        
        // TESTING ONLY — sends notification after 10 seconds
        let trigger =
            UNTimeIntervalNotificationTrigger(
                timeInterval: 10,
                repeats: false
            )

        let request =
            UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

        UNUserNotificationCenter.current()
            .add(request) { error in

                if let error {

                    print(
                        "Failed to schedule practice notification: \(error)"
                    )

                } else {

                    print(
                        "Scheduled practice reminder: \(title)"
                    )
                }
            }
    }


    // removes the pending reminder for a practice task
    static func cancelPracticeTaskDue(
        taskID: UUID
    ) {

        let identifier =
            practiceTaskNotificationID(
                taskID: taskID
            )

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [
                    identifier
                ]
            )
    }
}
