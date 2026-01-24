PROGRAM_NAME='NAVFoundation.HttpUtils'

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

/**
 * @file NAVFoundation.HttpUtils.axi
 * @brief Implementation of HTTP protocol utilities.
 *
 * This module provides functions for creating, modifying, and processing HTTP requests
 * and responses. It handles request initialization, header management, content type
 * inference, and message building according to HTTP/1.1 specification.
 *
 * The library facilitates building HTTP clients and basic servers, with support for
 * standard HTTP methods, status codes, headers, and content types.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_HTTPUTILS__
#DEFINE __NAV_FOUNDATION_HTTPUTILS__ 'NAVFoundation.Http.Utils'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.HttpUtils.h.axi'
#include 'NAVFoundation.ArrayUtils.axi'
#include 'NAVFoundation.Url.axi'
#include 'NAVFoundation.StringUtils.axi'


/**
 * @function NAVHttpRequestInit
 * @public
 * @description Initializes an HTTP request structure with essential values.
 *
 * This function sets up a request with the specified method, URL details, and body.
 * It automatically adds required headers such as Host and, if a body is present,
 * Content-Length and Content-Type.
 *
 * @param {_NAVHttpRequest} req - The request structure to initialize
 * @param {char[]} method - HTTP method (GET, POST, etc.)
 * @param {_NAVUrl} url - URL structure containing host, path, and other components
 * @param {char[]} body - Request body (can be empty)
 *
 * @returns {char} TRUE if initialization succeeded, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpRequest request
 * stack_var _NAVUrl url
 * stack_var char success
 *
 * // Assume url is already populated
 * success = NAVHttpRequestInit(request, 'GET', url, '')
 *
 * @see NAVHttpParseUrl
 * @see NAVHttpRequestAddHeader
 */
define_function char NAVHttpRequestInit(_NAVHttpRequest req,
                                        char method[],
                                        _NAVUrl url,
                                        char body[]) {
    stack_var char scheme[10]

    // Validate URL for HTTP/HTTPS requirements:
    // - Scheme MUST be present and must be 'http' or 'https'
    // - Host must be present and not empty
    // Note: Port validation has limitations due to integer overflow in atoi()
    //       Ports > 65535 will wrap around and appear valid

    // HTTP requests MUST have a scheme
    if (!length_array(url.Scheme)) {
        return false
    }

    // Scheme must be http or https (case-insensitive)
    scheme = lower_string(url.Scheme)

    if (scheme != 'http' && scheme != 'https') {
        return false
    }

    // Check if host is present and not empty
    if (!length_array(url.Host)) {
        return false
    }

    req.Version = NAV_HTTP_VERSION_1_1

    req.Method = method
    if (!length_array(req.Method)) {
        req.Method = NAV_HTTP_METHOD_GET
    }

    req.Host = url.Host
    req.Path = url.FullPath

    req.Body = body

    req.Headers.Count = 0
    NAVHttpRequestAddHeader(req, NAV_HTTP_HEADER_HOST, req.Host)

    if (length_array(req.Body)) {
        NAVHttpRequestAddHeader(req, NAV_HTTP_HEADER_CONTENT_LENGTH, itoa(length_array(req.Body)))
        NAVHttpRequestAddHeader(req, NAV_HTTP_HEADER_CONTENT_TYPE, NAVHttpInferContentType(req.Body))
    }

    return true
}

/**
 * @function NAVHttpStatusInit
 * @public
 * @description Initializes an HTTP status structure.
 *
 * @param {_NAVHttpStatus} status - The status structure to initialize
 *
 * @returns {void}
 *
 * @see NAVHttpResponseInit
 */
define_function NAVHttpStatusInit(_NAVHttpStatus status) {
    status.Code = 0
    status.Message = ''
}


/**
 * @function NAVHttpResponseInit
 * @public
 * @description Initializes an HTTP response structure.
 *
 * @param {_NAVHttpResponse} res - The response structure to initialize
 *
 * @returns {void}
 *
 * @see NAVHttpStatusInit
 */
define_function NAVHttpResponseInit(_NAVHttpResponse res) {
    NAVHttpStatusInit(res.Status)
    res.Body = ''

    res.Headers.Count = 0
}


/**
 * @function NAVHttpHeaderInit
 * @internal
 * @description Initializes an HTTP header key-value pair.
 *
 * Per RFC 7230, header field names are case-insensitive but the original
 * case is preserved. This function stores the key exactly as provided.
 *
 * @param {_NAVHttpHeader} header - The header structure to initialize
 * @param {char[]} key - Header name
 * @param {char[]} value - Header value
 *
 * @returns {void}
 */
define_function NAVHttpHeaderInit(_NAVHttpHeader header,
                                    char key[],
                                    char value[]) {
    header.Key = key
    header.Value = value
}


/**
 * @function NAVHttpGetDefaultPort
 * @public
 * @description Returns the default port number for the specified scheme.
 *
 * @param {char[]} scheme - URL scheme ('http' or 'https')
 *
 * @returns {integer} Default port number for the scheme
 *
 * @example
 * stack_var integer port
 *
 * port = NAVHttpGetDefaultPort('https')  // Returns 443
 */
define_function integer NAVHttpGetDefaultPort(char scheme[]) {
    switch (lower_string(scheme)) {
        case NAV_URL_SCHEME_HTTP: {
            return NAV_HTTP_PORT
        }
        case NAV_URL_SCHEME_HTTPS: {
            return NAV_HTTPS_PORT
        }
        default: {
            return NAV_HTTP_PORT
        }
    }
}


/**
 * @function NAVHttpParseUrl
 * @public
 * @description Parses a URL string into a structured URL object.
 *
 * This function handles URL parsing and ensures the scheme is valid for HTTP.
 * If the scheme is missing, it defaults to 'http'.
 *
 * @param {char[]} buffer - The URL string to parse
 * @param {_NAVUrl} url - The URL structure to populate with parsed data
 *
 * @returns {char} TRUE if parsing was successful, FALSE otherwise
 *
 * @example
 * stack_var char urlString[256]
 * stack_var _NAVUrl url
 * stack_var char success
 *
 * urlString = 'https://example.com:8443/api/v1/data?id=123'
 * success = NAVHttpParseUrl(urlString, url)
 *
 * @see NAVParseUrl
 */
define_function char NAVHttpParseUrl(char buffer[], _NAVUrl url) {
    if (!NAVParseUrl(buffer, url)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseUrl',
                                    "'Failed to parse URL'")

        return false
    }

    if (!length_array(url.Scheme)) {
        url.Scheme = NAV_URL_SCHEME_HTTP
    }
    else {
        if (!NAVFindInArrayString(NAV_HTTP_SCHEMES, url.Scheme)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                        __NAV_FOUNDATION_HTTPUTILS__,
                                        'NAVHttpParseUrl',
                                        "'Invalid scheme "', url.Scheme, '" specified. Defaulting to ', NAV_URL_SCHEME_HTTP")

            url.Scheme = NAV_URL_SCHEME_HTTP
        }
    }

    return true
}


