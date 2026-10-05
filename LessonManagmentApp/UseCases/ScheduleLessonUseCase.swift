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


    // schedules one lesson or one recurring lesson rule
    func execute(
        title: String,
        date: Date,
        durationMinutes: Int,
        location: String,
        notes: String,
        studentID: UUID,
        teacherID: UUID,
        recurrence: LessonRecurrence,
        recurrenceEndDate: Date?,
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

        // checks for a conflict at the first scheduled lesson
        if !allowConflict,
           conflictingLesson(
                startingDate: date,
                durationMinutes: durationMinutes,
                teacherID: teacherID,
                recurrence: recurrence,
                recurrenceEndDate: recurrenceEndDate
           ) != nil {

            throw ScheduleLessonError
                .schedulingConflict
        }

        // only ONE lesson is stored
        // recurrence describes how it repeats
        let lesson =
            Lesson(
                id: UUID(),
                title: cleanedTitle,
                date: date,
                durationMinutes: durationMinutes,
                studentID: studentID,
                teacherID: teacherID,
                notes: notes,
                location: location,
                recurrence: recurrence,
                recurrenceEndDate:
                    recurrence == .weekly
                    ? recurrenceEndDate
                    : nil
            )

        lessonRepository.addLesson(
            lesson
        )
    }


    // finds an existing lesson that overlaps
    // the first scheduled lesson time
    func conflictingLesson(
        startingDate: Date,
        durationMinutes: Int,
        teacherID: UUID,
        recurrence: LessonRecurrence = .none,
        recurrenceEndDate: Date? = nil,
        excludingLessonID: UUID? = nil
    ) -> Lesson? {

        let existingLessons =
            lessonRepository.getLessons(
                forTeacherID: teacherID
            )

        for existingLesson in existingLessons {

            // ignores the lesson currently being edited
            if existingLesson.id ==
                excludingLessonID {

                continue
            }

            if schedulesConflict(
                firstStart: startingDate,
                firstDurationMinutes: durationMinutes,
                firstRecurrence: recurrence,
                firstRecurrenceEndDate: recurrenceEndDate,
                secondStart: existingLesson.date,
                secondDurationMinutes:
                    existingLesson.durationMinutes,
                secondRecurrence:
                    existingLesson.recurrence,
                secondRecurrenceEndDate:
                    existingLesson.recurrenceEndDate
            ) {
                return existingLesson
            }
        }

        return nil
    }
    
    // checks whether two lesson schedules ever overlap
    private func schedulesConflict(
        firstStart: Date,
        firstDurationMinutes: Int,
        firstRecurrence: LessonRecurrence,
        firstRecurrenceEndDate: Date?,
        secondStart: Date,
        secondDurationMinutes: Int,
        secondRecurrence: LessonRecurrence,
        secondRecurrenceEndDate: Date?
    ) -> Bool {

        // both lessons are one-off lessons
        if firstRecurrence == .none &&
            secondRecurrence == .none {

            return timesOverlap(
                firstStart: firstStart,
                firstDurationMinutes:
                    firstDurationMinutes,
                secondStart: secondStart,
                secondDurationMinutes:
                    secondDurationMinutes
            )
        }

        /*
         Weekly schedules repeat every seven days.

         Once both schedules have started, checking a little
         over one week is enough to determine whether their
         repeating patterns can overlap.
         */

        let comparisonStart =
            max(
                firstStart,
                secondStart
            )

        let longestDurationMinutes =
            max(
                firstDurationMinutes,
                secondDurationMinutes
            )

        // starts slightly before the comparison point so
        // lessons crossing midnight are still detected
        let searchStart =
            comparisonStart.addingTimeInterval(
                -TimeInterval(
                    longestDurationMinutes * 60
                )
            )

        guard let searchEnd =
            Calendar.current.date(
                byAdding: .day,
                value: 8,
                to: comparisonStart
            )
        else {
            return false
        }

        let firstOccurrences =
            occurrenceStarts(
                startingDate: firstStart,
                recurrence: firstRecurrence,
                recurrenceEndDate:
                    firstRecurrenceEndDate,
                from: searchStart,
                through: searchEnd
            )

        let secondOccurrences =
            occurrenceStarts(
                startingDate: secondStart,
                recurrence: secondRecurrence,
                recurrenceEndDate:
                    secondRecurrenceEndDate,
                from: searchStart,
                through: searchEnd
            )

        for firstOccurrence in firstOccurrences {

            for secondOccurrence in secondOccurrences {

                if timesOverlap(
                    firstStart: firstOccurrence,
                    firstDurationMinutes:
                        firstDurationMinutes,
                    secondStart: secondOccurrence,
                    secondDurationMinutes:
                        secondDurationMinutes
                ) {
                    return true
                }
            }
        }

        return false
    }


    // creates only the occurrence dates needed
    // for the small conflict-checking window
    private func occurrenceStarts(
        startingDate: Date,
        recurrence: LessonRecurrence,
        recurrenceEndDate: Date?,
        from searchStart: Date,
        through searchEnd: Date
    ) -> [Date] {

        let calendar = Calendar.current

        switch recurrence {

        case .none:

            if startingDate >= searchStart &&
                startingDate <= searchEnd {

                return [startingDate]
            }

            return []


        case .weekly:

            var occurrences: [Date] = []

            var occurrence = startingDate

            // moves forward one week at a time until
            // reaching the conflict-checking window
            while occurrence < searchStart {

                guard let nextOccurrence =
                    calendar.date(
                        byAdding: .weekOfYear,
                        value: 1,
                        to: occurrence
                    )
                else {
                    return occurrences
                }

                occurrence = nextOccurrence
            }

            while occurrence <= searchEnd {

                // stops once the recurrence end date
                // has been passed
                if let recurrenceEndDate {

                    let occurrenceDay =
                        calendar.startOfDay(
                            for: occurrence
                        )

                    let endDay =
                        calendar.startOfDay(
                            for: recurrenceEndDate
                        )

                    if occurrenceDay > endDay {
                        break
                    }
                }

                occurrences.append(
                    occurrence
                )

                guard let nextOccurrence =
                    calendar.date(
                        byAdding: .weekOfYear,
                        value: 1,
                        to: occurrence
                    )
                else {
                    break
                }

                occurrence = nextOccurrence
            }

            return occurrences
        }
    }


    // checks whether two individual lesson times overlap
    private func timesOverlap(
        firstStart: Date,
        firstDurationMinutes: Int,
        secondStart: Date,
        secondDurationMinutes: Int
    ) -> Bool {

        let firstEnd =
            firstStart.addingTimeInterval(
                TimeInterval(
                    firstDurationMinutes * 60
                )
            )

        let secondEnd =
            secondStart.addingTimeInterval(
                TimeInterval(
                    secondDurationMinutes * 60
                )
            )

        return firstStart < secondEnd &&
            firstEnd > secondStart
    }
}
