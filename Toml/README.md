# NAVFoundation.Toml

A fully-featured TOML v1.1.0 (with v1.0.0 backwards compatibility) lexer, parser, and query system for NetLinx/AMX.

## Features

- **Full TOML 1.1.0 Compliance**: Supports all TOML 1.1.0 features including new escape sequences (`\e`, `\xHH`), optional seconds in datetime/time, and multiline inline tables
- **Full TOML 1.0.0 Compliance**: Supports all TOML data types and structural features
- **Lexer/Parser Architecture**: Clean separation between tokenization and tree building
- **jq-Inspired Query System**: Powerful dot notation queries for navigating TOML documents
- **Tree Navigation**: Functions for walking and traversing the parsed TOML tree
- **Debug Logging**: Comprehensive debug output controlled by compiler directives
- **Comprehensive Testing**: Full test suite covering all features and edge cases

## Data Types Supported

### Scalars

- **Strings**: Basic (`"..."`), Literal (`'...'`), Multiline Basic (`"""..."""`), Multiline Literal (`'''...'''`)
- **Integers**: Decimal, Hexadecimal (`0x...`), Octal (`0o...`), Binary (`0b...`)
- **Floats**: Standard notation, Scientific notation, Special values (`inf`, `-inf`, `nan`)
- **Booleans**: `true`, `false`
- **Date/Time**: RFC 3339 datetime, Local date, Local time

### Structures

- **Arrays**: `[1, 2, 3]` with support for nested arrays
- **Tables**: `[table]` with dotted notation support `[a.b.c]`
- **Inline Tables**: `{ key = value, key2 = value2 }`
- **Array of Tables**: `[[products]]` for repeating table structures

## Usage

### Basic Parsing

```netlinx
#include 'NAVFoundation.Toml.axi'

define_variable
    _NAVToml toml
    char toml_content[1024]

define_start

toml_content = "
    'title = "My Application"', 13, 10,
    '[server]', 13, 10,
    'host = "localhost"', 13, 10,
    'port = 8080', 13, 10
"

if (NAVTomlParse(toml_content, toml)) {
    send_string 0, "'TOML parsed successfully!'"
} else {
    send_string 0, "'Parse failed: ', NAVTomlGetError(toml)"
}
```

### Querying Values

```netlinx
// Query strings
char hostname[128]
if (NAVTomlQueryString(toml, '.server.host', hostname)) {
    send_string 0, "'Host: ', hostname"
}

// Query integers
sinteger port
if (NAVTomlQueryInteger(toml, '.server.port', port)) {
    send_string 0, "'Port: ', itoa(port)"
}

// Query booleans
char ssl_enabled
if (NAVTomlQueryBoolean(toml, '.server.ssl', ssl_enabled)) {
    send_string 0, "'SSL: ', NAVBooleanToString(ssl_enabled)"
}

// Query floats
float threshold
if (NAVTomlQueryFloat(toml, '.limits.max', threshold)) {
    send_string 0, "'Threshold: ', ftoa(threshold)"
}
```

### Query Syntax

The query system uses jq-inspired dot notation:

- `.property` - Access a root-level property
- `.table.property` - Access nested properties
- `.array[1]` - Access array elements (1-indexed in queries)
- `.array[2].property` - Access properties of array elements
- `.table1.table2.array[3].value` - Complex nested paths

Note: Array indices in queries are 1-based (`.array[1]` for first element), following the NetLinx convention.

### Tree Navigation

```netlinx
// Get root node
integer root = NAVTomlGetRootNode(toml)

// Query for a specific node
integer node = NAVTomlQuery(toml, '.server')

// Get parent node
integer parent = NAVTomlGetParentNode(toml, node)

// Get property by key
integer child = NAVTomlGetPropertyByKey(toml, node, 'port')

// Get array element
integer element = NAVTomlGetArrayElement(toml, arrayNode, 2)

// Get child count
integer count = NAVTomlGetChildCount(toml, node)
```

### Type Checking