/**
 * @function NAVHttpRequestAddHeader
 * @public
 * @description Adds a header to an HTTP request.
 *
 * If the header already exists with a different value, it will be updated.
 *
 * @param {_NAVHttpRequest} req - The request to add the header to
 * @param {char[]} key - Header name
 * @param {char[]} value - Header value
 *
 * @returns {char} TRUE if the header was added successfully, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpRequest request
 * stack_var char success
 *
 * // Assume request is already initialized
 * success = NAVHttpRequestAddHeader(request, 'User-Agent', 'AMX NetLinx/1.0')
 *
 * @see NAVHttpRequestUpdateHeader
 */
define_function char NAVHttpRequestAddHeader(_NAVHttpRequest req,
                                            char key[],
                                            char value[]) {
    _NAVHttpHeader header

    if (req.Headers.Count >= NAV_HTTP_MAX_HEADERS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpRequestAddHeader',
                                    "'Maximum number of headers (', NAV_HTTP_MAX_HEADERS, ') reached'")

        return false
    }

    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpRequestAddHeader',
                                    "'Header key cannot be empty'")

        return false
    }

    if (!length_array(value)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpRequestAddHeader',
                                    "'Header value cannot be empty'")

        return false
    }

    if (!NAVFindInArrayString(NAV_HTTP_HEADERS, key)) {
        // Allow custom headers that start with letter or digit
        stack_var char firstChar
        firstChar = key[1]

        if (!((firstChar >= 'A' && firstChar <= 'Z') ||
              (firstChar >= 'a' && firstChar <= 'z') ||
              (firstChar >= '0' && firstChar <= '9'))) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_HTTPUTILS__,
                                        'NAVHttpRequestAddHeader',
                                        "'Key ', key, ' is not a valid HTTP header'")

            return false
        }
    }

    if (NAVHttpHeaderKeyExists(req.Headers, key)) {
        if (NAVHttpGetHeaderValue(req.Headers, key) == value) {
            return true
        }

        return NAVHttpRequestUpdateHeader(req, key, value)
    }

    NAVHttpHeaderInit(header, key, value);

    req.Headers.Count++
    req.Headers.Headers[req.Headers.Count] = header

    return true
}


/**
 * @function NAVHttpRequestUpdateHeader
 * @public
 * @description Updates an existing header in an HTTP request.
 *
 * If the header doesn't exist, the function will fail.
 *
 * @param {_NAVHttpRequest} req - The request containing the header to update
 * @param {char[]} key - Header name to update
 * @param {char[]} value - New header value
 *
 * @returns {char} TRUE if header was updated, FALSE if header doesn't exist or other error
 *
 * @see NAVHttpRequestAddHeader
 */
define_function char NAVHttpRequestUpdateHeader(_NAVHttpRequest req,
                                                char key[],
                                                char value[]) {
    stack_var integer x
    stack_var integer header

    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpRequestUpdateHeader',
                                    "'Header key cannot be empty'")

        return false
    }

    if (!length_array(value)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpRequestUpdateHeader',
                                    "'Header value cannot be empty'")

        return false
    }

    if (!NAVFindInArrayString(NAV_HTTP_HEADERS, key) && !NAVStringStartsWith(key, 'X')) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpRequestUpdateHeader',
                                    "'Key ', key, ' is not a valid HTTP header'")

        return false
    }

    if (!NAVHttpHeaderKeyExists(req.Headers, key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpRequestUpdateHeader',
                                    "'Header key ', key, ' does not exist'")

        return false
    }

    header = NAVHttpFindHeader(req.Headers, key)

    if (!header) {
        return false
    }

    req.Headers.Headers[header].Value = value

    return true
}


/**
 * @function NAVHttpResponseAddHeader
 * @public
 * @description Adds a header to an HTTP response.
 *
 * If the header already exists with a different value, it will be updated.
 *
 * @param {_NAVHttpResponse} res - The response to add the header to
 * @param {char[]} key - Header name
 * @param {char[]} value - Header value
 *
 * @returns {char} TRUE if the header was added successfully, FALSE otherwise
 *
 * @see NAVHttpResponseUpdateHeader
 */
define_function char NAVHttpResponseAddHeader(_NAVHttpResponse res,
                                                char key[],
                                                char value[]) {
    _NAVHttpHeader header

    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpResponseAddHeader',
                                    "'Header key cannot be empty'")

        return false
    }

    if (!length_array(value)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpResponseAddHeader',
                                    "'Header value cannot be empty'")

        return false
    }

    if (!NAVFindInArrayString(NAV_HTTP_HEADERS, key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpResponseAddHeader',
                                    "'Key ', key, ' is not a valid HTTP header'")

        return false
    }

    if (NAVHttpHeaderKeyExists(res.Headers, key)) {
        if (NAVHttpGetHeaderValue(res.Headers, key) == value) {
            return true
        }

        return NAVHttpResponseUpdateHeader(res, key, value)
    }

    NAVHttpHeaderInit(header, key, value);

    res.Headers.Count++
    res.Headers.Headers[res.Headers.Count] = header

    return true
}


/**
 * @function NAVHttpResponseUpdateHeader
 * @public
 * @description Updates an existing header in an HTTP response.
 *
 * If the header doesn't exist, the function will fail.
 *
 * @param {_NAVHttpResponse} res - The response containing the header to update
 * @param {char[]} key - Header name to update
 * @param {char[]} value - New header value
 *
 * @returns {char} TRUE if header was updated, FALSE if header doesn't exist or other error
 *
 * @see NAVHttpResponseAddHeader
 */
define_function char NAVHttpResponseUpdateHeader(_NAVHttpResponse res,
                                                char key[],
                                                char value[]) {
    stack_var integer x
    stack_var integer header

    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpResponseUpdateHeader',
                                    "'Header key cannot be empty'")

        return false
    }

    if (!length_array(value)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpResponseUpdateHeader',
                                    "'Header value cannot be empty'")

        return false
    }

    if (!NAVFindInArrayString(NAV_HTTP_HEADERS, key) && !NAVStringStartsWith(key, 'X')) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpResponseUpdateHeader',
                                    "'Key ', key, ' is not a valid HTTP header'")

        return false
    }

    if (!NAVHttpHeaderKeyExists(res.Headers, key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpResponseUpdateHeader',
                                    "'Header key ', key, ' does not exist'")

        return false
    }

    header = NAVHttpFindHeader(res.Headers, key)

    if (!header) {
        return false
    }

    res.Headers.Headers[header].Value = value

    return true
}


