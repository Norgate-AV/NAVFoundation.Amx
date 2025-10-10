# NAVFoundation.Url

A comprehensive URL manipulation library for NetLinx, providing RFC 3986 compliant URL parsing, building, validation, encoding/decoding, and resolution functionality.

## Overview

The NAVFoundation URL library provides a complete set of tools for working with URLs in NetLinx applications. It implements the URL standard defined in RFC 3986 and includes compatibility with WHATWG URL API and C# System.Uri behaviors.

## Features

- **URL Parsing**: Parse URLs into structured components (scheme, host, port, path, query, fragment)
- **URL Building**: Construct URLs from structured components
- **URL Validation**: Validate URLs against schemes, port ranges, and required components
- **URL Resolution**: Resolve relative URLs against base URLs per RFC 3986 Section 5
- **Percent Encoding/Decoding**: Encode and decode URL components
- **Path Normalization**: Normalize paths by removing dot segments (`.` and `..`)
- **Query String Parsing**: Parse query parameters into key-value pairs
- **Standards Compliance**: RFC 3986, RFC 6335, WHATWG URL API compatible

## Dependencies

- `NAVFoundation.Core.axi` - Core utility functions
- `NAVFoundation.StringUtils.axi` - String manipulation utilities
- `NAVFoundation.ErrorLogUtils.axi` - Error logging
- `NAVFoundation.PathUtils.axi` - Path utilities

## Data Structures

### `_NAVUrl`

The main URL structure containing all URL components:

```netlinx
struct _NAVUrl {
    char Scheme[NAV_MAX_URL_SCHEME]     // URL scheme (http, https, etc.)
    char Host[NAV_MAX_URL_HOST]         // Hostname or IP address
    integer Port                        // Port number (0 = default port)
    char UserInfo[NAV_MAX_URL_USERINFO] // User info (user:pass)
    char Path[NAV_MAX_BUFFER]           // URL path
    _NAVKeyStringValuePair Queries[NAV_URL_MAX_QUERIES] // Query parameters
    char Fragment[NAV_MAX_BUFFER]       // Fragment identifier
    integer HasUserInfo                 // Whether user info is present
}
```

### `_NAVKeyStringValuePair`

Structure for key-value pairs (used for query parameters):

```netlinx
struct _NAVKeyStringValuePair {
    char Key[NAV_MAX_BUFFER]
    char Value[NAV_MAX_BUFFER]
}
```

## API Reference

### URL Encoding/Decoding

#### `NAVUrlEncode(buffer[], safeChars[])`

Encodes a string for use in URLs using percent-encoding.

**Parameters:**
- `buffer[]` - String to encode
- `safeChars[]` - Additional characters to leave unencoded

**Returns:** Encoded string

**Example:**
```netlinx
stack_var char original[100]
stack_var char encoded[NAV_MAX_BUFFER]

original = 'Hello World!'
encoded = NAVUrlEncode(original, '')
// Result: 'Hello%20World%21'
```

#### `NAVUrlDecode(buffer[])`

Decodes a percent-encoded URL string.

**Parameters:**
- `buffer[]` - String to decode

**Returns:** Decoded string

**Example:**
```netlinx
stack_var char encoded[100]
stack_var char decoded[NAV_MAX_BUFFER]

encoded = 'Hello%20World%21'
decoded = NAVUrlDecode(encoded)
// Result: 'Hello World!'
```

### URL Validation

#### `NAVUrlIsValidPort(port)`

Validates that a port number is within the valid range (1-65535).

**Parameters:**
- `port` - Port number to validate

**Returns:** TRUE if valid, FALSE otherwise

#### `NAVUrlIsValidScheme(scheme[])`

Validates that a scheme follows the correct format (starts with ALPHA, contains only ALPHA/DIGIT/+/-/.) .

**Parameters:**
- `scheme[]` - Scheme to validate

**Returns:** TRUE if valid, FALSE otherwise

#### `NAVValidateUrl(buffer[], allowedSchemes[][], requireScheme, requireHost)`

Comprehensive URL validation with customizable requirements.

**Parameters:**
- `buffer[]` - URL string to validate
- `allowedSchemes[][]` - Array of allowed schemes (empty array = no scheme validation)
- `requireScheme` - Whether scheme is required
- `requireHost` - Whether host is required

