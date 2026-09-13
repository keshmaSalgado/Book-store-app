<?php
// ====================================================================
// BookVerse REST API - Master Front Controller & Router
// Routes clean REST endpoints to modular endpoint scripts
// ====================================================================

require_once __DIR__ . '/helpers/response.php';

// Normalize the request URI path
$requestUri = $_SERVER['REQUEST_URI'];
$scriptName = $_SERVER['SCRIPT_NAME'];

// Remove query string
$path = parse_url($requestUri, PHP_URL_PATH);

// Strip the base directory (e.g. /bookverse_api/)
$baseDir = dirname($scriptName);
if ($baseDir !== '/' && strpos($path, $baseDir) === 0) {
    $path = substr($path, strlen($baseDir));
}
$path = '/' . trim($path, '/');

$method = $_SERVER['REQUEST_METHOD'];

// Handle root status check
if ($path === '/' || $path === '/api' || $path === '') {
    sendSuccess('Welcome to BookVerse REST API', [
        'name'      => 'BookVerse API',
        'status'    => 'running',
        'version'   => '1.0.0',
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}

// --------------------------------------------------------------------
// Route Table Matching
// --------------------------------------------------------------------

// Authentication
if ($path === '/api/auth/register' && $method === 'POST') {
    require __DIR__ . '/auth/register.php';
    exit;
}

if ($path === '/api/auth/login' && $method === 'POST') {
    require __DIR__ . '/auth/login.php';
    exit;
}

if ($path === '/api/auth/profile') {
    require __DIR__ . '/auth/profile.php';
    exit;
}

if ($path === '/api/auth/logout' && $method === 'POST') {
    require __DIR__ . '/auth/logout.php';
    exit;
}

// Books Search
if ($path === '/api/books/search' && $method === 'GET') {
    require __DIR__ . '/books/search_books.php';
    exit;
}

// Single Book Operations (/api/books/{id})
if (preg_match('#^/api/books/(\d+)$#', $path, $matches)) {
    $_GET['id'] = $matches[1];
    if ($method === 'GET') {
        require __DIR__ . '/books/get_book.php';
        exit;
    } elseif ($method === 'PUT') {
        require __DIR__ . '/books/update_book.php';
        exit;
    } elseif ($method === 'DELETE') {
        require __DIR__ . '/books/delete_book.php';
        exit;
    }
}

// Books Collection (/api/books)
if ($path === '/api/books') {
    if ($method === 'GET') {
        require __DIR__ . '/books/get_books.php';
        exit;
    } elseif ($method === 'POST') {
        require __DIR__ . '/books/add_book.php';
        exit;
    }
}

// Single Category Operations (/api/categories/{id})
if (preg_match('#^/api/categories/(\d+)$#', $path, $matches)) {
    $_GET['id'] = $matches[1];
    if ($method === 'PUT') {
        require __DIR__ . '/categories/update_category.php';
        exit;
    } elseif ($method === 'DELETE') {
        require __DIR__ . '/categories/delete_category.php';
        exit;
    }
}

// Categories Collection (/api/categories)
if ($path === '/api/categories') {
    if ($method === 'GET') {
        require __DIR__ . '/categories/get_categories.php';
        exit;
    } elseif ($method === 'POST') {
        require __DIR__ . '/categories/add_category.php';
        exit;
    }
}

// Shopping Cart Item Operations (/api/cart/{id})
if (preg_match('#^/api/cart/(\d+)$#', $path, $matches)) {
    $_GET['id'] = $matches[1];
    if ($method === 'PUT') {
        require __DIR__ . '/cart/update_cart.php';
        exit;
    } elseif ($method === 'DELETE') {
        require __DIR__ . '/cart/remove_cart.php';
        exit;
    }
}

// Shopping Cart Collection (/api/cart)
if ($path === '/api/cart') {
    if ($method === 'GET') {
        require __DIR__ . '/cart/get_cart.php';
        exit;
    } elseif ($method === 'POST') {
        require __DIR__ . '/cart/add_to_cart.php';
        exit;
    }
}

// Order Status Update (/api/orders/{id}/status)
if (preg_match('#^/api/orders/(\d+)/status$#', $path, $matches)) {
    $_GET['id'] = $matches[1];
    if ($method === 'PUT' || $method === 'POST') {
        require __DIR__ . '/orders/update_order_status.php';
        exit;
    }
}

// Single Order (/api/orders/{id})
if (preg_match('#^/api/orders/(\d+)$#', $path, $matches)) {
    $_GET['id'] = $matches[1];
    if ($method === 'GET') {
        require __DIR__ . '/orders/get_order.php';
        exit;
    }
}

// Orders Collection (/api/orders)
if ($path === '/api/orders') {
    if ($method === 'GET') {
        require __DIR__ . '/orders/get_orders.php';
        exit;
    } elseif ($method === 'POST') {
        require __DIR__ . '/orders/place_order.php';
        exit;
    }
}

// Single User Operations (/api/users/{id})
if (preg_match('#^/api/users/(\d+)$#', $path, $matches)) {
    $_GET['id'] = $matches[1];
    if ($method === 'PUT') {
        require __DIR__ . '/users/update_user.php';
        exit;
    } elseif ($method === 'DELETE') {
        require __DIR__ . '/users/delete_user.php';
        exit;
    }
}

// Users Collection (/api/users)
if ($path === '/api/users') {
    if ($method === 'GET') {
        require __DIR__ . '/users/get_users.php';
        exit;
    } elseif ($method === 'POST') {
        require __DIR__ . '/users/add_user.php';
        exit;
    }
}

// Dashboards
if ($path === '/api/admin/dashboard' && $method === 'GET') {
    require __DIR__ . '/dashboard/admin_dashboard.php';
    exit;
}

if ($path === '/api/staff/dashboard' && $method === 'GET') {
    require __DIR__ . '/dashboard/staff_dashboard.php';
    exit;
}

// If no matching route found
sendError("Route '$path' [$method] not found", 404);
