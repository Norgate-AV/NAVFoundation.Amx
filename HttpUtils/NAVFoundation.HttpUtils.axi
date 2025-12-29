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
 * This converts the header name to train case (capitalized words separated by hyphens).
 *
 * @param {_NAVHttpHeader} header - The header structure to initialize
 * @param {char[]} key - Header name
 * @param {char[]} value - Header value
 *
 * @returns {void}
 *
 * @see NAVStringTrainCase
 */
define_function NAVHttpHeaderInit(_NAVHttpHeader header,
                                    char key[],
                                    char value[]) {
    header.Key = NAVStringTrainCase(key)
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
    switch (scheme) {
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

    result = "res.Status.Code, ' ', NAVHttpGetStatusMessage(res.Status.Code), NAV_CR, NAV_LF"
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
        if (headers.Headers[x].Key != key) {
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
 * @function NAVHttpParseResponseHeaders
 * @public
 * @description Parses HTTP response status line and headers.
 *
 * This function is designed for real-world NetLinx device communication where
 * the response arrives in chunks. Use NAVStringGather to extract data up to and
 * including the double CRLF (13,10,13,10), then parse the headers. The body can
 * be processed separately once Content-Length bytes have been received.
 *
 * @param {char[]} buffer - Response buffer containing status line and headers (up to double CRLF)
 * @param {_NAVHttpResponse} res - The response structure to populate
 *
 * @returns {char} TRUE if parsing succeeded, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpResponse response
 * stack_var char headers[NAV_MAX_BUFFER]
 * stack_var char result
 *
 * // Use NAVStringGather to extract headers from device buffer
 * headers = NAVStringGather(deviceBuffer, "13,10,13,10", true)
 * result = NAVHttpParseResponseHeaders(headers, response)
 *
 * // Now you have response.Status and response.Headers
 * // Body can be extracted separately based on Content-Length
 *
 * @see NAVHttpParseResponseBody
 * @see NAVHttpParseResponse
 * @see NAVHttpParseStatusLine
 * @see NAVHttpParseHeaders
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

    return true
}


/**
 * @function NAVHttpParseResponseBody
 * @public
 * @description Extracts and validates the HTTP response body.
 *
 * This function is designed to be called after NAVHttpParseResponseHeaders once
 * the body data has been received from the device. If Content-Length header is
 * present, it validates that the body matches the expected length.
 *
 * @param {char[]} buffer - Buffer containing the response body
 * @param {_NAVHttpResponse} res - The response structure to populate with body
 *
 * @returns {char} TRUE if body extraction succeeded, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpResponse response
 * stack_var char buffer[NAV_MAX_BUFFER]
 * stack_var integer length
 * stack_var char result
 *
 * // After parsing headers, get Content-Length
 * length = atoi(NAVHttpGetHeaderValue(response.Headers, 'Content-Length'))
 *
 * // Wait until we have enough data in device buffer
 * if (length_array(deviceBuffer) >= length) {
 *     buffer = get_buffer_string(deviceBuffer, length)
 *     result = NAVHttpParseResponseBody(buffer, response)
 * }
 *
 * @see NAVHttpParseResponseHeaders
 * @see NAVHttpParseResponse
 */
define_function char NAVHttpParseResponseBody(char buffer[], _NAVHttpResponse res) {
    stack_var integer length

    // Validate against Content-Length if present
    if (!NAVHttpHeaderKeyExists(res.Headers, NAV_HTTP_HEADER_CONTENT_LENGTH)) {
        res.Body = ''
        return true
    }

    length = atoi(NAVHttpGetHeaderValue(res.Headers, NAV_HTTP_HEADER_CONTENT_LENGTH))

    if (length < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseResponseBody',
                                    "'Invalid Content-Length header value'")
        return false
    }

    if (length_array(buffer) < length) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseResponseBody',
                                    "'Buffer length ', itoa(length_array(buffer)), ' is less than Content-Length ', itoa(length)")
        return false
    }

    if (length == 0) {
        res.Body = ''
        return true
    }

    res.Body = NAVRemoveStringByLength(buffer, length)

    return true
}


/**
 * @function NAVHttpParseResponse
 * @public
 * @description Parses a complete HTTP response into a response structure.
 *
 * This is a convenience function that parses the status line, headers, and body
 * from a complete HTTP response string. For real-world device communication where
 * responses arrive in chunks, use NAVHttpParseResponseHeaders followed by
 * NAVHttpParseResponseBody instead.
 *
 * @param {char[]} buffer - Complete raw HTTP response string
 * @param {_NAVHttpResponse} res - The response structure to populate
 *
 * @returns {char} TRUE if parsing succeeded, FALSE otherwise
 *
 * @example
 * stack_var _NAVHttpResponse response
 * stack_var char buffer[NAV_MAX_BUFFER]
 * stack_var char result
 *
 * buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
 *           'Content-Type: application/json', NAV_CR, NAV_LF,
 *           NAV_CR, NAV_LF,
 *           '{"status":"ok"}'"
 * result = NAVHttpParseResponse(buffer, response)
 *
 * @see NAVHttpParseResponseHeaders
 * @see NAVHttpParseResponseBody
 * @see NAVHttpParseStatusLine
 * @see NAVHttpParseHeaders
 */
define_function char NAVHttpParseResponse(char buffer[], _NAVHttpResponse res) {
    stack_var integer headerEnd
    stack_var char headerBuffer[NAV_MAX_BUFFER]
    stack_var char bodyBuffer[NAV_MAX_BUFFER]

    if (!length_array(buffer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseResponse',
                                    "'Response buffer is empty'")
        return false
    }

    // Find end of headers (double CRLF)
    headerEnd = NAVIndexOf(buffer, "NAV_CR, NAV_LF, NAV_CR, NAV_LF", 1)

    if (!headerEnd) {
        // No double CRLF found - might just be headers without body
        headerBuffer = buffer
        bodyBuffer = ''
    }
    else {
        // Split into headers and body
        headerBuffer = left_string(buffer, headerEnd + 3)  // Include double CRLF

        if (headerEnd + 3 < length_array(buffer)) {
            bodyBuffer = right_string(buffer, length_array(buffer) - headerEnd - 3)
        }
        else {
            bodyBuffer = ''
        }
    }

    // Parse headers first
    if (!NAVHttpParseResponseHeaders(headerBuffer, res)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpParseResponse',
                                    "'Failed to parse headers'")
        return false
    }

    // Parse body if present
    if (length_array(bodyBuffer)) {
        if (!NAVHttpParseResponseBody(bodyBuffer, res)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_HTTPUTILS__,
                                        'NAVHttpParseResponse',
                                        "'Failed to parse body'")
            return false
        }
    }

    return true
}


#END_IF // __NAV_FOUNDATION_HTTPUTILS__