/**
 * @function NAVHttpBuildHeaders
 * @public
 * @description Constructs a string of HTTP headers from a header structure.
 *
 * @param {_NAVHttpHeader} headers - The headers to build into a string
 *
 * @returns {char[NAV_MAX_BUFFER]} A string containing all headers formatted for HTTP
 *
 * @example
 * stack_var _NAVHttpHeader headers
 * stack_var char headerString[NAV_MAX_BUFFER]
 *
 * // Assume headers are already populated
 * headerString = NAVHttpBuildHeaders(headers)
 */
define_function char[NAV_MAX_BUFFER] NAVHttpBuildHeaders(_NAVHttpHeaderCollection headers) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer x

    if (!headers.Count) {
        return ''
    }

    for (x = 1; x <= headers.Count; x++) {
        result = "result, headers.Headers[x].Key, ': ', headers.Headers[x].Value, NAV_CR, NAV_LF"
    }

    return result
}


/**
 * @function NAVHttpBuildResponse
 * @public
 * @description Constructs a full HTTP response message from a response structure.
 *
 * @param {_NAVHttpResponse} res - The response structure to build into a message
 *
 * @returns {char[NAV_MAX_BUFFER]} A string containing the full HTTP response message
 *
 * @example
 * stack_var _NAVHttpResponse response
 * stack_var char responseString[NAV_MAX_BUFFER]
 *
 * // Assume response is already populated
 * responseString = NAVHttpBuildResponse(response)
 */
define_function char[NAV_MAX_BUFFER] NAVHttpBuildResponse(_NAVHttpResponse res) {
    stack_var char result[NAV_MAX_BUFFER]

    result = "NAV_HTTP_VERSION_1_1, ' ', itoa(res.Status.Code), ' ', NAVHttpGetStatusMessage(res.Status.Code), NAV_CR, NAV_LF"
    result = "result, NAVHttpBuildHeaders(res.Headers), NAV_CR, NAV_LF"

    if (!length_array(res.Body)) {
        return result
    }

    result = "result, res.Body, NAV_CR, NAV_LF"
    result = "result, NAV_CR, NAV_LF"

    return result
}


/**
 * @function NAVHttpFindHeader
 * @internal
 * @description Finds the index of a header in a header structure by key.
 *
 * @param {_NAVHttpHeader} headers - The headers to search
 * @param {char[]} key - The header name to find
 *
 * @returns {integer} The index of the header, or 0 if not found
 *
 * @see NAVHttpHeaderKeyExists
 */
define_function integer NAVHttpFindHeader(_NAVHttpHeaderCollection headers, char key[]) {
    stack_var integer x

    for (x = 1; x <= headers.Count; x++) {
        if (lower_string(headers.Headers[x].Key) != lower_string(key)) {
            continue
        }

        return x
    }

    return 0
}


/**
 * @function NAVHttpHeaderKeyExists
 * @internal
 * @description Checks if a header key exists in a header structure.
 *
 * @param {_NAVHttpHeader} headers - The headers to check
 * @param {char[]} key - The header name to check for
 *
 * @returns {char} TRUE if the header exists, FALSE otherwise
 *
 * @see NAVHttpFindHeader
 */
define_function char NAVHttpHeaderKeyExists(_NAVHttpHeaderCollection headers, char key[]) {
    return NAVHttpFindHeader(headers, key) > 0
}


/**
 * @function NAVHttpGetHeaderValue
 * @public
 * @description Retrieves the value of a header by key.
 *
 * @param {_NAVHttpHeader} headers - The headers to search
 * @param {char[]} key - The header name to find
 *
 * @returns {char[1024]} The header value, or an empty string if not found
 *
 * @see NAVHttpHeaderKeyExists
 */
define_function char[1024] NAVHttpGetHeaderValue(_NAVHttpHeadercollection headers, char key[]) {
    stack_var integer x

    if (!NAVHttpHeaderKeyExists(headers, key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpGetHeaderValue',
                                    "'Header key ', key, ' does not exist'")



        return ''
    }

    return headers.Headers[NAVHttpFindHeader(headers, key)].Value
}


/**
 * @function NAVHttpValidateHeaders
 * @public
 * @description Validates the headers in a header structure.
 *
 * Ensures that all headers have non-empty keys and values, and that the keys are valid HTTP headers.
 *
 * @param {_NAVHttpHeader} headers - The headers to validate
 *
 * @returns {char} TRUE if all headers are valid, FALSE otherwise
 *
 * @see NAVHttpHeaderKeyExists
 */
define_function char NAVHttpValidateHeaders(_NAVHttpHeaderCollection headers) {
    stack_var integer x

    if (headers.Count <= 0) {
        return true
    }

    for (x = 1; x <= headers.Count; x++) {
        if (!length_array(headers.Headers[x].Key)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_HTTPUTILS__,
                                        'NAVHttpValidateHeaders',
                                        "'Header key cannot be empty'")

            return false
        }

        if (!length_array(headers.Headers[x].Value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_HTTPUTILS__,
                                        'NAVHttpValidateHeaders',
                                        "'Header value cannot be empty'")

            return false
        }

        if (!NAVFindInArrayString(NAV_HTTP_HEADERS, headers.Headers[x].Key) && !NAVStringStartsWith(headers.Headers[x].Key, 'X')) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_HTTPUTILS__,
                                        'NAVHttpValidateHeaders',
                                        "'Key ', headers.Headers[x].Key, ' is not a valid HTTP header'")

            return false
        }
    }

    return true
}


/**
 * @function NAVHttpInferContentType
 * @public
 * @description Infers the content type of a request body based on its content.
 *
 * @param {char[]} body - The request body to infer the content type for
 *
 * @returns {char[NAV_MAX_BUFFER]} The inferred content type
 *
 * @example
 * stack_var char body[256]
 * stack_var char contentType[NAV_MAX_BUFFER]
 *
 * body = '{"key": "value"}'
 * contentType = NAVHttpInferContentType(body)  // Returns 'application/json'
 */
define_function char[NAV_MAX_BUFFER] NAVHttpInferContentType(char body[]) {
    select {
        active (NAVStartsWith(body, '{') && NAVEndsWith(body, '}')): {
            return NAV_HTTP_CONTENT_TYPE_APPLICATION_JSON
        }
        active (NAVStartsWith(body, '[') && NAVEndsWith(body, ']')): {
            return NAV_HTTP_CONTENT_TYPE_APPLICATION_JSON
        }
        active (NAVStartsWith(body, '<?xml') && NAVEndsWith(body, '?>')): {
            return NAV_HTTP_CONTENT_TYPE_TEXT_XML
        }
        active (NAVStartsWith(body, '<html>') && NAVEndsWith(body, '>')): {
            return NAV_HTTP_CONTENT_TYPE_TEXT_HTML
        }
        active (true): {
            return NAV_HTTP_CONTENT_TYPE_TEXT_PLAIN
        }
    }
}


