# Regex Implementation - Potential Refactorings

## Overview
This document tracks potential refactorings and improvements for the NAVFoundation Regex implementation.

---

## 1. Compiler: Escape Sequence Conversion in Character Classes

**Current State:**
- The compiler stores escape sequences literally in character classes (e.g., `[\t\n\r]` → 6 characters: `\`, `t`, `\`, `n`, `\`, `r`)
- The matcher interprets these escape sequences at runtime by extracting substrings

**Proposed Refactoring:**
- Have the compiler convert escape sequences to their actual character values during compilation
- Character class `[\t\n\r]` would be compiled to 3 actual bytes: `$09`, `$0A`, `$0D`
- Matcher would simply compare characters without needing to interpret escape sequences

**Benefits:**
- Simpler matcher logic - just character comparison
- Smaller compiled character class strings (3 bytes vs 6 bytes for `[\t\n\r]`)
- More consistent with how standalone escape sequences work (e.g., `/\t/`)
- Potentially faster matching - no runtime interpretation needed

**Implementation Notes:**
- Modify `NAVFoundation.Regex.Compiler.axi`, function `NAVRegexCompileCharacterClass()`
- Around lines 211-239, when a backslash is detected:
  ```netlinx
  if (code == '\') {
      // Advance to get the escape character
      code = NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)
      
      // Convert escape sequences to actual characters
      switch (code) {
          case 't': { charclass = "charclass, NAV_TAB" }      // $09
          case 'n': { charclass = "charclass, NAV_LF" }       // $0A
          case 'r': { charclass = "charclass, NAV_CR" }       // $0D
          case 'd': { charclass = "charclass, '\d'" }         // Keep meta chars
          case 'w': { charclass = "charclass, '\w'" }         // Keep meta chars
          case 's': { charclass = "charclass, '\s'" }         // Keep meta chars
          case 'x': { charclass = "charclass, '\x'" }         // Keep meta chars
          default:  { charclass = "charclass, code" }         // Literal escape
      }
  }
  ```
- Simplify matcher's `NAVRegexMatchCharClass()` - remove substring extraction
- Update `NAVRegexMatchCharClassMetaChar()` to handle meta characters only

**Files to Modify:**
- `Regex/NAVFoundation.Regex.Compiler.axi` (lines ~211-239)
- `Regex/NAVFoundation.Regex.Matcher.axi` (lines ~193-212, function `NAVRegexMatchCharClass`)

**Test Coverage:**
- All existing tests should pass (167 tests)
- Specifically verify escaped character tests (tests 1-18 in escaped chars section)

**Priority:** Medium
**Effort:** ~2-3 hours
**Risk:** Low (existing tests provide good coverage)

---

## 2. Hex Escape Sequences (`\x41` style)

**Current State:**
- `\x` matches hex digit characters `[0-9A-Fa-f]`
- No support for `\x41` style hex escape sequences (e.g., `\x41` for 'A')

**Proposed Enhancement:**
- Add support for hex escape sequences in the format `\xHH` (two hex digits)
- Example: `/\x41/` would match the character 'A' (ASCII 65)
- Example: `/\x0A/` would match newline character

**Benefits:**
- More flexibility in pattern specification
- Standard regex feature found in many implementations
- Useful for matching specific byte values

**Implementation Notes:**
- Compiler needs to detect `\x` followed by two hex digits
- Parse the two hex digits and convert to actual character value
- Handle both standalone patterns `/\x41/` and character class patterns `/[\x41\x42]/`

**Challenges:**
- Conflicts with current `\x` meaning (hex digit matcher)
- Would need to lookahead to determine if `\xHH` or `\x` (single char class)
- Consider: Use `\xh` or `\h` for hex digit matcher instead?

**Files to Modify:**
- `Regex/NAVFoundation.Regex.Compiler.axi` (escape sequence parsing)
- Potentially `Regex/NAVFoundation.Regex.h.axi` (add new token type?)

**Priority:** Low
**Effort:** ~4-6 hours
**Risk:** Medium (breaking change to `\x` behavior)

**Decision Required:**
- Keep current `\x` for hex digit matching OR implement `\xHH` hex escapes
- If implementing `\xHH`, need alternative syntax for hex digit matching

---

## 3. Performance: Character Class Matching Optimization

**Current State:**
- Character class matching iterates through the entire character class string for each input character
- Escape sequences require substring extraction and interpretation at runtime

**Proposed Optimization:**
- Pre-process character classes into a lookup table or bitset during compilation
- For simple character classes (no ranges, no escapes), use direct lookup
- For complex character classes, optimize the matching logic

**Benefits:**
- Faster matching for frequently used character classes
- Reduced runtime overhead for escape sequence interpretation

**Implementation Ideas:**
- Add a `char classbitmap[256]` field to the state structure
- During compilation, populate bitmap for included characters
- During matching, check `classbitmap[c]` instead of iterating

**Challenges:**
- Increased memory usage (256 bytes per character class)
- May not be worth it for small character classes
- Need to handle ranges efficiently

**Files to Modify:**
- `Regex/NAVFoundation.Regex.h.axi` (add bitmap field to state structure)
- `Regex/NAVFoundation.Regex.Compiler.axi` (populate bitmap)
- `Regex/NAVFoundation.Regex.Matcher.axi` (use bitmap for matching)

**Priority:** Low
**Effort:** ~6-8 hours
**Risk:** Medium (memory usage concerns)

---

## 4. Code Organization: Extract Escape Sequence Handling

**Current State:**
- Escape sequence interpretation logic is scattered across compiler and matcher
- Duplication between standalone escape sequences and character class escape sequences

**Proposed Refactoring:**
- Create a common function for escape sequence interpretation
- Example: `define_function char NAVRegexInterpretEscapeSequence(char escapeChar)`
- Returns the actual character value or a special marker for meta characters

**Benefits:**
- DRY (Don't Repeat Yourself) principle
- Easier to add new escape sequences
- Consistent behavior across all contexts

**Implementation:**
```netlinx
define_function char NAVRegexInterpretEscapeSequence(char escapeChar) {
    switch (escapeChar) {
        case 't': { return NAV_TAB }
        case 'n': { return NAV_LF }
        case 'r': { return NAV_CR }
        case '0': { return $00 }
        // ... more escape sequences
        default:  { return escapeChar }  // Literal character
    }
}

