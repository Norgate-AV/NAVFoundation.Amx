PROGRAM_NAME='NAVFoundation.HttpUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_HTTPUTILS__
#DEFINE __NAV_FOUNDATION_HTTPUTILS__ 'NAVFoundation.HttpUtils'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.HttpUtils.h.axi'
#include 'NAVFoundation.ArrayUtils.axi'
#include 'NAVFoundation.Url.axi'


define_function char NAVHttpRequestInit(_NAVHttpRequest req,
                                        char method[],
                                        _NAVUrl url,
                                        char body[]) {
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


define_function NAVHttpStatusInit(_NAVHttpStatus status) {
    status.Code = 0
    status.Message = ''
}


define_function NAVHttpResponseInit(_NAVHttpResponse res) {
    NAVHttpStatusInit(res.Status)
    res.Body = ''

    res.Headers.Count = 0
}


define_function NAVHttpHeaderInit(_NAVKeyStringValuePair header,
                                    char key[],
                                    char value[]) {
    header.Key = NAVStringTrainCase(key)
    header.Value = value
}


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
                                        "'Invalid scheme "', url.Scheme,'" specified. Defaulting to ', NAV_URL_SCHEME_HTTP")

            url.Scheme = NAV_URL_SCHEME_HTTP
        }
    }

    return true
}


define_function char NAVHttpRequestAddHeader(_NAVHttpRequest req,
                                            char key[],
                                            char value[]) {
    _NAVKeyStringValuePair header

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
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HTTPUTILS__,
                                    'NAVHttpRequestAddHeader',
                                    "'Key ', key, ' is not a valid HTTP header'")

        return false
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

    if (!NAVFindInArrayString(NAV_HTTP_HEADERS, key)) {
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


define_function char NAVHttpResponseAddHeader(_NAVHttpResponse res,
                                                char key[],
                                                char value[]) {
    _NAVKeyStringValuePair header

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
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
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

    if (!NAVFindInArrayString(NAV_HTTP_HEADERS, key)) {
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


define_function char[NAV_MAX_BUFFER] NAVHttpBuildHeaders(_NAVHttpHeader headers) {
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


define_function integer NAVHttpFindHeader(_NAVHttpHeader headers, char key[]) {
    stack_var integer x

    for (x = 1; x <= headers.Count; x++) {
        if (headers.Headers[x].Key != key) {
            continue
        }

        return x
    }

    return 0
}


define_function char NAVHttpHeaderKeyExists(_NAVHttpHeader headers, char key[]) {
    return NAVHttpFindHeader(headers, key) > 0
}


define_function char[256] NAVHttpGetHeaderValue(_NAVHttpHeader headers, char key[]) {
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


define_function char NAVHttpValidateHeaders(_NAVHttpHeader headers) {
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

        if (!NAVFindInArrayString(NAV_HTTP_HEADERS, headers.Headers[x].Key)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_HTTPUTILS__,
                                        'NAVHttpValidateHeaders',
                                        "'Key ', headers.Headers[x].Key, ' is not a valid HTTP header'")

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


// define_function char NAVHttpParseResponse(char buffer[], _NAVHttpResponse res) {
//     stack_var integer x
//     stack_var char status[NAV_MAX_CHARS]
//     stack_var char message[NAV_MAX_CHARS]
//     stack_var char headers[NAV_MAX_BUFFER]
//     stack_var char body[NAV_MAX_BUFFER]

//     if (!length_array(buffer)) {
//         return false
//     }

//     if (!NAVHttpParseStatus(buffer, res.Status)) {
//         NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
//                                     __NAV_FOUNDATION_HTTPUTILS__,
//                                     'NAVHttpParseResponse',
//                                     "'Failed to parse status line'")

//         return false
//     }

//     if (!NAVHttpParseHeaders(buffer, res.Headers)) {
//         NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
//                                     __NAV_FOUNDATION_HTTPUTILS__,
//                                     'NAVHttpParseResponse',
//                                     "'Failed to parse headers'")

//         return false
//     }

//     if (!NAVHttpParseBody(buffer, res.Body)) {
//         NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
//                                     __NAV_FOUNDATION_HTTPUTILS__,
//                                     'NAVHttpParseResponse',
//                                     "'Failed to parse body'")

//         return false
//     }

//     return true
// }


#END_IF // __NAV_FOUNDATION_HTTPUTILS__
