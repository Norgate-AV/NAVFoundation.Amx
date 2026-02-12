PROGRAM_NAME='NAVFoundation.Jwt'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_JWT__
#DEFINE __NAV_FOUNDATION_JWT__ 'NAVFoundation.Jwt'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Encoding.Base64Url.axi'
#include 'NAVFoundation.Cryptography.Hmac.axi'
#include 'NAVFoundation.Cryptography.Hmac.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.Jwt.h.axi'


// =============================================================================
// PRIVATE HELPER FUNCTIONS
// =============================================================================

/**
 * @function NAVJwtGetAlgorithmType
 * @private
 * @description Converts an algorithm string to an algorithm type code.
 *
 * @param {char[]} algorithm - Algorithm name (e.g., "HS256")
 *
 * @returns {sinteger} Algorithm type code or NAV_JWT_ALG_TYPE_UNKNOWN
 */
define_function sinteger NAVJwtGetAlgorithmType(char algorithm[]) {
    switch (algorithm) {
        case NAV_JWT_ALG_HS256: return NAV_JWT_ALG_TYPE_HS256
        case NAV_JWT_ALG_HS384: return NAV_JWT_ALG_TYPE_HS384
        case NAV_JWT_ALG_HS512: return NAV_JWT_ALG_TYPE_HS512
        case NAV_JWT_ALG_NONE:  return NAV_JWT_ALG_TYPE_NONE
        default:                return NAV_JWT_ALG_TYPE_UNKNOWN
    }
}


// =============================================================================
// PUBLIC API FUNCTIONS
// =============================================================================

/**
 * @function NAVJwtCreateHeader
 * @public
 * @description Creates a standard JWT header JSON string.
 *
 * @param {char[]} algorithm - Signing algorithm (e.g., "HS256")
 * @param {char[]} tokenType - Token type (default: "JWT")
 *
 * @returns {char[]} JSON string representing the JWT header
 *
 * @example
 * header = NAVJwtCreateHeader(NAV_JWT_ALG_HS256, NAV_JWT_TYP_JWT)
 * // Returns: {"alg":"HS256","typ":"JWT"}
 */
define_function char[NAV_JWT_MAX_JSON_LENGTH] NAVJwtCreateHeader(char algorithm[], char tokenType[]) {
    stack_var char alg[64]
    stack_var char typ[64]

    alg = algorithm
    typ = tokenType

    // Default values
    if (!length_array(alg)) {
        alg = NAV_JWT_ALG_HS256
    }

    if (!length_array(typ)) {
        typ = NAV_JWT_TYP_JWT
    }

    // Build JSON header
    return "'{"alg":"', alg, '","typ":"', typ, '"}'"
}

/**
 * @function NAVJwtSplitToken
 * @public
 * @description Splits a JWT token into its three components: header, payload, signature.
 *
 * @param {_NAVJwtToken} jwtToken - JWT token structure (token field must be populated)
 *
 * @returns {char} true if successful, false otherwise (errorCode field set in struct)
 */
define_function char NAVJwtSplitToken(_NAVJwtToken jwtToken) {
    stack_var char parts[3][NAV_JWT_MAX_COMPONENT_LENGTH]
    stack_var integer count

    // Clear outputs
    jwtToken.header = ''
    jwtToken.payload = ''
    jwtToken.signature = ''

    // Check for empty token
    if (!length_array(jwtToken.token)) {
        jwtToken.errorCode = NAV_JWT_ERROR_EMPTY_TOKEN
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtSplitToken',
                                    'Token is empty')
        return false
    }

    // Split token by '.' separator
    count = NAVSplitString(jwtToken.token, '.', parts)

    // JWT must have exactly 3 parts (header.payload.signature)
    if (count != 3) {
        jwtToken.errorCode = NAV_JWT_ERROR_INVALID_FORMAT
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtSplitToken',
                                    "'Invalid token format: expected 3 parts, got ', itoa(count)")
        return false
    }

    // Assign parts to struct fields
    jwtToken.header = parts[1]
    jwtToken.payload = parts[2]
    jwtToken.signature = parts[3]

    jwtToken.errorCode = NAV_JWT_SUCCESS
    return true
}

/**
 * @function NAVJwtGetHeader
 * @public
 * @description Extracts and decodes the header from a JWT token.
 *
 * @param {char[]} token - Complete JWT token string
 * @param {char[]} header - Output: Decoded header JSON string
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * char header[NAV_JWT_MAX_JSON_LENGTH]
 * if (NAVJwtGetHeader(token, header)) {
 *     // header contains decoded JSON
 * }
 */
