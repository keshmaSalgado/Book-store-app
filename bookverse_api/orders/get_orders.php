<?php
// ====================================================================
// BookVerse REST API - Get Orders
// GET /api/orders
// Supports filter: ?status=pending|processing|shipped|delivered|cancelled
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

$db = Database::getConnection();

$status = $_GET['status'] ?? null;
$params = [];

$query = "
    SELECT 
        o.id,
        o.user_id,
        u.name AS customer_name,
        u.email AS customer_email,
        o.total_amount,
        o.status,
        o.delivery_address,
        o.created_at,
        o.updated_at,
        COUNT(oi.id) AS total_items,
        COALESCE(SUM(oi.quantity), 0) AS total_quantity
    FROM orders o
    INNER JOIN users u ON o.user_id = u.id
    LEFT JOIN order_items oi ON o.id = oi.order_id
    WHERE 1=1
";

// If customer, restrict to own orders
if ($role === 'customer') {
    $query .= " AND o.user_id = :user_id";
    $params['user_id'] = $userId;
}

// Optional status filter
if (!empty($status)) {
    $query .= " AND o.status = :status";
    $params['status'] = strtolower($status);
}

$query .= " GROUP BY o.id ORDER BY o.created_at DESC";

$stmt = $db->prepare($query);
$stmt->execute($params);
$orders = $stmt->fetchAll();

foreach ($orders as &$order) {
    $order['id'] = (int)$order['id'];
    $order['user_id'] = (int)$order['user_id'];
    $order['total_amount'] = (float)$order['total_amount'];
    $order['total_items'] = (int)$order['total_items'];
    $order['total_quantity'] = (int)$order['total_quantity'];
}

sendSuccess('Orders retrieved successfully', $orders);
