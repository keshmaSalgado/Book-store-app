<?php
// ====================================================================
// BookVerse REST API - User Registration
// POST /api/auth/register
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/validation.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

$input = getJsonInput();

$name = trim($input['name'] ?? '');
$email = trim($input['email'] ?? '');
$password = $input['password'] ?? '';
$confirmPassword = $input['confirm_password'] ?? $password;

// Validation
$errors = Validator::validateUser(['name' => $name, 'email' => $email, 'password' => $password], true);

if ($password !== $confirmPassword) {
    $errors[] = 'Password confirmation does not match';
}

if (!empty($errors)) {
    sendError(implode(', ', $errors), 400);
}

$db = Database::getConnection();

// Check duplicate email
$checkStmt = $db->prepare("SELECT id FROM users WHERE email = :email LIMIT 1");
$checkStmt->execute(['email' => $email]);
if ($checkStmt->fetch()) {
    sendError('Email address is already registered', 409);
}

// Hash password with bcrypt
$hashedPassword = password_hash($password, PASSWORD_BCRYPT);

try {
    $db->beginTransaction();

    $insertStmt = $db->prepare("
        INSERT INTO users (name, email, password, role, status)
        VALUES (:name, :email, :password, 'customer', 'active')
    ");
    $insertStmt->execute([
        'name' => Validator::sanitize($name),
        'email' => $email,
        'password' => $hashedPassword,
    ]);

    $userId = (int)$db->lastInsertId();

    // Create an initial cart for the user
    $cartStmt = $db->prepare("INSERT INTO carts (user_id) VALUES (:user_id)");
    $cartStmt->execute(['user_id' => $userId]);

    $db->commit();

    sendSuccess('Account created successfully. You can now login.', [
        'user_id' => $userId,
        'name' => $name,
        'email' => $email,
        'role' => 'customer'
    ], 201);
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendError('Failed to create account: ' . $e->getMessage(), 500);
}
