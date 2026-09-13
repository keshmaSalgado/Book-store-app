<?php
// ====================================================================
// BookVerse REST API - Delete User (Admin Only)
// DELETE /api/users/{id} or /users/delete_user.php?id=X
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../middleware/role_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'DELETE' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

$currentUser = AuthMiddleware::authenticate();
RoleMiddleware::requireAdmin($currentUser);

$id = isset($_GET['id']) && is_numeric($_GET['id']) ? (int)$_GET['id'] : null;
$input = getJsonInput();

if (!$id && isset($input['id']) && is_numeric($input['id'])) {
    $id = (int)$input['id'];
}

if (!$id) {
    sendError('User ID is required', 400);
}

// Safety check: Cannot delete yourself
if ($id === (int)$currentUser['id']) {
    sendError('You cannot delete your own administrator account', 400);
}

$db = Database::getConnection();

$checkStmt = $db->prepare("SELECT id, name, email FROM users WHERE id = :id LIMIT 1");
$checkStmt->execute(['id' => $id]);
$user = $checkStmt->fetch();

if (!$user) {
    sendError('User not found', 404);
}

try {
    $delStmt = $db->prepare("DELETE FROM users WHERE id = :id");
    $delStmt->execute(['id' => $id]);

    sendSuccess('User deleted successfully', [
        'deleted_id' => $id,
        'name'       => $user['name'],
        'email'      => $user['email']
    ]);
} catch (PDOException $e) {
    sendError('Failed to delete user: ' . $e->getMessage(), 500);
}
