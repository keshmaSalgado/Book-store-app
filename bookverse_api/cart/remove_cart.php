<?php
// ====================================================================
// BookVerse REST API - Remove Item from Shopping Cart
// DELETE /api/cart/{id} or /cart/remove_cart.php?id=X
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'DELETE' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

$currentUser = AuthMiddleware::authenticate();
$userId = (int)$currentUser['id'];

$cartItemId = isset($_GET['id']) && is_numeric($_GET['id']) ? (int)$_GET['id'] : null;
$input = getJsonInput();

if (!$cartItemId && isset($input['id']) && is_numeric($input['id'])) {
    $cartItemId = (int)$input['id'];
}

if (!$cartItemId) {
    sendError('Cart item ID is required', 400);
}

$db = Database::getConnection();

// Verify that cart item belongs to user
$verifyStmt = $db->prepare("
    SELECT ci.id, ci.book_id
    FROM cart_items ci
    INNER JOIN carts c ON ci.cart_id = c.id
    WHERE ci.id = :cart_item_id AND c.user_id = :user_id
    LIMIT 1
");
$verifyStmt->execute([
    'cart_item_id' => $cartItemId,
    'user_id'      => $userId
]);
$item = $verifyStmt->fetch();

if (!$item) {
    sendError('Cart item not found or does not belong to you', 404);
}

$delStmt = $db->prepare("DELETE FROM cart_items WHERE id = :id");
$delStmt->execute(['id' => $cartItemId]);

sendSuccess('Item removed from cart', ['cart_item_id' => $cartItemId]);
