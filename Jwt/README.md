# NAVFoundation.Jwt

## Overview

The JWT implementation provides comprehensive functionality for creating, signing, verifying, and decoding JSON Web Tokens (JWT) in NetLinx applications. JSON Web Tokens are an open, industry-standard method for representing claims securely between two parties.

This library implements:

- **RFC 7519** - JSON Web Token (JWT)
- **RFC 7515** - JSON Web Signature (JWS)

Key features:

- Create JWT tokens with custom headers and payloads
- Sign tokens using HMAC algorithms (HS256, HS512; HS384 not yet implemented)
- Verify token signatures
- Decode and extract token components
- Time-based validation (exp, nbf, iat claims)
- Comprehensive error handling

**Dependencies:**

- NAVFoundation.Core
- NAVFoundation.Encoding.Base64Url
- NAVFoundation.Cryptography.Hmac
- NAVFoundation.StringUtils

## Buffer Size Configuration

The library uses domain-specific buffer size constants that can be configured at compile time:

- **`NAV_JWT_MAX_TOKEN_LENGTH`** (default: 4096 bytes) - Maximum length for complete JWT token strings
- **`NAV_JWT_MAX_COMPONENT_LENGTH`** (default: 2048 bytes) - Maximum length for individual token components (header, payload, signature)
- **`NAV_JWT_MAX_JSON_LENGTH`** (default: 2048 bytes) - Maximum length for decoded JSON header/payload strings

These can be overridden before including the library:

```netlinx
#DEFINE NAV_JWT_MAX_TOKEN_LENGTH 8192
#include 'NAVFoundation.Jwt.axi'
```

## What is JWT?

JSON Web Token (JWT) is a compact, URL-safe means of representing claims to be transferred between two parties. The claims in a JWT are encoded as a JSON object that is used as the payload of a JSON Web Signature (JWS) structure.

A JWT consists of three parts separated by dots (`.`):

```
header.payload.signature
```

**Example JWT:**

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U
```

### JWT Structure

1. **Header** - Contains metadata about the token (algorithm, type)

    ```json
    {
        "alg": "HS256",
        "typ": "JWT"
    }
    ```

2. **Payload** - Contains the claims (data)

    ```json
    {
        "sub": "1234567890",
        "name": "John Doe",
        "iat": 1516239022
    }
    ```

3. **Signature** - Ensures the token hasn't been tampered with
    ```
    HMACSHA256(
      base64UrlEncode(header) + "." + base64UrlEncode(payload),
      secret
    )
    ```

## Common Use Cases

JWT is commonly used for:

- **API Authentication** - Stateless authentication for REST APIs
- **Single Sign-On (SSO)** - Cross-domain authentication
- **Information Exchange** - Securely transmitting information between parties
- **Authorization** - Granting access to resources
- **Session Management** - Alternative to server-side sessions
- **Third-party Integration** - Authentication with external services (OAuth, OpenID Connect)
- **Control System Integration** - Secure communication between AMX systems and cloud services

## API Reference

### Core Functions

#### `NAVJwtCreate`

```netlinx
define_function char NAVJwtCreate(char headerJson[], char payloadJson[], char secret[], char token[])
```

**Description:** Creates a complete JWT token from header and payload JSON strings.

**Parameters:**

- `headerJson` - Header JSON string (or empty string for default HS256 header)
- `payloadJson` - Payload JSON string containing claims
- `secret` - Secret key for HMAC signing
- `token` - Output: Complete JWT token string (header.payload.signature)

**Returns:** `true` if successful, `false` otherwise

**Example:**

```netlinx
stack_var char token[NAV_JWT_MAX_TOKEN_LENGTH]
stack_var char payload[500]

payload = '{"sub":"user123","name":"John Doe","iat":1516239022}'
if (NAVJwtCreate('', payload, 'mySecretKey', token)) {
    // Token created successfully
}
// Use empty string for headerJson to get default HS256 header
```

#### `NAVJwtVerify`

```netlinx
define_function char NAVJwtVerify(char token[], char secret[])
```

**Description:** Verifies the signature of a JWT token.

**Parameters:**

- `token` - Complete JWT token string
- `secret` - Secret key used for signing

**Returns:** `true` if valid, `false` otherwise

**Example:**

```netlinx
if (NAVJwtVerify(token, 'mySecretKey')) {
    send_string 0, "'Token is valid'"
} else {
    send_string 0, "'Token verification failed'"
}
```

#### `NAVJwtDecode`

```netlinx
define_function char NAVJwtDecode(char token[], _NAVJwtToken jwtToken)
```

**Description:** Decodes a JWT token into a \_NAVJwtToken structure with all components.

**Parameters:**

- `token` - Complete JWT token string
- `jwtToken` - Output structure containing decoded components

**Returns:** `true` if successful, `false` otherwise (errorCode field set in struct)

**Example:**

```netlinx
stack_var _NAVJwtToken jwtToken

