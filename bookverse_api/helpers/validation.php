<?php
// ====================================================================
// BookVerse REST API - Input Validation Helpers
// ====================================================================

class Validator {
    /**
     * Clean and sanitize input string
     */
    public static function sanitize(string $data): string {
        return htmlspecialchars(strip_tags(trim($data)), ENT_QUOTES, 'UTF-8');
    }

    /**
     * Validate user registration/update input
     */
    public static function validateUser(array $data, bool $isNew = true): array {
        $errors = [];

        if ($isNew || isset($data['name'])) {
            $name = trim($data['name'] ?? '');
            if (empty($name)) {
                $errors[] = 'Full name is required';
            } elseif (strlen($name) < 3) {
                $errors[] = 'Full name must be at least 3 characters';
            }
        }

        if ($isNew || isset($data['email'])) {
            $email = trim($data['email'] ?? '');
            if (empty($email)) {
                $errors[] = 'Email is required';
            } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $errors[] = 'Please provide a valid email address';
            }
        }

        if ($isNew || !empty($data['password'])) {
            $password = $data['password'] ?? '';
            if ($isNew && empty($password)) {
                $errors[] = 'Password is required';
            } elseif (!empty($password) && strlen($password) < 6) {
                $errors[] = 'Password must be at least 6 characters';
            }
        }

        return $errors;
    }

    /**
     * Validate book input
     */
    public static function validateBook(array $data, bool $isNew = true): array {
        $errors = [];

        if ($isNew || isset($data['title'])) {
            $title = trim($data['title'] ?? '');
            if (empty($title)) {
                $errors[] = 'Book title is required';
            }
        }

        if ($isNew || isset($data['author'])) {
            $author = trim($data['author'] ?? '');
            if (empty($author)) {
                $errors[] = 'Author name is required';
            }
        }

        if ($isNew || isset($data['price'])) {
            if (!isset($data['price']) || !is_numeric($data['price']) || floatval($data['price']) <= 0) {
                $errors[] = 'Price must be greater than 0';
            }
        }

        if ($isNew || isset($data['stock_quantity'])) {
            if (!isset($data['stock_quantity']) || !is_numeric($data['stock_quantity']) || intval($data['stock_quantity']) < 0) {
                $errors[] = 'Stock quantity cannot be negative';
            }
        }

        return $errors;
    }

    /**
     * Validate category input
     */
    public static function validateCategory(array $data): array {
        $errors = [];
        $name = trim($data['name'] ?? '');
        if (empty($name)) {
            $errors[] = 'Category name is required';
        }
        return $errors;
    }
}
