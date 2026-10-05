# Ensemble — Music Lesson Management App

Ensemble is an iOS music lesson management application designed to help music teachers and students manage lessons, practice tasks, resources and progress in one centralised place.

The application provides separate teacher and student experiences, allowing teachers to organise lesson-related information while giving students easy access to their upcoming lessons and assigned work.

## Features

### Teacher

- Create and manage student accounts
- Schedule lessons for students
- Schedule one-off or weekly recurring lessons
- Detect scheduling conflicts between lessons
- View upcoming lessons through the teacher calendar
- Assign practice tasks linked to lessons
- Manage lesson resources
- View individual student information

### Student

- Sign in using an account created by their teacher
- Change the temporary password on first login
- View upcoming lessons
- View teacher information associated with lessons
- View and complete assigned practice tasks
- Access lesson resources
- Receive reminders for upcoming practice-task deadlines

## Technologies

The application is built using:

- Swift
- SwiftUI
- SwiftData
- Supabase
- WidgetKit
- UserNotifications
- Notification Content Extension
- Lottie

SwiftData is used for local application data, while Supabase provides cloud data synchronisation and authentication between teacher and student accounts.

## Architecture

Ensemble separates the user interface, business rules and data-access logic using models, repositories, use cases and view models.

The general application flow is:

```text
SwiftUI Views
      ↓
ViewModels
      ↓
Use Cases
      ↓
Repository Protocols
      ↓
Local / Supabase Repositories
      ↓
SwiftData / Supabase
```

Repository protocols allow the application's data source to be replaced without changing the domain logic.

For example, production code can use:

```text
ScheduleLessonUseCase
        ↓
LessonRepository
        ↓
LocalLessonRepository
        ↓
SwiftData
```

while unit tests can use:

```text
ScheduleLessonUseCase
        ↓
LessonRepository
        ↓
MockLessonRepository
        ↓
In-memory test data
```

## Domain Use Cases

Business rules are separated into dedicated Use Case structures.

Examples include:

### ScheduleLessonUseCase

Handles lesson scheduling and validates:

- A lesson has a title
- Lesson duration is valid
- A teacher does not have conflicting lessons
- Lessons can begin exactly when another lesson ends
- Recurring weekly lesson conflicts are detected

### AssignPracticeTaskUseCase

Handles practice-task assignment and validates:

- A task has a title
- The linked lesson exists
- The task due date occurs after the linked lesson

### AddStudentUseCase

Validates student information before an account is created, including:

- Student name
- Email format
- Duplicate email addresses

Domain-specific errors are used so validation failures can be presented to users with meaningful messages.

## Data Persistence

The application uses a combination of SwiftData and Supabase.

### SwiftData

SwiftData provides the local data layer used by the application's repository implementations.

Core domain models include:

- User
- Lesson
- PracticeTask
- Resource

Relationships between these models allow lessons, practice tasks and resources to be associated with the appropriate teacher and student.

### Supabase

Supabase is used for:

- Authentication
- Teacher and student accounts
- Cloud data storage
- Synchronisation between teacher and student devices
- Edge Functions for secure account operations

When a teacher creates a student account, a temporary password is generated. The student is required to replace this password after their first login.

## Repository Pattern

Data access is abstracted using repository protocols, including:

- LessonRepository
- PracticeTaskRepository
- UserRepository
- ResourceRepository

Production implementations provide access to the application's persisted data.

For unit testing, these repositories can be replaced with:

- MockLessonRepository
- MockPracticeTaskRepository
- MockUserRepository
- MockResourceRepository

This allows business logic to be tested independently of the real persistence stack.

## System Extensions

The application implements two iOS system extensions.

### WidgetKit Widget Extension

The Ensemble widget displays upcoming lesson information without requiring the user to open the main application.

The widget:

- Reads shared lesson information using an App Group shared container
- Displays upcoming lesson information
- Supports teacher and student contexts
- Supports `.systemSmall`
- Supports `.systemMedium`
- Refreshes when relevant lesson data changes

### Notification Content Extension

A Notification Content Extension provides a custom expanded interface for practice-task reminders.

When an eligible practice task approaches its due date, the student receives a local notification. Pressing and holding the notification displays the custom notification interface containing additional task information.

The extension uses the `PRACTICE_TASK_DUE` notification category to identify supported notifications.

## Unit Testing

Unit tests are implemented using Swift Testing.

The test suite uses mock repository implementations rather than the application's real persistence stack.

The current suite contains 9 unit tests covering:

- Successful lesson scheduling
- Lesson scheduling conflicts
- Lesson scheduling boundary conditions
- Successful practice-task assignment
- Invalid practice-task due dates
- Practice-task due-date boundary conditions
- Invalid student email validation
- Duplicate student email validation
- Repository filtering behaviour

The tests cover successful operations, domain errors and boundary conditions.

Tests can be run in Xcode using:

```text
⌘U
```

## Project Structure

```text
LessonManagmentApp
│
├── Models
├── Repositories
├── UseCases
├── ViewModels
├── Views
├── Services
├── Animation
│
├── LessonManagmentAppTests
│   ├── LessonManagmentAppTests.swift
│   └── MockRepositories.swift
│
├── LessonWidgetExtension
│
└── PracticeNotificationExtension
```

The exact grouping of source files may vary, but responsibilities are separated between domain models, persistence, business logic and user-interface components.

## Authentication Flow

Student accounts are created by teachers.

The account flow is:

```text
Teacher creates student
        ↓
Supabase Auth account is created
        ↓
Temporary password is generated
        ↓
Student signs in
        ↓
Password change is required
        ↓
Student chooses a new password
        ↓
Normal student experience is displayed
```

Sensitive account operations are handled through Supabase authentication and Edge Functions rather than directly from the client.

## Recurring Lessons

Lessons can be scheduled as either:

- One-off lessons
- Weekly recurring lessons

A recurring lesson is stored as a single lesson containing its recurrence information rather than creating a separate stored record for every occurrence.

The application generates the required occurrence dates when displaying or checking recurring lessons.

Scheduling conflict detection also considers recurring lesson occurrences.

## Notifications

Students can receive local reminders for incomplete practice tasks with upcoming due dates.

Notifications use stable task identifiers so existing pending notifications can be updated or cancelled when required.

Completed or removed tasks should not continue to generate pending reminders.

## Requirements

To run the project:

- macOS with Xcode
- An iOS Simulator or compatible iOS device
- Swift Package dependencies used by the project
- Access to the configured Supabase backend for cloud functionality

## Running the Project

1. Clone the repository.
2. Open `LessonManagmentApp.xcodeproj` in Xcode.
3. Allow Swift Package dependencies to resolve.
4. Select the `LessonManagmentApp` scheme.
5. Select an iOS Simulator or connected device.
6. Build and run the application using `⌘R`.
7. Run the unit test suite using `⌘U`.

Some cloud functionality requires the project's configured Supabase services.

## Author

**Eden Fernando**
