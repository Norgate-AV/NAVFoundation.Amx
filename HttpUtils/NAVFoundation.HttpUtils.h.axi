PROGRAM_NAME='NAVFoundation.Http.h'

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
 * @file NAVFoundation.HttpUtils.h.axi
 * @brief Header file for HTTP protocol utilities.
 *
 * This header defines constants and data structures for working with HTTP protocol,
 * including request and response handling, headers, status codes, content types,
 * and other HTTP-related operations.
 *
 * These utilities support standard HTTP operations in compliance with HTTP/1.0 and HTTP/1.1
 * specifications and can be used for building HTTP clients and simple servers.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_HTTPUTILS_H__
#DEFINE __NAV_FOUNDATION_HTTPUTILS_H__ 'NAVFoundation.HttpUtils.h'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Url.h.axi'


/*
    GET / HTTP/1.1\r\n
    Host: localhost\r\n

    HTTP/1.1 200 OK\r\n
    Content-Type: text/html\r\n
    Content-Length: 13\r\n
    \r\n
    Hello, World!
*/


DEFINE_CONSTANT

/**
 * @constant NAV_HTTP_HOST_DEFAULT
 * @description Default hostname used when none is specified
 */
constant char NAV_HTTP_HOST_DEFAULT[]       = 'localhost'

/**
 * @constant NAV_HTTP_PATH_DEFAULT
 * @description Default path used when none is specified
 */
constant char NAV_HTTP_PATH_DEFAULT[]      = '/'

/**
 * @constant NAV_HTTP_SCHEMES
 * @description Supported HTTP URL schemes
 */
constant char NAV_HTTP_SCHEMES[][20]  =   {
                                            'http',
                                            'https'
                                        }

/**
 * @constant NAV_HTTP_MAX_REQUEST_LENGTH
 * @description Maximum allowed length for HTTP request
 */
constant integer NAV_HTTP_MAX_REQUEST_LENGTH    = 4096

/**
 * @constant NAV_HTTP_MAX_RESPONSE_LENGTH
 * @description Maximum allowed length for HTTP response
 */
constant integer NAV_HTTP_MAX_RESPONSE_LENGTH   = 16384

/**
 * @constant NAV_HTTP_METHOD_*
 * @description Standard HTTP request methods
 */
NAV_HTTP_METHOD_CONNECT  = 'CONNECT'
NAV_HTTP_METHOD_DELETE   = 'DELETE'
NAV_HTTP_METHOD_GET      = 'GET'
NAV_HTTP_METHOD_HEAD     = 'HEAD'
NAV_HTTP_METHOD_OPTIONS   = 'OPTIONS'
NAV_HTTP_METHOD_PATCH    = 'PATCH'
NAV_HTTP_METHOD_POST     = 'POST'
NAV_HTTP_METHOD_PUT      = 'PUT'
NAV_HTTP_METHOD_TRACE    = 'TRACE'

/**
 * @constant NAV_HTTP_METHODS
 * @description Array of all supported HTTP methods
 */
constant char NAV_HTTP_METHODS[][20]=  {
                                            'CONNECT',
                                            'DELETE',
                                            'GET',
                                            'HEAD',
                                            'OPTIONS',
                                            'PATCH',
                                            'POST',
                                            'PUT',
                                            'TRACE'
                                        }

/**
 * @constant NAV_HTTP_VERSION_*
 * @description HTTP protocol versions
 */
constant char NAV_HTTP_VERSION_1_0[]    = 'HTTP/1.0'
constant char NAV_HTTP_VERSION_1_1[]    = 'HTTP/1.1'
constant char NAV_HTTP_VERSION_2_0[]    = 'HTTP/2.0'

/**
 * @constant NAV_HTTP_VERSIONS
 * @description Array of supported HTTP versions
 */
constant char NAV_HTTP_VERSIONS[][20]   =   {
                                                'HTTP/1.0',
                                                'HTTP/1.1',
                                                'HTTP/2.0'
                                            }


constant integer NAV_HTTP_STATUS_CODE_INFO_CONTINUE             = 100
constant integer NAV_HTTP_STATUS_CODE_INFO_SWITCHING_PROTOCOLS  = 101
constant integer NAV_HTTP_STATUS_CODE_INFO_PROCESSING           = 102
constant integer NAV_HTTP_STATUS_CODE_INFO_EARLY_HINTS          = 103

constant char NAV_HTTP_STATUS_MESSAGE_INFO_CONTINUE[]             = 'Continue'
constant char NAV_HTTP_STATUS_MESSAGE_INFO_SWITCHING_PROTOCOLS[]  = 'Switching Protocols'
constant char NAV_HTTP_STATUS_MESSAGE_INFO_PROCESSING[]           = 'Processing'
constant char NAV_HTTP_STATUS_MESSAGE_INFO_EARLY_HINTS[]          = 'Early Hints'


constant integer NAV_HTTP_STATUS_CODE_SUCCESS_OK                        = 200
constant integer NAV_HTTP_STATUS_CODE_SUCCESS_CREATED                   = 201
constant integer NAV_HTTP_STATUS_CODE_SUCCESS_ACCEPTED                  = 202
constant integer NAV_HTTP_STATUS_CODE_SUCCESS_NON_AUTHORITATIVE_INFO    = 203
constant integer NAV_HTTP_STATUS_CODE_SUCCESS_NO_CONTENT                = 204
constant integer NAV_HTTP_STATUS_CODE_SUCCESS_RESET_CONTENT             = 205
constant integer NAV_HTTP_STATUS_CODE_SUCCESS_PARTIAL_CONTENT           = 206
constant integer NAV_HTTP_STATUS_CODE_SUCCESS_MULTI_STATUS              = 207
constant integer NAV_HTTP_STATUS_CODE_SUCCESS_ALREADY_REPORTED          = 208
constant integer NAV_HTTP_STATUS_CODE_SUCCESS_IM_USED                   = 209

constant char NAV_HTTP_STATUS_MESSAGE_SUCCESS_OK[]                        = 'OK'
constant char NAV_HTTP_STATUS_MESSAGE_SUCCESS_CREATED[]                   = 'Created'
constant char NAV_HTTP_STATUS_MESSAGE_SUCCESS_ACCEPTED[]                  = 'Accepted'
constant char NAV_HTTP_STATUS_MESSAGE_SUCCESS_NON_AUTHORITATIVE_INFO[]    = 'Non-Authoritative Information'
constant char NAV_HTTP_STATUS_MESSAGE_SUCCESS_NO_CONTENT[]                = 'No Content'
constant char NAV_HTTP_STATUS_MESSAGE_SUCCESS_RESET_CONTENT[]             = 'Reset Content'
constant char NAV_HTTP_STATUS_MESSAGE_SUCCESS_PARTIAL_CONTENT[]           = 'Partial Content'
constant char NAV_HTTP_STATUS_MESSAGE_SUCCESS_MULTI_STATUS[]              = 'Multi-Status'
constant char NAV_HTTP_STATUS_MESSAGE_SUCCESS_ALREADY_REPORTED[]          = 'Already Reported'
constant char NAV_HTTP_STATUS_MESSAGE_SUCCESS_IM_USED[]                   = 'IM Used'


