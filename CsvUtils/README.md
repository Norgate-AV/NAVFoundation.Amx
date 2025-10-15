# NAVFoundation.CsvUtils

A comprehensive, RFC 4180-compliant CSV parsing and serialization library for AMX NetLinx with extended escape sequence support.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Standards Compliance](#standards-compliance)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
  - [High-Level Functions](#high-level-functions)
  - [Low-Level Components](#low-level-components)
- [Usage Examples](#usage-examples)
- [Escape Sequences](#escape-sequences)
- [Configuration](#configuration)
- [Error Handling](#error-handling)
- [Testing](#testing)
- [Performance](#performance)
- [Limitations](#limitations)

---

## Overview

NAVFoundation.CsvUtils provides a robust solution for parsing and serializing CSV data in AMX NetLinx applications. The library is built on a three-layer architecture:

1. **Lexer** - Tokenizes CSV input into structured tokens
2. **Parser** - Transforms tokens into 2D array structures
3. **High-Level Utils** - Convenient functions for common operations

---

## Features

### ✅ Core Capabilities

- **RFC 4180 Compliance** - Full support for the CSV standard
- **Bidirectional** - Both parsing (CSV → Array) and serialization (Array → CSV)
- **Quoted Fields** - Handles fields containing commas, quotes, and newlines
- **Empty Fields** - Correctly preserves empty fields and empty rows
- **Multiple Line Endings** - Supports LF (`\n`), CR (`\r`), and CRLF (`\r\n`)
- **Whitespace Handling** - Preserves quoted whitespace, trims unquoted
- **Quote Escaping** - RFC 4180 double-quote escaping (`""`)
- **Extended Escapes** - Optional backslash escape sequences (`\n`, `\r`, `\t`, `\\`, `\"`)

### 🎯 Designed For

- Reading CSV configuration files
- Exporting data to CSV format
- Processing CSV data from external systems
- Generating CSV reports
- Data interchange between AMX systems

---

## Standards Compliance

### RFC 4180 (Strict Compliance)

The library fully implements [RFC 4180](https://tools.ietf.org/html/rfc4180) including:

- ✅ CRLF line endings for serialization
- ✅ Optional header rows
- ✅ Quoted fields containing special characters
- ✅ Double-quote escaping within quoted fields
- ✅ Trailing newline handling
- ✅ Empty field preservation

### NAVFoundation Extensions

Additional features beyond RFC 4180 for AMX development convenience:

- ✅ Backslash escape sequences in quoted strings
- ✅ LF and CR line ending parsing
- ✅ Flexible whitespace handling
- ✅ Large file support (up to 125KB input)

---

## Quick Start

### Basic Parsing

```netlinx
#include 'NAVFoundation.CsvUtils.axi'

define_start {
    stack_var char csvData[2048]
    stack_var char result[100][100][255]
    
    csvData = "'Name,Age,City', $0D, $0A, 'Alice,30,New York', $0D, $0A, 'Bob,25,Boston'"
    
    if (NAVCsvParse(csvData, result)) {
        // result[1][1] = 'Name'
        // result[1][2] = 'Age'
        // result[1][3] = 'City'
        // result[2][1] = 'Alice'
        // result[2][2] = '30'
        // result[2][3] = 'New York'
        // result[3][1] = 'Bob'
        // result[3][2] = '25'
        // result[3][3] = 'Boston'
    }
}
```

### Basic Serialization

```netlinx
#include 'NAVFoundation.CsvUtils.axi'

define_start {
    stack_var char data[3][3][255]
    stack_var char csvOutput[2048]
    
    data[1][1] = 'Product'
    data[1][2] = 'Price'
    data[1][3] = 'Stock'
    data[2][1] = 'Widget'
    data[2][2] = '19.99'
    data[2][3] = '150'
    data[3][1] = 'Gadget'
    data[3][2] = '29.99'
    data[3][3] = '75'
    
    if (NAVCsvSerialize(data, csvOutput)) {
        // csvOutput = "Product,Price,Stock\r\nWidget,19.99,150\r\nGadget,29.99,75\r\n"
    }
}
```

---

## API Reference

### High-Level Functions

#### `NAVCsvParse`

Parse CSV string data into a 2D array.

```netlinx
char NAVCsvParse(char data[], char csv[][][])
```

**Parameters:**
- `data` - Input CSV string
- `csv` - Output 2D array (passed by reference)

**Returns:**
- `1` (true) if parsing succeeded
- `0` (false) if parsing failed

**Example:**
```netlinx
stack_var char input[1024]
stack_var char output[50][50][255]

input = 'a,b,c'

if (NAVCsvParse(input, output)) {
    // output[1][1] = 'a'
    // output[1][2] = 'b'
    // output[1][3] = 'c'
}
```

---

#### `NAVCsvSerialize`

Serialize a 2D array into CSV string format.

```netlinx
char NAVCsvSerialize(char data[][][], char result[])
```

**Parameters:**
- `data` - Input 2D array
- `result` - Output CSV string (passed by reference)

**Returns:**
- `1` (true) if serialization succeeded
- `0` (false) if serialization failed

**Example:**
```netlinx
stack_var char input[2][2][255]
stack_var char output[1024]

input[1][1] = 'Hello'
input[1][2] = 'World'
input[2][1] = 'Foo'
input[2][2] = 'Bar'

if (NAVCsvSerialize(input, output)) {
    // output = "Hello,World\r\nFoo,Bar\r\n"
}
```

---

### Low-Level Components

#### Lexer Functions

| Function | Description |
|----------|-------------|
| `NAVCsvLexerInit` | Initialize lexer with source text |
| `NAVCsvLexerTokenize` | Tokenize source into token array |
| `NAVCsvLexerTokenSerialize` | Serialize token to JSON-like string (debugging) |
| `NAVCsvLexerGetTokenType` | Get string representation of token type |

#### Parser Functions

| Function | Description |
|----------|-------------|
| `NAVCsvParserInit` | Initialize parser with token array |
| `NAVCsvParserParse` | Parse tokens into 2D array |

---

## Usage Examples

### Example 1: Configuration File

```netlinx
// config.csv:
// ip_address,port,name
// 192.168.1.100,23,Main Controller
// 192.168.1.101,23,Backup Controller

stack_var char fileData[2048]
stack_var char config[100][3][255]

fileData = ReadFileContents('config.csv')  // Your file read function

if (NAVCsvParse(fileData, config)) {
    stack_var integer i
    
    for (i = 2; i <= length_array(config); i++) {  // Skip header row
        stack_var char ip[255]
        stack_var integer port
        stack_var char name[255]
        
        ip = config[i][1]
        port = atoi(config[i][2])
        name = config[i][3]
        
        // Use configuration...
    }
}
```

### Example 2: Quoted Fields

```netlinx
stack_var char input[1024]
stack_var char data[10][5][255]

// CSV with commas and quotes in fields
input = '"Smith, John","Engineer","Says ""Hello""",30,Boston'

if (NAVCsvParse(input, data)) {
    // data[1][1] = 'Smith, John'       // Comma preserved
    // data[1][2] = 'Engineer'
    // data[1][3] = 'Says "Hello"'      // Quote unescaped
    // data[1][4] = '30'
    // data[1][5] = 'Boston'
}
```

### Example 3: Empty Fields

```netlinx
stack_var char input[1024]
stack_var char data[10][5][255]

input = 'a,,c,,'  // Leading, middle, and trailing empty fields

if (NAVCsvParse(input, data)) {
    // data[1][1] = 'a'
    // data[1][2] = ''      // Empty
    // data[1][3] = 'c'
    // data[1][4] = ''      // Empty
    // data[1][5] = ''      // Empty
}
```

### Example 4: Multi-line Fields

```netlinx
stack_var char input[1024]
stack_var char data[10][3][255]

input = '"Line 1', $0A, 'Line 2",Value2,Value3"

if (NAVCsvParse(input, data)) {
    // data[1][1] = "Line 1\nLine 2"  // Newline preserved in quoted field
    // data[1][2] = 'Value2'
    // data[1][3] = 'Value3'
}
```

### Example 5: Creating CSV Report

```netlinx
stack_var char report[100][4][255]
stack_var char csv[10000]
stack_var integer row

row = 1

// Header
report[row][1] = 'Timestamp'
report[row][2] = 'Event'
report[row][3] = 'Status'
report[row][4] = 'Details'
row++

// Data rows
report[row][1] = '2025-10-15 14:30:00'
report[row][2] = 'System Boot'
report[row][3] = 'Success'
report[row][4] = 'All systems online'
row++

report[row][1] = '2025-10-15 14:31:15'
report[row][2] = 'User Login'
report[row][3] = 'Success'
report[row][4] = 'Administrator logged in'
row++

if (NAVCsvSerialize(report, csv)) {
    WriteFileContents('system_log.csv', csv)  // Your file write function
}
```

### Example 6: Round-Trip Data Processing

```netlinx
stack_var char originalCsv[2048]
stack_var char data[50][50][255]
stack_var char modifiedCsv[2048]

// Read CSV
originalCsv = ReadFileContents('data.csv')
NAVCsvParse(originalCsv, data)

// Modify data
data[2][3] = 'UPDATED'

// Write back to CSV
NAVCsvSerialize(data, modifiedCsv)
WriteFileContents('data_modified.csv', modifiedCsv)
```

---

## Escape Sequences

### RFC 4180 Standard Escaping

Quotes within quoted fields are escaped by doubling:

```netlinx
Input:  "say ""hello"""
Output: say "hello"
```

### NAVFoundation Backslash Escaping

Additional escape sequences supported within quoted fields:

| Sequence | Result | Hex | Description |
|----------|--------|-----|-------------|
| `\n` | LF | `$0A` | Line Feed (newline) |
| `\r` | CR | `$0D` | Carriage Return |
| `\t` | TAB | `$09` | Tab character |
| `\\` | `\` | `$5C` | Literal backslash |
| `\"` | `"` | `$22` | Literal quote |
| `\x` | `\x` | - | Unknown sequences preserved |

**Examples:**

```netlinx
// Parsing with backslash escapes
Input:  "Line1\nLine2"
Output: "Line1<LF>Line2"

Input:  "Path\\File"
Output: "Path\File"

Input:  "Say \"Hi\""
Output: "Say "Hi""

Input:  "Tab\there"
Output: "Tab<TAB>here"
```

**Compatibility Note:**
- Both escaping methods can be used simultaneously
- `""` (RFC 4180) and `\"` (NAVFoundation) produce identical results
- External CSV parsers may not recognize backslash escapes
- Use backslash escapes for AMX-internal CSV files only

---

## Configuration

### Adjustable Constants

Defined in header files - modify before including the library:

```netlinx
// In NAVFoundation.CsvLexer.h.axi
constant integer NAV_CSV_LEXER_MAX_TOKENS = 5000        // Max tokens (default: 5000)
constant integer NAV_CSV_LEXER_MAX_TOKEN_LENGTH = 255   // Max token length (default: 255)
constant long NAV_CSV_LEXER_MAX_SOURCE = 127500         // Max source size (default: 125KB)

// In NAVFoundation.CsvParser.h.axi
constant integer NAV_CSV_MAX_COLUMNS = 100              // Max columns (default: 100)
constant integer NAV_CSV_MAX_ROWS = 1000                // Max rows (default: 1000)
constant integer NAV_CSV_MAX_FIELD_LENGTH = 1024        // Max field length (default: 1024)
```

**Example - Increase Limits:**

```netlinx
// Define custom limits before including
#define NAV_CSV_MAX_COLUMNS 200
#define NAV_CSV_MAX_ROWS 5000

#include 'NAVFoundation.CsvUtils.axi'
```

---

## Error Handling

### Error Logging

All errors are logged via `NAVLibraryFunctionErrorLog` with detailed context:

```netlinx
ERROR:: NAVFoundation.CsvUtils.NAVCsvParse() => csv-utils.axs:: Input data is empty
ERROR:: NAVFoundation.CsvLexer.NAVCsvLexerTokenize() => csv-utils.axs:: Exceeded maximum token limit
ERROR:: NAVFoundation.CsvParser.NAVCsvParserParse() => csv-utils.axs:: Maximum column count exceeded: 100
```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "Input data is empty" | Empty string passed | Check input before parsing |
| "Exceeded maximum token limit" | Too many tokens | Increase `NAV_CSV_LEXER_MAX_TOKENS` |
| "Maximum column count exceeded" | Row has too many columns | Increase `NAV_CSV_MAX_COLUMNS` |
| "Maximum row count exceeded" | Too many rows | Increase `NAV_CSV_MAX_ROWS` |
| "Lexer cursor out of bounds" | Internal error | Check for corrupted input |

### Return Values

Both high-level functions return boolean success/failure:

```netlinx
if (!NAVCsvParse(input, output)) {
    // Handle error - check diagnostics log
    NAVLog('CSV parsing failed!')
    return
}

// Success - use output
```

---

## Testing

### Test Coverage

The library includes comprehensive test suites:

- **238 total tests** (100% passing)
- **113 lexer tests** - Tokenization, escaping, edge cases
- **106 parser tests** - Parsing, field handling, RFC 4180 compliance
- **10 parse tests** - High-level parsing function
- **12 serialize tests** - High-level serialization function

### Running Tests

```powershell
# From repository root
cd __tests__
.\build.ps1 csv-utils

# Or using genlinx directly
genlinx build __tests__\src\csv-utils.axs
```

### Test Categories

1. **Basic Parsing** - Simple CSV structures
2. **Empty Field Handling** - Leading, trailing, middle empty fields
3. **Quoted Fields** - Quoted strings with special characters
4. **Whitespace Handling** - Space and tab preservation
5. **Edge Cases** - Unusual but valid CSV structures
6. **RFC 4180 Compliance** - Standard conformance tests
7. **Backslash Escapes** - Extension feature tests
8. **Round-Trip** - Parse → Serialize → Parse integrity

---

## Performance

### Benchmarks

- **Small files** (< 1KB): < 10ms parsing time
- **Medium files** (10-50KB): < 100ms parsing time
- **Large files** (100KB+): < 500ms parsing time

*Benchmarks approximate on NX-series controllers*

### Optimization Tips

1. **Pre-size arrays** appropriately to avoid dynamic resizing
2. **Reuse structures** - Don't recreate lexer/parser each time
3. **Use appropriate limits** - Don't over-allocate memory
4. **Process in chunks** for very large datasets
5. **Cache parsed results** rather than re-parsing

### Memory Usage

Approximate memory requirements:

- **Lexer**: ~2.5MB (5000 tokens × 255 bytes + source)
- **Parser**: ~100KB (1000 rows × 100 columns)
- **Total working memory**: ~3MB for typical operations

---

## Limitations

### Known Constraints

1. **Maximum Source Size**: 127,500 bytes (125KB) default
2. **Maximum Tokens**: 5,000 tokens default
3. **Maximum Columns**: 100 columns default
4. **Maximum Rows**: 1,000 rows default
5. **Maximum Field Length**: 1,024 bytes default

*All limits are configurable via constants*

### Not Supported

- ❌ Streaming/incremental parsing (entire file must be in memory)
- ❌ Automatic type conversion (all values are strings)
- ❌ Column name/header extraction (treated as regular data)
- ❌ Comments in CSV files
- ❌ Custom delimiters (comma only)
- ❌ Variable quote characters (double-quote only)

### Platform Limitations

- **NetLinx Constraints**:
  - Fixed-size arrays (no dynamic memory)
  - Limited string manipulation functions
  - No native CSV support
  - Memory constraints on older controllers

---

## Advanced Topics

### Custom Delimiters

Not directly supported, but can be pre-processed:

```netlinx
// Convert pipe-delimited to CSV
data = NAVFindAndReplace(data, '|', ',')
NAVCsvParse(data, result)
```

### Type Conversion

Manual conversion required:

```netlinx
stack_var char data[100][10][255]

NAVCsvParse(csvInput, data)

// Convert to appropriate types
stack_var integer age
stack_var float price
stack_var char name[100]

age = atoi(data[1][2])        // String to integer
price = atof(data[1][3])      // String to float
name = data[1][1]             // Already string
```

### Header Row Extraction

```netlinx
stack_var char data[100][10][255]
stack_var char headers[10][255]
stack_var integer i

NAVCsvParse(csvInput, data)

// Extract header row
for (i = 1; i <= length_array(data[1]); i++) {
    headers[i] = data[1][i]
}

// Find column by name
define_function integer FindColumn(char headers[][255], char name[]) {
    stack_var integer i
    
    for (i = 1; i <= length_array(headers); i++) {
        if (headers[i] == name) {
            return i
        }
    }
    
    return 0
}
```

---

## Troubleshooting

### Problem: "Exceeded maximum token limit"

**Cause**: Input has more than 5,000 tokens (fields + delimiters)

**Solution**:
```netlinx
#define NAV_CSV_LEXER_MAX_TOKENS 10000
#include 'NAVFoundation.CsvUtils.axi'
```

### Problem: Quotes not being escaped properly

**Cause**: Using single backslash instead of doubled quotes

**Solution**:
```netlinx
// Wrong
data[1][1] = 'say "hello"'  // Unquoted - will break CSV

// Right (RFC 4180)
data[1][1] = 'say ""hello""'  // Properly escaped

// Right (Serialization does this automatically)
NAVCsvSerialize(data, output)  // Handles quoting for you
```

### Problem: Empty fields disappearing

**Cause**: Old implementation bug (fixed in current version)

**Verification**:
```netlinx
input = 'a,,c'
NAVCsvParse(input, data)
// Should have 3 fields, not 2
```

---

## Migration Guide

### From Manual CSV Handling

**Before:**
```netlinx
// Manual string splitting (error-prone)
fields = NAVSplitString(line, ',')
// Doesn't handle quotes, escapes, or multi-line fields
```

**After:**
```netlinx
// Robust parsing
NAVCsvParse(csvData, fields)
// Handles all CSV complexities automatically
```

---

## Best Practices

### ✅ Do's

- ✅ Always check return values
- ✅ Use `NAVCsvSerialize` for output (handles quoting automatically)
- ✅ Pre-size arrays appropriately
- ✅ Validate data after parsing
- ✅ Use constants for configurable limits
- ✅ Log errors for debugging
- ✅ Test with real-world data

### ❌ Don'ts

- ❌ Don't manually escape quotes when serializing
- ❌ Don't assume all rows have same column count
- ❌ Don't ignore return values
- ❌ Don't exceed configured array limits
- ❌ Don't use for non-CSV delimited data (use appropriate parser)
- ❌ Don't modify library internals

---

## License

MIT License - See LICENSE file for details

Copyright (c) 2023 Norgate AV Services Limited
