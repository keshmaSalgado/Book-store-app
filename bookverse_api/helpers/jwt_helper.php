<?php
// ====================================================================
// BookVerse REST API - Pure PHP JWT Implementation (HMAC-SHA256)
// ====================================================================

require_once __DIR__ . '/../config/config.php';

class JWT {
    /**
     * Base64Url Encode
     */
    private static function base64UrlEncode(string $data): string {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    /**
     * Base64Url Decode
     */
    private static function base64UrlDecode(string $data): string {
        return base64_decode(strtr($data, '-_', '+/'));
    }

    /**
     * Generate a signed JWT token
     * 
     * @param array $payload Token claims (sub, name, email, role, etc.)
     * @param int|null $expiresIn Expiration duration in seconds
     * @return string Signed JWT string
     */
    public static function generateToken(array $payload, ?int $expiresIn = null): string {
        $expiresIn = $expiresIn ?? JWT_EXPIRY_SECONDS;
        $now = time();

        $header = [
            'typ' => 'JWT',
            'alg' => 'HS256'
        ];

        $payload['iss'] = JWT_ISSUER;
        $payload['iat'] = $now;
        $payload['exp'] = $now + $expiresIn;

        $headerEncoded = self::base64UrlEncode(json_encode($header));
        $payloadEncoded = self::base64UrlEncode(json_encode($payload));

        $signature = hash_hmac('sha256', "$headerEncoded.$payloadEncoded", JWT_SECRET, true);
        $signatureEncoded = self::base64UrlEncode($signature);

        return "$headerEncoded.$payloadEncoded.$signatureEncoded";
    }

    /**
     * Verify and decode a JWT token
     * 
     * @param string $token JWT token
     * @return array Decoded payload
     * @throws Exception If token is invalid or expired
     */
    public static function verifyToken(string $token): array {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            throw new Exception('Invalid token format');
        }

        [$headerEncoded, $payloadEncoded, $signatureEncoded] = $parts;

        $signature = self::base64UrlDecode($signatureEncoded);
        $expectedSignature = hash_hmac('sha256', "$headerEncoded.$payloadEncoded", JWT_SECRET, true);

        if (!hash_equals($signature, $expectedSignature)) {
            throw new Exception('Invalid token signature');
        }

        $payload = json_decode(self::base64UrlDecode($payloadEncoded), true);
        if (!is_array($payload)) {
            throw new Exception('Invalid token payload');
        }

        if (isset($payload['exp']) && $payload['exp'] < time()) {
            throw new Exception('Token has expired');
        }

        return $payload;
    }
}
