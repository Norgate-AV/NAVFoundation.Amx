PROGRAM_NAME='NAVFoundation.Url.h'

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
 * @file NAVFoundation.Url.h.axi
 * @brief Header file for URL manipulation and parsing.
 *
 * This header defines constants and data structures for working with URLs,
 * including schemes, tokens, and the URL structure used for parsing and building.
 * URLs can include scheme, host, port, path, query parameters, and fragments.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_URL_H__
#DEFINE __NAV_FOUNDATION_URL_H__ 'NAVFoundation.Url.h'


DEFINE_CONSTANT

/**
 * @constant NAV_URL_SCHEME_*
 * @description Standard URL schemes for various protocols.
 */
constant char NAV_URL_SCHEME_HTTP[]      = 'http'
constant char NAV_URL_SCHEME_HTTPS[]     = 'https'
constant char NAV_URL_SCHEME_FTP[]       = 'ftp'
constant char NAV_URL_SCHEME_SFTP[]      = 'sftp'
constant char NAV_URL_SCHEME_FILE[]      = 'file'
constant char NAV_URL_SCHEME_MAILTO[]    = 'mailto'
constant char NAV_URL_SCHEME_RTSP[]      = 'rtsp'
constant char NAV_URL_SCHEME_RTSPS[]     = 'rtsps'
constant char NAV_URL_SCHEME_WS[]        = 'ws'
constant char NAV_URL_SCHEME_WSS[]       = 'wss'
constant char NAV_URL_SCHEME_S3[]        = 's3'

/**
 * @constant NAV_URL_*_TOKEN
 * @description Delimiter tokens for URL components.
 */
constant char NAV_URL_SCHEME_TOKEN[]     = '://'
constant char NAV_URL_PORT_TOKEN[]       = ':'
constant char NAV_URL_PATH_TOKEN[]       = '/'
constant char NAV_URL_QUERY_TOKEN[]      = '?'
constant char NAV_URL_FRAGMENT_TOKEN[]   = '#'

/**
 * @constant NAV_MAX_URL_SCHEME
 * @description Maximum length for URL scheme strings.
 * This matches the size of the Scheme field in _NAVUrl structure.
 */
constant integer NAV_MAX_URL_SCHEME      = 16

/**
 * @constant NAV_URL_DEFAULT_PORT_*
 * @description Default ports for standard URL schemes per RFC 3986 Section 6.2.3.
 * When a URL uses the default port for its scheme, the port should be omitted
 * during normalization for canonical form.
 */
constant integer NAV_URL_DEFAULT_PORT_HTTP       = 80
constant integer NAV_URL_DEFAULT_PORT_HTTPS      = 443
constant integer NAV_URL_DEFAULT_PORT_FTP        = 21
constant integer NAV_URL_DEFAULT_PORT_SFTP       = 22
constant integer NAV_URL_DEFAULT_PORT_RTSP       = 554
constant integer NAV_URL_DEFAULT_PORT_RTSPS      = 322
constant integer NAV_URL_DEFAULT_PORT_WS         = 80
constant integer NAV_URL_DEFAULT_PORT_WSS        = 443

/**
 * @constant NAV_URL_MAX_QUERIES
 * @description Maximum number of query parameters supported in a URL.
 */
constant integer NAV_URL_MAX_QUERIES      = 30


DEFINE_TYPE

/**
 * @struct _NAVUrlUserInfo
 * @description Structure for holding URL userinfo (username and password).
 *
 * This structure stores the username and password extracted from URL userinfo
 * component (e.g., "username:password@" in "http://username:password@example.com").
 *
 * @warning Per RFC 2396, passing authentication information in clear text URLs
 *          is NOT RECOMMENDED as it poses security risks. This functionality
 *          should only be used with legacy systems.
 *
 * @property {char[128]} Username - The username portion of userinfo
 * @property {char[128]} Password - The password portion of userinfo
 *
 * @see _NAVUrl
 * @see NAVParseUrl
 */
struct _NAVUrlUserInfo {
    char Username[128];
    char Password[128];
}

/**
 * @struct _NAVUrl
 * @description Structure for holding parsed URL components.
 *
 * This structure stores all parts of a parsed URL, including scheme, host, port,
 * path, query parameters, and fragment.
 *
 * @property {char[16]} Scheme - The URL scheme (http, https, etc.)
 * @property {_NAVUrlUserInfo} UserInfo - The username and password from URL
 * @property {char} HasUserInfo - Boolean flag indicating if userinfo is present
 * @property {char[512]} Host - The hostname or IP address
 * @property {integer} Port - The port number, or 0 if not specified
 * @property {char[256]} Path - The URL path without query or fragment
 * @property {char[1024]} FullPath - The complete path including query and fragment
 * @property {_NAVKeyStringValuePair[]} Queries - Array of query parameters
 * @property {char[256]} Fragment - The fragment identifier (after #)
 *
 * @see NAVParseUrl
 * @see NAVBuildUrl
 */
struct _NAVUrl {
    char Scheme[16];
    _NAVUrlUserInfo UserInfo;
    char HasUserInfo;
    char Host[512];
    integer Port;
    char Path[256];
    char FullPath[1024];
    _NAVKeyStringValuePair Queries[NAV_URL_MAX_QUERIES];
    char Fragment[256];
}


#END_IF // __NAV_FOUNDATION_URL_H__