if (NAVJwtDecode(token, jwtToken)) {
    send_string 0, "'Header: ', jwtToken.headerJson"
    send_string 0, "'Payload: ', jwtToken.payloadJson"
    send_string 0, "'Algorithm: ', jwtToken.headerParsed.alg"
} else {
    send_string 0, "'Decode failed: ', NAVJwtGetErrorMessage(jwtToken.errorCode)"
}
```

#### `NAVJwtVerifyAndDecode`

```netlinx
define_function char NAVJwtVerifyAndDecode(char token[], char secret[], _NAVJwtToken jwtToken)
```

**Description:** Verifies and decodes a JWT token in one operation.

**Parameters:**

- `token` - Complete JWT token string
- `secret` - Secret key used for signing
- `jwtToken` - Output structure containing decoded components

**Returns:** `true` if valid, `false` otherwise (errorCode field set in struct)

**Example:**

```netlinx
stack_var _NAVJwtToken jwtToken

if (NAVJwtVerifyAndDecode(token, 'mySecretKey', jwtToken)) {
    send_string 0, "'Valid token from: ', jwtToken.payloadJson"
} else {
    send_string 0, "'Error: ', NAVJwtGetErrorMessage(jwtToken.errorCode)"
}
```

### Component Extraction Functions

#### `NAVJwtGetHeader`

```netlinx
define_function char NAVJwtGetHeader(char token[], char header[])
```

**Description:** Extracts and decodes the header from a JWT token.

**Parameters:**

- `token` - Complete JWT token string
- `header` - Output: Decoded header JSON string

**Returns:** `true` if successful, `false` otherwise

#### `NAVJwtGetPayload`

```netlinx
define_function char NAVJwtGetPayload(char token[], char payload[])
```

**Description:** Extracts and decodes the payload from a JWT token.

**Parameters:**

- `token` - Complete JWT token string
- `payload` - Output: Decoded payload JSON string

**Returns:** `true` if successful, `false` otherwise

#### `NAVJwtGetSignature`

```netlinx
define_function char NAVJwtGetSignature(char token[], char signature[])
```

**Description:** Extracts the signature component from a JWT token (Base64Url encoded).

**Parameters:**

- `token` - Complete JWT token string
- `signature` - Output: Base64Url encoded signature

**Returns:** `true` if successful, `false` otherwise

### Helper Functions

#### `NAVJwtCreateHeader`

```netlinx
define_function char[NAV_JWT_MAX_JSON_LENGTH] NAVJwtCreateHeader(char algorithm[], char tokenType[])
```

**Description:** Creates a standard JWT header JSON string.

**Parameters:**

- `algorithm` - Signing algorithm (use `NAV_JWT_ALG_HS256` or `NAV_JWT_ALG_HS512`; HS384 not yet implemented)
- `tokenType` - Token type (default: `NAV_JWT_TYP_JWT`)

**Returns:** JSON string representing the JWT header

**Example:**

```netlinx
stack_var char header[NAV_JWT_MAX_JSON_LENGTH]
header = NAVJwtCreateHeader(NAV_JWT_ALG_HS256, NAV_JWT_TYP_JWT)
// Returns: {"alg":"HS256","typ":"JWT"}
```

#### `NAVJwtSign`

```netlinx
define_function char NAVJwtSign(char encodedHeader[], char encodedPayload[],
                                char secret[], char algorithm[], char token[])
```

**Description:** Signs existing Base64Url encoded header and payload components.

**Parameters:**

- `encodedHeader` - Base64Url encoded header
- `encodedPayload` - Base64Url encoded payload
- `secret` - Secret key for signing
- `algorithm` - Algorithm to use
- `token` - Output: Complete JWT token string

**Returns:** `true` if successful, `false` otherwise

#### `NAVJwtValidateTime`

```netlinx
define_function char NAVJwtValidateTime(char payloadJson[], slong currentTime, integer clockSkew)
```

**Description:** Validates time-based claims (exp, nbf, iat) in a JWT token.

**Parameters:**

- `payloadJson` - Decoded payload JSON string
- `currentTime` - Current Unix timestamp (signed long)
- `clockSkew` - Allowed clock skew in seconds

**Returns:** `true` if valid, `false` if expired or not yet valid

#### `NAVJwtGetErrorMessage`

```netlinx
define_function char[128] NAVJwtGetErrorMessage(sinteger errorCode)
```

**Description:** Returns a human-readable error message for a JWT error code.

**Parameters:**

- `errorCode` - JWT error code

**Returns:** Error message string

## Usage Examples

### Creating a Simple JWT Token

```netlinx
#include 'NAVFoundation.Jwt.axi'

