//
//  NotificationViewController.swift
//  PracticeTaskNotification
//
//  Created by Eden Fernando on 30/9/2026.
//

import UIKit
import UserNotifications
import UserNotificationsUI


class NotificationViewController:
    UIViewController,
    UNNotificationContentExtension {

    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var lessonLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
    }


    // updates the custom notification with practice task details
    func didReceive(
        _ notification: UNNotification
    ) {

        let userInfo =
            notification.request.content.userInfo

        let taskTitle =
            userInfo["taskTitle"] as? String
            ?? "Practice Task"

        let lessonTitle =
            userInfo["lessonTitle"] as? String
            ?? "Lesson"

        let dueTimestamp =
            userInfo["dueDate"] as? TimeInterval
            ?? 0

        let dueDate =
            Date(
                timeIntervalSince1970:
                    dueTimestamp
            )

        let formattedDueDate =
            dueDate.formatted(
                date: .abbreviated,
                time: .shortened
            )

        taskTitleLabel.text =
            taskTitle

        lessonLabel.text =
            lessonTitle

        dueDateLabel.text =
            "Due \(formattedDueDate)"
    }
}
