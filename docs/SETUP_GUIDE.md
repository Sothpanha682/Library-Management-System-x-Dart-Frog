# Environment Setup & Execution Guide

This guide details running the complete full-stack University Library Management System locally or in container environments.

## Prerequisites
- **Dart SDK** (v3.0.0 or higher)
- **Flutter SDK** (v3.19.0 or higher)
- **Dart Frog CLI** (`dart pub global activate dart_frog_cli`)
- **MySQL 8.0+** running locally or via Docker

---

## 1. Database Setup

1. Start your MySQL service:
   ```bash
   # If using system MySQL:
   sudo systemctl start mysql

   # Or if using Docker:
   docker run --name library-mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=library_db -p 3306:3306 -d mysql:8.0
   ```

2. Run the database initialization and seed scripts:
   ```bash
   mysql -u root -p < database/schema.sql
   mysql -u root -p library_db < database/seed.sql
   ```

   **Default Test Credentials Seeded:**
   - **Admin User**:
     - Email: `admin@library.edu`
     - Password: `Admin@123`
     - Role: `admin`
   - **Student 1**:
     - Email: `student1@library.edu`
     - Password: `Student@123`
     - Role: `student`
   - **Student 2**:
     - Email: `student2@library.edu`
     - Password: `Student@123`
     - Role: `student`

---

## 2. Dart Frog Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd library_management_backend
   ```

2. Install dependencies:
   ```bash
   dart pub get
   ```

3. Configure environment:
   ```bash
   cp .env.example .env
   ```
   Ensure `.env` matches your MySQL host, port, user, and password.

4. Run unit and integration tests:
   ```bash
   dart test
   ```

5. Start the backend development server:
   ```bash
   dart_frog dev
   ```
   The REST API will be serving requests at `http://localhost:8080`.

---

## 3. Flutter Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd library_management_frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the widget and unit tests:
   ```bash
   flutter test
   ```

4. Launch the Flutter app:
   ```bash
   # Launch on Chrome / Web:
   flutter run -d chrome

   # Launch on Android Emulator:
   flutter run -d emulator-5554

   # Launch on macOS / Linux desktop:
   flutter run -d macos
   ```

   *Note: When running on an Android Emulator, the app automatically switches its base URL to `http://10.0.2.2:8080` to seamlessly reach your host backend.*

---

## 4. Postman API Testing

1. Open Postman.
2. Click **Import** and select `postman/library_api.postman_collection.json`.
3. The collection is organized by resource:
   - Run `1. Authentication -> Login (Student)`: The test script automatically saves the `token` variable into the collection.
   - Run `3. Borrowings -> Borrow Book`: Executes with the saved bearer token.
   - Run `5. Admin Endpoints -> Admin Add Book`: Tests role-based protection with `admin_token`.
