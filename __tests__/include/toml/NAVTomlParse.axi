PROGRAM_NAME='NAVTomlParse'

// Uncomment to enable detailed tree validation debug logging
// #DEFINE DEBUG_TOML_TREE_VALIDATION


DEFINE_VARIABLE

volatile char TOML_PARSE_TEST[91][4096]
volatile _NAVTomlNode TOML_PARSE_EXPECTED_NODES[91][50]  // Max 50 nodes per test

constant char TOML_PARSE_EXPECTED_RESULT[] = {
    true,   // Test 1: Empty document
    true,   // Test 2: Simple key-value
    true,   // Test 3: Multiple key-values
    true,   // Test 4: Integer types
    true,   // Test 5: Float types
    true,   // Test 6: Boolean values
    true,   // Test 7: Date and time
    true,   // Test 8: Arrays
    true,   // Test 9: Inline table
    true,   // Test 10: Table header
    true,   // Test 11: Multiple tables
    true,   // Test 12: Nested tables
    true,   // Test 13: Array of tables
    true,   // Test 14: Dotted keys
    true,   // Test 15: Mixed values
    true,   // Test 16: Complex nested structure
    true,   // Test 17: String escapes
    true,   // Test 18: Multiline strings
    true,   // Test 19: Comments
    true,   // Test 20: Empty array
    true,   // Test 21: Empty inline table
    true,   // Test 22: Hexadecimal integer
    true,   // Test 23: DateTime with timezone
    true,   // Test 24: Array with trailing comma
    true,   // Test 25: Integer with underscores
    true,   // Test 26: Nested arrays
    true,   // Test 27: Multiple array of tables
    true,   // Test 28: Inf and NaN
    true,   // Test 29: Literal strings
    true,   // Test 30: Complex document
    true,   // Test 31: Negative numbers
    true,   // Test 32: Zero values
    true,   // Test 33: Mixed float representations
    true,   // Test 34: Empty strings
    true,   // Test 35: Multiline array
    true,   // Test 36: Array of inline tables
    true,   // Test 37: Nested inline tables
    true,   // Test 38: Dotted keys in table
    true,   // Test 39: Quoted keys
    true,   // Test 40: Local datetime
    true,   // Test 41: Datetime with fractional seconds
    true,   // Test 42: Multiline string with escapes
    true,   // Test 43: Line-ending backslash
    true,   // Test 44: Multiple array tables same level
    true,   // Test 45: Table after array of tables
    true,   // Test 46: Deeply nested tables
    true,   // Test 47: Whitespace handling
    true,   // Test 48: All escape sequences
    true,   // Test 49: Complex array structures
    true,   // Test 50: Edge case combinations
    true,   // Test 51: Unicode escape sequences (\uXXXX)
    true,   // Test 52: Unicode escape sequences (\UXXXXXXXX)
    false,  // Test 53: Invalid - duplicate key in same table
    false,  // Test 54: Invalid - duplicate key in nested table
    false,  // Test 55: Invalid - table defined after array of tables (same name)
    false,  // Test 56: Invalid - redefining existing key as table
    false,  // Test 57: Invalid - mixed type array (integer and string)
    false,  // Test 58: Invalid - mixed type array (integer and float)
    false,  // Test 59: Invalid - mixed type array (boolean and integer)
    true,   // Test 60: Valid - nested homogeneous arrays
    false,  // Test 61: Invalid - nested array with mixed types
    false,  // Test 62: Invalid - outer array containing invalid inner array
    false,  // Test 63: Invalid - first nested array has mixed types
    false,  // Test 64: Invalid - mixing array with non-array type
    true,   // Test 65: TOML 1.1.0 - Local time without seconds
    true,   // Test 66: TOML 1.1.0 - Local datetime without seconds
    true,   // Test 67: TOML 1.1.0 - Offset datetime without seconds with Z
    true,   // Test 68: TOML 1.1.0 - Offset datetime without seconds with timezone
    true,   // Test 69: TOML 1.1.0 - Local datetime with space, no seconds
    true,   // Test 70: TOML 1.1.0 - Multiple datetime with/without seconds
    true,   // Test 71: TOML 1.1.0 - Basic multiline inline table
    true,   // Test 72: TOML 1.1.0 - Trailing comma before closing brace
    true,   // Test 73: TOML 1.1.0 - Multiline with trailing comma
    true,   // Test 74: TOML 1.1.0 - Nested inline tables with newlines
    true,   // Test 75: TOML 1.1.0 - Multiple key-value pairs multiline
    true,   // Test 76: TOML 1.1.0 - Inline table with newlines in array
    true,   // Test 77: TOML 1.1.0 - Empty inline table multiline format
    true,   // Test 78: TOML 1.1.0 - Inline table with mixed types and newlines
    true,   // Test 79: TOML 1.1.0 - Single line with trailing comma
    true,   // Test 80: TOML 1.1.0 - Deeply nested multiline inline tables
    true,   // Test 81: TOML 1.1.0 - Multiple inline tables in same document
    true,   // Test 82: TOML 1.1.0 - Inline table with various value types and trailing comma
    false,  // Test 83: Invalid - Multiple consecutive commas in inline table
    true,   // Test 84: TOML 1.1.0 - Empty multiline inline table with whitespace
    true,   // Test 85: TOML 1.1.0 - Very deeply nested multiline inline tables
    true,   // Test 86: TOML 1.1.0 - Multiline inline table with excessive whitespace
    true,   // Test 87: TOML 1.1.0 - Trailing comma with newline before closing brace
    false,  // Test 88: Invalid - Comment inside inline table
    false,  // Test 89: Invalid - Time without seconds (hour out of range)
    false,  // Test 90: Invalid - Time without seconds (minute out of range)
    false   // Test 91: Invalid - Fractional seconds without seconds field
}

constant integer TOML_PARSE_EXPECTED_NODE_COUNT[] = {
    1,      // Test 1: Root only
    2,      // Test 2: Root + 1 key-value
    4,      // Test 3: Root + 3 key-values
    5,      // Test 4: Root + 4 integer types
    5,      // Test 5: Root + 4 float types
    3,      // Test 6: Root + 2 booleans
    4,      // Test 7: Root + 3 datetime values
    7,      // Test 8: Root + array + 5 elements
    4,      // Test 9: Root + inline table + 2 properties
    3,      // Test 10: Root + table + 1 key
    5,      // Test 11: Root + 2 tables + 1 key each
    7,      // Test 12: Root + server + host + database + name + cache + ttl
    8,      // Test 13: Root + array + 2 tables + 4 keys
    3,      // Test 14: Root + implicit table + value
    8,      // Test 15: Root + 4 values + array + 2 elements
    13,     // Test 16: Complex nested structure
    3,      // Test 17: Root + 2 escaped strings
    3,      // Test 18: Root + multiline strings
    2,      // Test 19: Root + key (comments ignored)
    2,      // Test 20: Root + empty array
    2,      // Test 21: Root + empty inline table
    2,      // Test 22: Root + hex integer
    2,      // Test 23: Root + datetime
    5,      // Test 24: Root + array + 3 elements
    2,      // Test 25: Root + integer with underscores
    8,      // Test 26: Root + array + 2 nested arrays + 4 elements
    8,      // Test 27: Root + array + 3 tables + 3 keys
    4,      // Test 28: Root + inf + nan
    2,      // Test 29: Root + literal string
    21,     // Test 30: Complex document
    4,      // Test 31: Root + 3 negative numbers
    5,      // Test 32: Root + 4 zero values
    5,      // Test 33: Root + array + 3 float values (different notations)
    3,      // Test 34: Root + 2 empty strings
    5,      // Test 35: Root + array + 3 elements with newlines
    8,      // Test 36: Root + array + 2 inline tables + 4 values
    4,      // Test 37: Root + nested inline table + value
    5,      // Test 38: Root + table + 2 dotted keys creating implicit table + 2 values
    3,      // Test 39: Root + 2 quoted keys
    2,      // Test 40: Root + local datetime
    2,      // Test 41: Root + datetime with fractional seconds
    2,      // Test 42: Root + multiline with escapes
    2,      // Test 43: Root + line-ending backslash
    11,     // Test 44: Root + array table + 3 items + 2 keys each
    6,      // Test 45: Root + array table + regular table + keys
    7,      // Test 46: Root + 6 nested tables + value
    4,      // Test 47: Root + 3 keys with whitespace
    8,      // Test 48: Root + 7 escape sequences
    15,     // Test 49: Root + complex nested arrays (3 levels)
    8,      // Test 50: Root + mixed edge cases
    3,      // Test 51: Root + 2 Unicode escape sequences (\uXXXX)
    3,      // Test 52: Root + 2 Unicode escape sequences (\UXXXXXXXX)
    0,      // Test 53: Parse error - no nodes
    0,      // Test 54: Parse error - no nodes
    0,      // Test 55: Parse error - no nodes
    0,      // Test 56: Parse error - no nodes
    0,      // Test 57: Parse error - no nodes
    0,      // Test 58: Parse error - no nodes
    0,      // Test 59: Parse error - no nodes
    8,      // Test 60: Root + outer array + 2 inner arrays + 4 integers
    0,      // Test 61: Parse error - no nodes
    0,      // Test 62: Parse error - no nodes
    0,      // Test 63: Parse error - no nodes
    0,      // Test 64: Parse error - no nodes
    2,      // Test 65: Root + local time
    2,      // Test 66: Root + local datetime
    2,      // Test 67: Root + offset datetime with Z
    2,      // Test 68: Root + offset datetime with timezone
    2,      // Test 69: Root + local datetime with space
    5,      // Test 70: Root + 4 datetime values
    4,      // Test 71: Root + point inline table (2 children) = 4 nodes
    4,      // Test 72: Root + data inline table (2 children) = 4 nodes
    3,      // Test 73: Root + obj inline table (1 child) = 3 nodes
    6,      // Test 74: Root + outer inline table (inner inline table + value) = 6 nodes
    5,      // Test 75: Root + config inline table (3 children) = 5 nodes
    8,      // Test 76: Root + items array (2 inline tables with 4 children total) = 8 nodes
    2,      // Test 77: Root + empty inline table = 2 nodes
    9,      // Test 78: Root + mixed inline table (4 values + array with 3 elements) = 9 nodes
    3,      // Test 79: Root + simple inline table (1 child) = 3 nodes
    5,      // Test 80: Root + deep inline table (3 nested + 1 value) = 5 nodes
    5,      // Test 81: Root + 2 inline tables with 2 children total = 5 nodes
    5,      // Test 82: Root + person inline table (3 children) = 5 nodes
    0,      // Test 83: Parse error - no nodes
    2,      // Test 84: Root + empty inline table = 2 nodes
    5,      // Test 85: Root + outer (middle (inner + value)) = 5 nodes
    4,      // Test 86: Root + point inline table (2 children with whitespace) = 4 nodes
    3,      // Test 87: Root + data inline table (1 child) = 3 nodes
    0,      // Test 88: Parse error - no nodes
    0,      // Test 89: Parse error - no nodes
    0,      // Test 90: Parse error - no nodes
    0       // Test 91: Parse error - no nodes
}

constant integer TOML_PARSE_EXPECTED_ROOT_CHILD_COUNT[] = {
    0,      // Test 1
    1,      // Test 2
    3,      // Test 3
    4,      // Test 4
    4,      // Test 5
    2,      // Test 6
    3,      // Test 7
    1,      // Test 8
    1,      // Test 9
    1,      // Test 10
    2,      // Test 11
    1,      // Test 12
    1,      // Test 13
    1,      // Test 14
    5,      // Test 15
    2,      // Test 16
    2,      // Test 17
    2,      // Test 18
    1,      // Test 19
    1,      // Test 20
    1,      // Test 21
    1,      // Test 22
    1,      // Test 23
    1,      // Test 24
    1,      // Test 25
    1,      // Test 26
    1,      // Test 27
    3,      // Test 28
    1,      // Test 29
    5,      // Test 30
    3,      // Test 31
    4,      // Test 32
    1,      // Test 33
    2,      // Test 34
    1,      // Test 35
    1,      // Test 36
    1,      // Test 37
    1,      // Test 38
    2,      // Test 39
    1,      // Test 40
    1,      // Test 41
    1,      // Test 42
    1,      // Test 43
    1,      // Test 44
    2,      // Test 45
    1,      // Test 46
    3,      // Test 47
    7,      // Test 48: Root has 7 children (escape sequences)
    1,      // Test 49
    7,      // Test 50
    2,      // Test 51: Root has 2 children (Unicode escapes)
    2,      // Test 52: Root has 2 children (Unicode escapes)
    0,      // Test 53: Parse error
    0,      // Test 54: Parse error
    0,      // Test 55: Parse error
    0,      // Test 56: Parse error
    0,      // Test 57: Parse error
    0,      // Test 58: Parse error
    0,      // Test 59: Parse error
    1,      // Test 60: Root has 1 child (nested array)
    0,      // Test 61: Parse error
    0,      // Test 62: Parse error
    0,      // Test 63: Parse error
    0,      // Test 64: Parse error
    1,      // Test 65: Root has 1 child (time)
    1,      // Test 66: Root has 1 child (datetime)
    1,      // Test 67: Root has 1 child (datetime with Z)
    1,      // Test 68: Root has 1 child (datetime with offset)
    1,      // Test 69: Root has 1 child (datetime with space)
    4,      // Test 70: Root has 4 children (4 datetime values)
    1,      // Test 71: point
    1,      // Test 72: data
    1,      // Test 73: obj
    1,      // Test 74: outer
    1,      // Test 75: config
    1,      // Test 76: items
    1,      // Test 77: empty
    1,      // Test 78: mixed
    1,      // Test 79: simple
    1,      // Test 80: deep
    2,      // Test 81: first, second
    1,      // Test 82: person
    0,      // Test 83: Parse error
    1,      // Test 84: empty
    1,      // Test 85: outer
    1,      // Test 86: point
    1,      // Test 87: data
    0,      // Test 88: Parse error
    0,      // Test 89: Parse error
    0,      // Test 90: Parse error
    0       // Test 91: Parse error
}


