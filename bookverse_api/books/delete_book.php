<?php
// ====================================================================
// BookVerse REST API - Delete Book (Admin Only)
// DELETE /api/books/{id} or /books/delete_book.php?id=X
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../middleware/role_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'DELETE' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

// Authenticate and require Admin role
$currentUser = AuthMiddleware::authenticate();
RoleMiddleware::requireAdmin($currentUser);

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
$checkStmt = $db->prepare("SELECT id, title FROM books WHERE id = :id LIMIT 1");
$checkStmt->execute(['id' => $id]);
$book = $checkStmt->fetch();

if (!$book) {
    sendError('Book not found', 404);
}

try {
    $deleteStmt = $db->prepare("DELETE FROM books WHERE id = :id");
    $deleteStmt->execute(['id' => $id]);

    sendSuccess('Book deleted successfully', ['deleted_id' => $id, 'title' => $book['title']]);
} catch (PDOException $e) {
    // If book is referenced in orders and foreign key restricts delete
    if ($e->getCode() == '23000') {
        sendError('Cannot delete book because it is part of existing customer orders', 409);
    }
    sendError('Failed to delete book: ' . $e->getMessage(), 500);
}
