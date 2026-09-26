//
//  TeacherStudentsView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

struct TeacherStudentsView: View {

    @Binding var showMenu: Bool
    @Binding var selectedSection: TeacherSection
    @State private var showAddStudentSheet = false

    @StateObject var viewModel: TeacherStudentsViewModel
    
    let lessonRepository: LessonRepository
    let practiceTaskRepository: PracticeTaskRepository

    @State private var selectedStudent: User?

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


                Text("Students")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("View and manage your students.")
                    .foregroundStyle(.secondary)
                
                Button {
                    showAddStudentSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus")

                        Text("Add Student")
                            .fontWeight(.semibold)

                        Spacer()
                    }
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)


                if viewModel.students.isEmpty {

                    Text("No students found.")
                        .foregroundStyle(.secondary)
                        .padding(.top)

                } else {

                    ForEach(viewModel.students) { student in
                        
                        Button {

                            selectedStudent = student

                        } label: {

                            HStack(spacing: 16) {

                                Image(
                                    systemName: "person.circle.fill"
                                )
                                .font(.system(size: 44))
                                .foregroundStyle(.blue)

                                VStack(
                                    alignment: .leading,
                                    spacing: 5
                                ) {

                                    Text(student.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(student.email)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    Text("Music Student")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(
                                    systemName: "chevron.right"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .padding()
        }


        .sheet(
            item: $selectedStudent
        ) { student in

            TeacherStudentDetailView(
                student: student,
                viewModel:
                    TeacherStudentDetailViewModel(
                        lessonRepository:
                            lessonRepository,
                        practiceTaskRepository:
                            practiceTaskRepository
                    )
            )
        }
        .sheet(
            isPresented: $showAddStudentSheet
        ) {
            AddStudentView(
                viewModel: viewModel
            )
        }
        .onAppear {
            viewModel.loadStudents()
        }
    }
}
