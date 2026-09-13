<?php
// ====================================================================
// BookVerse REST API - Role-Based Access Control Middleware
// ====================================================================

require_once __DIR__ . '/../helpers/response.php';

class RoleMiddleware {
    /**
     * Ensure user role is in the allowed list
     * 
     * @param array|string $allowedRoles Single role string or array of allowed roles
     * @param array $currentUser User array returned from AuthMiddleware::authenticate()
     */
    public static function checkRole($allowedRoles, array $currentUser): void {
        if (is_string($allowedRoles)) {
            $allowedRoles = [$allowedRoles];
        }

        $userRole = $currentUser['role'] ?? '';

        if (!in_array($userRole, $allowedRoles, true)) {
            sendError('Forbidden: You do not have permission to perform this action', 403);
            exit;
        }
    }

    /**
     * Require Admin role
     */
    public static function requireAdmin(array $currentUser): void {
        self::checkRole(['admin'], $currentUser);
    }

    /**
     * Require Staff or Admin role
     */
    public static function requireStaffOrAdmin(array $currentUser): void {
        self::checkRole(['staff', 'admin'], $currentUser);
    }

    /**
     * Require Customer role
     */
    public static function requireCustomer(array $currentUser): void {
        self::checkRole(['customer', 'admin'], $currentUser);
    }
}