**Returns:** TRUE if valid, FALSE otherwise

**Examples:**
```netlinx
// Validate HTTPS URL
stack_var char schemes[1][10]
schemes[1] = 'https'
result = NAVValidateUrl('https://example.com', schemes, true, true)

// Validate any HTTP-like URL
stack_var char schemes[2][10]
schemes[1] = 'http'
schemes[2] = 'https'
result = NAVValidateUrl('http://example.com:8080/path', schemes, true, true)
```

### URL Parsing

#### `NAVParseUrl(buffer[], url)`

Parses a URL string into a structured `_NAVUrl` object.

**Parameters:**
- `buffer[]` - URL string to parse
- `url` - `_NAVUrl` structure to populate

**Returns:** TRUE if parsing successful, FALSE otherwise

**Example:**
```netlinx
stack_var char urlString[NAV_MAX_BUFFER]
stack_var _NAVUrl parsedUrl

urlString = 'https://user:pass@example.com:8080/path/to/resource?param=value&other=test#section'
if (NAVParseUrl(urlString, parsedUrl)) {
    // parsedUrl.Scheme = 'https'
    // parsedUrl.UserInfo = 'user:pass'
    // parsedUrl.Host = 'example.com'
    // parsedUrl.Port = 8080
    // parsedUrl.Path = '/path/to/resource'
    // parsedUrl.Queries[1].Key = 'param'
    // parsedUrl.Queries[1].Value = 'value'
    // parsedUrl.Queries[2].Key = 'other'
    // parsedUrl.Queries[2].Value = 'test'
    // parsedUrl.Fragment = 'section'
}
```

#### `NAVParseQueryString(buffer[], queries[])`

Parses a query string into key-value pairs.

**Parameters:**
- `buffer[]` - Query string (without leading '?')
- `queries[]` - Array of `_NAVKeyStringValuePair` to populate

**Example:**
```netlinx
stack_var char queryString[100]
stack_var _NAVKeyStringValuePair queries[NAV_URL_MAX_QUERIES]

queryString = 'param1=value1&param2=value2&param3='
NAVParseQueryString(queryString, queries)
// queries[1].Key = 'param1', queries[1].Value = 'value1'
// queries[2].Key = 'param2', queries[2].Value = 'value2'
// queries[3].Key = 'param3', queries[3].Value = ''
```

### URL Building

#### `NAVBuildUrl(url)`

Constructs a URL string from a `_NAVUrl` structure.

**Parameters:**
- `url` - `_NAVUrl` structure containing URL components

**Returns:** Complete URL string

**Example:**
```netlinx
stack_var _NAVUrl url
stack_var char result[NAV_MAX_BUFFER]

url.Scheme = 'https'
url.Host = 'example.com'
url.Port = 8080
url.Path = '/api/v1/users'
url.Queries[1].Key = 'limit'
url.Queries[1].Value = '10'
set_length_array(url.Queries, 1)
url.Fragment = 'results'

result = NAVBuildUrl(url)
// Result: 'https://example.com:8080/api/v1/users?limit=10#results'
```

### URL Resolution

#### `NAVResolveUrl(base[], reference[])`

Resolves a relative URL reference against a base URL per RFC 3986 Section 5.

**Parameters:**
- `base[]` - Base URL string
- `reference[]` - Relative or absolute URL reference

**Returns:** Resolved absolute URL string

**Examples:**
```netlinx
// Relative path
result = NAVResolveUrl('http://example.com/a/b/c', '../d')
// Result: 'http://example.com/a/d'

// Absolute path
result = NAVResolveUrl('http://example.com/a/b/c', '/x/y')
// Result: 'http://example.com/x/y'

// Protocol-relative
result = NAVResolveUrl('https://example.com/path', '//other.com/file')
// Result: 'https://other.com/file'

// Query replacement
result = NAVResolveUrl('http://example.com/path?old=1', '?new=2')
// Result: 'http://example.com/path?new=2'

// Fragment replacement
result = NAVResolveUrl('http://example.com/page#old', '#new')
// Result: 'http://example.com/page#new'
```