constant integer NAV_HTTP_STATUS_CODE_REDIRECT_MULTIPLE_CHOICES     = 300
constant integer NAV_HTTP_STATUS_CODE_REDIRECT_MOVED_PERMANENTLY    = 301
constant integer NAV_HTTP_STATUS_CODE_REDIRECT_FOUND                = 302
constant integer NAV_HTTP_STATUS_CODE_REDIRECT_SEE_OTHER            = 303
constant integer NAV_HTTP_STATUS_CODE_REDIRECT_NOT_MODIFIED         = 304
constant integer NAV_HTTP_STATUS_CODE_REDIRECT_USE_PROXY            = 305
constant integer NAV_HTTP_STATUS_CODE_REDIRECT_UNUSED               = 306
constant integer NAV_HTTP_STATUS_CODE_REDIRECT_TEMPORARY_REDIRECT   = 307
constant integer NAV_HTTP_STATUS_CODE_REDIRECT_PERMANENT_REDIRECT   = 308

constant char NAV_HTTP_STATUS_MESSAGE_REDIRECT_MULTIPLE_CHOICES[]     = 'Multiple Choices'
constant char NAV_HTTP_STATUS_MESSAGE_REDIRECT_MOVED_PERMANENTLY[]    = 'Moved Permanently'
constant char NAV_HTTP_STATUS_MESSAGE_REDIRECT_FOUND[]                = 'Found'
constant char NAV_HTTP_STATUS_MESSAGE_REDIRECT_SEE_OTHER[]            = 'See Other'
constant char NAV_HTTP_STATUS_MESSAGE_REDIRECT_NOT_MODIFIED[]         = 'Not Modified'
constant char NAV_HTTP_STATUS_MESSAGE_REDIRECT_USE_PROXY[]            = 'Use Proxy'
constant char NAV_HTTP_STATUS_MESSAGE_REDIRECT_UNUSED[]               = '(Unused)'
constant char NAV_HTTP_STATUS_MESSAGE_REDIRECT_TEMPORARY_REDIRECT[]   = 'Temporary Redirect'
constant char NAV_HTTP_STATUS_MESSAGE_REDIRECT_PERMANENT_REDIRECT[]   = 'Permanent Redirect'


constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_BAD_REQUEST                      = 400
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_UNAUTHORIZED                     = 401
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_PAYMENT_REQUIRED                 = 402
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_FORBIDDEN                        = 403
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_NOT_FOUND                        = 404
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_METHOD_NOT_ALLOWED               = 405
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_NOT_ACCEPTABLE                   = 406
// constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_PROXY_AUTHENTICATION_REQUIRED    = 407
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_REQUEST_TIMEOUT                  = 408
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_CONFLICT                         = 409
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_GONE                             = 410
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_LENGTH_REQUIRED                  = 411
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_PRECONDITION_FAILED              = 412
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_PAYLOAD_TOO_LARGE                = 413
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_URI_TOO_LONG                     = 414
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_UNSUPPORTED_MEDIA_TYPE           = 415
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_RANGE_NOT_SATISFIABLE            = 416
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_EXPECTATION_FAILED               = 417
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_IM_A_TEAPOT                      = 418
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_MISDIRECTED_REQUEST              = 421
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_UNPROCESSABLE_CONTENT            = 422
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_LOCKED                           = 423
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_FAILED_DEPENDENCY                = 424
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_TOO_EARLY                        = 425
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_UPGRADE_REQUIRED                 = 426
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_PRECONDITION_REQUIRED            = 428
constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_TOO_MANY_REQUESTS                = 429
// constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_REQUEST_HEADER_FIELDS_TOO_LARGE  = 431
// constant integer NAV_HTTP_STATUS_CODE_CLIENT_ERROR_UNAVAILABLE_FOR_LEGAL_REASONS    = 451

constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_BAD_REQUEST[]                      = 'Bad Request'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_UNAUTHORIZED[]                     = 'Unauthorized'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_PAYMENT_REQUIRED[]                 = 'Payment Required'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_FORBIDDEN[]                        = 'Forbidden'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_NOT_FOUND[]                        = 'Not Found'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_METHOD_NOT_ALLOWED[]               = 'Method Not Allowed'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_NOT_ACCEPTABLE[]                   = 'Not Acceptable'
// constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_PROXY_AUTHENTICATION_REQUIRED[]    = 'Proxy Authentication Required'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_REQUEST_TIMEOUT[]                  = 'Request Timeout'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_CONFLICT[]                         = 'Conflict'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_GONE[]                             = 'Gone'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_LENGTH_REQUIRED[]                  = 'Length Required'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_PRECONDITION_FAILED[]              = 'Precondition Failed'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_PAYLOAD_TOO_LARGE[]                = 'Payload Too Large'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_URI_TOO_LONG[]                     = 'URI Too Long'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_UNSUPPORTED_MEDIA_TYPE[]           = 'Unsupported Media Type'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_RANGE_NOT_SATISFIABLE[]            = 'Range Not Satisfiable'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_EXPECTATION_FAILED[]               = 'Expectation Failed'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_IM_A_TEAPOT[]                      = 'I''m a teapot'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_MISDIRECTED_REQUEST[]              = 'Misdirected Request'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_UNPROCESSABLE_CONTENT[]            = 'Unprocessable Content'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_LOCKED[]                           = 'Locked'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_FAILED_DEPENDENCY[]                = 'Failed Dependency'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_TOO_EARLY[]                        = 'Too Early'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_UPGRADE_REQUIRED[]                 = 'Upgrade Required'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_PRECONDITION_REQUIRED[]            = 'Precondition Required'
constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_TOO_MANY_REQUESTS[]                = 'Too Many Requests'
// constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_REQUEST_HEADER_FIELDS_TOO_LARGE[]  = 'Request Header Fields Too Large'
// constant char NAV_HTTP_STATUS_MESSAGE_CLIENT_ERROR_UNAVAILABLE_FOR_LEGAL_REASONS[]    = 'Unavailable For Legal Reasons'


constant integer NAV_HTTP_STATUS_CODE_SERVER_ERROR_SERVER_ERROR                     = 500
constant integer NAV_HTTP_STATUS_CODE_SERVER_ERROR_NOT_IMPLEMENTED                  = 501
constant integer NAV_HTTP_STATUS_CODE_SERVER_ERROR_BAD_GATEWAY                      = 502
constant integer NAV_HTTP_STATUS_CODE_SERVER_ERROR_SERVICE_UNAVAILABLE              = 503
constant integer NAV_HTTP_STATUS_CODE_SERVER_ERROR_SERVER_TIMEOUT                   = 504
constant integer NAV_HTTP_STATUS_CODE_SERVER_ERROR_VERSION_NOT_SUPPORTED            = 505
constant integer NAV_HTTP_STATUS_CODE_SERVER_ERROR_VARIANT_ALSO_NEGOTIATES          = 506
constant integer NAV_HTTP_STATUS_CODE_SERVER_ERROR_INSUFFICIENT_STORAGE             = 507
constant integer NAV_HTTP_STATUS_CODE_SERVER_ERROR_LOOP_DETECTED                    = 508
constant integer NAV_HTTP_STATUS_CODE_SERVER_ERROR_NOT_EXTENDED                     = 510
// constant integer NAV_HTTP_STATUS_CODE_SERVER_ERROR_NETWORK_AUTHENTICATION_REQUIRED  = 511

