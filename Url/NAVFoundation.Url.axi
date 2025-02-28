PROGRAM_NAME='NAVFoundation.Url'

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

/**
 * @file NAVFoundation.Url.axi
 * @brief Implementation for URL manipulation and parsing.
 *
 * This module provides functions to work with URLs, including parsing URLs
 * into their component parts and building URLs from structured data.
 * It supports all standard URL components: scheme, host, port, path,
 * query parameters, and fragments.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_URL__
#DEFINE __NAV_FOUNDATION_URL__ 'NAVFoundation.Url'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Url.h.axi'


/**
 * @function NAVBuildUrl
 * @public
 * @description Builds a complete URL string from a structured URL object.
 *
 * This function takes a populated _NAVUrl structure and converts it into
 * a properly formatted URL string.
 *
 * @param {_NAVUrl} url - The URL structure to convert to a string
 *
 * @returns {char[NAV_MAX_BUFFER]} The complete URL as a string
 *
 * @example
 * stack_var _NAVUrl url
 * stack_var char urlString[NAV_MAX_BUFFER]
 *
 * url.Scheme = 'https'
 * url.Host = 'example.com'
 * url.Port = 8080
 * url.Path = '/api/v1/data'
 * url.Queries[1].Key = 'param1'
 * url.Queries[1].Value = 'value1'
 * url.Fragment = 'section2'
 * set_length_array(url.Queries, 1)
 *
 * urlString = NAVBuildUrl(url)
 * // urlString will be 'https://example.com:8080/api/v1/data?param1=value1#section2'
 *
 * @see NAVParseUrl
 */
define_function char[NAV_MAX_BUFFER] NAVBuildUrl(_NAVUrl url) {
    stack_var char result[NAV_MAX_BUFFER]

    result = ''

    if (url.Scheme) {
        result = "url.Scheme, NAV_URL_SCHEME_TOKEN"
    }

    if (url.Host) {
        result = "result, url.Host"

        if (url.Port) {
            result = "result, NAV_URL_PORT_TOKEN, itoa(url.Port)"
        }
    }

    if (url.Path) {
        if (!NAVStartsWith(url.Path, '/')) {
            result = "result, NAV_URL_PATH_TOKEN"
        }

        result = "result, url.Path"
    }

    if (length_array(url.Queries)) {
        stack_var integer x

        for (x = 1; x <= length_array(url.Queries); x++) {
            if (x == 1) {
                result = "result, NAV_URL_QUERY_TOKEN"
            }
            else {
                result = "result, '&'"
            }

            result = "result, url.Queries[x].Key, '=', url.Queries[x].Value"
        }
    }

    if (url.Fragment) {
        result = "result, NAV_URL_FRAGMENT_TOKEN, url.Fragment"
    }

    return result
}


/**
 * @function NAVParseUrl
 * @public
 * @description Parses a URL string into a structured _NAVUrl object.
 *
 * This function breaks down a URL into its component parts: scheme, host,
 * port, path, query parameters, and fragment.
 *
 * @param {char[]} buffer - The URL string to parse
 * @param {_NAVUrl} url - The URL structure to populate with parsed data
 *
 * @returns {char} TRUE if parsing was successful, FALSE otherwise
 *
 * @example
 * stack_var char urlString[NAV_MAX_BUFFER]
 * stack_var _NAVUrl parsedUrl
 * stack_var char success
 *
 * urlString = 'https://example.com:8080/path/to/resource?param=value#section'
 * success = NAVParseUrl(urlString, parsedUrl)
 *
 * // If successful, parsedUrl will contain:
 * // parsedUrl.Scheme = 'https'
 * // parsedUrl.Host = 'example.com'
 * // parsedUrl.Port = 8080
 * // parsedUrl.Path = '/path/to/resource'
 * // parsedUrl.Queries[1].Key = 'param'
 * // parsedUrl.Queries[1].Value = 'value'
 * // parsedUrl.Fragment = 'section'
 *
 * @see NAVBuildUrl
 * @see NAVParseQueryString
 */
