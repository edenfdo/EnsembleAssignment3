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

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var lessonLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!


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

        let taskDescription =
            userInfo["taskDescription"] as? String
            ?? ""

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


        headingLabel.text =
            "Practice Due Soon"

        taskTitleLabel.text =
            taskTitle

        lessonLabel.text =
            lessonTitle

        let formattedDueDate =
            dueDate.formatted(
                date: .abbreviated,
                time: .shortened
            )

        if taskDescription.isEmpty {

            detailsLabel.text =
                "Due \(formattedDueDate)"

        } else {

            detailsLabel.text =
                "Due \(formattedDueDate)\n\(taskDescription)"
        }
    }
}
