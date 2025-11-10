# NAVFoundation.Regex

A complete, production-ready regular expression library for NetLinx/AMX control systems.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
  - [Lexer](#lexer)
  - [Parser](#parser)
  - [Matcher](#matcher)
  - [Template](#template)
- [Feature Support Matrix](#feature-support-matrix)
- [Real-World Pattern Support](#real-world-pattern-support)
- [Public API Reference](#public-api-reference)
  - [Simple API](#simple-api)
  - [Advanced API](#advanced-api)
  - [Utility Functions](#utility-functions)
  - [Helper API](#helper-api)
- [Performance Guidelines](#performance-guidelines)
- [Limits and Constraints](#limits-and-constraints)
- [Known Limitations](#known-limitations)

---

## Overview

The NAVFoundation Regex module provides a comprehensive regular expression implementation for NetLinx. It uses Thompson's NFA (Nondeterministic Finite Automaton) construction algorithm for efficient pattern matching and supports most common regex features including capture groups, backreferences, lookarounds, and inline flags.

**Key Features:**
- Full pattern compilation and matching
- Named and numbered capture groups (up to 50 per pattern)
- Global matching (`/g` flag)
- Backreferences and lookaround assertions
- Efficient pre-compilation for repeated use
- Replace and split operations with capture group substitution
- Case-insensitive, multiline, and dotall modes
- Over 2,920 automated tests with 100% passing

**Quick Start:**

```netlinx
// Simple boolean test - validate IP address
if (NAVRegexTest('/^(\d{1,3}\.){3}\d{1,3}$/', ipAddress)) {
    // Valid IP address format
}

// Extract data with capture groups - parse device response
stack_var _NAVRegexMatchCollection matches
if (NAVRegexMatch('/POWER(\d+)/', 'POWER1', matches)) {
    powerState = matches.matches[1].groups[1].text  // '1'
}

// Find all volume levels in a status response
if (NAVRegexMatch('/VOL(\d+)/g', 'VOL25 VOL30 VOL45', matches)) {
    // matches.count = 3
}

// Efficient repeated matching - parse incoming device commands
stack_var _NAVRegexNFA pattern
NAVRegexCompile('/^!(\w+)#(.+)\r$/', pattern)
for (i = 1; i <= count; i++) {
    NAVRegexMatchCompiled(pattern, commands[i], matches)  // Fast!
}
```

---

## Architecture

The regex library is built on four main components working together:

### Lexer

The **Lexer** tokenizes regex patterns into a stream of typed tokens. It handles pattern extraction, escape sequences, character classes, groups, inline flags, and syntax validation.

**Capabilities:**
- Pattern extraction from JavaScript-style delimiters (`/pattern/flags`)
- All standard regex metacharacters and escape sequences
- Hex (`\xHH`) and octal (`\0` to `\377`) escapes
- Character classes with ranges and negation (`[a-z]`, `[^abc]`)
- Named groups in all three syntaxes: `(?P<name>...)`, `(?<name>...)`, `(?'name'...)`
- Lookaround assertions (lookahead/lookbehind, positive/negative)
- Inline flags (`(?i)`, `(?m)`, `(?s)`, `(?x)`) and toggles (`(?i-m)`)
- Comments (`(?#text)`)
- Context-free numeric escape tokenization
- Complete metadata tracking for groups and flags

**Limits:**
- Max 50 groups per pattern
- Max 50 character group name length

### Parser

The **Parser** converts token streams into a Thompson NFA state machine using Thompson's Construction algorithm.

**Capabilities:**
- Fragment management (build and patch operations)
- 26 NFA state types (LITERAL, DOT, CHAR_CLASS, DIGIT, WORD, WHITESPACE, SPLIT, MATCH, CAPTURE_START/END, BACKREF, LOOKAHEAD, LOOKBEHIND, anchors, etc.)
- Epsilon transitions for branching and optional paths
- Capture group state pairs with position tracking
- Lookaround sub-NFA construction
- Bounded quantifiers including on groups (e.g., `(abc){2,4}`)
- Deep cloning with BFS traversal for quantified groups
- Alternation with SPLIT states
- Backreference validation (forward references detected)
- Flag stack management for scoped inline flags

**Limits:**
- Max 1024 NFA states
- Max 8 transitions per state
- Max 32 recursion depth
- Sequential group numbering (1, 2, 3...)

### Matcher

The **Matcher** executes the compiled NFA against input strings using Thompson NFA simulation.

**Capabilities:**
- Thompson NFA simulation using state set management
- Epsilon closure expansion via BFS
- Capture group tracking (start/end positions)
- Backtracking for backreferences and lookarounds
- Global matching with position advancement
- Case-insensitive matching (`/i` flag)
- Multiline mode (`/m` flag - affects `^` and `$`)
- Dotall mode (`/s` flag - `.` matches newlines)
- Word boundaries (transition detection)
- String anchors (absolute start/end positions)
- Zero-width assertions

**Match Results:**
- Full match text, start, end, length
- All capture groups (numbered and named)
- Match collection for global matching
- Success/failure status with error messages

**Limits:**
- Up to 256 simultaneous active states
- Handles inputs up to 65,535 characters
- Up to 50 capture groups per pattern

### Template

The **Template** module parses replacement strings for regex replace operations.

**Supported Syntax:**
- Numbered capture groups: `$1`, `$2`, ..., `$99`
- Full match reference: `$&` or `$0`
- Named capture groups: `${name}` or `$<name>`
- Escaped dollar signs: `$$` (literal `$`)
- Literal text (anything not part of a substitution)

**Example:**
```netlinx
// Template: "User ${username} (ID: $1) - Email: $2"
// Input captured: "12345", "user@example.com", Named "username" = "john_doe"
// Output: "User john_doe (ID: 12345) - Email: user@example.com"
```

---

## Feature Support Matrix

**Legend:**
- ✅ = Fully supported, implemented, and tested
- ⚠️ = Implemented with limitations
- 🚧 = Planned for future
- ❌ = Not supported (intentional)

### Patterns

| Feature | Syntax | Status |
|---------|--------|--------|
| Literal character | `a`, `b`, `1` | ✅ |
| Any character | `.` | ✅ |
| Escaped special char | `\.`, `\*`, `\+` | ✅ |
| Concatenation | `abc` | ✅ |
| Alternation | `a\|b\|c` | ✅ |
| Inline comments | `(?#text)` | ✅ |

### Anchors

| Feature | Syntax | Status |
|---------|--------|--------|
| Line start | `^` | ✅ |
| Line end | `$` | ✅ |
| String start | `\A` | ✅ |
| String end before newline | `\Z` | ✅ |
| String end absolute | `\z` | ✅ |
| Word boundary | `\b` | ✅ |
| Non-word boundary | `\B` | ✅ |

### Quantifiers

| Feature | Syntax | Status |
|---------|--------|--------|
| Zero or more | `*` | ✅ |
| One or more | `+` | ✅ |
| Zero or one | `?` | ✅ |
| Exactly n | `{3}` | ✅ |
| At least n | `{3,}` | ✅ |
| Between n and m | `{2,5}` | ✅ |
| Lazy quantifiers | `*?`, `+?`, `??`, `{n,m}?` | ✅ |
| Quantifier on groups | `(abc)*`, `(abc){2,4}` | ✅ |
| Possessive quantifiers | `*+`, `++`, `?+` | ❌ |

### Character Classes

| Feature | Syntax | Status |
|---------|--------|--------|
| Character set | `[abc]` | ✅ |
| Negated set | `[^abc]` | ✅ |
| Range | `[a-z]` | ✅ |
| Multiple ranges | `[a-zA-Z0-9]` | ✅ |
| Literal dash | `[-abc]`, `[abc-]` | ✅ |
| Digit | `\d` / `[0-9]` | ✅ |
| Non-digit | `\D` / `[^0-9]` | ✅ |
| Word character | `\w` / `[a-zA-Z0-9_]` | ✅ |
| Non-word character | `\W` / `[^a-zA-Z0-9_]` | ✅ |
| Whitespace | `\s` / `[ \t\n\r\f\v]` | ✅ |
| Non-whitespace | `\S` / `[^ \t\n\r\f\v]` | ✅ |
| Hex escape | `\xHH` (e.g., `\x41` = `A`) | ✅ |
| Octal escape | `\0` to `\377` | ✅ |
| Special escapes | `\n`, `\r`, `\t`, `\f`, `\v`, `\a`, `\e`, `\0` | ✅ |
| Shorthands in classes | `[\d\w\s]`, `[\D\W\S]` | ✅ |
| Hex/octal in classes | `[\x41-\x5A]`, `[\060-\071]` | ✅ |

### Groups

| Feature | Syntax | Status |
|---------|--------|--------|
| Capturing group | `(abc)` | ✅ |
| Non-capturing group | `(?:abc)` | ✅ |
| Named capture (Python) | `(?P<name>abc)` | ✅ |
| Named capture (PCRE angle) | `(?<name>abc)` | ✅ |
| Named capture (PCRE quote) | `(?'name'abc)` | ✅ |
| Empty group | `()` | ✅ |
| Nested groups | `((a)(b))` | ✅ |
| Positive lookahead | `(?=abc)` | ✅ |
| Negative lookahead | `(?!abc)` | ✅ |
| Positive lookbehind | `(?<=abc)` | ✅ |
| Negative lookbehind | `(?<!abc)` | ✅ |
| Atomic groups | `(?>...)` | ❌ |

### Backreferences

| Feature | Syntax | Status |
|---------|--------|--------|
| Numbered backreference | `\1` to `\99` | ✅ |
| Named backreference (PCRE) | `\k<name>` | ✅ |
| Named backreference (Python) | `(?P=name)` | ✅ |

### Inline Flags

| Feature | Syntax | Status | Notes |
|---------|--------|--------|-------|
| Global flag | `/pattern/g` | ✅ | Find all matches |
| Case-insensitive flag | `/pattern/i` | ✅ | Entire pattern |
| Multiline flag | `/pattern/m` | ✅ | `^`/`$` match line boundaries |
| Dotall flag | `/pattern/s` | ✅ | `.` matches newlines |
| Extended flag | `/pattern/x` | ⚠️ | Parsed but no effect |
| Inline case-insensitive | `(?i)` | ✅ | Global scope |
| Inline multiline | `(?m)` | ✅ | Global scope |
| Inline dotall | `(?s)` | ✅ | Global scope |
| Inline extended | `(?x)` | ⚠️ | Parsed but no effect |
| Combined flags | `(?ims)`, `/pattern/gims` | ✅ | All combinations |
| Scoped flags | `(?i:abc)` | ✅ | Limited to group scope |
| Flag toggles | `(?i-m)`, `(?-i)` | ✅ | Enable/disable flags |

**Note:** Extended mode `(?x)` is accepted by the lexer and parser but has no functional effect. Whitespace is NOT ignored, and comments are only supported via `(?#...)` syntax.

### Not Supported

| Feature | Reason |
|---------|--------|
| Unicode properties (`\p{Letter}`, `\p{Digit}`) | Requires large character tables |
| Unicode categories (`\p{Lu}`, `\p{Ll}`) | High memory overhead |
| Conditional patterns (`(?(1)yes\|no)`) | Extremely rare use case |
| Subroutines (`(?1)`, `(?R)`) | Recursive patterns not planned |
| Branch reset (`(?\|...)`) | Perl 5.10+ only |
| Code execution (`(?{code})`) | Security risk |
| POSIX classes (`[[:alpha:]]`, `[[:digit:]]`) | Under consideration |

---

## Real-World Pattern Support

The library handles common real-world patterns efficiently:

| Pattern Type | Example | Status |
|-------------|---------|--------|
| Email validation | `/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/i` | ✅ |
| Phone numbers | `/(\d{3})-(\d{3})-(\d{4})/` | ✅ |
| IP addresses | `/(\d{1,3}\.){3}\d{1,3}/` | ✅ |
| URLs | `/https?:\/\/[^\s]+/` | ✅ |
| Dates (ISO 8601) | `/\d{4}-\d{2}-\d{2}/` | ✅ |
| Dates (flexible) | `/\d{1,2}\/\d{1,2}\/\d{2,4}/` | ✅ |
| Hex colors | `/#[0-9a-fA-F]{6}/` | ✅ |
| UUID | `/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/` | ✅ |
| MAC address | `/([0-9A-F]{2}:){5}[0-9A-F]{2}/` | ✅ |
| Credit card | `/\d{4}(-\d{4}){3}/` | ✅ |
| Time (24h) | `/([01]\d\|2[0-3]):[0-5]\d/` | ✅ |
| Repeated words | `/\b(\w+)\s+\1\b/` | ✅ |
| Balanced parens | `/\((?:[^()]|\([^()]*\))*\)/` | ✅ |
| HTML tags | `/<([a-z]+)[^>]*>(.*?)<\/\1>/` | ✅ |
| Quoted strings | `/"(?:[^"\\]\|\\.)*"/` | ✅ |
| CSV fields | `/"(?:[^"]\|"")*"\|[^,]+/` | ✅ |

---

## Public API Reference

### Simple API

#### `NAVRegexTest`

Quick boolean test to check if a pattern matches an input string.

**Signature:**
```netlinx
define_function char NAVRegexTest(char pattern[], char input[])
```

**Parameters:**
- `pattern` - The regex pattern to test (e.g., `'\d+'`, `'/pattern/i'`)
- `input` - The input string to test against

**Returns:**
- `TRUE` if pattern matches anywhere in input
- `FALSE` if no match or compilation error

**Behavior:**
- Simple yes/no test - does NOT return capture groups or match details
- Compiles pattern internally on each call (not efficient for repeated use)
- Ignores `/g` flag (only checks if pattern matches, not how many times)
- Returns `TRUE` on first match found

**Example:**
```netlinx
// Test if string contains digits
if (NAVRegexTest('\d+', 'abc123def')) {
    // Returns TRUE - pattern matches
}

// Test with flags
if (NAVRegexTest('/hello/i', 'HELLO WORLD')) {
    // Returns TRUE - case-insensitive match
}

// No match
if (NAVRegexTest('[0-9]+', 'no numbers here')) {
    // Returns FALSE
}
```

**Use Cases:**
- Input validation (does string match expected format?)
- Quick existence checks
- Conditional logic based on pattern presence

**Performance Note:**
For repeated testing with the same pattern, use `NAVRegexCompile()` + `NAVRegexMatchCompiled()` instead.

---

#### `NAVRegexMatch`

Match a pattern against an input string, with dynamic behavior based on the global flag.

**Signature:**
```netlinx
define_function char NAVRegexMatch(char pattern[], 
                                   char input[], 
                                   _NAVRegexMatchCollection collection)
```

**Parameters:**
- `pattern` - The regex pattern (e.g., `'(\d+)'`, `'/(\d+)/g'`, `'/hello/i'`)
- `input` - The input string to match against
- `collection` - Result structure to populate with match details

**Returns:**
- `TRUE` if at least one match found
- `FALSE` if no match or compilation error

**Behavior:**
- **Without `/g` flag:** Returns **first match only**
  - `collection.count = 1` (or 0 if no match)
  - `collection.matches[1]` contains the first match with all capture groups
  
- **With `/g` flag:** Returns **all matches**
  - `collection.count = N` (number of matches found)
  - `collection.matches[1..N]` contains all non-overlapping matches
  - Each match includes full match text and all capture groups

- Compiles pattern internally on each call (not efficient for repeated use)
- Populates match positions, lengths, and captured groups
- Sets `collection.status` to indicate success/failure/error

**Match Collection Structure:**
```netlinx
collection.status       // MATCH_STATUS_SUCCESS, MATCH_STATUS_NO_MATCH, or MATCH_STATUS_ERROR
collection.count        // Number of matches found (0 to MAX_REGEX_MATCHES)
collection.matches[i]   // Individual match results:
    .fullMatch.text         // The complete matched text
    .fullMatch.start        // Start position (1-based)
    .fullMatch.end          // End position (1-based, inclusive)
    .fullMatch.length       // Length of match
    .groupCount             // Number of capture groups
    .groups[1..N]           // Captured groups (1-based indexing)
        .text               // Captured text
        .start              // Start position
        .end                // End position
        .name               // Group name (if named capture)
```

**Examples:**

```netlinx
stack_var _NAVRegexMatchCollection matches

// Example 1: Single match (no /g flag)
if (NAVRegexMatch('(\d+)', 'Price: $123 or $456', matches)) {
    // matches.count == 1
    // matches.matches[1].fullMatch.text == '123'  (first match only)
    // matches.matches[1].groups[1].text == '123'
}

// Example 2: All matches (with /g flag)
if (NAVRegexMatch('/(\d+)/g', 'Price: $123 or $456', matches)) {
    // matches.count == 2
    // matches.matches[1].fullMatch.text == '123'
    // matches.matches[1].groups[1].text == '123'
    // matches.matches[2].fullMatch.text == '456'
    // matches.matches[2].groups[1].text == '456'
}

// Example 3: Multiple capture groups
if (NAVRegexMatch('/(\\d+)-(\\d+)/g', 'Dates: 2025-11-03 and 2025-12-25', matches)) {
    // matches.count == 2
    // matches.matches[1].groupCount == 2
    // matches.matches[1].groups[1].text == '2025'
    // matches.matches[1].groups[2].text == '11'
    // matches.matches[2].groups[1].text == '2025'
    // matches.matches[2].groups[2].text == '12'
}

// Example 4: Named capture groups
if (NAVRegexMatch('/(?<year>\\d{4})-(?<month>\\d{2})/', '2025-11-03', matches)) {
    // matches.matches[1].groups[1].name == 'year'
    // matches.matches[1].groups[1].text == '2025'
    // matches.matches[1].groups[2].name == 'month'
    // matches.matches[1].groups[2].text == '11'
}

// Example 5: Case-insensitive with global flag
if (NAVRegexMatch('/hello/gi', 'Hello HELLO hello', matches)) {
    // matches.count == 3 (all three variations matched)
}
```

**Error Handling:**
```netlinx
if (!NAVRegexMatch('/[invalid/', 'test', matches)) {
    if (matches.status == MATCH_STATUS_ERROR) {
        // matches.errorMessage contains compilation error details
    } else {
        // matches.status == MATCH_STATUS_NO_MATCH (pattern didn't match)
    }
}
```

**Use Cases:**
- Extract data from text (phone numbers, emails, IDs)
- Parse structured text with capture groups
- Find all occurrences of a pattern (with `/g`)
- Validate and extract parts of input simultaneously

**Performance Note:**
For repeated matching with the same pattern, use `NAVRegexCompile()` + `NAVRegexMatchCompiled()` instead.

---

#### `NAVRegexMatchAll`

Find all matches of a pattern in an input string, always forcing global matching behavior.

**Signature:**
```netlinx
define_function char NAVRegexMatchAll(char pattern[], 
                                      char input[], 
                                      _NAVRegexMatchCollection collection)
```

**Parameters:**
- `pattern` - The regex pattern (with or without `/g` flag)
- `input` - The input string to match against
- `collection` - Result structure to populate with all matches

**Returns:**
- `TRUE` if at least one match found
- `FALSE` if no match or compilation error

**Behavior:**
- **Always returns all matches** regardless of `/g` flag presence
- Forces global matching behavior
- Returns all non-overlapping matches from left to right
- Each match advances the search position past the previous match
- Zero-width matches advance by one position to prevent infinite loops
- Compiles pattern internally on each call (not efficient for repeated use)
- Identical to `NAVRegexMatch('/pattern/g', ...)` but more explicit

**Comparison with `NAVRegexMatch`:**
```netlinx
// NAVRegexMatch respects /g flag
NAVRegexMatch('\\d+', 'a1b2c3', matches)      // count = 1 (first match only)
NAVRegexMatch('/\\d+/g', 'a1b2c3', matches)   // count = 3 (all matches)

// NAVRegexMatchAll always returns all matches
NAVRegexMatchAll('\\d+', 'a1b2c3', matches)   // count = 3 (all matches)
NAVRegexMatchAll('/\\d+/g', 'a1b2c3', matches) // count = 3 (same result)
```

**Examples:**

```netlinx
stack_var _NAVRegexMatchCollection matches

// Example 1: Find all numbers
if (NAVRegexMatchAll('\\d+', 'a1b22c333', matches)) {
    // matches.count == 3
    // matches.matches[1].fullMatch.text == '1'
    // matches.matches[2].fullMatch.text == '22'
    // matches.matches[3].fullMatch.text == '333'
}

// Example 2: Extract all email addresses
if (NAVRegexMatchAll('[\\w.]+@[\\w.]+', 'Contact: user@test.com or admin@test.com', matches)) {
    // matches.count == 2
    // matches.matches[1].fullMatch.text == 'user@test.com'
    // matches.matches[2].fullMatch.text == 'admin@test.com'
}

// Example 3: Find all words
if (NAVRegexMatchAll('/\\w+/g', 'Hello World Test', matches)) {
    // matches.count == 3
    // matches.matches[1].fullMatch.text == 'Hello'
    // matches.matches[2].fullMatch.text == 'World'
    // matches.matches[3].fullMatch.text == 'Test'
}

// Example 4: Extract all dates with capture groups
if (NAVRegexMatchAll('/(\\d{4})-(\\d{2})-(\\d{2})/', 'Dates: 2025-11-03, 2025-12-25', matches)) {
    // matches.count == 2
    // First date:
    // matches.matches[1].fullMatch.text == '2025-11-03'
    // matches.matches[1].groups[1].text == '2025'  // year
    // matches.matches[1].groups[2].text == '11'    // month
    // matches.matches[1].groups[3].text == '03'    // day
    // Second date:
    // matches.matches[2].fullMatch.text == '2025-12-25'
    // matches.matches[2].groups[1].text == '2025'
    // matches.matches[2].groups[2].text == '12'
    // matches.matches[2].groups[3].text == '25'
}

// Example 5: Case-insensitive global search
if (NAVRegexMatchAll('/hello/i', 'Hello hello HELLO', matches)) {
    // matches.count == 3 (all variations matched)
}
```

**Use Cases:**
- Extract all occurrences of a pattern (phone numbers, URLs, IDs)
- Parse lists or repeated structures
- Text analysis and statistics
- Data extraction from logs or formatted text
- When you always want all matches (explicit intent)

**Performance Note:**
For repeated global matching with the same pattern, use `NAVRegexCompile()` + `NAVRegexMatchAllCompiled()` instead.

---

### Advanced API

The Advanced API provides a two-step process for efficient pattern matching:
1. **Compile** the pattern once with `NAVRegexCompile()`
2. **Match** many times with `NAVRegexMatchCompiled()` or `NAVRegexMatchAllCompiled()`

This is significantly more efficient than the Simple API when using the same pattern repeatedly.

#### `NAVRegexCompile`

Pre-compile a regex pattern into an NFA (Non-deterministic Finite Automaton) structure for efficient reuse.

**Signature:**
```netlinx
define_function char NAVRegexCompile(char pattern[], _NAVRegexNFA nfa)
```

**Parameters:**
- `pattern` - The regex pattern to compile (e.g., `'(\d+)'`, `'/pattern/gi'`)
- `nfa` - NFA structure to populate with compiled pattern

**Returns:**
- `TRUE` if compilation succeeded
- `FALSE` if pattern is invalid or compilation failed

**Behavior:**
- Compiles pattern into an NFA state machine
- Parses and validates pattern syntax
- Extracts and processes global flags (`/pattern/flags`)
- Stores compiled NFA for repeated use
- One-time compilation cost, then fast matching
- NFA can be reused indefinitely with different inputs

**Examples:**

```netlinx
stack_var _NAVRegexNFA nfa
stack_var _NAVRegexMatchCollection matches

// Example 1: Compile once, use many times
if (NAVRegexCompile('/(\d+)/g', nfa)) {
    // Use the compiled NFA repeatedly
    NAVRegexMatchCompiled(nfa, 'test123', matches)
    NAVRegexMatchCompiled(nfa, 'value456', matches)
    NAVRegexMatchCompiled(nfa, 'data789', matches)
    // Much faster than calling NAVRegexMatch() three times
}

// Example 2: Compile validation pattern
stack_var _NAVRegexNFA emailPattern
if (NAVRegexCompile('/^[\\w.]+@[\\w.]+\\.[a-z]{2,}$/i', emailPattern)) {
    // Reuse for validating multiple email addresses
    // ...
}

// Example 3: Error handling
if (!NAVRegexCompile('/[invalid/', nfa)) {
    // Compilation failed - invalid pattern
    NAVErrorLog(NAV_LOG_LEVEL_ERROR, 'Failed to compile regex pattern')
}
```

**Performance Comparison:**

```netlinx
// Simple API - Recompiles pattern each time (SLOW)
for (i = 1; i <= 1000; i++) {
    NAVRegexMatch('/(\d+)/g', input[i], matches)  // Compiles 1000 times!
}

// Advanced API - Compile once (FAST)
NAVRegexCompile('/(\d+)/g', nfa)  // Compile once
for (i = 1; i <= 1000; i++) {
    NAVRegexMatchCompiled(nfa, input[i], matches)  // Just match, no compilation
}
```

**Use Cases:**
- Pattern used repeatedly in a loop
- Validation patterns checked frequently
- Real-time data parsing with same pattern
- Performance-critical matching operations
- Long-running systems with persistent patterns

**Notes:**
- NFA structure persists until overwritten
- Can store multiple compiled patterns in different NFA variables
- Compilation failure does not modify the NFA structure
- Global flags are extracted and stored in the NFA

---

#### `NAVRegexMatchCompiled`

Match a string using a pre-compiled NFA, with dynamic behavior based on the compiled `/g` flag.

**Signature:**
```netlinx
define_function char NAVRegexMatchCompiled(_NAVRegexNFA nfa, 
                                           char input[], 
                                           _NAVRegexMatchCollection collection)
```

**Parameters:**
- `nfa` - Pre-compiled NFA from `NAVRegexCompile()`
- `input` - The input string to match against
- `collection` - Result structure to populate with match details

**Returns:**
- `TRUE` if at least one match found
- `FALSE` if no match

**Behavior:**
- **Dynamic behavior based on compiled `/g` flag:**
  - NFA compiled **without** `/g` → returns **first match only** (count = 1)
  - NFA compiled **with** `/g` → returns **all matches** (count = N)
  
- Uses pre-compiled NFA (no recompilation overhead)
- Identical semantics to `NAVRegexMatch()` but more efficient
- Global flag behavior determined at compile time, not match time
- More efficient than Simple API for repeated matching

**Examples:**

```netlinx
stack_var _NAVRegexNFA nfa
stack_var _NAVRegexMatchCollection matches

// Example 1: Compile without /g - single match per call
NAVRegexCompile('(\\d+)', nfa)

if (NAVRegexMatchCompiled(nfa, 'a1b2c3', matches)) {
    // matches.count == 1 (first match only)
    // matches.matches[1].fullMatch.text == '1'
}

if (NAVRegexMatchCompiled(nfa, 'x99y88z77', matches)) {
    // matches.count == 1 (first match only)
    // matches.matches[1].fullMatch.text == '99'
}

// Example 2: Compile with /g - all matches per call
NAVRegexCompile('/(\\d+)/g', nfa)

if (NAVRegexMatchCompiled(nfa, 'a1b2c3', matches)) {
    // matches.count == 3 (all matches)
    // matches.matches[1].fullMatch.text == '1'
    // matches.matches[2].fullMatch.text == '2'
    // matches.matches[3].fullMatch.text == '3'
}

if (NAVRegexMatchCompiled(nfa, 'x99y88z77', matches)) {
    // matches.count == 3 (all matches)
    // matches.matches[1].fullMatch.text == '99'
    // matches.matches[2].fullMatch.text == '88'
    // matches.matches[3].fullMatch.text == '77'
}

// Example 3: Efficient validation loop
stack_var _NAVRegexNFA emailPattern
stack_var char emails[100][100]
stack_var integer i

// Compile once
NAVRegexCompile('/^[\\w.]+@[\\w.]+\\.[a-z]{2,}$/i', emailPattern)

// Validate many
for (i = 1; i <= length_array(emails); i++) {
    if (NAVRegexMatchCompiled(emailPattern, emails[i], matches)) {
        // Valid email
    }
}

// Example 4: Real-time data parsing
stack_var _NAVRegexNFA tempPattern

NAVRegexCompile('/(\\d+\\.\\d+)/', tempPattern)

// Called repeatedly on incoming data
data_event[dvDevice] {
    string: {
        NAVRegexMatchCompiled(tempPattern, data.text, matches)
        if (matches.count > 0) {
            temperature = atof(matches.matches[1].groups[1].text)
        }
    }
}
```

**Performance Comparison:**

```netlinx
stack_var _NAVRegexNFA nfa
stack_var _NAVRegexMatchCollection matches
stack_var char inputs[1000][100]
stack_var integer i

// SLOW: Simple API - Recompiles 1000 times
for (i = 1; i <= 1000; i++) {
    NAVRegexMatch('/(\\d+)/g', inputs[i], matches)
}

// FAST: Advanced API - Compiles once, matches 1000 times
NAVRegexCompile('/(\\d+)/g', nfa)
for (i = 1; i <= 1000; i++) {
    NAVRegexMatchCompiled(nfa, inputs[i], matches)
}
```

**Use Cases:**
- Same pattern used repeatedly with different inputs
- Real-time data processing (data events, string handlers)
- Validation loops
- Performance-critical matching
- Long-running systems with persistent patterns

**Notes:**
- NFA contains the compiled `/g` flag state
- Changing between single/global requires recompiling with different pattern
- No runtime overhead for pattern parsing
- Suitable for event handlers and real-time processing

---

#### `NAVRegexMatchAllCompiled`

Find all matches using a pre-compiled NFA, always forcing global matching behavior.

**Signature:**
```netlinx
define_function char NAVRegexMatchAllCompiled(_NAVRegexNFA nfa, 
                                              char input[], 
                                              _NAVRegexMatchCollection collection)
```

**Parameters:**
- `nfa` - Pre-compiled NFA from `NAVRegexCompile()`
- `input` - The input string to match against
- `collection` - Result structure to populate with all matches

**Returns:**
- `TRUE` if at least one match found
- `FALSE` if no match

**Behavior:**
- **Always returns all matches** regardless of `/g` flag in compiled NFA
- Forces global matching behavior
- Returns all non-overlapping matches from left to right
- Uses pre-compiled NFA (no recompilation overhead)
- Identical semantics to `NAVRegexMatchAll()` but more efficient
- More efficient than Simple API for repeated global matching

**Comparison:**
```netlinx
stack_var _NAVRegexNFA nfa
stack_var _NAVRegexMatchCollection matches

// Compile without /g flag
NAVRegexCompile('\\d+', nfa)

// NAVRegexMatchCompiled respects NFA's /g flag (no /g = single match)
NAVRegexMatchCompiled(nfa, 'a1b2c3', matches)     // count = 1

// NAVRegexMatchAllCompiled ignores NFA's /g flag (always all matches)
NAVRegexMatchAllCompiled(nfa, 'a1b2c3', matches)  // count = 3
```

**Examples:**

```netlinx
stack_var _NAVRegexNFA nfa
stack_var _NAVRegexMatchCollection matches

// Example 1: Force global matching (NFA compiled without /g)
NAVRegexCompile('(\\d+)', nfa)  // No /g flag

if (NAVRegexMatchAllCompiled(nfa, 'a1b2c3', matches)) {
    // matches.count == 3 (all matches, /g flag ignored)
    // matches.matches[1].fullMatch.text == '1'
    // matches.matches[2].fullMatch.text == '2'
    // matches.matches[3].fullMatch.text == '3'
}

// Example 2: Extract all emails from multiple inputs
stack_var _NAVRegexNFA emailPattern
stack_var char logs[100][500]
stack_var integer i

NAVRegexCompile('[\\w.]+@[\\w.]+\\.[a-z]{2,}', emailPattern)

for (i = 1; i <= length_array(logs); i++) {
    if (NAVRegexMatchAllCompiled(emailPattern, logs[i], matches)) {
        // Process all email addresses found in this log entry
        // matches.count = number of emails in logs[i]
    }
}

// Example 3: Parse all key-value pairs
NAVRegexCompile('/(\\w+)=(\\w+)/', nfa)

if (NAVRegexMatchAllCompiled(nfa, 'name=John&age=30&city=NYC', matches)) {
    // matches.count == 3
    // matches.matches[1].groups[1].text == 'name'
    // matches.matches[1].groups[2].text == 'John'
    // matches.matches[2].groups[1].text == 'age'
    // matches.matches[2].groups[2].text == '30'
    // matches.matches[3].groups[1].text == 'city'
    // matches.matches[3].groups[2].text == 'NYC'
}

// Example 4: Efficient log parsing in data event
stack_var _NAVRegexNFA logPattern

NAVRegexCompile('/\\[(\\d{2}:\\d{2}:\\d{2})\\]\\s+(\\w+):\\s+(.+)/', logPattern)

data_event[dvLogger] {
    string: {
        // Extract all log entries from incoming data
        if (NAVRegexMatchAllCompiled(logPattern, data.text, matches)) {
            // Process each log entry
            for (i = 1; i <= matches.count; i++) {
                timestamp = matches.matches[i].groups[1].text
                level = matches.matches[i].groups[2].text
                message = matches.matches[i].groups[3].text
                // ... process log entry
            }
        }
    }
}
```

**Performance Comparison:**

```netlinx
stack_var _NAVRegexNFA nfa
stack_var _NAVRegexMatchCollection matches
stack_var char inputs[1000][100]
stack_var integer i

// SLOW: Simple API - Recompiles 1000 times
for (i = 1; i <= 1000; i++) {
    NAVRegexMatchAll('\\d+', inputs[i], matches)
}

// FAST: Advanced API - Compiles once, matches 1000 times
NAVRegexCompile('\\d+', nfa)
for (i = 1; i <= 1000; i++) {
    NAVRegexMatchAllCompiled(nfa, inputs[i], matches)
}
```

**Use Cases:**
- Extract all occurrences from multiple inputs (logs, files, streams)
- Batch processing with same pattern
- Real-time data parsing requiring all matches
- Performance-critical global matching
- When you always want all matches (explicit intent with efficiency)

**Notes:**
- Ignores `/g` flag state in compiled NFA (always global)
- For conditional global behavior, use `NAVRegexMatchCompiled()` instead
- No runtime overhead for pattern parsing
- Suitable for data events, loops, and batch processing

---

## API Quick Reference

### Function Selection Guide

**Choose the right function for your use case:**

| **Use Case** | **Function** | **Efficiency** | **Global Behavior** |
|--------------|--------------|----------------|---------------------|
| Quick yes/no test | `NAVRegexTest()` | Low (recompiles) | N/A (boolean only) |
| One-off match | `NAVRegexMatch()` | Low (recompiles) | Respects `/g` flag |
| One-off match (always all) | `NAVRegexMatchAll()` | Low (recompiles) | Always global |
| Pre-compile pattern | `NAVRegexCompile()` | N/A (setup) | N/A (compile only) |
| Repeated matching | `NAVRegexMatchCompiled()` | **High** | Respects `/g` flag |
| Repeated matching (always all) | `NAVRegexMatchAllCompiled()` | **High** | Always global |

### Global Flag Behavior Summary

| **Function** | **Pattern: `'\d+'`** | **Pattern: `'/\d+/g'`** |
|--------------|---------------------|------------------------|
| `NAVRegexMatch()` | Single match | All matches |
| `NAVRegexMatchAll()` | All matches | All matches |
| `NAVRegexMatchCompiled()` | Single match | All matches |
| `NAVRegexMatchAllCompiled()` | All matches | All matches |

### Common Patterns

**Quick validation - IP address:**
```netlinx
if (NAVRegexTest('/^(\d{1,3}\.){3}\d{1,3}$/', deviceIP)) {
    // Valid IP address format
}
```

**Extract first match - parse device response:**
```netlinx
stack_var _NAVRegexMatchCollection matches
if (NAVRegexMatch('VOL(\\d+)', 'Current volume: VOL75', matches)) {
    volume = atoi(matches.matches[1].groups[1].text)  // 75
}
```

**Extract all matches - multiple inputs:**
```netlinx
if (NAVRegexMatch('/INPUT(\\d+)/g', 'INPUT1 INPUT2 INPUT3', matches)) {
    // matches.count == 3
}
```

**Efficient repeated validation - MAC addresses:**
```netlinx
stack_var _NAVRegexNFA pattern
NAVRegexCompile('/^([0-9A-F]{2}:){5}[0-9A-F]{2}$/i', pattern)

for (i = 1; i <= length_array(macAddresses); i++) {
    if (NAVRegexMatchCompiled(pattern, macAddresses[i], matches)) {
        // Valid MAC address
    }
}
```

**Real-time parsing - device string events:**
```netlinx
stack_var _NAVRegexNFA commandPattern
NAVRegexCompile('/^!(\w+)#(.+)\r$/', commandPattern)

data_event[dvDevice] {
    string: {
        if (NAVRegexMatchAllCompiled(commandPattern, data.text, matches)) {
            // Process all commands in incoming data
            command = matches.matches[1].groups[1].text
            value = matches.matches[1].groups[2].text
        }
    }
}
```

---

### Utility Functions

#### `NAVRegexReplace`

Replace pattern matches in a string with replacement text, with dynamic behavior based on the `/g` flag.

**Signature:**
```netlinx
define_function char NAVRegexReplace(char pattern[], 
                                     char input[], 
                                     char replacement[], 
                                     char output[])
```

**Parameters:**
- `pattern` - The regex pattern (with or without `/g` flag)
- `input` - The input string to search in
- `replacement` - Replacement text with optional substitutions
- `output` - Result string (input with replacements made)

**Returns:**
- `TRUE` if pattern compiled successfully (even if no match)
- `FALSE` if pattern compilation failed

**Behavior:**
- **Without `/g` flag:** Replace **first match only**
- **With `/g` flag:** Replace **all matches**
- If no match: `output = input` (unchanged), returns TRUE
- If compilation fails: `output = ''`, returns FALSE

**Replacement Syntax:**
- `$1, $2, $3...` - Numbered capture groups
- `$0` or `$&` - Full match text
- `${name}` or `$<name>` - Named capture groups
- `$$` - Literal dollar sign (escape)

**Examples:**

```netlinx
stack_var char result[1000]

// Replace first match only (no /g)
NAVRegexReplace('/\\d+/', 'a1b2c3', 'X', result)
// result = 'aXb2c3'

// Replace all matches (with /g)
NAVRegexReplace('/\\d+/g', 'a1b2c3', 'X', result)
// result = 'aXbXcX'

// Using numbered capture groups
NAVRegexReplace('/(\\d+)-(\\d+)/', '2025-11-03', '$2/$1', result)
// result = '11/2025-03' (first match only)

NAVRegexReplace('/(\\d+)-(\\d+)/g', '2025-11-03 and 2025-12-25', '$2/$1', result)
// result = '11/2025 and 12/2025' (all matches)

// Using full match reference
NAVRegexReplace('/\\d+/', 'Price: 123', '[$&]', result)
// result = 'Price: [123]'

NAVRegexReplace('/\\d+/', 'Price: 123', '[$0]', result)
// result = 'Price: [123]' (same as $&)

// Using named capture groups
NAVRegexReplace('/(?<year>\\d{4})-(?<month>\\d{2})/', '2025-11', '${month}/${year}', result)
// result = '11/2025'

NAVRegexReplace('/(?<year>\\d{4})-(?<month>\\d{2})/', '2025-11', '$<month>/$<year>', result)
// result = '11/2025' (alternative syntax)

// Literal dollar sign
NAVRegexReplace('/price/', 'The price is 100', '$$50', result)
// result = 'The $50 is 100'

// No match - returns original
if (NAVRegexReplace('/\\d+/', 'no numbers', 'X', result)) {
    // Returns TRUE
    // result = 'no numbers' (unchanged)
}

// Sanitize user input
NAVRegexReplace('/[^a-zA-Z0-9]/g', userInput, '_', sanitized)
// Replaces all non-alphanumeric with underscore
```

**Use Cases:**
- Text sanitization and cleaning
- Format conversion (dates, phone numbers)
- Template substitution
- Log message redaction
- Data masking

---

#### `NAVRegexReplaceAll`

Replace all pattern matches, always forcing global replacement behavior.

**Signature:**
```netlinx
define_function char NAVRegexReplaceAll(char pattern[], 
                                        char input[], 
                                        char replacement[], 
                                        char output[])
```

**Parameters:**
- `pattern` - The regex pattern (with or without `/g` flag)
- `input` - The input string to search in
- `replacement` - Replacement text with optional substitutions
- `output` - Result string (input with all replacements made)

**Returns:**
- `TRUE` if pattern compiled successfully (even if no match)
- `FALSE` if pattern compilation failed

**Behavior:**
- **Always replaces all matches** regardless of `/g` flag
- Forces global replacement behavior
- Same replacement syntax as `NAVRegexReplace`
- More explicit intent than using `/g` flag

**Examples:**

```netlinx
stack_var char result[1000]

// Even without /g, replaces all
NAVRegexReplaceAll('/\\d+/', 'a1b2c3', 'X', result)
// result = 'aXbXcX'

// Same result with /g flag
NAVRegexReplaceAll('/\\d+/g', 'a1b2c3', 'X', result)
// result = 'aXbXcX' (identical behavior)

// Remove all special characters
NAVRegexReplaceAll('/[^\\w\\s]/', 'Hello, World! How are you?', '', result)
// result = 'Hello World How are you'

// Normalize whitespace
NAVRegexReplaceAll('/\\s+/', 'hello    world\t\ttab', ' ', result)
// result = 'hello world tab'
```

**Use Cases:**
- When you always want global replacement (explicit intent)
- Cleaning/normalizing text
- Batch text transformations
- When `/g` flag might be forgotten

---

#### `NAVRegexSplit`

Split a string using pattern matches as delimiters.

**Signature:**
```netlinx
define_function char NAVRegexSplit(char pattern[], 
                                   char input[], 
                                   char parts[][], 
                                   integer count)
```

**Parameters:**
- `pattern` - The regex pattern for delimiters
- `input` - The input string to split
- `parts[][]` - Array to populate with split parts
- `count` - Output parameter: number of parts found

**Returns:**
- `TRUE` if pattern compiled successfully
- `FALSE` if pattern compilation failed

**Behavior:**
- Pattern matches are **removed** (used as delimiters only)
- Always splits on all matches (ignores `/g` flag)
- Empty strings are **preserved**
- If no match: returns entire input as single part (count = 1)
- If array too small: fills what it can, `count` shows actual number

**Edge Cases:**
- Leading delimiter → first part is empty string
- Trailing delimiter → last part is empty string
- Consecutive delimiters → empty strings between them
- No match → `parts[1] = input`, `count = 1`

**Examples:**

```netlinx
stack_var char parts[10][100]
stack_var integer count

// Split by comma
if (NAVRegexSplit(',', 'a,b,c', parts, count)) {
    // count = 3
    // parts[1] = 'a'
    // parts[2] = 'b'
    // parts[3] = 'c'
}

// Split by whitespace (any amount)
if (NAVRegexSplit('/\\s+/', 'hello  world\t\ttab', parts, count)) {
    // count = 3
    // parts[1] = 'hello'
    // parts[2] = 'world'
    // parts[3] = 'tab'
}

// Empty strings preserved
if (NAVRegexSplit(',', 'a,,b', parts, count)) {
    // count = 3
    // parts[1] = 'a'
    // parts[2] = '' (empty)
    // parts[3] = 'b'
}

// Leading/trailing delimiters
if (NAVRegexSplit(',', ',a,b,', parts, count)) {
    // count = 4
    // parts[1] = '' (empty before first comma)
    // parts[2] = 'a'
    // parts[3] = 'b'
    // parts[4] = '' (empty after last comma)
}

// No match - entire input returned
if (NAVRegexSplit(',', 'no commas here', parts, count)) {
    // count = 1
    // parts[1] = 'no commas here'
}

// Parse CSV line
if (NAVRegexSplit(',', 'John,Doe,30,Engineer', parts, count)) {
    firstName = parts[1]  // 'John'
    lastName = parts[2]   // 'Doe'
    age = atoi(parts[3])  // 30
    job = parts[4]        // 'Engineer'
}

// Split by multiple delimiters
if (NAVRegexSplit('/[,;:|]/', 'a,b;c:d|e', parts, count)) {
    // count = 5
    // parts[1] = 'a', parts[2] = 'b', parts[3] = 'c'
    // parts[4] = 'd', parts[5] = 'e'
}

// Array too small - detect truncation
char smallParts[2][100]
if (NAVRegexSplit(',', 'a,b,c,d,e', smallParts, count)) {
    // count = 5 (actual number of parts)
    // smallParts[1] = 'a'
    // smallParts[2] = 'b'
    // parts c,d,e are lost!
    
    if (count > max_length_array(smallParts)) {
        NAVErrorLog(NAV_LOG_LEVEL_WARNING, 
                   "'Split truncated: needed ', itoa(count), ' but array size is ', 
                    itoa(max_length_array(smallParts))")
    }
}
```

**Use Cases:**
- Parse CSV/TSV data
- Split command strings
- Parse configuration lines
- Token extraction
- Break text into sentences/words

---

### Helper API

#### `NAVRegexGetNamedGroupFromMatch`

Get a named capture group from a single match result.

**Signature:**
```netlinx
define_function char NAVRegexGetNamedGroupFromMatch(_NAVRegexMatchResult match,
                                                     char name[],
                                                     _NAVRegexGroup group)
```

**Parameters:**
- `match` - The individual match to search (e.g., `collection.matches[1]`)
- `name` - Name of the group to find
- `group` - Output: the found group (with full details)

**Returns:**
- `TRUE` if named group found and was captured
- `FALSE` if named group not found or not captured

**Behavior:**
- Searches a single match for the named group
- Returns full `_NAVRegexGroup` structure with text, start, end, length
- Checks `isCaptured` flag - optional groups that didn't participate return FALSE
- This is the primitive function used internally by other helpers

**Examples:**
```netlinx
stack_var _NAVRegexMatchCollection matches
stack_var _NAVRegexGroup yearGroup

// Get named group from specific match
if (NAVRegexMatch('/(?<year>\d{4})-(?<month>\d{2})/', '2025-11', matches)) {
    if (NAVRegexGetNamedGroupFromMatch(matches.matches[1], 'year', yearGroup)) {
        // yearGroup.text = '2025'
        // yearGroup.start = 1
        // yearGroup.end = 4
        // yearGroup.length = 4
        // yearGroup.name = 'year'
        // yearGroup.number = 1
        // yearGroup.isCaptured = TRUE
    }
}

// Process multiple matches with global flag
if (NAVRegexMatch('/(?<num>\d+)/g', 'a1b2c3', matches)) {
    stack_var integer i
    stack_var _NAVRegexGroup numGroup
    
    for (i = 1; i <= matches.count; i++) {
        if (NAVRegexGetNamedGroupFromMatch(matches.matches[i], 'num', numGroup)) {
            send_string 0, "'Match ', itoa(i), ': ', numGroup.text"
            // Match 1: 1
            // Match 2: 2
            // Match 3: 3
        }
    }
}

// Handle optional groups
if (NAVRegexMatch('/\d+(?<unit>px|em)?/', '12', matches)) {
    stack_var _NAVRegexGroup unitGroup
    
    if (NAVRegexGetNamedGroupFromMatch(matches.matches[1], 'unit', unitGroup)) {
        send_string 0, "'Unit: ', unitGroup.text"
    } else {
        send_string 0, "'No unit specified, using default'"
    }
}
```

**Use Cases:**
- Process specific matches from global matches
- Extract named captures with position metadata
- Validate optional group participation
- Used internally by `NAVRegexGetNamedGroupFromMatchCollection`

---

#### `NAVRegexGetNamedGroupFromMatchCollection`

Get a named capture group from any match in the collection.

**Signature:**
```netlinx
define_function char NAVRegexGetNamedGroupFromMatchCollection(_NAVRegexMatchCollection collection,
                                                               char name[],
                                                               _NAVRegexGroup group)
```

**Parameters:**
- `collection` - The match collection to search
- `name` - Name of the group to find
- `group` - Output: the found group (with full details)

**Returns:**
- `TRUE` if named group found in any match
- `FALSE` if named group not found or not captured

**Behavior:**
- Searches entire collection for first occurrence of named group
- Returns full `_NAVRegexGroup` structure with text, start, end, length
- Group names are unique within a pattern - no match index needed
- For numbered groups, access directly via `collection.matches[i].groups[j]`
- Uses `NAVRegexGetNamedGroupFromMatch` internally

**Examples:**
```netlinx
stack_var _NAVRegexMatchCollection matches
stack_var _NAVRegexGroup yearGroup

// Get named group with full metadata (convenience wrapper)
if (NAVRegexMatch('/(?<year>\d{4})-(?<month>\d{2})/', '2025-11', matches)) {
    if (NAVRegexGetNamedGroupFromMatchCollection(matches, 'year', yearGroup)) {
        // yearGroup.text = '2025'
        // yearGroup.start = 1
        // yearGroup.end = 4
        // yearGroup.length = 4
        // yearGroup.name = 'year'
        // yearGroup.number = 1
    }
}

// Works with global matches - returns first occurrence
if (NAVRegexMatch('/(?<num>\d+)/g', 'a1b2c3', matches)) {
    if (NAVRegexGetNamedGroupFromMatchCollection(matches, 'num', yearGroup)) {
        // yearGroup.text = '1' (from first match)
    }
}

// Parse URL components
if (NAVRegexMatch('/(?<protocol>https?):\/\/(?<domain>[^\/]+)(?<path>\/.*)?/', 
                  'https://example.com/api/v1', matches)) {
    stack_var _NAVRegexGroup protocol, domain, path
    
    NAVRegexGetNamedGroupFromMatchCollection(matches, 'protocol', protocol)  // 'https'
    NAVRegexGetNamedGroupFromMatchCollection(matches, 'domain', domain)      // 'example.com'
    NAVRegexGetNamedGroupFromMatchCollection(matches, 'path', path)          // '/api/v1'
    
    send_string 0, "'Protocol: ', protocol.text"
    send_string 0, "'Domain: ', domain.text"
    send_string 0, "'Path: ', path.text"
}
```

**Use Cases:**
- Extract specific named captures without array indexing
- Self-documenting code (group name explains purpose)
- Access optional groups safely
- Parse structured data (URLs, dates, etc.)

---

#### `NAVRegexGetNamedGroupTextFromMatch`

Get just the text of a named capture group from a single match.

**Signature:**
```netlinx
define_function char NAVRegexGetNamedGroupTextFromMatch(_NAVRegexMatchResult match,
                                                         char name[],
                                                         char text[])
```

**Parameters:**
- `match` - The individual match to search (e.g., `collection.matches[1]`)
- `name` - Name of the group to find
- `text` - Output: the captured text (empty if not found)

**Returns:**
- `TRUE` if named group found
- `FALSE` if named group not found or not captured

**Behavior:**
- Convenience wrapper around `NAVRegexGetNamedGroupFromMatch`
- Returns only the text value, not position metadata
- Most common use case - simpler than declaring `_NAVRegexGroup` structure
- Sets `text = ''` if group not found

**Examples:**
```netlinx
stack_var _NAVRegexMatchCollection matches
stack_var char year[10]

// Simple text extraction from specific match
if (NAVRegexMatch('/(?<year>\d{4})-(?<month>\d{2})/', '2025-11', matches)) {
    NAVRegexGetNamedGroupTextFromMatch(matches.matches[1], 'year', year)  // year = '2025'
}

// Process multiple global matches
if (NAVRegexMatch('/(?<word>\w+)/g', 'hello world test', matches)) {
    stack_var integer i
    stack_var char word[50]
    
    for (i = 1; i <= matches.count; i++) {
        if (NAVRegexGetNamedGroupTextFromMatch(matches.matches[i], 'word', word)) {
            send_string 0, "'Word ', itoa(i), ': ', word"
            // Word 1: hello
            // Word 2: world
            // Word 3: test
        }
    }
}

// Handle optional groups per match
if (NAVRegexMatch('/\d+(?<unit>px|em)?/g', '12px 34 56em', matches)) {
    stack_var integer i
    stack_var char unit[10]
    
    for (i = 1; i <= matches.count; i++) {
        if (NAVRegexGetNamedGroupTextFromMatch(matches.matches[i], 'unit', unit)) {
            send_string 0, "'Match ', itoa(i), ' has unit: ', unit"
        } else {
            send_string 0, "'Match ', itoa(i), ' has no unit'"
        }
    }
}
```

**Use Cases:**
- Extract text from specific matches
- Process global matches individually
- Simple text retrieval without metadata
- Used internally by `NAVRegexGetNamedGroupTextFromMatchCollection`

---

#### `NAVRegexGetNamedGroupTextFromMatchCollection`

Get just the text of a named capture group from the first match in a collection.

**Signature:**
```netlinx
define_function char NAVRegexGetNamedGroupTextFromMatchCollection(_NAVRegexMatchCollection collection,
                                                                   char name[],
                                                                   char text[])
```

**Parameters:**
- `collection` - The match collection to search
- `name` - Name of the group to find
- `text` - Output: the captured text (empty if not found)

**Returns:**
- `TRUE` if named group found
- `FALSE` if named group not found or not captured

**Behavior:**
- Convenience wrapper around `NAVRegexGetNamedGroupFromMatchCollection`
- Returns only the text value, not position metadata
- Most common use case - simpler than declaring `_NAVRegexGroup` structure
- Sets `text = ''` if group not found

**Examples:**
```netlinx
stack_var _NAVRegexMatchCollection matches
stack_var char year[10]
stack_var char month[10]

// Simple text extraction
if (NAVRegexMatch('/(?<year>\d{4})-(?<month>\d{2})/', '2025-11', matches)) {
    NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'year', year)    // year = '2025'
    NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'month', month)  // month = '11'
    
    send_string 0, "'Date: ', month, '/', year"
}

// Parse configuration line
if (NAVRegexMatch('/(?<key>\w+)\s*=\s*(?<value>.+)/', 'timeout = 30', matches)) {
    stack_var char key[50], value[100]
    
    NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'key', key)      // 'timeout'
    NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'value', value)  // '30'
    
    // Process configuration
    if (key == 'timeout') {
        timeout = atoi(value)
    }
}

// Extract email parts
if (NAVRegexMatch('/(?<user>\w+)@(?<domain>[\w.]+)/', 'admin@example.com', matches)) {
    stack_var char username[50], domain[100]
    
    NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'user', username)   // 'admin'
    NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'domain', domain)   // 'example.com'
}

// Optional groups - check return value
stack_var char unit[10]
if (NAVRegexMatch('/\d+(?<unit>px|em|rem)?/', '12px', matches)) {
    if (NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'unit', unit)) {
        // unit = 'px'
    } else {
        // unit = '' (use default)
    }
}
```

**Use Cases:**
- Extract specific values without position info
- Parse structured text (config files, logs, etc.)
- Clean, readable code (no struct declarations)
- Quick value extraction

---

#### `NAVRegexHasNamedGroupInMatch`

Check if a single match has a specific named group that was captured.

**Signature:**
```netlinx
define_function char NAVRegexHasNamedGroupInMatch(_NAVRegexMatchResult match,
                                                   char name[])
```

**Parameters:**
- `match` - The individual match to check (e.g., `collection.matches[1]`)
- `name` - Name of the group to check for

**Returns:**
- `TRUE` if named group exists and was captured in this match
- `FALSE` if named group not found or didn't participate

**Behavior:**
- Quick boolean check without retrieving group data
- Checks `isCaptured` flag - optional groups that didn't participate return FALSE
- No output parameter needed
- Wrapper around `NAVRegexGetNamedGroupFromMatch` (discards group data)

**Examples:**
```netlinx
stack_var _NAVRegexMatchCollection matches

// Check specific match for optional group
if (NAVRegexMatch('/\d+(?<unit>px|em)?/g', '12px 34 56em', matches)) {
    stack_var integer i
    
    for (i = 1; i <= matches.count; i++) {
        if (NAVRegexHasNamedGroupInMatch(matches.matches[i], 'unit')) {
            stack_var char unit[10]
            NAVRegexGetNamedGroupTextFromMatch(matches.matches[i], 'unit', unit)
            send_string 0, "'Match ', itoa(i), ' has unit: ', unit"
        } else {
            send_string 0, "'Match ', itoa(i), ' has no unit (using default)'"
        }
    }
}

// Conditional processing per match
if (NAVRegexMatch('/(?<protocol>https?):\/\/(?<domain>[^\/]+)(?<path>\/.*)?/g', 
                  urls, matches)) {
    stack_var integer i
    
    for (i = 1; i <= matches.count; i++) {
        if (NAVRegexHasNamedGroupInMatch(matches.matches[i], 'path')) {
            stack_var char path[200]
            NAVRegexGetNamedGroupTextFromMatch(matches.matches[i], 'path', path)
            send_string 0, "'URL ', itoa(i), ' has path: ', path"
        } else {
            send_string 0, "'URL ', itoa(i), ' is root'"
        }
    }
}
```

**Use Cases:**
- Check optional group presence in specific matches
- Process global matches with conditional logic
- Validate match structure before extraction

---

#### `NAVRegexHasNamedGroupInMatchCollection`

Check if any match in the collection has a specific named group.

**Signature:**
```netlinx
define_function char NAVRegexHasNamedGroupInMatchCollection(_NAVRegexMatchCollection collection,
                                                             char name[])
```

**Parameters:**
- `collection` - The match collection to check
- `name` - Name of the group to check for

**Returns:**
- `TRUE` if named group exists and was captured
- `FALSE` if named group not found or didn't participate

**Behavior:**
- Quick boolean check without retrieving group data
- Useful for conditional logic with optional groups
- No output parameter needed
- Checks `isCaptured` flag (groups that didn't participate return FALSE)
- Wrapper around `NAVRegexGetNamedGroupFromMatchCollection` (discards group data)

**Examples:**
```netlinx
stack_var _NAVRegexMatchCollection matches

// Handle optional groups
if (NAVRegexMatch('/\d+(?<unit>px|em)?/', '12px', matches)) {
    if (NAVRegexHasNamedGroupInMatchCollection(matches, 'unit')) {
        // Process with unit
        stack_var char unit[10]
        NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'unit', unit)
        send_string 0, "'Has unit: ', unit"
    } else {
        // Use default unit
        send_string 0, "'Using default unit: px'"
    }
}

// Conditional parsing based on pattern match
if (NAVRegexMatch('/(?<ipv4>\d+\.\d+\.\d+\.\d+)|(?<ipv6>[0-9a-f:]+)/', 
                  '192.168.1.1', matches)) {
    if (NAVRegexHasNamedGroupInMatchCollection(matches, 'ipv4')) {
        // Handle IPv4
        stack_var char ipv4[20]
        NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'ipv4', ipv4)
        send_string 0, "'IPv4 address: ', ipv4"
    }
    else if (NAVRegexHasNamedGroupInMatchCollection(matches, 'ipv6')) {
        // Handle IPv6
        stack_var char ipv6[50]
        NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'ipv6', ipv6)
        send_string 0, "'IPv6 address: ', ipv6"
    }
}

// Check for optional fields before processing
if (NAVRegexMatch('/(?<name>\w+)(\s+(?<age>\d+))?(\s+(?<city>\w+))?/', 
                  'John 30 NYC', matches)) {
    stack_var char name[50], age[10], city[50]
    
    NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'name', name)  // Always present
    
    if (NAVRegexHasNamedGroupInMatchCollection(matches, 'age')) {
        NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'age', age)
    }
    
    if (NAVRegexHasNamedGroupInMatchCollection(matches, 'city')) {
        NAVRegexGetNamedGroupTextFromMatchCollection(matches, 'city', city)
    }
}
```

**Use Cases:**
- Check optional group presence before extraction
- Conditional logic based on pattern alternatives
- Validate pattern structure
- Handle variable input formats

---

## Performance Guidelines

### When to Use Simple vs Advanced API

**Simple API** (`NAVRegexTest`, `NAVRegexMatch`, `NAVRegexMatchAll`):
- One-off pattern matching
- Different pattern each time
- Convenience over performance
- Quick validation or extraction

**Advanced API** (`NAVRegexCompile` + `NAVRegexMatchCompiled`):
- Same pattern used repeatedly (loops, event handlers)
- Performance-critical operations
- Real-time data processing
- Long-running systems

**Performance Comparison:**

```netlinx
// SLOW: Recompiles pattern 1000 times
for (i = 1; i <= 1000; i++) {
    NAVRegexMatch('/\d+/g', inputs[i], matches)
}

// FAST: Compiles once, matches 1000 times
stack_var _NAVRegexNFA pattern
NAVRegexCompile('/\d+/g', pattern)
for (i = 1; i <= 1000; i++) {
    NAVRegexMatchCompiled(pattern, inputs[i], matches)
}
```

### Pattern Optimization Tips

1. **Be specific**: Use `\d` instead of `[0-9]` when possible
2. **Anchor when possible**: `^pattern$` is faster than `pattern`
3. **Use non-capturing groups**: `(?:abc)` is more efficient than `(abc)` if you don't need the capture
4. **Avoid nested quantifiers**: `(a*)*` can cause exponential behavior
5. **Limit backtracking**: Backreferences and lookarounds add overhead

### Known Performance Considerations

- **Backtracking complexity**: Backreferences and lookarounds may have exponential behavior on adversarial inputs
- **State set size**: Large alternations may create large state sets
- **Capture group overhead**: Each group adds position tracking overhead
- **Global matching**: Finding all matches is slower than finding the first match

---

## Limits and Constraints

### Pattern Limits

| Constraint | Value | Notes |
|------------|-------|-------|
| Max groups per pattern | 50 | Numbered and named combined |
| Max group name length | 50 characters | Alphanumeric + underscore only |
| Max NFA states | 1024 | Total states in compiled pattern |
| Max state transitions | 8 per state | Outgoing edges from each state |
| Max recursion depth | 32 levels | Nested groups/quantifiers |

### Matching Limits

| Constraint | Value | Notes |
|------------|-------|-------|
| Max input length | 65,535 characters | NetLinx string limit |
| Max active states | 256 simultaneous | During NFA simulation |
| Max lookaround depth | 16 levels | Nested assertions |
| Max backreferences | 99 | `\1` to `\99` |

### Collection Limits

| Constraint | Value | Notes |
|------------|-------|-------|
| Max matches | 100 | Global matching limit |
| Max capture groups | 50 per pattern | Same as pattern limit |

### Template Limits

| Constraint | Value | Notes |
|------------|-------|-------|
| Max template parts | 100 | Replacement string components |
| Max literal segment length | 200 characters | Single literal part |
| Max named reference length | 50 characters | Group name in template |

---

## Known Limitations

### By Design

- **No Unicode properties**: `\p{Letter}`, `\p{Digit}` not supported (requires large character tables)
- **No Unicode categories**: `\p{Lu}`, `\p{Ll}` not supported (high memory overhead)
- **No atomic groups**: `(?>...)` not supported (optimization-only feature)
- **No possessive quantifiers**: `*+`, `++`, `?+` not supported (PCRE-only)
- **No subroutines**: `(?1)`, `(?R)` not supported (recursive patterns not planned)
- **No conditional patterns**: `(?(condition)yes|no)` not supported (extremely rare use case)
- **No POSIX classes**: `[[:alpha:]]`, `[[:digit:]]` not supported (under consideration)
- **Extended mode**: `(?x)` is parsed but has no effect (whitespace not ignored)

### Error Handling

- **Invalid patterns**: Compilation fails with error message in `collection.errorMessage`
- **Forward backreferences**: `\1(...)` detected and rejected by parser
- **Invalid escape sequences**: Detected by lexer with error message
- **Unclosed groups**: Detected by lexer with error message
- **Quantifier errors**: Nothing to quantify, consecutive quantifiers detected

### Test Coverage

Over **2,920 automated tests** covering:
- All supported features (100% passing)
- Edge cases and error conditions
- Real-world pattern examples
- Performance and stress tests
- All public API functions

**Test Suites:**
- Lexer: Pattern extraction, tokenization, escape sequences, character classes, groups, flags
- Parser: NFA construction, fragment building, quantifiers, backreferences, lookarounds
- Matcher: Pattern matching, capture groups, global matching, backreferences, lookarounds
- Replace: Template parsing, substitution, global replacement
- Split: Delimiter parsing, edge cases
- Integration: End-to-end real-world patterns