### Path and Encoding Utilities

#### `NAVUrlNormalizePath(path[])`

Normalizes a URL path by removing dot segments (`.` and `..`).

**Parameters:**
- `path[]` - Path to normalize

**Returns:** Normalized path

**Examples:**
```netlinx
result = NAVUrlNormalizePath('/a/b/../c/./d')
// Result: '/a/c/d'

result = NAVUrlNormalizePath('/a/b/../../../c')
// Result: '/c'
```

#### `NAVUrlGetDefaultPort(scheme[])`

Returns the default port for a given scheme.

**Parameters:**
- `scheme[]` - URL scheme

**Returns:** Default port number (0 if no default)

**Examples:**
```netlinx
port = NAVUrlGetDefaultPort('http')    // Returns 80
port = NAVUrlGetDefaultPort('https')   // Returns 443
port = NAVUrlGetDefaultPort('ftp')     // Returns 21
port = NAVUrlGetDefaultPort('custom')  // Returns 0
```

## Usage Patterns

### Basic URL Parsing and Validation

```netlinx
define_function integer ProcessUrl(char urlString[]) {
    stack_var _NAVUrl url
    stack_var char schemes[2][10]

    // Set up allowed schemes
    schemes[1] = 'http'
    schemes[2] = 'https'
    set_length_array(schemes, 2)

    // Validate URL
    if (!NAVValidateUrl(urlString, schemes, true, true)) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Invalid URL: ', urlString")
        return false
    }

    // Parse URL
    if (!NAVParseUrl(urlString, url)) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Failed to parse URL: ', urlString")
        return false
    }

    // Process components
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Host: ', url.Host")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Path: ', url.Path")

    return true
}
```

### Building URLs with Query Parameters

```netlinx
define_function char[NAV_MAX_BUFFER] BuildApiUrl(char baseUrl[], char endpoint[], char params[][], integer paramCount) {
    stack_var _NAVUrl url
    stack_var integer i

    // Parse base URL
    NAVParseUrl(baseUrl, url)

    // Set path
    url.Path = endpoint

    // Add query parameters
    for (i = 1; i <= paramCount; i++) {
        url.Queries[i].Key = params[i][1]    // Key
        url.Queries[i].Value = params[i][2]  // Value
    }
    set_length_array(url.Queries, paramCount)

    return NAVBuildUrl(url)
}
```

### URL Resolution for Web Scraping

```netlinx
define_function char[NAV_MAX_BUFFER] ResolveLink(char baseUrl[], char link[]) {
    stack_var char resolved[NAV_MAX_BUFFER]

    resolved = NAVResolveUrl(baseUrl, link)

    // Validate the resolved URL
    if (!NAVValidateUrl(resolved, ''', false, true)) {
        NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'Invalid resolved URL: ', resolved")
        return ''
    }

    return resolved
}
```

## Standards Compliance

- **RFC 3986**: Uniform Resource Identifier (URI): Generic Syntax
- **RFC 6335**: Internet Assigned Numbers Authority (IANA) Procedures for the Management of the Service Name and Transport Protocol Port Number Registry
- **WHATWG URL Specification**: Compatible with modern web URL parsing
- **C# System.Uri**: Compatible behavior for .NET interoperability

## Error Handling

The library uses the NAVFoundation error logging system for reporting issues:

- Invalid URL formats
- Port numbers out of range (1-65535)
- Malformed schemes
- Encoding/decoding errors

All parsing functions return boolean success indicators, and validation functions provide detailed error information through the logging system.

## Performance Considerations

- URL parsing is optimized for typical web URLs
- Query parameter arrays are limited to `NAV_URL_MAX_QUERIES` (configurable)
- String operations use NAVFoundation's efficient string utilities
- Memory usage scales with URL complexity and query parameter count

## Constants

Key constants defined in the header file:

- `NAV_MAX_URL_SCHEME`: Maximum scheme length (32)
- `NAV_MAX_URL_HOST`: Maximum host length (253)
- `NAV_MAX_URL_USERINFO`: Maximum user info length (255)
- `NAV_URL_MAX_QUERIES`: Maximum query parameters (50)
- `NAV_MAX_BUFFER`: General buffer size (2048)
