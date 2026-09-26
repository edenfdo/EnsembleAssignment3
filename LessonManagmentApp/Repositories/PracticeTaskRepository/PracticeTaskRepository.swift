//
//  PracticeTaskRepository.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 30/8/2026.
//

import Foundation

protocol PracticeTaskRepository {

    func getAllTasks() -> [PracticeTask]

    func getTasks(forStudentID studentID: UUID) -> [PracticeTask]

    func addTask(_ task: PracticeTask)

    func updateTask(_ task: PracticeTask)
    
    func deleteTask(
        _ task: PracticeTask
    )
}