define_function char NAVJwtGetHeader(char token[], char header[]) {
    stack_var _NAVJwtToken jwtToken

    // Clear output
    header = ''

    jwtToken.token = token

    if (!NAVJwtSplitToken(jwtToken)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtGetHeader',
                                    'Failed to split token')
        return false
    }

    header = NAVBase64UrlDecode(jwtToken.header)
    if (!length_array(header)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtGetHeader',
                                    'Failed to decode header')
        return false
    }

    return true
}

/**
 * @function NAVJwtGetPayload
 * @public
 * @description Extracts and decodes the payload from a JWT token.
 *
 * @param {char[]} token - Complete JWT token string
 * @param {char[]} payload - Output: Decoded payload JSON string
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * char payload[NAV_JWT_MAX_JSON_LENGTH]
 * if (NAVJwtGetPayload(token, payload)) {
 *     // payload contains decoded JSON
 * }
 */
define_function char NAVJwtGetPayload(char token[], char payload[]) {
    stack_var _NAVJwtToken jwtToken

    // Clear output
    payload = ''

    jwtToken.token = token

    if (!NAVJwtSplitToken(jwtToken)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtGetPayload',
                                    'Failed to split token')
        return false
    }

    payload = NAVBase64UrlDecode(jwtToken.payload)
    if (!length_array(payload)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtGetPayload',
                                    'Failed to decode payload')
        return false
    }

    return true
}

/**
 * @function NAVJwtGetSignature
 * @public
 * @description Extracts the signature component from a JWT token (still Base64Url encoded).
 *
 * @param {char[]} token - Complete JWT token string
 * @param {char[]} signature - Output: Base64Url encoded signature
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * char signature[NAV_JWT_MAX_COMPONENT_LENGTH]
 * if (NAVJwtGetSignature(token, signature)) {
 *     // signature contains Base64Url encoded value
 * }
 */
define_function char NAVJwtGetSignature(char token[], char signature[]) {
    stack_var _NAVJwtToken jwtToken

    // Clear output
    signature = ''

    jwtToken.token = token

    if (!NAVJwtSplitToken(jwtToken)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtGetSignature',
                                    'Failed to split token')
        return false
    }

    signature = jwtToken.signature
    return true
}

/**
 * @function NAVJwtExtractAlgorithm
 * @private
 * @description Extracts the algorithm from a JWT header JSON string.
 *
 * @param {char[]} headerJson - Header JSON string
 *
 * @returns {char[]} Algorithm name or empty string if not found
 */
define_function char[64] NAVJwtExtractAlgorithm(char headerJson[]) {
    stack_var integer algPos
    stack_var integer colonPos
    stack_var integer quoteStart
    stack_var integer quoteEnd
    stack_var char temp[NAV_JWT_MAX_JSON_LENGTH]
    stack_var char result[64]

    // Find "alg" field (try with quotes first)
    algPos = NAVIndexOf(headerJson, '"alg"', 1)
    if (!algPos) {
        // Try without quotes
        algPos = NAVIndexOf(headerJson, 'alg', 1)
        if (!algPos) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_JWT__,
                                        'NAVJwtExtractAlgorithm',
                                        '"alg" field not found in header')
            return ''
        }
    }

    // Get substring after "alg"
    temp = NAVStringSubstring(headerJson, algPos + 3, 0)

    // Find the colon
    colonPos = NAVIndexOf(temp, ':', 1)
    if (!colonPos) {
        return ''
    }

    // Get substring after colon
    temp = NAVStringSubstring(temp, colonPos + 1, 0)
    temp = NAVTrimString(temp)

    // Find opening quote
    quoteStart = NAVIndexOf(temp, '"', 1)
    if (!quoteStart) {
        return ''
    }

    // Get substring after opening quote
    temp = NAVStringSubstring(temp, quoteStart + 1, 0)

    // Find closing quote
    quoteEnd = NAVIndexOf(temp, '"', 1)
    if (!quoteEnd) {
        return ''
    }

    // Extract algorithm value
    result = NAVStringSubstring(temp, 1, quoteEnd - 1)

    return result
}

