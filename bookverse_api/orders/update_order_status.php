<?php
// ====================================================================
// BookVerse REST API - Update Order Status (Staff & Admin)
// PUT /api/orders/{id}/status or /orders/update_order_status.php?id=X
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/auth_middleware.php';
require_once __DIR__ . '/../middleware/role_middleware.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'PUT' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method Not Allowed', 405);
}

// Authenticate & require Staff or Admin
$currentUser = AuthMiddleware::authenticate();
RoleMiddleware::requireStaffOrAdmin($currentUser);

$orderId = isset($_GET['id']) && is_numeric($_GET['id']) ? (int)$_GET['id'] : null;
$input = getJsonInput();

if (!$orderId && isset($input['id']) && is_numeric($input['id'])) {
    $orderId = (int)$input['id'];
}

if (!$orderId) {
    sendError('Order ID is required', 400);
}

$newStatus = strtolower(trim($input['status'] ?? ''));
$allowedStatuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];

if (!in_array($newStatus, $allowedStatuses, true)) {
    sendError('Invalid status. Allowed values: ' . implode(', ', $allowedStatuses), 400);
}

$db = Database::getConnection();

// Fetch current order status
$orderStmt = $db->prepare("SELECT id, status FROM orders WHERE id = :id LIMIT 1");
$orderStmt->execute(['id' => $orderId]);
$order = $orderStmt->fetch();

if (!$order) {
    sendError('Order not found', 404);
}

$oldStatus = $order['status'];

if ($oldStatus === $newStatus) {
    sendSuccess('Order status is already ' . $newStatus, [
        'order_id' => $orderId,
        'status'   => $newStatus
    ]);
}

try {
    $db->beginTransaction();

    // If order was cancelled and now changed, or changed TO cancelled
    if ($newStatus === 'cancelled' && $oldStatus !== 'cancelled') {
        // Return quantities back to book stock
        $itemsStmt = $db->prepare("SELECT book_id, quantity FROM order_items WHERE order_id = :order_id");
        $itemsStmt->execute(['order_id' => $orderId]);
        $items = $itemsStmt->fetchAll();

        $restoreStockStmt = $db->prepare("UPDATE books SET stock_quantity = stock_quantity + :qty WHERE id = :book_id");
        foreach ($items as $item) {
            $restoreStockStmt->execute([
                'qty'     => $item['quantity'],
                'book_id' => $item['book_id']
            ]);
        }
    } elseif ($oldStatus === 'cancelled' && $newStatus !== 'cancelled') {
        // Re-deduct stock if un-cancelling
        $itemsStmt = $db->prepare("SELECT book_id, quantity FROM order_items WHERE order_id = :order_id");
        $itemsStmt->execute(['order_id' => $orderId]);
        $items = $itemsStmt->fetchAll();

        $deductStockStmt = $db->prepare("
            UPDATE books SET stock_quantity = stock_quantity - :deduct_qty 
            WHERE id = :book_id AND stock_quantity >= :min_qty
        ");
        foreach ($items as $item) {
            $deductStockStmt->execute([
                'deduct_qty' => $item['quantity'],
                'min_qty'    => $item['quantity'],
                'book_id'    => $item['book_id']
            ]);
            if ($deductStockStmt->rowCount() === 0) {
                throw new Exception("Cannot un-cancel order: Insufficient stock for book ID {$item['book_id']}");
            }
        }
    }

    $updateStmt = $db->prepare("UPDATE orders SET status = :status WHERE id = :id");
    $updateStmt->execute(['status' => $newStatus, 'id' => $orderId]);

    $db->commit();

    sendSuccess("Order #$orderId status updated to '$newStatus'", [
        'order_id'   => $orderId,
        'old_status' => $oldStatus,
        'new_status' => $newStatus
    ]);
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendError('Failed to update order status: ' . $e->getMessage(), 500);
}
