# TaskFlow

TaskFlow is a Flutter-based project and task management application designed for organization-based teams.

The application uses a local mock data layer instead of a real backend API. This allows the complete application flow to be demonstrated without requiring external services while keeping the application architecture structured so that the mock data source can later be replaced by a real API implementation.

---

## 1. Project Overview

TaskFlow supports organization-based project and task management.

Users can:

- Sign in using mock credentials
- Maintain a simulated authenticated session
- View their organization information
- View organization projects
- Create projects
- Edit projects
- Delete projects
- View tasks within projects
- Create tasks
- Edit tasks
- Delete tasks
- Assign tasks
- Update task status
- Update task priority
- View notifications
- Mark notifications as read
- Mark all notifications as read
- Delete notifications
- View and manage task comments
- Test simulated error and offline scenarios
- Log out and clear the local session

Organization administrators have additional project-management permissions.

The application intentionally does not use a real backend. The assignment's functionality is implemented using local mock data.

---

## 2. Technology Stack

- Flutter
- Dart
- Provider
- flutter_secure_storage
- shared_preferences
- Material UI

### Versions

- Flutter: 3.24.4
- Dart: 3.8.1

The project's Dart SDK requirement is defined in `pubspec.yaml`.

---

## 3. Architecture

TaskFlow follows a layered architecture that separates the UI, state management, repository, and mock data implementation.

```text
┌───────────────────────────────────┐
│            UI / Screens           │
│                                   │
│ Login / Home / Projects / Tasks   │
│ Notifications / Comments / QA     │
└───────────────────┬───────────────┘
                    │
                    ▼
┌───────────────────────────────────┐
│          Provider Layer           │
│                                   │
│ AuthProvider                      │
│ ProjectProvider                   │
│ TaskProvider                      │
│ CommentProvider                   │
│ NotificationProvider              │
└───────────────────┬───────────────┘
                    │
                    ▼
┌───────────────────────────────────┐
│            Repository             │
│                                   │
│       TaskFlowRepository          │
└───────────────────┬───────────────┘
                    │
                    ▼
┌───────────────────────────────────┐
│          Mock Data Source         │
│                                   │
│          MockDataSource            │
└───────────────────┬───────────────┘
                    │
             ┌──────┴──────┐
             ▼             ▼
       mock-data.json  SharedPreferences
```

### Architecture Responsibilities

#### Presentation Layer

Screens and widgets are responsible for:

- Displaying application state
- Collecting user input
- Triggering provider operations
- Navigation
- Showing loading, empty, and error states

#### Provider Layer

Providers use `ChangeNotifier` and manage feature-specific application state.

Main providers include:

- `AuthProvider`
- `ProjectProvider`
- `TaskProvider`
- `CommentProvider`
- `NotificationProvider`

#### Repository Layer

`TaskFlowRepository` provides an abstraction between providers and the data source.

For example:

```dart
Future<List<ProjectModel>> getProjects(String orgId)
```

The provider does not directly access the mock JSON or local persistence layer.

#### Data Layer

`MockDataSource` handles:

- Loading mock JSON data
- Local persistence
- CRUD operations
- Simulated delays
- Simulated errors
- Offline scenarios

This separation makes it possible to replace the mock data source with a real API implementation later.

---

## 4. Folder Structure

```text
lib/
│
├── core/
│   └── tokens.dart
│
├── data/
│   ├── data_sources/
│   │   └── local/
│   │       ├── mock_data_source.dart
│   │       └── mock_scenario.dart
│   │
│   ├── models/
│   │   ├── auth_model.dart
│   │   ├── comment_model.dart
│   │   ├── notifications_model.dart
│   │   ├── organizations_model.dart
│   │   ├── project_model.dart
│   │   ├── task_model.dart
│   │   └── user_model.dart
│   │
│   └── repositories/
│       └── task_flowrepository.dart
│
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── comment_provider.dart
│   │   ├── notifications_provider.dart
│   │   ├── project_provider.dart
│   │   └── task_provider.dart
│   │
│   └── screens/
│       ├── auth/
│       ├── home/
│       ├── notification/
│       ├── projects/
│       ├── qa/
│       └── tasks/
│
└── main.dart

assets/
└── mock/
    └── mock-data.json

test/
└── widget_test.dart
```

---

## 5. State Management

TaskFlow uses the `Provider` package with `ChangeNotifier`.

Each major feature has its own provider.

### AuthProvider

Manages:

- Login
- Registration
- Logout
- Authentication status
- Access token
- Refresh token
- Token expiry
- User ID
- Email
- Organization ID
- User role
- Session restoration

### ProjectProvider

Manages:

- Project loading
- Project creation
- Project updates
- Project deletion
- Loading state
- Empty state
- Error state

### TaskProvider

Manages:

- Task loading
- Task creation
- Task updates
- Task deletion
- Task assignment
- Task status
- Task priority
- Loading state
- Empty state
- Error state

### CommentProvider

Manages:

