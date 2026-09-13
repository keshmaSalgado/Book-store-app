<?php
// ====================================================================
// BookVerse REST API - Search Books by Title or Author
// GET /api/books/search?query=XYZ
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method Not Allowed', 405);
}

$query = trim($_GET['query'] ?? '');

$db = Database::getConnection();

if (empty($query)) {
    // If empty query, return all books
    $stmt = $db->query("
        SELECT 
            b.id, b.title, b.author, b.isbn, b.description, b.price,
            b.stock_quantity, b.image_url, b.category_id, c.name AS category_name,
            b.created_at, b.updated_at
        FROM books b
        LEFT JOIN categories c ON b.category_id = c.id
        ORDER BY b.title ASC
    ");
} else {
    $searchPattern = '%' . $query . '%';
    $stmt = $db->prepare("
        SELECT 
            b.id, b.title, b.author, b.isbn, b.description, b.price,
            b.stock_quantity, b.image_url, b.category_id, c.name AS category_name,
            b.created_at, b.updated_at
        FROM books b
        LEFT JOIN categories c ON b.category_id = c.id
        WHERE b.title LIKE :query_title OR b.author LIKE :query_author OR b.isbn LIKE :query_isbn
        ORDER BY b.title ASC
    ");
    $stmt->execute([
        'query_title'  => $searchPattern,
        'query_author' => $searchPattern,
        'query_isbn'   => $searchPattern,
    ]);
}

$books = $stmt->fetchAll();

foreach ($books as &$book) {
    $book['id'] = (int)$book['id'];
    $book['price'] = (float)$book['price'];
    $book['stock_quantity'] = (int)$book['stock_quantity'];
    $book['category_id'] = $book['category_id'] !== null ? (int)$book['category_id'] : null;
}

sendSuccess('Search completed', $books);
