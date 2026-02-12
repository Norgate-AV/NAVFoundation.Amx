# NAVFoundation.Json

A comprehensive JSON parser and query library for AMX NetLinx, providing RFC 8259-compliant JSON parsing with a JQ-inspired query syntax for easy data extraction.

## Features

- **RFC 8259 Compliant**: Full JSON specification support (objects, arrays, strings, numbers, booleans, null)
- **Zero-Copy String Storage**: All values stored as strings and parsed on-demand for maximum precision
- **JQ-Inspired Query Syntax**: Simple dot-notation path queries for easy value extraction (`.user.name`, `.data[0].value`)
- **Type-Safe Value Extraction**: Dedicated query functions for each NetLinx type (integer, long, float, string, boolean)
- **Tree Navigation**: Low-level API for manual tree traversal and inspection
- **Comprehensive Error Handling**: Detailed error messages with line/column information
- **Configurable Limits**: Adjust token counts, node limits, and buffer sizes for your needs

## Table of Contents

- [Quick Start](#quick-start)
- [Query System](#query-system)
- [Public API](#public-api)
    - [Core Parsing](#core-parsing)
    - [Query Functions](#query-functions)
    - [Tree Navigation](#tree-navigation)
    - [Type Checking](#type-checking)
    - [Value Getters](#value-getters)
    - [Object/Array Helpers](#objectarray-helpers)
    - [Error Handling](#error-handling)
- [Configuration](#configuration)
- [Examples](#examples)
- [Limitations](#limitations)

---

## Quick Start

### Basic Parsing and Querying

```netlinx
#include 'NAVFoundation.Json.axi'

stack_var _NAVJson json
stack_var char response[2048]
stack_var char name[255]
stack_var integer age

// Sample JSON response
response = '{"user":{"name":"John","age":30},"active":true}'

// Parse JSON
if (NAVJsonParse(response, json)) {
    // Query values using dot notation
    if (NAVJsonQueryString(json, '.user.name', name)) {
        send_string 0, "'Name: ', name"  // Output: Name: John
    }

    if (NAVJsonQueryInteger(json, '.user.age', age)) {
        send_string 0, "'Age: ', itoa(age)"  // Output: Age: 30
    }
} else {
    send_string 0, "'Parse error: ', NAVJsonGetError(json)"
}
```

### Array Access

```netlinx
stack_var _NAVJson json
stack_var char jsonData[1024]
stack_var integer ports[10]

jsonData = '{"servers":[{"port":8080},{"port":8081},{"port":8082}]}'

if (NAVJsonParse(jsonData, json)) {
    stack_var char value[255]

    // Access array elements using [index] notation (0-based)
    if (NAVJsonQueryString(json, '.servers[0].port', value)) {
        send_string 0, "'First port: ', value"  // Output: First port: 8080
    }
}
```

---

## Query System

The library provides a **JQ-inspired query syntax** for accessing values in parsed JSON. This is a **simplified subset** focused on basic value extraction - it does not include filtering, functions, or complex transformations like the full JQ language.

### Query Syntax

| Pattern                | Description                    | Example                                  |
| ---------------------- | ------------------------------ | ---------------------------------------- |
| `.property`            | Access object property         | `.name` → `"John"`                       |
| `.property.nested`     | Access nested property         | `.user.email` → `"john@example.com"`     |
| `.[index]`             | Access array element (0-based) | `.[0]` → first element                   |
| `.array[index]`        | Access nested array element    | `.data[2].value` → third element's value |
| `.deep.nested[0].path` | Combined access                | `.users[0].addresses[1].city`            |

### What's Supported

✅ **Property access** - `.property`, `.nested.property`  
✅ **Array indexing** - `.[0]`, `.array[5]`  
✅ **Combined paths** - `.data[0].items[2].name`  
✅ **Numeric literals** - Any non-negative integer index

### What's NOT Supported

❌ **Filtering** - `.[] | select(.age > 30)` - Not supported  
❌ **Functions** - `length`, `keys`, `map`, etc. - Not supported  
❌ **Pipes** - `.data | .values` - Not supported  
❌ **Array slicing** - `.[0:5]` - Not supported  
❌ **Wildcards** - `.[]` (all elements) - Not supported  
❌ **Recursive descent** - `..property` - Not supported

> **Note**: This is a **value extraction system**, not a transformation language. Use the query functions to retrieve values, then process them in NetLinx code.

### Query Examples

```netlinx
// Simple property access
NAVJsonQueryString(json, '.name', result)                    // Get string
NAVJsonQueryInteger(json, '.age', result)                    // Get integer
NAVJsonQueryBoolean(json, '.active', result)                 // Get boolean

// Nested object access
NAVJsonQueryString(json, '.user.email', result)              // Nested property
NAVJsonQueryFloat(json, '.settings.temperature', result)     // Nested number

// Array access (0-based indexing)
NAVJsonQueryString(json, '.users[0].name', result)           // First user's name
NAVJsonQueryInteger(json, '.data[5].value', result)          // Sixth item's value
NAVJsonQueryFloat(json, '.measurements[10].temp', result)    // Eleventh measurement

// Deep nesting
NAVJsonQueryString(json, '.company.departments[2].employees[0].name', result)

// Array extraction (entire array to NetLinx array)
stack_var integer ports[50]
NAVJsonQueryIntegerArray(json, '.config.ports', ports)       // Get all ports
```

---

## Public API

### Core Parsing

#### `NAVJsonParse`

Parse a JSON string into a node tree structure.

```netlinx
define_function char NAVJsonParse(char input[], _NAVJson json)
```

**Parameters:**

- `input` - The JSON string to parse
- `json` - Output parameter to receive the parsed structure

**Returns:** `true` if parsing succeeded, `false` on error

**Example:**

```netlinx
stack_var _NAVJson json
if (NAVJsonParse('{"key":"value"}', json)) {
    // Success - query or navigate the tree
} else {
    send_string 0, "'Error: ', NAVJsonGetError(json)"
}
```

---

### Query Functions

#### Single Value Queries

Query functions extract typed values from JSON using path notation. All return `false` if the path doesn't exist, the type doesn't match, or the value is null.

##### `NAVJsonQuery`

Get the raw node at a path (for advanced use).

```netlinx
define_function char NAVJsonQuery(_NAVJson json, char query[], _NAVJsonNode result)
```

##### `NAVJsonQueryString`

Query for a string value.

```netlinx
define_function char NAVJsonQueryString(_NAVJson json, char query[], char result[])
```

**Example:**

```netlinx
stack_var char name[255]
if (NAVJsonQueryString(json, '.user.name', name)) {
    send_string 0, "'Name: ', name"
}
```

##### `NAVJsonQueryInteger`

Query for an unsigned 16-bit integer (0-65535).

```netlinx
define_function char NAVJsonQueryInteger(_NAVJson json, char query[], integer result)
```

##### `NAVJsonQuerySignedInteger`

Query for a signed 16-bit integer (-32768 to 32767).

```netlinx
define_function char NAVJsonQuerySignedInteger(_NAVJson json, char query[], sinteger result)
```

##### `NAVJsonQueryLong`

Query for an unsigned 32-bit integer (0-4294967295).

```netlinx
define_function char NAVJsonQueryLong(_NAVJson json, char query[], long result)
```

##### `NAVJsonQuerySignedLong`

Query for a signed 32-bit integer (-2147483648 to 2147483647).

```netlinx
define_function char NAVJsonQuerySignedLong(_NAVJson json, char query[], slong result)
```

##### `NAVJsonQueryFloat`

Query for a floating-point number.

```netlinx
define_function char NAVJsonQueryFloat(_NAVJson json, char query[], float result)
```

**Example:**

```netlinx
stack_var float temperature
if (NAVJsonQueryFloat(json, '.sensor.temperature', temperature)) {
    send_string 0, "'Temp: ', ftoa(temperature)"
}
```

##### `NAVJsonQueryBoolean`

Query for a boolean value. Returns `false` for null values.

```netlinx
define_function char NAVJsonQueryBoolean(_NAVJson json, char query[], char result)
```

**Example:**

```netlinx
stack_var char isActive
if (NAVJsonQueryBoolean(json, '.user.active', isActive)) {
    if (isActive) {
        // User is active
    }
}
```

#### Array Queries

Query functions that extract entire arrays into NetLinx arrays. All array elements must be of the same type (homogeneous arrays).

##### `NAVJsonQueryStringArray`

```netlinx
define_function char NAVJsonQueryStringArray(_NAVJson json, char query[], char result[][])
```

**Example:**

```netlinx
stack_var char names[50][255]
if (NAVJsonQueryStringArray(json, '.users.names', names)) {
    stack_var integer i
    for (i = 1; i <= length_array(names); i++) {
        send_string 0, "'Name: ', names[i]"
    }
}
```

##### `NAVJsonQueryIntegerArray`

```netlinx
define_function char NAVJsonQueryIntegerArray(_NAVJson json, char query[], integer result[])
```

##### `NAVJsonQuerySignedIntegerArray`

```netlinx
define_function char NAVJsonQuerySignedIntegerArray(_NAVJson json, char query[], sinteger result[])
```

##### `NAVJsonQueryLongArray`

```netlinx
define_function char NAVJsonQueryLongArray(_NAVJson json, char query[], long result[])
```

##### `NAVJsonQuerySignedLongArray`

```netlinx
define_function char NAVJsonQuerySignedLongArray(_NAVJson json, char query[], slong result[])
```

##### `NAVJsonQueryFloatArray`

```netlinx
define_function char NAVJsonQueryFloatArray(_NAVJson json, char query[], float result[])
```

**Example:**

```netlinx
stack_var float temperatures[100]
if (NAVJsonQueryFloatArray(json, '.data.temperatures', temperatures)) {
    send_string 0, "'Count: ', itoa(length_array(temperatures))"
}
```

##### `NAVJsonQueryBooleanArray`

```netlinx
define_function char NAVJsonQueryBooleanArray(_NAVJson json, char query[], char result[])
```

---

### Tree Navigation

Low-level functions for manually traversing the JSON tree structure.

##### `NAVJsonGetRootNode`

Get the root node of the JSON document.

```netlinx
define_function char NAVJsonGetRootNode(_NAVJson json, _NAVJsonNode node)
```

##### `NAVJsonGetParentNode`

Get the parent of a node. Returns `false` if the node is the root.

```netlinx
define_function char NAVJsonGetParentNode(_NAVJson json, _NAVJsonNode currentNode, _NAVJsonNode parentNode)
```

##### `NAVJsonGetFirstChild`

Get the first child of an object or array node.

```netlinx
define_function char NAVJsonGetFirstChild(_NAVJson json, _NAVJsonNode parentNode, _NAVJsonNode childNode)
```

##### `NAVJsonGetNextNode`

Get the next sibling of a node.

```netlinx
define_function char NAVJsonGetNextNode(_NAVJson json, _NAVJsonNode currentNode, _NAVJsonNode nextNode)
```

**Example - Iterate over object properties:**

```netlinx
stack_var _NAVJsonNode root, child
NAVJsonGetRootNode(json, root)

if (NAVJsonGetFirstChild(json, root, child)) {
    send_string 0, "'Key: ', child.key, ', Value: ', child.value"

    while (NAVJsonGetNextNode(json, child, child)) {
        send_string 0, "'Key: ', child.key, ', Value: ', child.value"
    }
}
```

---

### Type Checking

Functions to check the type of a JSON node.

```netlinx
define_function char NAVJsonIsObject(_NAVJsonNode node)
define_function char NAVJsonIsArray(_NAVJsonNode node)
define_function char NAVJsonIsString(_NAVJsonNode node)
define_function char NAVJsonIsNumber(_NAVJsonNode node)
define_function char NAVJsonIsBoolean(_NAVJsonNode node)
define_function char NAVJsonIsTrue(_NAVJsonNode node)
define_function char NAVJsonIsFalse(_NAVJsonNode node)
define_function char NAVJsonIsNull(_NAVJsonNode node)
```

**Example:**

```netlinx
stack_var _NAVJsonNode node
if (NAVJsonQuery(json, '.data', node)) {
    if (NAVJsonIsArray(node)) {
        send_string 0, "'Data is an array'"
    } else if (NAVJsonIsObject(node)) {
        send_string 0, "'Data is an object'"
    }
}
```

---

### Value Getters

Extract typed values from nodes (lower-level than query functions).

```netlinx
define_function char NAVJsonGetString(_NAVJsonNode node, char result[])
define_function char NAVJsonGetNumber(_NAVJsonNode node, float result)
define_function char NAVJsonGetBoolean(_NAVJsonNode node, char result)
define_function char[64] NAVJsonGetKey(_NAVJsonNode node)
```

**Example:**

```netlinx
stack_var _NAVJsonNode node
stack_var char value[255]

if (NAVJsonQuery(json, '.user.email', node)) {
    if (NAVJsonGetString(node, value)) {
        send_string 0, "'Email: ', value"
    }
}
```

---

### Object/Array Helpers

Functions for working with objects and arrays.

##### `NAVJsonGetPropertyByKey`

Get an object property by key name.

```netlinx
define_function char NAVJsonGetPropertyByKey(_NAVJson json, _NAVJsonNode parentNode, char key[], _NAVJsonNode result)
```

##### `NAVJsonHasProperty`

Check if an object has a specific property.

```netlinx
define_function char NAVJsonHasProperty(_NAVJson json, _NAVJsonNode parentNode, char key[])
```

##### `NAVJsonGetArrayElement`

Get an array element by index (0-based).

```netlinx
define_function char NAVJsonGetArrayElement(_NAVJson json, _NAVJsonNode arrayNode, integer index, _NAVJsonNode result)
```

##### `NAVJsonGetChildCount`

Get the number of children (object properties or array elements).

```netlinx
define_function integer NAVJsonGetChildCount(_NAVJsonNode node)
```

**Example:**

```netlinx
stack_var _NAVJsonNode arrayNode
stack_var integer count

if (NAVJsonQuery(json, '.users', arrayNode)) {
    count = NAVJsonGetChildCount(arrayNode)
    send_string 0, "'User count: ', itoa(count)"
}
```

##### Array Conversion Helpers

Convert entire JSON arrays to NetLinx arrays:

```netlinx
define_function char NAVJsonToStringArray(_NAVJson json, _NAVJsonNode arrayNode, char result[][])
define_function char NAVJsonToFloatArray(_NAVJson json, _NAVJsonNode arrayNode, float result[])
define_function char NAVJsonToIntegerArray(_NAVJson json, _NAVJsonNode arrayNode, integer result[])
define_function char NAVJsonToSignedIntegerArray(_NAVJson json, _NAVJsonNode arrayNode, sinteger result[])
define_function char NAVJsonToLongArray(_NAVJson json, _NAVJsonNode arrayNode, long result[])
define_function char NAVJsonToSignedLongArray(_NAVJson json, _NAVJsonNode arrayNode, slong result[])
define_function char NAVJsonToBooleanArray(_NAVJson json, _NAVJsonNode arrayNode, char result[])
```

---

### Error Handling

##### `NAVJsonIsValid`

Check if JSON parsing was successful.

```netlinx
define_function char NAVJsonIsValid(_NAVJson json)
```

##### `NAVJsonGetError`

Get the error message from a failed parse.

```netlinx
define_function char[255] NAVJsonGetError(_NAVJson json)
```

##### `NAVJsonGetErrorLine`

Get the line number where the error occurred.

```netlinx
define_function integer NAVJsonGetErrorLine(_NAVJson json)
```

##### `NAVJsonGetErrorColumn`

Get the column number where the error occurred.

```netlinx
define_function integer NAVJsonGetErrorColumn(_NAVJson json)
```

**Example:**

```netlinx
if (!NAVJsonParse(input, json)) {
    send_string 0, "'Parse failed at line ', itoa(NAVJsonGetErrorLine(json)),
                    ', column ', itoa(NAVJsonGetErrorColumn(json)),
                    ': ', NAVJsonGetError(json)"
}
```

---

### Tree Information

##### `NAVJsonGetNodeCount`

Get the total number of nodes in the JSON tree.

```netlinx
define_function integer NAVJsonGetNodeCount(_NAVJson json)
```

##### `NAVJsonGetMaxDepth`

Get the maximum nesting depth of the JSON structure.

```netlinx
define_function sinteger NAVJsonGetMaxDepth(_NAVJson json)
```

---

### Utility Functions

##### `NAVJsonEscapeString`

Escape special characters in a string for JSON serialization.

```netlinx
define_function char[255] NAVJsonEscapeString(char value[])
```

**Example:**

```netlinx
stack_var char escaped[512]
escaped = NAVJsonEscapeString('Hello "World"')  // Returns: Hello \"World\"
```

##### `NAVJsonGetNodeType`

Get a human-readable string for a node type constant.

```netlinx
define_function char[16] NAVJsonGetNodeType(integer type)
```

---

## Configuration

The library provides several configuration constants that can be overridden before including the library files.

### Lexer Configuration

```netlinx
// Maximum number of tokens (default: 1000)
// Each structural element and value requires a token
// Example: [1,2,3] requires 7 tokens: [ 1 , 2 , 3 ]
#DEFINE NAV_JSON_LEXER_MAX_TOKENS 1000

// Maximum source input size in bytes (default: 4096)
#DEFINE NAV_JSON_LEXER_MAX_SOURCE 4096

// Maximum token value length (default: 255)
#DEFINE NAV_JSON_LEXER_MAX_TOKEN_LENGTH 255
```

### Parser Configuration

```netlinx
// Maximum number of nodes in the tree (default: 1000)
// Each JSON value (object, array, string, number, boolean, null) requires one node
#DEFINE NAV_JSON_PARSER_MAX_NODES 1000

// Maximum object key length (default: 64)
#DEFINE NAV_JSON_PARSER_MAX_KEY_LENGTH 64

// Maximum string value length (default: 255)
#DEFINE NAV_JSON_PARSER_MAX_STRING_LENGTH 255

// Maximum nesting depth (default: 32)
#DEFINE NAV_JSON_PARSER_MAX_DEPTH 32
```

### Query Configuration

```netlinx
// Maximum query path complexity (default: 50)
#DEFINE NAV_JSON_QUERY_MAX_TOKENS 50

// Maximum path step count (default: 25)
#DEFINE NAV_JSON_QUERY_MAX_PATH_STEPS 25

// Maximum identifier length in query paths (default: 64)
#DEFINE NAV_JSON_QUERY_MAX_IDENTIFIER_LENGTH 64
```

### Example: Custom Configuration

```netlinx
// Define custom limits BEFORE including the library
#DEFINE NAV_JSON_LEXER_MAX_TOKENS 2000        // Handle larger documents
#DEFINE NAV_JSON_PARSER_MAX_STRING_LENGTH 512  // Support longer strings

#include 'NAVFoundation.Json.axi'
```

---

## Examples

### Example 1: REST API Response Processing

```netlinx
stack_var _NAVJson json
stack_var char response[4096]
stack_var char status[255]
stack_var integer code
stack_var char message[512]

// Simulated API response
response = '{
    "status": "success",
    "code": 200,
    "data": {
        "message": "Device configured successfully",
        "timestamp": 1640000000
    }
}'

if (NAVJsonParse(response, json)) {
    NAVJsonQueryString(json, '.status', status)
    NAVJsonQueryInteger(json, '.code', code)
    NAVJsonQueryString(json, '.data.message', message)

    if (code == 200) {
        send_string 0, "'Success: ', message"
    }
}
```

### Example 2: Processing Configuration Arrays

```netlinx
stack_var _NAVJson json
stack_var char config[2048]
stack_var integer ports[50]
stack_var char ips[50][255]
stack_var integer i

config = '{
    "servers": [
        {"ip": "192.168.1.100", "port": 8080},
        {"ip": "192.168.1.101", "port": 8081},
        {"ip": "192.168.1.102", "port": 8082}
    ]
}'

if (NAVJsonParse(config, json)) {
    // Extract individual values with specific indices
    for (i = 0; i < 3; i++) {
        stack_var char query[128]
        stack_var char ip[255]
        stack_var integer port

        query = "'.servers[', itoa(i), '].ip'"
        NAVJsonQueryString(json, query, ip)

        query = "'.servers[', itoa(i), '].port'"
        NAVJsonQueryInteger(json, query, port)

        send_string 0, "'Server ', itoa(i + 1), ': ', ip, ':', itoa(port)"
    }
}
```

### Example 3: Tree Navigation

```netlinx
stack_var _NAVJson json
stack_var char data[1024]
stack_var _NAVJsonNode root, child

data = '{"name":"John","age":30,"active":true}'

if (NAVJsonParse(data, json)) {
    // Get root and iterate through all properties
    NAVJsonGetRootNode(json, root)

    send_string 0, "'Object properties:'"
    if (NAVJsonGetFirstChild(json, root, child)) {
        send_string 0, "'  ', child.key, ' = ', child.value"

        while (NAVJsonGetNextNode(json, child, child)) {
            send_string 0, "'  ', child.key, ' = ', child.value"
        }
    }
}
```

### Example 4: Type Checking and Conditional Processing

```netlinx
stack_var _NAVJson json
stack_var _NAVJsonNode node
stack_var char response[1024]

response = '{"data": [1, 2, 3, 4, 5]}'

if (NAVJsonParse(response, json)) {
    if (NAVJsonQuery(json, '.data', node)) {
        if (NAVJsonIsArray(node)) {
            stack_var integer values[100]
            if (NAVJsonToIntegerArray(json, node, values)) {
                send_string 0, "'Array has ', itoa(length_array(values)), ' elements'"
            }
        } else if (NAVJsonIsObject(node)) {
            send_string 0, "'Data is an object'"
        } else if (NAVJsonIsString(node)) {
            stack_var char str[255]
            NAVJsonGetString(node, str)
            send_string 0, "'Data is string: ', str"
        }
    }
}
```

### Example 5: Error Handling

```netlinx
stack_var _NAVJson json
stack_var char badJson[512]

badJson = '{"name": "John", "age": 30'  // Missing closing brace

if (NAVJsonParse(badJson, json)) {
    // Parse successful
} else {
    // Handle error
    send_string 0, "'JSON Parse Error:'"
    send_string 0, "'  Line: ', itoa(NAVJsonGetErrorLine(json))"
    send_string 0, "'  Column: ', itoa(NAVJsonGetErrorColumn(json))"
    send_string 0, "'  Message: ', NAVJsonGetError(json)"
}
```

---

## Limitations

### Design Constraints

1. **Fixed-size Buffers**: All structures use pre-allocated arrays. Adjust configuration constants for larger documents.

2. **String Value Length**: Values are truncated to `NAV_JSON_PARSER_MAX_STRING_LENGTH` (default: 255 characters).

3. **No Unicode Escape Decoding**: Unicode escape sequences (`\uXXXX`) are preserved as-is, not decoded to actual characters.

4. **No Mixed-Type Arrays**: Array conversion functions require homogeneous arrays (all elements same type).

5. **Query Syntax Limitations**: No filtering, functions, or transformations - only path-based value extraction.

### Performance Considerations

- **Large Documents**: Parsing large JSON documents (>100KB) may be slow due to NetLinx's interpreted nature.
- **Deep Nesting**: Very deep nesting (>15 levels) impacts performance due to recursive tree traversal.
- **Array Processing**: Processing large arrays (>500 elements) is slower than accessing individual properties.

### JSON Specification Compliance

- ✅ **Supports**: Objects, arrays, strings, numbers, booleans, null, escape sequences
- ✅ **Validates**: Proper structure, matching braces/brackets, commas, colons
- ⚠️ **Limitations**: No unicode escape decoding, trailing commas not allowed (per spec)

---

## License

MIT License - Copyright (c) 2010-2026 Norgate AV

---

## Support

For issues, questions, or contributions, please visit the [NAVFoundation.Amx repository](https://github.com/Norgate-AV/NAVFoundation.Amx).
