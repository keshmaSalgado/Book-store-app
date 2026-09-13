<?php
// ====================================================================
// BookVerse REST API - Response Helper & CORS Headers
// ====================================================================

// Set CORS headers for all incoming API requests
function setupCors(): void {
    // Allow from any origin
    if (isset($_SERVER['HTTP_ORIGIN'])) {
        header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
        header('Access-Control-Allow-Credentials: true');
    } else {
        header("Access-Control-Allow-Origin: *");
    }

    header('Access-Control-Max-Age: 86400'); // Cache preflight for 1 day

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD'])) {
            header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
        }
        if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS'])) {
            header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");
        } else {
            header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
        }
        http_response_code(200);
        exit;
    }
}

// Call CORS setup automatically
setupCors();

/**
 * Send JSON response
 * 
 * @param int $statusCode HTTP Status Code
 * @param bool $success Success indicator
 * @param string $message User/developer message
 * @param mixed $data Optional payload
 */
function sendResponse(int $statusCode, bool $success, string $message, $data = null): void {
    header('Content-Type: application/json; charset=UTF-8');
    http_response_code($statusCode);

    $response = [
        'success' => $success,
        'message' => $message,
    ];

    if ($data !== null) {
        $response['data'] = $data;
    }

    echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

/**
 * Helper to send quick success response (200 OK)
 */
function sendSuccess(string $message = 'Request successful', $data = null, int $statusCode = 200): void {
    sendResponse($statusCode, true, $message, $data);
}

/**
 * Helper to send error response
 */
function sendError(string $message, int $statusCode = 400): void {
    sendResponse($statusCode, false, $message);
}

/**
 * Parse JSON input from php://input
 * 
 * @return array
 */
function getJsonInput(): array {
    $rawInput = file_get_contents('php://input');
    if (empty($rawInput)) {
        return $_POST; // Fallback to standard POST data if form-encoded
    }
    $decoded = json_decode($rawInput, true);
    if (!is_array($decoded)) {
        return [];
    }
    return $decoded;
}
