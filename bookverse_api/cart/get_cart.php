<?php
// ====================================================================
// BookVerse REST API - Get Customer Shopping Cart
// GET /api/cart
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method Not Allowed', 405);
}

$currentUser = AuthMiddleware::authenticate();
$userId = (int)$currentUser['id'];

$db = Database::getConnection();

// Get or create cart for user
$cartStmt = $db->prepare("SELECT id FROM carts WHERE user_id = :user_id LIMIT 1");
$cartStmt->execute(['user_id' => $userId]);
$cart = $cartStmt->fetch();

if (!$cart) {
    $createCart = $db->prepare("INSERT INTO carts (user_id) VALUES (:user_id)");
    $createCart->execute(['user_id' => $userId]);
    $cartId = (int)$db->lastInsertId();
} else {
    $cartId = (int)$cart['id'];
}

// Fetch items in cart with book details
$itemsStmt = $db->prepare("
    SELECT 
        ci.id AS cart_item_id,
        ci.quantity,
        b.id AS book_id,
        b.title,
        b.author,
        b.isbn,
        b.price,
        b.stock_quantity,
        b.image_url,
        c.name AS category_name,
        (ci.quantity * b.price) AS subtotal
    FROM cart_items ci
    INNER JOIN books b ON ci.book_id = b.id
    LEFT JOIN categories c ON b.category_id = c.id
    WHERE ci.cart_id = :cart_id
    ORDER BY ci.id DESC
");
$itemsStmt->execute(['cart_id' => $cartId]);
$items = $itemsStmt->fetchAll();

$totalAmount = 0.0;
$totalItems = 0;

foreach ($items as &$item) {
    $item['cart_item_id'] = (int)$item['cart_item_id'];
    $item['book_id'] = (int)$item['book_id'];
    $item['quantity'] = (int)$item['quantity'];
    $item['price'] = (float)$item['price'];
    $item['stock_quantity'] = (int)$item['stock_quantity'];
    $item['subtotal'] = round((float)$item['subtotal'], 2);

    $totalAmount += $item['subtotal'];
    $totalItems += $item['quantity'];
}

sendSuccess('Cart retrieved successfully', [
    'cart_id'      => $cartId,
    'total_items'  => $totalItems,
    'total_amount' => round($totalAmount, 2),
    'items'        => $items
]);
