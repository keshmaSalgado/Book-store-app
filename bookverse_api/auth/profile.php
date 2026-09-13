<?php
// ====================================================================
// BookVerse REST API - User Profile
// GET /api/auth/profile
// PUT /api/auth/profile
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/validation.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../config/database.php';

$currentUser = AuthMiddleware::authenticate();
$db = Database::getConnection();
$userId = (int)$currentUser['id'];

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $db->prepare("SELECT id, name, email, role, status, created_at, updated_at FROM users WHERE id = :id");
    $stmt->execute(['id' => $userId]);
    $user = $stmt->fetch();

    if (!$user) {
        sendError('User not found', 404);
    }

    sendSuccess('Profile retrieved successfully', $user);
} elseif ($method === 'PUT') {
    $input = getJsonInput();

    $name = isset($input['name']) ? trim($input['name']) : null;
    $email = isset($input['email']) ? trim($input['email']) : null;
    $password = !empty($input['password']) ? $input['password'] : null;

    $errors = Validator::validateUser([
        'name' => $name ?? $currentUser['name'],
        'email' => $email ?? $currentUser['email'],
        'password' => $password
    ], false);

    if (!empty($errors)) {
        sendError(implode(', ', $errors), 400);
    }

    // If changing email, check uniqueness
    if ($email !== null && strtolower($email) !== strtolower($currentUser['email'])) {
        $checkStmt = $db->prepare("SELECT id FROM users WHERE email = :email AND id != :id LIMIT 1");
        $checkStmt->execute(['email' => $email, 'id' => $userId]);
        if ($checkStmt->fetch()) {
            sendError('Email address is already in use by another account', 409);
        }
    }

    $updates = [];
    $params = ['id' => $userId];

    if ($name !== null) {
        $updates[] = "name = :name";
        $params['name'] = Validator::sanitize($name);
    }
    if ($email !== null) {
        $updates[] = "email = :email";
        $params['email'] = $email;
    }
    if ($password !== null) {
        $updates[] = "password = :password";
        $params['password'] = password_hash($password, PASSWORD_BCRYPT);
    }

    if (empty($updates)) {
        sendError('No update fields provided', 400);
    }

    $sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id = :id";
    $stmt = $db->prepare($sql);
    $stmt->execute($params);

    // Fetch updated user
    $fetchStmt = $db->prepare("SELECT id, name, email, role, status, updated_at FROM users WHERE id = :id");
    $fetchStmt->execute(['id' => $userId]);
    $updatedUser = $fetchStmt->fetch();

    sendSuccess('Profile updated successfully', $updatedUser);
} else {
    sendError('Method Not Allowed', 405);
}
