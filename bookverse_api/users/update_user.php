<?php
// ====================================================================
// BookVerse REST API - Update User (Admin Only)
// PUT /api/users/{id} or /users/update_user.php?id=X
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
    sendError('User ID is required', 400);
}

$db = Database::getConnection();

// Check if user exists
$checkStmt = $db->prepare("SELECT * FROM users WHERE id = :id LIMIT 1");
$checkStmt->execute(['id' => $id]);
$existingUser = $checkStmt->fetch();

if (!$existingUser) {
    sendError('User not found', 404);
}

$name = isset($input['name']) ? trim($input['name']) : $existingUser['name'];
$email = isset($input['email']) ? trim($input['email']) : $existingUser['email'];
$role = isset($input['role']) ? strtolower(trim($input['role'])) : $existingUser['role'];
$status = isset($input['status']) ? strtolower(trim($input['status'])) : $existingUser['status'];
$password = !empty($input['password']) ? $input['password'] : null;

$errors = Validator::validateUser([
    'name'     => $name,
    'email'    => $email,
    'password' => $password
], false);

$allowedRoles = ['customer', 'staff', 'admin'];
if (!in_array($role, $allowedRoles, true)) {
    $errors[] = 'Invalid role. Allowed roles: customer, staff, admin';
}

$allowedStatuses = ['active', 'inactive'];
if (!in_array($status, $allowedStatuses, true)) {
    $errors[] = 'Invalid status. Allowed statuses: active, inactive';
}

// Safety check: Cannot demote or deactivate yourself
if ($id === (int)$currentUser['id']) {
    if ($role !== 'admin') {
        $errors[] = 'You cannot revoke your own administrator role';
    }
    if ($status !== 'active') {
        $errors[] = 'You cannot deactivate your own account';
    }
}

if (!empty($errors)) {
    sendError(implode(', ', $errors), 400);
}

// Check email uniqueness if changed
if (strtolower($email) !== strtolower($existingUser['email'])) {
    $emailStmt = $db->prepare("SELECT id FROM users WHERE email = :email AND id != :id LIMIT 1");
    $emailStmt->execute(['email' => $email, 'id' => $id]);
    if ($emailStmt->fetch()) {
        sendError('Email address is already in use by another account', 409);
    }
}

$updates = [
    'name = :name',
    'email = :email',
    'role = :role',
    'status = :status'
];

$params = [
    'name'   => Validator::sanitize($name),
    'email'  => $email,
    'role'   => $role,
    'status' => $status,
    'id'     => $id
];

if ($password !== null) {
    $updates[] = 'password = :password';
    $params['password'] = password_hash($password, PASSWORD_BCRYPT);
}

$sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id = :id";
$updateStmt = $db->prepare($sql);
$updateStmt->execute($params);

// Fetch updated user
$stmt = $db->prepare("SELECT id, name, email, role, status, updated_at FROM users WHERE id = :id");
$stmt->execute(['id' => $id]);
$updatedUser = $stmt->fetch();

$updatedUser['id'] = (int)$updatedUser['id'];

sendSuccess('User updated successfully', $updatedUser);
