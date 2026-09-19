# Full-Stack University Library Management System

A production-grade, full-stack **University Library Management System** designed and engineered with **Flutter**, **Dart Frog**, **MySQL**, and **Material 3**.

---

## Architecture Overview

```
Flutter Client UI (Mobile, Web, Desktop)
       │
       │ HTTP / JSON (REST API on Port 8081)
       ▼
Dart Frog REST API Backend
  ├── Routes (Auth, Books, Borrowings, Reservations, Admin)
  ├── Middleware (CORS, JWT Authentication, Role Guards)
  ├── Services (Domain Logic, Stock Math, Transaction Coordination)
  ├── Repositories (Prepared SQL, mysql_client Connection Pool, Transactions)
  ├── Models & Validation (Data Sanitization & Envelope Responses)
       │
       │ TCP / MySQL 8.0+ Connection (InnoDB with caching_sha2_password support)
       ▼
MySQL Relational Database (`library_management`)
  ├── users (Roles: student, admin)
  ├── books (ISBN, Stock, Available Copies)
  ├── borrowings (14-day loans, Overdue tracking)
  └── reservations (Priority queue holds)
```

---

## Key Features

### 🎓 For Students
- **Browse & Search**: Real-time search across titles, authors, categories, and ISBNs with category filters.
- **Book Availability**: Live copy tracking showing total vs. currently available stock in the university stacks.
- **Self-Service Borrowing**: 1-tap borrowing for standard 14-day loans with automated inventory decrement.
- **Book Reservations / Holds**: When a book is completely checked out (0 copies), students can place priority holds.
- **Book Returns**: Return books directly with atomic inventory replenishment.
- **Overdue Monitoring**: Visual status badges flagging overdue materials and remaining due days.

### 🛡️ For Administrators
- **Catalog Management**: Add, edit, and delete textbooks with ISBN validation, descriptions, and cover URLs.
- **Borrowing Overview**: Real-time dashboard showing every active and completed loan across all university students.
- **Hold Queues**: Monitor reserved titles and active reservations.
- **User Directory**: View registered students and staff accounts.

---

## Directory Structure

```
.
├── database/
│   ├── schema.sql                     # Full MySQL DDL schema with constraints & indexes
│   └── seed.sql                       # Seed data (16 books, 4 users, borrowings, reservations)
├── library_management_backend/        # Dart Frog REST API server
│   ├── routes/                        # API route handlers
│   │   ├── _middleware.dart           # Global CORS middleware
│   │   └── api/
│   │       ├── auth/                  # /api/auth (register, login, me)
│   │       ├── books/                 # /api/books (list, search, [id])
│   │       ├── borrowings/            # /api/borrowings (borrow, list, return)
│   │       ├── reservations/          # /api/reservations (reserve, list, cancel)
│   │       └── admin/                 # /api/admin (books, borrowings, reservations, users)
│   ├── lib/
│   │   ├── auth/                      # JWT service, password hasher, auth context
│   │   ├── database/                  # Connection pooling, config, transactions (mysql_client)
│   │   ├── middleware/                # Route security & role guards
│   │   ├── models/                    # Domain models & standard ApiResponse
│   │   ├── repositories/              # Prepared SQL statements & transactions
│   │   ├── services/                  # Business logic rules enforcement
│   │   └── validation/                # Email, password, ISBN, and quantity validators
│   └── test/                          # Unit and integration tests
├── library_management_frontend/       # Flutter Application (Android, Web, Desktop)
│   ├── lib/
│   │   ├── core/                      # Constants (endpoints: 8081), theme, auth token storage
│   │   ├── models/                    # User, Book, Borrowing, Reservation models
│   │   ├── services/                  # API communication layer
│   │   ├── providers/                 # Provider state management
│   │   ├── widgets/                   # Reusable UI components & dialogs
│   │   └── screens/                   # Splash, Auth, Home, Search, Loans, Holds, Admin
│   └── test/                          # Widget and model unit tests
├── postman/
│   └── library_api.postman_collection.json # Complete API collection with environment vars
└── docs/
    ├── ARCHITECTURE.md                # System design & layer decoupling
    ├── DATABASE.md                    # Data dictionary & transaction rules
    ├── API_DOCUMENTATION.md           # REST endpoint specs & payloads
    ├── SETUP_GUIDE.md                 # Complete guide to running the project
    └── FIGMA_DESIGN_SYSTEM.md         # UI color tokens, typography & components
```

---

## Quick Start Guide

### 1. Database Setup (MySQL 8.0+ / 8.4+)
Create the schema and seed the initial dataset:

```bash
# Initialize schema and seed data
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql
```
*(Or import `database/schema.sql` followed by `database/seed.sql` inside phpMyAdmin/Laragon/Workbench).*

**Pre-seeded Test Accounts:**
| Role | Email | Password |
|---|---|---|
| **Admin** | `admin@library.edu` | `Admin@123` |
| **Student 1** | `student1@library.edu` | `Student@123` |
| **Student 2** | `student2@library.edu` | `Student@123` |
| **Student 3** | `student3@library.edu` | `Student@123` |

---

### 2. Start Backend API
Ensure Dart Frog CLI is activated globally:
```bash
dart pub global activate dart_frog_cli
```

Start the dev server on port **8081**:
```bash
cd library_management_backend
dart pub get
dart_frog dev --port 8081
# Server running at http://localhost:8081
```

---

### 3. Run Flutter App
```bash
cd library_management_frontend
flutter pub get

# Run on Chrome (Web):
flutter run -d chrome

# Run on Android (Physical device via USB):
adb reverse tcp:8081 tcp:8081
flutter run

# Run on Android Emulator:
flutter run

# Run on Windows Desktop:
flutter run -d windows
```

> **Note on Network Ports**: 
> The backend runs on port `8081` to avoid conflicts with system services.
> - **Web / Desktop**: connects to `http://localhost:8081`
> - **Android Emulator**: automatically connects to `http://10.0.2.2:8081`
> - **Physical Android Phone**: run `adb reverse tcp:8081 tcp:8081` over USB

---

### 4. Run Tests
- **Backend Tests**:
  ```bash
  cd library_management_backend
  dart test
  ```
- **Frontend Tests**:
  ```bash
  cd library_management_frontend
  flutter test
  ```
