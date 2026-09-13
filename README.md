# 📚 BookVerse — Interactive Mobile Bookstore Application

A full-stack, enterprise-grade mobile application for an online bookstore built for the **SEN5001 Mobile and Web Technologies** assignment.

The application allows users to browse and search books, view book details, manage a persistent shopping cart, and place orders. It also features comprehensive role-based portals for **Customers**, **Store Staff**, and **System Administrators** backed by a custom **PHP REST API** and **MySQL** database.

---

## 🏗️ Architecture & Technology Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Mobile Frontend** | **Flutter / Dart** | Material Design 3, responsive layout, Provider state management |
| **Backend REST API** | **PHP 8.x** | Pure RESTful architecture, modular endpoint routing, JSON payloads |
| **Authentication** | **JWT + PHP Bcrypt** | `Firebase\JWT`, secure `password_hash()` and `password_verify()` |
| **Relational Database** | **MySQL (XAMPP)** | InnoDB engine, foreign keys, transaction rollbacks, indexation |
| **API Testing** | **Postman** | Complete test suite with automated assertions & JWT variables |

---

## 📂 Project Structure

```text
online_bookstore/
├── bookverse_api/              # PHP REST API (Deploy to XAMPP htdocs)
│   ├── api/                    # REST endpoints (auth, books, cart, categories, orders, users)
│   ├── config/                 # Database connection & JWT configuration
│   ├── helpers/                # Response helpers & JWT validation middleware
│   ├── index.php               # API health check & documentation gateway
│   └── vendor/                 # PHP JWT dependency
├── database/                   # Database schema and seed data
│   └── bookverse_db.sql        # MySQL dump (7 tables + seed users, books & categories)
├── docs/                       # University assignment documentation
│   ├── API_DOCUMENTATION.md    # Complete REST API specifications with samples
│   ├── DATABASE_ERD.md         # Database schema & Entity Relationship Diagram
│   ├── POSTMAN_TESTING.md      # Postman test collection and test run guide
│   ├── SETUP_GUIDE.md          # Step-by-step installation instructions
│   └── TEST_PLAN_AND_CASES.md  # Formal QA test plan & test matrix
├── lib/                        # Flutter Application Source Code
│   ├── models/                 # Dart data models (Book, Cart, Order, User, Category)
│   ├── screens/                # UI screens (Customer, Staff, Admin, Auth)
│   ├── services/               # HTTP client & API communication layer
│   ├── utils/                  # App theme, constants, validators & network config
│   └── widgets/                # Reusable UI widgets
├── pubspec.yaml                # Flutter dependencies & assets
└── README.md                   # Project overview & quickstart instructions
```

---

## 🚀 Quick Setup & Installation Guide

Follow these steps to run the complete stack locally.

