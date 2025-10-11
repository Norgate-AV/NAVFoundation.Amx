# NAVFoundation.HttpUtils

The HttpUtils library for NAVFoundation provides a comprehensive set of functions and data structures for working with HTTP requests and responses in NetLinx programming. It simplifies the process of building, sending, and processing HTTP communications in AMX control systems.

## Overview

HTTP (Hypertext Transfer Protocol) is the foundation of data communication on the web. This library enables NetLinx programmers to interact with web services, APIs, and web servers using standard HTTP methods and protocols. It handles the complexities of HTTP message formatting, header management, and status code handling.

## Features

- **HTTP Request Building**: Create properly formatted HTTP requests with methods, headers, and body content
- **HTTP Response Parsing**: Parse HTTP responses including status codes, headers, and body content
- **Headers Management**: Add, update, and validate HTTP headers
- **Content Type Handling**: Automatic content type inference based on request body
- **URL Parsing**: Parse URLs into components (scheme, host, path, port, etc.)
- **Status Code Handling**: Comprehensive set of HTTP status codes with proper messages
- **Response Processing**: Parse complete responses or handle responses in chunks for streaming
- **Utility Functions**: Helper functions for common HTTP-related tasks

## Constants and Definitions

### HTTP Methods

```netlinx
NAV_HTTP_METHOD_GET      = 'GET'
NAV_HTTP_METHOD_POST     = 'POST'
NAV_HTTP_METHOD_PUT      = 'PUT'
NAV_HTTP_METHOD_DELETE   = 'DELETE'
NAV_HTTP_METHOD_HEAD     = 'HEAD'
NAV_HTTP_METHOD_OPTIONS  = 'OPTIONS'
NAV_HTTP_METHOD_PATCH    = 'PATCH'
NAV_HTTP_METHOD_CONNECT  = 'CONNECT'
NAV_HTTP_METHOD_TRACE    = 'TRACE'
```

### HTTP Versions

```netlinx
NAV_HTTP_VERSION_1_0     = 'HTTP/1.0'
NAV_HTTP_VERSION_1_1     = 'HTTP/1.1'
NAV_HTTP_VERSION_2_0     = 'HTTP/2.0'
```

### HTTP Status Code Categories

```netlinx
// Information responses (100-199)
NAV_HTTP_STATUS_CODE_INFO_CONTINUE             = 100
NAV_HTTP_STATUS_CODE_INFO_SWITCHING_PROTOCOLS  = 101
// ... 

// Successful responses (200-299)
NAV_HTTP_STATUS_CODE_SUCCESS_OK                = 200
NAV_HTTP_STATUS_CODE_SUCCESS_CREATED           = 201
// ...

// Redirection messages (300-399)
NAV_HTTP_STATUS_CODE_REDIRECT_MULTIPLE_CHOICES = 300
NAV_HTTP_STATUS_CODE_REDIRECT_MOVED_PERMANENTLY = 301
// ...

// Client error responses (400-499)
NAV_HTTP_STATUS_CODE_CLIENT_ERROR_BAD_REQUEST  = 400
NAV_HTTP_STATUS_CODE_CLIENT_ERROR_UNAUTHORIZED = 401
// ...

// Server error responses (500-599)
NAV_HTTP_STATUS_CODE_SERVER_ERROR_SERVER_ERROR = 500
NAV_HTTP_STATUS_CODE_SERVER_ERROR_NOT_IMPLEMENTED = 501
// ...
```

**Note:** The library includes comprehensive HTTP status code support with constants for all standard codes and their corresponding message strings. See the header file for the complete list of `NAV_HTTP_STATUS_CODE_*` and `NAV_HTTP_STATUS_MESSAGE_*` constants.

### Common Content Types

```netlinx
NAV_HTTP_CONTENT_TYPE_TEXT_PLAIN        = 'text/plain'
NAV_HTTP_CONTENT_TYPE_TEXT_HTML         = 'text/html'
NAV_HTTP_CONTENT_TYPE_APPLICATION_JSON  = 'application/json'
// ... and many more (over 50 content types supported)
```

**Note:** The library includes comprehensive MIME type support for text, application, image, audio, video, and font content types. See the header file for the complete list of `NAV_HTTP_CONTENT_TYPE_*` constants.

