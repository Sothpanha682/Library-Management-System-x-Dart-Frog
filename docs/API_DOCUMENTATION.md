# REST API Documentation

Base URL: `http://localhost:8080/api`

All JSON responses adhere to the standard envelope format:

### Success Response Format
```json
{
  "success": true,
  "message": "Operation description",
  "data": { ... }
}
```

### Paginated List Response Format
```json
{
  "success": true,
  "message": "Items retrieved",
  "data": [ ... ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 54
  }
}
```

### Error Response Format
```json
{
  "success": false,
  "message": "Validation error or business failure explanation",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": { ... }
  }
}
```

---

## Endpoint Reference Table

| Method | Endpoint | Description | Auth Required | Admin Only |
|---|---|---|---|---|
| `POST` | `/api/auth/register` | Register new student account | No | No |
| `POST` | `/api/auth/login` | Authenticate and obtain JWT | No | No |
| `GET` | `/api/auth/me` | Fetch authenticated user profile | Yes | No |
| `PUT` | `/api/auth/me` | Update authenticated user name | Yes | No |
| `GET` | `/api/books` | Get books with filters and pagination | No | No |
| `GET` | `/api/books/search?q=:query`| Search books by title, author, ISBN | No | No |
| `GET` | `/api/books/:id` | Get book details by ID | No | No |
| `POST` | `/api/borrowings` | Borrow a book for 14 days | Yes | No |
| `GET` | `/api/borrowings` | Get current user's borrowings | Yes | No |
| `GET` | `/api/borrowings/:id` | Get borrowing details | Yes | No |
| `PUT` | `/api/borrowings/:id/return`| Return a borrowed book | Yes | No |
| `POST` | `/api/reservations` | Reserve unavailable book | Yes | No |
| `GET` | `/api/reservations` | Get user's active/past reservations | Yes | No |
| `GET` | `/api/reservations/:id` | Get reservation details | Yes | No |
| `DELETE`| `/api/reservations/:id` | Cancel an active reservation | Yes | No |
| `POST` | `/api/admin/books` | Add new book to catalog | Yes | **Yes** |
| `PUT` | `/api/admin/books/:id` | Edit book details & inventory | Yes | **Yes** |
| `DELETE`| `/api/admin/books/:id` | Delete book from catalog | Yes | **Yes** |
| `GET` | `/api/admin/users` | List all registered university users | Yes | **Yes** |
| `GET` | `/api/admin/borrowings` | List all university borrowings | Yes | **Yes** |
| `GET` | `/api/admin/reservations`| List all reservations in system | Yes | **Yes** |

---

## Detailed Endpoint Examples

### 1. Register
- **Request**: `POST /api/auth/register`
- **Body**:
  ```json
  {
    "name": "Sarah Connor",
    "email": "sarah@library.edu",
    "password": "Password123!"
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "success": true,
    "message": "User registered successfully",
    "data": {
      "user": {
        "id": 4,
        "name": "Sarah Connor",
        "email": "sarah@library.edu",
        "role": "student"
      },
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
  ```

### 2. Borrow a Book
- **Request**: `POST /api/borrowings`
- **Header**: `Authorization: Bearer <token>`
- **Body**:
  ```json
  {
    "book_id": 1
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "success": true,
    "message": "Book borrowed successfully",
    "data": {
      "id": 1,
      "user_id": 2,
      "book_id": 1,
      "borrowed_at": "2026-09-19T03:15:00.000Z",
      "due_date": "2026-10-03T03:15:00.000Z",
      "status": "borrowed"
    }
  }
  ```

### 3. Return a Book
- **Request**: `PUT /api/borrowings/1/return`
- **Header**: `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Book returned successfully. Inventory updated.",
    "data": {
      "id": 1,
      "status": "returned",
      "returned_at": "2026-09-19T03:20:00.000Z"
    }
  }
  ```
