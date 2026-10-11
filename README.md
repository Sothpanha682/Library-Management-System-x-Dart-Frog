# Full-Stack University Library Management System

A production-grade, full-stack **University Library Management System** designed and engineered with **Flutter (Material 3)**, **Dart Frog (REST API)**, and **MongoDB (Docker)**.

---

## 🏛️ Architecture Overview

```text
Flutter Client UI (Mobile, Web, Desktop)
       │
       │ HTTP / JSON (REST API on Port 8081)
       ▼
Dart Frog REST API Backend
  ├── Routes (Auth, Books, Borrowings, Reservations, Admin)
  ├── Middleware (CORS & Preflight, JWT Authentication, Admin Role Guards)
  ├── Services (Domain Logic, Stock Math, Transaction Coordination)
  ├── Repositories (mongo_dart driver, atomic operations, populates)
  ├── Models & Validation (Data Sanitization & Envelope Responses)
       │
       │ TCP / MongoDB 7.0 (Docker container on Port 27017)
       ▼
MongoDB Database (`library_management`)
  ├── users (Roles: student, admin)
  ├── books (ISBN, Stock, Available Copies)
  ├── borrowings (14-day loans, Overdue tracking)
  ├── reservations (Priority queue holds)
  └── counters (Atomic auto-increment IDs)
```

---

## ✨ Key Features

### 🎓 For Students
- **Browse & Search**: Real-time catalog search across titles, authors, categories, and ISBNs with category chips.
- **Book Availability**: Live copy tracking showing total stock vs. currently available copies in university stacks.
- **Self-Service Borrowing**: 1-tap borrowing for standard 14-day loans with automated atomic inventory decrement.
- **Book Reservations / Holds**: Priority queue holds when a book is completely checked out (0 copies available).
- **Book Returns**: Return books directly with atomic inventory replenishment.
- **Overdue Monitoring**: Visual status badges flagging overdue materials and due-date counters.

### 🛡️ For Administrators
- **Catalog Management**: Add, edit, and delete textbooks with ISBN validation, descriptions, and cover URLs.
- **Borrowing Overview**: Real-time dashboard showing every active and completed loan across all university students.
- **Hold Queues**: Monitor reserved titles and active student hold requests.
- **User Directory**: View registered students and staff accounts.

### 🎨 Design & Mobile Branding
- **Custom University Emblem Logo**: Integrated across Splash screen, Login, and Mobile Home headers.
- **Full Mobile App Launcher Icons**: Standard launcher icons generated for **Android** (adaptive & mipmap densities), **iOS** (AppIcon set), and **Web** (PWA icons).
- **Default White / Light Theme**: Clean, modern Material 3 academic palette with seamless toggle to Dark Mode.
- **Automated Port & CORS Handling**: Robust preflight `OPTIONS` and error headers ensuring smooth web and mobile connectivity.

---

## 📁 Directory Structure

```text
.
├── docker-compose.yml                 # MongoDB 7.0 & Mongo Express services
├── start.ps1                          # 1-click startup script (handles port cleanup & launches both apps)
├── logo-lib.png                       # Source university library emblem
├── database/
│   ├── mongo-init.js                  # MongoDB seed script (users, books, borrowings, reservations)
│   ├── schema.sql                     # SQL schema reference
│   └── seed.sql                       # SQL seed data reference
├── library_management_backend/        # Dart Frog REST API server
│   ├── routes/                        # API route handlers
│   │   ├── _middleware.dart           # Global CORS & request logging middleware
│   │   └── api/
│   │       ├── auth/                  # /api/auth (register, login, me)
│   │       ├── books/                 # /api/books (list, search, [id])
│   │       ├── borrowings/            # /api/borrowings (borrow, list, return)
│   │       ├── reservations/          # /api/reservations (reserve, list, cancel)
│   │       └── admin/                 # /api/admin (books, borrowings, reservations, users)
│   ├── lib/
│   │   ├── auth/                      # JWT service, password hasher, auth context
│   │   ├── database/                  # MongoDB connection pool & atomic sequences
│   │   ├── middleware/                # CORS, JWT auth, and role guard middlewares
│   │   ├── models/                    # Domain models & standard ApiResponse envelope
│   │   ├── repositories/              # MongoDB repositories with atomic operations
│   │   ├── services/                  # Business logic rules enforcement
│   │   └── validation/                # Email, password, ISBN, and quantity validators
│   └── test/                          # Unit & integration tests
├── library_management_frontend/       # Flutter Application (Android, iOS, Web, Windows)
│   ├── assets/images/                 # App logo & icon assets
│   ├── lib/
│   │   ├── core/                      # Constants, theme palette, token storage
│   │   ├── models/                    # User, Book, Borrowing, Reservation models
│   │   ├── services/                  # HTTP client & API communication layer
│   │   ├── providers/                 # State management (Auth, Books, Borrowings, Theme)
│   │   ├── widgets/                   # BookCard, EmptyState, StatusBadge, ConfirmDialog
│   │   └── screens/                   # Splash, Auth, Home, Search, Loans, Holds, Admin
│   └── test/                          # Unit & widget tests
└── postman/
    └── library_api.postman_collection.json # API collection for manual testing
```

---

## 🚀 Quick Start Guide

### 1. Start MongoDB (Docker)
Ensure Docker Desktop is running, then start MongoDB:
```bash
docker compose up -d
```
MongoDB will start on port `27017` and seed the database with initial users, textbooks, and borrowing records.

**Pre-seeded Accounts:**
| Role | Email | Password |
|---|---|---|
| **Admin** | `admin@library.edu` | `Admin@123` |
| **Student 1** | `student1@library.edu` | `Student@123` |
| **Student 2** | `student2@library.edu` | `Student@123` |
| **Student 3** | `student3@library.edu` | `Student@123` |

---

### 2. 1-Click Launch (Recommended)
Run the PowerShell startup script from the project root:
```powershell
./start.ps1
```
This script automatically:
1. Installs backend and frontend dependencies (`pub get`).
2. Cleans up any stale processes on ports `8081` and `8181`.
3. Opens **Terminal 1** running the Dart Frog backend dev server on `http://localhost:8081`.
4. Opens **Terminal 2** running the Flutter application.

---

### 3. Manual Startup

#### Backend
```bash
cd library_management_backend
dart pub get
dart_frog dev --port 8081
```

#### Frontend
```bash
cd library_management_frontend
flutter pub get

# Run on Chrome (Web):
flutter run -d chrome

# Run on Windows Desktop:
flutter run -d windows

# Run on Android:
flutter run
```

> **Note on Mobile Network Routing**:
> - **Web & Desktop**: Connects directly to `http://localhost:8081`.
> - **Android Emulator**: Automatically routes to `http://10.0.2.2:8081`.
> - **Physical Android Phone**: Run `adb reverse tcp:8081 tcp:8081` over USB.

---

## 🧪 Running Tests

### Backend Tests
```bash
cd library_management_backend
dart test
```

### Frontend Tests
```bash
cd library_management_frontend
flutter test
```

---

## 📄 License
This project is licensed under the MIT License.
