PROGRAM_NAME='NAVFoundation.Http'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

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

#IF_NOT_DEFINED __NAV_FOUNDATION_HTTP__
#DEFINE __NAV_FOUNDATION_HTTP__ 'NAVFoundation.Http'

#include 'NAVFoundation.Http.h.axi'
#include 'NAVFoundation.ArrayUtils.axi'
#include 'NAVFoundation.StringUtils.axi'


define_function NAVHttpPost(char resource[], char body[]) {
    stack_var _NAVHttpUrl url
    stack_var _NAVHttpRequest req

    NAVHttpParseUrl(resource, url)

    req.Method = NAV_HTTP_METHOD_POST
    req.Body = body

    // Do something with the request
}


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


define_function NAVHttpRequestInit(_NAVHttpRequest req) {
    req.Method = NAV_HTTP_METHOD_GET
    req.Path = NAV_HTTP_PATH_DEFAULT
    req.Version = NAV_HTTP_VERSION_1_1
    req.Host.Address = ''
    req.Body = ''

    req.Headers.Count = 0
}


define_function NAVHttpStatusInit(_NAVHttpStatus status) {
    status.Code = 0
    status.Message = ''
}


define_function NAVHttpResponseInit(_NAVHttpResponse res) {
    NAVHttpStatusInit(res.Status)
    res.Body = ''

    res.Headers.Count = 0
}


define_function NAVHttpHeaderInit(_NAVKeyStringValuePair header, char key[], char value[]) {
    header.Key = NAVStringPascalCase(key)
    header.Value = value
}


define_function char[NAV_MAX_BUFFER] NAVHttpBuildUrl(char protocol[], char host[], char route[]) {
    return "protocol, '://', host, route"
}


define_function integer NAVHttpGetDefaultPort(char scheme[]) {
    switch (scheme) {
        case NAV_HTTP_SCHEME_HTTP: {
            return NAV_HTTP_PORT
        }
        case NAV_HTTP_SCHEME_HTTPS: {
            return NAV_HTTPS_PORT
        }
        default: {
            return NAV_HTTP_PORT
        }
    }
}


define_function char NAVHttpUrlIsRelative(char url[]) {
    return type_cast(NAVStartsWith(url, '/'))
}


define_function char NAVHttpParseUrl(char buffer[], _NAVHttpUrl url) {
    stack_var integer scheme
    stack_var integer path

    if (!length_array(buffer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpParseUrl',
                                    "'URL cannot be empty'")

        return false
    }

    scheme = NAVIndexOf(buffer, NAV_HTTP_SCHEME_TOKEN, 1)

    if (!scheme) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpParseUrl',
                                    "'URL must contain a scheme'")

        return false
    }

    url.Scheme = NAVGetStringBefore(buffer, NAV_HTTP_SCHEME_TOKEN)

    if (!NAVFindInArrayString(NAV_HTTP_SCHEMES, url.Scheme)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpParseUrl',
                                    "'Invalid scheme specified. Defaulting to ', NAV_HTTP_SCHEME_DEFAULT")

        url.Scheme = NAV_HTTP_SCHEME_DEFAULT
    }

    path = NAVIndexOf(buffer, NAV_HTTP_PATH_TOKEN, scheme + length_array(NAV_HTTP_SCHEME_TOKEN))

    if (!path) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpParseUrl',
                                    "'Path not specified. Defaulting to ', NAV_HTTP_PATH_DEFAULT")

        url.Path = NAV_HTTP_PATH_DEFAULT
        url.Host.Address = NAVGetStringAfter(buffer, NAV_HTTP_SCHEME_TOKEN)

        return NAVHttpParseHost(url.Host.Address, url)
    }

    url.Host.Address = NAVGetStringBetween(buffer, NAV_HTTP_SCHEME_TOKEN, NAV_HTTP_PATH_TOKEN)

    if (!NAVHttpParseHost(url.Host.Address, url)) {
        return false
    }

    url.Path = "NAV_HTTP_PATH_TOKEN, NAVGetStringAfter(buffer, NAV_HTTP_PATH_TOKEN)"

    return NAVHttpParsePath(url.Path, url)
}