/**
 * @function NAVHttpBuildRequest
 * @public
 * @description Constructs a full HTTP request message from a request structure.
 *
 * @param {_NAVHttpRequest} req - The request structure to build into a message
 * @param {char[]} payload - The string to populate with the full HTTP request message
 *
 * @returns {char} TRUE if the request was built successfully, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpRequest request
 * stack_var char requestString[NAV_MAX_BUFFER]
 * stack_var char success
 *
 * // Assume request is already populated
 * success = NAVHttpBuildRequest(request, requestString)
 */
define_function char NAVHttpBuildRequest(_NAVHttpRequest req, char payload[]) {
    if (!NAVHttpValidateHeaders(req.Headers)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpBuildRequest',
                                    "'Invalid HTTP headers specified'")

        return false
    }

    if (!length_array(req.Host)) {
        req.Host = NAV_HTTP_HOST_DEFAULT
    }

    req.Method = upper_string(req.Method)
    if (!NAVFindInArrayString(NAV_HTTP_METHODS, req.Method)) {
        req.Method = NAV_HTTP_METHOD_GET
    }

    if (!length_array(req.Path)) {
        req.Path = NAV_HTTP_PATH_DEFAULT
    }

    req.Version = upper_string(req.Version)
    if (!NAVFindInArrayString(NAV_HTTP_VERSIONS, req.Version)) {
        req.Version = NAV_HTTP_VERSION_1_1
    }

    payload = "req.Method, ' ', req.Path, ' ', req.Version, NAV_CR, NAV_LF"

    if (!req.Headers.Count) {
        payload = "payload, NAV_CR, NAV_LF"
    }
    else {
        payload = "payload, NAVHttpBuildHeaders(req.Headers)"
    }

    payload = "payload, NAV_CR, NAV_LF"

    if (!length_array(req.Body)) {
        return true
    }

    payload = "payload, req.Body"

    return true
}


/**
 * @function NAVHttpGetStatusMessage
 * @public
 * @description Returns the status message corresponding to an HTTP status code.
 *
 * @param {integer} status - The HTTP status code
 *
 * @returns {char[NAV_MAX_CHARS]} The corresponding status message
 *
 * @example
 * stack_var integer statusCode
 * stack_var char statusMessage[NAV_MAX_CHARS]
 *
 * statusCode = 200
 * statusMessage = NAVHttpGetStatusMessage(statusCode)  // Returns 'OK'
 */
