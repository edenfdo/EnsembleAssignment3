//
//  LessonCalendarView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 13/9/2026.
//

import SwiftUI

struct LessonCalendarView: View {

    @Binding var selectedDate: Date
    @Binding var displayedMonth: Date

    let lessons: [Lesson]

    private let calendar =
        Calendar.current

    private let weekdaySymbols = [
        "M",
        "T",
        "W",
        "T",
        "F",
        "S",
        "S"
    ]

    var body: some View {

        VStack(
            spacing: 16
        ) {

            HStack {

                Button {

                    changeMonth(
                        by: -1
                    )

                } label: {

                    Image(
                        systemName: "chevron.left"
                    )
                    .font(.headline)
                }

                Spacer()

                Text(
                    monthTitle
                )
                .font(.title3)
                .fontWeight(.semibold)

                Spacer()

                Button {

                    changeMonth(
                        by: 1
                    )

                } label: {

                    Image(
                        systemName: "chevron.right"
                    )
                    .font(.headline)
                }
            }

            HStack {

                ForEach(
                    weekdaySymbols,
                    id: \.self
                ) { day in

                    Text(
                        day
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(
                        maxWidth: .infinity
                    )
                }
            }

            LazyVGrid(
                columns: calendarColumns,
                spacing: 12
            ) {

                ForEach(
                    calendarDays.indices,
                    id: \.self
                ) { index in

                    if let date =
                        calendarDays[index] {

                        calendarDay(
                            date
                        )

                    } else {

                        Color.clear
                            .frame(
                                width: 38,
                                height: 38
                            )
                    }
                }
            }
        }
        .padding()
        .background(
            .gray.opacity(0.08)
        )
        .cornerRadius(14)
    }

    // creates the button and styling for a single calendar day
    private func calendarDay(
        _ date: Date
    ) -> some View {

        let today =
            calendar.isDateInToday(
                date
            )

        let selected =
            calendar.isDate(
                date,
                inSameDayAs:
                    selectedDate
            )

        let hasLesson =
            lessons.contains {

                calendar.isDate(
                    $0.date,
                    inSameDayAs:
                        date
                )
            }

        return Button {

            selectedDate = date

        } label: {

            Text(
                "\(calendar.component(.day, from: date))"
            )
            .fontWeight(
                selected
                ? .semibold
                : .regular
            )
            .foregroundStyle(
                today
                ? Color.white
                : Color.primary
            )
            .frame(
                width: 38,
                height: 38
            )
            .background {

                if today {
                    Circle()
                        .fill(
                            Color(
                                red: 183 / 255,
                                green: 41 / 255,
                                blue: 41 / 255
                            )
                        )
                } else if hasLesson {

                    Circle()
                        .fill(
                            Color.blue.opacity(
                                0.18
                            )
                        )
                }
            }
            .clipShape(
                Circle()
            )
            .overlay {

                if selected {

                    Circle()
                        .stroke(
                            Color.blue,
                            lineWidth: 2
                        )
                }
            }
        }
        .buttonStyle(.plain)
    }



    // formats the displayed month and year for the calendar heading
    private var monthTitle:
        String {

        displayedMonth.formatted(
            .dateTime
                .month(.wide)
                .year()
        )
    }

    // creates seven flexible columns for the days of the week
    private var calendarColumns:
        [GridItem] {

        Array(
            repeating:
                GridItem(
                    .flexible()
                ),
            count: 7
        )
    }

    // builds the dates for the displayed month with empty spaces before the first day
    private var calendarDays:
        [Date?] {

        guard let monthInterval =
            calendar.dateInterval(
                of: .month,
                for: displayedMonth
            )
        else {

            return []
        }

        let firstDay =
            monthInterval.start

        guard let numberOfDays =
            calendar.range(
                of: .day,
                in: .month,
                for: firstDay
            )?.count
        else {

            return []
        }

        let weekday =
            calendar.component(
                .weekday,
                from: firstDay
            )

        // adjusts the leading empty days so the calendar starts on Monday
        let leadingEmptyDays =
            (weekday + 5) % 7

        var days: [Date?] =
            Array(
                repeating: nil,
                count:
                    leadingEmptyDays
            )

        for day in
            0..<numberOfDays {

            if let date =
                calendar.date(
                    byAdding: .day,
                    value: day,
                    to: firstDay
                ) {

                days.append(
                    date
                )
            }
        }

        return days
    }


    // moves the calendar forward or backward by the given number of months
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(
            byAdding: .month,
            value: value,
            to: displayedMonth
        ) {
            displayedMonth = newMonth
            selectedDate = newMonth
        }
    }
}
