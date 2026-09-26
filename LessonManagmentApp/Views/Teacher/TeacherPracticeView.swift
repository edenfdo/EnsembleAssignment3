//
//  TeacherPracticeView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

struct TeacherPracticeView: View {

    @Binding var showMenu: Bool
    @Binding var selectedSection: TeacherSection

    let teacher: User
    
    @StateObject var viewModel: TeacherPracticeViewModel

    @State private var showAssignTaskSheet = false

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 20
            ) {


                MenuBarView(
                    showMenu: $showMenu,
                    onLogoTap: {
                        selectedSection = .home
                    }
                )


                Text("Practice Tasks")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(
                    "Create and manage practice tasks for your students."
                )
                .foregroundStyle(.secondary)


                Button {

                    showAssignTaskSheet = true

                } label: {

                    HStack {

                        Image(systemName: "plus")

                        Text("Assign Practice Task")
                            .fontWeight(.semibold)

                        Spacer()
                    }
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)


                Text("Assigned Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 4)

                if viewModel.tasks.isEmpty {

                    Text("No practice tasks assigned.")
                        .foregroundStyle(.secondary)

                } else {

                    ForEach(viewModel.tasks, id: \.id) { task in

                        taskCard(task)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            viewModel.loadData(
                teacherID: teacher.id
            )
        }
        .sheet(
            isPresented: $showAssignTaskSheet
        ) {
            AssignPracticeTaskView(
                teacher: teacher,
                viewModel: viewModel
            )
        }
    }


    // builds the reusable card layout for each practice task
    private func taskCard(
        _ task: PracticeTask
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

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
                    spacing: 6
                ) {

                    Text(task.title)
                        .font(.headline)

                    if !task.taskDescription
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .isEmpty {

                        Text(
                            task.taskDescription
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    if let student =
                        viewModel.studentForTask(task) {

                        Text("Student: \(student.name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let lesson =
                        viewModel.lessons.first(
                            where: {
                                $0.id == task.lessonID
                            }
                        ) {

                        Text(
                            "Lesson: \(lesson.title)"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Text(
                            "Lesson Date: \(lesson.date.formatted(date: .abbreviated, time: .omitted))"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    if let dueDate = task.dueDate {

                        Text(
                            "Due \(dueDate.formatted(date: .abbreviated, time: .omitted))"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            Text(
                task.isCompleted
                ? "Completed"
                : "In Progress"
            )
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(
                task.isCompleted
                ? .green
                : .orange
            )
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
