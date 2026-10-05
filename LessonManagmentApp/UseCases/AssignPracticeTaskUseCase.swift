//
//  AssignPracticeTaskUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/9/2026.
//

import Foundation


enum AssignPracticeTaskError: Error {

    case missingTitle
    case lessonNotFound
    case invalidDueDate
}


struct AssignPracticeTaskUseCase {

    private let practiceTaskRepository: PracticeTaskRepository
    private let lessonRepository: LessonRepository


    // creates the use case with access to practice task and lesson data
    init(
        practiceTaskRepository: PracticeTaskRepository,
        lessonRepository: LessonRepository
    ) {

        self.practiceTaskRepository =
            practiceTaskRepository

        self.lessonRepository =
            lessonRepository
    }


    // assigns a practice task while enforcing practice task rules
    func execute(
        title: String,
        description: String,
        studentID: UUID,
        teacherID: UUID,
        lessonID: UUID,
        dueDate: Date?
    ) throws {

        let cleanedTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanedTitle.isEmpty else {
            throw AssignPracticeTaskError.missingTitle
        }

        guard let lesson =
            lessonRepository
                .getAllLessons()
                .first(
                    where: {
                        $0.id == lessonID
                    }
                )
        else {
            throw AssignPracticeTaskError.lessonNotFound
        }

        // ensures the due date occurs after the linked lesson
        if let dueDate = dueDate {

            guard dueDate > lesson.date else {
                throw AssignPracticeTaskError.invalidDueDate
            }
        }

        let task = PracticeTask(
            id: UUID(),
            title: cleanedTitle,
            description: description,
            studentID: studentID,
            teacherID: teacherID,
            lessonID: lessonID,
            dueDate: dueDate,
            isCompleted: false
        )

        practiceTaskRepository.addTask(
            task
        )

        
    }
}
