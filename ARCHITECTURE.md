# TaskFlow — Architecture Document

## 1. Overview

TaskFlow is a Flutter project and task management application designed for organization-based teams.

The application intentionally uses a local mock data layer instead of a real backend. The architecture separates presentation, state management, repository, and data-source responsibilities so that the mock data source can later be replaced by a real API implementation.

The main architectural goals are:

- Separation of concerns
- Testable application logic
- Clear state management
- Replaceable data source
- Simulated authentication
- Secure token storage
- Consistent loading, empty, and error states
- Easy reviewer testing

---

## 2. Architecture Diagram

```text
┌─────────────────────────────────────────┐
│             Presentation Layer           │
│                                         │
│ Screens / Widgets                       │
│ Login / Home / Projects / Tasks         │
│ Notifications / Comments / QA           │
└────────────────────┬────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│              Provider Layer             │
│                                         │
│ AuthProvider                            │
│ ProjectProvider                         │
│ TaskProvider                            │
│ CommentProvider                         │
│ NotificationProvider                    │
└────────────────────┬────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│             Repository Layer            │
│                                         │
│         TaskFlowRepository              │
└────────────────────┬────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│              Data Layer                 │
│                                         │
│           MockDataSource                │
└────────────────────┬────────────────────┘
                     │
             ┌───────┴────────┐
             ▼                ▼
      mock-data.json    SharedPreferences
```

---

## 3. Layer Responsibilities

### 3.1 Presentation Layer

The presentation layer contains the Flutter screens and widgets.

Responsibilities:

- Display application state
- Collect user input
- Validate forms
- Trigger provider operations
- Display loading states
- Display empty states
- Display errors
- Navigate between screens

Screens do not directly access the mock JSON or local persistence layer.

---

### 3.2 Provider Layer

TaskFlow uses:

```text
Provider
ChangeNotifier
```

Each major feature has its own provider.

#### AuthProvider

Responsible for:

- Login
- Registration
- Logout
- Session restoration
- Authentication status
- User information
- Organization information
- Role information
- Access token
- Refresh token
- Token expiry
- Token refresh

#### ProjectProvider

Responsible for:

- Loading projects
- Creating projects
- Updating projects
- Deleting projects
- Loading state
- Empty state
- Error state

#### TaskProvider

Responsible for:

- Loading tasks
- Creating tasks
- Updating tasks
- Deleting tasks
- Assigning tasks
- Updating task status
- Updating task priority
- Loading state
- Empty state
- Error state

#### CommentProvider

Responsible for:

- Loading comments
- Creating comments
- Updating comments
- Deleting comments

#### NotificationProvider

Responsible for:

- Loading notifications
- Tracking unread count
- Marking notifications as read
- Marking all notifications as read
- Deleting notifications

---

## 4. Repository Layer

The repository is:

```text
TaskFlowRepository
```

It provides an abstraction between providers and the data source.

For example:

```dart
Future<List<ProjectModel>> getProjects(String orgId)
```

The provider does not need to know whether project data comes from:

- JSON
- SharedPreferences
- REST API
- Database

The current flow is:

```text
Provider
   ↓
TaskFlowRepository
   ↓
MockDataSource
```

This design allows the data source to be replaced later without tightly coupling the UI to the implementation.

---

## 5. Mock Data Layer

The assignment intentionally does not use a real backend.

The mock data is stored in:

```text
assets/mock/mock-data.json
```

`MockDataSource` is responsible for reading the mock data and providing CRUD operations.

The mock data includes:

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

Instead:

```text
Screen
   ↓
Provider
   ↓
Repository
   ↓
MockDataSource
   ↓
mock-data.json
```

---

## 6. Local Persistence

TaskFlow uses `shared_preferences` for local persistence of mock project and task data.

The purpose is to allow CRUD operations to persist locally during application usage.

The application does not require:

- Backend server
- Remote database
- REST API
- External service

This is appropriate for the assignment because the backend is intentionally excluded.

In a production application, this local persistence would normally be replaced or supplemented by a server-side data store.

---

## 7. Authentication Architecture

Authentication is simulated using credentials contained in the mock data.

The login flow is:

```text
Login Screen
     ↓
AuthProvider.login()
     ↓
TaskFlowRepository
     ↓
MockDataSource
     ↓
Mock Credentials
     ↓
Mock Login Response
     ↓
Secure Storage
     ↓
Authenticated State
     ↓
Home Screen
```

The login process performs the following steps:

