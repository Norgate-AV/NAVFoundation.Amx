# NAVFoundation.Jsmn

A minimalistic JSON parser for AMX NetLinx, ported from the [jsmn C library](https://github.com/zserge/jsmn). Jsmn (pronounced like 'jasmine') provides a lightweight, efficient way to parse JSON data in resource-constrained NetLinx environments.

## Features

- **Minimalist Design**: Core parser is ~650 lines of NetLinx code
- **Zero-Copy Parsing**: Tokens point to positions in the original JSON string - no string duplication
- **No Dynamic Memory**: All memory is stack-allocated using NetLinx arrays
- **Incremental Parsing**: Single-pass parser that can handle streaming data
- **Standards Compliant**: Passes all 61 test cases from the original C implementation
- **Production Ready**: Extensively tested with multiple parsing modes (strict/non-strict, parent links)

## Philosophy

Most JSON parsers allocate temporary objects and provide complex APIs to extract values. Jsmn proves that for many use cases, this is overkill. By simply identifying token boundaries in the original string, you can efficiently parse JSON without unnecessary memory overhead.

JSON format is simple - the parser should be too.

## Installation

Include the JSMN library in your NetLinx project:

```netlinx
#include 'NAVFoundation.Jsmn.axi'
```

For helper functions (optional):

```netlinx
#include 'NAVFoundation.JsmnEx.axi'
```

## Quick Start

```netlinx
DEFINE_VARIABLE

JsmnParser parser
JsmnToken tokens[128]
char json[NAV_MAX_BUFFER]
sinteger result

DEFINE_START

json = '{"name":"AMX","version":1.0,"active":true}'

jsmn_init(parser)
result = jsmn_parse(parser, json, length_array(json), tokens, max_length_array(tokens))

if (result > 0) {
    // Successfully parsed - result contains the number of tokens
    // tokens[1] is the root object
    // tokens[2] is the first key "name"
    // tokens[3] is the value "AMX"
    // etc.
}
else {
    // Error occurred
    switch (result) {
        case JSMN_ERROR_NOMEM: { /* Not enough tokens */ }
        case JSMN_ERROR_INVAL: { /* Invalid JSON syntax */ }
        case JSMN_ERROR_PART: { /* Incomplete JSON string */ }
    }
}
```

## Token Structure

Each parsed JSON element is represented by a `JsmnToken`:

```netlinx
STRUCTURE JsmnToken {
    integer type      // Token type (JSMN_TYPE_OBJECT, JSMN_TYPE_ARRAY, etc.)
    sinteger start    // Start position in JSON string
    sinteger end      // End position in JSON string
    integer size      // Number of child tokens (for objects/arrays)
    sinteger parent   // Index of parent token (-1 for root)
}
```

### Token Types

- `JSMN_TYPE_UNDEFINED` (0): Uninitialized token
- `JSMN_TYPE_OBJECT`: JSON object `{...}`
- `JSMN_TYPE_ARRAY`: JSON array `[...]`
- `JSMN_TYPE_STRING`: Quoted string `"..."`
- `JSMN_TYPE_PRIMITIVE`: Number, boolean (true/false), or null

## Extracting Values

Use the helper function to extract token values:

```netlinx
#include 'NAVFoundation.JsmnEx.axi'

// Get the value of a token
stack_var char value[NAV_MAX_BUFFER]
value = jsmnex_get_token_value(json, tokens[3])  // Returns "AMX" (with quotes)

// Check if a token matches a specific value
if (jsmnex_token_equals(json, tokens[2], '"name"')) {
    // This is the "name" key
}
```

## Parser Configuration

### Strict Mode

Enable strict JSON validation (keys must be strings, no multiple root values):

```netlinx
#DEFINE JSMN_STRICT
#include 'NAVFoundation.Jsmn.axi'
```

### Parent Links

Enable parent token tracking for easier navigation:

```netlinx
#DEFINE JSMN_PARENT_LINKS
#include 'NAVFoundation.Jsmn.axi'
```

With parent links enabled, each token's `parent` field contains the index of its parent token, making it easy to traverse the hierarchy.

### Debug Mode

Enable debug logging for troubleshooting:

```netlinx
#DEFINE JSMN_DEBUG
#include 'NAVFoundation.Jsmn.axi'
```

## Parsing Examples

### Simple Object

```netlinx
json = '{"temperature":72.5,"unit":"F"}'
// tokens[1]: Object (root)
// tokens[2]: String "temperature"
// tokens[3]: Primitive 72.5
// tokens[4]: String "unit"
// tokens[5]: String "F"
```

### Array

```netlinx
json = '["red","green","blue"]'
// tokens[1]: Array (root, size=3)
// tokens[2]: String "red"
// tokens[3]: String "green"
// tokens[4]: String "blue"
```

### Nested Structure

```netlinx
json = '{"user":{"name":"John","age":30}}'
// tokens[1]: Object (root, size=1)
// tokens[2]: String "user"
// tokens[3]: Object (size=2)
// tokens[4]: String "name"
// tokens[5]: String "John"
// tokens[6]: String "age"
// tokens[7]: Primitive 30
```

## Helper Functions (JsmnEx)

The extended API provides convenience functions:

- `jsmnex_parse()`: Simplified parse wrapper
- `jsmnex_get_token_value()`: Extract token value from JSON string
- `jsmnex_token_equals()`: Compare token value with a string
- `jsmnex_token_type_to_string()`: Convert token type to readable string
- `jsmnex_print_token()`: Debug output for single token
- `jsmnex_print_tokens()`: Debug output for token array
- `jsmnex_print_error()`: Pretty-print error messages
- `jsmnex_print_parser()`: Show parser state

## Important Notes

### NetLinx Array Indexing

NetLinx arrays are 1-based, unlike C's 0-based arrays. The first token is at `tokens[1]`, not `tokens[0]`.

### String Tokens

String token positions point to the **content between quotes**, not including the quotes themselves. However, `jsmnex_get_token_value()` returns the full string including quotes.

### Escape Sequences

The parser validates escape sequences (`\n`, `\t`, `\"`, etc.) but does **not** decode them. Tokens contain the raw JSON text with backslash escapes intact.

### Unicode Escapes

Unicode escape sequences (`\uXXXX`) are validated to ensure exactly 4 hexadecimal digits follow `\u`, but are not converted to actual Unicode characters.

## Testing

The implementation includes a comprehensive test suite with 61 tests covering:

- Empty objects and arrays
- Nested structures
- String escapes and unicode
- Primitives (numbers, booleans, null)
- Error conditions (malformed JSON)
- Strict vs non-strict modes
- Partial parsing
- Unquoted keys (non-strict mode)

All tests pass in multiple configurations (strict mode, parent links, combinations).

## Performance

Token-based parsing is extremely efficient:

- No string copies or allocations
- Single pass through the JSON data
- Minimal memory footprint
- Suitable for embedded NetLinx environments

## Credits

This is a NetLinx port of [jsmn](https://github.com/zserge/jsmn) by Serge Zaitsev.

Original C library: https://github.com/zserge/jsmn

## License

MIT License - Copyright (c) 2010-2026 Norgate AV

See LICENSE file for full license text.

