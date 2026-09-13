<?php
// ====================================================================
// BookVerse REST API - Authentication Middleware
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/jwt_helper.php';
require_once __DIR__ . '/../config/database.php';

class AuthMiddleware {
    /**
     * Authenticate incoming request via Bearer JWT
     * 
     * @return array Decoded user data
     */
    public static function authenticate(): array {
        $headers = self::getRequestHeaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';

        if (empty($authHeader)) {
            // Also check Apache / FastCGI environment variables
            if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
                $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
            } elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
                $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
            }
        }

        if (empty($authHeader) || !preg_match('/Bearer\s+(\S+)/', $authHeader, $matches)) {
            sendError('Unauthorized access: Missing or invalid token', 401);
        }

        $token = $matches[1];

        try {
            $payload = JWT::verifyToken($token);

            // Verify user in database to ensure account is active and not deleted
            $db = Database::getConnection();
            $stmt = $db->prepare("SELECT id, name, email, role, status FROM users WHERE id = :id LIMIT 1");
            $stmt->execute(['id' => $payload['user_id'] ?? $payload['sub'] ?? 0]);
            $user = $stmt->fetch();

            if (!$user) {
                sendError('Unauthorized access: User does not exist', 401);
            }

            if ($user['status'] !== 'active') {
                sendError('Account is inactive. Please contact support.', 403);
            }

            return $user;
        } catch (Exception $e) {
            sendError('Unauthorized access: ' . $e->getMessage(), 401);
            exit;
        }
    }

    /**
     * Helper to reliably get request headers across different servers
     */
    private static function getRequestHeaders(): array {
        if (function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
            if ($headers !== false) {
                return $headers;
            }
        }

        $headers = [];
        foreach ($_SERVER as $key => $value) {
            if (str_starts_with($key, 'HTTP_')) {
                $headerName = str_replace(' ', '-', ucwords(str_replace('_', ' ', strtolower(substr($key, 5)))));
                $headers[$headerName] = $value;
            }
        }
        return $headers;
    }
}