define_function char NAVRegexIsMetaCharacter(char escapeChar) {
    switch (escapeChar) {
        case 'd':
        case 'D':
        case 'w':
        case 'W':
        case 's':
        case 'S':
        case 'x':
        case 'b':
        case 'B': { return true }
        default:  { return false }
    }
}
```

**Files to Modify:**
- `Regex/NAVFoundation.Regex.Helpers.axi` (add new helper functions)
- `Regex/NAVFoundation.Regex.Compiler.axi` (use helpers)
- `Regex/NAVFoundation.Regex.Matcher.axi` (use helpers)

**Priority:** Medium
**Effort:** ~3-4 hours
**Risk:** Low

---

## 5. Debug Flag: Remove from Match Result Structure

**Current State:**
- Debug flag is stored in `_NAVRegexMatchResult` structure
- Tests set `match.debug` to enable/disable debug output

**Proposed Refactoring:**
- Move debug flag to a global module variable or constant
- Alternatively, add a `NAVRegexSetDebug(char enabled)` function
- Remove `debug` field from `_NAVRegexMatchResult` structure

**Benefits:**
- Cleaner API - debug is an implementation detail, not part of match results
- Reduces structure size
- Easier to control debug output globally

**Implementation:**
```netlinx
// In NAVFoundation.Regex.axi
define_variable
volatile char __NAV_REGEX_DEBUG_ENABLED = false

define_function NAVRegexSetDebug(char enabled) {
    __NAV_REGEX_DEBUG_ENABLED = enabled
}

// Update NAVRegexDebug() to check global flag
```

**Files to Modify:**
- `Regex/NAVFoundation.Regex.h.axi` (remove debug from structure)
- `Regex/NAVFoundation.Regex.axi` (add global variable and function)
- `Regex/NAVFoundation.Regex.Helpers.axi` (update NAVRegexDebug)
- All test files (change from `match.debug = true` to `NAVRegexSetDebug(true)`)

**Priority:** Low
**Effort:** ~2 hours
**Risk:** Low (requires test file updates)

---

## Status Key
- **Priority:** High | Medium | Low
- **Effort:** Estimated time to implement
- **Risk:** 
  - Low: Safe refactoring with good test coverage
  - Medium: May affect existing behavior or require careful testing
  - High: Significant changes with potential for bugs

---

## Notes
- All refactorings should maintain backward compatibility where possible
- Existing test suite (167 tests) should pass after each refactoring
- Consider performance implications for embedded NetLinx systems
- Document any breaking changes clearly

---

**Last Updated:** October 5, 2025
**Version:** 1.0
