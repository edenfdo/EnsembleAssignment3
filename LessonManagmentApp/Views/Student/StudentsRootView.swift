//
//  StudentsRootView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 10/9/2026.
//

import SwiftUI

struct StudentRootView: View {

    let student: User

    let lessonRepository: LessonRepository
    let practiceTaskRepository: PracticeTaskRepository
    let resourceRepository: ResourceRepository
    let userRepository: UserRepository

    let onLogout: () -> Void
    
    @State private var selectedSection: StudentSection = .home
    @State private var showMenu = false
    @State private var resourceToOpen: Resource?


    var body: some View {

        ZStack {

            currentPage

            if showMenu {

                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showMenu = false
                    }

                HStack(spacing: 0) {

                    Spacer()

                    VStack(
                        alignment: .leading,
                        spacing: 0
                    ) {

                        HStack {

                            Text("Menu")
                                .font(.title2)
                                .fontWeight(.bold)

                            Spacer()

                            Button {
                                showMenu = false
                            } label: {

                                Image(
                                    systemName: "xmark"
                                )
                                .font(.title2)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 60)
                        .padding(.bottom, 25)

                        Divider()

                        menuButton(
                            title: "Home",
                            icon: "house",
                            section: .home
                        )

                        menuButton(
                            title: "Calendar",
                            icon: "calendar",
                            section: .calendar
                        )

                        menuButton(
                            title: "Practice",
                            icon: "checklist",
                            section: .practice
                        )

                        menuButton(
                            title: "Resources",
                            icon: "folder",
                            section: .resources
                        )

                        menuButton(
                            title: "Quizzes",
                            icon: "questionmark.circle",
                            section: .quizzes
                        )

                        menuButton(
                            title: "Settings",
                            icon: "gearshape",
                            section: .settings
                        )

                        Spacer()

                        Divider()

                        Button {

                            showMenu = false
                            onLogout()

                        } label: {

                            HStack(
                                spacing: 16
                            ) {

                                Image(
                                    systemName:
                                        "rectangle.portrait.and.arrow.right"
                                )
                                .frame(width: 24)

                                Text("Log Out")
                                    .fontWeight(.semibold)

                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: 300)
                    .background(
                        Color(.systemBackground)
                    )
                    .ignoresSafeArea()
                    .shadow(radius: 10)
                }
            }
        }
    }

    // displays the student screen that matches the selected menu section
    @ViewBuilder
    private var currentPage: some View {

        switch selectedSection {

        case .home:

            StudentHomeView(
                viewModel: StudentHomeViewModel(
                    lessonRepository: lessonRepository,
                    practiceTaskRepository:
                        practiceTaskRepository
                ),
                studentID: student.id,
                showMenu: $showMenu,
                selectedSection:
                    $selectedSection
            )

        case .calendar:

            CalendarView(
                viewModel: CalendarViewModel(
                    lessonRepository: lessonRepository,
                    practiceTaskRepository: practiceTaskRepository,
                    resourceRepository: resourceRepository
                ),
                showMenu: $showMenu,
                studentID: student.id,
                selectedSection: $selectedSection
            )

        case .practice:

            PracticeView(
                viewModel: PracticeViewModel(
                    practiceTaskRepository:
                        practiceTaskRepository,
                    lessonRepository:
                        lessonRepository
                ),
                showMenu: $showMenu,
                selectedSection: $selectedSection,
                studentID: student.id
            )

        case .resources:

            ResourcesView(
                showMenu: $showMenu,
                selectedSection: $selectedSection,
                viewModel: StudentResourcesViewModel(
                    resourceRepository: resourceRepository,
                    lessonRepository: lessonRepository
                ),
                studentID: student.id,
                resourceToOpen: $resourceToOpen
            )

        case .quizzes:

            QuizzesView(
                showMenu: $showMenu,
                selectedSection: $selectedSection,
                viewModel: QuizViewModel(
                    quizRepository: LocalQuizRepository()
                )
            )

        case .settings:

            SettingsView(
                showMenu: $showMenu,
                onLogoTap: {
                    selectedSection = .home
                },
                user: student,
                viewModel: SettingsViewModel(
                    userRepository: userRepository
                )
            )
        }
    }

    // creates a reusable menu button that navigates to the selected section
    private func menuButton(
        title: String,
        icon: String,
        section: StudentSection
    ) -> some View {

        Button {

            selectedSection = section
            showMenu = false

        } label: {

            HStack(
                spacing: 16
            ) {

                Image(
                    systemName: icon
                )
                .frame(width: 24)

                Text(title)
                    .fontWeight(
                        selectedSection == section
                            ? .semibold
                            : .regular
                    )

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .foregroundStyle(
                selectedSection == section
                    ? Color.blue
                    : Color.primary
            )
            .background(
                selectedSection == section
                    ? Color.blue.opacity(0.08)
                    : Color.clear
            )
        }
        .buttonStyle(.plain)
    }
}
