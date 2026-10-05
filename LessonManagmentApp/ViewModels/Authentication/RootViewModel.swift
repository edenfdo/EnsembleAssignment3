//
//  RootViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine
import Supabase
import Auth

final class RootViewModel: ObservableObject {

    @Published var currentUser: User?
    @Published var requiresPasswordChange = false

    // sets the logged-in user and records whether they must change their password
    func login(
        user: User,
        requiresPasswordChange: Bool = false,
        userRepository: UserRepository,
        lessonRepository: LessonRepository
    ) {

        currentUser = user

        self.requiresPasswordChange =
            requiresPasswordChange

        updateWidgetData(
            for: user,
            userRepository: userRepository,
            lessonRepository: lessonRepository
        )
    }
    
    // allows the user to continue after completing a required password change
    func completeRequiredPasswordChange() {

        requiresPasswordChange = false
    }
    
    // signs out of Supabase and clears the current user
    func logout() {

        Task {

            do {

                try await SupabaseService.client.auth.signOut()

                await MainActor.run {
                    currentUser = nil
                    requiresPasswordChange = false
                }

            } catch {

                print("Failed to log out: \(error)")
            }
        }
    }
    
    // updates the widget for the logged-in user
    private func updateWidgetData(
        for user: User,
        userRepository: UserRepository,
        lessonRepository: LessonRepository
    ) {

        if user.role == .teacher {

            let lessons =
                lessonRepository
                    .getLessons(
                        forTeacherID: user.id
                    )

            let students =
                userRepository
                    .getStudents()

            let now = Date()

            let widgetLessons =
                lessons.flatMap { lesson in

                    let studentName =
                        students.first {
                            $0.id == lesson.studentID
                        }?.name
                        ?? "Student"

                    let occurrenceDates =
                        LessonRecurrenceService
                            .upcomingOccurrenceDates(
                                for: lesson,
                                onOrAfter: now,
                                limit: 3
                            )

                    return occurrenceDates.map { occurrenceDate in

                        WidgetLessonData(
                            id: UUID(),
                            title: lesson.title,
                            date: occurrenceDate,
                            durationMinutes: lesson.durationMinutes,
                            personName: studentName,
                            location: lesson.location
                        )
                    }
                }
                .sorted {
                    $0.date < $1.date
                }

            WidgetDataService.save(
                role: "teacher",
                lessons: widgetLessons
            )

        } else {

            let lessons =
                lessonRepository
                    .getLessons(
                        forStudentID: user.id
                    )

            let teachers =
                userRepository
                    .getTeachers()

            let now = Date()

            let widgetLessons =
                lessons.flatMap { lesson in

                    let teacherName =
                        teachers.first {
                            $0.id == lesson.teacherID
                        }?.name
                        ?? "Teacher"

                    let occurrenceDates =
                        LessonRecurrenceService
                            .upcomingOccurrenceDates(
                                for: lesson,
                                onOrAfter: now,
                                limit: 3
                            )

                    return occurrenceDates.map { occurrenceDate in

                        WidgetLessonData(
                            id: UUID(),
                            title: lesson.title,
                            date: occurrenceDate,
                            durationMinutes: lesson.durationMinutes,
                            personName: teacherName,
                            location: lesson.location
                        )
                    }
                }
                .sorted {
                    $0.date < $1.date
                }

            WidgetDataService.save(
                role: "student",
                lessons: widgetLessons
            )
        }
    }

    
    // fixed IDs keep seeded users, lessons and tasks linked consistently
    static let studentID =
        UUID(
            uuidString:
                "11111111-1111-1111-1111-111111111111"
        )!

    static let teacherID =
        UUID(
            uuidString:
                "22222222-2222-2222-2222-222222222222"
        )!
    static let lessonID =
        UUID(
            uuidString:
                "33333333-3333-3333-3333-333333333333"
        )!
}
