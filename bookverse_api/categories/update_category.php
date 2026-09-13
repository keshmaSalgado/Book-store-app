<?php
// ====================================================================
// BookVerse REST API - Update Category (Admin Only)
// PUT /api/categories/{id} or /categories/update_category.php?id=X
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/validation.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../middleware/role_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'PUT' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
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

$checkStmt = $db->prepare("SELECT * FROM categories WHERE id = :id LIMIT 1");
$checkStmt->execute(['id' => $id]);
$existingCat = $checkStmt->fetch();

if (!$existingCat) {
    sendError('Category not found', 404);
}

$name = isset($input['name']) ? trim($input['name']) : $existingCat['name'];
$description = isset($input['description']) ? trim($input['description']) : $existingCat['description'];

if (empty($name)) {
    sendError('Category name cannot be empty', 400);
}

// Check unique name if changed
if (strtolower($name) !== strtolower($existingCat['name'])) {
    $uniqStmt = $db->prepare("SELECT id FROM categories WHERE name = :name AND id != :id LIMIT 1");
    $uniqStmt->execute(['name' => $name, 'id' => $id]);
    if ($uniqStmt->fetch()) {
        sendError('Another category with this name already exists', 409);
    }
}

$stmt = $db->prepare("UPDATE categories SET name = :name, description = :description WHERE id = :id");
$stmt->execute([
    'name' => Validator::sanitize($name),
    'description' => $description,
    'id' => $id
]);

sendSuccess('Category updated successfully', [
    'id' => $id,
    'name' => $name,
    'description' => $description
]);
