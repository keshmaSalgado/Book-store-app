<?php
// ====================================================================
// BookVerse REST API - Get Single Book Details
// GET /api/books/{id} or /books/get_book.php?id=X
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method Not Allowed', 405);
}

$id = isset($_GET['id']) && is_numeric($_GET['id']) ? (int)$_GET['id'] : null;

if (!$id) {
    sendError('Book ID is required', 400);
}

$db = Database::getConnection();

$stmt = $db->prepare("
    SELECT 
        b.id,
        b.title,
        b.author,
        b.isbn,
        b.description,
        b.price,
        b.stock_quantity,
        b.image_url,
        b.category_id,
        c.name AS category_name,
        c.description AS category_description,
        b.created_at,
        b.updated_at
    FROM books b
    LEFT JOIN categories c ON b.category_id = c.id
    WHERE b.id = :id
    LIMIT 1
");
$stmt->execute(['id' => $id]);
$book = $stmt->fetch();

if (!$book) {
    sendError('Book not found', 404);
}

$book['id'] = (int)$book['id'];
$book['price'] = (float)$book['price'];
$book['stock_quantity'] = (int)$book['stock_quantity'];
$book['category_id'] = $book['category_id'] !== null ? (int)$book['category_id'] : null;

sendSuccess('Book retrieved successfully', $book);
