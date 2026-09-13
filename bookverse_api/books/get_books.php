<?php
// ====================================================================
// BookVerse REST API - Get All Books
// GET /api/books
// Supports filters: ?category_id=X, ?filter=featured|latest, ?limit=N
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method Not Allowed', 405);
}

$db = Database::getConnection();

$categoryId = isset($_GET['category_id']) && is_numeric($_GET['category_id']) ? (int)$_GET['category_id'] : null;
$filter = $_GET['filter'] ?? null;
$limit = isset($_GET['limit']) && is_numeric($_GET['limit']) ? (int)$_GET['limit'] : null;

$query = "
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
        b.created_at,
        b.updated_at
    FROM books b
    LEFT JOIN categories c ON b.category_id = c.id
    WHERE 1=1
";

$params = [];

if ($categoryId !== null) {
    $query .= " AND b.category_id = :category_id";
    $params['category_id'] = $categoryId;
}

if ($filter === 'latest') {
    $query .= " ORDER BY b.created_at DESC";
} elseif ($filter === 'featured') {
    $query .= " ORDER BY b.stock_quantity DESC, b.price DESC";
} else {
    $query .= " ORDER BY b.id ASC";
}

if ($limit !== null && $limit > 0) {
    $query .= " LIMIT " . intval($limit);
}

$stmt = $db->prepare($query);
$stmt->execute($params);
$books = $stmt->fetchAll();

// Format numbers for JSON
foreach ($books as &$book) {
    $book['id'] = (int)$book['id'];
    $book['price'] = (float)$book['price'];
    $book['stock_quantity'] = (int)$book['stock_quantity'];
    $book['category_id'] = $book['category_id'] !== null ? (int)$book['category_id'] : null;
}

sendSuccess('Books retrieved successfully', $books);
