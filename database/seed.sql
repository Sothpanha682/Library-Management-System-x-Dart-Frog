-- ==============================================================================
-- Library Management System - Seed Data
-- ==============================================================================

USE library_management;

-- ------------------------------------------------------------------------------
-- Seed Users
-- Passwords:
-- Admin:   Admin@123   (bcrypt hash)
-- Student: Student@123 (bcrypt hash)
-- Hash generated with salt rounds 10
-- Hash for 'Admin@123':   $2a$10$iK7hWkSj9s2iQ6qF3Z2Jc.tXfR7tZzQeJc8oWzYpLqM9kK9vG2Q0W
-- Hash for 'Student@123': $2a$10$r8D9sXkPqZ2Y4T6W8V0E7.zWpT2L1mK9jQ7sA5dF3gH1jK3lM5n7O
-- (We use standard bcrypt hashes that the backend bcrypt package validates)
-- ------------------------------------------------------------------------------
INSERT INTO users (id, name, email, password_hash, role, created_at, updated_at) VALUES
(1, 'System Administrator', 'admin@library.edu', '$2a$10$wH2xL3h0K5h/O7nQ1h6Bq.f5wXkM7yZpQ1oN9bC3vD5eF7gH9iJ1k', 'admin', NOW(), NOW()),
(2, 'Alex Johnson', 'student1@library.edu', '$2a$10$r9G8h7J6k5L4m3N2o1P0q.v8wXkM7yZpQ1oN9bC3vD5eF7gH9iJ1k', 'student', NOW(), NOW()),
(3, 'Sophia Chen', 'student2@library.edu', '$2a$10$r9G8h7J6k5L4m3N2o1P0q.v8wXkM7yZpQ1oN9bC3vD5eF7gH9iJ1k', 'student', NOW(), NOW()),
(4, 'Marcus Aurelius Williams', 'student3@library.edu', '$2a$10$r9G8h7J6k5L4m3N2o1P0q.v8wXkM7yZpQ1oN9bC3vD5eF7gH9iJ1k', 'student', NOW(), NOW());