/**
 * @function NAVJwtSignData
 * @private
 * @description Signs data using the specified algorithm.
 *
 * @param {char[]} data - Data to sign
 * @param {char[]} secret - Secret key
 * @param {char[]} algorithm - Algorithm to use (HS256, HS384, HS512)
 *
 * @returns {char[]} Signature bytes
 */
define_function char[HMAC_SHA512_HASH_SIZE] NAVJwtSignData(char data[], char secret[], char algorithm[]) {
    stack_var sinteger algType

    algType = NAVJwtGetAlgorithmType(algorithm)

    switch (algType) {
        case NAV_JWT_ALG_TYPE_HS256: {
            return NAVHmacSha256(secret, data)
        }
        case NAV_JWT_ALG_TYPE_HS384: {
            return NAVHmacSha384(secret, data)
        }
        case NAV_JWT_ALG_TYPE_HS512: {
            return NAVHmacSha512(secret, data)
        }
        case NAV_JWT_ALG_TYPE_NONE: {
            return ''
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_JWT__,
                                        'NAVJwtSignData',
                                        "'Unsupported algorithm type: ', itoa(algType)")
            return ''
        }
    }
}

/**
 * @function NAVJwtCreate
 * @public
 * @description Creates a complete JWT token from header and payload JSON strings.
 *
 * @param {char[]} headerJson - Header JSON string (or empty for default)
 * @param {char[]} payloadJson - Payload JSON string
 * @param {char[]} secret - Secret key for signing
 * @param {char[]} token - Output: Complete JWT token string (header.payload.signature)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * char token[NAV_JWT_MAX_TOKEN_LENGTH]
 * if (NAVJwtCreate('', '{"sub":"1234567890"}', 'mySecret', token)) {
 *     // Token created successfully
 * }
 */
define_function char NAVJwtCreate(char headerJson[], char payloadJson[], char secret[], char token[]) {
    stack_var char header[NAV_JWT_MAX_JSON_LENGTH]
    stack_var char payload[NAV_JWT_MAX_JSON_LENGTH]
    stack_var char encodedHeader[NAV_JWT_MAX_COMPONENT_LENGTH]
    stack_var char encodedPayload[NAV_JWT_MAX_COMPONENT_LENGTH]
    stack_var char signingInput[NAV_JWT_MAX_TOKEN_LENGTH]
    stack_var char signature[HMAC_SHA512_HASH_SIZE]
    stack_var char encodedSignature[NAV_JWT_MAX_COMPONENT_LENGTH]
    stack_var char algorithm[64]

    // Clear output
    token = ''

    // Use default header if not provided
    if (!length_array(headerJson)) {
        header = NAVJwtCreateHeader(NAV_JWT_ALG_HS256, NAV_JWT_TYP_JWT)
    } else {
        header = headerJson
    }

    payload = payloadJson

    // Check for empty payload
    if (!length_array(payload)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtCreate',
                                    'Payload is empty')
        return false
    }

    // Check for empty secret
    if (!length_array(secret)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtCreate',
                                    'Secret key is empty')
        return false
    }

    // Extract algorithm from header
    algorithm = NAVJwtExtractAlgorithm(header)
    if (!length_array(algorithm)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtCreate',
                                    'Failed to extract algorithm from header')
        return false
    }

    // Encode header and payload (Base64Url without padding)
    encodedHeader = NAVBase64UrlEncode(header)
    encodedPayload = NAVBase64UrlEncode(payload)

    // Create signing input (header.payload)
    signingInput = "encodedHeader, '.', encodedPayload"

    // Sign the data
    signature = NAVJwtSignData(signingInput, secret, algorithm)

    // Validate signature was generated
    if (!length_array(signature)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtCreate',
                                    'Failed to generate signature')
        return false
    }

    // Encode signature (Base64Url without padding)
    encodedSignature = NAVBase64UrlEncode(signature)

    // Build complete token (header.payload.signature)
    token = "signingInput, '.', encodedSignature"

    return true
}

/**
 * @function NAVJwtSign
 * @public
 * @description Signs existing header and payload with a secret key.
 *              This is useful when you already have Base64Url encoded header and payload.
 *
 * @param {char[]} encodedHeader - Base64Url encoded header
 * @param {char[]} encodedPayload - Base64Url encoded payload
 * @param {char[]} secret - Secret key for signing
 * @param {char[]} algorithm - Algorithm to use (HS256, HS384, HS512)
 * @param {char[]} token - Output: Complete JWT token string
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * char token[NAV_JWT_MAX_TOKEN_LENGTH]
 * if (NAVJwtSign(encodedHeader, encodedPayload, 'mySecret', NAV_JWT_ALG_HS256, token)) {
 *     // Token signed successfully
 * }
 */
