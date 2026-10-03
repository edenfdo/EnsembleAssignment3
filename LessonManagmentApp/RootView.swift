//
//  RootView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/8/2026.
//

import SwiftUI
import SwiftData

struct RootView: View {
    
    @Environment(\.modelContext)
    private var modelContext
    
    @StateObject private var viewModel = RootViewModel()
    
    var body: some View {
        
        // creates the repositories used throughout the app with the shared SwiftData context
        let resourceRepository =
        LocalResourceRepository(
            modelContext: modelContext
        )
        
        let lessonRepository =
        LocalLessonRepository(
            modelContext: modelContext
        )
        
        let practiceTaskRepository =
        LocalPracticeTaskRepository(
            modelContext:
                modelContext
        )
        
        let userRepository =
        LocalUserRepository(
            modelContext: modelContext
        )
        
        Group {
            
            if let user = viewModel.currentUser {

                // forces users with a temporary password
                // to create a new password before entering the app
                if viewModel.requiresPasswordChange {

                    ChangePasswordView(
                        user: user,
                        viewModel:
                            SettingsViewModel(
                                userRepository:
                                    userRepository
                            ),
                        isForcedChange: true,
                        onPasswordChanged: {

                            viewModel
                                .completeRequiredPasswordChange()
                        },
                        onLogout: {

                            viewModel.logout()
                        }
                    )

                } else {

                    // displays the correct app experience
                    // based on the logged-in user's role
                    switch user.role {

                    case .student:

                        StudentRootView(
                            student: user,
                            lessonRepository:
                                lessonRepository,
                            practiceTaskRepository:
                                practiceTaskRepository,
                            resourceRepository:
                                resourceRepository,
                            userRepository:
                                userRepository,
                            onLogout: {
                                viewModel.logout()
                            }
                        )

                    case .teacher:

                        TeacherRootView(
                            teacher: user,
                            lessonRepository:
                                lessonRepository,
                            practiceTaskRepository:
                                practiceTaskRepository,
                            userRepository:
                                userRepository,
                            resourceRepository:
                                resourceRepository,
                            onLogout: {
                                viewModel.logout()
                            }
                        )
                    }
                }

            } else {
                
                LoginView(
                    viewModel:
                        LoginViewModel(
                            userRepository:
                                userRepository
                        )
                ) { user, requiresPasswordChange in

                    viewModel.login(
                        user: user,
                        requiresPasswordChange:
                            requiresPasswordChange,
                        userRepository:
                            userRepository,
                        lessonRepository:
                            lessonRepository
                    )
                }
            }
        }
        .onAppear {
            
            viewModel.seedDataIfNeeded(
                userRepository:
                    userRepository,
                practiceTaskRepository:
                    practiceTaskRepository,
                lessonRepository:
                    lessonRepository
            )
        }
    }
}

#Preview {

    let container = try! ModelContainer(
        for: User.self,
        configurations: ModelConfiguration(
            isStoredInMemoryOnly: true
        )
    )

    let userRepository =
        LocalUserRepository(
            modelContext:
                container.mainContext
        )

    LoginView(
        viewModel:
            LoginViewModel(
                userRepository:
                    userRepository
            )
    ) { user, _ in

        print(user.name)
    }
    .modelContainer(container)
}
