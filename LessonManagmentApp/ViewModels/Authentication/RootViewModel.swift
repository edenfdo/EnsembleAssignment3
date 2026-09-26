//
//  RootViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine

final class RootViewModel: ObservableObject {

    @Published var currentUser: User?

    private var hasSeededData = false

    // seeds the initial users, practice tasks and lessons only once
    func seedDataIfNeeded(
        userRepository: UserRepository,
        practiceTaskRepository: PracticeTaskRepository,
        lessonRepository: LessonRepository
    ) {

        guard !hasSeededData else {
            return
        }

        seedUsersIfNeeded(
            repository: userRepository
        )

        seedPracticeTasksIfNeeded(
            repository: practiceTaskRepository
        )

        seedLessonsIfNeeded(
            repository: lessonRepository
        )

        hasSeededData = true
    }


    // sets the logged-in user
    func login(
        user: User
    ) {

        currentUser = user
    }

    
    // clears the current user to log out
    func logout() {

        currentUser = nil
    }

   
    // adds the default student and teacher if no users exist
    private func seedUsersIfNeeded(
        repository: UserRepository
    ) {

        let existingUsers =
            repository.getAllUsers()

        guard existingUsers.isEmpty else {
            return
        }

        let student = User(
            id: Self.studentID,
            name: "Mia",
            email: "mia@email.com",
            password: "student123",
            role: .student
        )

        let teacher = User(
            id: Self.teacherID,
            name: "Daniel",
            email: "daniel@email.com",
            password: "teacher123",
            role: .teacher
        )

        repository.addUser(student)
        repository.addUser(teacher)
    }


    // adds the default practice tasks if no tasks exist
    private func seedPracticeTasksIfNeeded(
        repository: PracticeTaskRepository
    ) {

        let existingTasks =
            repository.getAllTasks()

        guard existingTasks.isEmpty else {
            return
        }

        let task1 = PracticeTask(
            id: UUID(),
            title: "Practise C Major scale",
            description: "Practise slowly with both hands.",
            studentID: Self.studentID,
            teacherID: Self.teacherID,
            lessonID: Self.lessonID,
            dueDate: Date().addingTimeInterval(86400),
            isCompleted: true
        )

        let task2 = PracticeTask(
            id: UUID(),
            title: "Complete rhythm quiz",
            description:
                "Complete the rhythm quiz before your next lesson.",
            studentID: Self.studentID,
            teacherID: Self.teacherID,
            lessonID: Self.lessonID,
            dueDate: Date().addingTimeInterval(172800),
            isCompleted: false
        )

        let task3 = PracticeTask(
            id: UUID(),
            title: "Practise bars 1–16",
            description:
                "Focus on accurate notes and rhythm.",
            studentID: Self.studentID,
            teacherID: Self.teacherID,
            lessonID: Self.lessonID,
            dueDate: Date().addingTimeInterval(259200),
            isCompleted: false
        )

        repository.addTask(task1)
        repository.addTask(task2)
        repository.addTask(task3)
    }

    // adds the default lesson if no lessons exist
    private func seedLessonsIfNeeded(
        repository: LessonRepository
    ) {

        let existingLessons =
            repository.getAllLessons()

        guard existingLessons.isEmpty else {
            return
        }

        let lesson = Lesson(
            id: Self.lessonID,
            title: "Piano Lesson",
            date: Date().addingTimeInterval(86400),
            durationMinutes: 60,
            studentID: Self.studentID,
            teacherID: Self.teacherID,
            notes:
                "Practise C major scale and bars 1–16.",
            location: "Room 3"
        )

        repository.addLesson(lesson)
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
