<?php
// ====================================================================
// BookVerse REST API - Get Single Order Details
// GET /api/orders/{id} or /orders/get_order.php?id=X
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method Not Allowed', 405);
}

$currentUser = AuthMiddleware::authenticate();
$userId = (int)$currentUser['id'];
$role = $currentUser['role'];

$orderId = isset($_GET['id']) && is_numeric($_GET['id']) ? (int)$_GET['id'] : null;

if (!$orderId) {
    sendError('Order ID is required', 400);
}

$db = Database::getConnection();

// Fetch order header
$orderStmt = $db->prepare("
    SELECT 
        o.id,
        o.user_id,
        u.name AS customer_name,
        u.email AS customer_email,
        o.total_amount,
        o.status,
        o.delivery_address,
        o.created_at,
        o.updated_at
    FROM orders o
    INNER JOIN users u ON o.user_id = u.id
    WHERE o.id = :order_id
    LIMIT 1
");
$orderStmt->execute(['order_id' => $orderId]);
$order = $orderStmt->fetch();

if (!$order) {
    sendError('Order not found', 404);
}

// Access check: customers can only view their own order
if ($role === 'customer' && (int)$order['user_id'] !== $userId) {
    sendError('Forbidden: You cannot view another customer\'s order', 403);
}

// Fetch line items
$itemsStmt = $db->prepare("
    SELECT 
        oi.id AS order_item_id,
        oi.book_id,
        b.title,
        b.author,
        b.image_url,
        oi.quantity,
        oi.price,
        (oi.quantity * oi.price) AS subtotal
    FROM order_items oi
    INNER JOIN books b ON oi.book_id = b.id
    WHERE oi.order_id = :order_id
");
$itemsStmt->execute(['order_id' => $orderId]);
$items = $itemsStmt->fetchAll();

foreach ($items as &$item) {
    $item['order_item_id'] = (int)$item['order_item_id'];
    $item['book_id'] = (int)$item['book_id'];
    $item['quantity'] = (int)$item['quantity'];
    $item['price'] = (float)$item['price'];
    $item['subtotal'] = round((float)$item['subtotal'], 2);
}

$order['id'] = (int)$order['id'];
$order['user_id'] = (int)$order['user_id'];
$order['total_amount'] = (float)$order['total_amount'];
$order['items'] = $items;

sendSuccess('Order details retrieved successfully', $order);
