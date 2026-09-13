<?php
// ====================================================================
// BookVerse REST API - Update Book (Staff & Admin)
// PUT /api/books/{id} or /books/update_book.php?id=X
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/validation.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../middleware/role_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'PUT' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

// Authenticate and check role
$currentUser = AuthMiddleware::authenticate();
RoleMiddleware::requireStaffOrAdmin($currentUser);

$id = isset($_GET['id']) && is_numeric($_GET['id']) ? (int)$_GET['id'] : null;
$input = getJsonInput();

if (!$id && isset($input['id']) && is_numeric($input['id'])) {
    $id = (int)$input['id'];
}

if (!$id) {
    sendError('Book ID is required', 400);
}

$db = Database::getConnection();

// Check if book exists
$checkStmt = $db->prepare("SELECT * FROM books WHERE id = :id LIMIT 1");
$checkStmt->execute(['id' => $id]);
$existingBook = $checkStmt->fetch();

if (!$existingBook) {
    sendError('Book not found', 404);
}

$title = isset($input['title']) ? trim($input['title']) : $existingBook['title'];
$author = isset($input['author']) ? trim($input['author']) : $existingBook['author'];
$isbn = isset($input['isbn']) ? trim($input['isbn']) : $existingBook['isbn'];
$description = isset($input['description']) ? trim($input['description']) : $existingBook['description'];
$price = isset($input['price']) ? $input['price'] : $existingBook['price'];
$stockQuantity = isset($input['stock_quantity']) ? $input['stock_quantity'] : $existingBook['stock_quantity'];
$categoryId = array_key_exists('category_id', $input) ? (!empty($input['category_id']) ? (int)$input['category_id'] : null) : $existingBook['category_id'];
$imageUrl = isset($input['image_url']) ? trim($input['image_url']) : $existingBook['image_url'];

$errors = Validator::validateBook([
    'title' => $title,
    'author' => $author,
    'price' => $price,
    'stock_quantity' => $stockQuantity
], false);

if (!empty($errors)) {
    sendError(implode(', ', $errors), 400);
}

// Check ISBN uniqueness if changed
if ($isbn !== null && $isbn !== $existingBook['isbn']) {
    $isbnStmt = $db->prepare("SELECT id FROM books WHERE isbn = :isbn AND id != :id LIMIT 1");
    $isbnStmt->execute(['isbn' => $isbn, 'id' => $id]);
    if ($isbnStmt->fetch()) {
        sendError('Another book with this ISBN already exists', 409);
    }
}

// Check category if changed
if ($categoryId !== null) {
    $catStmt = $db->prepare("SELECT id FROM categories WHERE id = :id LIMIT 1");
    $catStmt->execute(['id' => $categoryId]);
    if (!$catStmt->fetch()) {
        sendError('Specified category does not exist', 400);
    }
}

$updateStmt = $db->prepare("
    UPDATE books SET
        title = :title,
        author = :author,
        isbn = :isbn,
        description = :description,
        price = :price,
        stock_quantity = :stock_quantity,
        image_url = :image_url,
        category_id = :category_id
    WHERE id = :id
");

$updateStmt->execute([
    'title'          => Validator::sanitize($title),
    'author'         => Validator::sanitize($author),
    'isbn'           => $isbn,
    'description'    => $description,
    'price'          => floatval($price),
    'stock_quantity' => intval($stockQuantity),
    'image_url'      => !empty($imageUrl) ? $imageUrl : null,
    'category_id'    => $categoryId,
    'id'             => $id,
]);

// Retrieve updated book
$stmt = $db->prepare("
    SELECT b.*, c.name AS category_name
    FROM books b
    LEFT JOIN categories c ON b.category_id = c.id
    WHERE b.id = :id
");
$stmt->execute(['id' => $id]);
$updatedBook = $stmt->fetch();

$updatedBook['id'] = (int)$updatedBook['id'];
$updatedBook['price'] = (float)$updatedBook['price'];
$updatedBook['stock_quantity'] = (int)$updatedBook['stock_quantity'];
$updatedBook['category_id'] = $updatedBook['category_id'] !== null ? (int)$updatedBook['category_id'] : null;

sendSuccess('Book updated successfully', $updatedBook);