```netlinx
integer node = NAVTomlQuery(toml, '.someValue')

if (NAVTomlIsString(toml, node)) {
    send_string 0, "'Value is a string'"
}
else if (NAVTomlIsNumber(toml, node)) {
    send_string 0, "'Value is a number'"
}
else if (NAVTomlIsBoolean(toml, node)) {
    send_string 0, "'Value is a boolean'"
}
else if (NAVTomlIsArray(toml, node)) {
    send_string 0, "'Value is an array'"
}
else if (NAVTomlIsTable(toml, node)) {
    send_string 0, "'Value is a table'"
}
else if (NAVTomlIsDateTime(toml, node)) {
    send_string 0, "'Value is a date/time'"
}
```

## Advanced Features

### Dotted Keys

TOML dotted keys automatically create nested table structures:

```toml
server.host = "localhost"
server.port = 8080

# Equivalent to:
[server]
host = "localhost"
port = 8080
```

Query both forms the same way: `.server.host`

### Array of Tables

Repeated table headers create arrays:

```toml
[[products]]
name = "Hammer"
price = 9.99

[[products]]
name = "Nail"
price = 0.50
```

Query individual products: `.products[1].name`, `.products[2].price`

### Inline Tables

Compact table syntax on one line or multiline (TOML 1.1.0):

```toml
# Single-line inline table
point = { x = 10, y = 20, z = 30 }

# Multiline inline table (TOML 1.1.0)
config = {
    host = "192.168.1.1",
    port = 8080,
    ssl = true,
}

# Query both forms: .point.x or .config.host
```

### Number Formats

```toml
# Integers with underscores for readability
large = 1_000_000

# Different bases
hex = 0xDEADBEEF
octal = 0o755
binary = 0b11010110

# Floats
pi = 3.14159
scientific = 5e+22
infinity = inf
not_a_number = nan
```

### Date and Time

```toml
# Full datetime with timezone
created = 1979-05-27T07:32:00Z

# Datetime with offset
updated = 1979-05-27T00:32:00-07:00

# Local datetime (no timezone)
local = 1979-05-27T07:32:00

# Date only
birthday = 1979-05-27

# Time only
alarm = 07:32:00

# TOML 1.1.0: Optional seconds in datetime/time
event_time = 14:30           # Seconds default to :00
meeting = 2024-01-15T14:30   # Local datetime without seconds
appointment = 2024-01-15T14:30Z  # UTC datetime without seconds
```

### TOML 1.1.0 Features

#### New Escape Sequences

```toml
# \e - ESC character (0x1B)
ansi_color = "\e[31mRed Text\e[0m"

# \xHH - Hex byte escape (00-FF)
null_byte = "Hello\x00World"
ascii_a = "\x61"  # Same as "a"
byte_255 = "\xFF"
```

#### Multiline Inline Tables

```toml
# TOML 1.1.0: Inline tables can span multiple lines
server = {
    host = "localhost",
    port = 8080,
    ssl = true,
}

# Arrays of multiline inline tables
endpoints = [
    { path = "/api", method = "GET" },
    {
        path = "/data",
        method = "POST",
        auth = true,
    }
]
```

## Debug Logging

Enable debug output by defining compiler directives before including the library:

```netlinx
#DEFINE TOML_LEXER_DEBUG
#DEFINE TOML_PARSER_DEBUG
#DEFINE TOML_QUERY_DEBUG

#include 'NAVFoundation.Toml.axi'
```

This will output detailed information about:

- **Lexer**: Token generation, string parsing, number parsing
- **Parser**: Node creation, table building, value assignment
- **Query**: Path parsing, node traversal, value retrieval

## Testing

The library includes a comprehensive test suite located in `__tests__/include/toml/`:

### Test Categories

1. **Lexer Tests** (`NAVTomlLexerTokenize.axi`, `NAVTomlLexerEdgeCases.axi`)
    - String tokenization (basic, literal, multiline)
    - Number tokenization (all bases, floats, special values)
    - Table and array tokenization
    - Date/time tokenization (including TOML 1.1.0 optional seconds)
    - TOML 1.1.0 escape sequences (\e, \xHH)
    - Edge cases and error conditions