constant char NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_SERVER_ERROR[]                     = 'Server Error'
constant char NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_NOT_IMPLEMENTED[]                  = 'Not Implemented'
constant char NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_BAD_GATEWAY[]                      = 'Bad Gateway'
constant char NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_SERVICE_UNAVAILABLE[]              = 'Service Unavailable'
constant char NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_SERVER_TIMEOUT[]                   = 'Server Timeout'
constant char NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_VERSION_NOT_SUPPORTED[]            = 'Version Not Supported'
constant char NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_VARIANT_ALSO_NEGOTIATES[]          = 'Variant Also Negotiates'
constant char NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_INSUFFICIENT_STORAGE[]             = 'Insufficient Storage'
constant char NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_LOOP_DETECTED[]                    = 'Loop Detected'
constant char NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_NOT_EXTENDED[]                     = 'Not Extended'
// constant char NAV_HTTP_STATUS_MESSAGE_SERVER_ERROR_NETWORK_AUTHENTICATION_REQUIRED[]  = 'Network Authentication Required'

constant char NAV_HTTP_STATUS_MESSAGE_UNKNOWN[]                                         = 'Unknown Error'


constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_1D_INTERLEAVED_PARTYFEC[] = 'application/1d-interleaved-parityfec'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_3GPDASH_QOE_REPORT_XML[]  = 'application/3gpdash-qoe-report+xml'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_3GPPHAL_JSON[]            = 'application/3gppHal+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_3GPPHALFORMS_JSON[]        = 'application/3gppHalForms+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_3GPP_IMS_XML[]            = 'application/3gpp-ims+xml'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_A2L[]                     = 'application/A2L'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACE_CBOR[]       = 'application/ace+cbor'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACE_JSON[]                 = 'application/ace+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACTIVE_MESSAGE[]                = 'application/activemessage'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACTIVITY_JSON[]              = 'application/activity+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_AIF_CBOR[]       = 'application/aif+cbor'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_AIF_JSON[]       = 'application/aif+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_CDNI_JSON[]         = 'application/alto-cdni+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_CDNIFILTER_JSON[]         = 'application/alto-cdnifilter+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_COSTMAP_JSON[]         = 'application/alto-costmap+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_COSTMAPFILTER_JSON[]         = 'application/alto-costmapfilter+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_DIRECTORY_JSON[]         = 'application/alto-directory+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_ENDPOINTPROP_JSON[]         = 'application/alto-endpointprop+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_ENDPOINTPROPPARAMS_JSON[]         = 'application/alto-endpointpropparams+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_ENDPOINTCOST_JSON[]         = 'application/alto-endpointcost+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_ENDPOINTCOSTPARAMS_JSON[]         = 'application/alto-endpointcostparams+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_ERROR_JSON[]         = 'application/alto-error+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_NETWORKMAPFILTER_JSON[]         = 'application/alto-networkmapfilter+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_NETWORKMAP_JSON[]         = 'application/alto-networkmap+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_PROPMAP_JSON[]         = 'application/alto-propmap+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_PROPMAPPARAMS_JSON[]         = 'application/alto-propmapparams+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_UPDATESTREAMCONTROL_JSON[]         = 'application/alto-updatestreamcontrol+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ALTO_UPDATESTREAMPARAMS_JSON[]         = 'application/alto-updatestreamparams+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_AML[]                     = 'application/AML'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ANDREW_INSET[]            = 'application/andrew-inset'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_APPLEFILE[]                     = 'application/applefile'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_AT_JWT[]                  = 'application/at+jwt'


constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACCDET[]                  = 'application/accdet'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACES[]                    = 'application/aces'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACE_AUTHZ_JSON[]          = 'application/ace+authz+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACE_AUTHZ_REQ_JSON[]      = 'application/ace+authz-req+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACE_CND_JSON[]            = 'application/ace+cnd+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACE_ERROR_JSON[]          = 'application/ace+error+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACE_PATCH_JSON[]          = 'application/ace+patch+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACE_QUERY_JSON[]          = 'application/ace+query+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACE_QUERY_REQ_JSON[]      = 'application/ace+query-req+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACE_UPDATE_JSON[]         = 'application/ace+update+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACE_UPDATE_REQ_JSON[]     = 'application/ace+update-req+json'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ACME_JSON[]               = 'application/acme+json'


constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_JSON[]     = 'application/json'
constant char NAV_HTTP_CONTENT_TYPE_TEXT_PLAIN[]           = 'text/plain'
constant char NAV_HTTP_CONTENT_TYPE_TEXT_HTML[]            = 'text/html'
constant char NAV_HTTP_CONTENT_TYPE_TEXT_CSV[]             = 'text/csv'
constant char NAV_HTTP_CONTENT_TYPE_TEXT_XML[]             = 'text/xml'


constant char NAV_HTTP_CONTENT_TYPE_FONT_COLLECTION[]       = 'font/collection'
constant char NAV_HTTP_CONTENT_TYPE_FONT_OTF[]             = 'font/otf'
constant char NAV_HTTP_CONTENT_TYPE_FONT_SFNT[]            = 'font/sfnt'
constant char NAV_HTTP_CONTENT_TYPE_FONT_TTF[]             = 'font/ttf'
constant char NAV_HTTP_CONTENT_TYPE_FONT_WOFF[]            = 'font/woff'
constant char NAV_HTTP_CONTENT_TYPE_FONT_WOFF2[]           = 'font/woff2'


// Additional Content Types
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_OCTET_STREAM[]    = 'application/octet-stream'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_PDF[]             = 'application/pdf'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_X_WWW_FORM_URLENCODED[] = 'application/x-www-form-urlencoded'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_FORM_DATA[]       = 'application/form-data'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_ZIP[]             = 'application/zip'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_XML[]             = 'application/xml'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_JAVASCRIPT[]      = 'application/javascript'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_GRAPHQL[]         = 'application/graphql'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_MSGPACK[]         = 'application/msgpack'
constant char NAV_HTTP_CONTENT_TYPE_APPLICATION_PROTOBUF[]        = 'application/protobuf'

