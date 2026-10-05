//
//  MockRepositories.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 5/10/2026.
//

import Foundation
@testable import LessonManagmentApp


final class MockLessonRepository: LessonRepository {

    var lessons: [Lesson] = []

    func getAllLessons() -> [Lesson] {
        lessons
    }

    func getLessons(
        forStudentID studentID: UUID
    ) -> [Lesson] {
        lessons.filter {
            $0.studentID == studentID
        }
    }

    func getLessons(
        forTeacherID teacherID: UUID
    ) -> [Lesson] {
        lessons.filter {
            $0.teacherID == teacherID
        }
    }

    func addLesson(
        _ lesson: Lesson
    ) {
        lessons.append(lesson)
    }

    func updateLesson(
        _ lesson: Lesson
    ) {
        guard let index =
            lessons.firstIndex(where: {
                $0.id == lesson.id
            })
        else {
            return
        }

        lessons[index] = lesson
    }

    func deleteLesson(
        _ lesson: Lesson
    ) {
        lessons.removeAll {
            $0.id == lesson.id
        }
    }
}


final class MockPracticeTaskRepository:
    PracticeTaskRepository {

    var tasks: [PracticeTask] = []

    func getAllTasks() -> [PracticeTask] {
        tasks
    }

    func getTasks(
        forStudentID studentID: UUID
    ) -> [PracticeTask] {
        tasks.filter {
            $0.studentID == studentID
        }
    }

    func addTask(
        _ task: PracticeTask
    ) {
        tasks.append(task)
    }

    func updateTask(
        _ task: PracticeTask
    ) {
        guard let index =
            tasks.firstIndex(where: {
                $0.id == task.id
            })
        else {
            return
        }

        tasks[index] = task
    }

    func deleteTask(
        _ task: PracticeTask
    ) {
        tasks.removeAll {
            $0.id == task.id
        }
    }
}


final class MockUserRepository: UserRepository {

    var users: [User] = []

    func getAllUsers() -> [User] {
        users
    }

    func getStudents() -> [User] {
        users.filter {
            $0.role == .student
        }
    }

    func getTeachers() -> [User] {
        users.filter {
            $0.role == .teacher
        }
    }

    func addUser(
        _ user: User
    ) {
        users.append(user)
    }

    func updateUser(
        _ user: User
    ) {
        guard let index =
            users.firstIndex(where: {
                $0.id == user.id
            })
        else {
            return
        }

        users[index] = user
    }

    func deleteUser(
        _ user: User
    ) {
        users.removeAll {
            $0.id == user.id
        }
    }
}



final class MockResourceRepository: ResourceRepository {

    var resources: [Resource] = []

    func getAllResources() -> [Resource] {
        resources
    }

    func getResources(
        forStudentID studentID: UUID
    ) -> [Resource] {
        resources.filter {
            $0.studentID == studentID
        }
    }

    func getResources(
        forTeacherID teacherID: UUID
    ) -> [Resource] {
        resources.filter {
            $0.teacherID == teacherID
        }
    }

    func addResource(
        _ resource: Resource
    ) {
        resources.append(resource)
    }

    func updateResource(
        _ resource: Resource
    ) {
        guard let index =
            resources.firstIndex(where: {
                $0.id == resource.id
            })
        else {
            return
        }

        resources[index] = resource
    }

    func deleteResource(
        _ resource: Resource
    ) {
        resources.removeAll {
            $0.id == resource.id
        }
    }
}