2. **Parser Tests** (`NAVTomlParse.axi`)
    - Basic key-value pairs
    - Table structures
    - Array structures
    - Array of tables
    - Inline tables (including TOML 1.1.0 multiline)
    - Dotted keys
    - Data type handling
    - TOML 1.1.0 features (escape sequences, optional seconds, multiline inline tables)

3. **Query Tests**
    - `NAVTomlQuery.axi` - General query operations
    - `NAVTomlQueryString.axi` - String queries
    - `NAVTomlQueryInteger.axi` - Integer queries
    - `NAVTomlQueryLong.axi` - Long integer queries
    - `NAVTomlQueryFloat.axi` - Float queries
    - `NAVTomlQueryBoolean.axi` - Boolean queries
    - Array query tests for each type

4. **Type Checking Tests** (`NAVTomlTypeChecking.axi`)
    - Type detection functions
    - Type validation

5. **Feature-Specific Tests**
    - `NAVTomlEscapeSequences.axi` - TOML 1.1.0 escape sequences (\e, \xHH)
    - `NAVTomlDeepNesting.axi` - Deep nesting scenarios
    - `NAVTomlLargeArrays.axi` - Large array handling
    - `NAVTomlLimits.axi` - Boundary and limit testing
    - `NAVTomlNavigationEdgeCases.axi` - Navigation edge cases
    - `NAVTomlParserUnescapeString.axi` - String unescaping tests

6. **Helper Function Tests**
    - `NAVTomlTreeInfo.axi` - Tree navigation functions
    - `NAVTomlGetParentNode.axi` - Parent navigation
    - `NAVTomlQueryEdgeCases.axi` - Edge cases and error handling
    - `NAVTomlValidation.axi` - Validation and errors
    - `NAVTomlValueGetters.axi` - Value getter functions

### Running Tests

Enable all tests in `__tests__/include/toml/toml.axi` or enable specific test categories:

```netlinx
#DEFINE TESTING_NAVTOMLPARSE
#DEFINE TESTING_NAVTOMLQUERY
#DEFINE TESTING_NAVTOMLQUERYSTRING
// ... etc
```

## Limitations

### Platform Limitations

- **IEEE 754 Special Float Values**: The lexer and parser correctly handle `inf`, `-inf`, and `nan` values per the TOML specification. These values are tokenized, parsed, and stored in the tree structure. However, query functions (`NAVTomlQueryFloat`) will return `false` when attempting to retrieve these values because NetLinx does not provide native representations for infinity or NaN. The values remain accessible in the tree as string representations via direct node access.

### Memory Constraints

- Maximum 2000 tokens per document (configurable via `NAV_TOML_LEXER_MAX_TOKENS`)
- Maximum 2000 nodes in parse tree (configurable via `NAV_TOML_PARSER_MAX_NODES`)
- Maximum 128 character key length (configurable via `NAV_TOML_PARSER_MAX_KEY_LENGTH`)
- No dynamic memory allocation (uses pre-allocated arrays)

## Files

### Library Files

- `NAVFoundation.Toml.axi` - Main library file
- `NAVFoundation.TomlLexer.h.axi` - Lexer header
- `NAVFoundation.TomlLexer.axi` - Lexer implementation
- `NAVFoundation.TomlParser.h.axi` - Parser header
- `NAVFoundation.TomlParser.axi` - Parser implementation
- `NAVFoundation.TomlQuery.h.axi` - Query header
- `NAVFoundation.TomlQuery.axi` - Query implementation

### Test Files

- `__tests__/include/toml/toml.axi` - Test orchestrator
- 30 individual test files covering all TOML 1.0.0 and 1.1.0 features

## Compatibility

- NetLinx/AMX control systems
- Compatible with existing NAVFoundation library patterns
- Follows same patterns as NAVFoundation.Json, NAVFoundation.Yaml, NAVFoundation.Xml

## References

- [TOML v1.1.0 Specification](https://toml.io/en/v1.1.0) (Current implementation)
- [TOML v1.0.0 Specification](https://toml.io/en/v1.0.0) (Backwards compatible)
- NAVFoundation library documentation

## License

See LICENSE file in repository root.

## Contributing

See CONTRIBUTING.md for guidelines on contributing to this library.