define_function char CreateAccessToken(char userId[], char token[]) {
    stack_var char payload[500]
    stack_var slong currentTime

    // Get current Unix timestamp (you'll need a time function)
    currentTime = 1516239022  // Example timestamp

    // Create payload with standard claims
    payload = "'{',
               '"sub":"', userId, '",',
               '"iat":', itoa(currentTime),
               '}'"

    // Create token with default HS256 header
    return NAVJwtCreate('', payload, 'your-256-bit-secret', token)
}
```

### Creating a JWT with Expiration

```netlinx
#include 'NAVFoundation.Jwt.axi'

define_function char CreateExpiringToken(char userId[], integer expiresInSeconds, char token[]) {
    stack_var char payload[500]
    stack_var slong currentTime
    stack_var slong expirationTime

    currentTime = 1516239022      // Current timestamp
    expirationTime = currentTime + expiresInSeconds

    // Create payload with exp claim
    payload = "'{',
               '"sub":"', userId, '",',
               '"iat":', itoa(currentTime), ',',
               '"exp":', itoa(expirationTime),
               '}'"

    return NAVJwtCreate('', payload, 'your-256-bit-secret', token)
}
```

### Verifying a JWT Token

```netlinx
#include 'NAVFoundation.Jwt.axi'

define_function integer AuthenticateRequest(char token[]) {
    stack_var _NAVJwtToken jwtToken

    // Verify and decode the token
    if (!NAVJwtVerifyAndDecode(token, 'your-256-bit-secret', jwtToken)) {
        send_string 0, "'Authentication failed: ', NAVJwtGetErrorMessage(jwtToken.errorCode)"
        return false
    }

    send_string 0, "'Authenticated. Payload: ', jwtToken.payloadJson"
    return true
}
```

### Extracting Claims from a Token

```netlinx
#include 'NAVFoundation.Jwt.axi'

define_function ProcessToken(char token[]) {
    stack_var char headerJson[NAV_JWT_MAX_JSON_LENGTH]
    stack_var char payloadJson[NAV_JWT_MAX_JSON_LENGTH]

    // Extract and decode components without verification
    // (useful for debugging or when signature verification is handled elsewhere)
    if (NAVJwtGetHeader(token, headerJson)) {
        send_string 0, "'Header: ', headerJson"
    }

    if (NAVJwtGetPayload(token, payloadJson)) {
        send_string 0, "'Payload: ', payloadJson"
    }

    // Now you can parse the JSON to extract specific claims
    // (Using your JSON parsing library)
}
```

### Creating a Token with Custom Header

```netlinx
#include 'NAVFoundation.Jwt.axi'

define_function char CreateTokenWithHS512(char token[]) {
    stack_var char header[NAV_JWT_MAX_JSON_LENGTH]
    stack_var char payload[500]

    // Create custom header with HS512 algorithm
    header = NAVJwtCreateHeader(NAV_JWT_ALG_HS512, NAV_JWT_TYP_JWT)

    payload = '{"sub":"user123","role":"admin"}'

    // Create token with custom header
    return NAVJwtCreate(header, payload, 'your-512-bit-secret', token)
}
```

### Complete API Authentication Example

```netlinx
#include 'NAVFoundation.Jwt.axi'
#include 'NAVFoundation.HttpUtils.axi'

define_variable

char gApiSecret[] = 'your-api-secret-key'
char gAuthToken[NAV_JWT_MAX_TOKEN_LENGTH]

define_function char GenerateApiToken(char token[]) {
    stack_var char header[NAV_JWT_MAX_JSON_LENGTH]
    stack_var char payload[1000]
    stack_var slong currentTime
    stack_var slong expirationTime

    // Current time (Get from your time function)
    currentTime = 1516239022
    expirationTime = currentTime + 3600  // Expires in 1 hour

    // Create payload with API claims
    payload = "'{',
               '"iss":"AMX Control System",',
               '"sub":"api_access",',
               '"iat":', itoa(currentTime), ',',
               '"exp":', itoa(expirationTime), ',',
               '"scope":"device.control"',
               '}'"

    // Use HS256 for API tokens
    header = NAVJwtCreateHeader(NAV_JWT_ALG_HS256, NAV_JWT_TYP_JWT)

    return NAVJwtCreate(header, payload, gApiSecret, token)
}

