// ==============================================================================
// Library Management System - MongoDB Initialization & Seed Script
// ==============================================================================

const dbName = 'library_management';
const dbTarget = db.getSiblingDB(dbName);

print(`[MongoDB Init] Initializing database: ${dbName}...`);

// ------------------------------------------------------------------------------
// 1. Create Collections & Indexes
// ------------------------------------------------------------------------------

// Users
dbTarget.createCollection('users');
dbTarget.users.createIndex({ id: 1 }, { unique: true });
dbTarget.users.createIndex({ email: 1 }, { unique: true });
dbTarget.users.createIndex({ role: 1 });

// Books
dbTarget.createCollection('books');
dbTarget.books.createIndex({ id: 1 }, { unique: true });
dbTarget.books.createIndex({ isbn: 1 }, { unique: true });
dbTarget.books.createIndex({ title: "text", author: "text", category: "text" });
dbTarget.books.createIndex({ category: 1 });
dbTarget.books.createIndex({ available_quantity: 1 });

// Borrowings
dbTarget.createCollection('borrowings');
dbTarget.borrowings.createIndex({ id: 1 }, { unique: true });
dbTarget.borrowings.createIndex({ user_id: 1 });
dbTarget.borrowings.createIndex({ book_id: 1 });
dbTarget.borrowings.createIndex({ status: 1 });
dbTarget.borrowings.createIndex({ due_date: 1 });

// Reservations
dbTarget.createCollection('reservations');
dbTarget.reservations.createIndex({ id: 1 }, { unique: true });
dbTarget.reservations.createIndex({ user_id: 1 });
dbTarget.reservations.createIndex({ book_id: 1 });
dbTarget.reservations.createIndex({ status: 1 });
dbTarget.reservations.createIndex({ expires_at: 1 });

// Counters (Auto-increment sequence)
dbTarget.createCollection('counters');
dbTarget.counters.createIndex({ _id: 1 });

// ------------------------------------------------------------------------------
// 2. Seed Counters
// ------------------------------------------------------------------------------
dbTarget.counters.deleteMany({});
dbTarget.counters.insertMany([
  { _id: 'userId', seq: 4 },
  { _id: 'bookId', seq: 16 },
  { _id: 'borrowingId', seq: 8 },
  { _id: 'reservationId', seq: 5 }
]);

// ------------------------------------------------------------------------------
// 3. Seed Users
// ------------------------------------------------------------------------------
dbTarget.users.deleteMany({});
const now = new Date();

dbTarget.users.insertMany([
  {
    id: 1,
    name: 'System Administrator',
    email: 'admin@library.edu',
    password_hash: '$2a$10$wH2xL3h0K5h/O7nQ1h6Bq.f5wXkM7yZpQ1oN9bC3vD5eF7gH9iJ1k',
    role: 'admin',
    created_at: now,
    updated_at: now
  },
  {
    id: 2,
    name: 'Alex Johnson',
    email: 'student1@library.edu',
    password_hash: '$2a$10$r9G8h7J6k5L4m3N2o1P0q.v8wXkM7yZpQ1oN9bC3vD5eF7gH9iJ1k',
    role: 'student',
    created_at: now,
    updated_at: now
  },
  {
    id: 3,
    name: 'Sophia Chen',
    email: 'student2@library.edu',
    password_hash: '$2a$10$r9G8h7J6k5L4m3N2o1P0q.v8wXkM7yZpQ1oN9bC3vD5eF7gH9iJ1k',
    role: 'student',
    created_at: now,
    updated_at: now
  },
  {
    id: 4,
    name: 'Marcus Aurelius Williams',
    email: 'student3@library.edu',
    password_hash: '$2a$10$r9G8h7J6k5L4m3N2o1P0q.v8wXkM7yZpQ1oN9bC3vD5eF7gH9iJ1k',
    role: 'student',
    created_at: now,
    updated_at: now
  }
]);

