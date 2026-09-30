//
//  ScheduleLessonUseCase.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/9/2026.
//

import Foundation


enum ScheduleLessonError: Error {

    case missingTitle
    case invalidDuration
    case invalidNumberOfLessons
    case schedulingConflict
}


struct ScheduleLessonUseCase {

    private let lessonRepository: LessonRepository


    // creates the use case with access to lesson data
    init(
        lessonRepository: LessonRepository
    ) {

        self.lessonRepository =
            lessonRepository
    }


    // schedules one or more lessons while enforcing lesson scheduling rules
    func execute(
        title: String,
        date: Date,
        durationMinutes: Int,
        location: String,
        notes: String,
        studentID: UUID,
        teacherID: UUID,
        repeatOption: LessonRepeatOption,
        numberOfLessons: Int,
        allowConflict: Bool = false
    ) throws {

        let cleanedTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanedTitle.isEmpty else {
            throw ScheduleLessonError.missingTitle
        }

        guard durationMinutes > 0 else {
            throw ScheduleLessonError.invalidDuration
        }

        if repeatOption != .none
            && numberOfLessons < 1 {

            throw ScheduleLessonError
                .invalidNumberOfLessons
        }

        // checks for an existing lesson at the requested time
        if !allowConflict,
           conflictingLesson(
                startingDate: date,
                durationMinutes: durationMinutes,
                teacherID: teacherID,
                repeatOption: repeatOption,
                numberOfLessons: numberOfLessons
           ) != nil {

            throw ScheduleLessonError
                .schedulingConflict
        }

        let lessonCount =
            repeatOption == .none
            ? 1
            : numberOfLessons

        // creates each lesson in the recurring series
        for index in 0..<lessonCount {

            let lessonDate =
                dateForLesson(
                    startingDate: date,
                    index: index,
                    repeatOption: repeatOption
                )

            let lesson = Lesson(
                id: UUID(),
                title: cleanedTitle,
                date: lessonDate,
                durationMinutes: durationMinutes,
                studentID: studentID,
                teacherID: teacherID,
                notes: notes,
                location: location
            )

            lessonRepository.addLesson(
                lesson
            )
        }
    }


    // finds an existing lesson that overlaps the requested lesson time
    func conflictingLesson(
        startingDate: Date,
        durationMinutes: Int,
        teacherID: UUID,
        repeatOption: LessonRepeatOption,
        numberOfLessons: Int,
        excludingLessonID: UUID? = nil
    ) -> Lesson? {

        let existingLessons =
            lessonRepository.getLessons(
                forTeacherID: teacherID
            )

        let lessonCount =
            repeatOption == .none
            ? 1
            : numberOfLessons

        for index in 0..<lessonCount {

            let newLessonStart =
                dateForLesson(
                    startingDate: startingDate,
                    index: index,
                    repeatOption: repeatOption
                )

            let newLessonEnd =
                newLessonStart.addingTimeInterval(
                    TimeInterval(
                        durationMinutes * 60
                    )
                )

            for existingLesson in existingLessons {

                // ignores the lesson currently being edited
                if existingLesson.id ==
                    excludingLessonID {
                    continue
                }

                let existingStart =
                    existingLesson.date

                let existingEnd =
                    existingStart
                        .addingTimeInterval(
                            TimeInterval(
                                existingLesson
                                    .durationMinutes * 60
                            )
                        )

                // checks whether the two lesson time ranges overlap
                let overlaps =
                    newLessonStart < existingEnd
                    &&
                    newLessonEnd > existingStart

                if overlaps {
                    return existingLesson
                }
            }
        }

        return nil
    }


    // calculates the date of each repeated lesson
    private func dateForLesson(
        startingDate: Date,
        index: Int,
        repeatOption: LessonRepeatOption
    ) -> Date {

        let calendar =
            Calendar.current

        switch repeatOption {

        case .none:

            return startingDate

        case .weekly:

            return calendar.date(
                byAdding: .weekOfYear,
                value: index,
                to: startingDate
            ) ?? startingDate

        case .fortnightly:

            return calendar.date(
                byAdding: .weekOfYear,
                value: index * 2,
                to: startingDate
            ) ?? startingDate
        }
    }
}
