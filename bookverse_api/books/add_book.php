<?php
// ====================================================================
// BookVerse REST API - Add Book (Staff & Admin)
// POST /api/books
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/validation.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../middleware/role_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

// Authenticate and check role
$currentUser = AuthMiddleware::authenticate();
RoleMiddleware::requireStaffOrAdmin($currentUser);

$input = getJsonInput();

$title = trim($input['title'] ?? '');
$author = trim($input['author'] ?? '');
$isbn = !empty($input['isbn']) ? trim($input['isbn']) : null;
$description = trim($input['description'] ?? '');
$price = $input['price'] ?? null;
$stockQuantity = $input['stock_quantity'] ?? 0;
$categoryId = !empty($input['category_id']) ? (int)$input['category_id'] : null;
$imageUrl = trim($input['image_url'] ?? '');

$errors = Validator::validateBook([
    'title' => $title,
    'author' => $author,
    'price' => $price,
    'stock_quantity' => $stockQuantity
], true);

if (!empty($errors)) {
    sendError(implode(', ', $errors), 400);
}

$db = Database::getConnection();

// Check ISBN uniqueness
if ($isbn !== null) {
    $isbnStmt = $db->prepare("SELECT id FROM books WHERE isbn = :isbn LIMIT 1");
    $isbnStmt->execute(['isbn' => $isbn]);
    if ($isbnStmt->fetch()) {
        sendError('A book with this ISBN already exists', 409);
    }
}

// Validate category exists if provided
if ($categoryId !== null) {
    $catStmt = $db->prepare("SELECT id FROM categories WHERE id = :id LIMIT 1");
    $catStmt->execute(['id' => $categoryId]);
    if (!$catStmt->fetch()) {
        sendError('Specified category does not exist', 400);
    }
}

$insertStmt = $db->prepare("
    INSERT INTO books (title, author, isbn, description, price, stock_quantity, image_url, category_id)
    VALUES (:title, :author, :isbn, :description, :price, :stock_quantity, :image_url, :category_id)
");

$insertStmt->execute([
    'title'          => Validator::sanitize($title),
    'author'         => Validator::sanitize($author),
    'isbn'           => $isbn,
    'description'    => $description,
    'price'          => floatval($price),
    'stock_quantity' => intval($stockQuantity),
    'image_url'      => !empty($imageUrl) ? $imageUrl : null,
    'category_id'    => $categoryId,
]);

$bookId = (int)$db->lastInsertId();

// Retrieve newly created book with category
$stmt = $db->prepare("
    SELECT b.*, c.name AS category_name
    FROM books b
    LEFT JOIN categories c ON b.category_id = c.id
    WHERE b.id = :id
");
$stmt->execute(['id' => $bookId]);
$newBook = $stmt->fetch();

$newBook['id'] = (int)$newBook['id'];
$newBook['price'] = (float)$newBook['price'];
$newBook['stock_quantity'] = (int)$newBook['stock_quantity'];
$newBook['category_id'] = $newBook['category_id'] !== null ? (int)$newBook['category_id'] : null;

sendSuccess('Book added successfully', $newBook, 201);
