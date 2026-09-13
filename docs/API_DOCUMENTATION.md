# BookVerse REST API Documentation
**Course**: SEN5001 Mobile and Web Technologies  
**Application Name**: BookVerse ("Your Books, Anywhere")  
**Base URL**: `http://localhost/bookverse_api` (or `http://10.0.2.2/bookverse_api` on Android Emulator)

---

## 1. Authentication & Security

The API uses **JWT (JSON Web Tokens)** using HMAC-SHA256 for stateful session verification.  
When an endpoint requires authentication, pass the token in the HTTP header:
```http
Authorization: Bearer <YOUR_JWT_TOKEN>
```

### Standard Response Structure

#### Success Response
```json
{
  "success": true,
  "message": "Request description",
  "data": {}
}
```

#### Error Response
```json
{
  "success": false,
  "message": "Descriptive error message"
}
```

---

## 2. Authentication Endpoints

### 2.1 Register User
- **Method**: `POST`
- **URL**: `/api/auth/register`
- **Access**: Public
- **Request Body**:
```json
{
  "name": "Jane Doe",
  "email": "jane.doe@example.com",
  "password": "Password@123",
  "confirm_password": "Password@123"
}
```
- **Response (201 Created)**:
```json
{
  "success": true,
  "message": "Account created successfully. You can now login.",
  "data": {
    "user_id": 5,
    "name": "Jane Doe",
    "email": "jane.doe@example.com",
    "role": "customer"
  }
}
```

### 2.2 Login User
- **Method**: `POST`
- **URL**: `/api/auth/login`
- **Access**: Public
- **Request Body**:
```json
{
  "email": "admin@bookverse.com",
  "password": "Admin@123"
}
```
- **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOi...",
    "user": {
      "id": 1,
      "name": "System Administrator",
      "email": "admin@bookverse.com",
      "role": "admin",
      "status": "active"
    }
  }
}
```

### 2.3 Get Profile
- **Method**: `GET`
- **URL**: `/api/auth/profile`
- **Access**: Authenticated (Bearer Token)
- **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "id": 3,
    "name": "Alice Johnson",
    "email": "customer1@bookverse.com",
    "role": "customer",
    "status": "active",
    "created_at": "2026-09-11 12:38:14",
    "updated_at": "2026-09-11 12:38:14"
  }
}
```

### 2.4 Update Profile
- **Method**: `PUT`
- **URL**: `/api/auth/profile`
- **Access**: Authenticated (Bearer Token)
- **Request Body**:
```json
{
  "name": "Alice M. Johnson",
  "email": "customer1@bookverse.com",
  "password": "NewSecretPassword@123"
}
```

### 2.5 Logout
- **Method**: `POST`
- **URL**: `/api/auth/logout`
- **Access**: Authenticated

---

## 3. Books Endpoints

### 3.1 Get All Books
- **Method**: `GET`
- **URL**: `/api/books`
- **Query Parameters**:
  - `category_id` (optional, integer): Filter books by category
  - `filter` (optional, `featured` | `latest`)
  - `limit` (optional, integer)
- **Access**: Public
- **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Books retrieved successfully",
  "data": [
    {
      "id": 1,
      "title": "The Midnight Library",
      "author": "Matt Haig",
      "isbn": "978-0525559474",
      "description": "Between life and death there is a library...",
      "price": 18.99,
      "stock_quantity": 25,
      "image_url": "https://images.unsplash.com/...",
      "category_id": 1,
      "category_name": "Fiction",
      "created_at": "2026-09-11 12:38:14",
      "updated_at": "2026-09-11 12:38:14"
    }
  ]
}
```

### 3.2 Get Book Details
- **Method**: `GET`
- **URL**: `/api/books/{id}`
- **Access**: Public

### 3.3 Search Books
- **Method**: `GET`
- **URL**: `/api/books/search?query={searchTerm}`
- **Access**: Public
- **Matches**: Title or Author or ISBN (`LIKE %searchTerm%`)

### 3.4 Add Book
- **Method**: `POST`
- **URL**: `/api/books`
- **Access**: Staff or Administrator only (`Authorization: Bearer <token>`)
- **Request Body**:
```json
{
  "title": "Clean Code",
  "author": "Robert C. Martin",
  "isbn": "978-0132350884",
  "description": "A handbook of agile software craftsmanship.",
  "price": 38.50,
  "stock_quantity": 20,
  "category_id": 3,
  "image_url": "https://images.unsplash.com/photo-1515879218367-8466d910aaa4"
}
```

### 3.5 Update Book
- **Method**: `PUT`
- **URL**: `/api/books/{id}`
- **Access**: Staff or Administrator only

### 3.6 Delete Book
- **Method**: `DELETE`
- **URL**: `/api/books/{id}`
- **Access**: Administrator only (Staff cannot delete books)

---

## 4. Categories Endpoints

### 4.1 Get Categories
- **Method**: `GET`
- **URL**: `/api/categories`
- **Access**: Public
- **Returns**: List of categories with count of books in each category.

### 4.2 Add Category
- **Method**: `POST`
- **URL**: `/api/categories`
- **Access**: Administrator only
- **Request Body**: `{"name": "Philosophy", "description": "Classic and modern works"}`

### 4.3 Update Category
- **Method**: `PUT`
- **URL**: `/api/categories/{id}`
- **Access**: Administrator only

### 4.4 Delete Category
- **Method**: `DELETE`
- **URL**: `/api/categories/{id}`
- **Access**: Administrator only

---

## 5. Shopping Cart Endpoints

### 5.1 Get Cart
- **Method**: `GET`
- **URL**: `/api/cart`
- **Access**: Customer only
- **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Cart retrieved successfully",
  "data": {
    "cart_id": 1,
    "total_items": 3,
    "total_amount": 56.97,
    "items": [
      {
        "cart_item_id": 1,
        "quantity": 3,
        "book_id": 1,
        "title": "The Midnight Library",
        "author": "Matt Haig",
        "price": 18.99,
        "stock_quantity": 25,
        "image_url": "https://...",
        "category_name": "Fiction",
        "subtotal": 56.97
      }
    ]
  }
}
```