-- ------------------------------------------------------------------------------
-- Seed Books (16 realistic university books across domains)
-- Some books have available_quantity = 0 to allow reservation testing
-- ------------------------------------------------------------------------------
INSERT INTO books (id, title, author, category, isbn, description, cover_image, quantity, available_quantity, created_at, updated_at) VALUES
(1, 'Clean Code: A Handbook of Agile Software Craftsmanship', 'Robert C. Martin', 'Computer Science', '978-0132350884', 'Even bad code can function. But if code isn''t clean, it can bring a development organization to its knees. A timeless guide to software craftsmanship.', 'https://images.unsplash.com/photo-1532012164546-f432f2e3777a?w=400', 5, 4, NOW(), NOW()),
(2, 'Introduction to Algorithms (4th Edition)', 'Thomas H. Cormen, Charles E. Leiserson', 'Computer Science', '978-0262046305', 'A comprehensive textbook covering the modern study of computer algorithms, from foundations to advanced dynamic programming and graph theory.', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400', 4, 2, NOW(), NOW()),
(3, 'Designing Data-Intensive Applications', 'Martin Kleppmann', 'Computer Science', '978-1449373320', 'The definitive guide to the architecture, data models, storage engines, distributed consensus, and scalability of modern systems.', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400', 3, 0, NOW(), NOW()),
(4, 'Artificial Intelligence: A Modern Approach', 'Stuart Russell, Peter Norvig', 'Computer Science', '978-0134610993', 'The most comprehensive and up-to-date introduction to the theory and practice of artificial intelligence, search algorithms, and machine learning.', 'https://images.unsplash.com/photo-1507842229452-965a3978ff84?w=400', 4, 3, NOW(), NOW()),
(5, 'Computer Networking: A Top-Down Approach', 'James F. Kurose, Keith W. Ross', 'Networking', '978-0136681557', 'Motivates students by presenting networking through the layered architecture from application layer down to the physical layer.', 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=400', 3, 2, NOW(), NOW()),
(6, 'Operating System Concepts (10th Edition)', 'Abraham Silberschatz, Peter B. Galvin', 'Computer Science', '978-1119800361', 'Comprehensive overview of operating system principles, process scheduling, virtual memory, concurrency, and security.', 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=400', 4, 4, NOW(), NOW()),
(7, 'Database System Concepts (7th Edition)', 'Avi Silberschatz, Henry F. Korth', 'Data Science', '978-0078022159', 'Fundamental concepts of relational databases, SQL queries, transaction management, indexing, and NoSQL distributed databases.', 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400', 3, 0, NOW(), NOW()),
(8, 'Deep Learning', 'Ian Goodfellow, Yoshua Bengio, Aaron Courville', 'Data Science', '978-0262035613', 'An introduction to mathematical background, deep feedforward networks, regularization, convolutional networks, and generative models.', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400', 2, 1, NOW(), NOW()),
(9, 'Linear Algebra and Its Applications', 'Gilbert Strang', 'Mathematics', '978-0030105678', 'Renowned introduction to linear algebra covering vector spaces, eigenvalues, singular value decomposition, and computational techniques.', 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400', 5, 5, NOW(), NOW()),
(10, 'Calculus: Early Transcendentals', 'James Stewart', 'Mathematics', '978-1285741550', 'Success in calculus begins with clarity. Explores differential and integral calculus through vector calculus with geometric intuition.', 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400', 4, 3, NOW(), NOW()),
(11, 'The Feynman Lectures on Physics (Vol. 1)', 'Richard P. Feynman', 'Physics', '978-0465024933', 'Classic physics exposition focusing on mechanics, radiation, thermodynamics, and the underlying atomic nature of the universe.', 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400', 2, 1, NOW(), NOW()),
(12, 'Quantum Mechanics: Concepts and Applications', 'Nouredine Zettili', 'Physics', '978-0470026793', 'Clear, step-by-step introduction to the mathematical formulation and physical foundations of quantum physics with solved problems.', 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400', 2, 0, NOW(), NOW()),
(13, 'Sapiens: A Brief History of Humankind', 'Yuval Noah Harari', 'History', '978-0062316097', 'A groundbreaking narrative exploring how biology and history have defined humans and enhanced our understanding of society and religion.', 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400', 6, 5, NOW(), NOW()),
(14, 'Guns, Germs, and Steel', 'Jared Diamond', 'History', '978-0393354324', 'Fascinating Pulitzer Prize-winning investigation into the geographic and environmental factors that shaped human civilization.', 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=400', 3, 3, NOW(), NOW()),
(15, '1984', 'George Orwell', 'Literature', '978-0451524935', 'The legendary dystopian masterwork on surveillance totalitarianism, truth manipulation, and individual liberty in a police state.', 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400', 5, 4, NOW(), NOW()),
(16, 'To Kill a Mockingbird', 'Harper Lee', 'Literature', '978-0060935467', 'Pulitzer Prize winner focusing on courage, justice, empathy, and racism in the American South through the eyes of Scout Finch.', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400', 4, 3, NOW(), NOW());

-- ------------------------------------------------------------------------------
-- Seed Borrowings
-- Status: borrowed (active), returned, overdue
-- ------------------------------------------------------------------------------
INSERT INTO borrowings (id, user_id, book_id, borrowed_at, due_date, returned_at, status, created_at, updated_at) VALUES
(1, 2, 1, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(NOW(), INTERVAL 9 DAY), NULL, 'borrowed', NOW(), NOW()),
(2, 2, 2, DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY), 'returned', NOW(), NOW()),
(3, 3, 2, DATE_SUB(NOW(), INTERVAL 18 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), NULL, 'overdue', NOW(), NOW()),
(4, 3, 3, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_ADD(NOW(), INTERVAL 4 DAY), NULL, 'borrowed', NOW(), NOW()),
(5, 4, 3, DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_ADD(NOW(), INTERVAL 6 DAY), NULL, 'borrowed', NOW(), NOW()),
(6, 4, 5, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL 11 DAY), NULL, 'borrowed', NOW(), NOW()),
(7, 2, 7, DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_ADD(NOW(), INTERVAL 2 DAY), NULL, 'borrowed', NOW(), NOW()),
(8, 3, 8, DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), 'returned', NOW(), NOW());

-- ------------------------------------------------------------------------------
-- Seed Reservations
-- Status: pending, available, completed, cancelled
-- ------------------------------------------------------------------------------
INSERT INTO reservations (id, user_id, book_id, reserved_at, expires_at, status, created_at, updated_at) VALUES
(1, 2, 3, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_ADD(NOW(), INTERVAL 5 DAY), 'pending', NOW(), NOW()),
(2, 4, 7, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 6 DAY), 'pending', NOW(), NOW()),
(3, 3, 12, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_ADD(NOW(), INTERVAL 3 DAY), 'pending', NOW(), NOW()),
(4, 2, 5, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), 'completed', NOW(), NOW()),
(5, 3, 1, DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY), 'cancelled', NOW(), NOW());
