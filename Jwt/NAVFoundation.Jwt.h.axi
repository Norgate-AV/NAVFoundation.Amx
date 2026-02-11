PROGRAM_NAME='NAVFoundation.Jwt.h'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_JWT_H__
#DEFINE __NAV_FOUNDATION_JWT_H__ 'NAVFoundation.Jwt.h'


DEFINE_CONSTANT

// =============================================================================
// Configuration Constants
// =============================================================================

/**
 * Maximum length for a complete JWT token string.
 * A JWT consists of: base64url(header).base64url(payload).base64url(signature)
 * Typical tokens range from 200-2000 bytes, but can be larger with extensive claims.
 * @default 4096
 */
#IF_NOT_DEFINED NAV_JWT_MAX_TOKEN_LENGTH
constant integer NAV_JWT_MAX_TOKEN_LENGTH          = 4096
#END_IF

/**
 * Maximum length for JWT components (encoded header, payload, or signature).
 * Base64url encoding increases size by ~33% from original JSON.
 * @default 2048
 */
#IF_NOT_DEFINED NAV_JWT_MAX_COMPONENT_LENGTH
constant integer NAV_JWT_MAX_COMPONENT_LENGTH   = 2048
#END_IF

/**
 * Maximum length for decoded JWT JSON strings (header and payload).
 * Should accommodate typical claims plus custom application data.
 * @default 2048
 */
#IF_NOT_DEFINED NAV_JWT_MAX_JSON_LENGTH
constant integer NAV_JWT_MAX_JSON_LENGTH        = 2048
#END_IF


// =============================================================================
// JWT Algorithms
// =============================================================================
// Supported signing algorithms for JWT tokens.
// See RFC 7518 Section 3.1 for algorithm specifications.

// HMAC algorithms (symmetric signing)
constant char NAV_JWT_ALG_HS256[]   = 'HS256'  // HMAC using SHA-256
constant char NAV_JWT_ALG_HS384[]   = 'HS384'  // HMAC using SHA-384
constant char NAV_JWT_ALG_HS512[]   = 'HS512'  // HMAC using SHA-512

// None algorithm (unsigned - use with extreme caution!)
constant char NAV_JWT_ALG_NONE[]    = 'none'   // No digital signature or MAC

/**
 * Algorithm type codes
 */
constant sinteger NAV_JWT_ALG_TYPE_HS256     = 1
constant sinteger NAV_JWT_ALG_TYPE_HS384     = 2
constant sinteger NAV_JWT_ALG_TYPE_HS512     = 3
constant sinteger NAV_JWT_ALG_TYPE_NONE      = 0
constant sinteger NAV_JWT_ALG_TYPE_UNKNOWN   = -1


// =============================================================================
// JWT Token Types
// =============================================================================

/**
 * Standard token type identifier.
 */
constant char NAV_JWT_TYP_JWT[]     = 'JWT'    // Default JWT type


// =============================================================================
// JWT Error Codes
// =============================================================================
// Error codes stored in _NAVJwtToken.errorCode field for detailed diagnostics.
// Functions return simple true/false, but these codes provide specific error information.

constant sinteger NAV_JWT_SUCCESS                    = 0
constant sinteger NAV_JWT_ERROR_INVALID_FORMAT       = -1    // Token structure invalid
constant sinteger NAV_JWT_ERROR_INVALID_HEADER       = -2    // Header JSON invalid
constant sinteger NAV_JWT_ERROR_INVALID_PAYLOAD      = -3    // Payload JSON invalid
constant sinteger NAV_JWT_ERROR_INVALID_SIGNATURE    = -4    // Signature verification failed
constant sinteger NAV_JWT_ERROR_UNSUPPORTED_ALG      = -5    // Algorithm not supported
constant sinteger NAV_JWT_ERROR_MISSING_ALG          = -6    // Algorithm not specified in header
constant sinteger NAV_JWT_ERROR_EMPTY_TOKEN          = -7    // Token string is empty
constant sinteger NAV_JWT_ERROR_EMPTY_SECRET         = -8    // Secret key is empty
constant sinteger NAV_JWT_ERROR_DECODE_FAILED        = -9    // Base64Url decode failed
constant sinteger NAV_JWT_ERROR_EXPIRED              = -10   // Token has expired (exp claim)
constant sinteger NAV_JWT_ERROR_NOT_YET_VALID        = -11   // Token not yet valid (nbf claim)
constant sinteger NAV_JWT_ERROR_INVALID_TIME         = -12   // Time validation failed