- Comment loading
- Comment creation
- Comment updates
- Comment deletion

### NotificationProvider

Manages:

- Notification loading
- Unread notification count
- Mark notification as read
- Mark all notifications as read
- Delete notifications

---

## 6. Mock Data Layer

The assignment intentionally uses a local mock data layer instead of a real backend.

The mock data is stored in:

```text
assets/mock/mock-data.json
```

The JSON contains data for:

- Organizations
- Users
- Organization members
- Projects
- Tasks
- Comments
- Notifications
- Authentication credentials
- Mock login response

The UI never reads the JSON file directly.

The general flow is:

```text
Screen
   ↓
Provider
   ↓
TaskFlowRepository
   ↓
MockDataSource
   ↓
mock-data.json
```

---

## 7. Local Persistence

`shared_preferences` is used to persist mock project and task data locally.

This allows CRUD operations performed during the application session to remain available after the data is saved locally.

The application does not require:

- A backend server
- A remote database
- REST APIs
- External network services

---

## 8. Authentication and Token Flow

Authentication is simulated using the credentials provided in the mock data.

The authentication flow is:

```text
Login Screen
     ↓
AuthProvider
     ↓
TaskFlowRepository
     ↓
Mock Authentication Credentials
     ↓
Mock Login Response
     ↓
Secure Storage
     ↓
flutter_secure_storage
```

After successful login:

1. Credentials are validated against the mock credentials.
2. A mock access token is returned.
3. A mock refresh token is returned.
4. Access-token expiry is calculated.
5. Tokens and expiry are stored securely.
6. User information is loaded.
7. Organization and role information are stored in `AuthProvider`.
8. The user is marked as authenticated.
9. The application navigates to the Home screen.

### Session Restoration

When the application starts, the Splash Screen calls:

```text
AuthProvider.checkSession()
```

The provider checks:

- Access token
- Refresh token
- Access-token expiry
- Saved user email

If a valid session exists, the user is taken to the Home Screen.

Otherwise, the user is taken to the Login Screen.

### Token Expiry

The access token has a simulated expiry period.

When the token expires, `AuthProvider` attempts a simulated session refresh using the refresh token.

---

## 9. Secure Token Storage

The application uses `flutter_secure_storage` for token storage.

Stored values include:

- Access token
- Refresh token
- Access-token expiry
- User email

Logout clears these values.

The secure storage implementation is kept separate from the authentication state management so authentication remains easier to test.

---

## 10. Mock Authentication Credentials

The mock authentication data contains credentials for two organizations.

### Organization A — Nimbus Digital

#### Admin

```text
Email: ava.admin@nimbusdigital.test
Password: Password123!
Role: org_admin
Organization ID: org_a1b2c3
```

#### Member

```text
Email: marcus.member@nimbusdigital.test
Password: Password123!
Role: member
Organization ID: org_a1b2c3
```

### Organization B — Harborlight Studios

#### Admin

```text
Email: daniel.admin@harborlightstudios.test
Password: Password123!
Role: org_admin
Organization ID: org_d4e5f6
```

#### Member

```text
Email: elena.member@harborlightstudios.test
Password: Password123!
Role: member
Organization ID: org_d4e5f6
```

---

## 11. Simulated Error and Offline Scenarios

The mock data source supports:

```dart
enum MockScenario {
  normal,
  offline,
  timeout,
  notFound,
  validationError,
}
```

These scenarios allow reviewers to demonstrate the application's error-handling behavior without requiring a real backend.

### Normal

```text
MockScenario.normal
```

Represents normal application behavior.

### Offline

```text
MockScenario.offline
```

Simulates an unavailable data source.

Expected behavior:

- Data loading fails
- Provider enters an error state
- UI displays the error
- Retry functionality can be demonstrated where available

### Timeout

```text
MockScenario.timeout
```

Simulates a delayed operation followed by a timeout/error.

Expected behavior:

- Mock operation is delayed
- Provider receives an error
- UI displays the error state

### Not Found

```text
MockScenario.notFound
```

Simulates a resource-not-found condition.

Expected behavior:

- Requested operation fails
- Provider enters an error state
- UI displays the appropriate error

### Validation Error

```text
MockScenario.validationError
```

Simulates a validation failure during a write operation.

Expected behavior:

- Create/update operation fails
- Provider receives the error
- UI displays the validation error

### Returning to Normal

After testing an error scenario, switch back to:

```text
MockScenario.normal
```

---

## 12. Loading, Empty, and Error States

The application explicitly handles different data states.

### Loading

Displays a loading indicator while data is being retrieved.

### Empty

Displays an appropriate empty-state message when there is no data.

Examples:

- No projects found
- No tasks found
- No notifications

### Error

Displays an error message and provides retry functionality where applicable.

---

## 13. Role-Based Behavior

TaskFlow supports two roles:

```text
org_admin
member
```

Organization administrators can perform administrative project operations.

Members have restricted permissions.

The role is obtained from the simulated authentication data and stored in `AuthProvider`.

