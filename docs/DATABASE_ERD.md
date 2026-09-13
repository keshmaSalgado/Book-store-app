# BookVerse - Database Schema & ER Diagram Description
**Course**: SEN5001 Mobile and Web Technologies  
**Database Name**: `bookverse_db`  
**Engine**: MySQL InnoDB (Character set: `utf8mb4_unicode_ci`)

---

## 1. Entity-Relationship Overview

```
 [Category] 1 ────────────< N [Book]
                                │ 1
                                │
               ┌────────────────┴────────────────┐
               │ 1                               │ 1
               ▼ N                               ▼ N
         [Cart Item] <─────────── 1 [Cart]  [Order Item] <────────── 1 [Order]
                                      │                                 │
                                      │ 1                               │ N
                                      ▼ 1                               ▼ 1
                                  [User] ───────────────────────────────┘
```

---

## 2. Table Specifications

### 2.1 `users`
Stores user credentials, roles, and status for authentication and authorization.
- `id`: INT AUTO_INCREMENT PRIMARY KEY
- `name`: VARCHAR(100) NOT NULL
- `email`: VARCHAR(150) NOT NULL UNIQUE
- `password`: VARCHAR(255) NOT NULL (Bcrypt hash)
- `role`: ENUM('customer', 'staff', 'admin') DEFAULT 'customer'
- `status`: ENUM('active', 'inactive') DEFAULT 'active'
- `created_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- `updated_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

### 2.2 `categories`
Organizes books into distinct genres and thematic sections.
- `id`: INT AUTO_INCREMENT PRIMARY KEY
- `name`: VARCHAR(100) NOT NULL UNIQUE
- `description`: TEXT
- `created_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

### 2.3 `books`
Contains book catalog metadata, pricing, stock levels, and category foreign keys.
- `id`: INT AUTO_INCREMENT PRIMARY KEY
- `title`: VARCHAR(255) NOT NULL
- `author`: VARCHAR(255) NOT NULL
- `isbn`: VARCHAR(50) UNIQUE
- `description`: TEXT
- `price`: DECIMAL(10,2) NOT NULL
- `stock_quantity`: INT NOT NULL DEFAULT 0
- `image_url`: VARCHAR(500)
- `category_id`: INT NULL (Foreign Key -> `categories(id)` ON DELETE SET NULL)
- `created_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- `updated_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

### 2.4 `carts`
Represents an active shopping session belonging to a customer.
- `id`: INT AUTO_INCREMENT PRIMARY KEY
- `user_id`: INT NOT NULL UNIQUE (Foreign Key -> `users(id)` ON DELETE CASCADE)
- `created_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

### 2.5 `cart_items`
Bridge table linking carts with selected books and desired purchase quantities.
- `id`: INT AUTO_INCREMENT PRIMARY KEY
- `cart_id`: INT NOT NULL (Foreign Key -> `carts(id)` ON DELETE CASCADE)
- `book_id`: INT NOT NULL (Foreign Key -> `books(id)` ON DELETE CASCADE)
- `quantity`: INT NOT NULL DEFAULT 1
- **Constraint**: `UNIQUE(cart_id, book_id)` ensures a book is not duplicated in the same cart.

### 2.6 `orders`
Header table recording placed orders, payment totals, delivery address, and progress status.
- `id`: INT AUTO_INCREMENT PRIMARY KEY
- `user_id`: INT NOT NULL (Foreign Key -> `users(id)` ON DELETE CASCADE)
- `total_amount`: DECIMAL(10,2) NOT NULL DEFAULT 0.00
- `status`: ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending'
- `delivery_address`: TEXT NOT NULL
- `created_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- `updated_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

### 2.7 `order_items`
Individual line items associated with each order, preserving price at time of purchase.
- `id`: INT AUTO_INCREMENT PRIMARY KEY
- `order_id`: INT NOT NULL (Foreign Key -> `orders(id)` ON DELETE CASCADE)
- `book_id`: INT NOT NULL (Foreign Key -> `books(id)` ON DELETE RESTRICT)
- `quantity`: INT NOT NULL
- `price`: DECIMAL(10,2) NOT NULL

---

## 3. Relational Cardinality & Business Rules

1. **User to Cart**: **1 : 1**  
   Each customer possesses exactly one active shopping cart in the database.
2. **User to Orders**: **1 : N**  
   A single customer can place multiple orders over time.
3. **Category to Books**: **1 : N**  
   A category can group zero, one, or many books. If a category is deleted, books remain preserved with `category_id` set to `NULL`.
4. **Cart to Cart Items**: **1 : N**  
   A cart can contain multiple books. Each item tracks quantity.
5. **Order to Order Items**: **1 : N**  
   An order has one or more line items.
6. **Book to Order Items**: **1 : N (RESTRICT)**  
   A book cannot be deleted if it exists in past customer order records (`ON DELETE RESTRICT`), maintaining audit and accounting integrity.