define_function char[NAV_MAX_CHARS] NAVHttpGetStatusMessage(integer status) {
    switch (status) {
        case NAV_HTTP_STATUS_CODE_INFO_CONTINUE:              { return NAV_HTTP_STATUS_MESSAGE_INFO_CONTINUE }
        case NAV_HTTP_STATUS_CODE_INFO_SWITCHING_PROTOCOLS:   { return NAV_HTTP_STATUS_MESSAGE_INFO_SWITCHING_PROTOCOLS }
        case NAV_HTTP_STATUS_CODE_INFO_PROCESSING:            { return NAV_HTTP_STATUS_MESSAGE_INFO_PROCESSING }
        case NAV_HTTP_STATUS_CODE_INFO_EARLY_HINTS:           { return NAV_HTTP_STATUS_MESSAGE_INFO_EARLY_HINTS }

        case NAV_HTTP_STATUS_CODE_SUCCESS_OK:                  { return NAV_HTTP_STATUS_MESSAGE_SUCCESS_OK }
        case NAV_HTTP_STATUS_CODE_SUCCESS_CREATED:             { return NAV_HTTP_STATUS_MESSAGE_SUCCESS_CREATED }
        case NAV_HTTP_STATUS_CODE_SUCCESS_ACCEPTED:            { return NAV_HTTP_STATUS_MESSAGE_SUCCESS_ACCEPTED }
        case NAV_HTTP_STATUS_CODE_SUCCESS_NON_AUTHORITATIVE_INFO: { return NAV_HTTP_STATUS_MESSAGE_SUCCESS_NON_AUTHORITATIVE_INFO }
        case NAV_HTTP_STATUS_CODE_SUCCESS_NO_CONTENT:          { return NAV_HTTP_STATUS_MESSAGE_SUCCESS_NO_CONTENT }
        case NAV_HTTP_STATUS_CODE_SUCCESS_RESET_CONTENT:       { return NAV_HTTP_STATUS_MESSAGE_SUCCESS_RESET_CONTENT }
        case NAV_HTTP_STATUS_CODE_SUCCESS_PARTIAL_CONTENT:     { return NAV_HTTP_STATUS_MESSAGE_SUCCESS_PARTIAL_CONTENT }
        case NAV_HTTP_STATUS_CODE_SUCCESS_MULTI_STATUS:        { return NAV_HTTP_STATUS_MESSAGE_SUCCESS_MULTI_STATUS }
        case NAV_HTTP_STATUS_CODE_SUCCESS_ALREADY_REPORTED:    { return NAV_HTTP_STATUS_MESSAGE_SUCCESS_ALREADY_REPORTED }
        case NAV_HTTP_STATUS_CODE_SUCCESS_IM_USED:             { return NAV_HTTP_STATUS_MESSAGE_SUCCESS_IM_USED }

        case NAV_HTTP_STATUS_CODE_REDIRECT_MULTIPLE_CHOICES:   { return NAV_HTTP_STATUS_MESSAGE_REDIRECT_MULTIPLE_CHOICES }
        case NAV_HTTP_STATUS_CODE_REDIRECT_MOVED_PERMANENTLY: { return NAV_HTTP_STATUS_MESSAGE_REDIRECT_MOVED_PERMANENTLY }
        case NAV_HTTP_STATUS_CODE_REDIRECT_FOUND:              { return NAV_HTTP_STATUS_MESSAGE_REDIRECT_FOUND }
        case NAV_HTTP_STATUS_CODE_REDIRECT_SEE_OTHER:          { return NAV_HTTP_STATUS_MESSAGE_REDIRECT_SEE_OTHER }
        case NAV_HTTP_STATUS_CODE_REDIRECT_NOT_MODIFIED:       { return NAV_HTTP_STATUS_MESSAGE_REDIRECT_NOT_MODIFIED }
        case NAV_HTTP_STATUS_CODE_REDIRECT_USE_PROXY:          { return NAV_HTTP_STATUS_MESSAGE_REDIRECT_USE_PROXY }
        case NAV_HTTP_STATUS_CODE_REDIRECT_TEMPORARY_REDIRECT: { return NAV_HTTP_STATUS_MESSAGE_REDIRECT_TEMPORARY_REDIRECT }
        case NAV_HTTP_STATUS_CODE_REDIRECT_PERMANENT_REDIRECT: { return NAV_HTTP_STATUS_MESSAGE_REDIRECT_PERMANENT_REDIRECT }

        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_BAD_REQUEST:    { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_BAD_REQUEST }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_UNAUTHORIZED:   { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_UNAUTHORIZED }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_PAYMENT_REQUIRED: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_PAYMENT_REQUIRED }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_FORBIDDEN:      { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_FORBIDDEN }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_NOT_FOUND:      { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_NOT_FOUND }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_METHOD_NOT_ALLOWED: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_METHOD_NOT_ALLOWED }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_NOT_ACCEPTABLE: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_NOT_ACCEPTABLE }
        // case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_PROXY_AUTH_REQUIRED: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_PROXY_AUTH_REQUIRED }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_REQUEST_TIMEOUT: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_REQUEST_TIMEOUT }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_CONFLICT:       { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_CONFLICT }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_GONE:           { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_GONE }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_LENGTH_REQUIRED: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_LENGTH_REQUIRED }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_PRECONDITION_FAILED: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_PRECONDITION_FAILED }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_PAYLOAD_TOO_LARGE: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_PAYLOAD_TOO_LARGE }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_URI_TOO_LONG:   { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_URI_TOO_LONG }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_UNSUPPORTED_MEDIA_TYPE: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_UNSUPPORTED_MEDIA_TYPE }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_RANGE_NOT_SATISFIABLE: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_RANGE_NOT_SATISFIABLE }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_EXPECTATION_FAILED: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_EXPECTATION_FAILED }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_IM_A_TEAPOT:     { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_IM_A_TEAPOT }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_MISDIRECTED_REQUEST: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_MISDIRECTED_REQUEST }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_UNPROCESSABLE_CONTENT: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_UNPROCESSABLE_CONTENT }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_LOCKED:          { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_LOCKED }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_FAILED_DEPENDENCY: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_FAILED_DEPENDENCY }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_TOO_EARLY:       { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_TOO_EARLY }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_UPGRADE_REQUIRED: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_UPGRADE_REQUIRED }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_PRECONDITION_REQUIRED: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_PRECONDITION_REQUIRED }
        case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_TOO_MANY_REQUESTS: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_TOO_MANY_REQUESTS }
        // case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_REQUEST_HEADER_FIELDS_TOO_LARGE: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_REQUEST_HEADER_FIELDS_TOO_LARGE }
        // case NAV_HTTP_STATUS_CODE_CLIENT_ERROR_UNAVAILABLE_FOR_LEGAL_REASONS: { return NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_UNAVAILABLE_FOR_LEGAL_REASONS }

        case NAV_HTTP_STATUS_CODE_SERVER_ERROR_SERVER_ERROR: { return NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_SERVER_ERROR }
        case NAV_HTTP_STATUS_CODE_SERVER_ERROR_NOT_IMPLEMENTED: { return NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_NOT_IMPLEMENTED }
        case NAV_HTTP_STATUS_CODE_SERVER_ERROR_BAD_GATEWAY:     { return NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_BAD_GATEWAY }
        case NAV_HTTP_STATUS_CODE_SERVER_ERROR_SERVICE_UNAVAILABLE: { return NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_SERVICE_UNAVAILABLE }
        case NAV_HTTP_STATUS_CODE_SERVER_ERROR_SERVER_TIMEOUT: { return NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_SERVER_TIMEOUT }
        case NAV_HTTP_STATUS_CODE_SERVER_ERROR_VERSION_NOT_SUPPORTED: { return NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_VERSION_NOT_SUPPORTED }
        case NAV_HTTP_STATUS_CODE_SERVER_ERROR_VARIANT_ALSO_NEGOTIATES: { return NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_VARIANT_ALSO_NEGOTIATES }
        case NAV_HTTP_STATUS_CODE_SERVER_ERROR_INSUFFICIENT_STORAGE: { return NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_INSUFFICIENT_STORAGE }
        case NAV_HTTP_STATUS_CODE_SERVER_ERROR_LOOP_DETECTED:   { return NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_LOOP_DETECTED }
        case NAV_HTTP_STATUS_CODE_SERVER_ERROR_NOT_EXTENDED:    { return NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_NOT_EXTENDED }
        // case NAV_HTTP_STATUS_CODE_SERVER_ERROR_NETWORK_AUTH_REQUIRED: { return NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_NETWORK_AUTH_REQUIRED }

        default:                                                { return NAV_HTTP_STATUS_MESSAGE_UNKNOWN }
    }
}


/**
 * @function NAVHttpParseStatusLine
 * @public
 * @description Parses an HTTP status line into a status structure.
 *
 * Extracts the HTTP version, status code, and status message from a status line.
 * Expected format: "HTTP/1.1 200 OK"
 *
 * @param {char[]} statusLine - The status line to parse
 * @param {_NAVHttpStatus} status - The status structure to populate
 *
 * @returns {char} TRUE if parsing succeeded, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpStatus status
 * stack_var char statusLine[256]
 * stack_var char result
 *
 * statusLine = 'HTTP/1.1 200 OK'
 * result = NAVHttpParseStatusLine(statusLine, status)
 * // status.Code = 200, status.Message = 'OK'
 *
 * @see NAVHttpParseResponse
 */
define_function char NAVHttpParseStatusLine(char statusLine[], _NAVHttpStatus status) {
    stack_var char parts[10][512]
    stack_var integer count

    if (!length_array(statusLine)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseStatusLine',
                                    "'Status line is empty'")
        return false
    }

    count = NAVSplitString(statusLine, ' ', parts)

    if (count < 2) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseStatusLine',
                                    "'Invalid status line format'")
        return false
    }

    // Trim parts extra whitespace
    NAVTrimStringArray(parts)

    // Validate and convert status code
    status.Code = atoi(parts[2])
    if (status.Code < 100 || status.Code > 599) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseStatusLine',
                                    "'Invalid status code: ', parts[2]")
        return false
    }

    if (count < 3) {
        status.Message = ''
        return true
    }

    {
        // Extract message preserving spaces
        stack_var char prefix[NAV_MAX_BUFFER]

        prefix = "parts[1], ' ', parts[2], ' '"
        status.Message = NAVGetStringAfter(statusLine, prefix)
    }

    return true
}


