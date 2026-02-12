# NAVFoundation.Yaml

A comprehensive YAML parser and query library for AMX NetLinx, providing 100% YAML 1.2 Core Schema compliant parsing with a yq-inspired query syntax for easy data extraction.

## Features

- **100% YAML 1.2 Core Schema Compliant**: Complete specification support with 508 automated tests
- **Zero-Copy String Storage**: All values stored as strings and parsed on-demand for maximum precision
- **yq-Inspired Query Syntax**: Simple dot-notation path queries for easy value extraction (`.property`, `.items[1]`)
- **Type-Safe Value Extraction**: Dedicated query functions for each NetLinx type (integer, long, float, string, boolean)
- **Indentation-Based Structure**: Native YAML indentation parsing
- **Block Scalars**: Support for literal (`|`) and folded (`>`) block scalars with chomping indicators (`-`, `+`)
- **Escape Sequences**: Full support for `\n`, `\t`, `\x##`, `\u####`, `\U########` and all YAML 1.2 escapes
- **Anchors & Aliases**: Reference reuse with `&anchor` and `*alias` syntax
- **Merge Keys**: DRY configuration with `<<: *anchor` and `<<: [*a, *b]` array merges
- **Directives**: Support for `%YAML 1.2` and `%TAG` directives
- **Type Tags**: Explicit typing with `!!str`, `!!int`, `!!bool`, and custom tags
- **Explicit Keys**: Complex key support with `?` syntax
- **Multi-Document Support**: Parse multiple YAML documents in one stream
- **Flow Style**: Support for JSON-like flow sequences `[...]` and mappings `{...}`
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
    - [Error Handling](#error-handling)
- [Configuration](#configuration)
- [YAML-Specific Features](#yaml-specific-features)
- [Examples](#examples)
- [Limitations](#limitations)

---

## Quick Start

### Basic Parsing and Querying

```netlinx
#include 'NAVFoundation.Yaml.axi'

stack_var _NAVYaml yaml
stack_var char config[2048]
stack_var char hostname[255]
stack_var integer port

// Sample YAML configuration
config = "'
config:
  server:
    host: 192.168.1.100
    port: 8080
  debug: true
'"

// Parse YAML
if (NAVYamlParse(config, yaml)) {
    // Query values using dot notation
    if (NAVYamlQueryString(yaml, '.config.server.host', hostname)) {
        send_string 0, "'Host: ', hostname"  // Output: Host: 192.168.1.100
    }

    if (NAVYamlQueryInteger(yaml, '.config.server.port', port)) {
        send_string 0, "'Port: ', itoa(port)"  // Output: Port: 8080
    }
} else {
    send_string 0, "'Parse error: ', NAVYamlGetError(yaml)"
}
```

### Sequence (Array) Access

```netlinx
stack_var _NAVYaml yaml
stack_var char yamlData[1024]
stack_var char servers[10][128]

yamlData = "'
servers:
  - name: primary
    ip: 192.168.1.10
  - name: backup
    ip: 192.168.1.11
  - name: testing
    ip: 192.168.1.12
'"

if (NAVYamlParse(yamlData, yaml)) {
    stack_var char serverName[128]

    // Access sequence elements using [index] notation (1-based)
    if (NAVYamlQueryString(yaml, '.servers[1].name', serverName)) {
        send_string 0, "'First server: ', serverName"  // Output: First server: primary
    }

    if (NAVYamlQueryString(yaml, '.servers[2].ip', serverName)) {
        send_string 0, "'Backup IP: ', serverName"  // Output: Backup IP: 192.168.1.11
    }
}
```

---

## Query System

The library provides a **yq-inspired query syntax** for accessing values in parsed YAML. This is a **simplified subset** focused on basic value extraction - it does not include filtering, functions, or complex transformations like the full yq tool.

**Important:** The query system uses **1-based indexing** for sequence elements, matching NetLinx array conventions and YAML specification expectations. For example, `.[1]` accesses the first element, `.[2]` the second, etc.

### Query Syntax

| Pattern                | Description                       | Example                                  |
| ---------------------- | --------------------------------- | ---------------------------------------- |
| `.property`            | Access mapping key                | `.name` → `"John"`                       |
| `.property.nested`     | Access nested mapping             | `.user.email` → `"john@example.com"`     |
| `.[index]`             | Access sequence element (1-based) | `.[1]` → first element                   |
| `.array[index]`        | Access nested sequence element    | `.data[3].value` → third element's value |
| `.deep.nested[1].path` | Combined access                   | `.users[1].addresses[2].city`            |

### What's Supported

✅ **Property access** - `.property`, `.nested.property`  
✅ **Sequence indexing** - `.[1]`, `.items[5]` (1-based indexing)  
✅ **Combined paths** - `.data[1].items[3].name`  
✅ **Numeric literals** - Any positive integer index (1-based)

### What's NOT Supported

❌ **Filtering** - `.[] | select(.age > 30)` - Not supported  
❌ **Functions** - `length`, `keys`, `map`, etc. - Not supported  
❌ **Pipes** - `.data | .values` - Not supported  
❌ **Sequence slicing** - `.[1:5]` - Not supported  
❌ **Wildcards** - `.[]` (all elements) - Not supported in single queries  
❌ **Recursive descent** - `..property` - Not supported  
❌ **Zero or negative indices** - `.[0]`, `.[-1]` - Not supported (1-based indexing only)

> **Note**: This is a **value extraction system**, not a transformation language. Use the query functions to retrieve values, then process them in NetLinx code.

### Query Examples

```netlinx
// Simple property access
NAVYamlQueryString(yaml, '.name', result)                    // Get string
NAVYamlQueryInteger(yaml, '.age', result)                    // Get integer
NAVYamlQueryBoolean(yaml, '.active', result)                 // Get boolean

// Nested mapping access
NAVYamlQueryString(yaml, '.user.email', result)              // Nested property
NAVYamlQueryFloat(yaml, '.settings.temperature', result)     // Nested number

// Sequence access (1-based indexing)
NAVYamlQueryString(yaml, '.users[1].name', result)           // First user's name
NAVYamlQueryInteger(yaml, '.data[6].value', result)          // Sixth item's value
NAVYamlQueryFloat(yaml, '.measurements[11].temp', result)    // Eleventh measurement

// Deep nesting
NAVYamlQueryString(yaml, '.company.departments[3].employees[1].name', result)

// Sequence extraction (entire sequence to NetLinx array)
stack_var integer ports[50]
NAVYamlQueryIntegerArray(yaml, '.config.ports', ports)       // Get all ports
```

---

## Public API

### Core Parsing

#### `NAVYamlParse`

Parse a YAML string into a node tree structure.

```netlinx
define_function char NAVYamlParse(char input[], _NAVYaml yaml)
```

**Parameters:**

- `input` - The YAML string to parse
- `yaml` - Output parameter to receive the parsed structure

**Returns:** `true` if parsing succeeded, `false` on error

**Example:**

```netlinx
stack_var _NAVYaml yaml
if (NAVYamlParse('name: John\nage: 30', yaml)) {
    // Success - query or navigate the tree
} else {
    send_string 0, "'Error: ', NAVYamlGetError(yaml)"
}
```

---

### Query Functions

#### Single Value Queries

Query functions extract typed values from YAML using path notation. All return `false` if the path doesn't exist, the type doesn't match, or the value is null.

##### `NAVYamlQuery`

Get the raw node at a path (for advanced use).

```netlinx
define_function char NAVYamlQuery(_NAVYaml yaml, char query[], _NAVYamlNode result)
```

##### `NAVYamlQueryString`

Query for a string value.

```netlinx
define_function char NAVYamlQueryString(_NAVYaml yaml, char query[], char result[])
```

**Example:**

```netlinx
stack_var char name[255]
if (NAVYamlQueryString(yaml, '.user.name', name)) {
    send_string 0, "'Name: ', name"
}
```

##### `NAVYamlQueryInteger`

Query for an unsigned 16-bit integer (0-65535).

```netlinx
define_function char NAVYamlQueryInteger(_NAVYaml yaml, char query[], integer result)
```

##### `NAVYamlQuerySignedInteger`

Query for a signed 16-bit integer (-32768 to 32767).

```netlinx
define_function char NAVYamlQuerySignedInteger(_NAVYaml yaml, char query[], sinteger result)
```

##### `NAVYamlQueryLong`

Query for an unsigned 32-bit integer (0-4294967295).

```netlinx
define_function char NAVYamlQueryLong(_NAVYaml yaml, char query[], long result)
```

##### `NAVYamlQuerySignedLong`

Query for a signed 32-bit integer (-2147483648 to 2147483647).

```netlinx
define_function char NAVYamlQuerySignedLong(_NAVYaml yaml, char query[], slong result)
```

##### `NAVYamlQueryFloat`

Query for a floating-point number.

```netlinx
define_function char NAVYamlQueryFloat(_NAVYaml yaml, char query[], float result)
```

**Example:**

```netlinx
stack_var float temperature
if (NAVYamlQueryFloat(yaml, '.sensor.temperature', temperature)) {
    send_string 0, "'Temp: ', ftoa(temperature)"
}
```

##### `NAVYamlQueryDouble`

Query for a double-precision floating-point number.

```netlinx
define_function char NAVYamlQueryDouble(_NAVYaml yaml, char query[], double result)
```

##### `NAVYamlQueryBoolean`

Query for a boolean value. Recognizes YAML boolean variations: `true/false`, `yes/no`, `on/off`.

```netlinx
define_function char NAVYamlQueryBoolean(_NAVYaml yaml, char query[], char result)
```

**Example:**

```netlinx
stack_var char isActive
if (NAVYamlQueryBoolean(yaml, '.user.active', isActive)) {
    if (isActive) {
        // User is active
    }
}
```

#### Array Queries

Query functions that extract entire sequences into NetLinx arrays. All sequence elements should be of the same type (homogeneous sequences).

##### `NAVYamlQueryStringArray`

```netlinx
define_function char NAVYamlQueryStringArray(_NAVYaml yaml, char query[], char result[][])
```

**Example:**

```netlinx
stack_var char names[50][255]
if (NAVYamlQueryStringArray(yaml, '.users.names', names)) {
    stack_var integer i
    for (i = 1; i <= length_array(names); i++) {
        send_string 0, "'Name: ', names[i]"
    }
}
```

##### `NAVYamlQueryIntegerArray`

```netlinx
define_function char NAVYamlQueryIntegerArray(_NAVYaml yaml, char query[], integer result[])
```

##### `NAVYamlQueryFloatArray`

```netlinx
define_function char NAVYamlQueryFloatArray(_NAVYaml yaml, char query[], float result[])
```

**Example:**

```netlinx
stack_var float temperatures[100]
if (NAVYamlQueryFloatArray(yaml, '.data.temperatures', temperatures)) {
    send_string 0, "'Count: ', itoa(length_array(temperatures))"
}
```

##### `NAVYamlQueryBooleanArray`

```netlinx
define_function char NAVYamlQueryBooleanArray(_NAVYaml yaml, char query[], char result[])
```

---

### Tree Navigation

Low-level functions for manually traversing the YAML tree structure.

##### `NAVYamlGetRoot`

Get the root node of the YAML document.

```netlinx
define_function char NAVYamlGetRoot(_NAVYaml yaml, _NAVYamlNode node)
```

##### `NAVYamlGetParent`

Get the parent of a node. Returns `false` if the node is the root.

```netlinx
define_function char NAVYamlGetParent(_NAVYaml yaml, _NAVYamlNode node, _NAVYamlNode parent)
```

##### `NAVYamlGetFirstChild`

Get the first child of a mapping or sequence node.

```netlinx
define_function char NAVYamlGetFirstChild(_NAVYaml yaml, _NAVYamlNode parent, _NAVYamlNode child)
```

##### `NAVYamlGetNextSibling`

Get the next sibling of a node.

```netlinx
define_function char NAVYamlGetNextSibling(_NAVYaml yaml, _NAVYamlNode node, _NAVYamlNode sibling)
```

**Example - Iterate over mapping entries:**

```netlinx
stack_var _NAVYamlNode root, child
NAVYamlGetRoot(yaml, root)

if (NAVYamlGetFirstChild(yaml, root, child)) {
    send_string 0, "'Key: ', NAVYamlGetKey(child), ', Value: ', NAVYamlGetValue(child)"

    while (NAVYamlGetNextSibling(yaml, child, child)) {
        send_string 0, "'Key: ', NAVYamlGetKey(child), ', Value: ', NAVYamlGetValue(child)"
    }
}
```

---

### Type Checking

Functions to check the type of a YAML node.

```netlinx
define_function char NAVYamlIsMapping(_NAVYamlNode node)      // Check if mapping (object/dict)
define_function char NAVYamlIsSequence(_NAVYamlNode node)     // Check if sequence (array/list)
define_function char NAVYamlIsString(_NAVYamlNode node)       // Check if string scalar
define_function char NAVYamlIsNumber(_NAVYamlNode node)       // Check if numeric scalar
define_function char NAVYamlIsBoolean(_NAVYamlNode node)      // Check if boolean scalar
define_function char NAVYamlIsNull(_NAVYamlNode node)         // Check if null value
define_function char NAVYamlIsTimestamp(_NAVYamlNode node)    // Check if timestamp
```

**Example:**

```netlinx
stack_var _NAVYamlNode node
if (NAVYamlQuery(yaml, '.data', node)) {
    if (NAVYamlIsMapping(node)) {
        send_string 0, "'data is a mapping'"
    } else if (NAVYamlIsSequence(node)) {
        send_string 0, "'data is a sequence'"
    }
}
```

---

### Value Getters

Low-level functions to get typed values from nodes.

```netlinx
define_function char NAVYamlGetString(_NAVYamlNode node, char result[])
define_function integer NAVYamlGetInteger(_NAVYamlNode node)
define_function sinteger NAVYamlGetSignedInteger(_NAVYamlNode node)
define_function long NAVYamlGetLong(_NAVYamlNode node)
define_function slong NAVYamlGetSignedLong(_NAVYamlNode node)
define_function float NAVYamlGetFloat(_NAVYamlNode node)
define_function double NAVYamlGetDouble(_NAVYamlNode node)
define_function char NAVYamlGetBoolean(_NAVYamlNode node)
```

---

### Mapping/Sequence Helpers

```netlinx
define_function integer NAVYamlGetChildCount(_NAVYamlNode node)
define_function integer NAVYamlCountElements(_NAVYamlNode node)  // Alias for GetChildCount
define_function char NAVYamlGetKey(_NAVYamlNode node)
define_function char NAVYamlGetValue(_NAVYamlNode node)
define_function char NAVYamlGetTag(_NAVYamlNode node)
define_function char NAVYamlGetAnchor(_NAVYamlNode node)
```

---

### Error Handling

```netlinx
define_function char NAVYamlGetError(_NAVYaml yaml)
define_function integer NAVYamlGetErrorLine(_NAVYaml yaml)
define_function integer NAVYamlGetErrorColumn(_NAVYaml yaml)
```

**Example:**

```netlinx
if (!NAVYamlParse(input, yaml)) {
    send_string 0, "'Parse error at line ', itoa(NAVYamlGetErrorLine(yaml)),
                   ', column ', itoa(NAVYamlGetErrorColumn(yaml)),
                   ': ', NAVYamlGetError(yaml)"
}
```

---

### Tree Information

```netlinx
define_function integer NAVYamlGetNodeCount(_NAVYaml yaml)
define_function integer NAVYamlGetDepth(_NAVYaml yaml, _NAVYamlNode node)
```

---

## Configuration

### Lexer Configuration

```netlinx
#DEFINE NAV_YAML_LEXER_MAX_TOKENS      1000  // Maximum tokens
#DEFINE NAV_YAML_LEXER_MAX_TOKEN_LENGTH 255  // Maximum token length
#DEFINE NAV_YAML_LEXER_MAX_SOURCE      4096  // Maximum source length
#DEFINE NAV_YAML_LEXER_MAX_INDENT_LEVEL  32  // Maximum indentation depth
```

### Parser Configuration

```netlinx
#DEFINE NAV_YAML_PARSER_MAX_NODES        1000  // Maximum nodes in tree
#DEFINE NAV_YAML_PARSER_MAX_KEY_LENGTH     64  // Maximum key length
#DEFINE NAV_YAML_PARSER_MAX_VALUE_LENGTH  255  // Maximum value length
#DEFINE NAV_YAML_PARSER_MAX_DEPTH          32  // Maximum nesting depth
#DEFINE NAV_YAML_PARSER_MAX_ERROR_LENGTH  255  // Maximum error message length
#DEFINE NAV_YAML_PARSER_MAX_TAG_LENGTH     32  // Maximum tag length
#DEFINE NAV_YAML_PARSER_MAX_ANCHOR_LENGTH  32  // Maximum anchor name length
```

### Query Configuration

```netlinx
#DEFINE NAV_YAML_QUERY_MAX_TOKENS              50  // Maximum query tokens
#DEFINE NAV_YAML_QUERY_MAX_IDENTIFIER_LENGTH   64  // Maximum identifier length
#DEFINE NAV_YAML_QUERY_MAX_PATH_STEPS          25  // Maximum path steps
```

---

## YAML-Specific Features

### Block Scalars

YAML supports multi-line strings with special handling:

**Literal Block Scalar (`|`)** - Preserves newlines:

```yaml
description: |
    This is a literal block scalar.
    Newlines are preserved exactly.
    Great for multi-line text.
```

**Folded Block Scalar (`>`)** - Joins lines:

```yaml
summary: >
    This is a folded block scalar.
    Lines are joined with spaces.
    Empty lines create paragraphs.
```

### Anchors & Aliases

Reuse content with anchors and aliases:

```yaml
defaults: &defaults
    timeout: 30
    retries: 3

production:
    <<: *defaults
    host: prod.example.com

staging:
    <<: *defaults
    host: staging.example.com
```

### Multi-Document Streams

Multiple YAML documents in one stream:

```yaml
---
document: 1
name: first
---
document: 2
name: second
...
```

### Flow Style

JSON-like syntax for compact representation:

```yaml
# Flow sequence
items: [1, 2, 3, 4, 5]

# Flow mapping
server: { host: localhost, port: 8080 }

# Mixed
config:
    {
        servers:
            [
                { name: primary, ip: 192.168.1.1 },
                { name: backup, ip: 192.168.1.2 },
            ],
    }
```

### Type Tags

Explicit type specification:

```yaml
# Explicit string (not parsed as number)
version: !!str 1.0

# Explicit integer
age: !!int 30

# Timestamp
created: 2024-01-15T10:30:00Z
```

### Boolean Variations

YAML recognizes multiple boolean formats:

```yaml
true_values: [true, True, TRUE, yes, Yes, YES, on, On, ON]
false_values: [false, False, FALSE, no, No, NO, off, Off, OFF]
```

### Null Values

Multiple representations of null:

```yaml
null_value: null
tilde: ~
empty:
explicit_null: !!null
```

### Escape Sequences

Full support for YAML 1.2 escape sequences in double-quoted strings:

```yaml
# Standard escape sequences
message: "Line 1\nLine 2\tTabbed" # Newline and tab
path: "C:\\Users\\Admin\\file.txt" # Backslash escaping
quote: 'He said "Hello"' # Quote escaping

# Hex escapes (8-bit)
ascii: "Letter A: \x41" # \x41 = 'A'
extended: "Euro: \xE2\x82\xAC" # UTF-8 encoded €

# Unicode escapes (16-bit and 32-bit)
unicode: "Snowman: \u2603" # ☃
emoji: "Smile: \U0001F600" # 😀

# Whitespace control
nbsp: "Non-breaking\_space" # Non-breaking space
nextline: "Next\Nline" # NEL (U+0085)
linesep: "Line\Lseparator" # LS (U+2028)
parasep: "Paragraph\Pseparator" # PS (U+2029)
```

**Usage:**

```netlinx
stack_var _NAVYaml yaml
stack_var char text[255]

yaml_text = "'
message: \"Hello\nWorld\tTab\"
'"

if (NAVYamlParse(yaml_text, yaml)) {
    NAVYamlQueryString(yaml, '.message', text)
    // text = 'Hello
    // World    Tab'
    // (actual newline and tab characters)
}
```

### Merge Keys

DRY configuration with merge keys (`<<`):

**Single Merge:**

```yaml
defaults: &defaults
    timeout: 30
    retries: 3
    enabled: true

production:
    <<: *defaults # Inherit all from defaults
    host: prod.example.com # Override/add specific values
    timeout: 60 # Local keys override merged ones


# Result for production:
# host: prod.example.com
# timeout: 60        <-- overridden
# retries: 3         <-- inherited
# enabled: true      <-- inherited
```

**Multiple Merges (Array):**

```yaml
base: &base
    version: 1.0
    enabled: true

network: &network
    host: localhost
    port: 8080

app:
    <<: [*base, *network] # Merge multiple anchors
    name: MyApp # Right-to-left precedence


# Result for app:
# name: MyApp
# version: 1.0
# enabled: true
# host: localhost
# port: 8080
```

**Usage:**

```netlinx
stack_var _NAVYaml yaml
stack_var integer timeout
stack_var char host[128]

yaml_text = "'
defaults: &defaults
    timeout: 30
    retries: 3

production:
    <<: *defaults
    host: prod.example.com
    timeout: 60
'"

if (NAVYamlParse(yaml_text, yaml)) {
    NAVYamlQueryInteger(yaml, '.production.timeout', timeout)
    // timeout = 60 (overridden value)

    NAVYamlQueryString(yaml, '.production.host', host)
    // host = 'prod.example.com'
}
```

### Directives

Document-level directives:

**YAML Version Directive:**

```yaml
%YAML 1.2
---
document: version specified
version: 1.2
```

**Tag Handle Directives:**

```yaml
%YAML 1.2
%TAG ! tag:example.com,2002:
---
custom: !mytype
    value: 123
```

**Multiple Directives:**

```yaml
%YAML 1.2
%TAG !! tag:yaml.org,2002:
%TAG !custom! tag:example.com,2002:
---
string: !!str explicit
number: !!int 42
custom: !custom!type value
```

**Usage:**

```netlinx
stack_var _NAVYaml yaml
stack_var char version[32]

yaml_text = "'
%YAML 1.2
---
version: 1.2.0
'"

if (NAVYamlParse(yaml_text, yaml)) {
    NAVYamlQueryString(yaml, '.version', version)
    // version = '1.2.0'
    // Directives are processed but not accessible via query
}
```

---

## Examples

### Configuration File

```netlinx
stack_var _NAVYaml yaml
stack_var char config[4096]
stack_var char serverHost[128]
stack_var integer serverPort
stack_var char enableDebug
stack_var integer timeouts[10]

config = "'
application:
  name: Control System
  version: 2.1.0

server:
  host: 192.168.1.100
  port: 8080
  timeout: 30

network:
  timeouts: [5, 10, 15, 30, 60]

features:
  debug: true
  logging: on
  ssl: yes
'"

if (NAVYamlParse(config, yaml)) {
    NAVYamlQueryString(yaml, '.server.host', serverHost)
    NAVYamlQueryInteger(yaml, '.server.port', serverPort)
    NAVYamlQueryBoolean(yaml, '.features.debug', enableDebug)
    NAVYamlQueryIntegerArray(yaml, '.network.timeouts', timeouts)

    send_string 0, "'Server: ', serverHost, ':', itoa(serverPort)"
    send_string 0, "'Debug: ', itoa(enableDebug)"
    send_string 0, "'Timeout count: ', itoa(length_array(timeouts))"
}
```

### Device Configuration

```netlinx
stack_var _NAVYaml yaml
stack_var char deviceConfig[2048]
stack_var char deviceNames[50][64]
stack_var integer devicePorts[50]

deviceConfig = "'
devices:
  - name: Main Display
    type: display
    port: 5001
    enabled: true

  - name: Audio Processor
    type: audio
    port: 5002
    enabled: true

  - name: Lighting Controller
    type: lighting
    port: 5003
    enabled: false
'"

if (NAVYamlParse(deviceConfig, yaml)) {
    stack_var _NAVYamlNode devices
    stack_var _NAVYamlNode device
    stack_var integer count

    // Navigate devices sequence
    if (NAVYamlQuery(yaml, '.devices', devices)) {
        if (NAVYamlGetFirstChild(yaml, devices, device)) {
            count = 0
            repeat {
                count++
                stack_var char name[64]
                stack_var integer port
                stack_var char enabled

                NAVYamlQueryString(yaml, "'.devices[', itoa(count), '].name'", name)
                NAVYamlQueryInteger(yaml, "'.devices[', itoa(count), '].port'", port)
                NAVYamlQueryBoolean(yaml, "'.devices[', itoa(count), '].enabled'", enabled)

                send_string 0, "'Device: ', name, ' Port: ', itoa(port), ' Enabled: ', itoa(enabled)"
            } until (!NAVYamlGetNextSibling(yaml, device, device))
        }
    }
}
```

### Tree Traversal

```netlinx
define_function PrintYamlTree(_NAVYaml yaml, _NAVYamlNode node, integer depth) {
    stack_var char indent[100]
    stack_var integer i
    stack_var _NAVYamlNode child

    // Build indentation
    indent = ''
    for (i = 1; i <= depth * 2; i++) {
        indent = "indent, ' '"
    }

    // Print node info
    if (NAVYamlIsMapping(node)) {
        send_string 0, "indent, 'MAPPING: ', NAVYamlGetKey(node)"
    } else if (NAVYamlIsSequence(node)) {
        send_string 0, "indent, 'SEQUENCE: ', NAVYamlGetKey(node)"
    } else {
        send_string 0, "indent, NAVYamlGetKey(node), ': ', NAVYamlGetValue(node)"
    }

    // Recursively print children
    if (NAVYamlGetFirstChild(yaml, node, child)) {
        repeat {
            PrintYamlTree(yaml, child, depth + 1)
        } until (!NAVYamlGetNextSibling(yaml, child, child))
    }
}

// Usage
stack_var _NAVYamlNode root
if (NAVYamlGetRoot(yaml, root)) {
    PrintYamlTree(yaml, root, 0)
}
```

---

## Limitations

### NetLinx Platform Limitations

- **No Dynamic Memory**: Fixed-size arrays and structures
- **String Length**: Limited by `NAV_YAML_PARSER_MAX_VALUE_LENGTH` (default 255 characters)
- **Tree Size**: Limited by `NAV_YAML_PARSER_MAX_NODES` (default 1000 nodes)
- **Nesting Depth**: Limited by `NAV_YAML_PARSER_MAX_DEPTH` (default 32 levels)

### YAML Specification Coverage

**100% YAML 1.2 Core Schema Compliant - All Features Supported:**

- ✅ Basic scalars (strings, numbers, booleans, null)
- ✅ Mappings (key-value pairs)
- ✅ Sequences (lists)
- ✅ Nested structures
- ✅ Indentation-based syntax
- ✅ Flow style (`[]`, `{}`)
- ✅ Comments (`#`)
- ✅ Multi-line strings
- ✅ Block scalars (`|`, `>`) with chomping indicators (`-`, `+`) and explicit indentation
- ✅ Escape sequences (`\n`, `\t`, `\r`, `\x##`, `\u####`, `\U########`, etc.)
- ✅ Anchors and aliases (`&anchor`, `*alias`)
- ✅ Merge keys (`<<: *anchor`, `<<: [*a, *b]`)
- ✅ Type tags (`!!str`, `!!int`, `!!float`, `!!bool`, `!!null`, `!!seq`, `!!map`, `!custom`)
- ✅ Explicit keys (`?` syntax for complex keys)
- ✅ Directives (`%YAML 1.2`, `%TAG`)
- ✅ Multi-document streams (`---`, `...`)
- ✅ Timestamps (`!!timestamp`)
- ✅ Binary data (`!!binary`)

**Not Supported (Beyond YAML 1.2 Core Schema):**

- ❌ Sets (`!!set`) - JSON Schema specific
- ❌ Ordered maps (`!!omap`) - JSON Schema specific
- ❌ Stream processing (only full document parsing)
- ❌ Custom schema definitions (user-defined types beyond tags)

> **Note:** The library implements the complete YAML 1.2 Core Schema as defined in the specification. Features marked as "not supported" are specialized types from the JSON Schema or are beyond the scope of the Core Schema.

### Query System Limitations

- No filtering or selection (`.[] | select(...)`)
- No transformations or functions
- No pipe operators
- No recursive descent
- Array access only by specific index, not ranges or wildcards

---

## License

MIT License - Copyright (c) 2010-2026 Norgate AV

---

## See Also

- [NAVFoundation.Json](../Json/README.md) - JSON parser with similar API
- [NAVFoundation.Xml](../Xml/README.md) - XML parser with similar API
- [YAML 1.2 Specification](https://yaml.org/spec/1.2/spec.html)
- [yq Documentation](https://mikefarah.gitbook.io/yq/)