### 5.2 Add to Cart
- **Method**: `POST`
- **URL**: `/api/cart`
- **Access**: Customer only
- **Request Body**: `{"book_id": 1, "quantity": 2}`
- **Validation**: Checks that requested quantity does not exceed book's `stock_quantity`.

### 5.3 Update Cart Item Quantity
- **Method**: `PUT`
- **URL**: `/api/cart/{cart_item_id}`
- **Access**: Customer only
- **Request Body**: `{"quantity": 3}`

### 5.4 Remove from Cart
- **Method**: `DELETE`
- **URL**: `/api/cart/{cart_item_id}`
- **Access**: Customer only

---

## 6. Orders Endpoints

### 6.1 Place Order (Checkout)
- **Method**: `POST`
- **URL**: `/api/orders`
- **Access**: Customer only
- **Request Body**:
```json
{
  "delivery_address": "123 University Way, Apt 4B, Cambridge, MA 02138"
}
```
- **Execution**: Runs in a single ACID database transaction:
  1. Validates that cart is not empty.
  2. Verifies each book's available stock.
  3. Inserts into `orders`.
  4. Inserts into `order_items`.
  5. Atomically decrements book `stock_quantity`.
  6. Clears customer `cart_items`.

### 6.2 Get Orders
- **Method**: `GET`
- **URL**: `/api/orders`
- **Query Parameter**: `?status=pending|processing|shipped|delivered|cancelled`
- **Access**:
  - Customer: views only their own orders.
  - Staff & Administrator: view all customer orders across the platform.

### 6.3 Get Single Order Details
- **Method**: `GET`
- **URL**: `/api/orders/{id}`
- **Access**: Customer (own order only), Staff, Administrator.

### 6.4 Update Order Status
- **Method**: `PUT`
- **URL**: `/api/orders/{id}/status`
- **Access**: Staff or Administrator only
- **Request Body**: `{"status": "shipped"}`
- **Permitted statuses**: `pending`, `processing`, `shipped`, `delivered`, `cancelled`.
- **Note**: If status is set to `cancelled`, reserved book quantities are automatically restored to stock.

---

## 7. User Management Endpoints (Administrator Only)

### 7.1 Get All Users
- **Method**: `GET`
- **URL**: `/api/users`
- **Access**: Administrator only

### 7.2 Add User
- **Method**: `POST`
- **URL**: `/api/users`
- **Access**: Administrator only
- **Request Body**:
```json
{
  "name": "Jane Assistant",
  "email": "jane@bookverse.com",
  "password": "Staff@123",
  "role": "staff",
  "status": "active"
}
```

### 7.3 Update User Role & Status
- **Method**: `PUT`
- **URL**: `/api/users/{id}`
- **Access**: Administrator only
- **Request Body**: `{"role": "staff", "status": "active"}`
- **Safety**: Cannot revoke or deactivate own admin account.

### 7.4 Delete User
- **Method**: `DELETE`
- **URL**: `/api/users/{id}`
- **Access**: Administrator only
- **Safety**: Cannot delete own account.

---

## 8. Dashboard Endpoints

### 8.1 Administrator Dashboard
- **Method**: `GET`
- **URL**: `/api/admin/dashboard`
- **Access**: Administrator only
- **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Dashboard metrics retrieved successfully",
  "data": {
    "total_users": 4,
    "total_books": 16,
    "total_orders": 3,
    "total_revenue": 135.93,
    "pending_orders": 1,
    "low_stock_books": 2,
    "recent_orders": [...]
  }
}
```

### 8.2 Store Staff Dashboard
- **Method**: `GET`
- **URL**: `/api/staff/dashboard`
- **Access**: Staff or Administrator