### HTTP Headers

```netlinx
NAV_HTTP_HEADER_HOST                    = 'Host'
NAV_HTTP_HEADER_USER_AGENT              = 'User-Agent'
NAV_HTTP_HEADER_CONTENT_TYPE            = 'Content-Type'
NAV_HTTP_HEADER_CONTENT_LENGTH          = 'Content-Length'
NAV_HTTP_HEADER_AUTHORIZATION           = 'Authorization'
// ... and many more (over 150 standard headers supported)
```

**Note:** The library includes comprehensive support for HTTP headers, including standard headers, security headers, CORS headers, and custom headers. See the header file for the complete list of `NAV_HTTP_HEADER_*` constants.

### Ports and Defaults

```netlinx
NAV_HTTP_PORT_DEFAULT                   = 80
NAV_HTTPS_PORT_DEFAULT                  = 443
NAV_HTTP_ALT_PORT                       = 8080
NAV_HTTPS_ALT_PORT                      = 8443

NAV_HTTP_HOST_DEFAULT                   = 'localhost'
NAV_HTTP_PATH_DEFAULT                   = '/'
```

### Additional Constants

The library provides many additional constants for:

- **Authentication schemes**: `NAV_HTTP_AUTH_SCHEME_BASIC`, `NAV_HTTP_AUTH_SCHEME_BEARER`, etc.
- **Cache control directives**: `NAV_HTTP_CACHE_CONTROL_NO_CACHE`, `NAV_HTTP_CACHE_CONTROL_PUBLIC`, etc.
- **Content encodings**: `NAV_HTTP_ENCODING_GZIP`, `NAV_HTTP_ENCODING_DEFLATE`, etc.
- **Transfer encodings**: `NAV_HTTP_TRANSFER_ENCODING_CHUNKED`, etc.
- **Connection types**: `NAV_HTTP_CONNECTION_KEEP_ALIVE`, etc.
- **Timeouts**: `NAV_HTTP_TIMEOUT_DEFAULT = 30` seconds
- **Size limits**: `NAV_HTTP_MAX_HEADERS = 20`, `NAV_HTTP_MAX_BUFFER`, etc.

See the header file for the complete list of available constants.

## Data Structures

### \_NAVHttpStatus

Structure representing an HTTP status code and message.

```netlinx
struct _NAVHttpStatus {
    integer Code;
    char Message[256];
}
```

### \_NAVHttpHeader

Structure for storing a key-value pair of strings.

```netlinx
struct _NAVHttpHeader {
    char Key[256];
    char Value[1024];
}
```

### \_NAVHttpHeaderCollection

Structure for storing HTTP headers as key-value pairs.

```netlinx
struct _NAVHttpHeaderCollection {
    integer Count;
    _NAVHttpHeader Headers[NAV_HTTP_MAX_HEADERS];
}
```

### \_NAVHttpRequest

Structure representing an HTTP request.

```netlinx
struct _NAVHttpRequest {
    char Method[7];
    char Path[256];
    char Version[8];
    char Host[256];
    integer Port;
    char Body[2048];
    _NAVHttpHeaderCollection Headers;
}
```

### \_NAVHttpResponse

Structure representing an HTTP response.

```netlinx
struct _NAVHttpResponse {
    _NAVHttpStatus Status;
    _NAVHttpHeaderCollection Headers;
    char Body[16384];
    char ContentType[256];
    long ContentLength;
}
```

### \_NAVHttpRequestConfig

Configuration options for HTTP requests.

```netlinx
struct _NAVHttpRequestConfig {
    integer Timeout;
    char AuthScheme[32];
    char AuthToken[1024];
    char CacheControl[256];
    integer MaxRedirects;
    integer ValidateCertificates;
    integer FollowRedirects;
    integer UseCompression;
}
```

## Function Reference

### Request Building and Management

#### NAVHttpRequestInit

Initializes an HTTP request structure with essential values.

```netlinx
define_function char NAVHttpRequestInit(_NAVHttpRequest req,
                                        char method[],
                                        _NAVUrl url,
                                        char body[])
```

**Parameters:**

- `req`: The request structure to initialize
- `method`: HTTP method (GET, POST, etc.)
- `url`: URL structure containing host, path, and other components
- `body`: Request body (can be empty)

