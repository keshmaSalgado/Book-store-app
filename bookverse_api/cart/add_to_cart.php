<?php
// ====================================================================
// BookVerse REST API - Add Item to Shopping Cart
// POST /api/cart
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

$currentUser = AuthMiddleware::authenticate();
$userId = (int)$currentUser['id'];

$input = getJsonInput();

$bookId = isset($input['book_id']) && is_numeric($input['book_id']) ? (int)$input['book_id'] : null;
$quantity = isset($input['quantity']) && is_numeric($input['quantity']) ? (int)$input['quantity'] : 1;

if (!$bookId) {
    sendError('Book ID is required', 400);
}

if ($quantity <= 0) {
    sendError('Quantity must be greater than 0', 400);
}

$db = Database::getConnection();

// Check if book exists and check stock
$bookStmt = $db->prepare("SELECT id, title, price, stock_quantity FROM books WHERE id = :id LIMIT 1");
$bookStmt->execute(['id' => $bookId]);
$book = $bookStmt->fetch();

if (!$book) {
    sendError('Book not found', 404);
}

$availableStock = (int)$book['stock_quantity'];
if ($availableStock <= 0) {
    sendError('Sorry, this book is currently out of stock', 400);
}

// Get or create user cart
$cartStmt = $db->prepare("SELECT id FROM carts WHERE user_id = :user_id LIMIT 1");
$cartStmt->execute(['user_id' => $userId]);
$cart = $cartStmt->fetch();

if (!$cart) {
    $createCart = $db->prepare("INSERT INTO carts (user_id) VALUES (:user_id)");
    $createCart->execute(['user_id' => $userId]);
    $cartId = (int)$db->lastInsertId();
} else {
    $cartId = (int)$cart['id'];
}

// Check if book already in cart
$itemStmt = $db->prepare("SELECT id, quantity FROM cart_items WHERE cart_id = :cart_id AND book_id = :book_id LIMIT 1");
$itemStmt->execute(['cart_id' => $cartId, 'book_id' => $bookId]);
$existingItem = $itemStmt->fetch();

if ($existingItem) {
    $newQuantity = (int)$existingItem['quantity'] + $quantity;

    if ($newQuantity > $availableStock) {
        sendError("Cannot add $quantity more. Total in cart would be $newQuantity, exceeding available stock ($availableStock).", 400);
    }

    $updateStmt = $db->prepare("UPDATE cart_items SET quantity = :quantity WHERE id = :id");
    $updateStmt->execute(['quantity' => $newQuantity, 'id' => $existingItem['id']]);
    $cartItemId = (int)$existingItem['id'];
    $finalQuantity = $newQuantity;
} else {
    if ($quantity > $availableStock) {
        sendError("Requested quantity ($quantity) exceeds available stock ($availableStock).", 400);
    }

    $insertStmt = $db->prepare("INSERT INTO cart_items (cart_id, book_id, quantity) VALUES (:cart_id, :book_id, :quantity)");
    $insertStmt->execute(['cart_id' => $cartId, 'book_id' => $bookId, 'quantity' => $quantity]);
    $cartItemId = (int)$db->lastInsertId();
    $finalQuantity = $quantity;
}

sendSuccess('Book added to cart', [
    'cart_item_id' => $cartItemId,
    'book_id'      => $bookId,
    'title'        => $book['title'],
    'quantity'     => $finalQuantity,
    'stock'        => $availableStock
]);