define_function InitializeTomlParseTestData() {
    // Test 1: Empty document
    TOML_PARSE_TEST[1] = ''

    // Test 2: Simple key-value
    TOML_PARSE_TEST[2] = 'name = "John Doe"'

    // Test 3: Multiple key-values
    TOML_PARSE_TEST[3] = "'name = "John"', 13, 10, 'age = 30', 13, 10, 'active = true', 13, 10"

    // Test 4: Integer types
    TOML_PARSE_TEST[4] = "'decimal = 123', 13, 10, 'hex = 0xDEADBEEF', 13, 10, 'octal = 0o755', 13, 10, 'binary = 0b11010110', 13, 10"

    // Test 5: Float types
    TOML_PARSE_TEST[5] = "'pi = 3.14159', 13, 10, 'exponent = 5e+22', 13, 10, 'infinity = inf', 13, 10, 'not_a_number = nan', 13, 10"

    // Test 6: Boolean values
    TOML_PARSE_TEST[6] = "'enabled = true', 13, 10, 'disabled = false', 13, 10"

    // Test 7: Date and time
    TOML_PARSE_TEST[7] = "'date = 1979-05-27', 13, 10, 'time = 07:32:00', 13, 10, 'datetime = 1979-05-27T07:32:00Z', 13, 10"

    // Test 8: Arrays
    TOML_PARSE_TEST[8] = 'numbers = [1, 2, 3, 4, 5]'

    // Test 9: Inline table
    TOML_PARSE_TEST[9] = 'point = { x = 10, y = 20 }'

    // Test 10: Table header
    TOML_PARSE_TEST[10] = "'[server]', 13, 10, 'host = "localhost"', 13, 10"

    // Test 11: Multiple tables
    TOML_PARSE_TEST[11] = "'[database]', 13, 10, 'server = "mysql"', 13, 10, '[cache]', 13, 10, 'server = "redis"', 13, 10"

    // Test 12: Nested tables
    TOML_PARSE_TEST[12] = "'[server]', 13, 10, 'host = "localhost"', 13, 10, '[server.database]', 13, 10, 'name = "mydb"', 13, 10, '[server.cache]', 13, 10, 'ttl = 300', 13, 10"

    // Test 13: Array of tables
    TOML_PARSE_TEST[13] = "'[[product]]', 13, 10, 'name = "Hammer"', 13, 10, 'sku = 738594937', 13, 10, '[[product]]', 13, 10, 'name = "Nail"', 13, 10, 'sku = 284758393', 13, 10"

    // Test 14: Dotted keys
    TOML_PARSE_TEST[14] = 'name.first = "Tom"'

    // Test 15: Mixed values
    TOML_PARSE_TEST[15] = "'title = "TOML Example"', 13, 10, 'version = 1', 13, 10, 'active = true', 13, 10, 'pi = 3.14', 13, 10, 'tags = ["config", "test"]', 13, 10"

    // Test 16: Complex nested structure
    TOML_PARSE_TEST[16] = "'[owner]', 13, 10, 'name = "Tom Preston-Werner"', 13, 10, 'dob = 1979-05-27T07:32:00-08:00', 13, 10, '[database]', 13, 10, 'server = "192.168.1.1"', 13, 10, 'ports = [8001, 8001, 8002]', 13, 10, '[database.connection]', 13, 10, 'max_connections = 5000', 13, 10, 'enabled = true', 13, 10"

    // Test 17: String escapes
    TOML_PARSE_TEST[17] = "'basic = "String with \n newline"', 13, 10, 'tab = "Contains \t tab"', 13, 10"

    // Test 18: Multiline strings
    TOML_PARSE_TEST[18] = "'multi1 = ', $22, $22, $22, 13, 10, 'This is', 13, 10, 'multiline', $22, $22, $22, 13, 10, 'multi2 = ', $27, $27, $27, 13, 10, 'Literal', 13, 10, 'multiline', $27, $27, $27, 13, 10"

    // Test 19: Comments
    TOML_PARSE_TEST[19] = "'# Comment line', 13, 10, 'key = "value"  # Inline comment', 13, 10"

    // Test 20: Empty array
    TOML_PARSE_TEST[20] = 'empty = []'

    // Test 21: Empty inline table
    TOML_PARSE_TEST[21] = 'empty_table = {}'

    // Test 22: Hexadecimal integer
    TOML_PARSE_TEST[22] = 'hex_color = 0xFF00FF'

    // Test 23: DateTime with timezone
    TOML_PARSE_TEST[23] = 'created_at = 1979-05-27T00:32:00-07:00'

    // Test 24: Array with trailing comma
    TOML_PARSE_TEST[24] = 'values = [1, 2, 3,]'

    // Test 25: Integer with underscores
    TOML_PARSE_TEST[25] = 'large_number = 1_000_000'

    // Test 26: Nested arrays
    TOML_PARSE_TEST[26] = 'matrix = [[1, 2], [3, 4]]'

    // Test 27: Multiple array of tables
    TOML_PARSE_TEST[27] = "'[[fruit]]', 13, 10, 'name = "apple"', 13, 10, '[[fruit]]', 13, 10, 'name = "banana"', 13, 10, '[[fruit]]', 13, 10, 'name = "cherry"', 13, 10"

    // Test 28: Inf and NaN
    TOML_PARSE_TEST[28] = "'pos_inf = inf', 13, 10, 'neg_inf = -inf', 13, 10, 'not_num = nan', 13, 10"

    // Test 29: Literal strings
    TOML_PARSE_TEST[29] = "'path = ''C:\Windows\System32'''"

    // Test 30: Complex document
    TOML_PARSE_TEST[30] = "'title = "Configuration File"', 13, 10, 'version = 1', 13, 10, '[server]', 13, 10, 'host = "localhost"', 13, 10, 'port = 8080', 13, 10, '[[servers.alpha]]', 13, 10, 'ip = "10.0.0.1"', 13, 10, 'dc = "eqdc10"', 13, 10, '[[servers.alpha]]', 13, 10, 'ip = "10.0.0.2"', 13, 10, 'dc = "eqdc10"', 13, 10, '[database]', 13, 10, 'server = "192.168.1.1"', 13, 10, 'ports = [8001, 8002]', 13, 10, 'connection_max = 5000', 13, 10, 'enabled = true', 13, 10"

    // Test 31: Negative numbers
    TOML_PARSE_TEST[31] = "'neg_int = -42', 13, 10, 'neg_float = -3.14', 13, 10, 'neg_zero = -0', 13, 10"

    // Test 32: Zero values
    TOML_PARSE_TEST[32] = "'int_zero = 0', 13, 10, 'float_zero = 0.0', 13, 10, 'neg_zero_int = -0', 13, 10, 'neg_zero_float = -0.0', 13, 10"

    // Test 33: Mixed float representations (all floats, different notations)
    TOML_PARSE_TEST[33] = 'mixed = [1.0, 2.5, 3e2]'

    // Test 34: Empty strings
    TOML_PARSE_TEST[34] = "'empty_basic = ""', 13, 10, 'empty_literal = ''''', 13, 10"

    // Test 35: Multiline array
    TOML_PARSE_TEST[35] = "'nums = [', 13, 10, '  1,', 13, 10, '  2,', 13, 10, '  3', 13, 10, ']', 13, 10"

    // Test 36: Array of inline tables
    TOML_PARSE_TEST[36] = 'points = [{x = 1, y = 2}, {x = 3, y = 4}]'

    // Test 37: Nested inline tables
    TOML_PARSE_TEST[37] = 'nested = {outer = {inner = 42}}'

    // Test 38: Dotted keys in table
    TOML_PARSE_TEST[38] = "'[section]', 13, 10, 'a.b = 1', 13, 10, 'a.c = 2', 13, 10"

    // Test 39: Quoted keys
    TOML_PARSE_TEST[39] = "'"key with spaces" = "value1"', 13, 10, '"special@key" = "value2"', 13, 10"

    // Test 40: Local datetime
    TOML_PARSE_TEST[40] = 'local_dt = 1979-05-27T07:32:00'

    // Test 41: Datetime with fractional seconds
    TOML_PARSE_TEST[41] = 'precise_dt = 1979-05-27T00:32:00.999999-07:00'

    // Test 42: Multiline string with escapes
    TOML_PARSE_TEST[42] = "'text = ', $22, $22, $22, 13, 10, 'Line 1\nLine 2', 13, 10, $22, $22, $22, 13, 10"

    // Test 43: Line-ending backslash
    TOML_PARSE_TEST[43] = "'str = ', $22, $22, $22, 'The quick \', 13, 10, '     brown fox', $22, $22, $22, 13, 10"

    // Test 44: Multiple array tables same level
    TOML_PARSE_TEST[44] = "'[[items]]', 13, 10, 'id = 1', 13, 10, 'name = "first"', 13, 10, '[[items]]', 13, 10, 'id = 2', 13, 10, 'name = "second"', 13, 10, '[[items]]', 13, 10, 'id = 3', 13, 10, 'name = "third"', 13, 10"

    // Test 45: Table after array of tables
    TOML_PARSE_TEST[45] = "'[[products]]', 13, 10, 'name = "Widget"', 13, 10, '[shipping]', 13, 10, 'weight = 10', 13, 10"

    // Test 46: Deeply nested tables
    TOML_PARSE_TEST[46] = "'[a.b.c.d.e]', 13, 10, 'value = 42', 13, 10"

    // Test 47: Whitespace handling
    TOML_PARSE_TEST[47] = "'  key1  =  ', $22, 'value1', $22, '  ', 13, 10, 'key2=', $22, 'value2', $22, 13, 10, '    key3    =    ', $22, 'value3', $22, '    ', 13, 10"

    // Test 48: All escape sequences
    TOML_PARSE_TEST[48] = "'tab = ', $22, $5C, 't', $22, 13, 10, 'newln = ', $22, $5C, 'n', $22, 13, 10, 'cr = ', $22, $5C, 'r', $22, 13, 10, 'quote = ', $22, $5C, $22, $22, 13, 10, 'backslash = ', $22, $5C, $5C, $22, 13, 10, 'backspace = ', $22, $5C, 'b', $22, 13, 10, 'formfeed = ', $22, $5C, 'f', $22, 13, 10"

    // Test 49: Complex array structures
    TOML_PARSE_TEST[49] = 'nested = [[[1]], [[2, 3]], [[4], [5, 6]]]'

    // Test 50: Edge case combinations
    TOML_PARSE_TEST[50] = "'empty_str = ""', 13, 10, 'empty_arr = []', 13, 10, 'empty_tbl = {}', 13, 10, 'zero = 0', 13, 10, 'neg = -1', 13, 10, 'inf_val = inf', 13, 10, 'nan_val = nan', 13, 10"

    // Test 51: Unicode escape sequences (\uXXXX) - 4-digit hex
    TOML_PARSE_TEST[51] = "'unicode_upper = ', $22, '\u0041\u0042\u0043', $22, 13, 10, 'unicode_symbol = ', $22, '\u0022\u0027', $22, 13, 10"

    // Test 52: Unicode escape sequences (\UXXXXXXXX) - 8-digit hex
    TOML_PARSE_TEST[52] = "'emoji = ', $22, '\U0001F600', $22, 13, 10, 'unicode_char = ', $22, '\U00000041', $22, 13, 10"

    // Test 53: Invalid - duplicate key in same table
    TOML_PARSE_TEST[53] = "'name = ', $22, 'first', $22, 13, 10, 'name = ', $22, 'second', $22, 13, 10"

    // Test 54: Invalid - duplicate key in nested table
    TOML_PARSE_TEST[54] = "'[database]', 13, 10, 'host = ', $22, 'localhost', $22, 13, 10, 'host = ', $22, '127.0.0.1', $22, 13, 10"

    // Test 55: Invalid - table defined after array of tables (same name)
    TOML_PARSE_TEST[55] = "'[[products]]', 13, 10, 'name = ', $22, 'Widget', $22, 13, 10, '[products]', 13, 10, 'count = 1', 13, 10"

    // Test 56: Invalid - redefining existing key as table
    TOML_PARSE_TEST[56] = "'config = ', $22, 'value', $22, 13, 10, '[config]', 13, 10, 'setting = 1', 13, 10"

    // Test 57: Invalid - mixed type array (integer and string)
    TOML_PARSE_TEST[57] = 'mixed = [1, "string", 3]'

    // Test 58: Invalid - mixed type array (integer and float)
    TOML_PARSE_TEST[58] = 'numbers = [1, 2.5, 3]'

    // Test 59: Invalid - mixed type array (boolean and integer)
    TOML_PARSE_TEST[59] = 'values = [true, 1, false]'

    // Test 60: Valid - nested homogeneous arrays
    TOML_PARSE_TEST[60] = 'nested = [[1, 2], [3, 4]]'

    // Test 61: Invalid - nested array with mixed types
    TOML_PARSE_TEST[61] = 'invalid = ["a", 1]'

    // Test 62: Invalid - outer array containing invalid inner array
    TOML_PARSE_TEST[62] = 'invalid = [[1, 2], ["a", 1]]'

    // Test 63: Invalid - first nested array has mixed types
    TOML_PARSE_TEST[63] = 'invalid = [[1, "2"], ["a", "b"]]'

    // Test 64: Invalid - mixing array with non-array type
    TOML_PARSE_TEST[64] = 'invalid = [[1, 2], "3"]'

    // Test 65: TOML 1.1.0 - Local time without seconds
    TOML_PARSE_TEST[65] = 'time = 14:15'

    // Test 66: TOML 1.1.0 - Local datetime without seconds
    TOML_PARSE_TEST[66] = 'dt = 2010-02-03T14:15'

    // Test 67: TOML 1.1.0 - Offset datetime without seconds with Z
    TOML_PARSE_TEST[67] = 'dt = 2010-02-03T14:15Z'

    // Test 68: TOML 1.1.0 - Offset datetime without seconds with timezone
    TOML_PARSE_TEST[68] = 'dt = 2010-02-03T14:15-08:00'

    // Test 69: TOML 1.1.0 - Local datetime with space separator, no seconds
    TOML_PARSE_TEST[69] = 'dt = 2010-02-03 14:15'

    // Test 70: TOML 1.1.0 - Multiple datetime values with and without seconds
    TOML_PARSE_TEST[70] = "'with_sec = 07:32:00', 13, 10, 'without_sec = 14:15', 13, 10, 'dt_with = 2010-02-03T14:15:30', 13, 10, 'dt_without = 2010-02-03T14:15', 13, 10"

    // Test 71: TOML 1.1.0 - Basic multiline inline table
    TOML_PARSE_TEST[71] = "'point = {', 13, 10, '  x = 10,', 13, 10, '  y = 20', 13, 10, '}'"

    // Test 72: TOML 1.1.0 - Trailing comma before closing brace
    TOML_PARSE_TEST[72] = 'data = { a = 1, b = 2, }'

    // Test 73: TOML 1.1.0 - Multiline with trailing comma
    TOML_PARSE_TEST[73] = "'obj = {', 13, 10, '  key = "value",', 13, 10, '}'"

    // Test 74: TOML 1.1.0 - Nested inline tables with newlines
    TOML_PARSE_TEST[74] = "'outer = {', 13, 10, '  inner = { a = 1, b = 2 },', 13, 10, '  value = 42', 13, 10, '}'"

    // Test 75: TOML 1.1.0 - Multiple key-value pairs multiline
    TOML_PARSE_TEST[75] = "'config = {', 13, 10, '  host = "localhost",', 13, 10, '  port = 8080,', 13, 10, '  ssl = true,', 13, 10, '}'"

    // Test 76: TOML 1.1.0 - Inline table with newlines in array
    TOML_PARSE_TEST[76] = "'items = [', 13, 10, '  {', 13, 10, '    name = "first",', 13, 10, '    value = 1', 13, 10, '  },', 13, 10, '  { name = "second", value = 2 }', 13, 10, ']'"

    // Test 77: TOML 1.1.0 - Empty inline table multiline format
    TOML_PARSE_TEST[77] = "'empty = {', 13, 10, '}'"

    // Test 78: TOML 1.1.0 - Inline table with mixed types and newlines
    TOML_PARSE_TEST[78] = "'mixed = {', 13, 10, '  str = "text",', 13, 10, '  num = 123,', 13, 10, '  bool = false,', 13, 10, '  arr = [1, 2, 3],', 13, 10, '}'"

    // Test 79: TOML 1.1.0 - Single line with trailing comma
    TOML_PARSE_TEST[79] = 'simple = { x = 1, }'

    // Test 80: TOML 1.1.0 - Deeply nested multiline inline tables
    TOML_PARSE_TEST[80] = "'deep = {', 13, 10, '  level1 = {', 13, 10, '    level2 = { value = 42 },', 13, 10, '  },', 13, 10, '}'"

    // Test 81: TOML 1.1.0 - Multiple inline tables in same document with newlines
    TOML_PARSE_TEST[81] = "'first = {', 13, 10, '  a = 1,', 13, 10, '}', 13, 10, 'second = { b = 2, }'"

    // Test 82: TOML 1.1.0 - Inline table with various value types and trailing comma
    TOML_PARSE_TEST[82] = "'person = {', 13, 10, '  name = "Alice",', 13, 10, '  age = 30,', 13, 10, '  email = "alice@example.com",', 13, 10, '}'"

    // ===== Multiline Inline Table Edge Cases =====
    // Test 83: Invalid - Multiple consecutive commas (should fail)
    TOML_PARSE_TEST[83] = 'point = { x = 1,, y = 2 }'

    // Test 84: Empty multiline inline table with whitespace
    TOML_PARSE_TEST[84] = "'empty = {', 13, 10, 13, 10, '}'"

    // Test 85: Very deeply nested multiline inline tables
    TOML_PARSE_TEST[85] = "'outer = {', 13, 10, '  middle = {', 13, 10, '    inner = {', 13, 10, '      value = 42,', 13, 10, '    },', 13, 10, '  },', 13, 10, '}'"

    // Test 86: Multiline inline table with excessive whitespace
    TOML_PARSE_TEST[86] = "'point = {', 13, 10, 13, 10, 13, 10, '  x = 1,', 13, 10, 13, 10, 13, 10, '  y = 2,', 13, 10, 13, 10, '}'"

    // Test 87: Trailing comma with newline before closing brace
    TOML_PARSE_TEST[87] = "'data = {', 13, 10, '  value = 123,', 13, 10, '}'"

    // Test 88: Invalid - Comment inside inline table (spec doesn't allow)
    TOML_PARSE_TEST[88] = "'point = {', 13, 10, '  x = 1, # X coordinate', 13, 10, '  y = 2', 13, 10, '}'"

    // ===== Optional Seconds Boundary Cases =====
    // Test 89: Invalid - Time without seconds but hour out of range
    TOML_PARSE_TEST[89] = 'time = 25:30'

    // Test 90: Invalid - Time without seconds but minute out of range
    TOML_PARSE_TEST[90] = 'time = 12:99'

    // Test 91: Invalid - Fractional seconds without seconds field
    TOML_PARSE_TEST[91] = 'time = 12:34.123'

    set_length_array(TOML_PARSE_TEST, 91)
}


