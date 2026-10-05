//
//  LessonDetailView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 6/9/2026.
//


import SwiftUI
import Lottie

struct LessonDetailView: View {

    let lesson: Lesson
    var occurrenceDate: Date? = nil

    let practiceTasks: [PracticeTask]
    let resources: [Resource]
    
    let onToggleTask: (PracticeTask) -> Void
    let onOpenResource: (Resource) -> Void
    
    @State private var animatingTaskID: UUID?

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 20
            ) {

                Text(lesson.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text(
                        displayedLessonDate,
                        style: .date
                    )

                    Text(
                        "\(displayedLessonDate.formatted(date: .omitted, time: .shortened)) – \(lessonEndTime.formatted(date: .omitted, time: .shortened))"
                    )

                    Text(
                        lesson.location
                    )
                    
                   
                }
                .foregroundStyle(.secondary)

                Divider()


                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text("Lesson Notes")
                        .font(.headline)

                    if lesson.notes.isEmpty {

                        Text(
                            "No lesson notes."
                        )
                        .foregroundStyle(
                            .secondary
                        )

                    } else {

                        Text(
                            lesson.notes
                        )
                    }
                }

                Divider()


                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {

                    Text("Practice Tasks")
                        .font(.headline)

                    if practiceTasks.isEmpty {

                        Text(
                            "No practice tasks have been added for this lesson."
                        )
                        .foregroundStyle(
                            .secondary
                        )

                    } else {

                        ForEach(
                            practiceTasks
                        ) { task in

                            // toggles the task and plays the completion animation when it is newly completed
                            Button {

                                let wasCompleted = task.isCompleted

                                onToggleTask(
                                    task
                                )

                                if !wasCompleted {

                                    animatingTaskID = task.id

                                    DispatchQueue.main.asyncAfter(
                                        deadline: .now() + 1.5
                                    ) {

                                        animatingTaskID = nil
                                    }
                                }

                            } label: {

                                HStack(
                                    alignment: .top,
                                    spacing: 12
                                ) {


                                    ZStack {

                                        if animatingTaskID == task.id {

                                            LottieView(
                                                animation: .named("taskComplete")
                                            )
                                            .playing()
                                            .frame(
                                                width: 32,
                                                height: 32
                                            )

                                        } else {

                                            Image(
                                                systemName:
                                                    task.isCompleted
                                                    ? "checkmark.circle.fill"
                                                    : "circle"
                                            )
                                            .font(.title3)
                                            .foregroundStyle(
                                                task.isCompleted
                                                ? Color(
                                                    red: 183 / 255,
                                                    green: 41 / 255,
                                                    blue: 41 / 255
                                                )
                                                : .secondary
                                            )
                                        }
                                    }
                                    .frame(
                                        width: 32,
                                        height: 32
                                    )

                                    VStack(
                                        alignment: .leading,
                                        spacing: 4
                                    ) {

                                        Text(
                                            task.title
                                        )
                                        .fontWeight(.semibold)

                                        Text(
                                            task.taskDescription
                                        )
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                        if let dueDate =
                                            task.dueDate {

                                            Text(
                                                "Due \(dueDate, style: .date)"
                                            )
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(
                                    .gray.opacity(0.08)
                                )
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Divider()


                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {

                    Text("Resources")
                        .font(.headline)

                    if resources.isEmpty {

                        Text(
                            "No resources have been added for this lesson."
                        )
                        .foregroundStyle(
                            .secondary
                        )

                    } else {

                        ForEach(
                            resources
                        ) { resource in

                            Button {

                                onOpenResource(
                                    resource
                                )

                            } label: {

                                HStack(
                                    spacing: 12
                                ) {

                                    Image(
                                        systemName:
                                            resource.fileType == .pdf
                                            ? "doc.fill"
                                            : "photo.fill"
                                    )
                                    .foregroundStyle(.blue)
                                    .frame(width: 24)

                                    VStack(
                                        alignment: .leading,
                                        spacing: 3
                                    ) {

                                        Text(
                                            resource.title
                                        )
                                        .fontWeight(.semibold)

                                        Text(
                                            resource.fileName
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(
                                        systemName: "chevron.right"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                }
                                .padding()
                                .background(
                                    .gray.opacity(0.08)
                                )
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
    
    // calculates the lesson end time using its start time and duration
    private var lessonEndTime: Date {

        displayedLessonDate.addingTimeInterval(
            TimeInterval(
                lesson.durationMinutes * 60
            )
        )
    }
    
    // combines the selected occurrence day
    // with the lesson's original start time
    private var displayedLessonDate: Date {

        guard let occurrenceDate else {
            return lesson.date
        }

        let calendar = Calendar.current

        let timeComponents =
            calendar.dateComponents(
                [.hour, .minute, .second],
                from: lesson.date
            )

        return calendar.date(
            bySettingHour:
                timeComponents.hour ?? 0,
            minute:
                timeComponents.minute ?? 0,
            second:
                timeComponents.second ?? 0,
            of: occurrenceDate
        ) ?? lesson.date
    }
}


#Preview {

    let lessonID = UUID()

    LessonDetailView(
        lesson: Lesson(
            id: lessonID,
            title: "Piano Lesson",
            date: Date(),
            durationMinutes: 60,
            studentID: UUID(),
            teacherID: UUID(),
            notes:
                "Practise C major scale and bars 1–16.",
            location: "Room 3"
        ),
        practiceTasks: [],
        resources: [],
        onToggleTask: { _ in },
        onOpenResource: { _ in }
    )
}
