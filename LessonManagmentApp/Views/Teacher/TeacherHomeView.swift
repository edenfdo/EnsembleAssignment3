//
//  TeacherHomeView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

struct TeacherHomeView: View {

    let teacher: User

    @Binding var showMenu: Bool
    @Binding var selectedSection: TeacherSection

    @StateObject var viewModel:
        TeacherHomeViewModel

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 24
            ) {


                MenuBarView(
                    showMenu: $showMenu,
                    onLogoTap: {
                        selectedSection = .home
                    }
                )


                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(
                        "Welcome, \(teacher.name)"
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)

                    Text(
                        "Manage your lessons, students and resources."
                    )
                    .foregroundStyle(.secondary)
                }


                Text("Today's Lessons")
                    .font(.title2)
                    .fontWeight(.bold)

                if viewModel.todaysLessons.isEmpty {

                    Text(
                        "No lessons scheduled for today."
                    )
                    .foregroundStyle(.secondary)

                } else {

                    ForEach(
                        viewModel.todaysLessons
                    ) { lesson in

                        VStack(
                            alignment: .leading,
                            spacing: 8
                        ) {

                            HStack {

                                if let student =
                                    viewModel.studentForLesson(
                                        lesson
                                    ) {

                                    Text(student.name)
                                        .font(.headline)

                                } else {

                                    Text("Student")
                                        .font(.headline)
                                }

                                Spacer()

                                Text(
                                    lesson.date,
                                    style: .time
                                )
                                .foregroundStyle(
                                    .secondary
                                )
                            }

                            Text(lesson.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(
                                    .secondary
                                )

                            HStack(
                                spacing: 6
                            ) {

                                Image(
                                    systemName:
                                        "mappin.and.ellipse"
                                )

                                Text(
                                    lesson.location
                                )
                            }
                            .font(.subheadline)
                            .foregroundStyle(
                                .secondary
                            )

                            HStack {

                                Spacer()

                                Button {

                                    selectedSection =
                                        .calendar

                                } label: {

                                    HStack(
                                        spacing: 4
                                    ) {

                                        Text(
                                            "View Calendar"
                                        )

                                        Image(
                                            systemName:
                                                "chevron.right"
                                        )
                                        .font(.caption)
                                    }
                                    .font(.subheadline)
                                    .fontWeight(
                                        .semibold
                                    )
                                    .foregroundStyle(
                                        .blue
                                    )
                                }
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
                    }
                }


                Text("Quick Actions")
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(
                    spacing: 12
                ) {

                    quickActionButton(
                        title: "Students",
                        icon: "person.2"
                    ) {

                        selectedSection =
                            .students
                    }

                    quickActionButton(
                        title: "Assign Task",
                        icon: "checklist"
                    ) {

                        selectedSection =
                            .practice
                    }
                }

                HStack(
                    spacing: 12
                ) {

                    quickActionButton(
                        title: "Calendar",
                        icon: "calendar"
                    ) {

                        selectedSection =
                            .calendar
                    }

                    quickActionButton(
                        title: "Resources",
                        icon: "folder"
                    ) {

                        selectedSection =
                            .resources
                    }
                }

                Spacer()
            }
            .padding()
        }

        .onAppear {

            viewModel.loadTodaysLessons(
                teacherID: teacher.id
            )
        }
    }

    // creates a reusable quick action button that runs the provided navigation action
    private func quickActionButton(
        title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {

        Button(
            action: action
        ) {

            VStack(
                spacing: 10
            ) {

                Image(
                    systemName: icon
                )
                .font(.title2)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(
                maxWidth: .infinity
            )
            .padding(
                .vertical,
                22
            )
            .background(
                .gray.opacity(0.12)
            )
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}