// Image Content Types
constant char NAV_HTTP_CONTENT_TYPE_IMAGE_GIF[]                   = 'image/gif'
constant char NAV_HTTP_CONTENT_TYPE_IMAGE_JPEG[]                  = 'image/jpeg'
constant char NAV_HTTP_CONTENT_TYPE_IMAGE_PNG[]                   = 'image/png'
constant char NAV_HTTP_CONTENT_TYPE_IMAGE_SVG_XML[]              = 'image/svg+xml'
constant char NAV_HTTP_CONTENT_TYPE_IMAGE_WEBP[]                 = 'image/webp'
constant char NAV_HTTP_CONTENT_TYPE_IMAGE_BMP[]                  = 'image/bmp'
constant char NAV_HTTP_CONTENT_TYPE_IMAGE_X_ICON[]              = 'image/x-icon'
constant char NAV_HTTP_CONTENT_TYPE_IMAGE_TIFF[]                = 'image/tiff'

// Audio Content Types
constant char NAV_HTTP_CONTENT_TYPE_AUDIO_MPEG[]                = 'audio/mpeg'
constant char NAV_HTTP_CONTENT_TYPE_AUDIO_OGG[]                 = 'audio/ogg'
constant char NAV_HTTP_CONTENT_TYPE_AUDIO_WAV[]                 = 'audio/wav'
constant char NAV_HTTP_CONTENT_TYPE_AUDIO_WEBM[]                = 'audio/webm'
constant char NAV_HTTP_CONTENT_TYPE_AUDIO_AAC[]                 = 'audio/aac'

// Video Content Types
constant char NAV_HTTP_CONTENT_TYPE_VIDEO_MP4[]                 = 'video/mp4'
constant char NAV_HTTP_CONTENT_TYPE_VIDEO_MPEG[]                = 'video/mpeg'
constant char NAV_HTTP_CONTENT_TYPE_VIDEO_OGG[]                 = 'video/ogg'
constant char NAV_HTTP_CONTENT_TYPE_VIDEO_WEBM[]                = 'video/webm'
constant char NAV_HTTP_CONTENT_TYPE_VIDEO_X_FLV[]              = 'video/x-flv'
constant char NAV_HTTP_CONTENT_TYPE_VIDEO_3GPP[]               = 'video/3gpp'

// Additional Text Content Types
constant char NAV_HTTP_CONTENT_TYPE_TEXT_CSS[]                  = 'text/css'
constant char NAV_HTTP_CONTENT_TYPE_TEXT_JAVASCRIPT[]           = 'text/javascript'
constant char NAV_HTTP_CONTENT_TYPE_TEXT_MARKDOWN[]             = 'text/markdown'
constant char NAV_HTTP_CONTENT_TYPE_TEXT_CACHE_MANIFEST[]       = 'text/cache-manifest'
constant char NAV_HTTP_CONTENT_TYPE_TEXT_CALENDAR[]             = 'text/calendar'


