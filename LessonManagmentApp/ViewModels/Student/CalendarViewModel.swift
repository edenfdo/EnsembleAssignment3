//
//  CalendarViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 6/9/2026.
//

import Foundation
import Combine

class CalendarViewModel: ObservableObject {

    @Published var lessons: [Lesson] = []
    @Published var selectedDate: Date = Date()
    
    @Published var practiceTasks: [PracticeTask] = []
    @Published var resources: [Resource] = []
    @Published var teachers: [User] = []
    
    private let syncStudentLessonsUseCase: SyncStudentLessonsUseCase

    private let practiceTaskRepository: PracticeTaskRepository
    private let resourceRepository: ResourceRepository
    private let userRepository: UserRepository

    private let lessonRepository: LessonRepository

    // creates the view model with access to lesson, practice task and resource data
    init(
        lessonRepository: LessonRepository,
        practiceTaskRepository: PracticeTaskRepository,
        resourceRepository: ResourceRepository,
        userRepository: UserRepository
    ) {
        self.lessonRepository = lessonRepository
        self.practiceTaskRepository = practiceTaskRepository
        self.resourceRepository = resourceRepository
        self.userRepository = userRepository
        
        self.syncStudentLessonsUseCase =
            SyncStudentLessonsUseCase(
                cloudLessonRepository: SupabaseLessonRepository(),
                cloudUserRepository: SupabaseUserRepository(),
                localLessonRepository: lessonRepository,
                localUserRepository: userRepository
            )
    }

    // syncs cloud lessons before loading the student's local calendar data
    func syncLessons(
        studentID: UUID
    ) async {

        do {

            try await syncStudentLessonsUseCase.execute(
                localStudentID: studentID
            )

            loadData(
                studentID: studentID
            )

        } catch {

            print(
                "Failed to sync student lessons: \(error)"
            )

            // still loads existing local data if cloud sync fails
            loadData(
                studentID: studentID
            )
        }
    }
    
    // loads the student's lessons, practice tasks and resources
    func loadData(
        studentID: UUID
    ) {

        lessons =
            lessonRepository
                .getLessons(
                    forStudentID: studentID
                )

        practiceTasks =
            practiceTaskRepository
                .getTasks(
                    forStudentID: studentID
                )

        resources =
            resourceRepository
                .getResources(
                    forStudentID: studentID
                )
        
        teachers =
            userRepository
                .getTeachers()
        
        updateWidgetData()
    }
    
    // updates the shared widget with the student's lessons
    private func updateWidgetData() {

        let widgetLessons =
            lessons.map { lesson in

                let teacherName =
                    teachers.first {
                        $0.id == lesson.teacherID
                    }?.name
                    ?? "Teacher"

                return WidgetLessonData(
                    id: lesson.id,
                    title: lesson.title,
                    date: lesson.date,
                    durationMinutes: lesson.durationMinutes,
                    personName: teacherName,
                    location: lesson.location
                )
            }

        WidgetDataService.save(
            role: "student",
            lessons: widgetLessons
        )
    }

    // finds lessons that occur on the selected date
    func lessons(for date: Date) -> [Lesson] {

        lessons.filter { lesson in
            Calendar.current.isDate(
                lesson.date,
                inSameDayAs: date
            )
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
    
    // toggles a task's completion status and saves the change
    func toggleTaskCompletion(
        _ task: PracticeTask
    ) {

        task.isCompleted.toggle()

        practiceTaskRepository.updateTask(
            task
        )
    }
}
