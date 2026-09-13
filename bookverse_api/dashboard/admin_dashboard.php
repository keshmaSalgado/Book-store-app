<?php
// ====================================================================
// BookVerse REST API - Administrator Dashboard Metrics
// GET /api/admin/dashboard
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../middleware/role_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method Not Allowed', 405);
}

// Authenticate and require Admin
$currentUser = AuthMiddleware::authenticate();
RoleMiddleware::requireAdmin($currentUser);

$db = Database::getConnection();

// Total Users
$usersCount = (int)$db->query("SELECT COUNT(*) FROM users")->fetchColumn();

// Total Books
$booksCount = (int)$db->query("SELECT COUNT(*) FROM books")->fetchColumn();

// Total Orders
$ordersCount = (int)$db->query("SELECT COUNT(*) FROM orders")->fetchColumn();

// Total Revenue (excluding cancelled orders)
$revenue = (float)$db->query("SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE status != 'cancelled'")->fetchColumn();

// Pending Orders
$pendingOrders = (int)$db->query("SELECT COUNT(*) FROM orders WHERE status = 'pending'")->fetchColumn();

// Low Stock Books (stock <= 5)
$lowStockBooks = (int)$db->query("SELECT COUNT(*) FROM books WHERE stock_quantity <= 5")->fetchColumn();

// Extra helpful dashboard statistics: Recent Orders list
$recentOrdersStmt = $db->query("
    SELECT o.id, u.name AS customer_name, o.total_amount, o.status, o.created_at
    FROM orders o
    INNER JOIN users u ON o.user_id = u.id
    ORDER BY o.created_at DESC
    LIMIT 5
");
$recentOrders = $recentOrdersStmt->fetchAll();

foreach ($recentOrders as &$ro) {
    $ro['id'] = (int)$ro['id'];
    $ro['total_amount'] = (float)$ro['total_amount'];
}

sendSuccess('Dashboard metrics retrieved successfully', [
    'total_users'     => $usersCount,
    'total_books'     => $booksCount,
    'total_orders'    => $ordersCount,
    'total_revenue'   => round($revenue, 2),
    'pending_orders'  => $pendingOrders,
    'low_stock_books' => $lowStockBooks,
    'recent_orders'   => $recentOrders
]);
