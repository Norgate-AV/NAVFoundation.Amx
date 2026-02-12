# NAVFoundation.Xml

A comprehensive XML parser and query library for AMX NetLinx, providing RFC-compliant XML parsing with a dot-notation query syntax for easy data extraction.

## Features

- **XML 1.0 Compliant**: Full XML specification support (elements, attributes, text, CDATA, comments, processing instructions)
- **Dot-Notation Query Syntax**: Simple jq-inspired syntax for easy value extraction (`.root.child`, `.items[1]`, `.@attribute`)
- **Entity Handling**: Automatic expansion of predefined entities (`&lt;`, `&gt;`, `&amp;`, `&quot;`, `&apos;`)
- **Character References**: Support for numeric character references (decimal: `&#65;`, hexadecimal: `&#x41;`)
- **CDATA Support**: Preserves special characters in CDATA sections without entity encoding
- **Type-Safe Value Extraction**: Dedicated query functions for string, integer, long, float, boolean, signed types
- **Array Support**: Query functions for extracting arrays of typed values from sibling elements
- **Tree Navigation**: Low-level API for manual tree traversal and inspection
- **Helper Functions**: Element counting, depth calculation, text content extraction, entity escaping/unescaping
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
- [Examples](#examples)
- [Limitations](#limitations)

---

## Quick Start

### Basic Parsing and Querying

```netlinx
#include 'NAVFoundation.Xml.axi'

stack_var _NAVXml xml
stack_var char response[2048]
stack_var char hostname[255]
stack_var integer port

// Sample XML response
response = "'<config>',
            '<server>',
            '<host>192.168.1.100</host>',
            '<port>8080</port>',
            '</server>',
            '</config>'"

// Parse XML
if (NAVXmlParse(response, xml)) {
    // Query values using dot notation
    if (NAVXmlQueryString(xml, '.config.server.host', hostname)) {
        send_string 0, "'Host: ', hostname"  // Output: Host: 192.168.1.100
    }

    if (NAVXmlQueryInteger(xml, '.config.server.port', port)) {
        send_string 0, "'Port: ', itoa(port)"  // Output: Port: 8080
    }
} else {
    send_string 0, "'Parse error: ', NAVXmlGetError(xml)"
}
```

### Attribute Access

```netlinx
stack_var _NAVXml xml
stack_var char xmlData[1024]
stack_var char serverName[255]

xmlData = "<config><server name='primary' enabled='true'/></config>"

if (NAVXmlParse(xmlData, xml)) {
    // Access attributes using @ notation
    if (NAVXmlQueryAttribute(xml, '.config.server', 'name', serverName)) {
        send_string 0, "'Server: ', serverName"  // Output: Server: primary
    }
}
```

### CDATA Handling

```netlinx
stack_var _NAVXml xml
stack_var char xmlData[1024]
stack_var char script[512]

xmlData = "'<script>',
           '<![CDATA[',
           'if (x < 10 && y > 5) {',
           '  alert(\"Hello & Goodbye\");',
           '}',
           ']]>',
           '</script>'"

if (NAVXmlParse(xmlData, xml)) {
    // CDATA content is automatically extracted
    if (NAVXmlQueryString(xml, '.script', script)) {
        // script contains the raw JavaScript without entity encoding
        send_string 0, "'Script: ', script"
    }
}
```

---

## Query System

The library provides a **jq-inspired dot-notation query syntax** for accessing values in parsed XML. This is designed for **value extraction** - simple and intuitive path navigation without the complexity of full XPath.

### Query Syntax

| Pattern          | Description              | Example                           |
| ---------------- | ------------------------ | --------------------------------- |
| `.`              | Root element             | `.` (returns root node)           |
| `.element`       | Direct child element     | `.config`                         |
| `.element.child` | Nested path              | `.config.server.host`             |
| `.element[1]`    | Indexed access (1-based) | `.servers.server[2]` → 2nd server |
| `.element.@attr` | Attribute value access   | `.server.@name`                   |
| `.[1]`           | Direct array indexing    | `.[2]` → 2nd child                |

### Supported Features

✅ **Dot notation** - `.root.child.grandchild`  
✅ **Array indexing** - `.servers.server[2]` (1-based)  
✅ **Attribute access** - `.element.@attribute`  
✅ **Root access** - `.` (returns root element)  
✅ **Direct indexing** - `.[3]` (3rd child of current context)  
✅ **Mixed notation** - `.servers[1].@name` (combined element, index, attribute)

### Not Supported

❌ **Descendant search** - `//element` (no recursive search)  
❌ **Parent axis** - `..` (parent navigation)  
❌ **Wildcards** - `*` (all elements)  
❌ **Functions** - `count()`, `text()`, etc.  
❌ **Predicates** - `[@id='123']`, `[text()='value']`  
❌ **Unions** - `path1 | path2`

> **Design Philosophy**: This is a **value extraction system**, not a query language. Use the simple dot notation to retrieve values, then process them in NetLinx code. For complex filtering or transformations, query the data and handle logic in your AMX program.

### Query Examples

```netlinx
// Simple element access
NAVXmlQueryString(xml, '.config.name', result)                // Get text content
NAVXmlQueryInteger(xml, '.config.port', result)               // Get numeric content
NAVXmlQueryFloat(xml, '.config.temperature', result)          // Get floating-point

// Nested element access
NAVXmlQueryString(xml, '.config.server.hostname', result)     // Nested path

// Indexed access (1-based)
NAVXmlQueryString(xml, '.servers.server[1].ip', result)       // First server
NAVXmlQueryString(xml, '.servers.server[3].ip', result)       // Third server

// Attribute access
NAVXmlQueryAttribute(xml, '.server', 'id', result)            // Direct attribute getter
NAVXmlQueryString(xml, '.server.@id', result)                 // Dot-style attribute access

// Array extraction
stack_var char names[50][64]
NAVXmlQueryStringArray(xml, '.users.user', names)             // Extract all user names

// Direct array indexing
NAVXmlQueryString(xml, '.[1]', result)                        // First child of root
NAVXmlQueryString(xml, '.items.[5]', result)                  // Fifth child of items

// Boolean/signed types
stack_var char enabled
NAVXmlQueryBoolean(xml, '.config.enabled', enabled)           // Parse boolean (true/false/1/0/yes/no/on/off)

stack_var sinteger offset
NAVXmlQuerySignedInteger(xml, '.data.offset', offset)         // Signed 16-bit (-32768 to 32767)

stack_var slong timestamp
NAVXmlQuerySignedLong(xml, '.data.timestamp', timestamp)      // Signed 32-bit
```

---

## Public API

### Core Parsing

#### `NAVXmlParse`

Parse an XML string into a node tree structure.

```netlinx
define_function char NAVXmlParse(char input[], _NAVXml xml)
```

**Parameters:**

- `input` - The XML string to parse
- `xml` - Output parameter to receive the parsed structure

**Returns:** `true` if parsing succeeded, `false` on error

**Example:**

```netlinx
stack_var _NAVXml xml
if (NAVXmlParse('<root><child>value</child></root>', xml)) {
    // Success - query or navigate the tree
} else {
    send_string 0, "'Error: ', NAVXmlGetError(xml)"
}
```

---

### Query Functions

Query functions extract typed values from XML using dot notation. All return `false` if the path doesn't exist or the type doesn't match.

#### Scalar Query Functions

##### `NAVXmlQuery`

Get the raw node at a path (for advanced use).

```netlinx
define_function char NAVXmlQuery(_NAVXml xml, char query[], _NAVXmlNode result)
```

##### `NAVXmlQueryString`

Query for text content as a string.

```netlinx
define_function char NAVXmlQueryString(_NAVXml xml, char query[], char result[])
```

**Example:**

```netlinx
stack_var char hostname[255]
if (NAVXmlQueryString(xml, '.config.server.host', hostname)) {
    send_string 0, "'Host: ', hostname"
}
```

##### `NAVXmlQueryInteger`

Query for numeric content as an unsigned 16-bit integer (0-65535).

```netlinx
define_function char NAVXmlQueryInteger(_NAVXml xml, char query[], integer result)
```

**Example:**

```netlinx
stack_var integer port
if (NAVXmlQueryInteger(xml, '.config.server.port', port)) {
    send_string 0, "'Port: ', itoa(port)"
}
```

##### `NAVXmlQuerySignedInteger`

Query for numeric content as a signed 16-bit integer (-32768 to 32767).

```netlinx
define_function char NAVXmlQuerySignedInteger(_NAVXml xml, char query[], sinteger result)
```

##### `NAVXmlQueryLong`

Query for numeric content as an unsigned 32-bit long (0-4294967295).

```netlinx
define_function char NAVXmlQueryLong(_NAVXml xml, char query[], long result)
```

##### `NAVXmlQuerySignedLong`

Query for numeric content as a signed 32-bit long (-2147483648 to 2147483647).

```netlinx
define_function char NAVXmlQuerySignedLong(_NAVXml xml, char query[], slong result)
```

##### `NAVXmlQueryFloat`

Query for numeric content as a floating-point number.

```netlinx
define_function char NAVXmlQueryFloat(_NAVXml xml, char query[], float result)
```

**Example:**

```netlinx
stack_var float temperature
if (NAVXmlQueryFloat(xml, '.sensor.temperature', temperature)) {
    send_string 0, "'Temp: ', ftoa(temperature)"
}
```

##### `NAVXmlQueryBoolean`

Query for boolean content. Accepts `true`/`false`, `1`/`0`, `yes`/`no`, `on`/`off` (case-insensitive).

```netlinx
define_function char NAVXmlQueryBoolean(_NAVXml xml, char query[], char result)
```

**Example:**

```netlinx
stack_var char enabled
if (NAVXmlQueryBoolean(xml, '.config.enabled', enabled)) {
    if (enabled) {
        send_string 0, 'Feature is enabled'
    }
}
```

##### `NAVXmlQueryAttribute`

Query for an attribute value.

```netlinx
define_function char NAVXmlQueryAttribute(_NAVXml xml, char elementQuery[], char attrName[], char result[])
```

**Example:**

```netlinx
stack_var char serverId[64]
if (NAVXmlQueryAttribute(xml, '.config.server', 'id', serverId)) {
    send_string 0, "'Server ID: ', serverId"
}
```

#### Array Query Functions

All array query functions extract text content from child elements and parse them into typed arrays. They return `false` if parsing fails for any element.

##### `NAVXmlQueryStringArray`

Extract text content from all child elements as a string array.

```netlinx
define_function char NAVXmlQueryStringArray(_NAVXml xml, char query[], char result[][])
```

**Example:**

```netlinx
stack_var char names[50][64]
if (NAVXmlQueryStringArray(xml, '.users.user', names)) {
    stack_var integer i
    for (i = 1; i <= length_array(names); i++) {
        send_string 0, "'User: ', names[i]"
    }
}
```

##### `NAVXmlQueryIntegerArray`

Extract and parse child elements as unsigned 16-bit integers.

```netlinx
define_function char NAVXmlQueryIntegerArray(_NAVXml xml, char query[], integer result[])
```

##### `NAVXmlQuerySignedIntegerArray`

Extract and parse child elements as signed 16-bit integers.

```netlinx
define_function char NAVXmlQuerySignedIntegerArray(_NAVXml xml, char query[], sinteger result[])
```

##### `NAVXmlQueryLongArray`

Extract and parse child elements as unsigned 32-bit longs.

```netlinx
define_function char NAVXmlQueryLongArray(_NAVXml xml, char query[], long result[])
```

##### `NAVXmlQuerySignedLongArray`

Extract and parse child elements as signed 32-bit longs.

```netlinx
define_function char NAVXmlQuerySignedLongArray(_NAVXml xml, char query[], slong result[])
```

##### `NAVXmlQueryFloatArray`

Extract and parse child elements as floats.

```netlinx
define_function char NAVXmlQueryFloatArray(_NAVXml xml, char query[], float result[])
```

##### `NAVXmlQueryBooleanArray`

Extract and parse child elements as booleans.

```netlinx
define_function char NAVXmlQueryBooleanArray(_NAVXml xml, char query[], char result[])
```

---

### Tree Navigation

Low-level functions for manual tree traversal.

#### `NAVXmlGetRootNode`

Get the root element node of the document.

```netlinx
define_function char NAVXmlGetRootNode(_NAVXml xml, _NAVXmlNode node)
```

**Example:**

```netlinx
stack_var _NAVXmlNode root
if (NAVXmlGetRootNode(xml, root)) {
    send_string 0, "'Root element: ', root.name"
}
```

#### `NAVXmlGetFirstChild`

Get the first child node of a parent node.

```netlinx
define_function char NAVXmlGetFirstChild(_NAVXml xml, _NAVXmlNode parent, _NAVXmlNode child)
```

#### `NAVXmlGetNextSibling`

Get the next sibling node of a node.

```netlinx
define_function char NAVXmlGetNextSibling(_NAVXml xml, _NAVXmlNode current, _NAVXmlNode sibling)
```

**Example (Iterate Children):**

```netlinx
stack_var _NAVXmlNode root
stack_var _NAVXmlNode child

if (NAVXmlGetRootNode(xml, root)) {
    if (NAVXmlGetFirstChild(xml, root, child)) {
        send_string 0, "'Child: ', child.name"

        while (NAVXmlGetNextSibling(xml, child, child)) {
            send_string 0, "'Sibling: ', child.name"
        }
    }
}
```

#### `NAVXmlGetParentNode`

Get the parent node of a node.

```netlinx
define_function char NAVXmlGetParentNode(_NAVXml xml, _NAVXmlNode current, _NAVXmlNode parent)
```

---

### Type Checking

#### `NAVXmlIsElement`

Check if a node is an element.

```netlinx
define_function char NAVXmlIsElement(_NAVXmlNode node)
```

#### `NAVXmlIsTextNode`

Check if a node is a text node.

```netlinx
define_function char NAVXmlIsTextNode(_NAVXmlNode node)
```

#### `NAVXmlIsCDATA`

Check if a node is a CDATA section.

```netlinx
define_function char NAVXmlIsCDATA(_NAVXmlNode node)
```

#### `NAVXmlIsComment`

Check if a node is a comment.

```netlinx
define_function char NAVXmlIsComment(_NAVXmlNode node)
```

#### `NAVXmlHasAttributes`

Check if an element node has attributes.

```netlinx
define_function char NAVXmlHasAttributes(_NAVXmlNode node)
```

#### `NAVXmlHasChildren`

Check if a node has child nodes.

```netlinx
define_function char NAVXmlHasChildren(_NAVXmlNode node)
```

---

### Value Getters

#### `NAVXmlGetElementName` / `NAVXmlGetTag`

Get the name of an element node.

```netlinx
define_function char[NAV_XML_PARSER_MAX_ELEMENT_NAME] NAVXmlGetElementName(_NAVXmlNode node)
define_function char[NAV_XML_PARSER_MAX_ELEMENT_NAME] NAVXmlGetTag(_NAVXmlNode node)
```

**Note:** `NAVXmlGetTag` is an alias for `NAVXmlGetElementName`.

#### `NAVXmlGetTextValue`

Get the text value of a text, CDATA, or comment node.

```netlinx
define_function char[NAV_XML_PARSER_MAX_TEXT_LENGTH] NAVXmlGetTextValue(_NAVXmlNode node)
```

#### `NAVXmlGetAttribute`

Get an attribute value from an element node.

```netlinx
define_function char NAVXmlGetAttribute(_NAVXml xml, _NAVXmlNode node, char attrName[], char result[])
```

#### `NAVXmlGetChildCount`

Get the total number of child nodes (all types).

```netlinx
define_function integer NAVXmlGetChildCount(_NAVXmlNode node)
```

#### `NAVXmlGetElementChildCount`

Get the number of element child nodes only (excludes text, comments, etc.).

```netlinx
define_function integer NAVXmlGetElementChildCount(_NAVXml xml, _NAVXmlNode node)
```

---

### Helper Functions

#### `NAVXmlGetNodeCount`

Get the total number of element nodes in the XML document.

```netlinx
define_function integer NAVXmlGetNodeCount(_NAVXml xml)
```

#### `NAVXmlGetMaxDepth`

Get the maximum nesting depth of element nodes in the tree.

```netlinx
define_function sinteger NAVXmlGetMaxDepth(_NAVXml xml)
```

**Returns:** Maximum depth (0 for empty/root only), -1 on error.

#### `NAVXmlEscapeString`

Escape special XML characters in a string for safe inclusion in XML content.

```netlinx
define_function char[NAV_MAX_BUFFER] NAVXmlEscapeString(char input[])
```

**Converts:**

- `<` → `&lt;`
- `>` → `&gt;`
- `&` → `&amp;`
- `"` → `&quot;`
- `'` → `&apos;`

**Example:**

```netlinx
stack_var char safe[1024]
safe = NAVXmlEscapeString('Value with <special> & "chars"')
// Result: 'Value with &lt;special&gt; &amp; &quot;chars&quot;'
```

#### `NAVXmlParserUnescapeString`

Unescape XML entity references in a string.

```netlinx
define_function char[NAV_MAX_BUFFER] NAVXmlParserUnescapeString(char input[])
```

**Converts:**

- `&lt;` → `<`
- `&gt;` → `>`
- `&amp;` → `&`
- `&quot;` → `"`
- `&apos;` → `'`

#### `NAVXmlGetNodeType`

Get a string representation of a node type constant.

```netlinx
define_function char[16] NAVXmlGetNodeType(integer type)
```

**Returns:** `"element"`, `"text"`, `"cdata"`, `"comment"`, `"pi"`, or `"none"`

---

### Error Handling

#### `NAVXmlGetError`

Get the error message from the last parse operation.

```netlinx
define_function char[NAV_XML_PARSER_MAX_ERROR_LENGTH] NAVXmlGetError(_NAVXml xml)
```

#### `NAVXmlGetErrorLine`

Get the line number where a parse error occurred.

```netlinx
define_function integer NAVXmlGetErrorLine(_NAVXml xml)
```

#### `NAVXmlGetErrorColumn`

Get the column number where a parse error occurred.

```netlinx
define_function integer NAVXmlGetErrorColumn(_NAVXml xml)
```

---

## Configuration

You can customize limits by defining these constants **before** including the library:

### Lexer Configuration

```netlinx
#define NAV_XML_LEXER_MAX_TOKENS       2000  // Max tokens in document
#define NAV_XML_LEXER_MAX_TOKEN_LENGTH 512   // Max token size (bytes)
#define NAV_XML_LEXER_MAX_SOURCE       8192  // Max source size (bytes)
```

### Parser Configuration

```netlinx
#define NAV_XML_PARSER_MAX_NODES          1000  // Max nodes in tree
#define NAV_XML_PARSER_MAX_ATTRIBUTES     500   // Max attributes total
#define NAV_XML_PARSER_MAX_ELEMENT_NAME   128   // Max element name length
#define NAV_XML_PARSER_MAX_TEXT_LENGTH    512   // Max text content length
#define NAV_XML_PARSER_MAX_ATTR_NAME      64    // Max attribute name length
#define NAV_XML_PARSER_MAX_ATTR_VALUE     255   // Max attribute value length
#define NAV_XML_PARSER_MAX_DEPTH          32    // Max nesting depth
```

### Query Configuration

```netlinx
#define NAV_XML_QUERY_MAX_TOKENS          50   // Max tokens in query
#define NAV_XML_QUERY_MAX_PATH_STEPS      25   // Max steps in query path
```

**Example:**

```netlinx
// Increase limits before including the library
#define NAV_XML_PARSER_MAX_NODES 2000
#define NAV_XML_PARSER_MAX_TEXT_LENGTH 1024

#include 'NAVFoundation.Xml.axi'
```

---

## Examples

### Complete Configuration Parser

```netlinx
#include 'NAVFoundation.Xml.axi'

define_start

stack_var _NAVXml xml
stack_var char config[4096]
stack_var char hostname[255]
stack_var integer port
stack_var char username[64]

config = "'<?xml version=\"1.0\" encoding=\"UTF-8\"?>',
          '<configuration>',
          '<server id=\"primary\" enabled=\"true\">',
          '<hostname>192.168.1.100</hostname>',
          '<port>8080</port>',
          '<credentials>',
          '<username>admin</username>',
          '</credentials>',
          '</server>',
          '</configuration>'"

if (!NAVXmlParse(config, xml)) {
    send_string 0, "'XML Parse Error: ', NAVXmlGetError(xml)"
    return
}

// Query nested values
if (NAVXmlQueryString(xml, '.configuration.server.hostname', hostname)) {
    send_string 0, "'Hostname: ', hostname"
}

if (NAVXmlQueryInteger(xml, '.configuration.server.port', port)) {
    send_string 0, "'Port: ', itoa(port)"
}

// Query with deeper nesting
if (NAVXmlQueryString(xml, '.configuration.server.credentials.username', username)) {
    send_string 0, "'Username: ', username"
}

// Query attributes
stack_var char serverId[64]
if (NAVXmlQueryAttribute(xml, '.configuration.server', 'id', serverId)) {
    send_string 0, "'Server ID: ', serverId"
}

// Query boolean attribute
stack_var char enabled
if (NAVXmlQueryAttribute(xml, '.configuration.server', 'enabled', enabled)) {
    if (NAVParseBoolean(enabled)) {
        send_string 0, 'Server is enabled'
    }
}
```

### Processing Multiple Elements with Arrays

```netlinx
stack_var _NAVXml xml
stack_var char xmlData[2048]

xmlData = "'<servers>',
           '<server><name>web1</name><ip>192.168.1.10</ip><port>80</port></server>',
           '<server><name>web2</name><ip>192.168.1.11</ip><port>80</port></server>',
           '<server><name>db1</name><ip>192.168.1.20</ip><port>3306</port></server>',
           '</servers>'"

if (NAVXmlParse(xmlData, xml)) {
    // Extract all server names as array
    stack_var char names[10][64]
    if (NAVXmlQueryStringArray(xml, '.servers.server.name', names)) {
        stack_var integer i
        for (i = 1; i <= length_array(names); i++) {
            send_string 0, "'Server ', itoa(i), ': ', names[i]"
        }
    }

    // Access specific server by index
    stack_var char serverIp[64]
    stack_var integer serverPort

    // Get first server's details
    if (NAVXmlQueryString(xml, '.servers.server[1].ip', serverIp)) {
        send_string 0, "'Server 1 IP: ', serverIp"
    }

    // Get third server's details
    if (NAVXmlQueryString(xml, '.servers.server[3].name', serverName)) {
        send_string 0, "'Server 3 Name: ', serverName"
    }

    if (NAVXmlQueryInteger(xml, '.servers.server[3].port', serverPort)) {
        send_string 0, "'Server 3 Port: ', itoa(serverPort)"
    }

    // Extract all ports as integer array
    stack_var integer ports[10]
    if (NAVXmlQueryIntegerArray(xml, '.servers.server.port', ports)) {
        for (i = 1; i <= length_array(ports); i++) {
            send_string 0, "'Port ', itoa(i), ': ', itoa(ports[i])"
        }
    }
}
```

### Manual Tree Traversal

```netlinx
stack_var _NAVXml xml
stack_var _NAVXmlNode root
stack_var _NAVXmlNode child

if (NAVXmlParse('<root><a>1</a><b>2</b><c>3</c></root>', xml)) {
    if (NAVXmlGetRootNode(xml, root)) {
        send_string 0, "'Root: ', root.name"

        if (NAVXmlGetFirstChild(xml, root, child)) {
            send_string 0, "'First child: ', child.name"

            // Iterate through siblings
            while (NAVXmlGetNextSibling(xml, child, child)) {
                send_string 0, "'Sibling: ', child.name"
            }
        }
    }
}
```

### Working with Signed Values

```netlinx
stack_var _NAVXml xml
stack_var char xmlData[512]

xmlData = "'<data>',
           '<offset>-150</offset>',
           '<temperature>-23.5</temperature>',
           '<values>',
           '<value>-100</value>',
           '<value>200</value>',
           '<value>-50</value>',
           '</values>',
           '</data>'"

if (NAVXmlParse(xmlData, xml)) {
    stack_var sinteger offset
    stack_var float temp
    stack_var sinteger values[10]

    // Query signed integer
    if (NAVXmlQuerySignedInteger(xml, '.data.offset', offset)) {
        send_string 0, "'Offset: ', itoa(offset)"
    }

    // Query float (handles negative)
    if (NAVXmlQueryFloat(xml, '.data.temperature', temp)) {
        send_string 0, "'Temperature: ', ftoa(temp)"
    }

    // Query signed integer array
    if (NAVXmlQuerySignedIntegerArray(xml, '.data.values.value', values)) {
        stack_var integer i
        for (i = 1; i <= length_array(values); i++) {
            send_string 0, "'Value ', itoa(i), ': ', itoa(values[i])"
        }
    }
}
```

### Error Handling

```netlinx
stack_var _NAVXml xml
stack_var char badXml[256]

badXml = '<root><unclosed>value</root>'  // Missing closing tag for 'unclosed'

if (!NAVXmlParse(badXml, xml)) {
    send_string 0, "'Parse failed: ', NAVXmlGetError(xml)"
    send_string 0, "'Line: ', itoa(NAVXmlGetErrorLine(xml))"
    send_string 0, "'Column: ', itoa(NAVXmlGetErrorColumn(xml))"
}
```

---

## Limitations

### Document Size

- Maximum source size: **8192 bytes** (configurable via `NAV_XML_LEXER_MAX_SOURCE`)
- Maximum tokens: **2000** (configurable via `NAV_XML_LEXER_MAX_TOKENS`)
- Maximum nodes: **1000** (configurable via `NAV_XML_PARSER_MAX_NODES`)
- Maximum attributes: **500** total (configurable via `NAV_XML_PARSER_MAX_ATTRIBUTES`)

### Element/Attribute Sizes

- Element name: **128 characters** (configurable via `NAV_XML_PARSER_MAX_ELEMENT_NAME`)
- Attribute name: **64 characters** (configurable via `NAV_XML_PARSER_MAX_ATTR_NAME`)
- Attribute value: **255 characters** (configurable via `NAV_XML_PARSER_MAX_ATTR_VALUE`)
- Text content: **512 characters** (configurable via `NAV_XML_PARSER_MAX_TEXT_LENGTH`)
- Token length: **512 characters** (configurable via `NAV_XML_LEXER_MAX_TOKEN_LENGTH`)

### Nesting Depth

- Maximum nesting: **32 levels** (configurable via `NAV_XML_PARSER_MAX_DEPTH`)

### Query System Features

- **Dot notation only** - Simple `.element.child` paths
- **No descendant search** - Cannot search at arbitrary depth (`//element` not supported)
- **No predicates/filtering** - Cannot filter by attribute values or text content in queries
- **No XPath functions** - No `count()`, `text()`, `position()`, etc.
- **No XPath axes** - Only direct child and indexed access supported
- **No wildcards** - Cannot use `*` to match any element

### Validation and Schema

- DTD declarations are parsed but **not validated**
- XML Schema (XSD) validation is **not supported**
- No enforcement of element or attribute constraints
- No datatype validation beyond basic type parsing

### Entity References

- Supports five predefined XML entities: `&lt;`, `&gt;`, `&amp;`, `&quot;`, `&apos;`
- Supports numeric character references: decimal `&#65;` and hexadecimal `&#x41;`
- Custom entity declarations (<!ENTITY>) are **not supported**
- External entity references are **not supported** (security: prevents XXE attacks)

### Character Encoding

- Input is treated as **ASCII/UTF-8**
- Full Unicode support is limited by NetLinx string handling
- No automatic encoding detection or conversion
- BOM (Byte Order Mark) is not automatically detected or removed

### XML Features Not Supported

- **Namespaces** - Namespace declarations are parsed but not enforced
- **Processing Instructions** - PIs are parsed but not executed
- **External DTD** - External DTD subsets are not loaded
- **NOTATION** - Notation declarations are not supported
- **Mixed Content** - Text interleaved with elements is supported but may complicate queries

### Performance Considerations

- Entire document is parsed into memory (no streaming)
- All nodes and attributes consume memory until freed
- Larger documents (approaching max limits) will be slower to parse
- Query performance is O(n) where n = path depth × sibling count

---

## Architecture

The library follows a three-layer architecture inspired by compiler design:

1. **Lexer** (`NAVFoundation.XmlLexer`) - Tokenizes XML source into lexical elements
2. **Parser** (`NAVFoundation.XmlParser`) - Builds a DOM-like tree structure from tokens
3. **Query** (`NAVFoundation.XmlQuery`) - Provides XPath-inspired query execution

This modular design ensures clean separation of concerns, testability, and maintainability.

---

## License

MIT License - Copyright (c) 2010-2026 Norgate AV

See [LICENSE](../LICENSE) for full details.