**Returns:** TRUE if initialization succeeded, FALSE otherwise

**Example:**

```netlinx
stack_var _NAVHttpRequest request
stack_var _NAVUrl url
stack_var char success

success = NAVHttpParseUrl('https://api.example.com/data', url)
success = NAVHttpRequestInit(request, 'GET', url, '')
```

#### NAVHttpRequestAddHeader

Adds a header to an HTTP request.

```netlinx
define_function char NAVHttpRequestAddHeader(_NAVHttpRequest req,
                                            char key[],
                                            char value[])
```

**Parameters:**

- `req`: The request to add the header to
- `key`: Header name
- `value`: Header value

**Returns:** TRUE if the header was added successfully, FALSE otherwise

**Example:**

```netlinx
NAVHttpRequestAddHeader(request, 'User-Agent', 'AMX NetLinx/1.0')
```

#### NAVHttpRequestUpdateHeader

Updates an existing header in an HTTP request.

```netlinx
define_function char NAVHttpRequestUpdateHeader(_NAVHttpRequest req,
                                               char key[],
                                               char value[])
```

**Parameters:**

- `req`: The request containing the header to update
- `key`: Header name to update
- `value`: New header value

**Returns:** TRUE if header was updated, FALSE if header doesn't exist or other error

**Example:**

```netlinx
NAVHttpRequestUpdateHeader(request, 'User-Agent', 'AMX NetLinx/2.0')
```

#### NAVHttpBuildRequest

Constructs a full HTTP request message from a request structure.

```netlinx
define_function char NAVHttpBuildRequest(_NAVHttpRequest req, char payload[])
```

**Parameters:**

- `req`: The request structure to build into a message
- `payload`: The string to populate with the full HTTP request message

**Returns:** TRUE if the request was built successfully, FALSE otherwise

**Example:**

```netlinx
stack_var char requestPayload[NAV_MAX_BUFFER]
NAVHttpBuildRequest(request, requestPayload)
```

### Response Handling

#### NAVHttpResponseInit

Initializes an HTTP response structure.

```netlinx
define_function NAVHttpResponseInit(_NAVHttpResponse res)
```

**Parameters:**

- `res`: The response structure to initialize

**Returns:** void

**Example:**

```netlinx
stack_var _NAVHttpResponse response
NAVHttpResponseInit(response)
```

#### NAVHttpResponseAddHeader

Adds a header to an HTTP response.

```netlinx
define_function char NAVHttpResponseAddHeader(_NAVHttpResponse res,
                                             char key[],
                                             char value[])
```

**Parameters:**

- `res`: The response to add the header to
- `key`: Header name
- `value`: Header value

**Returns:** TRUE if the header was added successfully, FALSE otherwise

**Example:**

```netlinx
NAVHttpResponseAddHeader(response, 'Content-Type', 'application/json')
```

#### NAVHttpResponseUpdateHeader

Updates an existing header in an HTTP response.

```netlinx
define_function char NAVHttpResponseUpdateHeader(_NAVHttpResponse res,
                                                char key[],
                                                char value[])
```

**Parameters:**

- `res`: The response containing the header to update
- `key`: Header name to update
- `value`: New header value

**Returns:** TRUE if header was updated, FALSE if header doesn't exist or other error

**Example:**

```netlinx
NAVHttpResponseUpdateHeader(response, 'Content-Type', 'text/plain')
```

#### NAVHttpBuildResponse

Constructs a full HTTP response message from a response structure.

```netlinx
define_function char[NAV_MAX_BUFFER] NAVHttpBuildResponse(_NAVHttpResponse res)
```

**Parameters:**

- `res`: The response structure to build into a message

**Returns:** A string containing the full HTTP response message

**Example:**

```netlinx
stack_var char responseString[NAV_MAX_BUFFER]
responseString = NAVHttpBuildResponse(response)
```

### URL Handling

#### NAVHttpParseUrl

Parses a URL string into a structured URL object.

```netlinx
define_function char NAVHttpParseUrl(char buffer[], _NAVUrl url)
```

**Parameters:**

- `buffer`: The URL string to parse
- `url`: The URL structure to populate with parsed data