constant char NAV_HTTP_HEADER_ACCEPT[]                              = 'Accept'
constant char NAV_HTTP_HEADER_ACCEPT_CH[]                           = 'Accept-CH'
constant char NAV_HTTP_HEADER_ACCEPT_CH_LIFETIME[]                  = 'Accept-CH-Lifetime'
constant char NAV_HTTP_HEADER_ACCEPT_CHARSET[]                      = 'Accept-Charset'
constant char NAV_HTTP_HEADER_ACCEPT_ENCODING[]                     = 'Accept-Encoding'
constant char NAV_HTTP_HEADER_ACCEPT_LANGUAGE[]                     = 'Accept-Language'
constant char NAV_HTTP_HEADER_ACCEPT_PATCH[]                        = 'Accept-Patch'
constant char NAV_HTTP_HEADER_ACCEPT_POST[]                         = 'Accept-Post'
constant char NAV_HTTP_HEADER_ACCEPT_RANGES[]                       = 'Accept-Ranges'
constant char NAV_HTTP_HEADER_ACCESS_CONTROL_ALLOW_CREDENTIALS[]    = 'Access-Control-Allow-Credentials'
constant char NAV_HTTP_HEADER_ACCESS_CONTROL_ALLOW_HEADERS[]        = 'Access-Control-Allow-Headers'
constant char NAV_HTTP_HEADER_ACCESS_CONTROL_ALLOW_METHODS[]        = 'Access-Control-Allow-Methods'
constant char NAV_HTTP_HEADER_ACCESS_CONTROL_ALLOW_ORIGIN[]         = 'Access-Control-Allow-Origin'
constant char NAV_HTTP_HEADER_ACCESS_CONTROL_EXPOSE_HEADERS[]       = 'Access-Control-Expose-Headers'
constant char NAV_HTTP_HEADER_ACCESS_CONTROL_MAX_AGE[]              = 'Access-Control-Max-Age'
constant char NAV_HTTP_HEADER_ACCESS_CONTROL_REQUEST_HEADERS[]      = 'Access-Control-Request-Headers'
constant char NAV_HTTP_HEADER_ACCESS_CONTROL_REQUEST_METHOD[]       = 'Access-Control-Request-Method'
constant char NAV_HTTP_HEADER_AGE[]                                 = 'Age'
constant char NAV_HTTP_HEADER_ALLOW[]                               = 'Allow'
constant char NAV_HTTP_HEADER_ALT_SVC[]                             = 'Alt-Svc'
constant char NAV_HTTP_HEADER_ALT_USED[]                            = 'Alt-Used'
constant char NAV_HTTP_HEADER_AUTHORIZATION[]                       = 'Authorization'
constant char NAV_HTTP_HEADER_CACHE_CONTROL[]                       = 'Cache-Control'
constant char NAV_HTTP_HEADER_CLEAR_SITE_DATA[]                     = 'Clear-Site-Data'
constant char NAV_HTTP_HEADER_CONNECTION[]                          = 'Connection'
constant char NAV_HTTP_HEADER_CONTENT_DISPOSITION[]                 = 'Content-Disposition'
constant char NAV_HTTP_HEADER_CONTENT_DPR[]                         = 'Content-DPR'
constant char NAV_HTTP_HEADER_CONTENT_ENCODING[]                    = 'Content-Encoding'
constant char NAV_HTTP_HEADER_CONTENT_LANGUAGE[]                    = 'Content-Language'
constant char NAV_HTTP_HEADER_CONTENT_LENGTH[]                      = 'Content-Length'
constant char NAV_HTTP_HEADER_CONTENT_LOCATION[]                    = 'Content-Location'
constant char NAV_HTTP_HEADER_CONTENT_RANGE[]                       = 'Content-Range'
constant char NAV_HTTP_HEADER_CONTENT_SECURITY_POLICY[]             = 'Content-Security-Policy'
constant char NAV_HTTP_HEADER_CONTENT_SECURITY_POLICY_REPORT_ONLY[] = 'Content-Security-Policy-Report-Only'
constant char NAV_HTTP_HEADER_CONTENT_TYPE[]                        = 'Content-Type'
constant char NAV_HTTP_HEADER_COOKIE[]                              = 'Cookie'
constant char NAV_HTTP_HEADER_CRITIAL_CH[]                          = 'Critical-CH'
constant char NAV_HTTP_HEADER_CROSS_ORIGIN_EMBEDDER_POLICY[]        = 'Cross-Origin-Embedder-Policy'
constant char NAV_HTTP_HEADER_CROSS_ORIGIN_OPENER_POLICY[]          = 'Cross-Origin-Opener-Policy'
constant char NAV_HTTP_HEADER_CROSS_ORIGIN_RESOURCE_POLICY[]        = 'Cross-Origin-Resource-Policy'
constant char NAV_HTTP_HEADER_DATE[]                                = 'Date'
constant char NAV_HTTP_HEADER_DEVICE_MEMORY[]                       = 'Device-Memory'
constant char NAV_HTTP_HEADER_DIGEST[]                              = 'Digest'
constant char NAV_HTTP_HEADER_DNT[]                                 = 'DNT'
constant char NAV_HTTP_HEADER_DOWNLINK[]                            = 'Downlink'
constant char NAV_HTTP_HEADER_DPR[]                                 = 'DPR'
constant char NAV_HTTP_HEADER_EARLY_DATA[]                          = 'Early-Data'
constant char NAV_HTTP_HEADER_ECT[]                                 = 'ECT'
constant char NAV_HTTP_HEADER_ETAG[]                                = 'ETag'
constant char NAV_HTTP_HEADER_EXPECT[]                              = 'Expect'
constant char NAV_HTTP_HEADER_EXPECT_CT[]                           = 'Expect-CT'
constant char NAV_HTTP_HEADER_EXPIRES[]                             = 'Expires'
constant char NAV_HTTP_HEADER_FORWARDED[]                           = 'Forwarded'
constant char NAV_HTTP_HEADER_FROM[]                                = 'From'
constant char NAV_HTTP_HEADER_HOST[]                                = 'Host'
constant char NAV_HTTP_HEADER_IF_MATCH[]                            = 'If-Match'
constant char NAV_HTTP_HEADER_IF_MODIFIED_SINCE[]                   = 'If-Modified-Since'
constant char NAV_HTTP_HEADER_IF_NONE_MATCH[]                       = 'If-None-Match'
constant char NAV_HTTP_HEADER_IF_RANGE[]                            = 'If-Range'
constant char NAV_HTTP_HEADER_IF_UNMODIFIED_SINCE[]                 = 'If-Unmodified-Since'
constant char NAV_HTTP_HEADER_KEEP_ALIVE[]                          = 'Keep-Alive'
constant char NAV_HTTP_HEADER_LARGE_ALLOCATION[]                    = 'Large-Allocation'
constant char NAV_HTTP_HEADER_LAST_MODIFIED[]                       = 'Last-Modified'
constant char NAV_HTTP_HEADER_LINK[]                                = 'Link'
constant char NAV_HTTP_HEADER_LOCATION[]                            = 'Location'
constant char NAV_HTTP_HEADER_MAX_FORWARDS[]                        = 'Max-Forwards'
constant char NAV_HTTP_HEADER_NEL[]                                 = 'NEL'
constant char NAV_HTTP_HEADER_ORIGIN[]                              = 'Origin'
constant char NAV_HTTP_HEADER_PERMISSIONS_POLICY[]                  = 'Permissions-Policy'
constant char NAV_HTTP_HEADER_PRAGMA[]                              = 'Pragma'
constant char NAV_HTTP_HEADER_PROXY_AUTHENTICATE[]                  = 'Proxy-Authenticate'
constant char NAV_HTTP_HEADER_PROXY_AUTHORIZATION[]                 = 'Proxy-Authorization'
constant char NAV_HTTP_HEADER_PROXY_RANGE[]                         = 'Range'
constant char NAV_HTTP_HEADER_PROXY_REFERER[]                       = 'Referer'
constant char NAV_HTTP_HEADER_REFERER_POLICY[]                      = 'Referer-Policy'
constant char NAV_HTTP_HEADER_RETRY_AFTER[]                         = 'Retry-After'
constant char NAV_HTTP_HEADER_RTT[]                                 = 'RTT'
constant char NAV_HTTP_HEADER_SAVE_DATA[]                           = 'Save-Data'
constant char NAV_HTTP_HEADER_SEC_CH_PREFERS_COLOR_SCHEME[]         = 'Sec-CH-Prefers-Color-Scheme'
constant char NAV_HTTP_HEADER_SEC_CH_PREFERS_REDUCED_MOTION[]       = 'Sec-CH-Prefers-Reduced-Motion'
constant char NAV_HTTP_HEADER_SEC_CH_PREFERS_REDUCED_TRANSPARENCY[] = 'Sec-CH-Prefers-Reduced-Transparency'
constant char NAV_HTTP_HEADER_SEC_CH_UA[]                           = 'Sec-CH-UA'
constant char NAV_HTTP_HEADER_SEC_CH_UA_ARCH[]                      = 'Sec-CH-UA-Arch'
constant char NAV_HTTP_HEADER_SEC_CH_UA_BITNESS[]                   = 'Sec-CH-UA-Bitness'
constant char NAV_HTTP_HEADER_SEC_CH_UA_FULL_VERSION[]              = 'Sec-CH-UA-Full-Version'
constant char NAV_HTTP_HEADER_SEC_CH_UA_FULL_VERSION_LIST[]         = 'Sec-CH-UA-Full-Version-List'
constant char NAV_HTTP_HEADER_SEC_CH_UA_MOBILE[]                    = 'Sec-CH-UA-Mobile'
constant char NAV_HTTP_HEADER_SEC_CH_UA_MODEL[]                     = 'Sec-CH-UA-Model'
constant char NAV_HTTP_HEADER_SEC_CH_UA_PLATFORM[]                  = 'Sec-CH-UA-Platform'
constant char NAV_HTTP_HEADER_SEC_CH_UA_PLATFORM_VERSION[]          = 'Sec-CH-UA-Platform-Version'
constant char NAV_HTTP_HEADER_SEC_FETCH_DEST[]                      = 'Sec-Fetch-Dest'
constant char NAV_HTTP_HEADER_SEC_FETCH_MODE[]                      = 'Sec-Fetch-Mode'
constant char NAV_HTTP_HEADER_SEC_FETCH_SITE[]                      = 'Sec-Fetch-Site'
constant char NAV_HTTP_HEADER_SEC_FETCH_USER[]                      = 'Sec-Fetch-User'
constant char NAV_HTTP_HEADER_SEC_GPC[]                             = 'Sec-GPC'
constant char NAV_HTTP_HEADER_SEC_PURPOSE[]                         = 'Sec-Purpose'
constant char NAV_HTTP_HEADER_SEC_WEBSOCKET_ACCEPT[]                = 'Sec-WebSocket-Accept'
constant char NAV_HTTP_HEADER_SERVER[]                              = 'Server'
constant char NAV_HTTP_HEADER_SERVER_TIMING[]                       = 'Server-Timing'
constant char NAV_HTTP_HEADER_SERVICE_WORKER_NAVIGATION_PRELOAD[]   = 'Service-Worker-Navigation-Preload'
constant char NAV_HTTP_HEADER_SET_COOKIE[]                          = 'Set-Cookie'
constant char NAV_HTTP_HEADER_SOURCEMAP[]                           = 'SourceMap'
constant char NAV_HTTP_HEADER_STRICT_TRANSPORT_SECURITY[]           = 'Strict-Transport-Security'
constant char NAV_HTTP_HEADER_TE[]                                  = 'TE'
constant char NAV_HTTP_HEADER_TIMING_ALLOW_ORIGIN[]                 = 'Timing-Allow-Origin'
constant char NAV_HTTP_HEADER_TK[]                                  = 'Tk'
constant char NAV_HTTP_HEADER_TRAILER[]                             = 'Trailer'
constant char NAV_HTTP_HEADER_TRANSFER_ENCODING[]                   = 'Transfer-Encoding'
constant char NAV_HTTP_HEADER_UPGRADE[]                             = 'Upgrade'
constant char NAV_HTTP_HEADER_UPGRADE_INSECURE_REQUESTS[]           = 'Upgrade-Insecure-Requests'
constant char NAV_HTTP_HEADER_USER_AGENT[]                          = 'User-Agent'
constant char NAV_HTTP_HEADER_VARY[]                                = 'Vary'
constant char NAV_HTTP_HEADER_VIA[]                                 = 'Via'
constant char NAV_HTTP_HEADER_VIEWPORT_WIDTH[]                      = 'Viewport-Width'
constant char NAV_HTTP_HEADER_WANT_DIGEST[]                         = 'Want-Digest'
constant char NAV_HTTP_HEADER_WARNING[]                             = 'Warning'
constant char NAV_HTTP_HEADER_WIDTH[]                               = 'Width'
constant char NAV_HTTP_HEADER_WWW_AUTHENTICATE[]                    = 'WWW-Authenticate'
constant char NAV_HTTP_HEADER_X_CONTENT_TYPE_OPTIONS[]              = 'X-Content-Type-Options'
constant char NAV_HTTP_HEADER_X_DNS_PREFETCH_CONTROL[]              = 'X-DNS-Prefetch-Control'
constant char NAV_HTTP_HEADER_X_FORWARDED_FOR[]                     = 'X-Forwarded-For'
constant char NAV_HTTP_HEADER_X_FORWARDED_HOST[]                    = 'X-Forwarded-Host'
constant char NAV_HTTP_HEADER_X_FORWARDED_PROTO[]                   = 'X-Forwarded-Proto'
constant char NAV_HTTP_HEADER_X_FRAME_OPTIONS[]                     = 'X-Frame-Options'
constant char NAV_HTTP_HEADER_X_XSS_PROTECTION[]                    = 'X-XSS-Protection'

