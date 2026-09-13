<?php
// ====================================================================
// BookVerse REST API - User Logout
// POST /api/auth/logout
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

// Ensure caller possesses valid token
$currentUser = AuthMiddleware::authenticate();

sendSuccess('Logged out successfully', [
    'user_id' => (int)$currentUser['id'],
    'logged_out_at' => date('Y-m-d H:i:s')
]);