// ------------------------------------------------------------------------------
// 4. Seed Books
// ------------------------------------------------------------------------------
dbTarget.books.deleteMany({});
dbTarget.books.insertMany([
  {
    id: 1,
    title: 'Clean Code: A Handbook of Agile Software Craftsmanship',
    author: 'Robert C. Martin',
    category: 'Computer Science',
    isbn: '978-0132350884',
    description: "Even bad code can function. But if code isn't clean, it can bring a development organization to its knees. A timeless guide to software craftsmanship.",
    cover_image: 'https://images.unsplash.com/photo-1532012164546-f432f2e3777a?w=400',
    quantity: 5,
    available_quantity: 4,
    created_at: now,
    updated_at: now
  },
  {
    id: 2,
    title: 'Introduction to Algorithms (4th Edition)',
    author: 'Thomas H. Cormen, Charles E. Leiserson',
    category: 'Computer Science',
    isbn: '978-0262046305',
    description: 'A comprehensive textbook covering the modern study of computer algorithms, from foundations to advanced dynamic programming and graph theory.',
    cover_image: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
    quantity: 4,
    available_quantity: 2,
    created_at: now,
    updated_at: now
  },
  {
    id: 3,
    title: 'Designing Data-Intensive Applications',
    author: 'Martin Kleppmann',
    category: 'Computer Science',
    isbn: '978-1449373320',
    description: 'The definitive guide to the architecture, data models, storage engines, distributed consensus, and scalability of modern systems.',
    cover_image: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
    quantity: 3,
    available_quantity: 0,
    created_at: now,
    updated_at: now
  },
  {
    id: 4,
    title: 'Artificial Intelligence: A Modern Approach',
    author: 'Stuart Russell, Peter Norvig',
    category: 'Computer Science',
    isbn: '978-0134610993',
    description: 'The most comprehensive and up-to-date introduction to the theory and practice of artificial intelligence, search algorithms, and machine learning.',
    cover_image: 'https://images.unsplash.com/photo-1507842229452-965a3978ff84?w=400',
    quantity: 4,
    available_quantity: 3,
    created_at: now,
    updated_at: now
  },
  {
    id: 5,
    title: 'Computer Networking: A Top-Down Approach',
    author: 'James F. Kurose, Keith W. Ross',
    category: 'Networking',
    isbn: '978-0136681557',
    description: 'Motivates students by presenting networking through the layered architecture from application layer down to the physical layer.',
    cover_image: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=400',
    quantity: 3,
    available_quantity: 2,
    created_at: now,
    updated_at: now
  },
  {
    id: 6,
    title: 'Operating System Concepts (10th Edition)',
    author: 'Abraham Silberschatz, Peter B. Galvin',
    category: 'Computer Science',
    isbn: '978-1119800361',
    description: 'Comprehensive overview of operating system principles, process scheduling, virtual memory, concurrency, and security.',
    cover_image: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=400',
    quantity: 4,
    available_quantity: 4,
    created_at: now,
    updated_at: now
  },
  {
    id: 7,
    title: 'Database System Concepts (7th Edition)',
    author: 'Avi Silberschatz, Henry F. Korth',
    category: 'Data Science',
    isbn: '978-0078022159',
    description: 'Fundamental concepts of relational databases, SQL queries, transaction management, indexing, and NoSQL distributed databases.',
    cover_image: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
    quantity: 3,
    available_quantity: 0,
    created_at: now,
    updated_at: now
  },
  {
    id: 8,
    title: 'Deep Learning',
    author: 'Ian Goodfellow, Yoshua Bengio, Aaron Courville',
    category: 'Data Science',
    isbn: '978-0262035613',
    description: 'An introduction to mathematical background, deep feedforward networks, regularization, convolutional networks, and generative models.',
    cover_image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400',
    quantity: 2,
    available_quantity: 1,
    created_at: now,
    updated_at: now
  },
  {
    id: 9,
    title: 'Linear Algebra and Its Applications',
    author: 'Gilbert Strang',
    category: 'Mathematics',
    isbn: '978-0030105678',
    description: 'Renowned introduction to linear algebra covering vector spaces, eigenvalues, singular value decomposition, and computational techniques.',
    cover_image: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400',
    quantity: 5,
    available_quantity: 5,
    created_at: now,
    updated_at: now
  },
  {
    id: 10,
    title: 'Calculus: Early Transcendentals',
    author: 'James Stewart',
    category: 'Mathematics',
    isbn: '978-1285741550',
    description: 'Success in calculus begins with clarity. Explores differential and integral calculus through vector calculus with geometric intuition.',
    cover_image: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400',
    quantity: 4,
    available_quantity: 3,
    created_at: now,
    updated_at: now
  },
  {
    id: 11,
    title: 'The Feynman Lectures on Physics (Vol. 1)',
    author: 'Richard P. Feynman',
    category: 'Physics',
    isbn: '978-0465024933',
    description: 'Classic physics exposition focusing on mechanics, radiation, thermodynamics, and the underlying atomic nature of the universe.',
    cover_image: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400',
    quantity: 2,
    available_quantity: 1,
    created_at: now,
    updated_at: now
  },
  {
    id: 12,
    title: 'Quantum Mechanics: Concepts and Applications',
    author: 'Nouredine Zettili',
    category: 'Physics',
    isbn: '978-0470026793',
    description: 'Clear, step-by-step introduction to the mathematical formulation and physical foundations of quantum physics with solved problems.',
    cover_image: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400',
    quantity: 2,
    available_quantity: 0,
    created_at: now,
    updated_at: now
  },
  {
    id: 13,
    title: 'Sapiens: A Brief History of Humankind',
    author: 'Yuval Noah Harari',
    category: 'History',
    isbn: '978-0062316097',
    description: 'A groundbreaking narrative exploring how biology and history have defined humans and enhanced our understanding of society and religion.',
    cover_image: 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400',
    quantity: 6,
    available_quantity: 5,
    created_at: now,
    updated_at: now
  },
  {
    id: 14,
    title: 'Guns, Germs, and Steel',
    author: 'Jared Diamond',
    category: 'History',
    isbn: '978-0393354324',
    description: 'Fascinating Pulitzer Prize-winning investigation into the geographic and environmental factors that shaped human civilization.',
    cover_image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=400',
    quantity: 3,
    available_quantity: 3,
    created_at: now,
    updated_at: now
  },
  {
    id: 15,
    title: '1984',
    author: 'George Orwell',
    category: 'Literature',
    isbn: '978-0451524935',
    description: 'The legendary dystopian masterwork on surveillance totalitarianism, truth manipulation, and individual liberty in a police state.',
    cover_image: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
    quantity: 5,
    available_quantity: 4,
    created_at: now,
    updated_at: now
  },
  {
    id: 16,
    title: 'To Kill a Mockingbird',
    author: 'Harper Lee',
    category: 'Literature',
    isbn: '978-0060935467',
    description: 'Pulitzer Prize winner focusing on courage, justice, empathy, and racism in the American South through the eyes of Scout Finch.',
    cover_image: 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400',
    quantity: 4,
    available_quantity: 3,
    created_at: now,
    updated_at: now
  }
]);