define_function char NAVJwtSign(char encodedHeader[], char encodedPayload[],
                                char secret[], char algorithm[], char token[]) {
    stack_var char signingInput[NAV_JWT_MAX_TOKEN_LENGTH]
    stack_var char signature[HMAC_SHA512_HASH_SIZE]
    stack_var char encodedSignature[NAV_JWT_MAX_COMPONENT_LENGTH]

    // Clear output
    token = ''

    // Validate inputs
    if (!length_array(encodedHeader) || !length_array(encodedPayload) ||
        !length_array(secret) || !length_array(algorithm)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtSign',
                                    'One or more required parameters are empty')
        return false
    }

    // Create signing input
    signingInput = "encodedHeader, '.', encodedPayload"

    // Sign the data
    signature = NAVJwtSignData(signingInput, secret, algorithm)

    // Check if signing failed
    if (!length_array(signature)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtSign',
                                    'Signing operation failed')
        return false
    }

    // Encode signature
    encodedSignature = NAVBase64UrlEncode(signature)

    // Build complete token
    token = "signingInput, '.', encodedSignature"

    return true
}

/**
 * @function NAVJwtVerify
 * @public
 * @description Verifies the signature of a JWT token.
 *
 * @param {char[]} token - Complete JWT token string
 * @param {char[]} secret - Secret key used for signing
 *
 * @returns {char} true if valid, false otherwise
 *
 * @example
 * if (NAVJwtVerify(token, 'mySecret')) {
 *     // Token is valid
 * }
 */
define_function char NAVJwtVerify(char token[], char secret[]) {
    stack_var _NAVJwtToken jwtToken
    stack_var char headerJson[NAV_JWT_MAX_JSON_LENGTH]
    stack_var char algorithm[64]
    stack_var char signingInput[NAV_JWT_MAX_TOKEN_LENGTH]
    stack_var char computedSignature[HMAC_SHA512_HASH_SIZE]
    stack_var char encodedComputedSignature[NAV_JWT_MAX_COMPONENT_LENGTH]

    // Check for empty token
    if (!length_array(token)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtVerify',
                                    'Token is empty')
        return false
    }

    // Check for empty secret
    if (!length_array(secret)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtVerify',
                                    'Secret key is empty')
        return false
    }

    // Split token
    jwtToken.token = token
    if (!NAVJwtSplitToken(jwtToken)) {
        // Error already logged by NAVJwtSplitToken
        return false
    }

    // Decode header
    headerJson = NAVBase64UrlDecode(jwtToken.header)
    if (!length_array(headerJson)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtVerify',
                                    'Failed to decode header')
        return false
    }

    // Extract algorithm
    algorithm = NAVJwtExtractAlgorithm(headerJson)
    if (!length_array(algorithm)) {
        // Error already logged by NAVJwtExtractAlgorithm
        return false
    }

    // Check if algorithm is supported
    if (NAVJwtGetAlgorithmType(algorithm) == NAV_JWT_ALG_TYPE_UNKNOWN) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtVerify',
                                    "'Unsupported algorithm: ', algorithm")
        return false
    }

    // Create signing input
    signingInput = "jwtToken.header, '.', jwtToken.payload"

    // Compute signature
    computedSignature = NAVJwtSignData(signingInput, secret, algorithm)

    // Validate signature was generated
    if (!length_array(computedSignature)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtVerify',
                                    'Failed to compute signature')
        return false
    }

    // Encode computed signature
    encodedComputedSignature = NAVBase64UrlEncode(computedSignature)

    // Compare signatures
    if (encodedComputedSignature != jwtToken.signature) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtVerify',
                                    'Signature verification failed')
        return false
    }

    return true
}

/**
 * @function NAVJwtDecode
 * @public
 * @description Decodes a JWT token into a _NAVJwtToken structure with all components.
 *
 * @param {char[]} token - Complete JWT token string
 * @param {_NAVJwtToken} jwtToken - Output: _NAVJwtToken structure with decoded components
 *
 * @returns {char} true if successful, false otherwise (errorCode field set in struct)
 *
 * @example
 * _NAVJwtToken jwtToken
 * if (NAVJwtDecode(token, jwtToken)) {
 *     send_string 0, "'Header: ', jwtToken.headerJson"
 *     send_string 0, "'Payload: ', jwtToken.payloadJson"
 * }
 */
