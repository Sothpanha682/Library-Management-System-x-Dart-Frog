# University Library Management System - Dart Frog REST API

A modern, high-performance REST API backend built with **Dart Frog**, providing clean architecture and full transaction-safe support for library management.

## Tech Stack
- **Framework**: Dart Frog 2.x
- **Language**: Dart 3.x
- **Database**: MySQL 8.0+ via `mysql1` with transaction support
- **Auth**: JWT (`dart_jsonwebtoken`) + Salted SHA-256 / Bcrypt password hashing
- **Testing**: `package:test`, `mocktail`

## Directory Structure
```
library_management_backend/
├── routes/
│   ├── _middleware.dart         # Global CORS and logging middleware
│   ├── index.dart               # API status and discovery
│   └── api/
│       ├── auth/                # Register, Login, Me (Profile)
│       ├── books/               # List, Search, Details
│       ├── borrowings/          # Borrow, List, Details, Return
│       ├── reservations/        # Reserve, List, Details, Cancel
│       └── admin/               # Book CRUD, User list, All Borrowings & Reservations
├── lib/
│   ├── models/                  # User, Book, Borrowing, Reservation, ApiResponse
│   ├── database/                # Connection pooling, config, transactions
│   ├── auth/                    # JWT service, password hasher, auth context
│   ├── middleware/              # Auth verification & Admin role guard
│   ├── repositories/            # SQL queries and transaction management
│   ├── services/                # Business logic rules enforcement
│   └── validation/              # Input validators (email, ISBN, fields)
├── test/                        # Unit and integration test suite
├── .env.example                 # Environment variables template
└── pubspec.yaml
```

## Running the Backend

1. Install dependencies:
   ```bash
   dart pub get
   ```

2. Copy `.env.example` to `.env` and set MySQL credentials:
   ```bash
   cp .env.example .env
   ```

3. Start server in development mode with live reload:
   ```bash
   dart_frog dev
   ```
   Or run the compiled server directly:
   ```bash
   dart bin/server.dart
   ```
   Server will be available at `http://localhost:8080`.

4. Run tests:
   ```bash
   dart test
   ```
