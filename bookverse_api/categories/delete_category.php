<?php
// ====================================================================
// BookVerse REST API - Delete Category (Admin Only)
// DELETE /api/categories/{id} or /categories/delete_category.php?id=X
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
    sendError('Category ID is required', 400);
}

$db = Database::getConnection();

$checkStmt = $db->prepare("SELECT id, name FROM categories WHERE id = :id LIMIT 1");
$checkStmt->execute(['id' => $id]);
$category = $checkStmt->fetch();

if (!$category) {
    sendError('Category not found', 404);
}

$stmt = $db->prepare("DELETE FROM categories WHERE id = :id");
$stmt->execute(['id' => $id]);

sendSuccess('Category deleted successfully', [
    'deleted_id' => $id,
    'name' => $category['name']
]);