// Additional Headers
constant char NAV_HTTP_HEADER_ACCESS_CONTROL_REQUEST_PRIVATE_NETWORK[] = 'Access-Control-Request-Private-Network'
constant char NAV_HTTP_HEADER_ACCEPT_PUSH_POLICY[]              = 'Accept-Push-Policy'
constant char NAV_HTTP_HEADER_ACCEPT_SIGNATURE[]                = 'Accept-Signature'
constant char NAV_HTTP_HEADER_AUTHENTICATION_CONTROL[]          = 'Authentication-Control'
constant char NAV_HTTP_HEADER_AUTHENTICATION_INFO[]             = 'Authentication-Info'
constant char NAV_HTTP_HEADER_CDN_CACHE_CONTROL[]              = 'CDN-Cache-Control'
constant char NAV_HTTP_HEADER_CONTENT_SECURITY_POLICY_PIN[]     = 'Content-Security-Policy-Pin'
constant char NAV_HTTP_HEADER_CROSS_ORIGIN_ISOLATION[]          = 'Cross-Origin-Isolation'
constant char NAV_HTTP_HEADER_DELTA_BASE[]                      = 'Delta-Base'
constant char NAV_HTTP_HEADER_DEPRECATION[]                     = 'Deprecation'
constant char NAV_HTTP_HEADER_DEVICE_CHANGE[]                   = 'Device-Change'
constant char NAV_HTTP_HEADER_EARLY_HINTS[]                     = 'Early-Hints'
constant char NAV_HTTP_HEADER_EXPECT_STAPLE[]                   = 'Expect-Staple'
constant char NAV_HTTP_HEADER_FEATURE_POLICY[]                  = 'Feature-Policy'
constant char NAV_HTTP_HEADER_IDENT[]                          = 'Ident'
constant char NAV_HTTP_HEADER_IDEMPOTENCY_KEY[]                = 'Idempotency-Key'
constant char NAV_HTTP_HEADER_IF_SCHEDULE_TAG_MATCH[]          = 'If-Schedule-Tag-Match'
constant char NAV_HTTP_HEADER_LAST_EVENT_ID[]                  = 'Last-Event-ID'
constant char NAV_HTTP_HEADER_LINK_TEMPLATE[]                  = 'Link-Template'
constant char NAV_HTTP_HEADER_METADATA[]                       = 'Metadata'
constant char NAV_HTTP_HEADER_NETWORK_CONTROL[]                = 'Network-Control'
constant char NAV_HTTP_HEADER_PRIORITY[]                       = 'Priority'
constant char NAV_HTTP_HEADER_PROTOCOL[]                       = 'Protocol'
constant char NAV_HTTP_HEADER_PUSH_POLICY[]                    = 'Push-Policy'
constant char NAV_HTTP_HEADER_RECEIVED_TTL[]                   = 'Received-TTL'
constant char NAV_HTTP_HEADER_SCHEDULING_REALM[]               = 'Scheduling-Realm'
constant char NAV_HTTP_HEADER_SEC_TOKEN_BINDING[]              = 'Sec-Token-Binding'
constant char NAV_HTTP_HEADER_SERVER_TIMING_ALLOW_ORIGIN[]     = 'Server-Timing-Allow-Origin'
constant char NAV_HTTP_HEADER_SIGNATURE[]                      = 'Signature'
constant char NAV_HTTP_HEADER_SIGNED_HEADERS[]                 = 'Signed-Headers'
constant char NAV_HTTP_HEADER_STATUS_URI[]                     = 'Status-URI'
constant char NAV_HTTP_HEADER_SUNSET[]                         = 'Sunset'
constant char NAV_HTTP_HEADER_SURROGATE_CAPABILITY[]           = 'Surrogate-Capability'
constant char NAV_HTTP_HEADER_TTL[]                           = 'TTL'
constant char NAV_HTTP_HEADER_VARIANT_VARY[]                   = 'Variant-Vary'
constant char NAV_HTTP_HEADER_X_CORRELATION_ID[]               = 'X-Correlation-ID'
constant char NAV_HTTP_HEADER_X_REQUEST_ID[]                   = 'X-Request-ID'
constant char NAV_HTTP_HEADER_X_ROBOTS_TAG[]                   = 'X-Robots-Tag'