define_function char NAVJwtDecode(char token[], _NAVJwtToken jwtToken) {
    stack_var char algorithm[64]

    // Initialize structure
    jwtToken.token = token
    jwtToken.header = ''
    jwtToken.payload = ''
    jwtToken.signature = ''
    jwtToken.headerJson = ''
    jwtToken.payloadJson = ''
    jwtToken.headerParsed.alg = ''
    jwtToken.headerParsed.typ = ''
    jwtToken.headerParsed.algType = NAV_JWT_ALG_TYPE_UNKNOWN
    jwtToken.isValid = false
    jwtToken.errorCode = NAV_JWT_SUCCESS

    // Split token
    if (!NAVJwtSplitToken(jwtToken)) {
        // Error already logged by NAVJwtSplitToken
        return false
    }

    // Decode header
    jwtToken.headerJson = NAVBase64UrlDecode(jwtToken.header)
    if (!length_array(jwtToken.headerJson)) {
        jwtToken.errorCode = NAV_JWT_ERROR_INVALID_HEADER
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtDecode',
                                    'Failed to decode header')
        return false
    }

    // Decode payload
    jwtToken.payloadJson = NAVBase64UrlDecode(jwtToken.payload)
    if (!length_array(jwtToken.payloadJson)) {
        jwtToken.errorCode = NAV_JWT_ERROR_INVALID_PAYLOAD
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JWT__,
                                    'NAVJwtDecode',
                                    'Failed to decode payload')
        return false
    }

    // Parse header
    algorithm = NAVJwtExtractAlgorithm(jwtToken.headerJson)
    if (!length_array(algorithm)) {
        jwtToken.errorCode = NAV_JWT_ERROR_MISSING_ALG
        // Error already logged by NAVJwtExtractAlgorithm
        return false
    }

    jwtToken.headerParsed.alg = algorithm
    jwtToken.headerParsed.typ = NAV_JWT_TYP_JWT  // Default value
    jwtToken.headerParsed.algType = NAVJwtGetAlgorithmType(algorithm)

    jwtToken.isValid = true

    return true
}

/**
 * @function NAVJwtVerifyAndDecode
 * @public
 * @description Verifies and decodes a JWT token in one operation.
 *
 * @param {char[]} token - Complete JWT token string
 * @param {char[]} secret - Secret key used for signing
 * @param {_NAVJwtToken} jwtToken - Output: _NAVJwtToken structure with decoded components
 *
 * @returns {char} true if valid, false otherwise (errorCode field set in struct)
 */
define_function char NAVJwtVerifyAndDecode(char token[], char secret[], _NAVJwtToken jwtToken) {
    // First decode
    if (!NAVJwtDecode(token, jwtToken)) {
        // Error already logged by NAVJwtDecode
        return false
    }

    // Then verify
    if (!NAVJwtVerify(token, secret)) {
        jwtToken.isValid = false
        jwtToken.errorCode = NAV_JWT_ERROR_INVALID_SIGNATURE
        // Error already logged by NAVJwtVerify
        return false
    }

    jwtToken.isValid = true
    jwtToken.errorCode = NAV_JWT_SUCCESS
    return true
}

/**
 * @function NAVJwtExtractNumericClaim
 * @private
 * @description Extracts a numeric claim value from a payload JSON string.
 *
 * @param {char[]} payloadJson - Payload JSON string
 * @param {char[]} claimName - Claim name to extract
 *
 * @returns {slong} Claim value as signed long integer, or -1 if not found
 */
