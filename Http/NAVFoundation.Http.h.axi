PROGRAM_NAME='NAVFoundation.Http.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_HTTP_H__
#DEFINE __NAV_FOUNDATION_HTTP_H__ 'NAVFoundation.Http.h'

#include 'NAVFoundation.Core.axi'


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

constant char NAV_HTTP_HOST_DEFAULT[]       = 'localhost'

constant char NAV_HTTP_PATH_DEFAULT[]      = '/'

constant char NAV_HTTP_SCHEME_HTTP[]      = 'http'
constant char NAV_HTTP_SCHEME_HTTPS[]     = 'https'

constant char NAV_HTTP_SCHEME_DEFAULT[]   = "NAV_HTTP_SCHEME_HTTP"

constant char NAV_HTTP_SCHEMES[][]  =   {
                                            NAV_HTTP_SCHEME_HTTP,
                                            NAV_HTTP_SCHEME_HTTPS
                                        }

constant char NAV_HTTP_SCHEME_TOKEN[]     = '://'
constant char NAV_HTTP_PORT_TOKEN[]       = ':'
constant char NAV_HTTP_PATH_TOKEN[]       = '/'
constant char NAV_HTTP_QUERY_TOKEN[]      = '?'
constant char NAV_HTTP_FRAGMENT_TOKEN[]   = '#'

constant integer NAV_HTTP_MAX_REQUEST_LENGTH    = 4096
constant integer NAV_HTTP_MAX_RESPONSE_LENGTH   = 16384

constant char NAV_HTTP_METHOD_CONNECT[]  = 'CONNECT'
constant char NAV_HTTP_METHOD_DELETE[]   = 'DELETE'
constant char NAV_HTTP_METHOD_GET[]      = 'GET'
constant char NAV_HTTP_METHOD_HEAD[]     = 'HEAD'
constant char NAV_HTTP_METHOD_OPTIONS[]  = 'OPTIONS'
constant char NAV_HTTP_METHOD_PATCH[]    = 'PATCH'
constant char NAV_HTTP_METHOD_POST[]     = 'POST'
constant char NAV_HTTP_METHOD_PUT[]      = 'PUT'
constant char NAV_HTTP_METHOD_TRACE[]    = 'TRACE'

constant char NAV_HTTP_METHOD_DEFAULT[] = "NAV_HTTP_METHOD_GET"

constant char NAV_HTTP_METHODS[][] =    {
                                            NAV_HTTP_METHOD_CONNECT,
                                            NAV_HTTP_METHOD_DELETE,
                                            NAV_HTTP_METHOD_GET,
                                            NAV_HTTP_METHOD_HEAD,
                                            NAV_HTTP_METHOD_OPTIONS,
                                            NAV_HTTP_METHOD_PATCH,
                                            NAV_HTTP_METHOD_POST,
                                            NAV_HTTP_METHOD_PUT,
                                            NAV_HTTP_METHOD_TRACE
                                        }


constant char NAV_HTTP_VERSION_1_0[]    = 'HTTP/1.0'
constant char NAV_HTTP_VERSION_1_1[]    = 'HTTP/1.1'
constant char NAV_HTTP_VERSION_2_0[]    = 'HTTP/2.0'

constant char NAV_HTTP_VERSION_DEFAULT[] = "NAV_HTTP_VERSION_1_1"

