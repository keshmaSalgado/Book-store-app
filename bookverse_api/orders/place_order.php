<?php
// ====================================================================
// BookVerse REST API - Place Order (Checkout)
// POST /api/orders
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/validation.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

$currentUser = AuthMiddleware::authenticate();
$userId = (int)$currentUser['id'];

$input = getJsonInput();
$deliveryAddress = trim($input['delivery_address'] ?? '');

if (empty($deliveryAddress)) {
    sendError('Delivery address is required', 400);
}

$db = Database::getConnection();

// Get customer cart
$cartStmt = $db->prepare("SELECT id FROM carts WHERE user_id = :user_id LIMIT 1");
$cartStmt->execute(['user_id' => $userId]);
$cart = $cartStmt->fetch();

if (!$cart) {
    sendError('Cart is empty. Please add books before checking out.', 400);
}

$cartId = (int)$cart['id'];

// Fetch cart items with current book stock & price
$itemsStmt = $db->prepare("
    SELECT 
        ci.id AS cart_item_id,
        ci.book_id,
        ci.quantity,
        b.title,
        b.price,
        b.stock_quantity
    FROM cart_items ci
    INNER JOIN books b ON ci.book_id = b.id
    WHERE ci.cart_id = :cart_id
");
$itemsStmt->execute(['cart_id' => $cartId]);
$cartItems = $itemsStmt->fetchAll();

if (empty($cartItems)) {
    sendError('Your shopping cart is empty', 400);
}

// Validate sufficient stock for every item before beginning transaction
foreach ($cartItems as $item) {
    if ($item['quantity'] > $item['stock_quantity']) {
        sendError("Insufficient stock for '{$item['title']}'. Requested: {$item['quantity']}, Available: {$item['stock_quantity']}.", 400);
    }
}

// Calculate total
$totalAmount = 0.0;
foreach ($cartItems as $item) {
    $totalAmount += ($item['quantity'] * $item['price']);
}
$totalAmount = round($totalAmount, 2);

try {
    $db->beginTransaction();

    // 1. Create order
    $orderStmt = $db->prepare("
        INSERT INTO orders (user_id, total_amount, status, delivery_address)
        VALUES (:user_id, :total_amount, 'pending', :delivery_address)
    ");
    $orderStmt->execute([
        'user_id'          => $userId,
        'total_amount'     => $totalAmount,
        'delivery_address' => Validator::sanitize($deliveryAddress)
    ]);
    $orderId = (int)$db->lastInsertId();

    // 2. Insert order items & decrement book stock
    $insertItemStmt = $db->prepare("
        INSERT INTO order_items (order_id, book_id, quantity, price)
        VALUES (:order_id, :book_id, :quantity, :price)
    ");

    $deductStockStmt = $db->prepare("
        UPDATE books 
        SET stock_quantity = stock_quantity - :deduct_qty 
        WHERE id = :book_id AND stock_quantity >= :min_qty
    ");

    $savedOrderItems = [];

    foreach ($cartItems as $item) {
        // Insert order line
        $insertItemStmt->execute([
            'order_id' => $orderId,
            'book_id'  => $item['book_id'],
            'quantity' => $item['quantity'],
            'price'    => $item['price']
        ]);

        // Deduct stock with concurrency safety check
        $deductStockStmt->execute([
            'deduct_qty' => $item['quantity'],
            'min_qty'    => $item['quantity'],
            'book_id'    => $item['book_id']
        ]);

        if ($deductStockStmt->rowCount() === 0) {
            throw new Exception("Stock became insufficient for book '{$item['title']}' during checkout.");
        }

        $savedOrderItems[] = [
            'book_id'  => (int)$item['book_id'],
            'title'    => $item['title'],
            'quantity' => (int)$item['quantity'],
            'price'    => (float)$item['price'],
            'subtotal' => round($item['quantity'] * $item['price'], 2)
        ];
    }

    // 3. Clear cart
    $clearCartStmt = $db->prepare("DELETE FROM cart_items WHERE cart_id = :cart_id");
    $clearCartStmt->execute(['cart_id' => $cartId]);

    $db->commit();

    sendSuccess('Order placed successfully', [
        'order_id'         => $orderId,
        'total_amount'     => $totalAmount,
        'status'           => 'pending',
        'delivery_address' => $deliveryAddress,
        'items_count'      => count($savedOrderItems),
        'items'            => $savedOrderItems,
        'created_at'       => date('Y-m-d H:i:s')
    ], 201);
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendError('Order placement failed: ' . $e->getMessage(), 500);
}
