//
//  LessonWidget.swift
//  LessonWidget
//
//  Created by Eden Fernando on 27/9/2026.
//

import WidgetKit
import SwiftUI


struct LessonWidgetEntry: TimelineEntry {

    let date: Date
    let snapshot: WidgetSnapshot?
}


struct Provider: TimelineProvider {

    private let appGroup =
        "group.com.edenfdo.LessonManagmentApp"

    private let dataKey =
        "lessonWidgetData"


    // provides sample data while the widget is loading
    func placeholder(
        in context: Context
    ) -> LessonWidgetEntry {

        LessonWidgetEntry(
            date: .now,
            snapshot: nil
        )
    }


    // provides data for the widget gallery preview
    func getSnapshot(
        in context: Context,
        completion: @escaping (LessonWidgetEntry) -> Void
    ) {

        let entry =
            LessonWidgetEntry(
                date: .now,
                snapshot: loadSnapshot()
            )

        completion(entry)
    }


    // loads shared lesson data and refreshes
    // after the next lesson begins
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<LessonWidgetEntry>) -> Void
    ) {

        let now = Date()

        let snapshot =
            loadSnapshot()

        let entry =
            LessonWidgetEntry(
                date: now,
                snapshot: snapshot
            )

        // finds the closest upcoming occurrence
        let nextLessonDate =
            snapshot?.lessons
                .filter {
                    $0.date >= now
                }
                .map {
                    $0.date
                }
                .min()

        let policy: TimelineReloadPolicy

        if let nextLessonDate {

            // refresh shortly after the lesson begins
            // so the following lesson becomes "Next Lesson"
            let refreshDate =
                nextLessonDate
                    .addingTimeInterval(60)

            policy = .after(refreshDate)

        } else {

            policy = .never
        }

        let timeline =
            Timeline(
                entries: [entry],
                policy: policy
            )

        completion(timeline)
    }


    // loads lesson data from the shared App Group
    private func loadSnapshot() -> WidgetSnapshot? {

        guard let data =
            UserDefaults(
                suiteName:
                    "group.com.edenfdo.LessonManagmentApp"
            )?.data(
                forKey: "lessonWidgetData"
            )
        else {
            return nil
        }

        return try? JSONDecoder()
            .decode(
                WidgetSnapshot.self,
                from: data
            )
    }
}


struct LessonWidgetEntryView: View {

    var entry: Provider.Entry

    @Environment(\.widgetFamily)
    private var family

    private let brandRed =
        Color(
            red: 183 / 255,
            green: 41 / 255,
            blue: 41 / 255
        )


    var body: some View {

        switch family {

        case .systemSmall:
            smallWidget

        case .systemMedium:
            mediumWidget

        default:
            smallWidget
        }
    }


    // displays the next upcoming lesson
    private var smallWidget: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            HStack(spacing: 6) {

                Image(
                    systemName: "music.note"
                )
                .foregroundStyle(brandRed)

                Text("Next Lesson")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }


            if let lesson = nextLesson {

                Text(lesson.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)


                Text(lesson.personName)
                    .font(.caption)
                    .foregroundStyle(.secondary)


               


                HStack(spacing: 5) {

                    Image(
                        systemName: "calendar"
                    )

                    Text(
                        lesson.date,
                        format: .dateTime
                            .day()
                            .month(.abbreviated)
                    )
                }
                .font(.caption)
                .fontWeight(.medium)


                HStack(spacing: 5) {

                    Image(
                        systemName: "clock"
                    )

                    Text(
                        lesson.date,
                        style: .time
                    )
                }
                .font(.caption)


                if !lesson.location.isEmpty {

                    HStack(spacing: 5) {

                        Image(
                            systemName: "location"
                        )

                        Text(lesson.location)
                            .lineLimit(1)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

            } else {

                Spacer()

                Text("No upcoming lessons")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(.top, 8)
        .padding(.bottom, 6)
    }


    // displays the next three upcoming lessons
    private var mediumWidget: some View {

        VStack(
            alignment: .leading,
            spacing: 7
        ) {

            HStack {

                HStack(spacing: 7) {

                    Image(
                        systemName: "music.note"
                    )
                    .foregroundStyle(brandRed)

                    Text(
                        entry.snapshot?.role == "teacher"
                        ? "Upcoming Lessons"
                        : "Your Upcoming Lessons"
                    )
                    .font(.headline)
                    .fontWeight(.bold)
                }

                Spacer()
            }


            if upcomingLessons.isEmpty {

                Spacer()

                HStack {

                    Image(
                        systemName: "calendar"
                    )
                    .foregroundStyle(.secondary)

                    Text("No upcoming lessons")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)

                Spacer()

            } else {

                ForEach(
                    Array(
                        upcomingLessons.prefix(3)
                    )
                ) { lesson in

                    HStack(
                        alignment: .center,
                        spacing: 10
                    ) {

                        // date
                        VStack(spacing: 1) {

                            Text(
                                lesson.date,
                                format: .dateTime
                                    .day()
                            )
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(brandRed)

                            Text(
                                lesson.date,
                                format: .dateTime
                                    .month(.abbreviated)
                            )
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                        .frame(width: 35)


                        // lesson information
                        VStack(
                            alignment: .leading,
                            spacing: 2
                        ) {

                            Text(lesson.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(1)

                            Text(lesson.personName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }


                        Spacer()


                        // lesson time
                        Text(
                            lesson.date,
                            style: .time
                        )
                        .font(.caption)
                        .fontWeight(.medium)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
            
        )
        .padding(.top, 12)
        .padding(.bottom, 8)
    }


    // finds the next upcoming lesson
    private var nextLesson: WidgetLessonData? {

        upcomingLessons.first
    }


    // filters and sorts upcoming lessons by date
    private var upcomingLessons: [WidgetLessonData] {

        guard let lessons =
            entry.snapshot?.lessons
        else {
            return []
        }

        return lessons
            .filter {
                $0.date >= Date()
            }
            .sorted {
                $0.date < $1.date
            }
    }
}


struct LessonWidget: Widget {

    let kind: String =
        "LessonWidget"


    var body: some WidgetConfiguration {

        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in

            LessonWidgetEntryView(
                entry: entry
            )
            .containerBackground(
                .fill.tertiary,
                for: .widget
            )
        }
        .configurationDisplayName(
            "Lessons"
        )
        .description(
            "View your upcoming music lessons."
        )
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
    }
}


#Preview(
    "Lesson - Small",
    as: .systemSmall
) {

    LessonWidget()

} timeline: {

    LessonWidgetEntry(
        date: .now,
        snapshot: nil
    )
}


#Preview(
    "Lesson - Medium",
    as: .systemMedium
) {

    LessonWidget()

} timeline: {

    LessonWidgetEntry(
        date: .now,
        snapshot: nil
    )
}
