# Database Schema & Data Dictionary

The University Library Management System uses a normalized MySQL database engine with foreign key relationships, cascade protections, and indexes for optimized querying.

## Entity Relationship Overview

```
 [ users ] 1 ───< (borrowings) >─── 1 [ books ]
     │                                    │
     └──────────< (reservations) >────────┘
```

---

## 1. Table Definitions

### `users`
Stores student members and library administrators.
```sql
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('student', 'admin') DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_email (email),
    INDEX idx_user_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### `books`
Stores the library catalog.
```sql
CREATE TABLE IF NOT EXISTS books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    isbn VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    cover_image VARCHAR(500),
    quantity INT NOT NULL DEFAULT 1,
    available_quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_book_category (category),
    INDEX idx_book_title (title),
    INDEX idx_book_author (author),
    INDEX idx_book_isbn (isbn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### `borrowings`
Tracks active and historical loans.
```sql
CREATE TABLE IF NOT EXISTS borrowings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    borrowed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_date TIMESTAMP NOT NULL,
    returned_at TIMESTAMP NULL DEFAULT NULL,
    status ENUM('borrowed', 'returned', 'overdue') DEFAULT 'borrowed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE RESTRICT,
    INDEX idx_borrowing_user (user_id),
    INDEX idx_borrowing_book (book_id),
    INDEX idx_borrowing_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### `reservations`
Tracks priority holds placed by students when physical inventory is exhausted.
```sql
CREATE TABLE IF NOT EXISTS reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    status ENUM('pending', 'available', 'cancelled', 'expired') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE RESTRICT,
    INDEX idx_reservation_user (user_id),
    INDEX idx_reservation_book (book_id),
    INDEX idx_reservation_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2. Transaction Integrity & Concurrency Rules

### Borrowing a Book (Atomic Transaction)
1. `START TRANSACTION;`
2. `SELECT available_quantity FROM books WHERE id = ? FOR UPDATE;`
3. Verify `available_quantity > 0`. If 0, `ROLLBACK` and return error.
4. Verify user has no active borrowing for this book:
   `SELECT id FROM borrowings WHERE user_id = ? AND book_id = ? AND status = 'borrowed';`
5. `INSERT INTO borrowings (user_id, book_id, borrowed_at, due_date, status) VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 14 DAY), 'borrowed');`
6. `UPDATE books SET available_quantity = available_quantity - 1 WHERE id = ?;`
7. `COMMIT;`

### Returning a Book (Atomic Transaction)
1. `START TRANSACTION;`
2. `SELECT user_id, book_id, status FROM borrowings WHERE id = ? FOR UPDATE;`
3. Verify `status != 'returned'`. If returned, `ROLLBACK` and return error.
4. `UPDATE borrowings SET returned_at = NOW(), status = 'returned' WHERE id = ?;`
5. `UPDATE books SET available_quantity = LEAST(quantity, available_quantity + 1) WHERE id = ?;`
6. `COMMIT;`
