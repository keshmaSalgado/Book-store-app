-- ====================================================================
-- BookVerse - Online Bookstore Database
-- Module: SEN5001 Mobile and Web Technologies
-- Database Name: bookverse_db
-- ====================================================================

CREATE DATABASE IF NOT EXISTS `bookverse_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `bookverse_db`;

-- Drop existing tables in reverse dependency order
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `cart_items`;
DROP TABLE IF EXISTS `carts`;
DROP TABLE IF EXISTS `books`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `users`;
SET FOREIGN_KEY_CHECKS = 1;

-- ====================================================================
-- TABLE: users
-- ====================================================================
CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM('customer', 'staff', 'admin') NOT NULL DEFAULT 'customer',
  `status` ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- TABLE: categories
-- ====================================================================
CREATE TABLE `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- TABLE: books
-- ====================================================================
CREATE TABLE `books` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `author` VARCHAR(255) NOT NULL,
  `isbn` VARCHAR(50) UNIQUE,
  `description` TEXT,
  `price` DECIMAL(10,2) NOT NULL,
  `stock_quantity` INT NOT NULL DEFAULT 0,
  `image_url` VARCHAR(500),
  `category_id` INT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_books_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- TABLE: carts
-- ====================================================================
CREATE TABLE `carts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL UNIQUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_carts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- TABLE: cart_items
-- ====================================================================
CREATE TABLE `cart_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `cart_id` INT NOT NULL,
  `book_id` INT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  CONSTRAINT `fk_cart_items_cart` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_items_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `uq_cart_book` UNIQUE (`cart_id`, `book_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- TABLE: orders
-- ====================================================================
CREATE TABLE `orders` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `status` ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
  `delivery_address` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- TABLE: order_items
-- ====================================================================
CREATE TABLE `order_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` INT NOT NULL,
  `book_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- SEED DATA: Users
-- Passwords:
-- Admin: Admin@123
-- Staff: Staff@123
-- Customers: Customer@123
-- ====================================================================
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `status`) VALUES
(1, 'System Administrator', 'admin@bookverse.com', '$2y$10$ncux3xQj5olmwIQpzXAZIe4nVXlGKyQpTAO9bXR8Hy44Clgftp.hq', 'admin', 'active'),
(2, 'Sarah Jenkins (Staff)', 'staff@bookverse.com', '$2y$10$2wybudi8KaBrY9B2Aou0dOms5ivuNh1oqwa7JHjyrvV1VKLj1T32C', 'staff', 'active'),
(3, 'Alice Johnson', 'customer1@bookverse.com', '$2y$10$CmslRod.bTT.qJKbcpLWWO31iKcV.z0CJPDQ8u/zOJcRvQsQ5jzm.', 'customer', 'active'),
(4, 'Bob Smith', 'customer2@bookverse.com', '$2y$10$CmslRod.bTT.qJKbcpLWWO31iKcV.z0CJPDQ8u/zOJcRvQsQ5jzm.', 'customer', 'active');

-- ====================================================================
-- SEED DATA: Categories
-- ====================================================================
INSERT INTO `categories` (`id`, `name`, `description`) VALUES
(1, 'Fiction', 'Imaginative literature including contemporary novels, literary classics, and modern epics.'),
(2, 'Science', 'Explorations of astrophysics, biology, quantum phenomena, and nature wonders.'),
(3, 'Technology', 'Cutting-edge guides to software engineering, cloud computing, AI, and systems programming.'),
(4, 'Mystery', 'Riveting detective fiction, gripping thrillers, forensic crime, and whodunits.'),
(5, 'Romance', 'Heartfelt love stories, emotional journeys, and modern relationships.');

