# Library Management System - Architecture & System Design

## 1. High-Level Architecture

The system strictly enforces a decoupled 3-tier client-server architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                       │
│  (Material 3 UI, Provider State Management, Clean Services) │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               │ HTTPS / JSON REST API
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    Dart Frog REST API                       │
│  ├── Routes (File-based endpoints)                          │
│  ├── Middleware (CORS, JWT Authentication, Admin Guard)     │
│  ├── Services (Domain & Business Logic Rules)               │
│  ├── Repositories (Prepared Statements & Transactions)      │
│  └── Models (Encapsulation & Validation)                    │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               │ MySQL Connection Pool
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   MySQL Relational DB                       │
│  (ACID Transactions, Foreign Keys, InnoDB, Indexes)         │
└─────────────────────────────────────────────────────────────┘
```

> **Strict Architectural Rule**: The Flutter client **NEVER** connects directly to MySQL. All persistence, authorization, validations, and stock calculations occur within the backend server.

---

## 2. Dart Frog Backend Architecture

The backend follows Clean Architecture principles:

- **Routes (`routes/api/...`)**: HTTP dispatch layer. Parses URL parameters, validates payloads, reads `AuthContext` injected by middleware, and delegates directly to Domain Services.
- **Middleware (`lib/middleware/...`)**:
  - `corsMiddleware`: Global CORS headers allowing cross-origin requests.
  - `authRequiredMiddleware`: Verifies bearer JWT token, extracts user payload, and injects `AuthContext` into request context.
  - `adminRequiredMiddleware`: Protects admin routes, verifying `user.role == 'admin'`.
- **Services (`lib/services/...`)**:
  - `AuthService`: Password hashing, token generation, user retrieval.
  - `BookService`: Book cataloging, search query orchestration, total quantity management.
  - `BorrowingService`: Enforces 14-day borrowing rules, atomic transactions for decrementing stock, duplicate active loan checks, and returning books.
  - `ReservationService`: Ensures reservations can only be created if a book has 0 available copies, holds books for 7 days, and allows cancellation.
- **Repositories (`lib/repositories/...`)**:
  - Direct database interaction using `mysql1`.
  - Atomicity guaranteed using `DbConnection.transaction` with `COMMIT` and `ROLLBACK`.
- **Models (`lib/models/...`)**:
  - Immutable domain entities (`User`, `Book`, `Borrowing`, `Reservation`).
  - Standard JSON response wrapper (`ApiResponse`).

---

## 3. Flutter Frontend Architecture

The mobile app is structured around feature-oriented layers with the Provider state management pattern:

```
lib/
├── core/             # Centralized constants, network client, token storage, M3 theme
├── models/           # Frontend entities matching API response structures
├── services/         # API HTTP communication abstraction
├── providers/        # State managers notifying UI changes via ChangeNotifier
├── widgets/          # Reusable design components (Badges, BookCard, TextField, Dialogs)
└── screens/          # Clean UI views (Splash, Auth, Home, Search, Details, Loans, Holds, Admin)
```

### State Management Flow:
1. User triggers an action (e.g. "Borrow Book").
2. UI opens a modal `ConfirmDialog`.
3. Upon confirmation, the UI calls `BorrowingProvider.borrowBook(bookId)`.
4. The provider calls `BorrowingService.borrowBook(bookId)`.
5. The service invokes `ApiClient.post('/api/borrowings')` which attaches the stored JWT token in the `Authorization` header.
6. The backend executes an atomic transaction and returns `201 Created`.
7. The provider updates its internal list, calls `notifyListeners()`, and triggers a reload in `BookProvider` to reflect the decremented quantity in real-time.