define_function MakeAuthenticatedApiRequest(char endpoint[]) {
    stack_var char authHeader[NAV_JWT_MAX_TOKEN_LENGTH + 20]

    // Generate token if needed
    if (!length_array(gAuthToken)) {
        if (!GenerateApiToken(gAuthToken)) {
            send_string 0, "'Failed to generate token'"
            return
        }
    }

    // Verify token is still valid
    if (!NAVJwtVerify(gAuthToken, gApiSecret)) {
        send_string 0, "'Token expired, generating new token'"
        if (!GenerateApiToken(gAuthToken)) {
            send_string 0, "'Failed to generate token'"
            return
        }
    }

    // Create Authorization header
    authHeader = "'Bearer ', gAuthToken"

    // Make HTTP request with JWT token
    // NAVHttpGet(endpoint, authHeader, ...)
    send_string 0, "'Making API request with token'"
}

define_function integer VerifyIncomingToken(char token[]) {
    stack_var _NAVJwtToken jwtToken
    stack_var slong currentTime

    // Verify signature
    if (!NAVJwtVerifyAndDecode(token, gApiSecret, jwtToken)) {
        send_string 0, "'Token verification failed: ', NAVJwtGetErrorMessage(jwtToken.errorCode)"
        return false
    }

    // Validate time claims
    currentTime = 1516239022  // Get current time
    if (!NAVJwtValidateTime(jwtToken.payloadJson, currentTime, 30)) {
        send_string 0, "'Token time validation failed'"
        return false
    }

    send_string 0, "'Token is valid and not expired'"
    return true
}
```

### Time Validation Example

```netlinx
#include 'NAVFoundation.Jwt.axi'

