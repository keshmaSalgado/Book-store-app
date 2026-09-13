# BookVerse - Complete Test Plan & Test Cases
**Module**: SEN5001 Mobile and Web Technologies  
**Application Name**: BookVerse ("Your Books, Anywhere")  
**Author**: University Student  

---

## 1. Test Objectives & Strategy

This test plan validates:
1. **Functional Correctness**: Ensuring all customer, staff, and admin user journeys operate according to university specifications.
2. **Security & Authorization**: Verifying password hashing (Bcrypt), JWT token generation and validation, and Role-Based Access Control (RBAC) enforcement on both API and Flutter layers.
3. **Data Integrity & Concurrency**: Confirming that database transactions maintain consistent stock counts and order items during checkout.
4. **Input Validation & Error Handling**: Checking that client and server reject improper inputs (invalid emails, duplicate accounts, out-of-stock orders).

---

## 2. Test Cases Specification & Execution Matrix

### Module 1: Authentication & Authorization

| Test ID | Test Scenario | Input Data | Expected Result | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **AUTH-01** | Register valid customer | Name: "Jane Doe", Email: "jane@example.com", Password: "Password@123" | 201 Created; JWT returned; User added to DB with role 'customer'; empty cart initialized | Account created; Cart ID created | **PASS** |
| **AUTH-02** | Register duplicate email | Existing email: "admin@bookverse.com" | 409 Conflict with message "Email address is already registered" | HTTP 409 "Email address is already registered" | **PASS** |
| **AUTH-03** | Register with invalid email | Email: "bademail" | 400 Bad Request with validation error message | HTTP 400 "Please provide a valid email address" | **PASS** |
| **AUTH-04** | Register with short password | Password: "123" (< 6 chars) | 400 Bad Request: "Password must be at least 6 characters" | Rejected by client validator and server | **PASS** |
| **AUTH-05** | Login with valid credentials | `admin@bookverse.com` / `Admin@123` | 200 OK; Valid JWT token issued; user object returned with role 'admin' | Returns token and user payload | **PASS** |
| **AUTH-06** | Login with invalid password | `admin@bookverse.com` / `WrongPass` | 401 Unauthorized with message "Invalid email or password" | HTTP 401 "Invalid email or password" | **PASS** |
| **AUTH-07** | Request protected API without token | `GET /api/orders` without Authorization header | 401 Unauthorized: "Missing or invalid token" | HTTP 401 "Unauthorized access: Missing or invalid token" | **PASS** |
| **AUTH-08** | Deactivated user login attempt | User with status 'inactive' | 403 Forbidden: "Your account has been deactivated" | HTTP 403 Account deactivated | **PASS** |

---

### Module 2: Book Catalog & Search

| Test ID | Test Scenario | Input Data | Expected Result | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **BOOK-01** | Retrieve all books | `GET /api/books` | 200 OK; Returns list of 16 seed books with categories and stock | Returns 16 books array in JSON | **PASS** |
| **BOOK-02** | Filter books by category | `GET /api/books?category_id=3` (Technology) | Returns books where `category_id = 3` | Returns Technology books only | **PASS** |
| **BOOK-03** | View single book details | `GET /api/books/1` | 200 OK; Returns title, author, price, stock, ISBN, description | Book details returned successfully | **PASS** |
| **BOOK-04** | Search books by title | Query: "Clean" | Returns "Clean Code" | Matched 1 book | **PASS** |
| **BOOK-05** | Search books by author | Query: "Hawking" | Returns "A Brief History of Time" | Matched 1 book | **PASS** |
| **BOOK-06** | Add book as Staff/Admin | Valid book fields | 201 Created; Book stored in DB; available in catalog | Book created with ID | **PASS** |
| **BOOK-07** | Add book with negative price | `price = -10.00` | 400 Bad Request: "Price must be greater than 0" | HTTP 400 validation error | **PASS** |
| **BOOK-08** | Delete book as Staff | Store Staff token -> `DELETE /api/books/1` | 403 Forbidden: Staff cannot delete books | HTTP 403 Forbidden | **PASS** |
| **BOOK-09** | Delete book as Admin | Admin token -> `DELETE /api/books/16` | 200 OK; Book removed from catalog | Book deleted | **PASS** |