define_function InitializeExpectedNodes() {
    // Test 1: Empty document
    // Node 1: root table (empty)
    TOML_PARSE_EXPECTED_NODES[1][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[1][1].childCount = 0

    // Test 2: Simple key-value: name = "John Doe"
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[2][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[2][1].childCount = 1
    // Node 2: name = "John Doe"
    TOML_PARSE_EXPECTED_NODES[2][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[2][2].key = 'name'
    TOML_PARSE_EXPECTED_NODES[2][2].value = 'John Doe'
    TOML_PARSE_EXPECTED_NODES[2][2].subtype = NAV_TOML_SUBTYPE_STRING_BASIC

    // Test 3: Multiple key-values
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[3][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[3][1].childCount = 3
    // Node 2: name = "John"
    TOML_PARSE_EXPECTED_NODES[3][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[3][2].key = 'name'
    TOML_PARSE_EXPECTED_NODES[3][2].value = 'John'
    TOML_PARSE_EXPECTED_NODES[3][2].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 3: age = 30
    TOML_PARSE_EXPECTED_NODES[3][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[3][3].key = 'age'
    TOML_PARSE_EXPECTED_NODES[3][3].value = '30'
    TOML_PARSE_EXPECTED_NODES[3][3].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 4: active = true
    TOML_PARSE_EXPECTED_NODES[3][4].type = NAV_TOML_NODE_TYPE_BOOLEAN
    TOML_PARSE_EXPECTED_NODES[3][4].key = 'active'
    TOML_PARSE_EXPECTED_NODES[3][4].value = 'true'
    TOML_PARSE_EXPECTED_NODES[3][4].subtype = NAV_TOML_SUBTYPE_TRUE

    // Test 4: Integer types
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[4][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[4][1].childCount = 4
    // Node 2: decimal = 123
    TOML_PARSE_EXPECTED_NODES[4][2].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[4][2].key = 'decimal'
    TOML_PARSE_EXPECTED_NODES[4][2].value = '123'
    TOML_PARSE_EXPECTED_NODES[4][2].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 3: hex = 0xDEADBEEF
    TOML_PARSE_EXPECTED_NODES[4][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[4][3].key = 'hex'
    TOML_PARSE_EXPECTED_NODES[4][3].value = '0xDEADBEEF'
    TOML_PARSE_EXPECTED_NODES[4][3].subtype = NAV_TOML_SUBTYPE_HEXADECIMAL
    // Node 4: octal = 0o755
    TOML_PARSE_EXPECTED_NODES[4][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[4][4].key = 'octal'
    TOML_PARSE_EXPECTED_NODES[4][4].value = '0o755'
    TOML_PARSE_EXPECTED_NODES[4][4].subtype = NAV_TOML_SUBTYPE_OCTAL
    // Node 5: binary = 0b11010110
    TOML_PARSE_EXPECTED_NODES[4][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[4][5].key = 'binary'
    TOML_PARSE_EXPECTED_NODES[4][5].value = '0b11010110'
    TOML_PARSE_EXPECTED_NODES[4][5].subtype = NAV_TOML_SUBTYPE_BINARY

    // Test 5: Float types
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[5][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[5][1].childCount = 4
    // Node 2: pi = 3.14159
    TOML_PARSE_EXPECTED_NODES[5][2].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[5][2].key = 'pi'
    TOML_PARSE_EXPECTED_NODES[5][2].value = '3.14159'
    TOML_PARSE_EXPECTED_NODES[5][2].subtype = NAV_TOML_SUBTYPE_FLOAT_NORMAL
    // Node 3: exponent = 5e+22
    TOML_PARSE_EXPECTED_NODES[5][3].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[5][3].key = 'exponent'
    TOML_PARSE_EXPECTED_NODES[5][3].value = '5e+22'
    TOML_PARSE_EXPECTED_NODES[5][3].subtype = NAV_TOML_SUBTYPE_FLOAT_NORMAL
    // Node 4: infinity = inf
    TOML_PARSE_EXPECTED_NODES[5][4].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[5][4].key = 'infinity'
    TOML_PARSE_EXPECTED_NODES[5][4].value = 'inf'
    TOML_PARSE_EXPECTED_NODES[5][4].subtype = NAV_TOML_SUBTYPE_FLOAT_INF
    // Node 5: not_a_number = nan
    TOML_PARSE_EXPECTED_NODES[5][5].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[5][5].key = 'not_a_number'
    TOML_PARSE_EXPECTED_NODES[5][5].value = 'nan'
    TOML_PARSE_EXPECTED_NODES[5][5].subtype = NAV_TOML_SUBTYPE_FLOAT_NAN

    // Test 6: Boolean values
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[6][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[6][1].childCount = 2
    // Node 2: enabled = true
    TOML_PARSE_EXPECTED_NODES[6][2].type = NAV_TOML_NODE_TYPE_BOOLEAN
    TOML_PARSE_EXPECTED_NODES[6][2].key = 'enabled'
    TOML_PARSE_EXPECTED_NODES[6][2].value = 'true'
    TOML_PARSE_EXPECTED_NODES[6][2].subtype = NAV_TOML_SUBTYPE_TRUE
    // Node 3: disabled = false
    TOML_PARSE_EXPECTED_NODES[6][3].type = NAV_TOML_NODE_TYPE_BOOLEAN
    TOML_PARSE_EXPECTED_NODES[6][3].key = 'disabled'
    TOML_PARSE_EXPECTED_NODES[6][3].value = 'false'
    TOML_PARSE_EXPECTED_NODES[6][3].subtype = NAV_TOML_SUBTYPE_FALSE

    // Test 7: Date and time
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[7][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[7][1].childCount = 3
    // Node 2: date = 1979-05-27
    TOML_PARSE_EXPECTED_NODES[7][2].type = NAV_TOML_NODE_TYPE_DATE
    TOML_PARSE_EXPECTED_NODES[7][2].key = 'date'
    TOML_PARSE_EXPECTED_NODES[7][2].value = '1979-05-27'
    // Node 3: time = 07:32:00
    TOML_PARSE_EXPECTED_NODES[7][3].type = NAV_TOML_NODE_TYPE_TIME
    TOML_PARSE_EXPECTED_NODES[7][3].key = 'time'
    TOML_PARSE_EXPECTED_NODES[7][3].value = '07:32:00'
    // Node 4: datetime = 1979-05-27T07:32:00Z
    TOML_PARSE_EXPECTED_NODES[7][4].type = NAV_TOML_NODE_TYPE_DATETIME
    TOML_PARSE_EXPECTED_NODES[7][4].key = 'datetime'
    TOML_PARSE_EXPECTED_NODES[7][4].value = '1979-05-27T07:32:00Z'

    // Test 8: Arrays - numbers = [1, 2, 3, 4, 5]
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[8][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[8][1].childCount = 1
    // Node 2: numbers array
    TOML_PARSE_EXPECTED_NODES[8][2].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[8][2].key = 'numbers'
    TOML_PARSE_EXPECTED_NODES[8][2].childCount = 5
    // Node 3: 1 (array element)
    TOML_PARSE_EXPECTED_NODES[8][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[8][3].value = '1'    // Node 4: 2
    TOML_PARSE_EXPECTED_NODES[8][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[8][4].value = '2'
    // Node 5: 3
    TOML_PARSE_EXPECTED_NODES[8][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[8][5].value = '3'
    // Node 6: 4
    TOML_PARSE_EXPECTED_NODES[8][6].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[8][6].value = '4'
    // Node 7: 5
    TOML_PARSE_EXPECTED_NODES[8][7].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[8][7].value = '5'
    // Test 9: Inline table - point = { x = 10, y = 20 }
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[9][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[9][1].childCount = 1
    // Node 2: point inline table
    TOML_PARSE_EXPECTED_NODES[9][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[9][2].key = 'point'
    TOML_PARSE_EXPECTED_NODES[9][2].childCount = 2
    // Node 3: x = 10
    TOML_PARSE_EXPECTED_NODES[9][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[9][3].key = 'x'
    TOML_PARSE_EXPECTED_NODES[9][3].value = '10'
    // Node 4: y = 20
    TOML_PARSE_EXPECTED_NODES[9][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[9][4].key = 'y'
    TOML_PARSE_EXPECTED_NODES[9][4].value = '20'

    // Test 10: Table header - [server] host = "localhost"
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[10][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[10][1].childCount = 1
    // Node 2: server table
    TOML_PARSE_EXPECTED_NODES[10][2].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[10][2].key = 'server'
    TOML_PARSE_EXPECTED_NODES[10][2].childCount = 1
    // Node 3: host = "localhost"
    TOML_PARSE_EXPECTED_NODES[10][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[10][3].key = 'host'
    TOML_PARSE_EXPECTED_NODES[10][3].value = 'localhost'

    // Test 11: Multiple tables
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[11][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[11][1].childCount = 2
    // Node 2: database table
    TOML_PARSE_EXPECTED_NODES[11][2].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[11][2].key = 'database'
    TOML_PARSE_EXPECTED_NODES[11][2].childCount = 1
    // Node 3: server = "mysql"
    TOML_PARSE_EXPECTED_NODES[11][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[11][3].key = 'server'
    TOML_PARSE_EXPECTED_NODES[11][3].value = 'mysql'
    // Node 4: cache table
    TOML_PARSE_EXPECTED_NODES[11][4].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[11][4].key = 'cache'
    TOML_PARSE_EXPECTED_NODES[11][4].childCount = 1
    // Node 5: server = "redis"
    TOML_PARSE_EXPECTED_NODES[11][5].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[11][5].key = 'server'
    TOML_PARSE_EXPECTED_NODES[11][5].value = 'redis'

    // Test 12: Nested tables
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[12][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[12][1].childCount = 1
    // Node 2: server table
    TOML_PARSE_EXPECTED_NODES[12][2].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[12][2].key = 'server'
    TOML_PARSE_EXPECTED_NODES[12][2].childCount = 3
    // Node 3: host = "localhost"
    TOML_PARSE_EXPECTED_NODES[12][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[12][3].key = 'host'
    TOML_PARSE_EXPECTED_NODES[12][3].value = 'localhost'
    // Node 4: server.database table
    TOML_PARSE_EXPECTED_NODES[12][4].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[12][4].key = 'database'
    TOML_PARSE_EXPECTED_NODES[12][4].childCount = 1
    // Node 5: name = "mydb"
    TOML_PARSE_EXPECTED_NODES[12][5].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[12][5].key = 'name'
    TOML_PARSE_EXPECTED_NODES[12][5].value = 'mydb'
    // Node 6: server.cache table
    TOML_PARSE_EXPECTED_NODES[12][6].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[12][6].key = 'cache'
    TOML_PARSE_EXPECTED_NODES[12][6].childCount = 1
    // Node 7: ttl = 300
    TOML_PARSE_EXPECTED_NODES[12][7].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[12][7].key = 'ttl'
    TOML_PARSE_EXPECTED_NODES[12][7].value = '300'

    // Test 13: Array of tables [[product]]
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[13][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[13][1].childCount = 1
    // Node 2: product array
    TOML_PARSE_EXPECTED_NODES[13][2].type = NAV_TOML_NODE_TYPE_TABLE_ARRAY
    TOML_PARSE_EXPECTED_NODES[13][2].key = 'product'
    TOML_PARSE_EXPECTED_NODES[13][2].childCount = 2
    // Node 3: first product table
    TOML_PARSE_EXPECTED_NODES[13][3].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[13][3].childCount = 2
    // Node 4: name = "Hammer"
    TOML_PARSE_EXPECTED_NODES[13][4].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[13][4].key = 'name'
    TOML_PARSE_EXPECTED_NODES[13][4].value = 'Hammer'
    // Node 5: sku = 738594937
    TOML_PARSE_EXPECTED_NODES[13][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[13][5].key = 'sku'
    TOML_PARSE_EXPECTED_NODES[13][5].value = '738594937'
    // Node 6: second product table
    TOML_PARSE_EXPECTED_NODES[13][6].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[13][6].childCount = 2
    // Node 7: name = "Nail"
    TOML_PARSE_EXPECTED_NODES[13][7].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[13][7].key = 'name'
    TOML_PARSE_EXPECTED_NODES[13][7].value = 'Nail'
    // Node 8: sku = 284758393
    TOML_PARSE_EXPECTED_NODES[13][8].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[13][8].key = 'sku'
    TOML_PARSE_EXPECTED_NODES[13][8].value = '284758393'

    // Test 14: Dotted keys - name.first = "Tom"
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[14][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[14][1].childCount = 1
    // Node 2: name implicit table
    TOML_PARSE_EXPECTED_NODES[14][2].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[14][2].key = 'name'
    TOML_PARSE_EXPECTED_NODES[14][2].childCount = 1
    // Node 3: first = "Tom"
    TOML_PARSE_EXPECTED_NODES[14][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[14][3].key = 'first'
    TOML_PARSE_EXPECTED_NODES[14][3].value = 'Tom'

    // Test 15: Mixed values
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[15][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[15][1].childCount = 5
    // Node 2: title = "TOML Example"
    TOML_PARSE_EXPECTED_NODES[15][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[15][2].key = 'title'
    TOML_PARSE_EXPECTED_NODES[15][2].value = 'TOML Example'
    TOML_PARSE_EXPECTED_NODES[15][2].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 3: version = 1
    TOML_PARSE_EXPECTED_NODES[15][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[15][3].key = 'version'
    TOML_PARSE_EXPECTED_NODES[15][3].value = '1'
    TOML_PARSE_EXPECTED_NODES[15][3].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 4: active = true
    TOML_PARSE_EXPECTED_NODES[15][4].type = NAV_TOML_NODE_TYPE_BOOLEAN
    TOML_PARSE_EXPECTED_NODES[15][4].key = 'active'
    TOML_PARSE_EXPECTED_NODES[15][4].value = 'true'
    TOML_PARSE_EXPECTED_NODES[15][4].subtype = NAV_TOML_SUBTYPE_TRUE
    // Node 5: pi = 3.14
    TOML_PARSE_EXPECTED_NODES[15][5].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[15][5].key = 'pi'
    TOML_PARSE_EXPECTED_NODES[15][5].value = '3.14'
    TOML_PARSE_EXPECTED_NODES[15][5].subtype = NAV_TOML_SUBTYPE_FLOAT_NORMAL
    // Node 6: tags array
    TOML_PARSE_EXPECTED_NODES[15][6].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[15][6].key = 'tags'
    TOML_PARSE_EXPECTED_NODES[15][6].childCount = 2
    // Node 7: "config"
    TOML_PARSE_EXPECTED_NODES[15][7].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[15][7].value = 'config'
    TOML_PARSE_EXPECTED_NODES[15][7].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 8: "test"
    TOML_PARSE_EXPECTED_NODES[15][8].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[15][8].value = 'test'
    TOML_PARSE_EXPECTED_NODES[15][8].subtype = NAV_TOML_SUBTYPE_STRING_BASIC

    // Test 16: Complex nested structure (simplified - just validate root structure)
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[16][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[16][1].childCount = 2
    // Node 2: owner table
    TOML_PARSE_EXPECTED_NODES[16][2].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[16][2].key = 'owner'
    TOML_PARSE_EXPECTED_NODES[16][2].childCount = 2
    // Node 3: name = "Tom Preston-Werner"
    TOML_PARSE_EXPECTED_NODES[16][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[16][3].key = 'name'
    TOML_PARSE_EXPECTED_NODES[16][3].value = 'Tom Preston-Werner'
    TOML_PARSE_EXPECTED_NODES[16][3].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 4: dob datetime
    TOML_PARSE_EXPECTED_NODES[16][4].type = NAV_TOML_NODE_TYPE_DATETIME
    TOML_PARSE_EXPECTED_NODES[16][4].key = 'dob'
    TOML_PARSE_EXPECTED_NODES[16][4].value = '1979-05-27T07:32:00-08:00'
    // Node 5: database table
    TOML_PARSE_EXPECTED_NODES[16][5].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[16][5].key = 'database'
    TOML_PARSE_EXPECTED_NODES[16][5].childCount = 3
    // Node 6: server = "192.168.1.1"
    TOML_PARSE_EXPECTED_NODES[16][6].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[16][6].key = 'server'
    TOML_PARSE_EXPECTED_NODES[16][6].value = '192.168.1.1'
    TOML_PARSE_EXPECTED_NODES[16][6].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 7: ports array
    TOML_PARSE_EXPECTED_NODES[16][7].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[16][7].key = 'ports'
    TOML_PARSE_EXPECTED_NODES[16][7].childCount = 3
    // Node 8: 8001
    TOML_PARSE_EXPECTED_NODES[16][8].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[16][8].value = '8001'
    TOML_PARSE_EXPECTED_NODES[16][8].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 9: 8001
    TOML_PARSE_EXPECTED_NODES[16][9].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[16][9].value = '8001'
    TOML_PARSE_EXPECTED_NODES[16][9].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 10: 8002
    TOML_PARSE_EXPECTED_NODES[16][10].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[16][10].value = '8002'
    TOML_PARSE_EXPECTED_NODES[16][10].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 11: connection table
    TOML_PARSE_EXPECTED_NODES[16][11].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[16][11].key = 'connection'
    TOML_PARSE_EXPECTED_NODES[16][11].childCount = 2
    // Node 12: max_connections = 5000
    TOML_PARSE_EXPECTED_NODES[16][12].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[16][12].key = 'max_connections'
    TOML_PARSE_EXPECTED_NODES[16][12].value = '5000'
    TOML_PARSE_EXPECTED_NODES[16][12].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 13: enabled = true
    TOML_PARSE_EXPECTED_NODES[16][13].type = NAV_TOML_NODE_TYPE_BOOLEAN
    TOML_PARSE_EXPECTED_NODES[16][13].key = 'enabled'
    TOML_PARSE_EXPECTED_NODES[16][13].value = 'true'
    TOML_PARSE_EXPECTED_NODES[16][13].subtype = NAV_TOML_SUBTYPE_TRUE

    // Test 17: String escapes
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[17][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[17][1].childCount = 2
    // Node 2: basic string with newline
    TOML_PARSE_EXPECTED_NODES[17][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[17][2].key = 'basic'
    TOML_PARSE_EXPECTED_NODES[17][2].value = "'String with ', $0A, ' newline'"
    // Node 3: tab string with tab
    TOML_PARSE_EXPECTED_NODES[17][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[17][3].key = 'tab'
    TOML_PARSE_EXPECTED_NODES[17][3].value = "'Contains ', $09, ' tab'"

    // Test 18: Multiline strings
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[18][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[18][1].childCount = 2
    // Node 2: multi1 multiline string
    TOML_PARSE_EXPECTED_NODES[18][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[18][2].key = 'multi1'
    TOML_PARSE_EXPECTED_NODES[18][2].value = "'This is', $0D, $0A, 'multiline'"
    TOML_PARSE_EXPECTED_NODES[18][2].subtype = NAV_TOML_SUBTYPE_STRING_MULTILINE
    // Node 3: multi2 literal multiline
    TOML_PARSE_EXPECTED_NODES[18][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[18][3].key = 'multi2'
    TOML_PARSE_EXPECTED_NODES[18][3].value = "'Literal', $0D, $0A, 'multiline'"
    TOML_PARSE_EXPECTED_NODES[18][3].subtype = NAV_TOML_SUBTYPE_STRING_LITERAL_ML

    // Test 19: Comments - key = "value"  # Inline comment
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[19][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[19][1].childCount = 1
    // Node 2: key = "value"
    TOML_PARSE_EXPECTED_NODES[19][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[19][2].key = 'key'
    TOML_PARSE_EXPECTED_NODES[19][2].value = 'value'

    // Test 20: Empty array - empty = []
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[20][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[20][1].childCount = 1
    // Node 2: empty array
    TOML_PARSE_EXPECTED_NODES[20][2].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[20][2].key = 'empty'
    TOML_PARSE_EXPECTED_NODES[20][2].childCount = 0

    // Test 21: Empty inline table - empty_table = {}
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[21][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[21][1].childCount = 1
    // Node 2: empty_table inline table
    TOML_PARSE_EXPECTED_NODES[21][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[21][2].key = 'empty_table'
    TOML_PARSE_EXPECTED_NODES[21][2].childCount = 0

    // Test 22: Hexadecimal integer - hex_color = 0xFF00FF
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[22][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[22][1].childCount = 1
    // Node 2: hex_color = 0xFF00FF
    TOML_PARSE_EXPECTED_NODES[22][2].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[22][2].key = 'hex_color'
    TOML_PARSE_EXPECTED_NODES[22][2].value = '0xFF00FF'
    TOML_PARSE_EXPECTED_NODES[22][2].subtype = NAV_TOML_SUBTYPE_HEXADECIMAL

    // Test 23: DateTime with timezone
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[23][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[23][1].childCount = 1
    // Node 2: created_at = 1979-05-27T00:32:00-07:00
    TOML_PARSE_EXPECTED_NODES[23][2].type = NAV_TOML_NODE_TYPE_DATETIME
    TOML_PARSE_EXPECTED_NODES[23][2].key = 'created_at'
    TOML_PARSE_EXPECTED_NODES[23][2].value = '1979-05-27T00:32:00-07:00'

    // Test 24: Array with trailing comma - values = [1, 2, 3,]
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[24][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[24][1].childCount = 1
    // Node 2: values array
    TOML_PARSE_EXPECTED_NODES[24][2].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[24][2].key = 'values'
    TOML_PARSE_EXPECTED_NODES[24][2].childCount = 3
    // Node 3: 1
    TOML_PARSE_EXPECTED_NODES[24][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[24][3].value = '1'
    // Node 4: 2
    TOML_PARSE_EXPECTED_NODES[24][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[24][4].value = '2'
    // Node 5: 3
    TOML_PARSE_EXPECTED_NODES[24][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[24][5].value = '3'

    // Test 25: Integer with underscores - large_number = 1_000_000
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[25][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[25][1].childCount = 1
    // Node 2: large_number = 1_000_000
    TOML_PARSE_EXPECTED_NODES[25][2].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[25][2].key = 'large_number'
    TOML_PARSE_EXPECTED_NODES[25][2].value = '1000000'
    TOML_PARSE_EXPECTED_NODES[25][2].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Test 26: Nested arrays - matrix = [[1, 2], [3, 4]]
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[26][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[26][1].childCount = 1
    // Node 2: matrix array
    TOML_PARSE_EXPECTED_NODES[26][2].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[26][2].key = 'matrix'
    TOML_PARSE_EXPECTED_NODES[26][2].childCount = 2
    // Node 3: [1, 2] array
    TOML_PARSE_EXPECTED_NODES[26][3].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[26][3].childCount = 2
    // Node 4: 1
    TOML_PARSE_EXPECTED_NODES[26][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[26][4].value = '1'
    // Node 5: 2
    TOML_PARSE_EXPECTED_NODES[26][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[26][5].value = '2'
    // Node 6: [3, 4] array
    TOML_PARSE_EXPECTED_NODES[26][6].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[26][6].childCount = 2
    // Node 7: 3
    TOML_PARSE_EXPECTED_NODES[26][7].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[26][7].value = '3'
    // Node 8: 4
    TOML_PARSE_EXPECTED_NODES[26][8].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[26][8].value = '4'

    // Test 27: Multiple array of tables [[fruit]]
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[27][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[27][1].childCount = 1
    // Node 2: fruit array
    TOML_PARSE_EXPECTED_NODES[27][2].type = NAV_TOML_NODE_TYPE_TABLE_ARRAY
    TOML_PARSE_EXPECTED_NODES[27][2].key = 'fruit'
    TOML_PARSE_EXPECTED_NODES[27][2].childCount = 3
    // Node 3: first fruit table
    TOML_PARSE_EXPECTED_NODES[27][3].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[27][3].childCount = 1
    // Node 4: name = "apple"
    TOML_PARSE_EXPECTED_NODES[27][4].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[27][4].key = 'name'
    TOML_PARSE_EXPECTED_NODES[27][4].value = 'apple'
    // Node 5: second fruit table
    TOML_PARSE_EXPECTED_NODES[27][5].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[27][5].childCount = 1
    // Node 6: name = "banana"
    TOML_PARSE_EXPECTED_NODES[27][6].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[27][6].key = 'name'
    TOML_PARSE_EXPECTED_NODES[27][6].value = 'banana'
    // Node 7: third fruit table
    TOML_PARSE_EXPECTED_NODES[27][7].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[27][7].childCount = 1
    // Node 8: name = "cherry"
    TOML_PARSE_EXPECTED_NODES[27][8].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[27][8].key = 'name'
    TOML_PARSE_EXPECTED_NODES[27][8].value = 'cherry'

    // Test 28: Inf and NaN
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[28][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[28][1].childCount = 3
    // Node 2: pos_inf = inf
    TOML_PARSE_EXPECTED_NODES[28][2].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[28][2].key = 'pos_inf'
    TOML_PARSE_EXPECTED_NODES[28][2].value = 'inf'
    TOML_PARSE_EXPECTED_NODES[28][2].subtype = NAV_TOML_SUBTYPE_FLOAT_INF
    // Node 3: neg_inf = -inf
    TOML_PARSE_EXPECTED_NODES[28][3].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[28][3].key = 'neg_inf'
    TOML_PARSE_EXPECTED_NODES[28][3].value = '-inf'
    TOML_PARSE_EXPECTED_NODES[28][3].subtype = NAV_TOML_SUBTYPE_FLOAT_INF
    // Node 4: not_num = nan
    TOML_PARSE_EXPECTED_NODES[28][4].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[28][4].key = 'not_num'
    TOML_PARSE_EXPECTED_NODES[28][4].value = 'nan'
    TOML_PARSE_EXPECTED_NODES[28][4].subtype = NAV_TOML_SUBTYPE_FLOAT_NAN

    // Test 29: Literal strings - path = 'C:\Windows\System32'
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[29][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[29][1].childCount = 1
    // Node 2: path = C:\Windows\System32 (literal string quotes are stripped)
    TOML_PARSE_EXPECTED_NODES[29][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[29][2].key = 'path'
    TOML_PARSE_EXPECTED_NODES[29][2].value = 'C:\Windows\System32'

    // Test 30: Complex document
    // Node 1: root table
    TOML_PARSE_EXPECTED_NODES[30][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[30][1].childCount = 5
    // Node 2: title = "Configuration File"
    TOML_PARSE_EXPECTED_NODES[30][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[30][2].key = 'title'
    TOML_PARSE_EXPECTED_NODES[30][2].value = 'Configuration File'
    TOML_PARSE_EXPECTED_NODES[30][2].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 3: version = 1
    TOML_PARSE_EXPECTED_NODES[30][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[30][3].key = 'version'
    TOML_PARSE_EXPECTED_NODES[30][3].value = '1'
    TOML_PARSE_EXPECTED_NODES[30][3].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 4: server table
    TOML_PARSE_EXPECTED_NODES[30][4].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[30][4].key = 'server'
    TOML_PARSE_EXPECTED_NODES[30][4].childCount = 2
    // Node 5: host = "localhost"
    TOML_PARSE_EXPECTED_NODES[30][5].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[30][5].key = 'host'
    TOML_PARSE_EXPECTED_NODES[30][5].value = 'localhost'
    TOML_PARSE_EXPECTED_NODES[30][5].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 6: port = 8080
    TOML_PARSE_EXPECTED_NODES[30][6].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[30][6].key = 'port'
    TOML_PARSE_EXPECTED_NODES[30][6].value = '8080'
    TOML_PARSE_EXPECTED_NODES[30][6].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 7: servers table
    TOML_PARSE_EXPECTED_NODES[30][7].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[30][7].key = 'servers'
    TOML_PARSE_EXPECTED_NODES[30][7].childCount = 1
    // Node 8: servers.alpha array
    TOML_PARSE_EXPECTED_NODES[30][8].type = NAV_TOML_NODE_TYPE_TABLE_ARRAY
    TOML_PARSE_EXPECTED_NODES[30][8].key = 'alpha'
    TOML_PARSE_EXPECTED_NODES[30][8].childCount = 2
    // Node 9: first alpha table
    TOML_PARSE_EXPECTED_NODES[30][9].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[30][9].childCount = 2
    // Node 10: ip = "10.0.0.1"
    TOML_PARSE_EXPECTED_NODES[30][10].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[30][10].key = 'ip'
    TOML_PARSE_EXPECTED_NODES[30][10].value = '10.0.0.1'
    TOML_PARSE_EXPECTED_NODES[30][10].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 11: dc = "eqdc10"
    TOML_PARSE_EXPECTED_NODES[30][11].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[30][11].key = 'dc'
    TOML_PARSE_EXPECTED_NODES[30][11].value = 'eqdc10'
    TOML_PARSE_EXPECTED_NODES[30][11].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 12: second alpha table
    TOML_PARSE_EXPECTED_NODES[30][12].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[30][12].childCount = 2
    // Node 13: ip = "10.0.0.2"
    TOML_PARSE_EXPECTED_NODES[30][13].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[30][13].key = 'ip'
    TOML_PARSE_EXPECTED_NODES[30][13].value = '10.0.0.2'
    TOML_PARSE_EXPECTED_NODES[30][13].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 14: dc = "eqdc10"
    TOML_PARSE_EXPECTED_NODES[30][14].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[30][14].key = 'dc'
    TOML_PARSE_EXPECTED_NODES[30][14].value = 'eqdc10'
    TOML_PARSE_EXPECTED_NODES[30][14].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 15: database table
    TOML_PARSE_EXPECTED_NODES[30][15].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[30][15].key = 'database'
    TOML_PARSE_EXPECTED_NODES[30][15].childCount = 4
    // Node 16: server = "192.168.1.1"
    TOML_PARSE_EXPECTED_NODES[30][16].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[30][16].key = 'server'
    TOML_PARSE_EXPECTED_NODES[30][16].value = '192.168.1.1'
    TOML_PARSE_EXPECTED_NODES[30][16].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 17: ports array [8001, 8002]
    TOML_PARSE_EXPECTED_NODES[30][17].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[30][17].key = 'ports'
    TOML_PARSE_EXPECTED_NODES[30][17].childCount = 2
    // Node 18: 8001
    TOML_PARSE_EXPECTED_NODES[30][18].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[30][18].value = '8001'
    TOML_PARSE_EXPECTED_NODES[30][18].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 19: 8002
    TOML_PARSE_EXPECTED_NODES[30][19].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[30][19].value = '8002'
    TOML_PARSE_EXPECTED_NODES[30][19].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 20: connection_max = 5000
    TOML_PARSE_EXPECTED_NODES[30][20].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[30][20].key = 'connection_max'
    TOML_PARSE_EXPECTED_NODES[30][20].value = '5000'
    TOML_PARSE_EXPECTED_NODES[30][20].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 21: enabled = true
    TOML_PARSE_EXPECTED_NODES[30][21].type = NAV_TOML_NODE_TYPE_BOOLEAN
    TOML_PARSE_EXPECTED_NODES[30][21].key = 'enabled'
    TOML_PARSE_EXPECTED_NODES[30][21].value = 'true'
    TOML_PARSE_EXPECTED_NODES[30][21].subtype = NAV_TOML_SUBTYPE_TRUE

    // Test 31: Negative numbers
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[31][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[31][1].childCount = 3
    // Node 2: neg_int = -42
    TOML_PARSE_EXPECTED_NODES[31][2].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[31][2].key = 'neg_int'
    TOML_PARSE_EXPECTED_NODES[31][2].value = '-42'
    // Node 3: neg_float = -3.14
    TOML_PARSE_EXPECTED_NODES[31][3].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[31][3].key = 'neg_float'
    TOML_PARSE_EXPECTED_NODES[31][3].value = '-3.14'
    // Node 4: neg_zero = -0
    TOML_PARSE_EXPECTED_NODES[31][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[31][4].key = 'neg_zero'
    TOML_PARSE_EXPECTED_NODES[31][4].value = '-0'

    // Test 32: Zero values
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[32][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[32][1].childCount = 4
    // Node 2: int_zero = 0
    TOML_PARSE_EXPECTED_NODES[32][2].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[32][2].key = 'int_zero'
    TOML_PARSE_EXPECTED_NODES[32][2].value = '0'
    // Node 3: float_zero = 0.0
    TOML_PARSE_EXPECTED_NODES[32][3].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[32][3].key = 'float_zero'
    TOML_PARSE_EXPECTED_NODES[32][3].value = '0.0'
    // Node 4: neg_zero_int = -0
    TOML_PARSE_EXPECTED_NODES[32][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[32][4].key = 'neg_zero_int'
    TOML_PARSE_EXPECTED_NODES[32][4].value = '-0'
    // Node 5: neg_zero_float = -0.0
    TOML_PARSE_EXPECTED_NODES[32][5].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[32][5].key = 'neg_zero_float'
    TOML_PARSE_EXPECTED_NODES[32][5].value = '-0.0'

    // Test 33: Mixed float representations - mixed = [1.0, 2.5, 3e2]
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[33][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[33][1].childCount = 1
    // Node 2: mixed array
    TOML_PARSE_EXPECTED_NODES[33][2].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[33][2].key = 'mixed'
    TOML_PARSE_EXPECTED_NODES[33][2].childCount = 3
    // Node 3: 1.0
    TOML_PARSE_EXPECTED_NODES[33][3].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[33][3].value = '1.0'
    // Node 4: 2.5
    TOML_PARSE_EXPECTED_NODES[33][4].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[33][4].value = '2.5'
    // Node 5: 3e2 (preserved as-is, not normalized to 300)
    TOML_PARSE_EXPECTED_NODES[33][5].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[33][5].value = '3e2'

    // Test 34: Empty strings
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[34][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[34][1].childCount = 2
    // Node 2: empty_basic = ""
    TOML_PARSE_EXPECTED_NODES[34][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[34][2].key = 'empty_basic'
    TOML_PARSE_EXPECTED_NODES[34][2].value = ''
    // Node 3: empty_literal = ''
    TOML_PARSE_EXPECTED_NODES[34][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[34][3].key = 'empty_literal'
    TOML_PARSE_EXPECTED_NODES[34][3].value = ''

    // Test 35: Multiline array - nums = [1, 2, 3]
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[35][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[35][1].childCount = 1
    // Node 2: nums array
    TOML_PARSE_EXPECTED_NODES[35][2].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[35][2].key = 'nums'
    TOML_PARSE_EXPECTED_NODES[35][2].childCount = 3
    // Node 3: 1
    TOML_PARSE_EXPECTED_NODES[35][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[35][3].value = '1'
    // Node 4: 2
    TOML_PARSE_EXPECTED_NODES[35][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[35][4].value = '2'
    // Node 5: 3
    TOML_PARSE_EXPECTED_NODES[35][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[35][5].value = '3'

    // Test 36: Array of inline tables - points = [{x=1,y=2}, {x=3,y=4}]
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[36][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[36][1].childCount = 1
    // Node 2: points array
    TOML_PARSE_EXPECTED_NODES[36][2].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[36][2].key = 'points'
    TOML_PARSE_EXPECTED_NODES[36][2].childCount = 2
    // Node 3: first inline table {x=1, y=2}
    TOML_PARSE_EXPECTED_NODES[36][3].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[36][3].childCount = 2
    // Node 4: x = 1
    TOML_PARSE_EXPECTED_NODES[36][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[36][4].key = 'x'
    TOML_PARSE_EXPECTED_NODES[36][4].value = '1'
    // Node 5: y = 2
    TOML_PARSE_EXPECTED_NODES[36][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[36][5].key = 'y'
    TOML_PARSE_EXPECTED_NODES[36][5].value = '2'
    // Node 6: second inline table {x=3, y=4}
    TOML_PARSE_EXPECTED_NODES[36][6].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[36][6].childCount = 2
    // Node 7: x = 3
    TOML_PARSE_EXPECTED_NODES[36][7].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[36][7].key = 'x'
    TOML_PARSE_EXPECTED_NODES[36][7].value = '3'
    // Node 8: y = 4
    TOML_PARSE_EXPECTED_NODES[36][8].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[36][8].key = 'y'
    TOML_PARSE_EXPECTED_NODES[36][8].value = '4'

    // Test 37: Nested inline tables - nested = {outer = {inner = 42}}
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[37][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[37][1].childCount = 1
    // Node 2: nested inline table
    TOML_PARSE_EXPECTED_NODES[37][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[37][2].key = 'nested'
    TOML_PARSE_EXPECTED_NODES[37][2].childCount = 1
    // Node 3: outer inline table
    TOML_PARSE_EXPECTED_NODES[37][3].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[37][3].key = 'outer'
    TOML_PARSE_EXPECTED_NODES[37][3].childCount = 1
    // Node 4: inner = 42
    TOML_PARSE_EXPECTED_NODES[37][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[37][4].key = 'inner'
    TOML_PARSE_EXPECTED_NODES[37][4].value = '42'

    // Test 38: Dotted keys in table - [section] a.b=1 a.c=2
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[38][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[38][1].childCount = 1
    // Node 2: section table
    TOML_PARSE_EXPECTED_NODES[38][2].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[38][2].key = 'section'
    TOML_PARSE_EXPECTED_NODES[38][2].childCount = 1
    // Node 3: implicit 'a' table
    TOML_PARSE_EXPECTED_NODES[38][3].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[38][3].key = 'a'
    TOML_PARSE_EXPECTED_NODES[38][3].childCount = 2
    // Node 4: b = 1
    TOML_PARSE_EXPECTED_NODES[38][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[38][4].key = 'b'
    TOML_PARSE_EXPECTED_NODES[38][4].value = '1'
    // Node 5: c = 2
    TOML_PARSE_EXPECTED_NODES[38][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[38][5].key = 'c'
    TOML_PARSE_EXPECTED_NODES[38][5].value = '2'

    // Test 39: Quoted keys
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[39][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[39][1].childCount = 2
    // Node 2: "key with spaces" = "value1"
    TOML_PARSE_EXPECTED_NODES[39][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[39][2].key = 'key with spaces'
    TOML_PARSE_EXPECTED_NODES[39][2].value = 'value1'
    // Node 3: "special@key" = "value2"
    TOML_PARSE_EXPECTED_NODES[39][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[39][3].key = 'special@key'
    TOML_PARSE_EXPECTED_NODES[39][3].value = 'value2'

    // Test 40: Local datetime
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[40][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[40][1].childCount = 1
    // Node 2: local_dt
    TOML_PARSE_EXPECTED_NODES[40][2].type = NAV_TOML_NODE_TYPE_DATETIME
    TOML_PARSE_EXPECTED_NODES[40][2].key = 'local_dt'
    TOML_PARSE_EXPECTED_NODES[40][2].value = '1979-05-27T07:32:00'

    // Test 41: Datetime with fractional seconds
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[41][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[41][1].childCount = 1
    // Node 2: precise_dt
    TOML_PARSE_EXPECTED_NODES[41][2].type = NAV_TOML_NODE_TYPE_DATETIME
    TOML_PARSE_EXPECTED_NODES[41][2].key = 'precise_dt'
    TOML_PARSE_EXPECTED_NODES[41][2].value = '1979-05-27T00:32:00.999999-07:00'

    // Test 42: Multiline string with escapes
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[42][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[42][1].childCount = 1
    // Node 2: text (with escape sequence processed)
    TOML_PARSE_EXPECTED_NODES[42][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[42][2].key = 'text'
    TOML_PARSE_EXPECTED_NODES[42][2].value = "'Line 1', 10, 'Line 2'"
    TOML_PARSE_EXPECTED_NODES[42][2].subtype = NAV_TOML_SUBTYPE_STRING_MULTILINE

    // Test 43: Line-ending backslash
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[43][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[43][1].childCount = 1
    // Node 2: str (backslash+newline+whitespace trimmed)
    TOML_PARSE_EXPECTED_NODES[43][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[43][2].key = 'str'
    TOML_PARSE_EXPECTED_NODES[43][2].value = 'The quick brown fox'
    TOML_PARSE_EXPECTED_NODES[43][2].subtype = NAV_TOML_SUBTYPE_STRING_MULTILINE

    // Test 44: Multiple array tables same level
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[44][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[44][1].childCount = 1
    // Node 2: items array table container
    TOML_PARSE_EXPECTED_NODES[44][2].type = NAV_TOML_NODE_TYPE_TABLE_ARRAY
    TOML_PARSE_EXPECTED_NODES[44][2].key = 'items'
    TOML_PARSE_EXPECTED_NODES[44][2].childCount = 3
    // Node 3: first item
    TOML_PARSE_EXPECTED_NODES[44][3].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[44][3].childCount = 2
    // Node 4: id = 1
    TOML_PARSE_EXPECTED_NODES[44][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[44][4].key = 'id'
    TOML_PARSE_EXPECTED_NODES[44][4].value = '1'
    // Node 5: name = "first"
    TOML_PARSE_EXPECTED_NODES[44][5].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[44][5].key = 'name'
    TOML_PARSE_EXPECTED_NODES[44][5].value = 'first'
    // Node 6: second item
    TOML_PARSE_EXPECTED_NODES[44][6].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[44][6].childCount = 2
    // Node 7: id = 2
    TOML_PARSE_EXPECTED_NODES[44][7].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[44][7].key = 'id'
    TOML_PARSE_EXPECTED_NODES[44][7].value = '2'
    // Node 8: name = "second"
    TOML_PARSE_EXPECTED_NODES[44][8].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[44][8].key = 'name'
    TOML_PARSE_EXPECTED_NODES[44][8].value = 'second'
    // Node 9: third item
    TOML_PARSE_EXPECTED_NODES[44][9].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[44][9].childCount = 2
    // Node 10: id = 3
    TOML_PARSE_EXPECTED_NODES[44][10].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[44][10].key = 'id'
    TOML_PARSE_EXPECTED_NODES[44][10].value = '3'
    // Node 11: name = "third"
    TOML_PARSE_EXPECTED_NODES[44][11].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[44][11].key = 'name'
    TOML_PARSE_EXPECTED_NODES[44][11].value = 'third'

    // Test 45: Table after array of tables
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[45][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[45][1].childCount = 2
    // Node 2: products array table
    TOML_PARSE_EXPECTED_NODES[45][2].type = NAV_TOML_NODE_TYPE_TABLE_ARRAY
    TOML_PARSE_EXPECTED_NODES[45][2].key = 'products'
    TOML_PARSE_EXPECTED_NODES[45][2].childCount = 1
    // Node 3: product table
    TOML_PARSE_EXPECTED_NODES[45][3].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[45][3].childCount = 1
    // Node 4: name = "Widget"
    TOML_PARSE_EXPECTED_NODES[45][4].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[45][4].key = 'name'
    TOML_PARSE_EXPECTED_NODES[45][4].value = 'Widget'
    // Node 5: shipping table
    TOML_PARSE_EXPECTED_NODES[45][5].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[45][5].key = 'shipping'
    TOML_PARSE_EXPECTED_NODES[45][5].childCount = 1
    // Node 6: weight = 10
    TOML_PARSE_EXPECTED_NODES[45][6].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[45][6].key = 'weight'
    TOML_PARSE_EXPECTED_NODES[45][6].value = '10'

    // Test 46: Deeply nested tables - [a.b.c.d.e]
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[46][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[46][1].childCount = 1
    // Node 2: a table
    TOML_PARSE_EXPECTED_NODES[46][2].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[46][2].key = 'a'
    TOML_PARSE_EXPECTED_NODES[46][2].childCount = 1
    // Node 3: b table
    TOML_PARSE_EXPECTED_NODES[46][3].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[46][3].key = 'b'
    TOML_PARSE_EXPECTED_NODES[46][3].childCount = 1
    // Node 4: c table
    TOML_PARSE_EXPECTED_NODES[46][4].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[46][4].key = 'c'
    TOML_PARSE_EXPECTED_NODES[46][4].childCount = 1
    // Node 5: d table
    TOML_PARSE_EXPECTED_NODES[46][5].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[46][5].key = 'd'
    TOML_PARSE_EXPECTED_NODES[46][5].childCount = 1
    // Node 6: e table
    TOML_PARSE_EXPECTED_NODES[46][6].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[46][6].key = 'e'
    TOML_PARSE_EXPECTED_NODES[46][6].childCount = 1
    // Node 7: value = 42
    TOML_PARSE_EXPECTED_NODES[46][7].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[46][7].key = 'value'
    TOML_PARSE_EXPECTED_NODES[46][7].value = '42'

    // Test 47: Whitespace handling
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[47][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[47][1].childCount = 3
    // Node 2: key1 = "value1"
    TOML_PARSE_EXPECTED_NODES[47][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[47][2].key = 'key1'
    TOML_PARSE_EXPECTED_NODES[47][2].value = 'value1'
    // Node 3: key2 = "value2"
    TOML_PARSE_EXPECTED_NODES[47][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[47][3].key = 'key2'
    TOML_PARSE_EXPECTED_NODES[47][3].value = 'value2'
    // Node 4: key3 = "value3"
    TOML_PARSE_EXPECTED_NODES[47][4].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[47][4].key = 'key3'
    TOML_PARSE_EXPECTED_NODES[47][4].value = 'value3'

    // Test 48: All escape sequences
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[48][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[48][1].childCount = 7
    // Node 2: tab = "\t"
    TOML_PARSE_EXPECTED_NODES[48][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[48][2].key = 'tab'
    TOML_PARSE_EXPECTED_NODES[48][2].value = "$09"
    // Node 3: newln = "\n"
    TOML_PARSE_EXPECTED_NODES[48][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[48][3].key = 'newln'
    TOML_PARSE_EXPECTED_NODES[48][3].value = "$0A"
    // Node 4: cr = "\r"
    TOML_PARSE_EXPECTED_NODES[48][4].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[48][4].key = 'cr'
    TOML_PARSE_EXPECTED_NODES[48][4].value = "$0D"
    // Node 5: quote = "\""
    TOML_PARSE_EXPECTED_NODES[48][5].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[48][5].key = 'quote'
    TOML_PARSE_EXPECTED_NODES[48][5].value = '"'
    // Node 6: backslash = "\\"
    TOML_PARSE_EXPECTED_NODES[48][6].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[48][6].key = 'backslash'
    TOML_PARSE_EXPECTED_NODES[48][6].value = '\'
    // Node 7: backspace = "\b"
    TOML_PARSE_EXPECTED_NODES[48][7].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[48][7].key = 'backspace'
    TOML_PARSE_EXPECTED_NODES[48][7].value = "$08"
    // Node 8: formfeed = "\f"
    TOML_PARSE_EXPECTED_NODES[48][8].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[48][8].key = 'formfeed'
    TOML_PARSE_EXPECTED_NODES[48][8].value = "$0C"
    // Node 9: (7 keys but 8 child count due to formfeed key-value)
    TOML_PARSE_EXPECTED_NODES[48][9].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[48][9].key = 'formfeed'
    TOML_PARSE_EXPECTED_NODES[48][9].value = "$0C"

    // Test 49: Complex array structures - nested = [[[1]], [[2,3]], [[4],[5,6]]]
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[49][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[49][1].childCount = 1
    // Node 2: nested array
    TOML_PARSE_EXPECTED_NODES[49][2].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[49][2].key = 'nested'
    TOML_PARSE_EXPECTED_NODES[49][2].childCount = 3
    // Node 3: [[1]] - first element array
    TOML_PARSE_EXPECTED_NODES[49][3].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[49][3].childCount = 1
    // Node 4: [1] - inner array
    TOML_PARSE_EXPECTED_NODES[49][4].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[49][4].childCount = 1
    // Node 5: 1
    TOML_PARSE_EXPECTED_NODES[49][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[49][5].value = '1'
    // Node 6: [[2,3]] - second element array
    TOML_PARSE_EXPECTED_NODES[49][6].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[49][6].childCount = 1
    // Node 7: [2,3] - inner array
    TOML_PARSE_EXPECTED_NODES[49][7].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[49][7].childCount = 2
    // Node 8: 2
    TOML_PARSE_EXPECTED_NODES[49][8].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[49][8].value = '2'
    // Node 9: 3
    TOML_PARSE_EXPECTED_NODES[49][9].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[49][9].value = '3'
    // Node 10: [[4],[5,6]] - third element array
    TOML_PARSE_EXPECTED_NODES[49][10].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[49][10].childCount = 2
    // Node 11: [4]
    TOML_PARSE_EXPECTED_NODES[49][11].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[49][11].childCount = 1
    // Node 12: 4
    TOML_PARSE_EXPECTED_NODES[49][12].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[49][12].value = '4'
    // Node 13: [5,6]
    TOML_PARSE_EXPECTED_NODES[49][13].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[49][13].childCount = 2
    // Node 14: 5
    TOML_PARSE_EXPECTED_NODES[49][14].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[49][14].value = '5'
    // Node 15: 6
    TOML_PARSE_EXPECTED_NODES[49][15].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[49][15].value = '6'

    // Test 50: Edge case combinations
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[50][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[50][1].childCount = 7
    // Node 2: empty_str = ""
    TOML_PARSE_EXPECTED_NODES[50][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[50][2].key = 'empty_str'
    TOML_PARSE_EXPECTED_NODES[50][2].value = ''
    TOML_PARSE_EXPECTED_NODES[50][2].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    // Node 3: empty_arr = []
    TOML_PARSE_EXPECTED_NODES[50][3].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[50][3].key = 'empty_arr'
    TOML_PARSE_EXPECTED_NODES[50][3].childCount = 0
    // Node 4: empty_tbl = {}
    TOML_PARSE_EXPECTED_NODES[50][4].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[50][4].key = 'empty_tbl'
    TOML_PARSE_EXPECTED_NODES[50][4].childCount = 0
    // Node 5: zero = 0
    TOML_PARSE_EXPECTED_NODES[50][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[50][5].key = 'zero'
    TOML_PARSE_EXPECTED_NODES[50][5].value = '0'
    TOML_PARSE_EXPECTED_NODES[50][5].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 6: neg = -1
    TOML_PARSE_EXPECTED_NODES[50][6].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[50][6].key = 'neg'
    TOML_PARSE_EXPECTED_NODES[50][6].value = '-1'
    TOML_PARSE_EXPECTED_NODES[50][6].subtype = NAV_TOML_SUBTYPE_DECIMAL
    // Node 7: inf_val = inf
    TOML_PARSE_EXPECTED_NODES[50][7].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[50][7].key = 'inf_val'
    TOML_PARSE_EXPECTED_NODES[50][7].value = 'inf'
    TOML_PARSE_EXPECTED_NODES[50][7].subtype = NAV_TOML_SUBTYPE_FLOAT_INF
    // Node 8: nan_val = nan
    TOML_PARSE_EXPECTED_NODES[50][8].type = NAV_TOML_NODE_TYPE_FLOAT
    TOML_PARSE_EXPECTED_NODES[50][8].key = 'nan_val'
    TOML_PARSE_EXPECTED_NODES[50][8].value = 'nan'
    TOML_PARSE_EXPECTED_NODES[50][8].subtype = NAV_TOML_SUBTYPE_FLOAT_NAN

    // Test 51: Unicode escape sequences (\uXXXX)
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[51][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[51][1].childCount = 2
    // Node 2: unicode_upper = "\u0041\u0042\u0043" (preserved as escape sequence)
    TOML_PARSE_EXPECTED_NODES[51][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[51][2].key = 'unicode_upper'
    TOML_PARSE_EXPECTED_NODES[51][2].value = "'\u0041\u0042\u0043'"
    // Node 3: unicode_symbol = "\u0022\u0027" (quote and apostrophe escape sequences)
    TOML_PARSE_EXPECTED_NODES[51][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[51][3].key = 'unicode_symbol'
    TOML_PARSE_EXPECTED_NODES[51][3].value = "'\u0022\u0027'"

    // Test 52: Unicode escape sequences (\UXXXXXXXX)
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[52][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[52][1].childCount = 2
    // Node 2: emoji = "\U0001F600" (preserved as escape sequence)
    TOML_PARSE_EXPECTED_NODES[52][2].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[52][2].key = 'emoji'
    TOML_PARSE_EXPECTED_NODES[52][2].value = "'\U0001F600'"
    // Node 3: unicode_char = "\U00000041" (preserved as escape sequence)
    TOML_PARSE_EXPECTED_NODES[52][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[52][3].key = 'unicode_char'
    TOML_PARSE_EXPECTED_NODES[52][3].value = "'\U00000041'"

    // Test 65: TOML 1.1.0 - Local time without seconds
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[65][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[65][1].childCount = 1
    // Node 2: time = 14:15
    TOML_PARSE_EXPECTED_NODES[65][2].type = NAV_TOML_NODE_TYPE_TIME
    TOML_PARSE_EXPECTED_NODES[65][2].key = 'time'
    TOML_PARSE_EXPECTED_NODES[65][2].value = '14:15'

    // Test 66: TOML 1.1.0 - Local datetime without seconds
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[66][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[66][1].childCount = 1
    // Node 2: dt = 2010-02-03T14:15
    TOML_PARSE_EXPECTED_NODES[66][2].type = NAV_TOML_NODE_TYPE_DATETIME
    TOML_PARSE_EXPECTED_NODES[66][2].key = 'dt'
    TOML_PARSE_EXPECTED_NODES[66][2].value = '2010-02-03T14:15'

    // Test 67: TOML 1.1.0 - Offset datetime without seconds with Z
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[67][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[67][1].childCount = 1
    // Node 2: dt = 2010-02-03T14:15Z
    TOML_PARSE_EXPECTED_NODES[67][2].type = NAV_TOML_NODE_TYPE_DATETIME
    TOML_PARSE_EXPECTED_NODES[67][2].key = 'dt'
    TOML_PARSE_EXPECTED_NODES[67][2].value = '2010-02-03T14:15Z'

    // Test 68: TOML 1.1.0 - Offset datetime without seconds with timezone
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[68][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[68][1].childCount = 1
    // Node 2: dt = 2010-02-03T14:15-08:00
    TOML_PARSE_EXPECTED_NODES[68][2].type = NAV_TOML_NODE_TYPE_DATETIME
    TOML_PARSE_EXPECTED_NODES[68][2].key = 'dt'
    TOML_PARSE_EXPECTED_NODES[68][2].value = '2010-02-03T14:15-08:00'

    // Test 69: TOML 1.1.0 - Local datetime with space separator, no seconds
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[69][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[69][1].childCount = 1
    // Node 2: dt = 2010-02-03 14:15
    TOML_PARSE_EXPECTED_NODES[69][2].type = NAV_TOML_NODE_TYPE_DATETIME
    TOML_PARSE_EXPECTED_NODES[69][2].key = 'dt'
    TOML_PARSE_EXPECTED_NODES[69][2].value = '2010-02-03 14:15'

    // Test 70: TOML 1.1.0 - Multiple datetime values with and without seconds
    // Node 1: root
    TOML_PARSE_EXPECTED_NODES[70][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[70][1].childCount = 4
    // Node 2: with_sec = 07:32:00
    TOML_PARSE_EXPECTED_NODES[70][2].type = NAV_TOML_NODE_TYPE_TIME
    TOML_PARSE_EXPECTED_NODES[70][2].key = 'with_sec'
    TOML_PARSE_EXPECTED_NODES[70][2].value = '07:32:00'
    // Node 3: without_sec = 14:15
    TOML_PARSE_EXPECTED_NODES[70][3].type = NAV_TOML_NODE_TYPE_TIME
    TOML_PARSE_EXPECTED_NODES[70][3].key = 'without_sec'
    TOML_PARSE_EXPECTED_NODES[70][3].value = '14:15'
    // Node 4: dt_with = 2010-02-03T14:15:30
    TOML_PARSE_EXPECTED_NODES[70][4].type = NAV_TOML_NODE_TYPE_DATETIME
    TOML_PARSE_EXPECTED_NODES[70][4].key = 'dt_with'
    TOML_PARSE_EXPECTED_NODES[70][4].value = '2010-02-03T14:15:30'
    // Node 5: dt_without = 2010-02-03T14:15
    TOML_PARSE_EXPECTED_NODES[70][5].type = NAV_TOML_NODE_TYPE_DATETIME
    TOML_PARSE_EXPECTED_NODES[70][5].key = 'dt_without'
    TOML_PARSE_EXPECTED_NODES[70][5].value = '2010-02-03T14:15'

    // Test 71: TOML 1.1.0 - Basic multiline inline table: point = { x = 10, y = 20 }
    TOML_PARSE_EXPECTED_NODES[71][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[71][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[71][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[71][2].key = 'point'
    TOML_PARSE_EXPECTED_NODES[71][2].childCount = 2
    TOML_PARSE_EXPECTED_NODES[71][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[71][3].key = 'x'
    TOML_PARSE_EXPECTED_NODES[71][3].value = '10'
    TOML_PARSE_EXPECTED_NODES[71][3].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[71][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[71][4].key = 'y'
    TOML_PARSE_EXPECTED_NODES[71][4].value = '20'
    TOML_PARSE_EXPECTED_NODES[71][4].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Test 72: TOML 1.1.0 - Trailing comma: data = { a = 1, b = 2, }
    TOML_PARSE_EXPECTED_NODES[72][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[72][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[72][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[72][2].key = 'data'
    TOML_PARSE_EXPECTED_NODES[72][2].childCount = 2
    TOML_PARSE_EXPECTED_NODES[72][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[72][3].key = 'a'
    TOML_PARSE_EXPECTED_NODES[72][3].value = '1'
    TOML_PARSE_EXPECTED_NODES[72][3].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[72][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[72][4].key = 'b'
    TOML_PARSE_EXPECTED_NODES[72][4].value = '2'
    TOML_PARSE_EXPECTED_NODES[72][4].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Test 73: TOML 1.1.0 - Multiline with trailing comma: obj = { key = "value", }
    TOML_PARSE_EXPECTED_NODES[73][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[73][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[73][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[73][2].key = 'obj'
    TOML_PARSE_EXPECTED_NODES[73][2].childCount = 1
    TOML_PARSE_EXPECTED_NODES[73][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[73][3].key = 'key'
    TOML_PARSE_EXPECTED_NODES[73][3].value = 'value'
    TOML_PARSE_EXPECTED_NODES[73][3].subtype = NAV_TOML_SUBTYPE_STRING_BASIC

    // Test 74: TOML 1.1.0 - Nested inline tables with newlines
    TOML_PARSE_EXPECTED_NODES[74][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[74][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[74][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[74][2].key = 'outer'
    TOML_PARSE_EXPECTED_NODES[74][2].childCount = 2
    TOML_PARSE_EXPECTED_NODES[74][3].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[74][3].key = 'inner'
    TOML_PARSE_EXPECTED_NODES[74][3].childCount = 2
    TOML_PARSE_EXPECTED_NODES[74][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[74][4].key = 'a'
    TOML_PARSE_EXPECTED_NODES[74][4].value = '1'
    TOML_PARSE_EXPECTED_NODES[74][4].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[74][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[74][5].key = 'b'
    TOML_PARSE_EXPECTED_NODES[74][5].value = '2'
    TOML_PARSE_EXPECTED_NODES[74][5].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[74][6].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[74][6].key = 'value'
    TOML_PARSE_EXPECTED_NODES[74][6].value = '42'
    TOML_PARSE_EXPECTED_NODES[74][6].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Test 75: TOML 1.1.0 - Multiple key-value pairs multiline
    TOML_PARSE_EXPECTED_NODES[75][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[75][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[75][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[75][2].key = 'config'
    TOML_PARSE_EXPECTED_NODES[75][2].childCount = 3
    TOML_PARSE_EXPECTED_NODES[75][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[75][3].key = 'host'
    TOML_PARSE_EXPECTED_NODES[75][3].value = 'localhost'
    TOML_PARSE_EXPECTED_NODES[75][3].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    TOML_PARSE_EXPECTED_NODES[75][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[75][4].key = 'port'
    TOML_PARSE_EXPECTED_NODES[75][4].value = '8080'
    TOML_PARSE_EXPECTED_NODES[75][4].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[75][5].type = NAV_TOML_NODE_TYPE_BOOLEAN
    TOML_PARSE_EXPECTED_NODES[75][5].key = 'ssl'
    TOML_PARSE_EXPECTED_NODES[75][5].value = 'true'
    TOML_PARSE_EXPECTED_NODES[75][5].subtype = NAV_TOML_SUBTYPE_TRUE

    // Test 76: TOML 1.1.0 - Inline table with newlines in array
    TOML_PARSE_EXPECTED_NODES[76][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[76][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[76][2].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[76][2].key = 'items'
    TOML_PARSE_EXPECTED_NODES[76][2].childCount = 2
    TOML_PARSE_EXPECTED_NODES[76][3].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[76][3].childCount = 2
    TOML_PARSE_EXPECTED_NODES[76][4].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[76][4].key = 'name'
    TOML_PARSE_EXPECTED_NODES[76][4].value = 'first'
    TOML_PARSE_EXPECTED_NODES[76][4].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    TOML_PARSE_EXPECTED_NODES[76][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[76][5].key = 'value'
    TOML_PARSE_EXPECTED_NODES[76][5].value = '1'
    TOML_PARSE_EXPECTED_NODES[76][5].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[76][6].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[76][6].childCount = 2
    TOML_PARSE_EXPECTED_NODES[76][7].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[76][7].key = 'name'
    TOML_PARSE_EXPECTED_NODES[76][7].value = 'second'
    TOML_PARSE_EXPECTED_NODES[76][7].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    TOML_PARSE_EXPECTED_NODES[76][8].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[76][8].key = 'value'
    TOML_PARSE_EXPECTED_NODES[76][8].value = '2'
    TOML_PARSE_EXPECTED_NODES[76][8].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Test 77: TOML 1.1.0 - Empty inline table multiline format
    TOML_PARSE_EXPECTED_NODES[77][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[77][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[77][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[77][2].key = 'empty'
    TOML_PARSE_EXPECTED_NODES[77][2].childCount = 0

    // Test 78: TOML 1.1.0 - Inline table with mixed types and newlines
    TOML_PARSE_EXPECTED_NODES[78][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[78][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[78][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[78][2].key = 'mixed'
    TOML_PARSE_EXPECTED_NODES[78][2].childCount = 4
    TOML_PARSE_EXPECTED_NODES[78][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[78][3].key = 'str'
    TOML_PARSE_EXPECTED_NODES[78][3].value = 'text'
    TOML_PARSE_EXPECTED_NODES[78][3].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    TOML_PARSE_EXPECTED_NODES[78][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[78][4].key = 'num'
    TOML_PARSE_EXPECTED_NODES[78][4].value = '123'
    TOML_PARSE_EXPECTED_NODES[78][4].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[78][5].type = NAV_TOML_NODE_TYPE_BOOLEAN
    TOML_PARSE_EXPECTED_NODES[78][5].key = 'bool'
    TOML_PARSE_EXPECTED_NODES[78][5].value = 'false'
    TOML_PARSE_EXPECTED_NODES[78][5].subtype = NAV_TOML_SUBTYPE_FALSE
    TOML_PARSE_EXPECTED_NODES[78][6].type = NAV_TOML_NODE_TYPE_ARRAY
    TOML_PARSE_EXPECTED_NODES[78][6].key = 'arr'
    TOML_PARSE_EXPECTED_NODES[78][6].childCount = 3
    TOML_PARSE_EXPECTED_NODES[78][7].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[78][7].value = '1'
    TOML_PARSE_EXPECTED_NODES[78][7].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[78][8].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[78][8].value = '2'
    TOML_PARSE_EXPECTED_NODES[78][8].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[78][9].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[78][9].value = '3'
    TOML_PARSE_EXPECTED_NODES[78][9].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Test 79: TOML 1.1.0 - Single line with trailing comma
    TOML_PARSE_EXPECTED_NODES[79][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[79][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[79][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[79][2].key = 'simple'
    TOML_PARSE_EXPECTED_NODES[79][2].childCount = 1
    TOML_PARSE_EXPECTED_NODES[79][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[79][3].key = 'x'
    TOML_PARSE_EXPECTED_NODES[79][3].value = '1'
    TOML_PARSE_EXPECTED_NODES[79][3].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Test 80: TOML 1.1.0 - Deeply nested multiline inline tables
    TOML_PARSE_EXPECTED_NODES[80][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[80][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[80][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[80][2].key = 'deep'
    TOML_PARSE_EXPECTED_NODES[80][2].childCount = 1
    TOML_PARSE_EXPECTED_NODES[80][3].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[80][3].key = 'level1'
    TOML_PARSE_EXPECTED_NODES[80][3].childCount = 1
    TOML_PARSE_EXPECTED_NODES[80][4].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[80][4].key = 'level2'
    TOML_PARSE_EXPECTED_NODES[80][4].childCount = 1
    TOML_PARSE_EXPECTED_NODES[80][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[80][5].key = 'value'
    TOML_PARSE_EXPECTED_NODES[80][5].value = '42'
    TOML_PARSE_EXPECTED_NODES[80][5].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Test 81: TOML 1.1.0 - Multiple inline tables in same document with newlines
    TOML_PARSE_EXPECTED_NODES[81][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[81][1].childCount = 2
    TOML_PARSE_EXPECTED_NODES[81][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[81][2].key = 'first'
    TOML_PARSE_EXPECTED_NODES[81][2].childCount = 1
    TOML_PARSE_EXPECTED_NODES[81][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[81][3].key = 'a'
    TOML_PARSE_EXPECTED_NODES[81][3].value = '1'
    TOML_PARSE_EXPECTED_NODES[81][3].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[81][4].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[81][4].key = 'second'
    TOML_PARSE_EXPECTED_NODES[81][4].childCount = 1
    TOML_PARSE_EXPECTED_NODES[81][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[81][5].key = 'b'
    TOML_PARSE_EXPECTED_NODES[81][5].value = '2'
    TOML_PARSE_EXPECTED_NODES[81][5].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Test 82: TOML 1.1.0 - Inline table with various value types and trailing comma
    TOML_PARSE_EXPECTED_NODES[82][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[82][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[82][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[82][2].key = 'person'
    TOML_PARSE_EXPECTED_NODES[82][2].childCount = 3
    TOML_PARSE_EXPECTED_NODES[82][3].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[82][3].key = 'name'
    TOML_PARSE_EXPECTED_NODES[82][3].value = 'Alice'
    TOML_PARSE_EXPECTED_NODES[82][3].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
    TOML_PARSE_EXPECTED_NODES[82][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[82][4].key = 'age'
    TOML_PARSE_EXPECTED_NODES[82][4].value = '30'
    TOML_PARSE_EXPECTED_NODES[82][4].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[82][5].type = NAV_TOML_NODE_TYPE_STRING
    TOML_PARSE_EXPECTED_NODES[82][5].key = 'email'
    TOML_PARSE_EXPECTED_NODES[82][5].value = 'alice@example.com'
    TOML_PARSE_EXPECTED_NODES[82][5].subtype = NAV_TOML_SUBTYPE_STRING_BASIC

    // Test 83: Invalid - Multiple consecutive commas (no nodes expected)

    // Test 84: Empty multiline inline table with whitespace
    TOML_PARSE_EXPECTED_NODES[84][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[84][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[84][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[84][2].key = 'empty'
    TOML_PARSE_EXPECTED_NODES[84][2].childCount = 0

    // Test 85: Very deeply nested multiline inline tables
    TOML_PARSE_EXPECTED_NODES[85][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[85][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[85][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[85][2].key = 'outer'
    TOML_PARSE_EXPECTED_NODES[85][2].childCount = 1
    TOML_PARSE_EXPECTED_NODES[85][3].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[85][3].key = 'middle'
    TOML_PARSE_EXPECTED_NODES[85][3].childCount = 1
    TOML_PARSE_EXPECTED_NODES[85][4].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[85][4].key = 'inner'
    TOML_PARSE_EXPECTED_NODES[85][4].childCount = 1
    TOML_PARSE_EXPECTED_NODES[85][5].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[85][5].key = 'value'
    TOML_PARSE_EXPECTED_NODES[85][5].value = '42'
    TOML_PARSE_EXPECTED_NODES[85][5].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Test 86: Multiline inline table with excessive whitespace
    TOML_PARSE_EXPECTED_NODES[86][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[86][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[86][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[86][2].key = 'point'
    TOML_PARSE_EXPECTED_NODES[86][2].childCount = 2
    TOML_PARSE_EXPECTED_NODES[86][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[86][3].key = 'x'
    TOML_PARSE_EXPECTED_NODES[86][3].value = '1'
    TOML_PARSE_EXPECTED_NODES[86][3].subtype = NAV_TOML_SUBTYPE_DECIMAL
    TOML_PARSE_EXPECTED_NODES[86][4].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[86][4].key = 'y'
    TOML_PARSE_EXPECTED_NODES[86][4].value = '2'
    TOML_PARSE_EXPECTED_NODES[86][4].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Test 87: Trailing comma with newline before closing brace
    TOML_PARSE_EXPECTED_NODES[87][1].type = NAV_TOML_NODE_TYPE_TABLE
    TOML_PARSE_EXPECTED_NODES[87][1].childCount = 1
    TOML_PARSE_EXPECTED_NODES[87][2].type = NAV_TOML_NODE_TYPE_INLINE_TABLE
    TOML_PARSE_EXPECTED_NODES[87][2].key = 'data'
    TOML_PARSE_EXPECTED_NODES[87][2].childCount = 1
    TOML_PARSE_EXPECTED_NODES[87][3].type = NAV_TOML_NODE_TYPE_INTEGER
    TOML_PARSE_EXPECTED_NODES[87][3].key = 'value'
    TOML_PARSE_EXPECTED_NODES[87][3].value = '123'
    TOML_PARSE_EXPECTED_NODES[87][3].subtype = NAV_TOML_SUBTYPE_DECIMAL

    // Tests 88-91: Invalid cases (no nodes expected)

    set_length_array(TOML_PARSE_EXPECTED_NODES, 91)
}


define_function integer ValidateTomlTreeRecursive(_NAVToml toml,
                                                   _NAVTomlNode node,
                                                   _NAVTomlNode expectedNodes[],
                                                   integer expectedCount,
                                                   integer index,
                                                   integer depth) {
    stack_var integer nextIndex
    stack_var _NAVTomlNode child
    stack_var char indent[128]
    stack_var integer i

    // Validate index bounds
    if (index < 1 || index > expectedCount) {
        #IF_DEFINED DEBUG_TOML_TREE_VALIDATION
        NAVLog("'ValidateTomlTreeRecursive: Index ', itoa(index), ' out of bounds (max=', itoa(expectedCount), ')'")
        #END_IF
        return 0
    }

    // Build indentation for debug output
    #IF_DEFINED DEBUG_TOML_TREE_VALIDATION
    indent = ''
    for (i = 0; i < depth; i++) {
        indent = "indent, '  '"
    }
    NAVLog("indent, 'Node[', itoa(index), '] type=', itoa(node.type), ' key=', node.key")
    #END_IF

    // Validate node type
    if (!NAVAssertIntegerEqual('Node type should match',
                                expectedNodes[index].type,
                                node.type)) {
        return 0
    }

    // Validate key for table/object properties (skip for array elements)
    if (expectedNodes[index].key != '') {
        if (!NAVAssertStringEqual('Node key should match',
                                   expectedNodes[index].key,
                                   node.key)) {
            return 0
        }
    }

    // Validate childCount for containers
    if (node.type == NAV_TOML_NODE_TYPE_TABLE ||
        node.type == NAV_TOML_NODE_TYPE_INLINE_TABLE ||
        node.type == NAV_TOML_NODE_TYPE_ARRAY ||
        node.type == NAV_TOML_NODE_TYPE_TABLE_ARRAY) {

        if (!NAVAssertIntegerEqual('Node childCount should match',
                                    expectedNodes[index].childCount,
                                    node.childCount)) {
            return 0
        }
    }

    // Validate value for leaf nodes
    switch (node.type) {
        case NAV_TOML_NODE_TYPE_STRING:
        case NAV_TOML_NODE_TYPE_INTEGER:
        case NAV_TOML_NODE_TYPE_FLOAT:
        case NAV_TOML_NODE_TYPE_BOOLEAN:
        case NAV_TOML_NODE_TYPE_DATETIME:
        case NAV_TOML_NODE_TYPE_DATE:
        case NAV_TOML_NODE_TYPE_TIME: {
            #IF_DEFINED DEBUG_TOML_TREE_VALIDATION
            NAVLog("indent, '  = ', node.value")
            #END_IF

            if (!NAVAssertStringEqual('Node value should match',
                                      expectedNodes[index].value,
                                      node.value)) {
                return 0
            }

            // Validate subtype if expected node has subtype set
            if (expectedNodes[index].subtype != 0 ||
                (node.type == NAV_TOML_NODE_TYPE_INTEGER && expectedNodes[index].type == NAV_TOML_NODE_TYPE_INTEGER) ||
                (node.type == NAV_TOML_NODE_TYPE_FLOAT && expectedNodes[index].type == NAV_TOML_NODE_TYPE_FLOAT) ||
                (node.type == NAV_TOML_NODE_TYPE_BOOLEAN && expectedNodes[index].type == NAV_TOML_NODE_TYPE_BOOLEAN) ||
                (node.type == NAV_TOML_NODE_TYPE_STRING && expectedNodes[index].type == NAV_TOML_NODE_TYPE_STRING)) {

                if (!NAVAssertIntegerEqual('Node subtype should match',
                                           expectedNodes[index].subtype,
                                           NAVTomlGetNodeSubtype(node))) {
                    return 0
                }
            }
        }
    }

    nextIndex = index + 1  // Move to next node in depth-first order

    // Recurse into children (depth-first traversal)
    if (node.childCount > 0) {
        if (NAVTomlGetFirstChild(toml, node, child)) {
            while (true) {
                nextIndex = ValidateTomlTreeRecursive(toml,
                                                      child,
                                                      expectedNodes,
                                                      expectedCount,
                                                      nextIndex,
                                                      depth + 1)

                if (nextIndex == 0) {
                    return 0  // Validation failed in child
                }

                if (!NAVTomlGetNextNode(toml, child, child)) {
                    break
                }
            }
        }
    }

    return nextIndex  // Return next available index
}


/**
 * Validate entire TOML tree against expected node array
 */
define_function char ValidateTomlTree(_NAVToml toml, integer testNum) {
    stack_var _NAVTomlNode root
    stack_var integer result

    // Skip validation if no expected nodes are defined for this test
    if (TOML_PARSE_EXPECTED_NODES[testNum][1].type == 0) {
        return true
    }

    if (!NAVTomlGetRootNode(toml, root)) {
        return false
    }

    result = ValidateTomlTreeRecursive(toml,
                                       root,
                                       TOML_PARSE_EXPECTED_NODES[testNum],
                                       TOML_PARSE_EXPECTED_NODE_COUNT[testNum],
                                       1,
                                       0)

    return result != 0  // Success if result > 0
}


define_function TestNAVTomlParse() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVTomlParse')

    InitializeTomlParseTestData()
    InitializeExpectedNodes()

    for (x = 1; x <= length_array(TOML_PARSE_TEST); x++) {
        stack_var _NAVToml toml
        stack_var char parseResult

        parseResult = NAVTomlParse(TOML_PARSE_TEST[x], toml)

        // Assert parse result
        if (!NAVAssertBooleanEqual('Parse should succeed',
                                    TOML_PARSE_EXPECTED_RESULT[x],
                                    parseResult)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_PARSE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(parseResult))
            continue
        }

        // Skip further validation for error cases
        if (!TOML_PARSE_EXPECTED_RESULT[x]) {
            NAVLogTestPassed(x)
            continue
        }

        // Assert node count
        if (!NAVAssertIntegerEqual('Node count should match',
                                    TOML_PARSE_EXPECTED_NODE_COUNT[x],
                                    toml.nodeCount)) {
            NAVLogTestFailed(x,
                            itoa(TOML_PARSE_EXPECTED_NODE_COUNT[x]),
                            itoa(toml.nodeCount))
            continue
        }

        // Assert root index is valid
        if (!NAVAssertIntegerGreaterThan('Root index should be valid',
                                         0,
                                         toml.rootIndex)) {
            NAVLogTestFailed(x, 'Root > 0', itoa(toml.rootIndex))
            continue
        }

        // Assert root is a table
        if (!NAVAssertIntegerEqual('Root should be a table',
                                    NAV_TOML_NODE_TYPE_TABLE,
                                    toml.nodes[toml.rootIndex].type)) {
            NAVLogTestFailed(x, 'TABLE', itoa(toml.nodes[toml.rootIndex].type))
            continue
        }

        // Assert root child count
        if (!NAVAssertIntegerEqual('Root child count should match',
                                    TOML_PARSE_EXPECTED_ROOT_CHILD_COUNT[x],
                                    toml.nodes[toml.rootIndex].childCount)) {
            NAVLogTestFailed(x,
                            itoa(TOML_PARSE_EXPECTED_ROOT_CHILD_COUNT[x]),
                            itoa(toml.nodes[toml.rootIndex].childCount))
            continue
        }

        // Validate entire tree structure using recursive traversal
        if (!ValidateTomlTree(toml, x)) {
            NAVLogTestFailed(x, 'Tree validation', 'failed')
            continue
        }

        // Assert error message is empty on success
        if (!NAVAssertStringEqual('Error message should be empty',
                                   '',
                                   toml.error)) {
            NAVLogTestFailed(x, '', toml.error)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVTomlParse')
}
