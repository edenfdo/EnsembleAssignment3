//
//  TeacherStudentDetailView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

struct TeacherStudentDetailView: View {

    let student: User
   
    @StateObject var viewModel: TeacherStudentDetailViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {

                    HStack(spacing: 16) {

                        Image(
                            systemName: "person.circle.fill"
                        )
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                        VStack(
                            alignment: .leading,
                            spacing: 5
                        ) {

                            Text(student.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            Text(student.email)
                                .foregroundStyle(.secondary)

                            Text("Music Student")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    Text("Upcoming Lesson")
                        .font(.title2)
                        .fontWeight(.bold)

                    if let lesson = viewModel.upcomingLesson {

                        VStack(
                            alignment: .leading,
                            spacing: 10
                        ) {

                            Text(lesson.title)
                                .font(.headline)

                            HStack {

                                Image(
                                    systemName: "calendar"
                                )

                                Text(
                                    lesson.date,
                                    style: .date
                                )
                            }
                            .foregroundStyle(.secondary)

                            HStack {

                                Image(
                                    systemName: "clock"
                                )

                                Text(
                                    lesson.date,
                                    style: .time
                                )
                            }
                            .foregroundStyle(.secondary)

                            HStack {

                                Image(
                                    systemName: "mappin.and.ellipse"
                                )

                                Text(lesson.location)
                            }
                            .foregroundStyle(.secondary)

                            if !lesson.notes.isEmpty {

                                Text(lesson.notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                        .padding()
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .background(
                            .gray.opacity(0.12)
                        )
                        .cornerRadius(14)

                    } else {

                        Text("No upcoming lesson.")
                            .foregroundStyle(.secondary)
                    }

                    Text("Practice Tasks")
                        .font(.title2)
                        .fontWeight(.bold)

                    if viewModel.practiceTasks.isEmpty {

                        Text("No practice tasks assigned.")
                            .foregroundStyle(.secondary)

                    } else {

                        ForEach(viewModel.practiceTasks, id: \.id) { task in

                            HStack(
                                alignment: .top,
                                spacing: 12
                            ) {

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

                                VStack(
                                    alignment: .leading,
                                    spacing: 5
                                ) {

                                    Text(task.title)
                                        .font(.headline)

                                    Text(task.taskDescription)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Student Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {

            viewModel.loadStudentData(
                studentID: student.id
            )
        }
    }

   
}
