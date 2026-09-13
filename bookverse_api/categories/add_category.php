<?php
// ====================================================================
// BookVerse REST API - Add Category (Admin Only)
// POST /api/categories
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/validation.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../middleware/role_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

// Authenticate and require Admin
$currentUser = AuthMiddleware::authenticate();
RoleMiddleware::requireAdmin($currentUser);

$input = getJsonInput();

$errors = Validator::validateCategory($input);
if (!empty($errors)) {
    sendError(implode(', ', $errors), 400);
}

$name = trim($input['name']);
$description = trim($input['description'] ?? '');

$db = Database::getConnection();

// Check unique category name
$checkStmt = $db->prepare("SELECT id FROM categories WHERE name = :name LIMIT 1");
$checkStmt->execute(['name' => $name]);
if ($checkStmt->fetch()) {
    sendError('A category with this name already exists', 409);
}

$stmt = $db->prepare("INSERT INTO categories (name, description) VALUES (:name, :description)");
$stmt->execute([
    'name' => Validator::sanitize($name),
    'description' => $description
]);

$id = (int)$db->lastInsertId();

sendSuccess('Category created successfully', [
    'id' => $id,
    'name' => $name,
    'description' => $description
], 201);
