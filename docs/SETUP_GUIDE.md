# BookVerse - Complete Setup & Installation Guide
**Module**: SEN5001 Mobile and Web Technologies

---

## 1. Prerequisites

Before starting, ensure the following are installed on your machine:
- **XAMPP** (with Apache, PHP 8.1+, and MySQL)
- **Flutter SDK** (Version 3.19+)
- **Android Studio** (for Android Emulator) or Google Chrome (for Web testing)

---

## 2. Database Setup (MySQL)

### Method A: Using phpMyAdmin (Recommended for GUI)
1. Open XAMPP Control Panel and start **MySQL** and **Apache**.
2. Open your web browser and go to: `http://localhost/phpmyadmin`
3. Click on the **Import** tab in the top menu.
4. Click **Choose File** and browse to:
   ```
   online_bookstore/database/bookverse_db.sql
   ```
5. Click **Import** at the bottom.
6. The `bookverse_db` database will be created with 7 tables, sample accounts, 5 categories, and 16 realistic books.

### Method B: Using MySQL Command Line
1. Open PowerShell or Command Prompt.
2. Run:
   ```powershell
   & "C:\xampp\mysql\bin\mysql.exe" -u root < "online_bookstore\database\bookverse_db.sql"
   ```

---

## 3. Backend API Setup (PHP & XAMPP)

1. Copy the `bookverse_api` directory to your XAMPP `htdocs` directory:
   ```powershell
   Copy-Item -Path "online_bookstore\bookverse_api" -Destination "C:\xampp\htdocs\bookverse_api" -Recurse -Force
   ```
2. Verify that Apache is running in the **XAMPP Control Panel**.
3. Open your browser and test the API health check:
   ```
   http://localhost/bookverse_api/
   ```
   You should see:
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
4. Test books endpoint:
   ```
   http://localhost/bookverse_api/api/books
   ```

---

## 4. Flutter Mobile Application Setup

1. Open a terminal in the Flutter project directory:
   ```powershell
   cd "c:\Mythings\myassisnmentinsemester3\Mobile and web\project\online_bookstore"
   ```
2. Download all Dart dependencies:
   ```powershell
   flutter pub get
   ```
3. Verify that there are zero compilation errors:
   ```powershell
   flutter analyze
   flutter test
   ```

---

## 5. Network Configuration for Different Devices

In `lib/utils/api_constants.dart`, the app is configured to automatically pick the correct IP:

### Scenario 1: Android Emulator
- Android Emulator automatically uses `http://10.0.2.2/bookverse_api`.
- Run:
  ```powershell
  flutter run
  ```

### Scenario 2: Physical Android Device via Wi-Fi
- Both your PC (running XAMPP) and your Android phone must be connected to the **same Wi-Fi network**.
- Find your PC's local IP (e.g. `192.168.1.100`) via `ipconfig`.
- In `lib/utils/api_constants.dart`, set:
  ```dart
  static const String physicalDeviceIp = '192.168.1.100'; // Replace with your PC IP
  ```
- Run:
  ```powershell
  flutter run
  ```

### Scenario 3: Windows Desktop / Chrome
- Run directly in Chrome or Windows desktop for immediate visual testing:
  ```powershell
  flutter run -d chrome
  # OR
  flutter run -d windows
  ```

---

## 6. Seed Accounts for Demonstration

| Role | Email | Password | Permissions |
| :--- | :--- | :--- | :--- |
| **Administrator** | `admin@bookverse.com` | `Admin@123` | Full control: Users, Books, Categories, Orders, Dashboard metrics |
| **Store Staff** | `staff@bookverse.com` | `Staff@123` | Book inventory & stock editing, Order fulfillment & status updates |
| **Customer 1** | `customer1@bookverse.com` | `Customer@123` | Book browsing, search, shopping cart, checkout, order history |
| **Customer 2** | `customer2@bookverse.com` | `Customer@123` | Customer features |

*Note: The login screen contains convenient "Quick Demo Accounts" buttons that fill these credentials with a single tap!*