/**
 * @function NAVHttpParseHeaders
 * @public
 * @description Parses HTTP header lines into a header collection.
 *
 * Parses multiple header lines in "Key: Value" format. Handles headers with
 * colons in the value and trims whitespace around keys and values.
 *
 * @param {char[]} headerBlock - Block of header lines separated by CRLF
 * @param {_NAVHttpHeaderCollection} headers - The header collection to populate
 *
 * @returns {char} TRUE if parsing succeeded, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpHeaderCollection headers
 * stack_var char headerBlock[NAV_MAX_BUFFER]
 * stack_var char result
 *
 * headerBlock = "'Content-Type: application/json', NAV_CR, NAV_LF,
 *                'Content-Length: 123', NAV_CR, NAV_LF"
 * result = NAVHttpParseHeaders(headerBlock, headers)
 *
 * @see NAVHttpParseResponse
 */
define_function char NAVHttpParseHeaders(char headerBlock[], _NAVHttpHeaderCollection headers) {
    stack_var char line[1024]
    stack_var integer lineEnd
    stack_var integer colonPos
    stack_var char key[256]
    stack_var char value[1024]
    stack_var char remaining[NAV_MAX_BUFFER]
    stack_var _NAVHttpHeader header

    if (!length_array(headerBlock)) {
        // Empty header block is valid (no headers)
        return true
    }

    remaining = headerBlock
    headers.Count = 0

    while (length_array(remaining)) {
        // Find end of line
        lineEnd = NAVIndexOf(remaining, "NAV_CR, NAV_LF", 1)

        if (!lineEnd) {
            // Last line without CRLF
            line = remaining
            remaining = ''
        }
        else {
            line = left_string(remaining, lineEnd - 1)
            remaining = right_string(remaining, length_array(remaining) - lineEnd - 1)
        }

        // Skip empty lines
        // Stop at empty lines (header terminator)
        if (!length_array(line)) {
            break
        }

        // Find colon separator
        colonPos = NAVIndexOf(line, ':', 1)
        if (!colonPos) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                        __NAV_FOUNDATION_HTTPUTILS__,
                                        'NAVHttpParseHeaders',
                                        "'Invalid header line (no colon): ', line")
            continue
        }

        // Extract key and value
        key = left_string(line, colonPos - 1)
        key = NAVTrimString(key)  // Remove leading/trailing spaces

        if (colonPos < length_array(line)) {
            value = right_string(line, length_array(line) - colonPos)
            value = NAVTrimString(value)  // Remove leading/trailing spaces
        }
        else {
            value = ''
        }

        // Check if we've hit the header limit
        if (headers.Count >= NAV_HTTP_MAX_HEADERS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                        __NAV_FOUNDATION_HTTPUTILS__,
                                        'NAVHttpParseHeaders',
                                        "'Maximum header limit reached, ignoring additional headers'")
            break
        }

        // Add header to collection
        NAVHttpHeaderInit(header, key, value)
        headers.Count++
        headers.Headers[headers.Count] = header
    }

    return true
}


/**
 * @function NAVHttpResponseMayHaveBody
 * @public
 * @description Determines if an HTTP response may have a body based on status code.
 *
 * Certain status codes never have response bodies according to HTTP specification:
 * - 1xx (Informational): 100-199
 * - 204 (No Content)
 * - 304 (Not Modified)
 *
 * @param {_NAVHttpResponse} res - The response structure to check
 *
 * @returns {char} TRUE if response should have a body, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpResponse response
 * stack_var char hasBody
 *
 * // After parsing headers
 * hasBody = NAVHttpResponseMayHaveBody(response)
 *
 * @see NAVHttpParseResponseHeaders
 */
define_function char NAVHttpResponseMayHaveBody(_NAVHttpResponse res) {
    // 1xx informational responses never have bodies
    if (res.Status.Code >= 100 && res.Status.Code < 200) {
        return false
    }

    // 204 No Content never has a body
    if (res.Status.Code == 204) {
        return false
    }

    // 304 Not Modified never has a body
    if (res.Status.Code == 304) {
        return false
    }

    // All other status codes may have bodies
    return true
}


/**
 * @function NAVHttpParseResponseHeaders
 * @public
 * @description Parses HTTP response status line and headers.
 *
 * This function parses the status line and headers from an HTTP response buffer.
 * The buffer should contain at least the complete headers (up to and including
 * the double CRLF: 13,10,13,10). Body parsing is handled separately.
 *
 * For incremental response processing, use NAVHttpProcessResponseBuffer which
 * handles state management and callbacks.
 *
 * @param {char[]} buffer - Response buffer containing status line and headers (up to double CRLF)
 * @param {_NAVHttpResponse} res - The response structure to populate
 *
 * @returns {char} TRUE if parsing succeeded, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpResponse response
 * stack_var char buffer[NAV_MAX_BUFFER]
 * stack_var char result
 *
 * // Parse headers from complete header buffer
 * buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
 *           'Content-Type: application/json', NAV_CR, NAV_LF,
 *           NAV_CR, NAV_LF"
 * result = NAVHttpParseResponseHeaders(buffer, response)
 *
 * // Now you have response.Status and response.Headers
 * // Body can be extracted separately based on Content-Length
 *
 * NOTE: This library only supports responses with Content-Length headers.
 * Responses using Transfer-Encoding (e.g., chunked) are not supported.
 *
 * @see NAVHttpParseResponseBody
 * @see NAVHttpParseResponse
 * @see NAVHttpParseStatusLine
 * @see NAVHttpParseHeaders
 * @see NAVHttpResponseMayHaveBody
 * @see NAVHttpProcessResponseBuffer
 */
define_function char NAVHttpParseResponseHeaders(char buffer[], _NAVHttpResponse res) {
    stack_var integer firstLineEnd
    stack_var char statusLine[NAV_MAX_BUFFER]
    stack_var char headerBlock[NAV_MAX_BUFFER]
    stack_var char remaining[NAV_MAX_BUFFER]

    if (!length_array(buffer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseResponseHeaders',
                                    "'Response buffer is empty'")
        return false
    }

    // Extract status line (first line)
    firstLineEnd = NAVIndexOf(buffer, "NAV_CR, NAV_LF", 1)
    if (!firstLineEnd) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseResponseHeaders',
                                    "'No CRLF found - invalid response format'")
        return false
    }

    statusLine = left_string(buffer, firstLineEnd - 1)
    remaining = right_string(buffer, length_array(buffer) - firstLineEnd - 1)

    // Parse status line
    if (!NAVHttpParseStatusLine(statusLine, res.Status)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseResponseHeaders',
                                    "'Failed to parse status line'")
        return false
    }

    // The remaining buffer contains headers, potentially ending with double CRLF
    // Parse headers (NAVHttpParseHeaders handles empty lines gracefully)
    if (!NAVHttpParseHeaders(remaining, res.Headers)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseResponseHeaders',
                                    "'Failed to parse headers'")
        return false
    }

    // Warn if Transfer-Encoding is present (not supported)
    if (NAVHttpHeaderKeyExists(res.Headers, 'Transfer-Encoding')) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseResponseHeaders',
                                    "'Transfer-Encoding header detected - this library only supports Content-Length'")
    }

    // Populate the common headers
    if (NAVHttpHeaderKeyExists(res.Headers, NAV_HTTP_HEADER_CONTENT_TYPE)) {
        res.ContentType = NAVHttpGetHeaderValue(res.Headers, NAV_HTTP_HEADER_CONTENT_TYPE)
    }

    if (NAVHttpHeaderKeyExists(res.Headers, NAV_HTTP_HEADER_CONTENT_LENGTH)) {
        if (!NAVParseLong(NAVHttpGetHeaderValue(res.Headers, NAV_HTTP_HEADER_CONTENT_LENGTH), res.ContentLength)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_HTTPUTILS__,
                                        'NAVHttpParseResponseHeaders',
                                        "'Invalid Content-Length header value'")
            return false
        }
    }

    return true
}


