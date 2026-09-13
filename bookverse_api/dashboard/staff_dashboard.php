<?php
// ====================================================================
// BookVerse REST API - Store Staff Dashboard Metrics
// GET /api/staff/dashboard
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../middleware/role_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method Not Allowed', 405);
}

// Authenticate and require Staff or Admin
$currentUser = AuthMiddleware::authenticate();
RoleMiddleware::requireStaffOrAdmin($currentUser);

$db = Database::getConnection();

// Total Books
$booksCount = (int)$db->query("SELECT COUNT(*) FROM books")->fetchColumn();

// Total Orders
$ordersCount = (int)$db->query("SELECT COUNT(*) FROM orders")->fetchColumn();

// Pending Orders
$pendingOrders = (int)$db->query("SELECT COUNT(*) FROM orders WHERE status = 'pending'")->fetchColumn();

// Processing Orders
$processingOrders = (int)$db->query("SELECT COUNT(*) FROM orders WHERE status = 'processing'")->fetchColumn();

// Low Stock Books (stock <= 5)
$lowStockBooks = (int)$db->query("SELECT COUNT(*) FROM books WHERE stock_quantity <= 5")->fetchColumn();

// Recent Orders requiring attention
$recentOrdersStmt = $db->query("
    SELECT o.id, u.name AS customer_name, o.total_amount, o.status, o.created_at
    FROM orders o
    INNER JOIN users u ON o.user_id = u.id
    ORDER BY o.created_at DESC
    LIMIT 6
");
$recentOrders = $recentOrdersStmt->fetchAll();

foreach ($recentOrders as &$ro) {
    $ro['id'] = (int)$ro['id'];
    $ro['total_amount'] = (float)$ro['total_amount'];
}

// Low Stock Books list
$lowStockStmt = $db->query("
    SELECT id, title, author, price, stock_quantity
    FROM books
    WHERE stock_quantity <= 5
    ORDER BY stock_quantity ASC
    LIMIT 5
");
$lowStockList = $lowStockStmt->fetchAll();

foreach ($lowStockList as &$ls) {
    $ls['id'] = (int)$ls['id'];
    $ls['price'] = (float)$ls['price'];
    $ls['stock_quantity'] = (int)$ls['stock_quantity'];
}

sendSuccess('Staff dashboard metrics retrieved successfully', [
    'total_books'       => $booksCount,
    'total_orders'      => $ordersCount,
    'pending_orders'    => $pendingOrders,
    'processing_orders' => $processingOrders,
    'low_stock_books'   => $lowStockBooks,
    'recent_orders'     => $recentOrders,
    'low_stock_items'   => $lowStockList
]);