1. Set authentication status to loading.
2. Load mock credentials.
3. Match the supplied email and password.
4. Reject invalid credentials.
5. Obtain the mock login response.
6. Calculate the simulated token expiry time.
7. Store the access token.
8. Store the refresh token.
9. Store token expiry.
10. Store the user email.
11. Load the matching user.
12. Store organization ID and role.
13. Start the access-token expiry timer.
14. Set authentication status to authenticated.

---

## 8. Session Restoration

The application checks for an existing session when it starts.

The Splash Screen triggers:

```text
AuthProvider.checkSession()
```

The provider reads:

- Access token
- Refresh token
- Access-token expiry
- Saved user email

The flow is:

```text
Application Start
       ↓
Splash Screen
       ↓
checkSession()
       ↓
┌───────────────────┐
│ Valid Session?    │
└─────────┬─────────┘
          │
      ┌───┴────┐
      │        │
     Yes       No
      │        │
      ▼        ▼
    Home     Login
```

If the token has expired, the provider attempts the simulated refresh flow.

---

## 9. Token Storage

TaskFlow uses:

```text
flutter_secure_storage
```

for sensitive authentication values.

Stored values include:

- Access token
- Refresh token
- Access-token expiry
- User email

The logout operation clears these values.

The application separates token storage from authentication state management so authentication logic can be tested without depending directly on native secure-storage behavior.

---

## 10. Token Expiry and Refresh

The access token has a simulated expiry duration.

After login:

```text
DateTime.now()
      +
Access Token Lifetime
      ↓
Access Token Expiry
```

An expiry timer is started by `AuthProvider`.

When the timer expires:

```text
Access Token Expired
        ↓
refreshSession()
        ↓
Mock Login Response
        ↓
New Access Token
        ↓
New Expiry
        ↓
Authenticated
```

If the refresh token is unavailable, the session is cleared and the user is logged out.

---

## 11. Role-Based Authorization

TaskFlow supports two roles:

```text
org_admin
member
```

The authenticated role is stored in `AuthProvider`.

The role determines which administrative operations are available.

For example, project modification actions are restricted to organization administrators.

The UI checks the authenticated role before displaying or executing administrative actions.

---

## 12. Navigation and Application Flow

The main authentication flow is:

```text
Application
    ↓
Splash Screen
    ↓
Session Check
    │
    ├── Valid Session ──→ Home
    │
    └── No Session ────→ Login
```

After authentication:

```text
Home
 ├── Projects
 │    ├── Project Details
 │    └── Tasks
 │         ├── Create Task
 │         ├── Edit Task
 │         ├── Assign Task
 │         └── Task Details
 │
 ├── Notifications
 │
 └── Other application features
```

---

## 13. Project Flow

Project operations follow:

```text
Project Screen
      ↓
ProjectProvider
      ↓
TaskFlowRepository
      ↓
MockDataSource
```

Supported operations:

```text
GET     → Load projects
CREATE  → Create project
UPDATE  → Update project
DELETE  → Delete project
```

Projects are filtered by organization ID so users only receive projects belonging to their organization.

---

## 14. Task Flow

Task operations follow:

```text
Task Screen
      ↓
TaskProvider
      ↓
TaskFlowRepository
      ↓
MockDataSource
```

Supported operations:

```text
GET
CREATE
UPDATE
DELETE
```

Tasks are filtered by project ID.

Task updates include:

- Name
- Description
- Assignment
- Status
- Priority
- Other supported task properties

---

## 15. Notification Flow

Notifications follow:

```text
Notification Screen
        ↓
NotificationProvider
        ↓
TaskFlowRepository
        ↓
MockDataSource
```

Supported operations include:

- Load notifications
- Filter notifications by user
- Mark notification as read
- Mark all notifications as read
- Delete notification

Unread count is maintained by the notification provider.

---

## 16. Comment Flow

Comments follow the same architecture:

```text
Task Screen
      ↓
CommentProvider
      ↓
TaskFlowRepository
      ↓
MockDataSource
```

Supported operations:

- Load comments
- Create comment
- Update comment
- Delete comment

Comments are associated with tasks using the task ID.

---

## 17. Error Handling

The application supports explicit application states.

Typical provider states include:

```text
initial
loading
success
error
```

The UI responds accordingly.

### Loading

A progress indicator is displayed.

### Empty

An appropriate empty-state message is displayed.

### Error

The error message is displayed with retry functionality where applicable.

This prevents the UI from assuming that every data operation succeeds.

---

## 18. QA Simulation Architecture

The mock data layer supports:

```dart
enum MockScenario {
  normal,
  offline,
  timeout,
  notFound,
  validationError,
}
```

The scenarios are intentionally simulated so reviewers can test the application's error-handling behavior.

### Normal

```text
MockScenario.normal
```

Normal application behavior.

### Offline