---

### Module 3: Shopping Cart Management

| Test ID | Test Scenario | Input Data | Expected Result | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **CART-01** | Add in-stock book to cart | Book ID: 2, Quantity: 2 | 200 OK; Item inserted into `cart_items` | Item added | **PASS** |
| **CART-02** | Add quantity exceeding stock | Stock = 3, Requested Qty = 5 | 400 Bad Request: "Requested quantity exceeds available stock" | HTTP 400 stock ceiling enforced | **PASS** |
| **CART-03** | Update quantity in cart | Cart Item ID, New Quantity: 3 | 200 OK; Subtotal recalculated | Cart item quantity updated to 3 | **PASS** |
| **CART-04** | Remove item from cart | `DELETE /api/cart/{id}` | 200 OK; Item deleted from cart | Item removed | **PASS** |
| **CART-05** | Calculate cart totals | 2 books at \$18.99 + 1 book at \$38.50 | Total: \$76.48; Total items: 3 | Sum computed accurately | **PASS** |

---

### Module 4: Order Placement & Checkout

| Test ID | Test Scenario | Input Data | Expected Result | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **ORD-01** | Checkout with empty cart | Cart has 0 items | 400 Bad Request: "Your shopping cart is empty" | Rejected with message | **PASS** |
| **ORD-02** | Checkout with missing address | Address: "" | 400 Bad Request: "Delivery address is required" | Rejected with message | **PASS** |
| **ORD-03** | Place valid order | Active cart + valid address | 201 Created; Order recorded with status 'pending'; Stock decremented; Cart cleared | Order placed; Stock deducted; Cart emptied | **PASS** |
| **ORD-04** | Customer views order history | Customer token | List of customer's own orders only | Only personal orders visible | **PASS** |
| **ORD-05** | Customer tries to view another user's order | Customer 2 viewing Order #1001 (Customer 1's) | 403 Forbidden: "You cannot view another customer's order" | HTTP 403 Forbidden | **PASS** |
| **ORD-06** | Staff updates order status | Order #1003 status -> 'shipped' | 200 OK; Order status updated to 'shipped' | Status updated successfully | **PASS** |
| **ORD-07** | Cancel order restores stock | Change status to 'cancelled' | Books stock quantities automatically incremented back | Stock restored | **PASS** |

---

### Module 5: Role-Based Access Control (RBAC)

| Test ID | Test Scenario | Actor | Target Endpoint | Expected Result | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RBAC-01** | Access Admin Dashboard | Customer | `GET /api/admin/dashboard` | 403 Forbidden | **PASS** |
| **RBAC-02** | Access Admin Dashboard | Store Staff | `GET /api/admin/dashboard` | 403 Forbidden | **PASS** |
| **RBAC-03** | Access Admin Dashboard | Administrator | `GET /api/admin/dashboard` | 200 OK with metrics | **PASS** |
| **RBAC-04** | Manage Users | Store Staff | `GET /api/users` | 403 Forbidden | **PASS** |
| **RBAC-05** | Manage Users | Administrator | `GET /api/users` | 200 OK with user list | **PASS** |
| **RBAC-06** | Self-deactivation prevention | Administrator | `PUT /api/users/1` with status 'inactive' | 400 Bad Request: Cannot deactivate own account | **PASS** |
| **RBAC-07** | Staff manages stock | Store Staff | `PUT /api/books/{id}` | 200 OK | **PASS** |

---

## 3. Automated Test Execution Results

1. **PHP CLI Backend Tests**:
   - `php test/backend_test.php`
   - **Result**: `All Backend Verification Tests PASSED!`
2. **Flutter Static Analysis**:
   - `flutter analyze`
   - **Result**: `No issues found!` (0 errors, 0 warnings).
3. **Flutter Widget & Unit Tests**:
   - `flutter test`
   - **Result**: `5/5 tests passed!`