define_function slong NAVJwtExtractNumericClaim(char payloadJson[], char claimName[]) {
    stack_var integer claimPos
    stack_var integer colonPos
    stack_var integer endPos
    stack_var char temp[NAV_JWT_MAX_JSON_LENGTH]
    stack_var char searchPattern[128]
    stack_var char valueStr[32]
    stack_var slong value
    stack_var integer i

    // Build search pattern: "claimName"
    searchPattern = "'"', claimName, '"'"

    // Find claim name with quotes
    claimPos = NAVIndexOf(payloadJson, searchPattern, 1)
    if (!claimPos) {
        // Try without quotes around claim name
        claimPos = NAVIndexOf(payloadJson, claimName, 1)
        if (!claimPos) {
            return -1
        }
    }

    // Get substring after claim name
    temp = NAVStringSubstring(payloadJson, claimPos + length_array(claimName), 0)

    // Find the colon
    colonPos = NAVIndexOf(temp, ':', 1)
    if (!colonPos) {
        return -1
    }

    // Get substring after colon and trim whitespace
    temp = NAVStringSubstring(temp, colonPos + 1, 0)
    temp = NAVTrimString(temp)

    // Remove leading quotes if present
    if (length_array(temp) > 0 && temp[1] == '"') {
        temp = NAVStringSubstring(temp, 2, 0)
    }

    // Find the end of the number (look for comma, brace, quote, or space)
    endPos = 0
    for (i = 1; i <= length_array(temp); i++) {
        if (temp[i] == ',' || temp[i] == '}' || temp[i] == '"' || temp[i] == ' ') {
            endPos = i
            break
        }
    }

    // If no delimiter found, use entire remaining string
    if (!endPos) {
        valueStr = temp
    } else {
        valueStr = NAVStringSubstring(temp, 1, endPos - 1)
    }

    // Convert to long
    if (length_array(valueStr) > 0) {
        value = atol(valueStr)
        return value
    }

    return -1
}

/**
 * @function NAVJwtValidateTime
 * @public
 * @description Validates time-based claims (exp, nbf, iat) in a JWT token.
 *
 * @param {char[]} payloadJson - Decoded payload JSON string
 * @param {slong} currentTime - Current Unix timestamp
 * @param {integer} clockSkew - Allowed clock skew in seconds (default: 0)
 *
 * @returns {char} true if valid, false if expired or not yet valid
 */
define_function char NAVJwtValidateTime(char payloadJson[], slong currentTime, integer clockSkew) {
    stack_var slong exp, nbf

    // Check expiration (exp)
    exp = NAVJwtExtractNumericClaim(payloadJson, NAV_JWT_CLAIM_EXP)
    if (exp != -1) {
        if (currentTime > (exp + clockSkew)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_JWT__,
                                        'NAVJwtValidateTime',
                                        "'Token expired: current=', itoa(currentTime), ', exp=', itoa(exp)")
            return false
        }
    }

    // Check not before (nbf)
    nbf = NAVJwtExtractNumericClaim(payloadJson, NAV_JWT_CLAIM_NBF)
    if (nbf != -1) {
        if (currentTime < (nbf - clockSkew)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_JWT__,
                                        'NAVJwtValidateTime',
                                        "'Token not yet valid: current=', itoa(currentTime), ', nbf=', itoa(nbf)")
            return false
        }
    }

    return true
}

/**
 * @function NAVJwtGetErrorMessage
 * @public
 * @description Returns a human-readable error message for a JWT error code.
 *
 * @param {sinteger} errorCode - JWT error code
 *
 * @returns {char[]} Error message string
 */
define_function char[128] NAVJwtGetErrorMessage(sinteger errorCode) {
    switch (errorCode) {
        case NAV_JWT_SUCCESS:
            return 'Success'
        case NAV_JWT_ERROR_INVALID_FORMAT:
            return 'Invalid token format'
        case NAV_JWT_ERROR_INVALID_HEADER:
            return 'Invalid header JSON'
        case NAV_JWT_ERROR_INVALID_PAYLOAD:
            return 'Invalid payload JSON'
        case NAV_JWT_ERROR_INVALID_SIGNATURE:
            return 'Signature verification failed'
        case NAV_JWT_ERROR_UNSUPPORTED_ALG:
            return 'Unsupported algorithm'
        case NAV_JWT_ERROR_MISSING_ALG:
            return 'Algorithm not specified'
        case NAV_JWT_ERROR_EMPTY_TOKEN:
            return 'Token is empty'
        case NAV_JWT_ERROR_EMPTY_SECRET:
            return 'Secret key is empty'
        case NAV_JWT_ERROR_DECODE_FAILED:
            return 'Base64Url decode failed'
        case NAV_JWT_ERROR_EXPIRED:
            return 'Token has expired'
        case NAV_JWT_ERROR_NOT_YET_VALID:
            return 'Token not yet valid'
        case NAV_JWT_ERROR_INVALID_TIME:
            return 'Time validation failed'
        default:
            return 'Unknown error'
    }
}

#END_IF // __NAV_FOUNDATION_JWT__
