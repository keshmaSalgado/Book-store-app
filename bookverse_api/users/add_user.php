<?php
// ====================================================================
// BookVerse REST API - Add User (Admin Only)
// POST /api/users
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/validation.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../middleware/role_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

$currentUser = AuthMiddleware::authenticate();
RoleMiddleware::requireAdmin($currentUser);

$input = getJsonInput();

$name = trim($input['name'] ?? '');
$email = trim($input['email'] ?? '');
$password = $input['password'] ?? '';
$role = strtolower(trim($input['role'] ?? 'customer'));
$status = strtolower(trim($input['status'] ?? 'active'));

$errors = Validator::validateUser(['name' => $name, 'email' => $email, 'password' => $password], true);

$allowedRoles = ['customer', 'staff', 'admin'];
if (!in_array($role, $allowedRoles, true)) {
    $errors[] = 'Invalid role. Allowed roles: customer, staff, admin';
}

$allowedStatuses = ['active', 'inactive'];
if (!in_array($status, $allowedStatuses, true)) {
    $errors[] = 'Invalid status. Allowed statuses: active, inactive';
}

if (!empty($errors)) {
    sendError(implode(', ', $errors), 400);
}

$db = Database::getConnection();

// Check unique email
$checkStmt = $db->prepare("SELECT id FROM users WHERE email = :email LIMIT 1");
$checkStmt->execute(['email' => $email]);
if ($checkStmt->fetch()) {
    sendError('Email address is already in use', 409);
}

$hashedPassword = password_hash($password, PASSWORD_BCRYPT);

try {
    $db->beginTransaction();

    $stmt = $db->prepare("
        INSERT INTO users (name, email, password, role, status)
        VALUES (:name, :email, :password, :role, :status)
    ");
    $stmt->execute([
        'name'     => Validator::sanitize($name),
        'email'    => $email,
        'password' => $hashedPassword,
        'role'     => $role,
        'status'   => $status
    ]);

    $userId = (int)$db->lastInsertId();

    // If customer, initialize a cart
    if ($role === 'customer') {
        $cartStmt = $db->prepare("INSERT INTO carts (user_id) VALUES (:user_id)");
        $cartStmt->execute(['user_id' => $userId]);
    }

    $db->commit();

    sendSuccess('User created successfully', [
        'id'     => $userId,
        'name'   => $name,
        'email'  => $email,
        'role'   => $role,
        'status' => $status
    ], 201);
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendError('Failed to create user: ' . $e->getMessage(), 500);
}
