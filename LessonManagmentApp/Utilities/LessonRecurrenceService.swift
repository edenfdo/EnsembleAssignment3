//
//  LessonRecurrenceService.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 5/10/2026.
//

import Foundation


enum LessonRecurrenceService {

    // checks whether a lesson occurs on a particular calendar date
    static func occurs(
        lesson: Lesson,
        on date: Date,
        calendar: Calendar = .current
    ) -> Bool {

        let lessonDay =
            calendar.startOfDay(
                for: lesson.date
            )

        let targetDay =
            calendar.startOfDay(
                for: date
            )

        // a recurring lesson cannot occur
        // before its original starting date
        guard targetDay >= lessonDay else {
            return false
        }

        // checks whether the recurrence has already ended
        if let recurrenceEndDate =
            lesson.recurrenceEndDate {

            let endDay =
                calendar.startOfDay(
                    for: recurrenceEndDate
                )

            guard targetDay <= endDay else {
                return false
            }
        }

        switch lesson.recurrence {

        case .none:

            return calendar.isDate(
                lesson.date,
                inSameDayAs: date
            )

        case .weekly:

            let dayDifference =
                calendar.dateComponents(
                    [.day],
                    from: lessonDay,
                    to: targetDay
                ).day ?? 0

            return dayDifference % 7 == 0
        }
    }
    
    // finds the next occurrence of a lesson
    // on or after the given date
    static func nextOccurrenceDate(
        for lesson: Lesson,
        onOrAfter date: Date,
        calendar: Calendar = .current
    ) -> Date? {

        switch lesson.recurrence {

        case .none:

            return lesson.date >= date
                ? lesson.date
                : nil


        case .weekly:

            var occurrence = lesson.date

            // moves through weekly occurrences
            // until reaching the next upcoming one
            while occurrence < date {

                guard let nextOccurrence =
                    calendar.date(
                        byAdding: .weekOfYear,
                        value: 1,
                        to: occurrence
                    )
                else {
                    return nil
                }

                occurrence = nextOccurrence
            }

            // checks whether the recurring series
            // has already ended
            if let recurrenceEndDate =
                lesson.recurrenceEndDate {

                let occurrenceDay =
                    calendar.startOfDay(
                        for: occurrence
                    )

                let endDay =
                    calendar.startOfDay(
                        for: recurrenceEndDate
                    )

                if occurrenceDay > endDay {
                    return nil
                }
            }

            return occurrence
        }
    }
    
    // returns the actual occurrence date and time
    // for a lesson on a specific calendar day
    static func occurrenceDate(
        for lesson: Lesson,
        on date: Date,
        calendar: Calendar = .current
    ) -> Date? {

        guard occurs(
            lesson: lesson,
            on: date,
            calendar: calendar
        ) else {
            return nil
        }

        let dayComponents =
            calendar.dateComponents(
                [.year, .month, .day],
                from: date
            )

        let timeComponents =
            calendar.dateComponents(
                [.hour, .minute, .second],
                from: lesson.date
            )

        var components = DateComponents()

        components.year = dayComponents.year
        components.month = dayComponents.month
        components.day = dayComponents.day

        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second

        return calendar.date(
            from: components
        )
    }
    
    // returns a limited number of upcoming occurrences
    // for a lesson, used by the widget
    static func upcomingOccurrenceDates(
        for lesson: Lesson,
        onOrAfter date: Date,
        limit: Int,
        calendar: Calendar = .current
    ) -> [Date] {

        guard limit > 0 else {
            return []
        }

        switch lesson.recurrence {

        case .none:

            guard lesson.date >= date else {
                return []
            }

            return [lesson.date]


        case .weekly:

            guard var occurrence =
                nextOccurrenceDate(
                    for: lesson,
                    onOrAfter: date,
                    calendar: calendar
                )
            else {
                return []
            }

            var occurrences: [Date] = []

            while occurrences.count < limit {

                // stops once the recurrence end date
                // has been passed
                if let recurrenceEndDate =
                    lesson.recurrenceEndDate {

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
}