**Returns:** TRUE if parsing was successful, FALSE otherwise

**Example:**

```netlinx
stack_var char urlString[256]
stack_var _NAVUrl url
stack_var char success

urlString = 'https://example.com:8443/api/v1/data?id=123'
success = NAVHttpParseUrl(urlString, url)
```

#### NAVHttpGetDefaultPort

Returns the default port number for the specified scheme.

```netlinx
define_function integer NAVHttpGetDefaultPort(char scheme[])
```

**Parameters:**

- `scheme`: URL scheme ('http' or 'https')

**Returns:** Default port number for the scheme

**Example:**

```netlinx
stack_var integer port
port = NAVHttpGetDefaultPort('https') // Returns 443
```

### Header Management

#### NAVHttpHeaderInit

Initializes an HTTP header key-value pair.

```netlinx
define_function NAVHttpHeaderInit(_NAVKeyStringValuePair header,
                                  char key[],
                                  char value[])
```

**Parameters:**

- `header`: The header structure to initialize
- `key`: Header name
- `value`: Header value

**Returns:** void

**Example:**

```netlinx
stack_var _NAVKeyStringValuePair header
NAVHttpHeaderInit(header, 'Content-Type', 'application/json')
```

#### NAVHttpBuildHeaders

Constructs a string of HTTP headers from a header structure.

```netlinx
define_function char[NAV_MAX_BUFFER] NAVHttpBuildHeaders(_NAVHttpHeader headers)
```

**Parameters:**

- `headers`: The headers to build into a string

**Returns:** A string containing all headers formatted for HTTP

**Example:**

```netlinx
stack_var char headerString[NAV_MAX_BUFFER]
headerString = NAVHttpBuildHeaders(request.Headers)
```

#### NAVHttpValidateHeaders

Validates the headers in a header structure.

```netlinx
define_function char NAVHttpValidateHeaders(_NAVHttpHeader headers)
```

**Parameters:**

- `headers`: The headers to validate

**Returns:** TRUE if all headers are valid, FALSE otherwise

**Example:**

```netlinx
if (NAVHttpValidateHeaders(request.Headers)) {
    // Headers are valid
}
```

#### NAVHttpGetHeaderValue

Retrieves the value of a header by key.

```netlinx
define_function char[256] NAVHttpGetHeaderValue(_NAVHttpHeader headers, char key[])
```

**Parameters:**

- `headers`: The headers to search
- `key`: The header name to find

**Returns:** The header value, or an empty string if not found

**Example:**

```netlinx
stack_var char contentType[256]
contentType = NAVHttpGetHeaderValue(response.Headers, 'Content-Type')
```

### Utility Functions

#### NAVHttpInferContentType

Infers the content type of a request body based on its content.

```netlinx
define_function char[NAV_MAX_BUFFER] NAVHttpInferContentType(char body[])
```

**Parameters:**

- `body`: The request body to infer the content type for

**Returns:** The inferred content type

**Example:**

```netlinx
stack_var char body[256]
stack_var char contentType[NAV_MAX_BUFFER]

body = '{"key": "value"}'
contentType = NAVHttpInferContentType(body) // Returns 'application/json'
```

#### NAVHttpGetStatusMessage

Returns the status message corresponding to an HTTP status code.

```netlinx
define_function char[NAV_MAX_CHARS] NAVHttpGetStatusMessage(integer status)
```

**Parameters:**

- `status`: The HTTP status code

**Returns:** The corresponding status message

**Example:**

```netlinx
stack_var char statusMessage[NAV_MAX_CHARS]
statusMessage = NAVHttpGetStatusMessage(200) // Returns 'OK'
```

## Usage Examples

### Making a Simple GET Request

```netlinx
DEFINE_FUNCTION SendGetRequest(dev socket, char host[], char path[]) {
    stack_var _NAVUrl url
    stack_var _NAVHttpRequest request
    stack_var char requestPayload[NAV_MAX_BUFFER]

    // Set up the URL
    url.Scheme = 'http'
    url.Host = host
    url.Path = path
    url.Port = NAV_HTTP_PORT_DEFAULT
    url.FullPath = path

    // Initialize and configure the request
    NAVHttpRequestInit(request, 'GET', url, '')
    NAVHttpRequestAddHeader(request, 'User-Agent', 'AMX NetLinx/1.0')

    // Build the request payload
    NAVHttpBuildRequest(request, requestPayload)

    // Send the request
    ip_client_open(socket.Port, url.Host, url.Port, IP_TCP)
    send_string socket, requestPayload
}
```

