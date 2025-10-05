# NAVFoundation.Regex

A lightweight regular expression engine for NetLinx, based on [tiny-regex-c](https://github.com/kokke/tiny-regex-c) with modifications for NetLinx compatibility.

## Overview

This library provides pattern matching capabilities for NetLinx applications.

## Quick Start

```netlinx
#include 'NAVFoundation.Regex.axi'

// Compile a pattern
_NAVRegexParser parser
if (NAVRegexCompile('/\d+/', parser)) {
    // Match against text
    if (NAVRegexMatch(parser, '12345')) {
        // Match found!
    }
}
```

## Supported Features

### ✅ Character Classes

| Pattern       | Description                              | Example                               |
| ------------- | ---------------------------------------- | ------------------------------------- |
| `.`           | Any character except newline             | `/a.c/` matches "abc", "a1c", "a-c"   |
| `\d`          | Digit (0-9)                              | `/\d+/` matches "123"                 |
| `\D`          | Non-digit                                | `/\D+/` matches "abc"                 |
| `\w`          | Word character (a-z, A-Z, 0-9, \_)       | `/\w+/` matches "hello_123"           |
| `\W`          | Non-word character                       | `/\W+/` matches "!@#"                 |
| `\s`          | Whitespace (space, tab, newline, return) | `/\s+/` matches " "                   |
| `\S`          | Non-whitespace                           | `/\S+/` matches "hello"               |
| `[abc]`       | Character set (a, b, or c)               | `/[aeiou]/` matches any vowel         |
| `[^abc]`      | Negated character set (not a, b, or c)   | `/[^0-9]/` matches non-digits         |
| `[a-z]`       | Character range                          | `/[a-z]+/` matches lowercase letters  |
| `[a-zA-Z0-9]` | Multiple ranges                          | `/[a-zA-Z0-9]+/` matches alphanumeric |

### ✅ Quantifiers

| Pattern | Description            | Example                                     |
| ------- | ---------------------- | ------------------------------------------- |
| `?`     | Zero or one (optional) | `/colou?r/` matches "color" or "colour"     |
| `*`     | Zero or more (greedy)  | `/ab*c/` matches "ac", "abc", "abbc"        |
| `+`     | One or more (greedy)   | `/ab+c/` matches "abc", "abbc" but not "ac" |
| `{n}`   | Exactly n times        | `/a{3}/` matches "aaa" only                 |
| `{n,}`  | At least n times       | `/a{2,}/` matches "aa", "aaa", "aaaa", etc. |
| `{n,m}` | Between n and m times  | `/a{2,4}/` matches "aa", "aaa", or "aaaa"   |

### ✅ Anchors

| Pattern | Description       | Example                                                   |
| ------- | ----------------- | --------------------------------------------------------- |
| `^`     | Start of string   | `/^hello/` matches "hello world" but not "say hello"      |
| `$`     | End of string     | `/world$/` matches "hello world" but not "world hello"    |
| `\b`    | Word boundary     | `/\bcat\b/` matches "cat" in "the cat" but not "category" |
| `\B`    | Non-word boundary | `/\Bcat\B/` matches "cat" in "category" but not "the cat" |

### ✅ Escape Sequences

| Pattern | Description           |
| ------- | --------------------- |
| `\.`    | Literal dot           |
| `\*`    | Literal asterisk      |
| `\+`    | Literal plus          |
| `\?`    | Literal question mark |
| `\[`    | Literal open bracket  |
| `\]`    | Literal close bracket |
| `\^`    | Literal caret         |
| `\$`    | Literal dollar sign   |
| `\\`    | Literal backslash     |
| `\t`    | Tab character         |
| `\n`    | Newline character     |
| `\r`    | Carriage return       |

## Not Supported (Yet)

### ❌ Advanced Features

- **Lazy Quantifiers** (`*?`, `+?`, `??`, `{n,m}?`) - All quantifiers are greedy
- **Capturing Groups** (`()`) - No group capture or backreferences
- **Alternation** (`|`) - Or operator not supported
- **Lookahead/Lookbehind** (`(?=...)`, `(?!...)`) - Not supported
- **Unicode** - Only ASCII character support
- **Hex Escapes** (`\xHH`) - Not yet implemented
- **Octal Escapes** (`\ooo`) - Not supported
- **Case-Insensitive Matching** - No inline flags support
- **Multi-line Mode** - No mode modifiers

### ⚠️ Limitations

- **No Backreferences** - Cannot reference captured groups
- **Greedy Only** - All quantifiers match greedily (maximum possible)
- **Single-line Patterns** - `.` does not match newlines
- **Fixed Buffer Size** - Maximum pattern complexity is limited by `NAV_REGEX_MAX_STATES` (default: 128)
- **ASCII Only** - No extended character set support

## Pattern Syntax

Patterns must be enclosed in forward slashes:

```netlinx
'/pattern/'    // Basic pattern
```

### Examples

```netlinx
// Email validation (simple)
'/\w+@\w+\.\w+/'

// IP address pattern
'/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/'

// Hexadecimal color code
'/^#[a-fA-F0-9]{6}$/'

// Word extraction
'/\b\w+\b/'

// Whitespace trimming
'/^\s+|\s+$/'
```

## API Reference

### NAVRegexCompile

Compiles a regex pattern into an internal representation.

```netlinx
define_function char NAVRegexCompile(char pattern[], _NAVRegexParser parser)
```

**Parameters:**

- `pattern[]` - The regex pattern string (e.g., `'/\d+/'`)
- `parser` - Parser structure to store compiled pattern

**Returns:** `true` if compilation succeeds, `false` on error

### NAVRegexMatch

Tests if a string matches the compiled pattern.

```netlinx
define_function char NAVRegexMatch(_NAVRegexParser parser, char text[])
```

**Parameters:**

- `parser` - Compiled pattern from `NAVRegexCompile`
- `text[]` - The string to test

**Returns:** `true` if match found, `false` otherwise

## Performance Considerations

- **Compile Once, Match Many** - Cache compiled patterns when possible
- **Pattern Complexity** - Complex patterns with many states may hit `NAV_REGEX_MAX_STATES` limit
- **Greedy Matching** - Patterns like `.*` can be slow on long strings
- **Memory Usage** - Each compiled pattern uses approximately 10KB of stack space

## Error Handling

The library logs errors using `NAVLibraryFunctionErrorLog`. Common errors include:

- **Invalid pattern syntax** - Unclosed brackets, invalid escapes
- **Pattern too complex** - Exceeds `NAV_REGEX_MAX_STATES`
- **Missing delimiters** - Pattern not enclosed in `/` slashes
- **Invalid quantifiers** - Malformed `{n,m}` syntax

## Testing

The library includes comprehensive test coverage:

- **Compiler Tests** - 61 patterns testing compilation
- **Matcher Tests** - 170+ tests for pattern matching
- **Edge Cases** - Empty strings, special characters, boundaries

Run tests with:

```
genlinx boot ".\__tests__\src\regex.axs" -o ".\test.log"
```

## Future Enhancements

See `REFACTORING.md` for planned improvements:

1. Hex escape sequences (`\xHH`)
2. Performance optimization with bitmaps
3. Lazy quantifier support
4. Capturing groups
5. Alternation operator

## Credits

Based on [tiny-regex-c](https://github.com/kokke/tiny-regex-c) by Kenneth Kaane Dalsgaard Jakobsen.

Adapted for NetLinx by Norgate AV.