### Step 1: Prerequisites
Make sure you have installed:
- [XAMPP](https://www.apachefriends.org/) (Apache, PHP 8.1+, MySQL)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19 or later)
- An Android Emulator (via Android Studio), a physical Android device, or Google Chrome.

---

### Step 2: Database Setup (MySQL)

1. Start **Apache** and **MySQL** in the **XAMPP Control Panel**.
2. Open **phpMyAdmin** in your browser: [http://localhost/phpmyadmin](http://localhost/phpmyadmin).
3. Click the **Import** tab at the top.
4. Click **Choose File** and select:
   ```text
   online_bookstore/database/bookverse_db.sql
   ```
5. Click **Import** at the bottom of the page.
6. The `bookverse_db` database will be created with:
   - 7 relational tables (`users`, `categories`, `books`, `cart_items`, `orders`, `order_items`, `user_tokens`).
   - 5 book categories.
   - 16 initial books with covers, authors, ratings, and stock.
   - 4 pre-configured user accounts across Admin, Staff, and Customer roles.

> 💡 **Alternative (via Command Line)**:
> ```powershell
> & "C:\xampp\mysql\bin\mysql.exe" -u root < "c:\path\to\online_bookstore\database\bookverse_db.sql"
> ```

---

### Step 3: Backend API Setup (Copy to XAMPP `htdocs`)

1. Copy the `bookverse_api` directory from this project directly into your XAMPP `htdocs` folder:
   ```powershell
   # Run in PowerShell from the project root:
   Copy-Item -Path ".\bookverse_api" -Destination "C:\xampp\htdocs\bookverse_api" -Recurse -Force
   ```
2. Verify the API is running by visiting the health check in your browser:
   [http://localhost/bookverse_api/](http://localhost/bookverse_api/)

   You should receive a JSON response:
   ```json
   {
     "success": true,
     "message": "Welcome to BookVerse REST API",
     "data": {
       "name": "BookVerse API",
       "status": "running",
       "version": "1.0.0"
     }
   }
   ```
3. Test the books endpoint:
   [http://localhost/bookverse_api/api/books](http://localhost/bookverse_api/api/books)

---

### Step 4: Flutter Mobile Application Setup

1. Open a terminal in the `online_bookstore` project directory:
   ```powershell
   cd "c:\path\to\online_bookstore"
   ```
2. Install dependencies:
   ```powershell
   flutter pub get
   ```
3. Run static analysis and tests to ensure everything is green:
   ```powershell
   flutter analyze
   flutter test
   ```

---

### Step 5: Network Configuration & Running the App

The Flutter app automatically handles endpoint URLs depending on your execution environment in [`lib/utils/api_constants.dart`](file:///lib/utils/api_constants.dart):

#### Option A: Android Emulator (Default)
The Android Emulator cannot connect directly to `localhost`. It automatically routes to `http://10.0.2.2/bookverse_api`.
```powershell
flutter run
```

#### Option B: Physical Android Device via Wi-Fi
1. Ensure your PC running XAMPP and your phone are on the **same Wi-Fi network**.
2. Run `ipconfig` in your command prompt to find your PC's IP address (e.g. `192.168.1.100`).
3. Open `lib/utils/api_constants.dart` and update `physicalDeviceIp`:
   ```dart
   static const String physicalDeviceIp = '192.168.1.100'; // Your PC IP
   ```
4. Run the app:
   ```powershell
   flutter run
   ```

#### Option C: Web Browser / Windows Desktop
Run directly on Chrome or Windows desktop for immediate visual testing:
```powershell
flutter run -d chrome
# OR
flutter run -d windows
```

---

## 🔑 Pre-Configured Demo Accounts

For fast demonstration and grading, the app includes "Quick Demo" buttons on the login screen that automatically populate these credentials:

| Role | Email Address | Password | Privileges |
| :--- | :--- | :--- | :--- |
| **Administrator** | `admin@bookverse.com` | `Admin@123` | Full analytics dashboard, manage books, manage users, manage categories, manage orders |
| **Store Staff** | `staff@bookverse.com` | `Staff@123` | Operations portal, stock adjustment, book inventory editor, order fulfillment |
| **Customer 1** | `customer1@bookverse.com` | `Customer@123` | Book browsing, search, persistent shopping cart, checkout, order history |
| **Customer 2** | `customer2@bookverse.com` | `Customer@123` | Additional customer account for testing concurrent orders & user management |

---

## 🧪 Postman & Automated API Testing

A complete Postman collection and environment are documented in [`docs/POSTMAN_TESTING.md`](file:///docs/POSTMAN_TESTING.md).

Endpoints covered:
- **Authentication**: `POST /api/auth/register`, `POST /api/auth/login`, `GET /api/auth/profile`, `PUT /api/auth/profile`
- **Books**: `GET /api/books`, `GET /api/books/{id}`, `POST /api/books`, `PUT /api/books/{id}`, `DELETE /api/books/{id}`
- **Categories**: `GET /api/categories`, `POST /api/categories`, `PUT /api/categories/{id}`, `DELETE /api/categories/{id}`
- **Cart**: `GET /api/cart`, `POST /api/cart`, `PUT /api/cart/{id}`, `DELETE /api/cart/{id}`
- **Orders**: `POST /api/orders`, `GET /api/orders`, `GET /api/orders/{id}`, `PUT /api/orders/{id}/status`
- **Users**: `GET /api/users`, `POST /api/users`, `PUT /api/users/{id}`, `DELETE /api/users/{id}`, `GET /api/users/dashboard`

---

## 📝 University Assignment Details

- **Module**: SEN5001 Mobile and Web Technologies
- **Project**: Interactive Mobile Application for an Online Bookstore
- **Core Requirements Implemented**:
  - ✅ Intuitive, interactive Material Design 3 mobile UI
  - ✅ Category filtering, instant search by title/author/ISBN, and detailed views
  - ✅ Persistent shopping cart with stock-aware quantity selectors
  - ✅ Concurrency-safe order checkout flow with real-time stock deduction
  - ✅ Role-Based Access Control (Customer / Staff / Admin)
  - ✅ Secure password hashing (`password_hash` with BCRYPT) & JWT token authentication
  - ✅ Relational MySQL database with foreign keys & transaction rollbacks
  - ✅ Comprehensive documentation & Postman test suite
#   C - M y t h i n g s - m y a s s i s n m e n t i n s e m e s t e r 3 - M o b i l e - a n d - w e b - p r o j e c t - o n l i n e _ b o o k s t o r e  
 