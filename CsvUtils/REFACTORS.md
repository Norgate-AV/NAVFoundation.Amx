# CSV Lexer - Potential Refactors

This document outlines potential improvements and refactoring opportunities for the CSV lexer implementation. These are not critical issues but would enhance maintainability, consistency, and code quality.

## Medium Priority

### 1. Extract Token Limit Check to Helper Function (DRY Principle)

**Issue**: The token limit check `lexer.tokenCount >= NAV_CSV_LEXER_MAX_TOKENS` is repeated in multiple functions (`NAVCsvLexerTokenize`, `NAVCsvLexerConsumeIdentifier`, `NAVCsvLexerConsumeString`, `NAVCsvLexerConsumeWhitespace`).

**Recommendation**: Extract to a helper function:

```netlinx
/**
 * @function NAVCsvLexerCanAddToken
 * @private
 * @description Check if the lexer can accept another token.
 *
 * @param {_NAVCsvLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if token can be added, False (0) otherwise
 */
define_function char NAVCsvLexerCanAddToken(_NAVCsvLexer lexer) {
    if (lexer.tokenCount >= NAV_CSV_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSV_LEXER__,
                                    'NAVCsvLexerCanAddToken',
                                    "'Exceeded maximum token limit'")
        return false
    }
    
    return true
}
```

**Benefits**:
- Single source of truth for token limit logic
- Easier to modify error handling in one place
- More maintainable code

### 2. Improve Error Handling in Consume Functions

**Issue**: The `Consume*` functions (`NAVCsvLexerConsumeIdentifier`, `NAVCsvLexerConsumeString`, `NAVCsvLexerConsumeWhitespace`) return early on cursor advance failures but don't set an error token or propagate the error state clearly.

**Recommendation**: Consider one of these approaches:

**Option A**: Return boolean success/failure
```netlinx
define_function char NAVCsvLexerConsumeIdentifier(_NAVCsvLexer lexer) {
    // ... implementation ...
    
    if (!NAVCsvLexerCanAddToken(lexer)) {
        return false
    }
    
    // ... rest of implementation ...
    return true
}
```

**Option B**: Set an error token when unexpected conditions occur
```netlinx
define_function NAVCsvLexerSetErrorToken(_NAVCsvLexer lexer, char message[]) {
    if (lexer.tokenCount >= NAV_CSV_LEXER_MAX_TOKENS) {
        return
    }
    
    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = NAV_CSV_TOKEN_TYPE_ERROR
    lexer.tokens[lexer.tokenCount].value = message
}
```

**Benefits**:
- Better debugging information
- Clearer error propagation
- Easier to identify where tokenization failed

## Low Priority

### 3. Renumber Token Type Constants

**Issue**: Token type constants have a gap (type 4 is missing - sequence goes 1, 2, 3, 5, 6, 7, 8).

**Current**:
```netlinx
constant integer NAV_CSV_TOKEN_TYPE_COMMA       = 1
constant integer NAV_CSV_TOKEN_TYPE_IDENTIFIER  = 2
constant integer NAV_CSV_TOKEN_TYPE_STRING      = 3
constant integer NAV_CSV_TOKEN_TYPE_NEWLINE     = 5  // Gap here
constant integer NAV_CSV_TOKEN_TYPE_EOF         = 6
constant integer NAV_CSV_TOKEN_TYPE_WHITESPACE  = 7
constant integer NAV_CSV_TOKEN_TYPE_ERROR       = 8
```

**Recommendation** (if not intentional):
```netlinx
constant integer NAV_CSV_TOKEN_TYPE_COMMA       = 1
constant integer NAV_CSV_TOKEN_TYPE_IDENTIFIER  = 2
constant integer NAV_CSV_TOKEN_TYPE_STRING      = 3
constant integer NAV_CSV_TOKEN_TYPE_NEWLINE     = 4
constant integer NAV_CSV_TOKEN_TYPE_EOF         = 5
constant integer NAV_CSV_TOKEN_TYPE_WHITESPACE  = 6
constant integer NAV_CSV_TOKEN_TYPE_ERROR       = 7
```

