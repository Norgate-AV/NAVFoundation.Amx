PROGRAM_NAME='NAVTomlLexerTokenize'

DEFINE_VARIABLE

volatile char TOML_LEXER_TOKENIZE_TEST[63][2048]

define_function InitializeTomlLexerTokenizeTestData() {
    // Test 1: Empty document
    TOML_LEXER_TOKENIZE_TEST[1] = ''

    // Test 2: Simple key-value
    TOML_LEXER_TOKENIZE_TEST[2] = 'name = "John"'

    // Test 3: Integer value
    TOML_LEXER_TOKENIZE_TEST[3] = 'age = 30'

    // Test 4: Boolean true
    TOML_LEXER_TOKENIZE_TEST[4] = 'enabled = true'

    // Test 5: Boolean false
    TOML_LEXER_TOKENIZE_TEST[5] = 'disabled = false'

    // Test 6: Float value
    TOML_LEXER_TOKENIZE_TEST[6] = 'pi = 3.14159'

    // Test 7: Basic string
    TOML_LEXER_TOKENIZE_TEST[7] = 'text = "Hello World"'

    // Test 8: Literal string
    TOML_LEXER_TOKENIZE_TEST[8] = "'path = ''C:\Windows\System32'''"

    // Test 9: Array of integers
    TOML_LEXER_TOKENIZE_TEST[9] = 'numbers = [1, 2, 3, 4, 5]'

    // Test 10: Array of strings
    TOML_LEXER_TOKENIZE_TEST[10] = 'colors = ["red", "green", "blue"]'

    // Test 11: Empty array
    TOML_LEXER_TOKENIZE_TEST[11] = 'empty = []'

    // Test 12: Table header
    TOML_LEXER_TOKENIZE_TEST[12] = '[server]'

    // Test 13: Dotted table header
    TOML_LEXER_TOKENIZE_TEST[13] = '[database.connection]'

    // Test 14: Array of tables header
    TOML_LEXER_TOKENIZE_TEST[14] = '[[products]]'

    // Test 15: Inline table
    TOML_LEXER_TOKENIZE_TEST[15] = 'point = { x = 10, y = 20 }'

    // Test 16: Hexadecimal integer
    TOML_LEXER_TOKENIZE_TEST[16] = 'hex = 0xDEADBEEF'

    // Test 17: Octal integer
    TOML_LEXER_TOKENIZE_TEST[17] = 'oct = 0o755'

    // Test 18: Binary integer
    TOML_LEXER_TOKENIZE_TEST[18] = 'bin = 0b11010110'

    // Test 19: Float with exponent
    TOML_LEXER_TOKENIZE_TEST[19] = 'value = 5e+22'

    // Test 20: Infinity
    TOML_LEXER_TOKENIZE_TEST[20] = 'infinity = inf'

    // Test 21: Not a number
    TOML_LEXER_TOKENIZE_TEST[21] = 'not_a_num = nan'

    // Test 22: Date value
    TOML_LEXER_TOKENIZE_TEST[22] = 'birthday = 1979-05-27'

    // Test 23: Time value
    TOML_LEXER_TOKENIZE_TEST[23] = 'alarm = 07:32:00'

    // Test 24: DateTime value
    TOML_LEXER_TOKENIZE_TEST[24] = 'created = 1979-05-27T07:32:00Z'

    // Test 25: DateTime with offset
    TOML_LEXER_TOKENIZE_TEST[25] = 'updated = 1979-05-27T00:32:00-07:00'

    // Test 26: Multiline basic string
    TOML_LEXER_TOKENIZE_TEST[26] = "'text = """', 13, 10, 'Line 1', 13, 10, 'Line 2', 13, 10, '"""'"

    // Test 27: Multiline literal string
    TOML_LEXER_TOKENIZE_TEST[27] = "'regex = ''''''', 13, 10, '\d{2}\\s+\\w+', 13, 10, ''''''''"

    // Test 28: Dotted key
    TOML_LEXER_TOKENIZE_TEST[28] = 'site."google.com" = true'

    // Test 29: Comment line
    TOML_LEXER_TOKENIZE_TEST[29] = "'# This is a comment', 13, 10, 'key = "value"  # inline comment', 13, 10"

    // Test 30: Integer with underscores
    TOML_LEXER_TOKENIZE_TEST[30] = 'large = 1_000_000'

    // Test 31: Float with underscores
    TOML_LEXER_TOKENIZE_TEST[31] = 'precise = 3.141_592_653'

    // Test 32: Empty inline table
    TOML_LEXER_TOKENIZE_TEST[32] = 'empty = {}'

    // Test 33: Nested arrays
    TOML_LEXER_TOKENIZE_TEST[33] = 'matrix = [[1, 2], [3, 4]]'

    // Test 34: Negative integer
    TOML_LEXER_TOKENIZE_TEST[34] = 'negative = -42'

    // Test 35: Negative float
    TOML_LEXER_TOKENIZE_TEST[35] = 'negative_float = -3.14'

    // Test 36: Positive sign
    TOML_LEXER_TOKENIZE_TEST[36] = 'positive = +42'

    // Test 37: Zero
    TOML_LEXER_TOKENIZE_TEST[37] = 'zero = 0'

    // Test 38: Bare key with numbers
    TOML_LEXER_TOKENIZE_TEST[38] = 'key123 = "value"'

    // Test 39: Bare key with underscores
    TOML_LEXER_TOKENIZE_TEST[39] = 'my_key = "value"'

    // Test 40: Bare key with hyphens
    TOML_LEXER_TOKENIZE_TEST[40] = 'my-key = "value"'

    // Test 41: Array with trailing comma
    TOML_LEXER_TOKENIZE_TEST[41] = 'array = [1, 2, 3,]'

    // Test 42: Multiple key-values
    TOML_LEXER_TOKENIZE_TEST[42] = "'name = "John"', 13, 10, 'age = 30', 13, 10, 'active = true', 13, 10"

    // Test 43: Table with key-value
    TOML_LEXER_TOKENIZE_TEST[43] = "'[server]', 13, 10, 'host = "localhost"', 13, 10, 'port = 8080', 13, 10"

    // Test 44: DateTime with fractional seconds
    TOML_LEXER_TOKENIZE_TEST[44] = 'precise_time = 1979-05-27T07:32:00.999999Z'

    // Test 45: Local datetime (no timezone)
    TOML_LEXER_TOKENIZE_TEST[45] = 'local = 1979-05-27T07:32:00'

    // Test 46: Time with fractional seconds
    TOML_LEXER_TOKENIZE_TEST[46] = 'time = 07:32:00.999999'

    // Test 47: Negative infinity
    TOML_LEXER_TOKENIZE_TEST[47] = 'minus_inf = -inf'

    // Test 48: Positive NaN
    TOML_LEXER_TOKENIZE_TEST[48] = 'plus_nan = +nan'

    // Test 49: Whitespace variations
    TOML_LEXER_TOKENIZE_TEST[49] = "'key   =   "value"'"

    // Test 50: Multiple tables
    TOML_LEXER_TOKENIZE_TEST[50] = "'[table1]', 13, 10, 'key1 = 1', 13, 10, '[table2]', 13, 10, 'key2 = 2', 13, 10"

    // ===== Underscore Tests =====
    // Test 51: Hexadecimal with underscores
    TOML_LEXER_TOKENIZE_TEST[51] = 'hex_value = 0xDEAD_BEEF'

    // Test 52: Octal with underscores
    TOML_LEXER_TOKENIZE_TEST[52] = 'octal_value = 0o7_5_5'

    // Test 53: Binary with underscores
    TOML_LEXER_TOKENIZE_TEST[53] = 'binary_value = 0b1101_0110'

    // Test 54: Multiple underscore groups in integer
    TOML_LEXER_TOKENIZE_TEST[54] = 'large_int = 1_234_567_890'

    // Test 55: Float with multiple underscore groups
    TOML_LEXER_TOKENIZE_TEST[55] = 'precise_float = 224_617.445_991_228'

    // Test 56: Negative integer with underscores
    TOML_LEXER_TOKENIZE_TEST[56] = 'neg_value = -1_000'

    // Test 57: Float with exponent and underscores
    TOML_LEXER_TOKENIZE_TEST[57] = 'sci_notation = 6.022_140_76e+2_3'

    // ===== \xHH Escape Sequence Tests =====
    // Test 58: Valid \xHH escape with lowercase hex digits
    TOML_LEXER_TOKENIZE_TEST[58] = 'text = "valid \xff"'

    // Test 59: Valid \xHH escape with uppercase hex digits
    TOML_LEXER_TOKENIZE_TEST[59] = 'text = "valid \xAB"'

    // Test 60: Valid \xHH escape with mixed case hex digits
    TOML_LEXER_TOKENIZE_TEST[60] = 'text = "valid \xAb"'

    // Test 61: Invalid \x escape with no hex digits (should fail)
    TOML_LEXER_TOKENIZE_TEST[61] = 'text = "incomplete \x"'

    // Test 62: Invalid \x escape with only 1 hex digit (should fail)
    TOML_LEXER_TOKENIZE_TEST[62] = 'text = "incomplete \x1"'

    // Test 63: Invalid \x escape with non-hex characters (should fail)
    TOML_LEXER_TOKENIZE_TEST[63] = 'text = "invalid \xGG"'

    set_length_array(TOML_LEXER_TOKENIZE_TEST, 63)
}


DEFINE_CONSTANT

constant char TOML_LEXER_TOKENIZE_EXPECTED_RESULT[] = {
    true,   // Test 1: Empty document
    true,   // Test 2: Simple key-value
    true,   // Test 3: Integer value
    true,   // Test 4: Boolean true
    true,   // Test 5: Boolean false
    true,   // Test 6: Float value
    true,   // Test 7: Basic string
    true,   // Test 8: Literal string
    true,   // Test 9: Array of integers
    true,   // Test 10: Array of strings
    true,   // Test 11: Empty array
    true,   // Test 12: Table header
    true,   // Test 13: Dotted table header
    true,   // Test 14: Array of tables header
    true,   // Test 15: Inline table
    true,   // Test 16: Hexadecimal integer
    true,   // Test 17: Octal integer
    true,   // Test 18: Binary integer
    true,   // Test 19: Float with exponent
    true,   // Test 20: Infinity
    true,   // Test 21: Not a number
    true,   // Test 22: Date value
    true,   // Test 23: Time value
    true,   // Test 24: DateTime value
    true,   // Test 25: DateTime with offset
    true,   // Test 26: Multiline basic string
    true,   // Test 27: Multiline literal string
    true,   // Test 28: Dotted key
    true,   // Test 29: Comment line
    true,   // Test 30: Integer with underscores
    true,   // Test 31: Float with underscores
    true,   // Test 32: Empty inline table
    true,   // Test 33: Nested arrays
    true,   // Test 34: Negative integer
    true,   // Test 35: Negative float
    true,   // Test 36: Positive sign
    true,   // Test 37: Zero
    true,   // Test 38: Bare key with numbers
    true,   // Test 39: Bare key with underscores
    true,   // Test 40: Bare key with hyphens
    true,   // Test 41: Array with trailing comma
    true,   // Test 42: Multiple key-values
    true,   // Test 43: Table with key-value
    true,   // Test 44: DateTime with fractional seconds
    true,   // Test 45: Local datetime
    true,   // Test 46: Time with fractional seconds
    true,   // Test 47: Negative infinity
    true,   // Test 48: Positive NaN
    true,   // Test 49: Whitespace variations
    true,   // Test 50: Multiple tables
    true,   // Test 51: Hexadecimal with underscores
    true,   // Test 52: Octal with underscores
    true,   // Test 53: Binary with underscores
    true,   // Test 54: Multiple underscore groups in integer
    true,   // Test 55: Float with multiple underscore groups
    true,   // Test 56: Negative integer with underscores
    true,   // Test 57: Float with exponent and underscores
    true,   // Test 58: Valid \xHH escape (lowercase)
    true,   // Test 59: Valid \xHH escape (uppercase)
    true,   // Test 60: Valid \xHH escape (mixed case)
    false,  // Test 61: Invalid \x escape (no digits)
    false,  // Test 62: Invalid \x escape (1 digit)
    false   // Test 63: Invalid \x escape (non-hex)
}

constant integer TOML_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[] = {
    1,      // Test 1: EOF
    4,      // Test 2: name, =, "John", EOF
    4,      // Test 3: age, =, 30, EOF
    4,      // Test 4: enabled, =, true, EOF
    4,      // Test 5: disabled, =, false, EOF
    4,      // Test 6: pi, =, 3.14159, EOF
    4,      // Test 7: text, =, "Hello World", EOF
    4,      // Test 8: path, =, 'C..', EOF
    14,     // Test 9: numbers, =, [, 1, ,, 2, ,, 3, ,, 4, ,, 5, ], EOF
    10,     // Test 10: colors, =, [, "red", ,, "green", ,, "blue", ], EOF
    5,      // Test 11: empty, =, [, ], EOF
    2,      // Test 12: [server], EOF
    2,      // Test 13: [database.connection], EOF
    2,      // Test 14: [[products]], EOF
    12,     // Test 15: point, =, {, x, =, 10, ,, y, =, 20, }, EOF
    4,      // Test 16: hex, =, 0xDEADBEEF, EOF
    4,      // Test 17: oct, =, 0o755, EOF
    4,      // Test 18: bin, =, 0b11010110, EOF
    4,      // Test 19: value, =, 5e+22, EOF
    4,      // Test 20: infinity, =, inf, EOF
    4,      // Test 21: not_a_num, =, nan, EOF
    4,      // Test 22: birthday, =, 1979-05-27, EOF
    4,      // Test 23: alarm, =, 07:32:00, EOF
    4,      // Test 24: created, =, datetime, EOF
    4,      // Test 25: updated, =, datetime, EOF
    4,      // Test 26: text, =, """...""", EOF
    4,      // Test 27: regex, =, '''...''', EOF
    6,      // Test 28: site, ., "google.com", =, true, EOF
    8,      // Test 29: comment, newline, key, =, "value", comment, newline, EOF
    4,      // Test 30: large, =, 1_000_000, EOF
    4,      // Test 31: precise, =, 3.141_592_653, EOF
    5,      // Test 32: empty, =, {, }, EOF
    16,     // Test 33: matrix, =, [, [, 1, ,, 2, ], ,, [, 3, ,, 4, ], ], EOF
    4,      // Test 34: negative, =, -42, EOF
    4,      // Test 35: negative_float, =, -3.14, EOF
    4,      // Test 36: positive, =, +42, EOF
    4,      // Test 37: zero, =, 0, EOF
    4,      // Test 38: key123, =, "value", EOF
    4,      // Test 39: my_key, =, "value", EOF
    4,      // Test 40: my-key, =, "value", EOF
    11,     // Test 41: array, =, [, 1, ,, 2, ,, 3, ,, ], EOF
    13,     // Test 42: name, =, "John", newline, age, =, 30, newline, active, =, true, newline, EOF
    11,     // Test 43: [server], newline, host, =, "localhost", newline, port, =, 8080, newline, EOF
    4,      // Test 44: precise_time, =, datetime, EOF
    4,      // Test 45: local, =, datetime, EOF
    4,      // Test 46: time, =, time, EOF
    4,      // Test 47: minus_inf, =, -inf, EOF
    4,      // Test 48: plus_nan, =, +nan, EOF
    4,      // Test 49: key, =, "value", EOF
    13,     // Test 50: [table1], newline, key1, =, 1, newline, [table2], newline, key2, =, 2, newline, EOF
    4,      // Test 51: hex_value, =, 0xDEAD_BEEF, EOF
    4,      // Test 52: octal_value, =, 0o7_5_5, EOF
    4,      // Test 53: binary_value, =, 0b1101_0110, EOF
    4,      // Test 54: large_int, =, 1_234_567_890, EOF
    4,      // Test 55: precise_float, =, 224_617.445_991_228, EOF
    4,      // Test 56: neg_value, =, -1_000, EOF
    4,      // Test 57: sci_notation, =, 6.022_140_76e+2_3, EOF
    4,      // Test 58: text, =, "valid \xff", EOF
    4,      // Test 59: text, =, "valid \xAB", EOF
    4,      // Test 60: text, =, "valid \xAb", EOF
    0,      // Test 61: Should fail (no hex digits)
    0,      // Test 62: Should fail (1 hex digit)
    0       // Test 63: Should fail (non-hex chars)
}

constant integer TOML_LEXER_TOKENIZE_EXPECTED_TYPES[63][20] = {
    // Test 1: Empty document
    {
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 2: Simple key-value (name = "John")
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // name
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "John"
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 3: Integer value (age = 30)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // age
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 30
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 4: Boolean true (enabled = true)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // enabled
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_BOOLEAN,       // true
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 5: Boolean false (disabled = false)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // disabled
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_BOOLEAN,       // false
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 6: Float value (pi = 3.14159)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // pi
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_FLOAT,         // 3.14159
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 7: Basic string (text = "Hello World")
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // text
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "Hello World"
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 8: Literal string (path = 'C:\Windows\System32')
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // path
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // 'C:\Windows\System32'
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 9: Array of integers (numbers = [1, 2, 3, 4, 5])
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // numbers
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_LEFT_BRACKET,  // [
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 1
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 2
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 3
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 4
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 5
        NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET, // ]
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 10: Array of strings (colors = ["red", "green", "blue"])
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // colors
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_LEFT_BRACKET,  // [
        NAV_TOML_TOKEN_TYPE_STRING,        // "red"
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_STRING,        // "green"
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_STRING,        // "blue"
        NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET, // ]
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 11: Empty array (empty = [])
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // empty
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_LEFT_BRACKET,  // [
        NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET, // ]
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 12: Table header ([server])
    {
        NAV_TOML_TOKEN_TYPE_TABLE_HEADER,  // [server]
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 13: Dotted table header ([database.connection])
    {
        NAV_TOML_TOKEN_TYPE_TABLE_HEADER,  // [database.connection]
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 14: Array of tables header ([[products]])
    {
        NAV_TOML_TOKEN_TYPE_ARRAY_TABLE,   // [[products]]
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 15: Inline table (point = { x = 10, y = 20 })
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // point
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_LEFT_BRACE,    // {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // x
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 10
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // y
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 20
        NAV_TOML_TOKEN_TYPE_RIGHT_BRACE,   // }
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 16: Hexadecimal integer (hex = 0xDEADBEEF)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // hex
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 0xDEADBEEF
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 17: Octal integer (oct = 0o755)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // oct
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 0o755
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 18: Binary integer (bin = 0b11010110)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // bin
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 0b11010110
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 19: Float with exponent (value = 5e+22)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // value
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_FLOAT,         // 5e+22
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 20: Infinity (infinity = inf)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // infinity
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_FLOAT,         // inf
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 21: Not a number (not_a_num = nan)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // not_a_num
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_FLOAT,         // nan
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 22: Date value (birthday = 1979-05-27)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // birthday
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_DATE,          // 1979-05-27
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 23: Time value (alarm = 07:32:00)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // alarm
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_TIME,          // 07:32:00
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 24: DateTime value (created = 1979-05-27T07:32:00Z)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // created
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_DATETIME,      // 1979-05-27T07:32:00Z
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 25: DateTime with offset (updated = 1979-05-27T00:32:00-07:00)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // updated
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_DATETIME,      // 1979-05-27T00:32:00-07:00
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 26: Multiline basic string
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,           // text
        NAV_TOML_TOKEN_TYPE_EQUALS,             // =
        NAV_TOML_TOKEN_TYPE_MULTILINE_STRING,   // """..."""
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 27: Multiline literal string
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,           // regex
        NAV_TOML_TOKEN_TYPE_EQUALS,             // =
        NAV_TOML_TOKEN_TYPE_MULTILINE_STRING,   // '''...'''
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 28: Dotted key (site."google.com" = true)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // site
        NAV_TOML_TOKEN_TYPE_DOT,           // .
        NAV_TOML_TOKEN_TYPE_STRING,        // "google.com"
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_BOOLEAN,       // true
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 29: Comment line (# This is a comment\n key = "value"  # inline comment\n)
    {
        NAV_TOML_TOKEN_TYPE_COMMENT,       // # This is a comment
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // key
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "value"
        NAV_TOML_TOKEN_TYPE_COMMENT,       // # inline comment
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 30: Integer with underscores (large = 1_000_000)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // large
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 1_000_000
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 31: Float with underscores (precise = 3.141_592_653)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // precise
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_FLOAT,         // 3.141_592_653
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 32: Empty inline table (empty = {})
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // empty
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_LEFT_BRACE,    // {
        NAV_TOML_TOKEN_TYPE_RIGHT_BRACE,   // }
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 33: Nested arrays (matrix = [[1, 2], [3, 4]])
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // matrix
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_LEFT_BRACKET,  // [
        NAV_TOML_TOKEN_TYPE_LEFT_BRACKET,  // [
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 1
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 2
        NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET, // ]
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_LEFT_BRACKET,  // [
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 3
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 4
        NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET, // ]
        NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET, // ]
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 34: Negative integer (negative = -42)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // negative
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // -42
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 35: Negative float (negative_float = -3.14)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // negative_float
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_FLOAT,         // -3.14
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 36: Positive sign (positive = +42)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // positive
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // +42
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 37: Zero (zero = 0)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // zero
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 0
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 38: Bare key with numbers (key123 = "value")
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // key123
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "value"
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 39: Bare key with underscores (my_key = "value")
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // my_key
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "value"
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 40: Bare key with hyphens (my-key = "value")
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // my-key
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "value"
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 41: Array with trailing comma (array = [1, 2, 3,])
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // array
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_LEFT_BRACKET,  // [
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 1
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 2
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 3
        NAV_TOML_TOKEN_TYPE_COMMA,         // ,
        NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET, // ]
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 42: Multiple key-values (name = "John"\n age = 30\n active = true\n)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // name
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "John"
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // age
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 30
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // active
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_BOOLEAN,       // true
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 43: Table with key-value ([server]\n host = "localhost"\n port = 8080\n)
    {
        NAV_TOML_TOKEN_TYPE_TABLE_HEADER,  // [server]
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // host
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "localhost"
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // port
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 8080
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 44: DateTime with fractional seconds
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // precise_time
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_DATETIME,      // 1979-05-27T07:32:00.999999Z
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 45: Local datetime (local = 1979-05-27T07:32:00)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // local
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_DATETIME,      // 1979-05-27T07:32:00
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 46: Time with fractional seconds (time = 07:32:00.999999)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // time
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_TIME,          // 07:32:00.999999
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 47: Negative infinity (minus_inf = -inf)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // minus_inf
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_FLOAT,         // -inf
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 48: Positive NaN (plus_nan = +nan)
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // plus_nan
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_FLOAT,         // +nan
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 49: Whitespace variations (key   =   "value")
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // key
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "value"
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 50: Multiple tables ([table1]\n key1 = 1\n [table2]\n key2 = 2\n)
    {
        NAV_TOML_TOKEN_TYPE_TABLE_HEADER,  // [table1]
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // key1
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 1
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_TABLE_HEADER,  // [table2]
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // key2
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 2
        NAV_TOML_TOKEN_TYPE_NEWLINE,       // \n
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 51: Hexadecimal with underscores (hex_value = 0xDEAD_BEEF)
    // Expected: Lexer stores "0xDEAD_BEEF", implementation should strip to "0xDEADBEEF"
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // hex_value
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 0xDEAD_BEEF
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 52: Octal with underscores (octal_value = 0o7_5_5)
    // Expected: Lexer stores "0o7_5_5", implementation should strip to "0o755"
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // octal_value
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 0o7_5_5
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 53: Binary with underscores (binary_value = 0b1101_0110)
    // Expected: Lexer stores "0b1101_0110", implementation should strip to "0b11010110"
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // binary_value
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 0b1101_0110
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 54: Multiple underscore groups (large_int = 1_234_567_890)
    // Expected: Lexer stores "1_234_567_890", implementation should strip to "1234567890"
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // large_int
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // 1_234_567_890
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 55: Float with multiple underscores (precise_float = 224_617.445_991_228)
    // Expected: Lexer stores "224_617.445_991_228", implementation should strip to "224617.445991228"
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // precise_float
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_FLOAT,         // 224_617.445_991_228
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 56: Negative with underscores (neg_value = -1_000)
    // Expected: Lexer stores "-1_000", implementation should strip to "-1000"
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // neg_value
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_INTEGER,       // -1_000
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 57: Float with exponent and underscores (sci_notation = 6.022_140_76e+2_3)
    // Expected: Lexer stores "6.022_140_76e+2_3", implementation should strip to "6.02214076e+23"
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // sci_notation
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_FLOAT,         // 6.022_140_76e+2_3
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 58: Valid \xHH escape (lowercase) (text = "valid \xff")
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // text
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "valid \xff"
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 59: Valid \xHH escape (uppercase) (text = "valid \xAB")
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // text
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "valid \xAB"
        NAV_TOML_TOKEN_TYPE_EOF
    },
    // Test 60: Valid \xHH escape (mixed case) (text = "valid \xAb")
    {
        NAV_TOML_TOKEN_TYPE_BARE_KEY,      // text
        NAV_TOML_TOKEN_TYPE_EQUALS,        // =
        NAV_TOML_TOKEN_TYPE_STRING,        // "valid \xAb"
        NAV_TOML_TOKEN_TYPE_EOF
    }
}

// Expected token values for each test
constant char TOML_LEXER_TOKENIZE_EXPECTED_VALUES[][][NAV_TOML_LEXER_MAX_TOKEN_LENGTH] = {
    // Test 1: Empty document
    {
        ''
    },
    // Test 2: Simple key-value (name = "John")
    {
        'name',
        '=',
        '"John"',
        ''
    },
    // Test 3: Integer value (age = 30)
    {
        'age',
        '=',
        '30',
        ''
    },
    // Test 4: Boolean true (enabled = true)
    {
        'enabled',
        '=',
        'true',
        ''
    },
    // Test 5: Boolean false (disabled = false)
    {
        'disabled',
        '=',
        'false',
        ''
    },
    // Test 6: Float value (pi = 3.14159)
    {
        'pi',
        '=',
        '3.14159',
        ''
    },
    // Test 7: Basic string (text = "Hello World")
    {
        'text',
        '=',
        '"Hello World"',
        ''
    },
    // Test 8: Literal string (path = 'C:\Windows\System32')
    {
        'path',
        '=',
        "'C:\Windows\System32'",
        ''
    },
    // Test 9: Array of integers (numbers = [1, 2, 3, 4, 5])
    {
        'numbers',
        '=',
        '[',
        '1',
        ',',
        '2',
        ',',
        '3',
        ',',
        '4',
        ',',
        '5',
        ']',
        ''
    },
    // Test 10: Array of strings (colors = ["red", "green", "blue"])
    {
        'colors',
        '=',
        '[',
        '"red"',
        ',',
        '"green"',
        ',',
        '"blue"',
        ']',
        ''
    },
    // Test 11: Empty array (empty = [])
    {
        'empty',
        '=',
        '[',
        ']',
        ''
    },
    // Test 12: Table header ([server])
    {
        '[server]',
        ''
    },
    // Test 13: Dotted table header ([database.connection])
    {
        '[database.connection]',
        ''
    },
    // Test 14: Array of tables header ([[products]])
    {
        '[[products]]',
        ''
    },
    // Test 15: Inline table (point = { x = 10, y = 20 })
    {
        'point',
        '=',
        '{',
        'x',
        '=',
        '10',
        ',',
        'y',
        '=',
        '20',
        '}',
        ''
    },
    // Test 16: Hexadecimal (hex = 0xDEADBEEF)
    {
        'hex',
        '=',
        '0xDEADBEEF',
        ''
    },
    // Test 17: Octal (oct = 0o755)
    {
        'oct',
        '=',
        '0o755',
        ''
    },
    // Test 18: Binary (bin = 0b11010110)
    {
        'bin',
        '=',
        '0b11010110',
        ''
    },
    // Test 19: Scientific notation (value = 5e+22)
    {
        'value',
        '=',
        '5e+22',
        ''
    },
    // Test 20: Positive infinity (infinity = inf)
    {
        'infinity',
        '=',
        'inf',
        ''
    },
    // Test 21: Not a number (not_a_num = nan)
    {
        'not_a_num',
        '=',
        'nan',
        ''
    },
    // Test 22: Date (birthday = 1979-05-27)
    {
        'birthday',
        '=',
        '1979-05-27',
        ''
    },
    // Test 23: Time (alarm = 07:32:00)
    {
        'alarm',
        '=',
        '07:32:00',
        ''
    },
    // Test 24: DateTime with Z (created = 1979-05-27T07:32:00Z)
    {
        'created',
        '=',
        '1979-05-27T07:32:00Z',
        ''
    },
    // Test 25: DateTime with offset (updated = 1979-05-27T00:32:00-07:00)
    {
        'updated',
        '=',
        '1979-05-27T00:32:00-07:00',
        ''
    },
    // Test 26: Multiline basic string
    {
        'text',
        '=',
        {'"', '"', '"', $0D, $0A, 'L', 'i', 'n', 'e', ' ', '1', $0D, $0A, 'L', 'i', 'n', 'e', ' ', '2', $0D, $0A, '"', '"', '"'},
        ''
    },
    // Test 27: Multiline literal string
    {
        'regex',
        '=',
        {'''', '''', '''', $0D, $0A, '\', 'd', '{', '2', '}', '\', '\', 's', '+', '\', '\', 'w', '+', $0D, $0A, '''', '''', ''''},
        ''
    },
    // Test 28: Dotted keys (site."google.com" = true)
    {
        'site',
        '.',
        '"google.com"',
        '=',
        'true',
        ''
    },
    // Test 29: Comments
    {
        '# This is a comment',
        {$0D, $0A},
        'key',
        '=',
        '"value"',
        '# inline comment',
        {$0D, $0A},
        ''
    },
    // Test 30: Integer with underscores (large = 1_000_000)
    {
        'large',
        '=',
        '1000000',
        ''
    },
    // Test 31: Float with underscores (precise = 3.141_592_653)
    {
        'precise',
        '=',
        '3.141592653',
        ''
    },
    // Test 32: Empty inline table (empty = {})
    {
        'empty',
        '=',
        '{',
        '}',
        ''
    },
    // Test 33: Nested arrays (matrix = [[1, 2], [3, 4]])
    {
        'matrix',
        '=',
        '[',
        '[',
        '1',
        ',',
        '2',
        ']',
        ',',
        '[',
        '3',
        ',',
        '4',
        ']',
        ']',
        ''
    },
    // Test 34: Negative integer (negative = -42)
    {
        'negative',
        '=',
        '-42',
        ''
    },
    // Test 35: Negative float (negative_float = -3.14)
    {
        'negative_float',
        '=',
        '-3.14',
        ''
    },
    // Test 36: Positive sign (positive = +42)
    {
        'positive',
        '=',
        '+42',
        ''
    },
    // Test 37: Zero (zero = 0)
    {
        'zero',
        '=',
        '0',
        ''
    },
    // Test 38: Key with digits (key123 = "value")
    {
        'key123',
        '=',
        '"value"',
        ''
    },
    // Test 39: Key with underscores (my_key = "value")
    {
        'my_key',
        '=',
        '"value"',
        ''
    },
    // Test 40: Key with hyphens (my-key = "value")
    {
        'my-key',
        '=',
        '"value"',
        ''
    },
    // Test 41: Trailing comma in array
    {
        'array',
        '=',
        '[',
        '1',
        ',',
        '2',
        ',',
        '3',
        ',',
        ']',
        ''
    },
    // Test 42: Multiple lines
    {
        'name',
        '=',
        '"John"',
        {$0D, $0A},
        'age',
        '=',
        '30',
        {$0D, $0A},
        'active',
        '=',
        'true',
        {$0D, $0A},
        ''
    },
    // Test 43: Table with key-values
    {
        '[server]',
        {$0D, $0A},
        'host',
        '=',
        '"localhost"',
        {$0D, $0A},
        'port',
        '=',
        '8080',
        {$0D, $0A},
        ''
    },
    // Test 44: DateTime with fractional seconds
    {
        'precise_time',
        '=',
        '1979-05-27T07:32:00.999999Z',
        ''
    },
    // Test 45: Local datetime
    {
        'local',
        '=',
        '1979-05-27T07:32:00',
        ''
    },
    // Test 46: Time with fractional seconds
    {
        'time',
        '=',
        '07:32:00.999999',
        ''
    },
    // Test 47: Negative infinity
    {
        'minus_inf',
        '=',
        '-inf',
        ''
    },
    // Test 48: Positive NaN
    {
        'plus_nan',
        '=',
        '+nan',
        ''
    },
    // Test 49: Whitespace variations
    {
        'key',
        '=',
        '"value"',
        ''
    },
    // Test 50: Multiple tables
    {
        '[table1]',
        {$0D, $0A},
        'key1',
        '=',
        '1',
        {$0D, $0A},
        '[table2]',
        {$0D, $0A},
        'key2',
        '=',
        '2',
        {$0D, $0A},
        ''
    },
    // Test 51: Hexadecimal with underscores (hex_value = 0xDEAD_BEEF)
    // Expected after underscore stripping: 0xDEADBEEF
    {
        'hex_value',
        '=',
        '0xDEADBEEF',  // Expected value after underscore stripping
        ''
    },
    // Test 52: Octal with underscores (octal_value = 0o7_5_5)
    // Expected after underscore stripping: 0o755
    {
        'octal_value',
        '=',
        '0o755',  // Expected value after underscore stripping
        ''
    },
    // Test 53: Binary with underscores (binary_value = 0b1101_0110)
    // Expected after underscore stripping: 0b11010110
    {
        'binary_value',
        '=',
        '0b11010110',  // Expected value after underscore stripping
        ''
    },
    // Test 54: Multiple underscore groups (large_int = 1_234_567_890)
    // Expected after underscore stripping: 1234567890
    {
        'large_int',
        '=',
        '1234567890',  // Expected value after underscore stripping
        ''
    },
    // Test 55: Float with multiple underscores (precise_float = 224_617.445_991_228)
    // Expected after underscore stripping: 224617.445991228
    {
        'precise_float',
        '=',
        '224617.445991228',  // Expected value after underscore stripping
        ''
    },
    // Test 56: Negative with underscores (neg_value = -1_000)
    // Expected after underscore stripping: -1000
    {
        'neg_value',
        '=',
        '-1000',  // Expected value after underscore stripping
        ''
    },
    // Test 57: Float with exponent and underscores (sci_notation = 6.022_140_76e+2_3)
    // Expected after underscore stripping: 6.02214076e+23
    {
        'sci_notation',
        '=',
        '6.02214076e+23',  // Expected value after underscore stripping
        ''
    },
    // Test 58: Valid \xHH escape (lowercase) (text = "valid \xff")
    {
        'text',
        '=',
        '"valid \xff"',
        ''
    },
    // Test 59: Valid \xHH escape (uppercase) (text = "valid \xAB")
    {
        'text',
        '=',
        '"valid \xAB"',
        ''
    },
    // Test 60: Valid \xHH escape (mixed case) (text = "valid \xAb")
    {
        'text',
        '=',
        '"valid \xAb"',
        ''
    }
}


define_function TestNAVTomlLexerTokenize() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlLexerTokenize'")

    InitializeTomlLexerTokenizeTestData()

    for (x = 1; x <= length_array(TOML_LEXER_TOKENIZE_TEST); x++) {
         stack_var integer j
        stack_var char failed
        stack_var char result
        stack_var _NAVTomlLexer lexer

        result = NAVTomlLexerTokenize(lexer, TOML_LEXER_TOKENIZE_TEST[x])

        // Assert tokenize result
        if (!NAVAssertBooleanEqual('Tokenize should succeed',
                                    TOML_LEXER_TOKENIZE_EXPECTED_RESULT[x],
                                    result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_LEXER_TOKENIZE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Skip further validation for error cases
        if (!TOML_LEXER_TOKENIZE_EXPECTED_RESULT[x]) {
            NAVLogTestPassed(x)
            continue
        }

        // Skip token type validation if first element is 0 (indicates complex test to skip)
        if (TOML_LEXER_TOKENIZE_EXPECTED_TYPES[x][1] == 0) {
            // Just do basic validation
            if (lexer.tokenCount > 0 &&
                lexer.tokens[lexer.tokenCount].type == NAV_TOML_TOKEN_TYPE_EOF) {
                NAVLogTestPassed(x)
            } else {
                NAVLogTestFailed(x, "'EOF token present'", "'Missing or invalid EOF'")
            }
            continue
        }

        // Assert token count
        if (!NAVAssertIntegerEqual('Token count should match',
                                    TOML_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[x],
                                    lexer.tokenCount)) {
            NAVLogTestFailed(x,
                            itoa(TOML_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[x]),
                            itoa(lexer.tokenCount))
            continue
        }

        // Assert each token type
        failed = false
        for (j = 1; j <= lexer.tokenCount; j++) {
            if (!NAVAssertIntegerEqual('Token type should match',
                                       TOML_LEXER_TOKENIZE_EXPECTED_TYPES[x][j],
                                       lexer.tokens[j].type)) {
                NAVLogTestFailed(x,
                                NAVTomlLexerGetTokenType(TOML_LEXER_TOKENIZE_EXPECTED_TYPES[x][j]),
                                NAVTomlLexerGetTokenType(lexer.tokens[j].type))
                failed = true
                break
            }

            // Assert line number is >= 1
            if (!NAVAssertIntegerGreaterThanOrEqual('Token line should be >= 1',
                                                    1,
                                                    lexer.tokens[j].line)) {
                NAVLogTestFailed(x, "'Line >= 1'", itoa(lexer.tokens[j].line))
                failed = true
                break
            }

            // Assert column number is positive
            if (!NAVAssertIntegerGreaterThan('Token column should be positive',
                                             0,
                                             lexer.tokens[j].column)) {
                NAVLogTestFailed(x, "'Column > 0'", itoa(lexer.tokens[j].column))
                failed = true
                break
            }

            // Skip value check for EOF token
            if (lexer.tokens[j].type == NAV_TOML_TOKEN_TYPE_EOF) {
                continue
            }

            // Assert token value matches expected
            if (!NAVAssertStringEqual('Token value should match',
                                      TOML_LEXER_TOKENIZE_EXPECTED_VALUES[x][j],
                                      lexer.tokens[j].value)) {
                NAVLogTestFailed(x,
                                TOML_LEXER_TOKENIZE_EXPECTED_VALUES[x][j],
                                lexer.tokens[j].value)
                failed = true
                break
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlLexerTokenize'")
}
