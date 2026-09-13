<?php
// ====================================================================
// BookVerse REST API - Get All Users (Admin Only)
// GET /api/users
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

$roleFilter = $_GET['role'] ?? null;
$params = [];

$query = "
    SELECT 
        u.id,
        u.name,
        u.email,
        u.role,
        u.status,
        u.created_at,
        u.updated_at,
        COUNT(DISTINCT o.id) AS total_orders
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
    WHERE 1=1
";

if (!empty($roleFilter)) {
    $query .= " AND u.role = :role";
    $params['role'] = $roleFilter;
}

$query .= " GROUP BY u.id ORDER BY u.id ASC";

$stmt = $db->prepare($query);
$stmt->execute($params);
$users = $stmt->fetchAll();

foreach ($users as &$user) {
    $user['id'] = (int)$user['id'];
    $user['total_orders'] = (int)$user['total_orders'];
}

sendSuccess('Users retrieved successfully', $users);