define_function char NAVHttpParseHost(char buffer[], _NAVHttpUrl url) {
    stack_var integer port

    if (!length_array(buffer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpParseHost',
                                    "'Host cannot be empty'")

        return false
    }

    port = NAVIndexOf(buffer, NAV_HTTP_PORT_TOKEN, 1)

    if (!port) {
        url.Host.Address = buffer
        url.Host.Port = NAVHttpGetDefaultPort(url.Scheme)

        return true
    }

    url.Host.Address = NAVGetStringBefore(buffer, NAV_HTTP_PORT_TOKEN)
    url.Host.Port = atoi(NAVGetStringAfter(buffer, NAV_HTTP_PORT_TOKEN))

    if (!url.Host.Port) {
        url.Host.Port = NAVHttpGetDefaultPort(NAV_HTTP_SCHEME_DEFAULT)
    }

    return true
}


define_function char NAVHttpParsePath(char buffer[], _NAVHttpUrl url) {
    if (!length_array(buffer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpParsePath',
                                    "'Path cannot be empty'")

        return false
    }

    return true
}


define_function NAVHttpRequestAddHeader(_NAVHttpRequest req, char key[], char value[]) {
    _NAVKeyStringValuePair header

    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpRequestAddHeader',
                                    "'Header key cannot be empty'")

        return
    }

    if (!length_array(value)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpRequestAddHeader',
                                    "'Header value cannot be empty'")

        return
    }

    if (!NAVFindInArrayString(NAV_HTTP_HEADERS, key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpRequestAddHeader',
                                    "'Key ', key, ' is not a valid HTTP header'")

        return
    }

    if (NAVHttpHeaderKeyExists(req.Headers, key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpRequestAddHeader',
                                    "'Key ', key, ' already exists'")

        return
    }

    NAVHttpHeaderInit(header, key, value);

    req.Headers.Count++
    req.Headers.Headers[req.Headers.Count] = header
}


define_function NAVHttpResponseAddHeader(_NAVHttpResponse res, char key[], char value[]) {
    _NAVKeyStringValuePair header

    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpRequestAddHeader',
                                    "'Header key cannot be empty'")

        return
    }

    if (!length_array(value)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpRequestAddHeader',
                                    "'Header value cannot be empty'")

        return
    }

    if (!NAVFindInArrayString(NAV_HTTP_HEADERS, key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpRequestAddHeader',
                                    "'Key ', key, ' is not a valid HTTP header'")

        return
    }

    if (NAVHttpHeaderKeyExists(res.Headers, key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpRequestAddHeader',
                                    "'Key ', key, ' already exists'")

        return
    }

    NAVHttpHeaderInit(header, key, value);

    res.Headers.Count++
    res.Headers.Headers[res.Headers.Count] = header
}


define_function char[NAV_MAX_BUFFER] NAVHttpBuildHeaders(_NAVHttpHeader headers) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer x

    result = ''

    for (x = 1; x <= headers.Count; x++) {
        result = "result, headers.Headers[x].Key, ': ', headers.Headers[x].Value, NAV_CR, NAV_LF"
    }

    return result
}


// define_function char[NAV_MAX_BUFFER] NAVHttpBuildResponse(_NAVHttpResponse res) {
//     stack_var char result[NAV_MAX_BUFFER]

//     result = "res.Status.Code, ' ', NAVHttpGetStatusMessage(res.Status.Code), NAV_CR, NAV_LF"
//     result = "result, NAVHttpBuildHeaders(res.Headers), NAV_CR, NAV_LF"

//     if (!length_array(res.Body)) {
//         return result
//     }

//     result = "result, res.Body, NAV_CR, NAV_LF"
//     result = "result, NAV_CR, NAV_LF"

//     return result
// }


define_function char NAVHttpHeaderKeyExists(_NAVHttpHeader headers, char key[]) {
    stack_var integer x

    for (x = 1; x <= headers.Count; x++) {
        if (headers.Headers[x].Key != key) {
            continue
        }

        return true
    }

    return false
}


