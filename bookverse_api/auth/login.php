<?php
// ====================================================================
// BookVerse REST API - User Login
// POST /api/auth/login
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/jwt_helper.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

$input = getJsonInput();

$email = trim($input['email'] ?? '');
$password = $input['password'] ?? '';

if (empty($email) || empty($password)) {
    sendError('Email and password are required', 400);
}

$db = Database::getConnection();

$stmt = $db->prepare("SELECT id, name, email, password, role, status FROM users WHERE email = :email LIMIT 1");
$stmt->execute(['email' => $email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password'])) {
    sendError('Invalid email or password', 401);
}

if ($user['status'] !== 'active') {
    sendError('Your account has been deactivated. Please contact support.', 403);
}

// Generate JWT token
$payload = [
    'user_id' => (int)$user['id'],
    'name'    => $user['name'],
    'email'   => $user['email'],
    'role'    => $user['role']
];

$token = JWT::generateToken($payload);

sendSuccess('Login successful', [
    'token' => $token,
    'user'  => [
        'id'     => (int)$user['id'],
        'name'   => $user['name'],
        'email'  => $user['email'],
        'role'   => $user['role'],
        'status' => $user['status']
    ]
]);
