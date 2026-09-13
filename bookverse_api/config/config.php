<?php
// ====================================================================
// BookVerse REST API - Global Configuration
// ====================================================================

// Application Details
define('APP_NAME', 'BookVerse API');
define('APP_VERSION', '1.0.0');

// Database Configuration
define('DB_HOST', 'localhost');
define('DB_NAME', 'bookverse_db');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

// JWT Configuration
define('JWT_SECRET', 'BookVerse_SuperSecret_Security_Key_2026_SEN5001');
define('JWT_EXPIRY_SECONDS', 60 * 60 * 24 * 7); // 7 days expiration
define('JWT_ISSUER', 'bookverse-api');

// Timezone
date_default_timezone_set('UTC');