// ------------------------------------------------------------------------------
// 5. Seed Borrowings
// ------------------------------------------------------------------------------
dbTarget.borrowings.deleteMany({});
function daysAgo(d) { return new Date(Date.now() - d * 24 * 60 * 60 * 1000); }
function daysAhead(d) { return new Date(Date.now() + d * 24 * 60 * 60 * 1000); }

dbTarget.borrowings.insertMany([
  {
    id: 1,
    user_id: 2,
    book_id: 1,
    borrowed_at: daysAgo(5),
    due_date: daysAhead(9),
    returned_at: null,
    status: 'borrowed',
    created_at: now,
    updated_at: now
  },
  {
    id: 2,
    user_id: 2,
    book_id: 2,
    borrowed_at: daysAgo(20),
    due_date: daysAgo(6),
    returned_at: daysAgo(7),
    status: 'returned',
    created_at: now,
    updated_at: now
  },
  {
    id: 3,
    user_id: 3,
    book_id: 2,
    borrowed_at: daysAgo(18),
    due_date: daysAgo(4),
    returned_at: null,
    status: 'overdue',
    created_at: now,
    updated_at: now
  },
  {
    id: 4,
    user_id: 3,
    book_id: 3,
    borrowed_at: daysAgo(10),
    due_date: daysAhead(4),
    returned_at: null,
    status: 'borrowed',
    created_at: now,
    updated_at: now
  },
  {
    id: 5,
    user_id: 4,
    book_id: 3,
    borrowed_at: daysAgo(8),
    due_date: daysAhead(6),
    returned_at: null,
    status: 'borrowed',
    created_at: now,
    updated_at: now
  },
  {
    id: 6,
    user_id: 4,
    book_id: 5,
    borrowed_at: daysAgo(3),
    due_date: daysAhead(11),
    returned_at: null,
    status: 'borrowed',
    created_at: now,
    updated_at: now
  },
  {
    id: 7,
    user_id: 2,
    book_id: 7,
    borrowed_at: daysAgo(12),
    due_date: daysAhead(2),
    returned_at: null,
    status: 'borrowed',
    created_at: now,
    updated_at: now
  },
  {
    id: 8,
    user_id: 3,
    book_id: 8,
    borrowed_at: daysAgo(15),
    due_date: daysAgo(1),
    returned_at: daysAgo(2),
    status: 'returned',
    created_at: now,
    updated_at: now
  }
]);

// ------------------------------------------------------------------------------
// 6. Seed Reservations
// ------------------------------------------------------------------------------
dbTarget.reservations.deleteMany({});
dbTarget.reservations.insertMany([
  {
    id: 1,
    user_id: 2,
    book_id: 3,
    reserved_at: daysAgo(2),
    expires_at: daysAhead(5),
    status: 'pending',
    created_at: now,
    updated_at: now
  },
  {
    id: 2,
    user_id: 4,
    book_id: 7,
    reserved_at: daysAgo(1),
    expires_at: daysAhead(6),
    status: 'pending',
    created_at: now,
    updated_at: now
  },
  {
    id: 3,
    user_id: 3,
    book_id: 12,
    reserved_at: daysAgo(4),
    expires_at: daysAhead(3),
    status: 'pending',
    created_at: now,
    updated_at: now
  },
  {
    id: 4,
    user_id: 2,
    book_id: 5,
    reserved_at: daysAgo(10),
    expires_at: daysAgo(3),
    status: 'completed',
    created_at: now,
    updated_at: now
  },
  {
    id: 5,
    user_id: 3,
    book_id: 1,
    reserved_at: daysAgo(14),
    expires_at: daysAgo(7),
    status: 'cancelled',
    created_at: now,
    updated_at: now
  }
]);

print(`[MongoDB Init] Initialization complete! Seeded 4 users, 16 books, 8 borrowings, 5 reservations.`);
