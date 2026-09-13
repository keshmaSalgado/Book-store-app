<?php
// ====================================================================
// BookVerse REST API - Get All Categories
// GET /api/categories
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method Not Allowed', 405);
}

$db = Database::getConnection();

// Also count books in each category for handy UI badges
$stmt = $db->query("
    SELECT 
        c.id,
        c.name,
        c.description,
        c.created_at,
        COUNT(b.id) AS book_count
    FROM categories c
    LEFT JOIN books b ON c.id = b.category_id
    GROUP BY c.id
    ORDER BY c.name ASC
");
$categories = $stmt->fetchAll();

foreach ($categories as &$cat) {
    $cat['id'] = (int)$cat['id'];
    $cat['book_count'] = (int)$cat['book_count'];
}

sendSuccess('Categories retrieved successfully', $categories);