**Benefits**:
- More consistent numbering
- Easier to remember/use
- Less confusing for future maintainers

**Note**: If type 4 is reserved for future use, document this with a comment.

### 4. Style Guide Compliance - Blank Lines

**Issue**: Minor style guide violations regarding blank lines after closing braces.

**Locations**:
- Line ~110: Missing blank line after closing brace before `return true` in `NAVCsvLexerAdvanceCursor`
- Line ~147: Missing blank line after closing brace before `return` in tokenization switch cases

**Recommendation**: Add blank lines per style guide:

```netlinx
// Before
    }

    return true
}

// After
    }
    
    return true
}
```

**Benefits**:
- Consistent with established style guide
- Improved readability

## Optional Improvements

### 5. Refactor String Escape Logic

**Issue**: The `continue` statement in `NAVCsvLexerConsumeString` is functional but could be clearer.

**Current**:
```netlinx
case '"': {
    // Handle escaped quote
    if (NAVCsvLexerHasMoreTokens(lexer)) {
        stack_var char next

        next = lexer.source[lexer.cursor + 1]

        switch (next) {
            case '"': {
                if (!NAVCsvLexerAdvanceCursor(lexer)) {
                    return
                }

                value = "value, ch"
                continue  // Continue outer while loop
            }
        }
    }

    // Closing quote
    break
}
```

**Alternative** (more explicit):
```netlinx
case '"': {
    // Check for escaped quote (double quote)
    if (NAVCsvLexerHasMoreTokens(lexer) &&
        lexer.source[lexer.cursor + 1] == '"') {
        // Escaped quote - add it to value and continue
        if (!NAVCsvLexerAdvanceCursor(lexer)) {
            return
        }
        value = "value, ch"
    }
    else {
        // Closing quote - we're done
        break
    }
}
```

**Benefits**:
- Avoids `continue` statement
- Makes escaped vs. closing quote logic more explicit
- Easier to understand at a glance

### 6. Early Return in Main Tokenization Loop

**Issue**: Per the style guide's "never nesting" principle, could reduce nesting in `NAVCsvLexerTokenize`.

**Current**:
```netlinx
while (NAVCsvLexerHasMoreTokens(lexer)) {
    stack_var char ch

    if (lexer.tokenCount == NAV_CSV_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSV_LEXER__,
                                    'NAVCsvLexerTokenize',
                                    "'Exceeded maximum token limit'")
        return false
    }

    if (!NAVCsvLexerAdvanceCursor(lexer)) {
        return false
    }
    
    // ... rest of logic
}
```

**Alternative** (if using helper function):
```netlinx
while (NAVCsvLexerHasMoreTokens(lexer)) {
    stack_var char ch

    if (!NAVCsvLexerCanAddToken(lexer)) {
        return false
    }

    if (!NAVCsvLexerAdvanceCursor(lexer)) {
        return false
    }
    
    // ... rest of logic
}
```

**Benefits**:
- Consistent with DRY principle
- Slightly cleaner code

### 7. Add Logical Section Separation

**Issue**: Long functions could benefit from blank lines between logical sections per style guide.

**Recommendation**: Add blank lines in longer functions like `NAVCsvLexerTokenize` to separate:
- Validation section
- Main processing section
- Cleanup/finalization section

**Benefits**:
- Improved readability
- Better visual organization
- Consistent with style guide

## Summary

These refactoring suggestions are **optional improvements** focused on:
- **Code maintainability** (DRY principle, helper functions)
- **Consistency** (token type numbering, style guide compliance)
- **Clarity** (error handling, logic flow)

The current implementation is **production-ready and functional**. These refactors can be addressed at your convenience as time permits.

## Status

- [ ] Extract token limit check to helper function
- [ ] Improve error handling in Consume functions
- [ ] Renumber token type constants (or document gap)
- [ ] Add missing blank lines for style guide compliance
- [ ] Refactor string escape logic
- [ ] Apply early return pattern more consistently
- [ ] Add logical section separation in long functions