// =============================================================================
// JWT Claim Names
// =============================================================================
// Standard registered claim names defined in RFC 7519 Section 4.1

constant char NAV_JWT_CLAIM_ISS[]   = 'iss'    // Issuer
constant char NAV_JWT_CLAIM_SUB[]   = 'sub'    // Subject
constant char NAV_JWT_CLAIM_AUD[]   = 'aud'    // Audience
constant char NAV_JWT_CLAIM_EXP[]   = 'exp'    // Expiration Time
constant char NAV_JWT_CLAIM_NBF[]   = 'nbf'    // Not Before
constant char NAV_JWT_CLAIM_IAT[]   = 'iat'    // Issued At
constant char NAV_JWT_CLAIM_JTI[]   = 'jti'    // JWT ID


// =============================================================================
// JWT Header Field Names
// =============================================================================
// Standard header fields defined in RFC 7515

constant char NAV_JWT_HEADER_ALG[]  = 'alg'    // Algorithm
constant char NAV_JWT_HEADER_TYP[]  = 'typ'    // Type


// =============================================================================
// JWT Component Separators
// =============================================================================

constant char NAV_JWT_SEPARATOR     = '.'      // Separator between JWT components


// =============================================================================
// JWT Validation Options
// =============================================================================
// Bitwise flags for validation options

constant integer NAV_JWT_VALIDATE_SIGNATURE     = $01  // Verify signature
constant integer NAV_JWT_VALIDATE_EXPIRATION    = $02  // Check exp claim
constant integer NAV_JWT_VALIDATE_NOT_BEFORE    = $04  // Check nbf claim
constant integer NAV_JWT_VALIDATE_ISSUED_AT     = $08  // Check iat claim
constant integer NAV_JWT_VALIDATE_ALL           = $FF  // All validations


DEFINE_TYPE

/**
 * @struct _NAVJwtHeader
 * @public
 * @description Represents a JWT header component.
 *
 * @property {char[]} alg - Algorithm name (e.g., "HS256")
 * @property {char[]} typ - Token type (usually "JWT")
 * @property {sinteger} algType - Algorithm type code
 */
struct _NAVJwtHeader {
    char alg[32]
    char typ[32]
    sinteger algType
}

/**
 * @struct _NAVJwtToken
 * @public
 * @description Represents a complete JWT token with all components.
 *
 * @property {char[]} token - Complete JWT token string
 * @property {char[]} header - Base64Url encoded header
 * @property {char[]} payload - Base64Url encoded payload
 * @property {char[]} signature - Base64Url encoded signature
 * @property {char[]} headerJson - Decoded header JSON
 * @property {char[]} payloadJson - Decoded payload JSON
 * @property {_NAVJwtHeader} headerParsed - Parsed header information
 * @property {sinteger} isValid - Validation result
 * @property {sinteger} errorCode - Error code if validation failed
 */
struct _NAVJwtToken {
    char token[NAV_JWT_MAX_TOKEN_LENGTH]
    char header[NAV_JWT_MAX_COMPONENT_LENGTH]
    char payload[NAV_JWT_MAX_COMPONENT_LENGTH]
    char signature[NAV_JWT_MAX_COMPONENT_LENGTH]
    char headerJson[NAV_JWT_MAX_JSON_LENGTH]
    char payloadJson[NAV_JWT_MAX_JSON_LENGTH]
    _NAVJwtHeader headerParsed
    char isValid
    sinteger errorCode
}

/**
 * @struct _NAVJwtOptions
 * @public
 * @description Options for JWT creation and validation.
 *
 * @property {integer} validateFlags - Validation flags (bitwise)
 * @property {slong} issuedAt - Issued at time (Unix timestamp)
 * @property {slong} expiresAt - Expiration time (Unix timestamp)
 * @property {slong} notBefore - Not before time (Unix timestamp)
 * @property {integer} clockSkewSeconds - Allowed clock skew in seconds
 */
struct _NAVJwtOptions {
    integer validateFlags
    slong issuedAt
    slong expiresAt
    slong notBefore
    integer clockSkewSeconds
}

#END_IF // __NAV_FOUNDATION_JWT_H__