constant char NAV_HTTP_HEADERS[][255] = {
    'Accept',
    'Accept-CH',
    'Accept-CH-Lifetime',
    'Accept-Charset',
    'Accept-Encoding',
    'Accept-Language',
    'Accept-Patch',
    'Accept-Post',
    'Accept-Push-Policy',
    'Accept-Ranges',
    'Accept-Signature',
    'Access-Control-Allow-Credentials',
    'Access-Control-Allow-Headers',
    'Access-Control-Allow-Methods',
    'Access-Control-Allow-Origin',
    'Access-Control-Expose-Headers',
    'Access-Control-Max-Age',
    'Access-Control-Request-Headers',
    'Access-Control-Request-Method',
    'Access-Control-Request-Private-Network',
    'Age',
    'Allow',
    'Alt-Svc',
    'Alt-Used',
    'Authentication-Control',
    'Authentication-Info',
    'Authorization',
    'Cache-Control',
    'CDN-Cache-Control',
    'Clear-Site-Data',
    'Connection',
    'Content-Disposition',
    'Content-DPR',
    'Content-Encoding',
    'Content-Language',
    'Content-Length',
    'Content-Location',
    'Content-Range',
    'Content-Security-Policy',
    'Content-Security-Policy-Pin',
    'Content-Security-Policy-Report-Only',
    'Content-Type',
    'Cookie',
    'Critical-CH',
    'Cross-Origin-Embedder-Policy',
    'Cross-Origin-Isolation',
    'Cross-Origin-Opener-Policy',
    'Cross-Origin-Resource-Policy',
    'Date',
    'Delta-Base',
    'Deprecation',
    'Device-Change',
    'Device-Memory',
    'Digest',
    'DNT',
    'Downlink',
    'DPR',
    'Early-Data',
    'Early-Hints',
    'ECT',
    'ETag',
    'Expect',
    'Expect-CT',
    'Expect-Staple',
    'Expires',
    'Feature-Policy',
    'Forwarded',
    'From',
    'Host',
    'Ident',
    'Idempotency-Key',
    'If-Match',
    'If-Modified-Since',
    'If-None-Match',
    'If-Range',
    'If-Schedule-Tag-Match',
    'If-Unmodified-Since',
    'Keep-Alive',
    'Large-Allocation',
    'Last-Event-ID',
    'Last-Modified',
    'Link',
    'Link-Template',
    'Location',
    'Max-Forwards',
    'Metadata',
    'NEL',
    'Network-Control',
    'Origin',
    'Permissions-Policy',
    'Pragma',
    'Priority',
    'Protocol',
    'Proxy-Authenticate',
    'Proxy-Authorization',
    'Push-Policy',
    'Range',
    'Received-TTL',
    'Referer',
    'Referer-Policy',
    'Retry-After',
    'RTT',
    'Save-Data',
    'Scheduling-Realm',
    'Sec-CH-Prefers-Color-Scheme',
    'Sec-CH-Prefers-Reduced-Motion',
    'Sec-CH-Prefers-Reduced-Transparency',
    'Sec-CH-UA',
    'Sec-CH-UA-Arch',
    'Sec-CH-UA-Bitness',
    'Sec-CH-UA-Full-Version',
    'Sec-CH-UA-Full-Version-List',
    'Sec-CH-UA-Mobile',
    'Sec-CH-UA-Model',
    'Sec-CH-UA-Platform',
    'Sec-CH-UA-Platform-Version',
    'Sec-Fetch-Dest',
    'Sec-Fetch-Mode',
    'Sec-Fetch-Site',
    'Sec-Fetch-User',
    'Sec-GPC',
    'Sec-Purpose',
    'Sec-Token-Binding',
    'Sec-WebSocket-Accept',
    'Server',
    'Server-Timing',
    'Server-Timing-Allow-Origin',
    'Service-Worker-Navigation-Preload',
    'Set-Cookie',
    'Signature',
    'Signed-Headers',
    'SourceMap',
    'Status-URI',
    'Strict-Transport-Security',
    'Sunset',
    'Surrogate-Capability',
    'TE',
    'Timing-Allow-Origin',
    'Tk',
    'Trailer',
    'Transfer-Encoding',
    'TTL',
    'Upgrade',
    'Upgrade-Insecure-Requests',
    'User-Agent',
    'Variant-Vary',
    'Vary',
    'Via',
    'Viewport-Width',
    'Want-Digest',
    'Warning',
    'Width',
    'WWW-Authenticate',
    'X-Content-Type-Options',
    'X-Correlation-ID',
    'X-DNS-Prefetch-Control',
    'X-Forwarded-For',
    'X-Forwarded-Host',
    'X-Forwarded-Proto',
    'X-Frame-Options',
    'X-Request-ID',
    'X-Robots-Tag',
    'X-XSS-Protection'
}

// Common HTTP Ports
constant integer NAV_HTTP_PORT_DEFAULT                = 80
constant integer NAV_HTTPS_PORT_DEFAULT              = 443
constant integer NAV_HTTP_ALT_PORT                   = 8080
constant integer NAV_HTTPS_ALT_PORT                  = 8443

// HTTP Authentication Schemes
constant char NAV_HTTP_AUTH_SCHEME_BASIC[]           = 'Basic'
constant char NAV_HTTP_AUTH_SCHEME_BEARER[]          = 'Bearer'
constant char NAV_HTTP_AUTH_SCHEME_DIGEST[]          = 'Digest'
constant char NAV_HTTP_AUTH_SCHEME_NEGOTIATE[]       = 'Negotiate'
constant char NAV_HTTP_AUTH_SCHEME_OAUTH[]           = 'OAuth'

// Cache Control Directives
constant char NAV_HTTP_CACHE_CONTROL_NO_CACHE[]      = 'no-cache'
constant char NAV_HTTP_CACHE_CONTROL_NO_STORE[]      = 'no-store'
constant char NAV_HTTP_CACHE_CONTROL_NO_TRANSFORM[]  = 'no-transform'
constant char NAV_HTTP_CACHE_CONTROL_ONLY_IF_CACHED[] = 'only-if-cached'
constant char NAV_HTTP_CACHE_CONTROL_MUST_REVALIDATE[] = 'must-revalidate'
constant char NAV_HTTP_CACHE_CONTROL_PUBLIC[]        = 'public'
constant char NAV_HTTP_CACHE_CONTROL_PRIVATE[]       = 'private'
constant char NAV_HTTP_CACHE_CONTROL_MAX_AGE[]       = 'max-age'
constant char NAV_HTTP_CACHE_CONTROL_S_MAXAGE[]      = 's-maxage'