define_function char NAVParseUrl(char buffer[], _NAVUrl url) {
    stack_var integer scheme
    stack_var integer host
    stack_var integer port
    stack_var integer path
    stack_var integer query
    stack_var integer fragment

    stack_var integer hostEnd

    stack_var integer length

    length = length_array(buffer)

    if (!length) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_URL__,
                                    'NAVParseUrl',
                                    "'Buffer is empty'")

        return false
    }

    scheme = NAVIndexOf(buffer, NAV_URL_SCHEME_TOKEN, 1)

    if (scheme) {
        url.Scheme = NAVGetStringBefore(buffer, NAV_URL_SCHEME_TOKEN)
    }
    else {
        url.Scheme = ''
    }

    host = scheme + 3

    port = NAVIndexOf(buffer, NAV_URL_PORT_TOKEN, host)
    path = NAVIndexOf(buffer, NAV_URL_PATH_TOKEN, host)
    query = NAVIndexOf(buffer, NAV_URL_QUERY_TOKEN, host)
    fragment = NAVIndexOf(buffer, NAV_URL_FRAGMENT_TOKEN, host)

    hostEnd = path

    if (!hostEnd || (port && port < hostEnd)) {
        hostEnd = port
    }

    if (!hostEnd || (query && query < hostEnd)) {
        hostEnd = query
    }

    if (!hostEnd || (fragment && fragment < hostEnd)) {
        hostEnd = fragment
    }

    if (!hostEnd) {
        url.Host = NAVStringSubstring(buffer, host, (length - host) + 1)
        return true
    }
    else {
        url.Host = NAVStringSubstring(buffer, host, (hostEnd - host))
    }

    if (port && (!path || port < path)) {
        stack_var integer portStart
        stack_var integer portEnd

        select {
            active (path && path > port): {
                portEnd = path - 1
            }
            active (query && query > port): {
                portEnd = query - 1
            }
            active (fragment && fragment > port): {
                portEnd = fragment - 1
            }
            active (true): {
                portEnd = length
            }
        }

        url.Port = atoi(NAVStringSubstring(buffer, port + 1, portEnd - port))
    }
    else {
        url.Port = 0
    }

    if (path) {
        stack_var integer pathEnd

        url.FullPath = NAVStringSubstring(buffer, path, (length - path) + 1)

        select {
            active (query && query > path): {
                pathEnd = query - 1
            }
            active (fragment && fragment > path): {
                pathEnd = fragment - 1
            }
            active (true): {
                pathEnd = length
            }
        }

        url.Path = NAVStringSubstring(buffer, path, (pathEnd - path) + 1)
    }

    if (query) {
        stack_var char queries[1024]

        if (fragment && fragment > query) {
            queries = NAVStringSubstring(buffer, query + 1, fragment - query - 1)
        }
        else {
            queries = NAVStringSubstring(buffer, query + 1, length - query)
        }

        NAVParseQueryString(queries, url.Queries)
    }

    if (fragment) {
        url.Fragment = right_string(buffer, length - fragment)
    }

    return true
}


/**
 * @function NAVParseQueryString
 * @internal
 * @description Parses a query string into key-value pairs.
 *
 * This function takes a query string (without the leading '?')
 * and splits it into an array of key-value pairs.
 *
 * @param {char[]} buffer - The query string to parse (without '?')
 * @param {_NAVKeyStringValuePair[]} queries - Array to populate with parsed query parameters
 *
 * @returns {void}
 *
 * @example
 * stack_var char queryString[100]
 * stack_var _NAVKeyStringValuePair queries[NAV_URL_MAX_QUERIES]
 *
 * queryString = 'param1=value1&param2=value2&param3='
 * NAVParseQueryString(queryString, queries)
 * // queries will contain:
 * // queries[1].Key = 'param1', queries[1].Value = 'value1'
 * // queries[2].Key = 'param2', queries[2].Value = 'value2'
 * // queries[3].Key = 'param3', queries[3].Value = ''
 *
 * @note This function is used internally by NAVParseUrl
 * @see NAVParseUrl
 */
define_function NAVParseQueryString(char buffer[], _NAVKeyStringValuePair queries[]) {
    stack_var integer x
    stack_var char pairs[NAV_URL_MAX_QUERIES][255]
    stack_var integer count

    count = NAVSplitString(buffer, '&', pairs)

    if (count <= 0) {
        return
    }

    for (x = 1; x <= count; x++) {
        stack_var integer index

        index = NAVIndexOf(pairs[x], '=', 1)

        if (index) {
            queries[x].Key = NAVStringSubstring(pairs[x], 1, index - 1)
            queries[x].Value = NAVStringSubstring(pairs[x], index + 1, length_array(pairs[x]) - index)
        }
        else {
            queries[x].Key = pairs[x]
            queries[x].Value = ''
        }
    }

    set_length_array(queries, count)
}


#END_IF // __NAV_FOUNDATION_URL__