```text
MockScenario.offline
```

Simulates an unavailable data source.

### Timeout

```text
MockScenario.timeout
```

Simulates a delayed operation followed by a timeout/error.

### Not Found

```text
MockScenario.notFound
```

Simulates a resource-not-found condition.

### Validation Error

```text
MockScenario.validationError
```

Simulates a validation failure during a write operation.

After testing, the scenario can be returned to:

```text
MockScenario.normal
```

---

## 19. Testing Architecture

The test suite is designed to test application logic without requiring a real backend.

The tests use:

- Mock data
- Fake token storage where required
- Mock SharedPreferences
- Repository
- Providers

The test architecture is:

```text
Test
 ↓
Provider / Repository
 ↓
MockDataSource
 ↓
Mock Data
```

Native secure-storage dependencies are avoided during tests through the storage abstraction.

`SharedPreferences.setMockInitialValues({})` is used to provide an in-memory implementation during tests.

---

## 20. Automated Tests

The current test suite contains 8 tests.

The tests cover:

1. Project filtering by organization
2. Unknown organization handling
3. Task filtering by project
4. Unknown project handling
5. Normal mock-data behavior
6. Offline scenario
7. Timeout scenario
8. Not-found scenario

Current result:

```text
8 tests passed
```

The tests can be executed with:

```bash
flutter test
```

---

## 21. Why This Architecture Was Chosen

The architecture was selected based on the assignment requirements.

### Separation of Concerns

Screens do not directly access the data source.

### Testability

Providers and repositories can be tested independently from native platform plugins.

### Replaceable Data Source

The mock data source can later be replaced by a REST API implementation.

### Centralized State

Each feature owns its state through a dedicated provider.

### Simple State Management

Provider and ChangeNotifier are lightweight and appropriate for the application's scope.

### Local Mock Persistence

SharedPreferences provides enough persistence for the assignment without introducing unnecessary database infrastructure.

---

## 22. Technical Trade-offs

### Mock Backend

**Decision:** Use a local mock data source.

**Reason:** The assignment explicitly states that a real backend is not required.

**Trade-off:** The application does not represent real server communication or server-side concurrency.

### Provider

**Decision:** Use Provider with ChangeNotifier.

**Reason:** It provides simple, readable state management and integrates naturally with Flutter widgets.

**Trade-off:** A larger production application might benefit from a more structured state-management solution.

### SharedPreferences

**Decision:** Use SharedPreferences for mock data persistence.

**Reason:** It is simple and sufficient for local assignment data.

**Trade-off:** It is not a replacement for a production database.

### Secure Storage

**Decision:** Use flutter_secure_storage for tokens.

**Reason:** Authentication tokens should not be stored using ordinary preferences.

**Trade-off:** Native secure-storage plugins require special handling in automated tests.

---

## 23. Production Replacement Strategy

If a real backend were introduced, the architecture could become:

```text
UI
 ↓
Provider
 ↓
Repository
 ↓
API Data Source
 ↓
REST API
 ↓
Backend
```

The current:

```text
MockDataSource
```

could be replaced with an API data source while keeping the providers and UI largely unchanged.

This is one of the main reasons the repository layer exists.

---

## 24. Known Limitations

The current application intentionally has the following limitations:

- No real backend API
- Simulated authentication
- Mock access and refresh tokens
- Simulated token refresh
- Local data persistence
- No multi-device synchronization
- Simulated network conditions
- Artificial QA error scenarios
- No server-side authorization
- Limited mock dataset
- No production-scale backend concurrency

These limitations are intentional because the assignment focuses on the Flutter application architecture and client-side implementation.

---

## 25. Future Improvements

With a real backend, the application could be extended with:

- REST API integration
- Real authentication
- Real access and refresh tokens
- Backend database
- Server-side authorization
- Real network connectivity detection
- Pagination
- Search
- Advanced filtering
- Push notifications
- More comprehensive integration tests
- Analytics
- Crash reporting
- Production monitoring

---

## 26. Project Verification

The following commands have been successfully verified:

```text
flutter pub get
✓ Passed

flutter test
✓ 8/8 tests passed

flutter build apk --release
✓ Release APK generated
```

The generated release APK is located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 27. Conclusion

TaskFlow demonstrates a clean Flutter architecture built around:

- Provider state management
- ChangeNotifier
- Repository abstraction
- Local mock data
- Local persistence
- Simulated authentication
- Secure token storage
- Token expiry and refresh
- Role-based behavior
- CRUD operations
- Loading, empty, and error states
- QA error simulation
- Automated testing
- Release build support

The architecture keeps the UI independent from the mock data implementation and provides a clear migration path toward a real backend in the future.