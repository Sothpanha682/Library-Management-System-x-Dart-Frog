# Full-Stack University Library Management System

A production-grade, full-stack **University Library Management System** designed and engineered with **Flutter**, **Dart Frog**, **MySQL**, and **Material 3**.

---

## Architecture Overview

```
Flutter Mobile App (Client UI)
       │
       │ HTTP / JSON (REST API)
       ▼
Dart Frog REST API Backend
  ├── Routes (Auth, Books, Borrowings, Reservations, Admin)
  ├── Middleware (CORS, JWT Authentication, Role Guards)
  ├── Services (Domain Logic, Stock Math, Transaction Coordination)
  ├── Repositories (Prepared SQL, Connection Pool, Transactions)
  ├── Models & Validation (Data Sanitization & Envelope Responses)
       │
       │ TCP / MySQL Connection Pool (InnoDB)
       ▼
MySQL Relational Database
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
│   └── seed.sql                       # Seed data (test admin, students, and 6 core books)
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
│   │   ├── database/                  # Connection pooling, config, transactions
│   │   ├── middleware/                # Route security & role guards
│   │   ├── models/                    # Domain models & standard ApiResponse
│   │   ├── repositories/              # Prepared SQL statements & transactions
│   │   ├── services/                  # Business logic rules enforcement
│   │   └── validation/                # Email, password, ISBN, and quantity validators
│   └── test/                          # Unit and integration tests
├── library_management_frontend/       # Flutter Mobile Application
│   ├── lib/
│   │   ├── core/                      # Constants, theme, network client, token storage
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

### 1. Database
```bash
mysql -u root -p < database/schema.sql
mysql -u root -p library_db < database/seed.sql
```

**Pre-seeded Test Accounts:**
- **Admin**: `admin@library.edu` / `Admin@123`
- **Student 1**: `student1@library.edu` / `Student@123`
- **Student 2**: `student2@library.edu` / `Student@123`

### 2. Start Backend API
```bash
cd library_management_backend
dart pub get
dart_frog dev
# Server running at http://localhost:8080
```

### 3. Run Flutter App
```bash
cd library_management_frontend
flutter pub get
flutter run -d chrome # or android emulator
```

### 4. Run Tests
- **Backend Tests**: `cd library_management_backend && dart test`
- **Frontend Tests**: `cd library_management_frontend && flutter test`