### Making a POST Request with JSON Body

```netlinx
DEFINE_FUNCTION SendJsonPostRequest(dev socket, char host[], char path[], char jsonData[]) {
    stack_var _NAVUrl url
    stack_var _NAVHttpRequest request
    stack_var char requestPayload[NAV_MAX_BUFFER]

    // Set up the URL
    url.Scheme = 'http'
    url.Host = host
    url.Path = path
    url.Port = NAV_HTTP_PORT_DEFAULT
    url.FullPath = path

    // Initialize and configure the request
    NAVHttpRequestInit(request, 'POST', url, jsonData)
    NAVHttpRequestAddHeader(request, 'User-Agent', 'AMX NetLinx/1.0')
    NAVHttpRequestAddHeader(request, 'Accept', 'application/json')

    // Build the request payload
    NAVHttpBuildRequest(request, requestPayload)

    // Send the request
    ip_client_open(socket.Port, url.Host, url.Port, IP_TCP)
    send_string socket, requestPayload
}
```

### Handling an HTTP Response

```netlinx
DEFINE_EVENT
DATA_EVENT[vdvTCPClient] {
    ONLINE: {
        // Connection established
    }
    STRING: {
        stack_var _NAVHttpResponse response

        // Initialize response
        NAVHttpResponseInit(response)

        // Parse the complete response
        if (NAVHttpParseResponse(data.text, response)) {
            // Check status code
            if (response.Status.Code >= 200 && response.Status.Code < 300) {
                // Success - process the response body
                NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Request successful: ', response.Body")
            }
            else {
                // Error handling
                NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Request failed with code ', itoa(response.Status.Code), ': ', response.Status.Message")
            }
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Failed to parse HTTP response'")
        }
    }
    OFFLINE: {
        // Connection closed
    }
}
```

### Parsing Responses in Chunks

For real-world applications where responses arrive in chunks:

```netlinx
DEFINE_FUNCTION HandleHttpResponse(char data[]) {
    stack_var _NAVHttpResponse response
    stack_var char headerBuffer[NAV_MAX_BUFFER]
    stack_var char bodyBuffer[NAV_MAX_BUFFER]

    NAVHttpResponseInit(response)

    // First, try to parse headers only
    if (NAVHttpParseResponseHeaders(data, response)) {
        // Headers parsed successfully
        // Now extract body based on Content-Length
        stack_var integer contentLength
        contentLength = atoi(NAVHttpGetHeaderValue(response.Headers, 'Content-Length'))

        if (contentLength > 0) {
            // Wait for body data and parse it separately
            // NAVHttpParseResponseBody(bodyData, response)
        }
    }
}
```

## Best Practices

### Setting Appropriate Headers

Always set appropriate headers for your requests:

```netlinx
// Set Content-Type header for requests with bodies
NAVHttpRequestAddHeader(request, 'Content-Type', 'application/json')

// Set Accept header to indicate what response format you can handle
NAVHttpRequestAddHeader(request, 'Accept', 'application/json')

// Set User-Agent to identify your application
NAVHttpRequestAddHeader(request, 'User-Agent', 'MyApp/1.0 (AMX NetLinx)')
```

### Error Handling

Always check the return values of functions that return success/failure indicators:

```netlinx
if (!NAVHttpRequestInit(request, 'GET', url, '')) {
    NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Failed to initialize HTTP request'")
    return
}
```

## Security Considerations

### Handle Authentication Properly

When using authentication, follow best practices:

```netlinx
// Basic Authentication
stack_var char authValue[256]
authValue = "'Basic ', NAVBase64Encode('username:password')"
NAVHttpRequestAddHeader(request, 'Authorization', authValue)

// Bearer Token
NAVHttpRequestAddHeader(request, 'Authorization', "'Bearer ', token")
```

## Contributing

For issues, suggestions, or contributions, please contact Norgate AV Services Limited.

## License

MIT License - Copyright (c) 2023 Norgate AV Services Limited