The UI uses the authenticated role to control available actions.

---

## 14. Local Setup

### Requirements

The project uses:

```text
Flutter 3.24.4
Dart 3.8.1
```

Verify Flutter:

```bash
flutter doctor
```

### Install Dependencies

From the project root:

```bash
flutter pub get
```

### Run the Application

```bash
flutter run
```

No backend setup or external service configuration is required.

---

## 15. Automated Testing

Run the test suite:

```bash
flutter test
```

The current automated test suite contains 8 tests covering:

- Project filtering by organization
- Unknown organization handling
- Task filtering by project
- Unknown project handling
- Normal mock-data behavior
- Offline scenario
- Timeout scenario
- Not-found scenario

Current result:

```text
8 tests passed
```

---

## 16. Required Commands

```bash
flutter pub get
flutter run
flutter test
flutter build apk --release
```

---

## 17. Release APK

A release APK has been successfully generated using:

```bash
flutter build apk --release
```

Generated APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

The release build completed successfully.

---

## 18. Reviewer Testing Checklist

### Authentication

- [ ] Login as organization admin
- [ ] Login as organization member
- [ ] Verify organization information
- [ ] Verify role information
- [ ] Verify Home screen
- [ ] Logout
- [ ] Login again
- [ ] Restart application and verify session restoration

### Projects

- [ ] View projects
- [ ] Create project as admin
- [ ] Edit project as admin
- [ ] Delete project as admin
- [ ] Verify member restrictions
- [ ] Refresh project list

### Tasks

- [ ] Open a project
- [ ] View tasks
- [ ] Create task
- [ ] Edit task
- [ ] Assign task
- [ ] Change task status
- [ ] Change task priority
- [ ] Delete task
- [ ] Refresh task list

### Notifications

- [ ] Open notifications
- [ ] Mark notification as read
- [ ] Mark all notifications as read
- [ ] Delete notification

### QA Simulation

- [ ] Normal
- [ ] Offline
- [ ] Timeout
- [ ] Not Found
- [ ] Validation Error
- [ ] Return to Normal

---

## 19. Technical Decisions and Trade-offs

### Mock Data Instead of a Backend

The assignment focuses on Flutter architecture, state management, data-layer design, simulated authentication, and UI behavior rather than backend implementation.

Therefore, a local mock data source was used.

Benefits:

- No backend setup required
- Easy local setup
- Deterministic reviewer testing
- Easy error simulation
- Easy offline simulation
- No external service dependencies

Trade-offs:

- No real network communication
- No server-side concurrency
- No real server-side validation
- No multi-device synchronization
- Data is limited to the supplied mock dataset

### Provider

Provider with `ChangeNotifier` was selected because it provides a lightweight and straightforward state-management approach.

### Repository Abstraction

The repository prevents providers and UI screens from directly depending on the mock data implementation.

This makes the mock data source replaceable with a real API implementation later.

### Secure Storage

`flutter_secure_storage` is used for authentication tokens so sensitive token values are not stored using ordinary preferences.

### SharedPreferences

`shared_preferences` is used for local persistence of mock application data.

This is suitable for the assignment because there is intentionally no real backend.

---

## 20. Known Limitations

- There is no real backend API.
- Authentication is simulated.
- Access and refresh tokens are mock tokens.
- Token refresh is simulated.
- Data persistence is local.
- Multiple-device synchronization is not implemented.
- Network connectivity is simulated.
- Error scenarios are intentionally simulated for QA testing.
- Server-side authorization is not implemented.
- The mock dataset is limited to the supplied data.
- The application does not represent production-scale backend concurrency.

---

## 21. Future Improvements

If the application were connected to a production backend, the mock data source could be replaced with an API implementation while keeping the provider, repository, model, and UI architecture largely intact.

Potential improvements include:

- REST API integration
- Real authentication
- Real access/refresh token handling
- Backend database
- Server-side authorization
- Real network connectivity monitoring
- Pagination
- Search
- Advanced filtering
- Push notifications
- More comprehensive integration tests
- Production analytics and monitoring

---

## 22. Production Readiness Verification

The following commands have been successfully verified:

```text
flutter pub get
✓ Passed

flutter test
✓ 8/8 tests passed

flutter build apk --release
✓ Release APK generated
```

The application runs without requiring a backend server or manual source-code modifications.

The release APK is generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 23. Summary

TaskFlow demonstrates a Flutter project-management application using:

- Layered architecture
- Provider state management
- Repository abstraction
- Local mock data
- Local persistence
- Simulated authentication
- Secure token storage
- Token expiry and refresh simulation
- Role-based behavior
- Project CRUD
- Task CRUD
- Task assignment
- Task status and priority management
- Comments
- Notifications
- Loading, empty, and error states
- Offline simulation
- Timeout simulation
- Not-found simulation
- Validation-error simulation
- Automated tests
- Release APK generation

The architecture is intentionally designed so that the local mock data source can later be replaced by a real backend implementation without tightly coupling the UI to the data source.