define_function char[256] NAVHttpGetHeaderValue(_NAVHttpHeader headers, char key[]) {
    stack_var integer x

    if (!NAVHttpHeaderKeyExists(headers, key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpGetHeaderValue',
                                    "'Header key ', key, ' does not exist'")



        return ''
    }

    for (x = 1; x <= headers.Count; x++) {
        if (headers.Headers[x].Key != key) {
            continue
        }

        return headers.Headers[x].Value
    }

    return ''
}


define_function char NAVHttpValidateHeaders(_NAVKeyStringValuePair headers[], integer count) {
    stack_var integer x

    for (x = 1; x <= count; x++) {
        if (!length_array(headers[x].Key)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_HTTP__,
                                        'NAVHttpValidateHeaders',
                                        "'Header key cannot be empty'")

            return false
        }

        if (!length_array(headers[x].Value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_HTTP__,
                                        'NAVHttpValidateHeaders',
                                        "'Header value cannot be empty'")

            return false
        }

        if (!NAVFindInArrayString(NAV_HTTP_HEADERS, headers[x].Key)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_HTTP__,
                                        'NAVHttpValidateHeaders',
                                        "'Key ', headers[x].Key, ' is not a valid HTTP header'")

            return false
        }
    }

    return true
}


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


define_function char[NAV_HTTP_MAX_REQUEST_LENGTH] NAVHttpBuildRequest(_NAVHttpRequest req) {
    char result[NAV_HTTP_MAX_REQUEST_LENGTH]

    result = ''

    if (!NAVHttpValidateHeaders(req.Headers.Headers, req.Headers.Count)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpBuildRequest',
                                    "'Invalid HTTP headers specified'")

        return ''
    }

    if (!length_array(req.Host.Address)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpBuildRequest',
                                    "'No host specified. Defaulting to ', NAV_HTTP_HOST_DEFAULT")

        req.Host.Address = NAV_HTTP_HOST_DEFAULT
    }

    req.Method = upper_string(req.Method)
    if (!NAVFindInArrayString(NAV_HTTP_METHODS, req.Method)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpBuildRequest',
                                    "'No method specified. Defaulting to ', NAV_HTTP_METHOD_DEFAULT")

        req.Method = NAV_HTTP_METHOD_DEFAULT
    }

    if (!length_array(req.Path)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpBuildRequest',
                                    "'No path specified. Defaulting to ', NAV_HTTP_PATH_DEFAULT")

        req.Path = NAV_HTTP_PATH_DEFAULT
    }

    req.Version = upper_string(req.Version)
    if (!NAVFindInArrayString(NAV_HTTP_VERSIONS, req.Version)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_HTTP__,
                                    'NAVHttpBuildRequest',
                                    "'Invalid HTTP version specified. Defaulting to ', NAV_HTTP_VERSION_DEFAULT")

        req.Version = NAV_HTTP_VERSION_DEFAULT
    }

    NAVHttpRequestAddHeader(req, NAV_HTTP_HEADER_HOST, req.Host.Address)

    if (length_array(req.Body)) {
        NAVHttpRequestAddHeader(req, NAV_HTTP_HEADER_CONTENT_LENGTH, itoa(length_array(req.Body)))

        if (!NAVHttpHeaderKeyExists(req.Headers, NAV_HTTP_HEADER_CONTENT_TYPE)) {
            NAVHttpRequestAddHeader(req, NAV_HTTP_HEADER_CONTENT_TYPE, NAVHttpInferContentType(req.Body))
        }
    }

    result = "req.Method, ' ', req.Path, ' ', req.Version, NAV_CR, NAV_LF"
    result = "result, NAVHttpBuildHeaders(req.Headers), NAV_CR, NAV_LF"

    if (!length_array(req.Body)) {
        return result
    }

    result = "result, req.Body, NAV_CR, NAV_LF"
    result = "result, NAV_CR, NAV_LF"

    return result
}


#END_IF // __NAV_FOUNDATION_HTTP__
