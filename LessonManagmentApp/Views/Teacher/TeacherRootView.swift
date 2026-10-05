//
//  TeacherRootView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

struct TeacherRootView: View {

    @State private var selectedSection: TeacherSection = .home
    @State private var showMenu = false
    @State private var refreshID = UUID()
    @State private var isInitialSyncing = true

    let teacher: User
    
    let lessonRepository: LessonRepository
    let practiceTaskRepository: PracticeTaskRepository
    let userRepository: UserRepository
    let resourceRepository: ResourceRepository
    
    let onLogout: () -> Void

    var body: some View {

        ZStack {

            if isInitialSyncing {

                VStack(
                    spacing: 12
                ) {

                    ProgressView()

                    Text("Loading...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

            } else {

                currentPage
                    .id(refreshID)
                    .refreshable {
                        await refreshAllTeacherData()
                    }
            }

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

                                Image(systemName: "xmark")
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
                            title: "Students",
                            icon: "person.2",
                            section: .students
                        )

                        menuButton(
                            title: "Practice Tasks",
                            icon: "checklist",
                            section: .practice
                        )

                        menuButton(
                            title: "Resources",
                            icon: "folder",
                            section: .resources
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
        .task {

            await refreshAllTeacherData()

            isInitialSyncing = false
        }
    }


    // displays the teacher screen that matches the selected menu section
    @ViewBuilder
    private var currentPage: some View {

        switch selectedSection {
            
        case .home:
            
            TeacherHomeView(
                teacher: teacher,
                showMenu: $showMenu,
                selectedSection: $selectedSection,
                viewModel: TeacherHomeViewModel(
                    lessonRepository: lessonRepository,
                    userRepository: userRepository
                )
            )
            
        case .calendar:

            TeacherCalendarView(
                showMenu: $showMenu,
                selectedSection: $selectedSection,
                teacher: teacher,
                viewModel: TeacherCalendarViewModel(
                    lessonRepository: lessonRepository,
                    userRepository: userRepository,
                    practiceTaskRepository: practiceTaskRepository,
                    resourceRepository: resourceRepository
                )
            )
            
        case .students:
            
            TeacherStudentsView(
                showMenu: $showMenu,
                selectedSection: $selectedSection,
                viewModel: TeacherStudentsViewModel(
                    userRepository: userRepository,
                    lessonRepository: lessonRepository,
                    practiceTaskRepository: practiceTaskRepository,
                    resourceRepository: resourceRepository
                ),
                lessonRepository: lessonRepository,
                practiceTaskRepository: practiceTaskRepository
            )
            
        case .practice:
            
            TeacherPracticeView(
                showMenu: $showMenu,
                selectedSection: $selectedSection,
                teacher: teacher,
                viewModel: TeacherPracticeViewModel(
                    practiceTaskRepository: practiceTaskRepository,
                    userRepository: userRepository,
                    lessonRepository: lessonRepository
                )
            )
            
        case .resources:
            
            TeacherResourcesView(
                showMenu: $showMenu,
                selectedSection: $selectedSection,
                teacher: teacher,
                viewModel: TeacherResourcesViewModel(
                    resourceRepository: resourceRepository,
                    userRepository: userRepository,
                    lessonRepository: lessonRepository
                )
            )
            
        case .settings:
            
            SettingsView(
                showMenu: $showMenu,
                onLogoTap: {
                    selectedSection = .home
                },
                user: teacher,
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
        section: TeacherSection
    ) -> some View {

        Button {

            selectedSection = section
            showMenu = false

        } label: {

            HStack(spacing: 16) {

                Image(systemName: icon)
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


    // creates a temporary placeholder page for unfinished teacher sections
    private func teacherPlaceholderPage(
        title: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 20
        ) {

            HStack {

                Text("Logo")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                Button {
                    showMenu = true
                } label: {

                    Image(
                        systemName: "line.3.horizontal"
                    )
                    .font(.title)
                }
            }

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(
                "\(title) page coming next."
            )
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
    }
    
    // synchronises the teacher's latest cloud data when they pull down to refresh
    @MainActor
    private func refreshAllTeacherData() async {

        let cloudUserRepository =
            SupabaseUserRepository()

        let syncStudents =
            SyncTeacherStudentsUseCase(
                cloudUserRepository:
                    cloudUserRepository,
                localUserRepository:
                    userRepository
            )

        let syncLessons =
            SyncTeacherLessonsUseCase(
                cloudLessonRepository:
                    SupabaseLessonRepository(),
                cloudUserRepository:
                    cloudUserRepository,
                localLessonRepository:
                    lessonRepository,
                localUserRepository:
                    userRepository
            )

        let syncPracticeTasks =
            SyncTeacherPracticeTasksUseCase(
                cloudPracticeTaskRepository:
                    SupabasePracticeTaskRepository(),
                cloudUserRepository:
                    cloudUserRepository,
                localPracticeTaskRepository:
                    practiceTaskRepository,
                localUserRepository:
                    userRepository
            )

        let syncResources =
            SyncTeacherResourcesUseCase(
                cloudResourceRepository:
                    SupabaseResourceRepository(),
                cloudUserRepository:
                    cloudUserRepository,
                localResourceRepository:
                    resourceRepository,
                localUserRepository:
                    userRepository
            )

        do {

            // students must sync first so the remaining
            // data can match cloud students to local students
            try await syncStudents.execute()

            // downloads the teacher's latest lessons
            try await syncLessons.execute(
                localTeacherID: teacher.id
            )

            // downloads the latest practice task changes
            try await syncPracticeTasks.execute(
                localTeacherID: teacher.id
            )

            // downloads the teacher's latest resources
            // including the actual PDF or image files
            try await syncResources.execute(
                localTeacherID: teacher.id
            )

            // recreates the current page so it reads
            // the updated SwiftData
            refreshID = UUID()

        } catch {

            print(
                "Failed to refresh teacher data: \(error)"
            )
        }
    }
}