define_function integer ValidateTokenTiming(char token[], char secret[]) {
    stack_var _NAVJwtToken jwtToken
    stack_var slong currentTime
    stack_var integer clockSkew

    // Decode the token
    if (!NAVJwtVerifyAndDecode(token, secret, jwtToken)) {
        return false
    }

    // Get current Unix timestamp
    currentTime = 1516239022  // Replace with actual time function

    // Allow 30 seconds of clock skew
    clockSkew = 30

    // Validate exp and nbf claims
    if (!NAVJwtValidateTime(jwtToken.payloadJson, currentTime, clockSkew)) {
        send_string 0, "'Token time validation failed'"
        return false
    }

    send_string 0, "'Token timing is valid'"
    return true
}
```

## Constants Reference

### Algorithm Constants

| Constant            | Value     | Description                               |
| ------------------- | --------- | ----------------------------------------- |
| `NAV_JWT_ALG_HS256` | `"HS256"` | HMAC using SHA-256 (recommended)          |
| `NAV_JWT_ALG_HS384` | `"HS384"` | HMAC using SHA-384 (not yet implemented)  |
| `NAV_JWT_ALG_HS512` | `"HS512"` | HMAC using SHA-512 (strongest)            |
| `NAV_JWT_ALG_NONE`  | `"none"`  | No signature (unsafe - use with caution!) |

### Error Codes

| Constant                          | Value | Description                           |
| --------------------------------- | ----- | ------------------------------------- |
| `NAV_JWT_SUCCESS`                 | `0`   | Operation successful                  |
| `NAV_JWT_ERROR_INVALID_FORMAT`    | `-1`  | Token structure invalid (not 3 parts) |
| `NAV_JWT_ERROR_INVALID_HEADER`    | `-2`  | Header JSON is invalid                |
| `NAV_JWT_ERROR_INVALID_PAYLOAD`   | `-3`  | Payload JSON is invalid               |
| `NAV_JWT_ERROR_INVALID_SIGNATURE` | `-4`  | Signature verification failed         |
| `NAV_JWT_ERROR_UNSUPPORTED_ALG`   | `-5`  | Algorithm not supported               |
| `NAV_JWT_ERROR_MISSING_ALG`       | `-6`  | Algorithm not specified in header     |
| `NAV_JWT_ERROR_EMPTY_TOKEN`       | `-7`  | Token string is empty                 |
| `NAV_JWT_ERROR_EMPTY_SECRET`      | `-8`  | Secret key is empty                   |
| `NAV_JWT_ERROR_DECODE_FAILED`     | `-9`  | Base64Url decode failed               |
| `NAV_JWT_ERROR_EXPIRED`           | `-10` | Token has expired (exp claim)         |
| `NAV_JWT_ERROR_NOT_YET_VALID`     | `-11` | Token not yet valid (nbf claim)       |
| `NAV_JWT_ERROR_INVALID_TIME`      | `-12` | Time validation failed                |

**Note:** Functions return simple boolean (`char`) values for success/failure. Detailed error codes are stored in the `errorCode` field of the `_NAVJwtToken` structure and can be retrieved using `NAVJwtGetErrorMessage()` for human-readable error messages.

### Standard Claims

| Constant            | Value   | Description     |
| ------------------- | ------- | --------------- |
| `NAV_JWT_CLAIM_ISS` | `"iss"` | Issuer          |
| `NAV_JWT_CLAIM_SUB` | `"sub"` | Subject         |
| `NAV_JWT_CLAIM_AUD` | `"aud"` | Audience        |
| `NAV_JWT_CLAIM_EXP` | `"exp"` | Expiration Time |
| `NAV_JWT_CLAIM_NBF` | `"nbf"` | Not Before      |
| `NAV_JWT_CLAIM_IAT` | `"iat"` | Issued At       |
| `NAV_JWT_CLAIM_JTI` | `"jti"` | JWT ID          |

## Security Considerations

### Secret Key Management

- **Never hardcode secrets** in production code
- Use **strong, random secrets** (at least 256 bits for HS256)
- **Rotate keys regularly** for enhanced security
- **Store secrets securely**, not in version control

### Algorithm Selection

- **Prefer HS256** for most applications (good balance of security and performance)
- Use **HS512** when maximum security is required
- **Never use "none"** algorithm in production
- Ensure algorithm in header matches expected algorithm (prevent algorithm confusion attacks)

### Token Expiration

- **Always set expiration** (`exp` claim) for tokens
- Use **short expiration times** for sensitive operations (minutes to hours)
- Implement **token refresh** mechanism for long-lived sessions
- Consider **clock skew** (typically 30-60 seconds) during validation

### Signature Verification

- **Always verify signatures** before trusting token content
- Verify **before** extracting or using claims
- Handle **verification failures** appropriately (log, reject, alert)
- Validate **time claims** (exp, nbf) in addition to signature

### Token Storage and Transmission

- Transmit tokens over **HTTPS only**
- Store tokens **securely** on client side (avoid localStorage for sensitive apps)
- Include tokens in **Authorization header**: `Authorization: Bearer <token>`
- Consider token size - large payloads increase bandwidth

### Common Vulnerabilities to Avoid

1. **None Algorithm Attack** - Reject tokens with `"alg":"none"`
2. **Algorithm Confusion** - Verify algorithm matches expectations
3. **Token Replay** - Use `jti` (JWT ID) claim and maintain a blacklist
4. **Insufficient Secret Length** - Use secrets at least as long as hash output
5. **Missing Expiration** - Always include `exp` claim

## Implementation Notes

- JWT components are **Base64Url encoded** (not standard Base64) per RFC 7515
- Padding is **omitted** from Base64Url encoding per RFC 7519
- Header and payload are **JSON objects**
- Signature is computed over: `base64url(header) + "." + base64url(payload)`
- Current implementation supports **HMAC algorithms only** (symmetric signing)
- Whitespace in JSON header/payload is preserved
- Claims are case-sensitive

## Limitations

- **RSA and ECDSA algorithms** (RS256, ES256, etc.) are not currently supported
- **JSON Web Encryption (JWE)** is not implemented
- No built-in **token blacklisting** or revocation
- Time functions must be provided by application (Unix timestamps)
- Maximum token size limited by configurable constants (default: `NAV_JWT_MAX_TOKEN_LENGTH` = 4096 bytes)

## Related Libraries

- **NAVFoundation.Encoding.Base64Url** - URL-safe Base64 encoding (required)
- **NAVFoundation.Cryptography.Hmac** - HMAC signatures (required)
- **NAVFoundation.Json** - JSON parsing for advanced claim extraction
- **NAVFoundation.HttpUtils** - HTTP client for API requests with JWT

## References

- [RFC 7519 - JSON Web Token (JWT)](https://tools.ietf.org/html/rfc7519)
- [RFC 7515 - JSON Web Signature (JWS)](https://tools.ietf.org/html/rfc7515)
- [RFC 7518 - JSON Web Algorithms (JWA)](https://tools.ietf.org/html/rfc7518)
- [RFC 4648 - Base64url Encoding](https://tools.ietf.org/html/rfc4648#section-5)
- [JWT.io](https://jwt.io/) - Online JWT debugger and documentation

## Testing

Test files for the JWT implementation can be found in the `__tests__` directory. The test suite covers:

- Token creation with various algorithms
- Signature verification (valid and invalid)
- Token decoding and component extraction
- Time-based validation
- Error handling for malformed tokens
- Round-trip encoding/decoding
- Edge cases and boundary conditions

Run tests using the NAVFoundation test framework.
