//
//  TeacherCalendarViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine


final class TeacherCalendarViewModel: ObservableObject {

    @Published var practiceTasks: [PracticeTask] = []
    @Published var resources: [Resource] = []
    
    @Published var lessons: [Lesson] = []
    @Published var students: [User] = []
    
    private let saveLessonToCloudUseCase: SaveLessonToCloudUseCase


    private let lessonRepository: LessonRepository
    private let userRepository: UserRepository
    
    private let practiceTaskRepository: PracticeTaskRepository
    private let resourceRepository: ResourceRepository
    
    private let scheduleLessonUseCase: ScheduleLessonUseCase
    
    // creates the view model with access to lesson, user, practice task and resource data
    init(
        lessonRepository: LessonRepository,
        userRepository: UserRepository,
        practiceTaskRepository: PracticeTaskRepository,
        resourceRepository: ResourceRepository
    ) {

        self.lessonRepository = lessonRepository
        self.userRepository = userRepository
        self.practiceTaskRepository =
            practiceTaskRepository
        self.resourceRepository =
            resourceRepository
        self.scheduleLessonUseCase =
            ScheduleLessonUseCase(
                lessonRepository: lessonRepository
            )
        
        self.saveLessonToCloudUseCase =
            SaveLessonToCloudUseCase(
                lessonRepository: SupabaseLessonRepository(),
                userRepository: SupabaseUserRepository()
            )
    }


    // loads the teacher's students, lessons, practice tasks and resources
    func loadData(
        teacherID: UUID
    ) {

        students =
            userRepository.getStudents()

        lessons =
            lessonRepository
                .getLessons(
                    forTeacherID: teacherID
                )
                .sorted {
                    $0.date < $1.date
                }
        
        practiceTasks =
            practiceTaskRepository
                .getAllTasks()
                .filter {
                    $0.teacherID == teacherID
                }

        resources =
            resourceRepository
                .getResources(
                    forTeacherID: teacherID
                )
        
        updateWidgetData()
    }
    
    // updates the shared widget with the teacher's upcoming lesson occurrences
    private func updateWidgetData() {

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
    }

    // schedules one or more lessons locally and saves them to Supabase
    func addLesson(
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
    ) async throws {

        guard let student =
            students.first(where: {
                $0.id == studentID
            })
        else {
            return
        }

        // stores existing lesson IDs so newly created lessons can be identified
        let existingLessonIDs =
            Set(
                lessons.map {
                    $0.id
                }
            )

        try scheduleLessonUseCase.execute(
            title: title,
            date: date,
            durationMinutes: durationMinutes,
            location: location,
            notes: notes,
            studentID: studentID,
            teacherID: teacherID,
            recurrence: recurrence,
            recurrenceEndDate: recurrenceEndDate,
            allowConflict: allowConflict
        )

        loadData(
            teacherID: teacherID
        )

        // finds the lessons that were just created
        let newLessons =
            lessons.filter {
                !existingLessonIDs.contains($0.id)
            }

        // saves each new lesson to Supabase
        for lesson in newLessons {

            try await saveLessonToCloudUseCase.execute(
                lesson: lesson,
                studentEmail: student.email
            )
        }
    }
    
    // checks for lesson conflicts through the scheduling use case
    func conflictingLesson(
        startingDate: Date,
        durationMinutes: Int,
        teacherID: UUID,
        recurrence: LessonRecurrence = .none,
        recurrenceEndDate: Date? = nil,
        excludingLessonID: UUID? = nil
    ) -> Lesson? {

        scheduleLessonUseCase.conflictingLesson(
            startingDate: startingDate,
            durationMinutes: durationMinutes,
            teacherID: teacherID,
            recurrence: recurrence,
            recurrenceEndDate: recurrenceEndDate,
            excludingLessonID: excludingLessonID
        )
    }
    

    // finds the student assigned to a specific lesson
    func studentForLesson(
        _ lesson: Lesson
    ) -> User? {

        students.first {
            $0.id == lesson.studentID
        }
    }
    

    // finds practice tasks linked to a specific lesson
    func practiceTasksForLesson(
        _ lesson: Lesson
    ) -> [PracticeTask] {

        practiceTasks.filter {
            $0.lessonID == lesson.id
        }
    }

    // finds resources linked to a specific lesson
    func resourcesForLesson(
        _ lesson: Lesson
    ) -> [Resource] {

        resources.filter {
            $0.lessonID == lesson.id
        }
    }
    
   
    // updates an existing lesson locally and in Supabase
    func updateLesson(
        _ lesson: Lesson,
        title: String,
        date: Date,
        durationMinutes: Int,
        location: String,
        notes: String,
        recurrence: LessonRecurrence,
        recurrenceEndDate: Date?,
        teacherID: UUID
    ) async throws {

        guard let student =
            students.first(where: {
                $0.id == lesson.studentID
            })
        else {
            return
        }

        lesson.title = title
        lesson.date = date
        lesson.durationMinutes = durationMinutes
        lesson.location = location
        lesson.notes = notes
        lesson.recurrence = recurrence

        lesson.recurrenceEndDate =
            recurrence == .weekly
                ? recurrenceEndDate
                : nil

        lessonRepository.updateLesson(
            lesson
        )

        try await saveLessonToCloudUseCase.update(
            lesson: lesson,
            studentEmail: student.email
        )

        loadData(
            teacherID: teacherID
        )
    }
    
    // deletes a lesson locally and from Supabase
    func deleteLesson(
        _ lesson: Lesson,
        teacherID: UUID
    ) async throws {

        let linkedResources =
            resources.filter {
                $0.lessonID == lesson.id
            }

        let linkedTasks =
            practiceTasks.filter {
                $0.lessonID == lesson.id
            }

        // deletes the cloud lesson before removing the local data
        try await saveLessonToCloudUseCase.delete(
            lessonID: lesson.id
        )

        // deletes attached files and resource records
        for resource in linkedResources {

            do {

                try ResourceFileStorage.deleteFile(
                    resourceID: resource.id,
                    fileName: resource.fileName
                )

            } catch {

                print(
                    "Failed to delete resource file: \(error)"
                )
            }

            resourceRepository.deleteResource(
                resource
            )
        }

        // deletes linked practice tasks
        for task in linkedTasks {

            practiceTaskRepository.deleteTask(
                task
            )
        }

        lessonRepository.deleteLesson(
            lesson
        )

        loadData(
            teacherID: teacherID
        )
    }
}