constant char NAV_HTTP_VERSIONS[][] =   {
                                            NAV_HTTP_VERSION_1_0,
                                            NAV_HTTP_VERSION_1_1,
                                            NAV_HTTP_VERSION_2_0
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

constant char NAV_HTTP_HEADERS[][]  =   {
                                            NAV_HTTP_HEADER_ACCEPT,
                                            NAV_HTTP_HEADER_ACCEPT_CH,
                                            NAV_HTTP_HEADER_ACCEPT_CH_LIFETIME,
                                            NAV_HTTP_HEADER_ACCEPT_CHARSET,
                                            NAV_HTTP_HEADER_ACCEPT_ENCODING,
                                            NAV_HTTP_HEADER_ACCEPT_LANGUAGE,
                                            NAV_HTTP_HEADER_ACCEPT_PATCH,
                                            NAV_HTTP_HEADER_ACCEPT_POST,
                                            NAV_HTTP_HEADER_ACCEPT_RANGES,
                                            NAV_HTTP_HEADER_ACCESS_CONTROL_ALLOW_CREDENTIALS,
                                            NAV_HTTP_HEADER_ACCESS_CONTROL_ALLOW_HEADERS,
                                            NAV_HTTP_HEADER_ACCESS_CONTROL_ALLOW_METHODS,
                                            NAV_HTTP_HEADER_ACCESS_CONTROL_ALLOW_ORIGIN,
                                            NAV_HTTP_HEADER_ACCESS_CONTROL_EXPOSE_HEADERS,
                                            NAV_HTTP_HEADER_ACCESS_CONTROL_MAX_AGE,
                                            NAV_HTTP_HEADER_ACCESS_CONTROL_REQUEST_HEADERS,
                                            NAV_HTTP_HEADER_ACCESS_CONTROL_REQUEST_METHOD,
                                            NAV_HTTP_HEADER_AGE,
                                            NAV_HTTP_HEADER_ALLOW,
                                            NAV_HTTP_HEADER_ALT_SVC,
                                            NAV_HTTP_HEADER_ALT_USED,
                                            NAV_HTTP_HEADER_AUTHORIZATION,
                                            NAV_HTTP_HEADER_CACHE_CONTROL,
                                            NAV_HTTP_HEADER_CLEAR_SITE_DATA,
                                            NAV_HTTP_HEADER_CONNECTION,
                                            NAV_HTTP_HEADER_CONTENT_DISPOSITION,
                                            NAV_HTTP_HEADER_CONTENT_DPR,
                                            NAV_HTTP_HEADER_CONTENT_ENCODING,
                                            NAV_HTTP_HEADER_CONTENT_LANGUAGE,
                                            NAV_HTTP_HEADER_CONTENT_LENGTH,
                                            NAV_HTTP_HEADER_CONTENT_LOCATION,
                                            NAV_HTTP_HEADER_CONTENT_RANGE,
                                            NAV_HTTP_HEADER_CONTENT_SECURITY_POLICY,
                                            NAV_HTTP_HEADER_CONTENT_SECURITY_POLICY_REPORT_ONLY,
                                            NAV_HTTP_HEADER_CONTENT_TYPE,
                                            NAV_HTTP_HEADER_COOKIE,
                                            NAV_HTTP_HEADER_CRITIAL_CH,
                                            NAV_HTTP_HEADER_CROSS_ORIGIN_EMBEDDER_POLICY,
                                            NAV_HTTP_HEADER_CROSS_ORIGIN_OPENER_POLICY,
                                            NAV_HTTP_HEADER_CROSS_ORIGIN_RESOURCE_POLICY,
                                            NAV_HTTP_HEADER_DATE,
                                            NAV_HTTP_HEADER_DEVICE_MEMORY,
                                            NAV_HTTP_HEADER_DIGEST,
                                            NAV_HTTP_HEADER_DNT,
                                            NAV_HTTP_HEADER_DOWNLINK,
                                            NAV_HTTP_HEADER_DPR,
                                            NAV_HTTP_HEADER_EARLY_DATA,
                                            NAV_HTTP_HEADER_ECT,
                                            NAV_HTTP_HEADER_ETAG,
                                            NAV_HTTP_HEADER_EXPECT,
                                            NAV_HTTP_HEADER_EXPECT_CT,
                                            NAV_HTTP_HEADER_EXPIRES,
                                            NAV_HTTP_HEADER_FORWARDED,
                                            NAV_HTTP_HEADER_FROM,
                                            NAV_HTTP_HEADER_HOST,
                                            NAV_HTTP_HEADER_IF_MATCH,
                                            NAV_HTTP_HEADER_IF_MODIFIED_SINCE,
                                            NAV_HTTP_HEADER_IF_NONE_MATCH,
                                            NAV_HTTP_HEADER_IF_RANGE,
                                            NAV_HTTP_HEADER_IF_UNMODIFIED_SINCE,
                                            NAV_HTTP_HEADER_KEEP_ALIVE,
                                            NAV_HTTP_HEADER_LARGE_ALLOCATION,
                                            NAV_HTTP_HEADER_LAST_MODIFIED,
                                            NAV_HTTP_HEADER_LINK,
                                            NAV_HTTP_HEADER_LOCATION,
                                            NAV_HTTP_HEADER_MAX_FORWARDS,
                                            NAV_HTTP_HEADER_NEL,
                                            NAV_HTTP_HEADER_ORIGIN,
                                            NAV_HTTP_HEADER_PERMISSIONS_POLICY,
                                            NAV_HTTP_HEADER_PRAGMA,
                                            NAV_HTTP_HEADER_PROXY_AUTHENTICATE,
                                            NAV_HTTP_HEADER_PROXY_AUTHORIZATION,
                                            NAV_HTTP_HEADER_PROXY_RANGE,
                                            NAV_HTTP_HEADER_PROXY_REFERER,
                                            NAV_HTTP_HEADER_REFERER_POLICY,
                                            NAV_HTTP_HEADER_RETRY_AFTER,
                                            NAV_HTTP_HEADER_RTT,
                                            NAV_HTTP_HEADER_SAVE_DATA,
                                            NAV_HTTP_HEADER_SEC_CH_PREFERS_COLOR_SCHEME,
                                            NAV_HTTP_HEADER_SEC_CH_PREFERS_REDUCED_MOTION,
                                            NAV_HTTP_HEADER_SEC_CH_PREFERS_REDUCED_TRANSPARENCY,
                                            NAV_HTTP_HEADER_SEC_CH_UA,
                                            NAV_HTTP_HEADER_SEC_CH_UA_ARCH,
                                            NAV_HTTP_HEADER_SEC_CH_UA_BITNESS,
                                            NAV_HTTP_HEADER_SEC_CH_UA_FULL_VERSION,
                                            NAV_HTTP_HEADER_SEC_CH_UA_FULL_VERSION_LIST,
                                            NAV_HTTP_HEADER_SEC_CH_UA_MOBILE,
                                            NAV_HTTP_HEADER_SEC_CH_UA_MODEL,
                                            NAV_HTTP_HEADER_SEC_CH_UA_PLATFORM,
                                            NAV_HTTP_HEADER_SEC_CH_UA_PLATFORM_VERSION,
                                            NAV_HTTP_HEADER_SEC_FETCH_DEST,
                                            NAV_HTTP_HEADER_SEC_FETCH_MODE,
                                            NAV_HTTP_HEADER_SEC_FETCH_SITE,
                                            NAV_HTTP_HEADER_SEC_FETCH_USER,
                                            NAV_HTTP_HEADER_SEC_GPC,
                                            NAV_HTTP_HEADER_SEC_PURPOSE,
                                            NAV_HTTP_HEADER_SEC_WEBSOCKET_ACCEPT,
                                            NAV_HTTP_HEADER_SERVER,
                                            NAV_HTTP_HEADER_SERVER_TIMING,
                                            NAV_HTTP_HEADER_SERVICE_WORKER_NAVIGATION_PRELOAD,
                                            NAV_HTTP_HEADER_SET_COOKIE,
                                            NAV_HTTP_HEADER_SOURCEMAP,
                                            NAV_HTTP_HEADER_STRICT_TRANSPORT_SECURITY,
                                            NAV_HTTP_HEADER_TE,
                                            NAV_HTTP_HEADER_TIMING_ALLOW_ORIGIN,
                                            NAV_HTTP_HEADER_TK,
                                            NAV_HTTP_HEADER_TRAILER,
                                            NAV_HTTP_HEADER_TRANSFER_ENCODING,
                                            NAV_HTTP_HEADER_UPGRADE,
                                            NAV_HTTP_HEADER_UPGRADE_INSECURE_REQUESTS,
                                            NAV_HTTP_HEADER_USER_AGENT,
                                            NAV_HTTP_HEADER_VARY,
                                            NAV_HTTP_HEADER_VIA,
                                            NAV_HTTP_HEADER_VIEWPORT_WIDTH,
                                            NAV_HTTP_HEADER_WANT_DIGEST,
                                            NAV_HTTP_HEADER_WARNING,
                                            NAV_HTTP_HEADER_WIDTH,
                                            NAV_HTTP_HEADER_WWW_AUTHENTICATE,
                                            NAV_HTTP_HEADER_X_CONTENT_TYPE_OPTIONS,
                                            NAV_HTTP_HEADER_X_DNS_PREFETCH_CONTROL,
                                            NAV_HTTP_HEADER_X_FORWARDED_FOR,
                                            NAV_HTTP_HEADER_X_FORWARDED_HOST,
                                            NAV_HTTP_HEADER_X_FORWARDED_PROTO,
                                            NAV_HTTP_HEADER_X_FRAME_OPTIONS,
                                            NAV_HTTP_HEADER_X_XSS_PROTECTION
                                        }


DEFINE_TYPE

struct _NAVHttpStatus {
    integer Code;
    char Message[256];
}


struct _NAVHttpHeader {
    integer Count;
    _NAVKeyStringValuePair Headers[10];
}


struct _NAVHttpHost {
    char Address[256];
    integer Port;
}


struct _NAVHttpRequest {
    char Method[7];
    char Path[256];
    char Version[8];
    _NAVHttpHost Host;
    char Body[2048];

    _NAVHttpHeader Headers;
}


struct _NAVHttpResponse {
    _NAVHttpStatus Status;
    char Body[16384];

    _NAVHttpHeader Headers;
}


struct _NAVHttpUrl {
    char Scheme[16];
    _NAVHttpHost Host;
    char Path[256];
    _NAVKeyStringValuePair Queries[10];
    _NAVKeyStringValuePair Fragments[10];
}


struct _NAVHttpUrlParser {
    char Scheme;
    char Host;
    char Path;
    char Query;
    char Fragment;
}


#END_IF // __NAV_FOUNDATION_HTTP_H__