-- ====================================================================
-- SEED DATA: Books (16 realistic books across all categories)
-- ====================================================================
INSERT INTO `books` (`id`, `title`, `author`, `isbn`, `description`, `price`, `stock_quantity`, `image_url`, `category_id`) VALUES
(1, 'The Midnight Library', 'Matt Haig', '978-0525559474', 'Between life and death there is a library where every book gives you a chance to try another life you could have lived.', 18.99, 25, 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=600&q=80', 1),
(2, 'Where the Crawdads Sing', 'Delia Owens', '978-0735219090', 'A painful coming-of-age story and a murder mystery centered around a barefoot young marsh girl in North Carolina.', 15.50, 18, 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=600&q=80', 1),
(3, 'Klara and the Sun', 'Kazuo Ishiguro', '978-0593318171', 'A thrilling look at our rapidly changing modern world through the eyes of an unforgettable Artificial Friend.', 19.95, 12, 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?auto=format&fit=crop&w=600&q=80', 1),
(4, 'Cosmos', 'Carl Sagan', '978-0345539434', 'The landmark exploration of the universe, cosmic evolution, and humanity origin story by legendary astrophysicist Carl Sagan.', 22.00, 30, 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80', 2),
(5, 'A Brief History of Time', 'Stephen Hawking', '978-0553380163', 'A masterpiece that explores the profound mysteries of the universe, black holes, time travel, and the big bang.', 21.50, 14, 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?auto=format&fit=crop&w=600&q=80', 2),
(6, 'The Gene: An Intimate History', 'Siddhartha Mukherjee', '978-1476733524', 'A magnificent history of the gene and a response to the defining question of the future: Does heredity dictate destiny?', 24.99, 8, 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=600&q=80', 2),
(7, 'Clean Code: Agile Software Craftsmanship', 'Robert C. Martin', '978-0132350884', 'Even bad code can function. But if code isn\'t clean, it can bring a development organization to its knees.', 38.50, 20, 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=600&q=80', 3),
(8, 'Designing Data-Intensive Applications', 'Martin Kleppmann', '978-1449373320', 'The definitive guide to the principles, architectures, and systems behind reliable, scalable, and maintainable data systems.', 44.99, 15, 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80', 3),
(9, 'Flutter in Action', 'Eric Windmill', '978-1617296147', 'An in-depth, hands-on guide to building multi-platform mobile and web applications with Google Flutter framework.', 36.00, 9, 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=600&q=80', 3),
(10, 'Artificial Intelligence: A Modern Approach', 'Stuart Russell & Peter Norvig', '978-0134610993', 'The authoritative, most widely used comprehensive introduction to the theory and practice of artificial intelligence.', 52.00, 3, 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=600&q=80', 3),
(11, 'The Silent Patient', 'Alex Michaelides', '978-1250301697', 'A shocking psychological thriller about a woman\'s act of violence against her husband—and of the therapist obsessed with uncovering her motive.', 16.99, 22, 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?auto=format&fit=crop&w=600&q=80', 4),
(12, 'The Maid', 'Nita Prose', '978-0593356159', 'A charmingly eccentric hotel maid discovers a guest murdered in his bed, turning her orderly life upside down.', 14.50, 11, 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?auto=format&fit=crop&w=600&q=80', 4),
(13, 'Gone Girl', 'Gillian Flynn', '978-0307588371', 'On the morning of his fifth wedding anniversary, Nick Dunne arrives home to find that his wife Amy has vanished without a trace.', 17.20, 2, 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80', 4),
(14, 'Pride and Prejudice', 'Jane Austen', '978-0141439518', 'The romantic clash between the opinionated Elizabeth Bennet and her handsome and arrogant beau, Mr. Darcy.', 12.99, 28, 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&w=600&q=80', 5),
(15, 'Book Lovers', 'Emily Henry', '978-0593334836', 'Two literary rivals find themselves repeatedly thrown together in a picturesque North Carolina mountain town.', 15.99, 16, 'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?auto=format&fit=crop&w=600&q=80', 5),
(16, 'The Seven Husbands of Evelyn Hugo', 'Taylor Jenkins Reid', '978-1501161933', 'Aging and reclusive Hollywood movie icon Evelyn Hugo is finally ready to tell the truth about her glamorous and scandalous life.', 17.00, 19, 'https://images.unsplash.com/photo-1463320726281-696a485928c7?auto=format&fit=crop&w=600&q=80', 5);

-- ====================================================================
-- SEED DATA: Sample Orders & Items
-- ====================================================================
INSERT INTO `orders` (`id`, `user_id`, `total_amount`, `status`, `delivery_address`, `created_at`) VALUES
(1001, 3, 57.49, 'delivered', '42 Maple Street, Westview, NY 10001', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(1002, 3, 38.50, 'processing', '42 Maple Street, Westview, NY 10001', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1003, 4, 39.94, 'pending', '742 Evergreen Terrace, Springfield, OR 97477', NOW());

INSERT INTO `order_items` (`order_id`, `book_id`, `quantity`, `price`) VALUES
(1001, 1, 1, 18.99),
(1001, 7, 1, 38.50),
(1002, 7, 1, 38.50),
(1003, 3, 2, 19.97);

-- Create a cart for Alice (Customer 1) with 1 item
INSERT INTO `carts` (`id`, `user_id`) VALUES (1, 3);
INSERT INTO `cart_items` (`cart_id`, `book_id`, `quantity`) VALUES (1, 4, 1);
