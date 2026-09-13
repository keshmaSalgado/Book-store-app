<?php
// ====================================================================
// BookVerse REST API - Update Cart Item Quantity
// PUT /api/cart/{id} or /cart/update_cart.php?id=X
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'PUT' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
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

if (!isset($input['quantity']) || !is_numeric($input['quantity'])) {
    sendError('Quantity is required', 400);
}

$quantity = (int)$input['quantity'];

$db = Database::getConnection();

// Verify that the cart item belongs to the authenticated user's cart
$verifyStmt = $db->prepare("
    SELECT ci.id, ci.cart_id, ci.book_id, b.title, b.stock_quantity
    FROM cart_items ci
    INNER JOIN carts c ON ci.cart_id = c.id
    INNER JOIN books b ON ci.book_id = b.id
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

// If quantity is 0 or less, remove the item
if ($quantity <= 0) {
    $delStmt = $db->prepare("DELETE FROM cart_items WHERE id = :id");
    $delStmt->execute(['id' => $cartItemId]);
    sendSuccess('Item removed from cart', ['cart_item_id' => $cartItemId, 'quantity' => 0]);
}

// Check against stock
if ($quantity > (int)$item['stock_quantity']) {
    sendError("Quantity ($quantity) exceeds available stock ({$item['stock_quantity']})", 400);
}

$updateStmt = $db->prepare("UPDATE cart_items SET quantity = :quantity WHERE id = :id");
$updateStmt->execute(['quantity' => $quantity, 'id' => $cartItemId]);

sendSuccess('Cart updated successfully', [
    'cart_item_id' => $cartItemId,
    'book_id'      => (int)$item['book_id'],
    'title'        => $item['title'],
    'quantity'     => $quantity,
    'stock'        => (int)$item['stock_quantity']
]);