// Common Content Encodings
constant char NAV_HTTP_ENCODING_GZIP[]               = 'gzip'
constant char NAV_HTTP_ENCODING_COMPRESS[]           = 'compress'
constant char NAV_HTTP_ENCODING_DEFLATE[]            = 'deflate'
constant char NAV_HTTP_ENCODING_BR[]                 = 'br'
constant char NAV_HTTP_ENCODING_IDENTITY[]           = 'identity'

// Transfer Encodings
constant char NAV_HTTP_TRANSFER_ENCODING_CHUNKED[]   = 'chunked'
constant char NAV_HTTP_TRANSFER_ENCODING_COMPRESS[]  = 'compress'
constant char NAV_HTTP_TRANSFER_ENCODING_DEFLATE[]   = 'deflate'
constant char NAV_HTTP_TRANSFER_ENCODING_GZIP[]      = 'gzip'

// Connection Types
constant char NAV_HTTP_CONNECTION_CLOSE[]            = 'close'
constant char NAV_HTTP_CONNECTION_KEEP_ALIVE[]       = 'keep-alive'
constant char NAV_HTTP_CONNECTION_UPGRADE[]          = 'upgrade'

// Common Character Constants
constant char NAV_HTTP_CRLF[]                        = '$0D,$0A'
constant char NAV_HTTP_HEADER_SEPARATOR[]            = ': '
constant char NAV_HTTP_QUERY_SEPARATOR[]             = '?'
constant char NAV_HTTP_FRAGMENT_SEPARATOR[]          = '#'
constant char NAV_HTTP_PATH_SEPARATOR[]              = '/'
constant char NAV_HTTP_QUERY_PARAM_SEPARATOR[]       = '&'
constant char NAV_HTTP_QUERY_VALUE_SEPARATOR[]       = '='

// Security Related
constant char NAV_HTTP_HSTS_MAX_AGE[]               = 'max-age=31536000'
constant char NAV_HTTP_HSTS_INCLUDE_SUBDOMAINS[]    = 'includeSubDomains'
constant char NAV_HTTP_HSTS_PRELOAD[]               = 'preload'

constant char NAV_HTTP_CSP_DEFAULT_SRC[]            = 'default-src'
constant char NAV_HTTP_CSP_SCRIPT_SRC[]             = 'script-src'
constant char NAV_HTTP_CSP_STYLE_SRC[]              = 'style-src'
constant char NAV_HTTP_CSP_IMG_SRC[]                = 'img-src'
constant char NAV_HTTP_CSP_CONNECT_SRC[]            = 'connect-src'
constant char NAV_HTTP_CSP_FONT_SRC[]               = 'font-src'
constant char NAV_HTTP_CSP_OBJECT_SRC[]             = 'object-src'
constant char NAV_HTTP_CSP_MEDIA_SRC[]              = 'media-src'

// Common Response Types
constant char NAV_HTTP_RESPONSE_TYPE_SUCCESS[]       = 'SUCCESS'
constant char NAV_HTTP_RESPONSE_TYPE_ERROR[]         = 'ERROR'
constant char NAV_HTTP_RESPONSE_TYPE_TIMEOUT[]       = 'TIMEOUT'

// HTTP Request Timeouts (in seconds)
constant integer NAV_HTTP_TIMEOUT_DEFAULT            = 30
constant integer NAV_HTTP_TIMEOUT_QUICK             = 5
constant integer NAV_HTTP_TIMEOUT_LONG              = 120

// Maximum Sizes
constant integer NAV_HTTP_MAX_HEADER_SIZE           = 8192
constant integer NAV_HTTP_MAX_URL_LENGTH            = 2048
constant integer NAV_HTTP_MAX_PATH_LENGTH           = 1024
constant integer NAV_HTTP_MAX_QUERY_LENGTH          = 1024
constant integer NAV_HTTP_MAX_HEADERS              = 20
constant integer NAV_HTTP_MAX_COOKIES              = 20

// Websocket Related
constant char NAV_HTTP_WEBSOCKET_VERSION[]          = '13'
constant char NAV_HTTP_WEBSOCKET_PROTOCOL[]         = 'websocket'

/**
 * Maximum number of HTTP headers allowed in a request or response.
 * Can be overridden before including this file if a different limit is needed.
 */
#IF_NOT_DEFINED NAV_HTTP_MAX_HEADERS
constant integer NAV_HTTP_MAX_HEADERS = 20
#END_IF


DEFINE_TYPE

/**
 * @struct _NAVHttpStatus
 * @description Structure representing an HTTP status code and message.
 *
 * @property {integer} Code - The 3-digit HTTP status code
 * @property {char[256]} Message - The human-readable status message
 *
 * @see NAVHttpGetStatusMessage
 */
struct _NAVHttpStatus {
    integer Code;
    char Message[256];
}


/**
 * @struct _NAVHttpHeader
 * @description Structure for storing a key-value pair of strings.
 *
 * @property {char[256]} Key - The key string
 * @property {char[1024]} Value - The value string
 *
 * @see NAVHttpHeaderAdd
 */
struct _NAVHttpHeader {
    char Key[256];
    char Value[1024];
}

/**
 * @struct _NAVHttpHeaderCollection
 * @description Structure for storing HTTP headers as key-value pairs.
 *
 * @property {integer} Count - Number of headers
 * @property {_NAVHttpHeader[NAV_HTTP_MAX_HEADERS]} Headers - Array of header key-value pairs
 *
 * @see NAVHttpRequestAddHeader
 * @see NAVHttpResponseAddHeader
 */
struct _NAVHttpHeaderCollection {
    integer Count;
    _NAVHttpHeader Headers[NAV_HTTP_MAX_HEADERS];
}

/**
 * @struct _NAVHttpRequest
 * @description Structure representing an HTTP request.
 *
 * @property {char[7]} Method - HTTP method (GET, POST, PUT, etc.)
 * @property {char[256]} Path - Request path including query string
 * @property {char[8]} Version - HTTP version
 * @property {char[256]} Host - Target host
 * @property {integer} Port - Target port
 * @property {char[2048]} Body - Request body content
 * @property {_NAVHttpHeader} Headers - Request headers
 *
 * @see NAVHttpRequestInit
 */
struct _NAVHttpRequest {
    char Method[7];
    char Path[256];
    char Version[8];
    char Host[256];
    integer Port;
    char Body[2048];

    _NAVHttpHeaderCollection Headers;
}

/**
 * @struct _NAVHttpResponse
 * @description Structure representing an HTTP response.
 *
 * @property {_NAVHttpStatus} Status - Response status code and message
 * @property {_NAVHttpHeader} Headers - Response headers
 * @property {char[16384]} Body - Response body content
 * @property {char[256]} ContentType - Content-Type of the response
 * @property {long} ContentLength - Length of response body in bytes
 *
 * @see NAVHttpResponseInit
 */
struct _NAVHttpResponse {
    _NAVHttpStatus Status;
    _NAVHttpHeaderCollection Headers;
    char Body[16384];
    char ContentType[256];
    long ContentLength;
}

#END_IF // __NAV_FOUNDATION_HTTPUTILS_H__
