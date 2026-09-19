# University Library Management System - Dart Frog REST API

A modern, high-performance REST API backend built with **Dart Frog**, providing clean architecture and full transaction-safe support for library management.

## Tech Stack
- **Framework**: Dart Frog 1.2.x
- **Language**: Dart 3.x
- **Database**: MySQL 8.0+ / 8.4+ via `mysql_client` with transaction & `caching_sha2_password` support
- **Auth**: JWT (`dart_jsonwebtoken`) + Salted SHA-256 / Bcrypt password verification
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
│   ├── database/                # Connection pooling, config, transactions (mysql_client)
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

1. Install Dart Frog CLI globally:
   ```bash
   dart pub global activate dart_frog_cli
   ```

2. Install dependencies:
   ```bash
   dart pub get
   ```

3. Configure environment (optional, defaults to `root` with no password on `127.0.0.1:3306`):
   ```bash
   cp .env.example .env
   ```

4. Start server in development mode with live reload on port **8081**:
   ```bash
   dart_frog dev --port 8081
   ```
   Or run the compiled production build:
   ```bash
   dart_frog build
   dart build/bin/server.dart
   ```
   Server will be available at `http://localhost:8081`.

5. Run tests:
   ```bash
   dart test
   ```
