# NAVFoundation.IniUtils

A comprehensive INI file parsing library for AMX NetLinx systems. This library provides robust parsing capabilities for INI configuration files with support for sections, properties, comments, and various data types.

## Features

- **Complete INI Parsing**: Parse standard INI file format with sections and key-value pairs
- **Flexible Value Access**: Multiple methods to retrieve values including dot notation
- **Comment Support**: Handle both semicolon (`;`) and hash (`#`) style comments
- **String Handling**: Support for quoted and unquoted strings with escape sequences
- **Robust Error Handling**: Comprehensive bounds checking and error reporting
- **Memory Safe**: Advanced cursor management with out-of-bounds protection
- **Configurable Limits**: All size constraints can be customized via compiler directives
- **Memory Efficient**: Optimized data structures for NetLinx memory constraints
- **Production Ready**: Extensively tested with comprehensive test suite

## Quick Start

### Basic Usage

```netlinx
#include 'NAVFoundation.IniFileUtils.axi'

stack_var char data[2048]
stack_var _NAVIniFile ini
stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

// Load your INI data (however you read the file)
data = "'[database]', 10, 'host=localhost', 10, 'port=5432', 10, 10, '[app]', 10, 'debug=true'"

// Parse the INI data
if (NAVIniFileParse(data, ini)) {
    // Get values using different methods
    value = NAVIniFileGetValue(ini, 'database.host')     // Returns 'localhost'
    value = NAVIniFileGetValue(ini, 'app.debug')         // Returns 'true'
    value = NAVIniFileGetGlobalValue(ini, 'timeout')     // Look in default section
}
```

### INI File Format Support

The library supports standard INI format:

```ini
; This is a comment
# This is also a comment

; Global properties (in default section)
timeout=30
retries=3

[database]
host=localhost
port=5432
username="admin user"
password='secret123'

[application]
name=MyApp
debug=true
log_level=info
```

## API Reference

### High-Level Functions

#### `NAVIniFileParse`
**Purpose**: Main parsing function to convert INI text into a structured format.

**Signature**: `char NAVIniFileParse(char data[], _NAVIniFile iniFile)`

**Parameters**:
- `data[]` - The INI file content as a string
- `iniFile` - Output structure to store parsed data

**Returns**: `1` on success, `0` on failure

**Example**:
```netlinx
stack_var char iniText[1024]
stack_var _NAVIniFile parsedIni

iniText = "'[section1]', 10, 'key1=value1'"
if (NAVIniFileParse(iniText, parsedIni)) {
    // Successfully parsed
}
```

#### `NAVIniFileGetValue`
**Purpose**: Get a property value using dot notation.

**Signature**: `char[NAV_INI_PARSER_MAX_VALUE_LENGTH] NAVIniFileGetValue(_NAVIniFile iniFile, char dotPath[])`

**Parameters**:
- `iniFile` - Parsed INI structure
- `dotPath` - Path in format "section.key" or just "key" for global

**Returns**: Property value or empty string if not found

**Example**:
```netlinx
stack_var char result[NAV_INI_PARSER_MAX_VALUE_LENGTH]
result = NAVIniFileGetValue(ini, 'database.host')      // section.key format
result = NAVIniFileGetValue(ini, 'timeout')           // global key format
```

### Section and Property Functions

#### `NAVIniFileGetSectionValue`
**Purpose**: Get a property value from a specific section.

**Signature**: `char[NAV_INI_PARSER_MAX_VALUE_LENGTH] NAVIniFileGetSectionValue(_NAVIniFile iniFile, char sectionName[], char propertyKey[])`

#### `NAVIniFileGetGlobalValue`
**Purpose**: Get a property value from the global (default) section.

**Signature**: `char[NAV_INI_PARSER_MAX_VALUE_LENGTH] NAVIniFileGetGlobalValue(_NAVIniFile iniFile, char propertyKey[])`

#### `NAVIniFileFindSection`
**Purpose**: Find the index of a section by name.

**Signature**: `integer NAVIniFileFindSection(_NAVIniFile iniFile, char sectionName[])`

**Returns**: 1-based section index, or 0 if not found

#### `NAVIniFileFindProperty`
**Purpose**: Find the index of a property within a section.

**Signature**: `integer NAVIniFileFindProperty(_NAVIniSection section, char propertyKey[])`

**Returns**: 1-based property index, or 0 if not found

## Data Structures

### `_NAVIniFile`
Main structure containing the parsed INI data:
```netlinx
structure _NAVIniFile {
    integer sectionCount
    _NAVIniSection sections[NAV_INI_PARSER_MAX_SECTIONS]
}
```

### `_NAVIniSection`
Represents a section within the INI file:
```netlinx
structure _NAVIniSection {
    char name[NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH]
    integer propertyCount
    _NAVIniProperty properties[NAV_INI_PARSER_MAX_PROPERTIES]
}
```

### `_NAVIniProperty`
Represents a key-value pair:
```netlinx
structure _NAVIniProperty {
    char key[NAV_INI_PARSER_MAX_KEY_LENGTH]
    char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]
}
```

