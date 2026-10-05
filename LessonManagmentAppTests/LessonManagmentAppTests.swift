//
//  LessonManagmentAppTests.swift
//  LessonManagmentAppTests
//
//  Created by Eden Fernando on 13/9/2026.
//

import Testing
import Foundation

@testable import LessonManagmentApp


@MainActor
struct LessonManagmentAppTests {


    // verifies a valid lesson can be scheduled
    @Test
    func scheduleLesson_succeeds_whenDetailsAreValid() throws {

        let lessonRepository =
            MockLessonRepository()

        let useCase =
            ScheduleLessonUseCase(
                lessonRepository: lessonRepository
            )

        try useCase.execute(
            title: "Piano Lesson",
            date: Date(),
            durationMinutes: 60,
            location: "Room 1",
            notes: "",
            studentID: UUID(),
            teacherID: UUID(),
            recurrence: .none,
            recurrenceEndDate: nil
        )

        #expect(lessonRepository.lessons.count == 1)

        #expect(
            lessonRepository.lessons.first?.title ==
            "Piano Lesson"
        )
    }


    // verifies overlapping lessons are rejected
    @Test
    func scheduleLesson_fails_whenTeacherHasOverlappingLesson() throws {

        let lessonRepository =
            MockLessonRepository()

        let teacherID = UUID()
        let studentID = UUID()
        let existingStart = Date()

        lessonRepository.addLesson(
            Lesson(
                id: UUID(),
                title: "Existing Piano Lesson",
                date: existingStart,
                durationMinutes: 60,
                studentID: studentID,
                teacherID: teacherID,
                notes: "",
                location: "Room 1"
            )
        )

        let useCase =
            ScheduleLessonUseCase(
                lessonRepository: lessonRepository
            )

        let overlappingStart =
            existingStart.addingTimeInterval(
                30 * 60
            )

        do {

            try useCase.execute(
                title: "New Piano Lesson",
                date: overlappingStart,
                durationMinutes: 60,
                location: "Room 2",
                notes: "",
                studentID: studentID,
                teacherID: teacherID,
                recurrence: .none,
                recurrenceEndDate: nil
            )

            Issue.record(
                "Expected a scheduling conflict."
            )

        } catch let error as ScheduleLessonError {

            switch error {

            case .schedulingConflict:
                break

            default:
                Issue.record(
                    "Expected schedulingConflict but received \(error)."
                )
            }
        }

        #expect(lessonRepository.lessons.count == 1)
    }


    // verifies a lesson can begin exactly when another lesson ends
    @Test
    func scheduleLesson_succeeds_whenStartingAtPreviousLessonEndTime() throws {

        let lessonRepository =
            MockLessonRepository()

        let teacherID = UUID()
        let studentID = UUID()
        let existingStart = Date()

        lessonRepository.addLesson(
            Lesson(
                id: UUID(),
                title: "Existing Lesson",
                date: existingStart,
                durationMinutes: 60,
                studentID: studentID,
                teacherID: teacherID,
                notes: "",
                location: "Room 1"
            )
        )

        let useCase =
            ScheduleLessonUseCase(
                lessonRepository: lessonRepository
            )

        let exactEndTime =
            existingStart.addingTimeInterval(
                60 * 60
            )

        try useCase.execute(
            title: "Next Lesson",
            date: exactEndTime,
            durationMinutes: 60,
            location: "Room 1",
            notes: "",
            studentID: studentID,
            teacherID: teacherID,
            recurrence: .none,
            recurrenceEndDate: nil
        )

        #expect(lessonRepository.lessons.count == 2)
    }

    // verifies a practice task can be assigned after its lesson
    @Test
    func assignPracticeTask_succeeds_whenDueDateIsAfterLesson() throws {

        let lessonRepository =
            MockLessonRepository()

        let practiceTaskRepository =
            MockPracticeTaskRepository()

        let teacherID = UUID()
        let studentID = UUID()
        let lessonID = UUID()

        let lessonDate = Date()

        lessonRepository.addLesson(
            Lesson(
                id: lessonID,
                title: "Piano Lesson",
                date: lessonDate,
                durationMinutes: 60,
                studentID: studentID,
                teacherID: teacherID,
                notes: "",
                location: "Room 1"
            )
        )

        let useCase =
            AssignPracticeTaskUseCase(
                practiceTaskRepository:
                    practiceTaskRepository,
                lessonRepository:
                    lessonRepository
            )

        let dueDate =
            lessonDate.addingTimeInterval(
                24 * 60 * 60
            )

        try useCase.execute(
            title: "Practise C Major Scale",
            description:
                "Practise the C major scale.",
            studentID: studentID,
            teacherID: teacherID,
            lessonID: lessonID,
            dueDate: dueDate
        )

        #expect(
            practiceTaskRepository.tasks.count == 1
        )

        #expect(
            practiceTaskRepository.tasks.first?.title ==
            "Practise C Major Scale"
        )
    }


    // verifies a due date before the lesson is rejected
    @Test
    func assignPracticeTask_fails_whenDueDateIsBeforeLesson() throws {

        let lessonRepository =
            MockLessonRepository()

        let practiceTaskRepository =
            MockPracticeTaskRepository()

        let teacherID = UUID()
        let studentID = UUID()
        let lessonID = UUID()

        let lessonDate = Date()

        lessonRepository.addLesson(
            Lesson(
                id: lessonID,
                title: "Piano Lesson",
                date: lessonDate,
                durationMinutes: 60,
                studentID: studentID,
                teacherID: teacherID,
                notes: "",
                location: "Room 1"
            )
        )

        let useCase =
            AssignPracticeTaskUseCase(
                practiceTaskRepository:
                    practiceTaskRepository,
                lessonRepository:
                    lessonRepository
            )

        let invalidDueDate =
            lessonDate.addingTimeInterval(
                -60 * 60
            )

        do {

            try useCase.execute(
                title: "Practise Scale",
                description: "",
                studentID: studentID,
                teacherID: teacherID,
                lessonID: lessonID,
                dueDate: invalidDueDate
            )

            Issue.record(
                "Expected an invalid due date error."
            )

        } catch let error as AssignPracticeTaskError {

            switch error {

            case .invalidDueDate:
                break

            default:
                Issue.record(
                    "Expected invalidDueDate but received \(error)."
                )
            }
        }

        #expect(
            practiceTaskRepository.tasks.isEmpty
        )
    }


    // verifies the lesson time itself cannot be used as the task due date
    @Test
    func assignPracticeTask_fails_whenDueDateEqualsLessonTime() throws {

        let lessonRepository =
            MockLessonRepository()

        let practiceTaskRepository =
            MockPracticeTaskRepository()

        let teacherID = UUID()
        let studentID = UUID()
        let lessonID = UUID()

        let lessonDate = Date()

        lessonRepository.addLesson(
            Lesson(
                id: lessonID,
                title: "Piano Lesson",
                date: lessonDate,
                durationMinutes: 60,
                studentID: studentID,
                teacherID: teacherID,
                notes: "",
                location: "Room 1"
            )
        )

        let useCase =
            AssignPracticeTaskUseCase(
                practiceTaskRepository:
                    practiceTaskRepository,
                lessonRepository:
                    lessonRepository
            )

        do {

            try useCase.execute(
                title: "Practise Scale",
                description: "",
                studentID: studentID,
                teacherID: teacherID,
                lessonID: lessonID,
                dueDate: lessonDate
            )

            Issue.record(
                "Expected an invalid due date error."
            )

        } catch let error as AssignPracticeTaskError {

            switch error {

            case .invalidDueDate:
                break

            default:
                Issue.record(
                    "Expected invalidDueDate but received \(error)."
                )
            }
        }

        #expect(
            practiceTaskRepository.tasks.isEmpty
        )
    }


    // verifies an invalid student email is rejected
    @Test
    func addStudent_fails_whenEmailIsInvalid() throws {

        let userRepository =
            MockUserRepository()

        let useCase =
            AddStudentUseCase(
                userRepository: userRepository
            )

        do {

            try useCase.execute(
                firstName: "Mia",
                lastName: "Smith",
                email: "miaemail"
            )

            Issue.record(
                "Expected an invalid email error."
            )

        } catch let error as AddStudentError {

            switch error {

            case .invalidEmail:
                break

            default:
                Issue.record(
                    "Expected invalidEmail but received \(error)."
                )
            }
        }
    }


    // verifies an existing student email cannot be used again
    @Test
    func addStudent_fails_whenEmailAlreadyExists() throws {

        let userRepository =
            MockUserRepository()

        userRepository.addUser(
            User(
                id: UUID(),
                name: "Mia Smith",
                email: "mia@email.com",
                password: "student123",
                role: .student
            )
        )

        let useCase =
            AddStudentUseCase(
                userRepository: userRepository
            )

        do {

            try useCase.execute(
                firstName: "Another",
                lastName: "Student",
                email: "MIA@email.com"
            )

            Issue.record(
                "Expected a duplicate email error."
            )

        } catch let error as AddStudentError {

            switch error {

            case .emailAlreadyExists:
                break

            default:
                Issue.record(
                    "Expected emailAlreadyExists but received \(error)."
                )
            }
        }
    }

    // verifies lessons can be retrieved for the assigned teacher
    @Test
    func lessonRepository_returnsOnlyLessonsForSelectedTeacher() {

        let repository =
            MockLessonRepository()

        let selectedTeacherID = UUID()
        let otherTeacherID = UUID()

        repository.addLesson(
            Lesson(
                id: UUID(),
                title: "Piano Lesson",
                date: Date(),
                durationMinutes: 60,
                studentID: UUID(),
                teacherID: selectedTeacherID,
                notes: "",
                location: "Room 1"
            )
        )

        repository.addLesson(
            Lesson(
                id: UUID(),
                title: "Guitar Lesson",
                date: Date(),
                durationMinutes: 60,
                studentID: UUID(),
                teacherID: otherTeacherID,
                notes: "",
                location: "Room 2"
            )
        )

        let lessons =
            repository.getLessons(
                forTeacherID: selectedTeacherID
            )

        #expect(lessons.count == 1)

        #expect(
            lessons.first?.title ==
            "Piano Lesson"
        )
    }
}