/**
 * @function NAVHttpParseResponseBody
 * @public
 * @description Extracts the response body from buffer based on Content-Length header.
 *
 * This function reads the Content-Length header from the response structure
 * and extracts exactly that many bytes from the buffer. The response must
 * have headers already parsed via NAVHttpParseResponseHeaders.
 *
 * This library only supports responses with Content-Length headers.
 *
 * @param {char[]} buffer - Buffer containing the response body data
 * @param {_NAVHttpResponse} res - The response structure with parsed headers
 *
 * @returns {char} TRUE if extraction succeeded, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpResponse response
 * stack_var char buffer[NAV_MAX_BUFFER]
 * stack_var char result
 *
 * // After parsing headers
 * NAVHttpParseResponseHeaders(headerData, response)
 *
 * // Wait until we have enough body data in device buffer
 * // Then extract body
 * result = NAVHttpParseResponseBody(bodyData, response)
 *
 * @see NAVHttpParseResponseHeaders
 * @see NAVHttpResponseMayHaveBody
 */
define_function char NAVHttpParseResponseBody(char buffer[], _NAVHttpResponse res) {
    // Content-Length is already validated and cached in res.ContentLength
    if (res.ContentLength == 0) {
        res.Body = ''
        return true
    }

    // Validate buffer has enough data
    if (length_array(buffer) < res.ContentLength) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseResponseBody',
                                    "'Buffer length ', itoa(length_array(buffer)), ' is less than Content-Length ', itoa(res.ContentLength)")
        return false
    }

    // Extract exactly ContentLength bytes from buffer
    res.Body = get_buffer_string(buffer, res.ContentLength)
    return true
}


/**
 * @function NAVHttpParseResponse
 * @public
 * @description Parses HTTP response status line and headers only.
 *
 * This function parses only the status line and headers from an HTTP response.
 * It does NOT parse the body - body parsing is a completely separate step.
 *
 * After calling this function:
 * 1. Check if response may have body: NAVHttpResponseMayHaveBody()
 * 2. Check body length: response.ContentLength
 * 3. Wait for body data in your device buffer
 * 4. Extract body: NAVHttpParseResponseBody()
 *
 * The buffer should contain at least the complete headers (up to and including
 * the double CRLF). Any data after the double CRLF is ignored.
 *
 * @param {char[]} buffer - Buffer containing at least the complete HTTP response headers
 * @param {_NAVHttpResponse} res - The response structure to populate
 *
 * @returns {char} TRUE if parsing succeeded, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpResponse response
 * stack_var char buffer[NAV_MAX_BUFFER]
 * stack_var long bodyLength
 * stack_var char result
 *
 * // Parse headers only
 * buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
 *           'Content-Type: application/json', NAV_CR, NAV_LF,
 *           'Content-Length: 15', NAV_CR, NAV_LF,
 *           NAV_CR, NAV_LF"
 * result = NAVHttpParseResponse(buffer, response)
 *
 * // Now separately handle body
 * if (NAVHttpResponseMayHaveBody(response)) {
 *     if (response.ContentLength > 0) {
 *         // ... wait for response.ContentLength bytes ...
 *         // NAVHttpParseResponseBody(bodyData, response)
 *     }
 * }
 *
 * @see NAVHttpParseResponseHeaders
 * @see NAVHttpParseResponseBody
 * @see NAVHttpResponseMayHaveBody
 */
define_function char NAVHttpParseResponse(char buffer[], _NAVHttpResponse res) {
    if (!length_array(buffer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseResponse',
                                    "'Response buffer is empty'")
        return false
    }

    // Just parse headers - body parsing is separate
    return NAVHttpParseResponseHeaders(buffer, res)
}


/**
 * HTTP Response Buffer Processing Functions
 *
 * These functions provide a high-level buffer processing pattern for HTTP responses.
 * They handle state management, incremental data arrival, and callbacks for headers,
 * body, and completion events.
 *
 * Use NAVHttpProcessResponseBuffer for automatic incremental response processing
 * from device buffers. It manages state transitions and calls your callbacks when
 * headers or body data is available.
 */

// Callback function prototypes - users implement these in their code:
// #DEFINE USING_NAV_HTTP_RESPONSE_HEADERS_CALLBACK
// define_function NAVHttpResponseHeadersCallback(_NAVHttpResponseHeadersResult result) {}
//
// #DEFINE USING_NAV_HTTP_RESPONSE_BODY_CALLBACK
// define_function NAVHttpResponseBodyCallback(_NAVHttpResponseBodyResult result) {}
//
// #DEFINE USING_NAV_HTTP_RESPONSE_COMPLETE_CALLBACK
// define_function NAVHttpResponseCompleteCallback(_NAVHttpResponseCompleteResult result) {}


/**
 * @function NAVHttpResponseBufferInit
 * @public
 * @description Initializes an HTTP response buffer structure.
 *
 * Call this before using the buffer to process HTTP responses.
 *
 * @param {_NAVHttpResponseBuffer} buffer - The buffer structure to initialize
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVHttpResponseBuffer buffer
 * NAVHttpResponseBufferInit(buffer)
 *
 * @see NAVHttpProcessResponseBuffer
 */
define_function NAVHttpResponseBufferInit(_NAVHttpResponseBuffer buffer) {
    buffer.Data = ''
    buffer.Semaphore = false
    buffer.State = NAV_HTTP_STATE_IDLE
    buffer.ContentLength = 0
}


