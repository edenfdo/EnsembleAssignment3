# Ensemble

Ensemble is an iOS music lesson management application designed to connect music lessons with students’ independent practice. It allows teachers to manage lessons, practice tasks and learning resources while giving students a central place to access their assigned work and lesson information.

## Features

### Teacher

- Create and manage student accounts.
- Schedule, edit and delete lessons.
- Create recurring weekly lessons.
- Assign practice tasks to students.
- Upload and share learning resources.
- View student task completion.
- Access upcoming lesson information through a Home Screen widget.

### Student

- View upcoming lessons and lesson information.
- View and complete assigned practice tasks.
- Access learning resources shared by their teacher.
- Complete quizzes.
- Receive reminders for upcoming practice-task deadlines.
- View upcoming lesson information through a Home Screen widget.

## Architecture

Ensemble uses a hybrid architecture combining local SwiftData persistence with Supabase for authentication, shared cloud data and resource storage. Repository protocols separate the domain layer from the underlying persistence implementation, while use cases contain application-specific business rules.

```text
┌──────────────────────┐
│     SwiftUI Views    │
│ Teacher / Student UI │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│      ViewModels      │
│ UI state + actions   │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│      Use Cases       │
│   Business rules     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Repository Protocols │
└──────────┬───────────┘
           │
      ┌────┴────┐
      ▼         ▼
┌───────────┐  ┌─────────────┐
│ SwiftData │  │  Supabase   │
│   Local   │  │ Cloud/Auth  │
└───────────┘  └─────────────┘
```

SwiftData maintains local copies of application data used by the interface, while Supabase enables data to be shared and synchronised between teacher and student accounts on separate devices. Supabase Edge Functions are used for operations requiring privileged server-side functionality, such as student account creation.

## Domain Use Cases

| Use Case | Responsibility |
| --- | --- |
| `ScheduleLessonUseCase` | Schedules a lesson while validating its title, duration and potential scheduling conflicts. |
| `AssignPracticeTaskUseCase` | Creates a practice task for an existing lesson and ensures its due date occurs after the lesson. |
| `AddStudentUseCase` | Validates student details, including required names, email format and duplicate email addresses, before account creation. |
| `SaveLessonToCloudUseCase` | Converts a locally created lesson into its cloud representation and saves it for the relevant teacher and student. |
| `ChangePasswordUseCase` | Handles the required student password change while validating and updating the authenticated account. |

Domain-specific errors are used to communicate validation failures back to the interface in a human-readable form.

## System Extensions

| Extension | Purpose |
| --- | --- |
| **WidgetKit Extension** | Displays upcoming lesson information directly on the Home Screen. The widget adapts to the logged-in account, displaying student information for teachers and teacher information for students, and supports both small and medium widget families. |
| **Notification Content Extension** | Provides a customised expanded interface for practice-task reminders. Students receive a reminder before an incomplete task is due and can expand the notification to view additional task information. |

The WidgetKit extension receives lesson information through a shared App Group container, allowing the main application and widget extension to access the required shared data.

## Project Structure

```text
LessonManagmentApp/
│
├── Models/
│   ├── User
│   ├── Lesson
│   ├── PracticeTask
│   └── Resource
│
├── Views/
│   ├── Authentication
│   ├── Teacher
│   ├── Student
│   ├── Lessons
│   ├── Practice Tasks
│   └── Resources
│
├── ViewModels/
│   ├── RootViewModel
│   ├── LoginViewModel
│   ├── TeacherCalendarViewModel
│   └── Student / Teacher ViewModels
│
├── UseCases/
│   ├── ScheduleLessonUseCase
│   ├── AssignPracticeTaskUseCase
│   ├── AddStudentUseCase
│   ├── SaveLessonToCloudUseCase
│   └── ChangePasswordUseCase
│
├── Repositories/
│   ├── Repository Protocols
│   ├── Local SwiftData Repositories
│   └── Supabase Repositories
│
├── Services/
│   ├── SupabaseService
│   └── NotificationService
│
├── Widget Extension/
│   └── Upcoming Lesson Widget
│
├── Notification Content Extension/
│   └── Custom Practice Task Notification
│
└── LessonManagmentAppTests/
    ├── Use Case Tests
    └── MockRepositories
```

## Requirements

- macOS
- Xcode
- iOS Simulator or compatible iOS device

## Running the Project

1. Clone the repository:

   ```bash
   git clone <repository-url>
   ```

2. Open `LessonManagmentApp.xcodeproj` in Xcode.

3. Select the **LessonManagmentApp** scheme.

4. Select an iOS Simulator or connected iOS device.

5. Build and run the application using **⌘R**.

6. Run the unit tests using **⌘U**.