## Advanced Usage

### Working with Sections Directly

```netlinx
stack_var integer sectionIndex
stack_var integer propertyIndex
stack_var _NAVIniSection section

// Find a specific section
sectionIndex = NAVIniFileFindSection(ini, 'database')
if (sectionIndex > 0) {
    section = ini.sections[sectionIndex]
    
    // Find a property in that section
    propertyIndex = NAVIniFileFindProperty(section, 'host')
    if (propertyIndex > 0) {
        // Access the value directly
        send_string 0, "'Host: ', section.properties[propertyIndex].value"
    }
}
```

### Iterating Through All Data

```netlinx
stack_var integer i, j

// Iterate through all sections
for (i = 1; i <= ini.sectionCount; i++) {
    send_string 0, "'Section: [', ini.sections[i].name, ']'"
    
    // Iterate through all properties in this section
    for (j = 1; j <= ini.sections[i].propertyCount; j++) {
        send_string 0, "'  ', ini.sections[i].properties[j].key, ' = ', ini.sections[i].properties[j].value"
    }
}
```

## Error Handling

The library provides comprehensive error logging through the NAVFoundation error logging system. Errors are logged with:

- **Error Level**: Detailed error messages for debugging
- **Function Context**: Which function encountered the error
- **Specific Details**: What went wrong and where

Common error scenarios:
- Malformed INI syntax
- Missing closing brackets in sections
- Invalid property assignments
- Unexpected end of input

## Implementation Details

### Parser Architecture

The library uses a robust two-stage parsing approach with enhanced safety features:

1. **Lexical Analysis** (`NAVFoundation.IniFileLexer.axi`): Breaks input into tokens with bounds checking
2. **Syntax Analysis** (`NAVFoundation.IniFileParser.axi`): Builds structured data from tokens with cursor safety

**Safety Features:**
- Comprehensive bounds checking prevents array access violations
- Centralized cursor management with automatic validation
- Detailed error logging for debugging and troubleshooting
- Graceful error recovery and reporting

### Token Types

- `LBRACKET` - `[`
- `RBRACKET` - `]`
- `EQUALS` - `=`
- `IDENTIFIER` - Alphanumeric strings, keys, section names
- `STRING` - Quoted strings or unquoted values
- `COMMENT` - Comments starting with `;` or `#`
- `NEWLINE` - Line terminators
- `WHITESPACE` - Spaces and tabs (ignored)

### Memory Considerations

The library is designed for NetLinx memory constraints with configurable limits:
- Maximum sections: `NAV_INI_PARSER_MAX_SECTIONS` (default: 100)
- Maximum properties per section: `NAV_INI_PARSER_MAX_PROPERTIES` (default: 100)
- Maximum key length: `NAV_INI_PARSER_MAX_KEY_LENGTH` (default: 64)
- Maximum value length: `NAV_INI_PARSER_MAX_VALUE_LENGTH` (default: 255)
- Maximum section name length: `NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH` (default: 64)

All limits can be customized by defining the constants before including the library.

## Configuration

The library supports customizable limits through compiler directives. Define these constants before including the library to override defaults:

```netlinx
// Customize limits (optional)
#DEFINE NAV_INI_PARSER_MAX_SECTIONS 200              // Default: 100
#DEFINE NAV_INI_PARSER_MAX_PROPERTIES 150            // Default: 100  
#DEFINE NAV_INI_PARSER_MAX_KEY_LENGTH 128             // Default: 64
#DEFINE NAV_INI_PARSER_MAX_VALUE_LENGTH 512          // Default: 255
#DEFINE NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH 128   // Default: 64

// Include the library
#include 'NAVFoundation.IniFileUtils.axi'
```

## Dependencies

- `NAVFoundation.Core.axi` - Core utilities and constants
- `NAVFoundation.StringUtils.axi` - String manipulation functions
- `NAVFoundation.ErrorLogUtils.axi` - Error logging capabilities

## Files Included

- `NAVFoundation.IniFileUtils.axi` - High-level utility functions
- `NAVFoundation.IniFileParser.axi` - Syntax parsing logic
- `NAVFoundation.IniFileLexer.axi` - Tokenization logic
- `NAVFoundation.IniFileParser.h.axi` - Parser data structures
- `NAVFoundation.IniFileLexer.h.axi` - Lexer data structures

## Best Practices

1. **Always check return values** from parsing functions
2. **Use dot notation** for cleaner, more readable value access
3. **Handle missing values gracefully** - functions return empty strings for missing keys
4. **Use constants for buffer sizes** - Use `NAV_INI_PARSER_MAX_VALUE_LENGTH` for value buffers
5. **Configure limits appropriately** - Adjust constants based on your application needs
6. **Monitor error logs** - The library provides detailed error information for debugging
7. **Test with edge cases** - Validate parsing with malformed INI files
8. **Keep INI files reasonable in size** due to NetLinx memory limitations

## Examples

See the `__tests__` directory for comprehensive examples and test cases demonstrating various usage patterns and edge cases.
