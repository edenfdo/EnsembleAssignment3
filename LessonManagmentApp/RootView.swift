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
            
            // displays the correct app experience based on the logged-in user's role
            if let user = viewModel.currentUser {
                
                switch user.role {
                    
                case .student:

                    StudentRootView(
                        student: user,
                        lessonRepository: lessonRepository,
                        practiceTaskRepository: practiceTaskRepository,
                        resourceRepository: resourceRepository,
                        userRepository: userRepository,
                        onLogout: {
                            viewModel.logout()
                        }
                    )
                    
                case .teacher:
                    
                    TeacherRootView(
                        teacher: user,
                        lessonRepository: lessonRepository,
                        practiceTaskRepository: practiceTaskRepository,
                        userRepository: userRepository,
                        resourceRepository: resourceRepository,
                        onLogout: {
                            viewModel.logout()
                        }
                    )
                }
                
            } else {
                
                LoginView(
                    viewModel:
                        LoginViewModel(
                            userRepository:
                                userRepository
                        )
                ) { user in
                    
                    viewModel.login(
                        user: user
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
    ) { user in

        print(user.name)
    }
    .modelContainer(container)
}
