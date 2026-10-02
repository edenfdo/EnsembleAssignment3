//
//  TeacherPracticeViewModel.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import Combine

final class TeacherPracticeViewModel: ObservableObject {

    @Published var tasks: [PracticeTask] = []
    @Published var students: [User] = []
    @Published var lessons: [Lesson] = []

    private let practiceTaskRepository: PracticeTaskRepository
    private let userRepository: UserRepository
    private let lessonRepository: LessonRepository
    
    private let assignPracticeTaskUseCase: AssignPracticeTaskUseCase

    
    private let savePracticeTaskToCloudUseCase:
        SavePracticeTaskToCloudUseCase
    // creates the view model with access to practice task, user and lesson data
    init(
        practiceTaskRepository: PracticeTaskRepository,
        userRepository: UserRepository,
        lessonRepository: LessonRepository
    ) {
        self.practiceTaskRepository = practiceTaskRepository
        self.userRepository = userRepository
        self.lessonRepository = lessonRepository
        self.assignPracticeTaskUseCase =
            AssignPracticeTaskUseCase(
                practiceTaskRepository: practiceTaskRepository,
                lessonRepository: lessonRepository
            )
        
        self.savePracticeTaskToCloudUseCase =
            SavePracticeTaskToCloudUseCase(
                practiceTaskRepository:
                    SupabasePracticeTaskRepository(),
                userRepository:
                    SupabaseUserRepository(),
                lessonRepository:
                    SupabaseLessonRepository()
            )
    }

    // loads the teacher's students, lessons and practice tasks
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

        tasks =
            practiceTaskRepository
                .getAllTasks()
                .filter {
                    $0.teacherID == teacherID
                }
    }

    // assigns a practice task locally and saves it to Supabase
    func assignTask(
        title: String,
        description: String,
        studentID: UUID,
        teacherID: UUID,
        lessonID: UUID,
        dueDate: Date?
    ) async throws {

        guard let student =
            students.first(where: {
                $0.id == studentID
            })
        else {
            return
        }

        // stores existing task IDs so the new task can be identified
        let existingTaskIDs =
            Set(
                tasks.map {
                    $0.id
                }
            )

        try assignPracticeTaskUseCase.execute(
            title: title,
            description: description,
            studentID: studentID,
            teacherID: teacherID,
            lessonID: lessonID,
            dueDate: dueDate
        )

        loadData(
            teacherID: teacherID
        )

        // finds the task that was just created
        guard let newTask =
            tasks.first(where: {
                !existingTaskIDs.contains($0.id)
            })
        else {
            return
        }

        try await savePracticeTaskToCloudUseCase.execute(
            task: newTask,
            studentEmail: student.email
        )
    }

    // finds the student assigned to a specific practice task
    func studentForTask(
        _ task: PracticeTask
    ) -> User? {

        students.first {
            $0.id == task.studentID
        }
    }

    // finds lessons assigned to a specific student
    func lessonsForStudent(
        studentID: UUID
    ) -> [Lesson] {

        lessons.filter {
            $0.studentID == studentID
        }
    }
}
