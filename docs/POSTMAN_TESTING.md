# Postman API Testing Guide for BookVerse

This guide explains how to test all BookVerse REST API endpoints using Postman.

---

## 1. Importing the Collection

1. Open **Postman**.
2. Click **Import** (top left).
3. Choose the file located at:
   ```
   online_bookstore/docs/postman_collection.json
   ```
4. Click **Import**. You will see the collection named **"BookVerse REST API - University Collection"**.

---

## 2. Environment Variables

The collection contains pre-configured collection variables:
- `baseUrl`: `http://localhost/bookverse_api` (or `http://10.0.2.2/bookverse_api` if testing via Android network)
- `token`: Automatically populated upon successful login!

---

## 3. Recommended Step-by-Step Test Sequence

### Phase 1: Authentication & RBAC Setup
1. **Login - Administrator**
   - Sends `admin@bookverse.com` / `Admin@123`.
   - **Postman Test Script**: Automatically extracts `data.token` and stores it into `{{token}}`.
2. **Login - Store Staff**
   - Sends `staff@bookverse.com` / `Staff@123`.
   - Updates `{{token}}` to staff token.
3. **Login - Customer**
   - Sends `customer1@bookverse.com` / `Customer@123`.
   - Updates `{{token}}` to customer token.
4. **Register New Customer**
   - Creates a new test user account with email uniqueness validation.

### Phase 2: Catalog Browsing & Search
1. **Get All Books**: Returns 16 seed books with categories and stock.
2. **Get Books by Category**: Filter by `category_id=3` (Technology books).
3. **Get Single Book Details**: View Book ID 1 (The Midnight Library).
4. **Search Books**: Search query `Clean` matches Clean Code.

### Phase 3: Shopping Cart Flow (As Customer)
1. **Get Cart**: Returns customer items and totals.
2. **Add to Cart**: Adds 2 copies of book ID 2.
3. **Update Quantity**: Sets quantity to 3 (checks stock ceiling).
4. **Remove Item**: Deletes cart item.

### Phase 4: Order & Checkout Flow
1. **Place Order**:
   - Address: `123 University Blvd, Cambridge, MA`
   - Executes transaction: decrements book stock, generates order ID, clears cart.
2. **Get Orders**: Customer views their placed orders.
3. **Get Order Details**: View receipt with itemized lines.
4. **Update Order Status (Staff / Admin)**: Switch status to `shipped` or `delivered`.

### Phase 5: Administration & Dashboards
1. **Admin Dashboard**: Inspect `total_users`, `total_books`, `total_orders`, `total_revenue`, `pending_orders`, `low_stock_books`.
2. **Staff Dashboard**: Inspect operational metrics and low-stock alerts.
3. **User Management**: View, create, update roles, or deactivate users.