/**
 * @function NAVHttpProcessResponseBuffer
 * @public
 * @description Processes HTTP response data from a buffer using a state machine approach.
 *
 * This function implements a callback-based pattern for processing HTTP responses
 * incrementally as data arrives. It extracts raw data and passes it to callbacks
 * where users parse and process it.
 *
 * The function handles:
 * - State management (IDLE -> PARSING_HEADERS -> PARSING_BODY)
 * - Data extraction based on delimiters (headers) or byte counts (body)
 * - Callbacks with raw data for user processing
 * - Automatic buffer cleanup and reset after complete response
 *
 * The buffer should be connected to a device using create_buffer in your code.
 * This function is typically called from a data_event[device] string handler.
 *
 * Users must implement callback functions and enable them with #DEFINE:
 * - #DEFINE USING_NAV_HTTP_RESPONSE_HEADERS_CALLBACK
 * - #DEFINE USING_NAV_HTTP_RESPONSE_BODY_CALLBACK (optional)
 * - #DEFINE USING_NAV_HTTP_RESPONSE_COMPLETE_CALLBACK (optional)
 *
 * State transitions:
 * - User sets buffer.State = NAV_HTTP_STATE_PARSING_BODY in headers callback if body expected
 * - User sets buffer.ContentLength in headers callback to specify body length
 * - Buffer automatically resets to IDLE after body processing
 *
 * @param {_NAVHttpResponseBuffer} buffer - Buffer structure with received HTTP data
 *
 * @returns {void}
 *
 * @example
 * // In DEFINE_VARIABLE:
 * volatile _NAVHttpResponseBuffer httpBuffer
 * volatile _NAVHttpResponse myResponse
 *
 * // In DEFINE_START:
 * NAVHttpResponseBufferInit(httpBuffer)
 * create_buffer dvSocket, httpBuffer.Data
 *
 * // In data_event:
 * data_event[dvSocket] {
 *     string: {
 *         NAVHttpProcessResponseBuffer(httpBuffer)
 *     }
 * }
 *
 * // Define callbacks:
 * #DEFINE USING_NAV_HTTP_RESPONSE_HEADERS_CALLBACK
 * define_function NAVHttpResponseHeadersCallback(_NAVHttpResponseHeadersResult result) {
 *     // Parse headers
 *     if (!NAVHttpParseResponseHeaders(result.Data, myResponse)) {
 *         return
 *     }
 *
 *     // Check if body expected
 *     if (NAVHttpResponseMayHaveBody(myResponse) && myResponse.ContentLength > 0) {
 *         httpBuffer.ContentLength = myResponse.ContentLength
 *         httpBuffer.State = NAV_HTTP_STATE_PARSING_BODY
 *     }
 * }
 *
 * #DEFINE USING_NAV_HTTP_RESPONSE_BODY_CALLBACK
 * define_function NAVHttpResponseBodyCallback(_NAVHttpResponseBodyResult result) {
 *     // Parse body
 *     NAVHttpParseResponseBody(result.Data, myResponse)
 *     // Process complete response...
 * }
 *
 * #DEFINE USING_NAV_HTTP_RESPONSE_COMPLETE_CALLBACK
 * define_function NAVHttpResponseCompleteCallback(_NAVHttpResponseCompleteResult result) {
 *     // Cleanup, notifications, restart timelines, etc.
 * }
 *
 * @see NAVHttpResponseBufferInit
 * @see _NAVHttpResponseBuffer
 */
define_function NAVHttpProcessResponseBuffer(_NAVHttpResponseBuffer buffer) {
    stack_var char data[NAV_HTTP_MAX_RESPONSE_BODY]

    // Prevent concurrent access
    if (buffer.Semaphore) {
        return
    }

    buffer.Semaphore = true

    // Initialize state if needed
    if (buffer.State == NAV_HTTP_STATE_IDLE) {
        buffer.State = NAV_HTTP_STATE_PARSING_HEADERS
    }

    // Process buffer while data available
    while (length_array(buffer.Data)) {
        switch (buffer.State) {
            case NAV_HTTP_STATE_PARSING_HEADERS: {
                // Wait for complete headers (CRLF CRLF delimiter)
                if (!NAVContains(buffer.Data, NAV_HTTP_HEADER_DELIMITER)) {
                    // Not enough data yet - wait for more
                    break
                }

                // Extract headers up to and including delimiter
                data = remove_string(buffer.Data, NAV_HTTP_HEADER_DELIMITER, 1)

                if (!length_array(data)) {
                    continue
                }

                // Fire headers callback with raw data
                // User parses and decides if body expected
                #IF_DEFINED USING_NAV_HTTP_RESPONSE_HEADERS_CALLBACK
                {
                    stack_var _NAVHttpResponseHeadersResult headersResult
                    headersResult.Data = data
                    NAVHttpResponseHeadersCallback(headersResult)
                }
                #END_IF

                // Check if user transitioned to body parsing state
                if (buffer.State == NAV_HTTP_STATE_PARSING_BODY) {
                    continue  // Keep processing
                }

                // No body expected - fire complete callback and reset
                #IF_DEFINED USING_NAV_HTTP_RESPONSE_COMPLETE_CALLBACK
                {
                    stack_var _NAVHttpResponseCompleteResult completeResult
                    completeResult.State = NAV_HTTP_STATE_PARSING_HEADERS
                    NAVHttpResponseCompleteCallback(completeResult)
                }
                #END_IF

                // Reset buffer for next response
                NAVHttpResponseBufferInit(buffer)
                break
            }

            case NAV_HTTP_STATE_PARSING_BODY: {
                // Wait for complete body based on ContentLength
                if (length_array(buffer.Data) < buffer.ContentLength) {
                    // Not enough data yet - wait for more
                    break
                }

                // Fire body callback with raw buffer
                // User calls NAVHttpParseResponseBody which extracts exact ContentLength bytes
                #IF_DEFINED USING_NAV_HTTP_RESPONSE_BODY_CALLBACK
                {
                    stack_var _NAVHttpResponseBodyResult bodyResult
                    bodyResult.Data = buffer.Data
                    NAVHttpResponseBodyCallback(bodyResult)
                }
                #END_IF

                // Fire complete callback
                #IF_DEFINED USING_NAV_HTTP_RESPONSE_COMPLETE_CALLBACK
                {
                    stack_var _NAVHttpResponseCompleteResult completeResult
                    completeResult.State = NAV_HTTP_STATE_PARSING_BODY
                    NAVHttpResponseCompleteCallback(completeResult)
                }
                #END_IF

                // Reset buffer for next response
                NAVHttpResponseBufferInit(buffer)
                break
            }
        }

        // If we broke out of the switch, exit the while loop
        break
    }

    buffer.Semaphore = false
}


#END_IF // __NAV_FOUNDATION_HTTPUTILS__
