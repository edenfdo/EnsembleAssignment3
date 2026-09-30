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
    
    // updates the shared widget with the teacher's lessons
    private func updateWidgetData() {

        let widgetLessons =
            lessons.map { lesson in

                let studentName =
                    students.first {
                        $0.id == lesson.studentID
                    }?.name
                    ?? "Student"

                return WidgetLessonData(
                    id: lesson.id,
                    title: lesson.title,
                    date: lesson.date,
                    durationMinutes: lesson.durationMinutes,
                    personName: studentName,
                    location: lesson.location
                )
            }

        WidgetDataService.save(
            role: "teacher",
            lessons: widgetLessons
        )
    }

    // schedules one or more lessons through the scheduling use case
    func addLesson(
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

        try scheduleLessonUseCase.execute(
            title: title,
            date: date,
            durationMinutes: durationMinutes,
            location: location,
            notes: notes,
            studentID: studentID,
            teacherID: teacherID,
            repeatOption: repeatOption,
            numberOfLessons: numberOfLessons,
            allowConflict: allowConflict
        )

        loadData(
            teacherID: teacherID
        )
    }
    
    // checks for lesson conflicts through the scheduling use case
    func conflictingLesson(
        startingDate: Date,
        durationMinutes: Int,
        teacherID: UUID,
        repeatOption: LessonRepeatOption,
        numberOfLessons: Int,
        excludingLessonID: UUID? = nil
    ) -> Lesson? {

        scheduleLessonUseCase.conflictingLesson(
            startingDate: startingDate,
            durationMinutes: durationMinutes,
            teacherID: teacherID,
            repeatOption: repeatOption,
            numberOfLessons: numberOfLessons,
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
    
   
    // updates an existing lesson and reloads the teacher's calendar data
    func updateLesson(
        _ lesson: Lesson,
        title: String,
        date: Date,
        durationMinutes: Int,
        location: String,
        notes: String,
        teacherID: UUID
    ) {

        lesson.title = title
        lesson.date = date
        lesson.durationMinutes = durationMinutes
        lesson.location = location
        lesson.notes = notes

        lessonRepository.updateLesson(
            lesson
        )

        loadData(
            teacherID: teacherID
        )
    }
    
    // deletes a lesson and any practice tasks or resources linked to it
    func deleteLesson(
        _ lesson: Lesson,
        teacherID: UUID
    ) {

        let linkedResources =
            resources.filter {
                $0.lessonID == lesson.id
            }

        let linkedTasks =
            practiceTasks.filter {
                $0.lessonID == lesson.id
            }

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

        // deletes the lesson itself
        lessonRepository.deleteLesson(
            lesson
        )

        // reloads the teacher's calendar data
        loadData(
            teacherID: teacherID
        )
    }
}

