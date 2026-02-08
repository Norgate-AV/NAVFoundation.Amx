PROGRAM_NAME='NAVYamlParse'

// Uncomment to enable detailed tree validation debug logging
// #DEFINE DEBUG_YAML_TREE_VALIDATION


DEFINE_VARIABLE

volatile char YAML_PARSE_TEST[56][1024]
volatile _NAVYamlNode YAML_PARSE_EXPECTED_NODES[56][50]  // Max 50 nodes per test

define_function InitializeYamlParseTestData() {
    // Test 1: Empty mapping
    YAML_PARSE_TEST[1] = '{}'

    // Test 2: Simple mapping with one key
    YAML_PARSE_TEST[2] = 'name: John'

    // Test 3: Mapping with multiple keys
    YAML_PARSE_TEST[3] = "'name: John', 13, 10,
                          'age: 30', 13, 10,
                          'active: true', 13, 10"

    // Test 4: Empty sequence
    YAML_PARSE_TEST[4] = '[]'

    // Test 5: Sequence with numbers
    YAML_PARSE_TEST[5] = "'- 1', 13, 10,
                          '- 2', 13, 10,
                          '- 3', 13, 10,
                          '- 4', 13, 10,
                          '- 5', 13, 10"

    // Test 6: Sequence with mixed types
    YAML_PARSE_TEST[6] = "'- 1', 13, 10,
                          '- two', 13, 10,
                          '- true', 13, 10,
                          '- null', 13, 10,
                          '- false', 13, 10"

    // Test 7: Nested mapping
    YAML_PARSE_TEST[7] = "'user:', 13, 10,
                          '  name: John', 13, 10,
                          '  age: 30', 13, 10"

    // Test 8: Nested sequence
    YAML_PARSE_TEST[8] = "'- - 1', 13, 10,
                          '  - 2', 13, 10,
                          '- - 3', 13, 10,
                          '  - 4', 13, 10"

    // Test 9: Sequence of mappings
    YAML_PARSE_TEST[9] = "'- id: 1', 13, 10,
                          '- id: 2', 13, 10"

    // Test 10: Mapping with sequence
    YAML_PARSE_TEST[10] = "'numbers:', 13, 10,
                           '  - 1', 13, 10,
                           '  - 2', 13, 10,
                           '  - 3', 13, 10,
                           'count: 3', 13, 10"

    // Test 11: All literal types
    YAML_PARSE_TEST[11] = "'null_value: null', 13, 10,
                           'true_value: true', 13, 10,
                           'false_value: false', 13, 10"

    // Test 12: Numbers with decimals
    YAML_PARSE_TEST[12] = "'pi: 3.14', 13, 10,
                           'e: 2.718', 13, 10"

    // Test 13: Negative numbers
    YAML_PARSE_TEST[13] = "'- -1', 13, 10,
                           '- -42', 13, 10,
                           '- -999', 13, 10"

    // Test 14: Flow style sequences
    YAML_PARSE_TEST[14] = 'items: [1, 2, 3, 4, 5]'

    // Test 15: Flow style mappings
    YAML_PARSE_TEST[15] = 'server: {host: localhost, port: 8080}'

    // Test 16: Deep nesting (depth 5)
    YAML_PARSE_TEST[16] = "'a:', 13, 10,
                           '  b:', 13, 10,
                           '    c:', 13, 10,
                           '      d:', 13, 10,
                           '        e: 1', 13, 10"

    // Test 17: Large sequence
    YAML_PARSE_TEST[17] = "'- 1', 13, 10,
                           '- 2', 13, 10,
                           '- 3', 13, 10,
                           '- 4', 13, 10,
                           '- 5', 13, 10,
                           '- 6', 13, 10,
                           '- 7', 13, 10,
                           '- 8', 13, 10,
                           '- 9', 13, 10,
                           '- 10', 13, 10"

    // Test 18: Complex nested structure
    YAML_PARSE_TEST[18] = "'users:', 13, 10,
                           '  - name: John', 13, 10,
                           '    age: 30', 13, 10,
                           '  - name: Jane', 13, 10,
                           '    age: 25', 13, 10,
                           'count: 2', 13, 10"

    // Test 19: Invalid - trailing comma in flow sequence
    YAML_PARSE_TEST[19] = '[1, 2, 3,]'

    // Test 20: Invalid - unclosed flow sequence
    YAML_PARSE_TEST[20] = '[1, 2, 3'

    // Test 21: Single-quoted string
    YAML_PARSE_TEST[21] = "'message: ''Hello, World!''', 13, 10"

    // Test 22: Double-quoted string
    YAML_PARSE_TEST[22] = 'message: "Hello, World!"'

    // Test 23: Double-quoted with escape sequences
    YAML_PARSE_TEST[23] = 'message: "Line 1\nLine 2\tTabbed"'

    // Test 24: Empty string (explicit)
    YAML_PARSE_TEST[24] = 'empty: ""'

    // Test 25: Boolean variants - yes/no
    YAML_PARSE_TEST[25] = "'yes_value: yes', 13, 10,
                           'no_value: no', 13, 10"

    // Test 26: Boolean variants - on/off
    YAML_PARSE_TEST[26] = "'on_value: on', 13, 10,
                           'off_value: off', 13, 10"

    // Test 27: Boolean variants - mixed case
    YAML_PARSE_TEST[27] = "'bool1: Yes', 13, 10,
                           'bool2: NO', 13, 10,
                           'bool3: True', 13, 10,
                           'bool4: FALSE', 13, 10"

    // Test 28: Null variants
    YAML_PARSE_TEST[28] = "'null1: ~', 13, 10,
                           'null2: null', 13, 10,
                           'null3: Null', 13, 10,
                           'null4: NULL', 13, 10"

    // Test 29: Positive numbers with + sign
    YAML_PARSE_TEST[29] = "'- +1', 13, 10,
                           '- +42', 13, 10,
                           '- +3.14', 13, 10"

    // Test 30: Hexadecimal numbers
    YAML_PARSE_TEST[30] = "'hex: 0x1A', 13, 10,
                           'hex2: 0xFF', 13, 10"

    // Test 31: Octal numbers
    YAML_PARSE_TEST[31] = "'octal: 0o12', 13, 10,
                           'octal2: 0o77', 13, 10"

    // Test 32: Scientific notation
    YAML_PARSE_TEST[32] = "'sci1: 1.23e+2', 13, 10,
                           'sci2: 4.56e-3', 13, 10"

    // Test 33: Infinity and NaN
    YAML_PARSE_TEST[33] = "'inf_val: .inf', 13, 10,
                           'neg_inf: -.inf', 13, 10,
                           'not_num: .nan', 13, 10"

    // Test 34: Inline comments
    YAML_PARSE_TEST[34] = "'name: John  # This is a comment', 13, 10,
                           'age: 30  # Another comment', 13, 10"

    // Test 35: Full-line comments
    YAML_PARSE_TEST[35] = "'# This is a comment line', 13, 10,
                           'name: John', 13, 10,
                           '# Another comment', 13, 10,
                           'age: 30', 13, 10"

    // Test 36: Empty flow mapping
    YAML_PARSE_TEST[36] = 'data: {}'

    // Test 37: Empty flow sequence
    YAML_PARSE_TEST[37] = 'items: []'

    // Test 38: Nested flow sequences
    YAML_PARSE_TEST[38] = '[[1, 2], [3, 4]]'

    // Test 39: Nested flow mappings
    YAML_PARSE_TEST[39] = '{outer: {inner: value}}'

    // Test 40: Mixed flow sequence in block mapping
    YAML_PARSE_TEST[40] = "'coords: [1, 2, 3]', 13, 10,
                           'name: point', 13, 10"

    // Test 41: Flow mapping in block sequence
    YAML_PARSE_TEST[41] = "'- {id: 1, name: Alice}', 13, 10,
                           '- {id: 2, name: Bob}', 13, 10"

    // Test 42: Complex nested block structure
    YAML_PARSE_TEST[42] = "'servers:', 13, 10,
                           '  production:', 13, 10,
                           '    host: prod.example.com', 13, 10,
                           '    port: 443', 13, 10,
                           '  staging:', 13, 10,
                           '    host: staging.example.com', 13, 10,
                           '    port: 8080', 13, 10"

    // Test 43: Sequence with mixed types
    YAML_PARSE_TEST[43] = "'- 123', 13, 10,
                           '- text', 13, 10,
                           '- true', 13, 10,
                           '- [1, 2]', 13, 10,
                           '- {key: value}', 13, 10"

    // Test 44: Deep nesting level 10
    YAML_PARSE_TEST[44] = "'a:', 13, 10,
                           '  b:', 13, 10,
                           '    c:', 13, 10,
                           '      d:', 13, 10,
                           '        e:', 13, 10,
                           '          f:', 13, 10,
                           '            g:', 13, 10,
                           '              h:', 13, 10,
                           '                i:', 13, 10,
                           '                  j: deep', 13, 10"

    // Test 45: Multiline sequence continuation (compact)
    YAML_PARSE_TEST[45] = "'- item1', 13, 10,
                           '- item2', 13, 10,
                           '- item3', 13, 10"

    // Test 46: Key with special characters
    YAML_PARSE_TEST[46] = "'127.0.0.1: localhost', 13, 10,
                           'my-key: value', 13, 10,
                           'my_key_2: value2', 13, 10"

    // Test 47: String that looks like number
    YAML_PARSE_TEST[47] = 'version: "1.0"'

    // Test 48: String that looks like boolean
    YAML_PARSE_TEST[48] = 'status: "false"'

    // Test 49: Complex flow and block mix
    YAML_PARSE_TEST[49] = "'data:', 13, 10,
                           '  - {id: 1, tags: [a, b, c]}', 13, 10,
                           '  - {id: 2, tags: [d, e, f]}', 13, 10"

    // Test 50: Empty mapping in sequence
    YAML_PARSE_TEST[50] = "'- {}', 13, 10,
                           '- {name: test}', 13, 10,
                           '- {}', 13, 10"

    // Test 51: Empty sequence in mapping
    YAML_PARSE_TEST[51] = "'empty: []', 13, 10,
                           'filled: [1, 2]', 13, 10"

    // Test 52: Zero values
    YAML_PARSE_TEST[52] = "'zero_int: 0', 13, 10,
                           'zero_float: 0.0', 13, 10,
                           'neg_zero: -0', 13, 10"

    // Test 53: Very long number
    YAML_PARSE_TEST[53] = 'large: 9223372036854775807'

    // Test 54: Multiple nested sequences
    YAML_PARSE_TEST[54] = "'matrix:', 13, 10,
                           '  - [1, 2, 3]', 13, 10,
                           '  - [4, 5, 6]', 13, 10,
                           '  - [7, 8, 9]', 13, 10"

    // Test 55: Compact mapping notation
    YAML_PARSE_TEST[55] = '{a: 1, b: 2, c: 3, d: 4, e: 5}'

    // Test 56: Empty string using $QT$ syntax (as used in ValueGetters test)
    YAML_PARSE_TEST[56] = "'text: ', 34, 34"

    set_length_array(YAML_PARSE_TEST, 56)

    InitializeExpectedNodes()
}

define_function InitializeExpectedNodes() {
    // Test 1: {}
    YAML_PARSE_EXPECTED_NODES[1][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[1][1].key = ''
    YAML_PARSE_EXPECTED_NODES[1][1].childCount = 0

    // Test 2: name: John
    YAML_PARSE_EXPECTED_NODES[2][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[2][1].key = ''
    YAML_PARSE_EXPECTED_NODES[2][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[2][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[2][2].key = 'name'
    YAML_PARSE_EXPECTED_NODES[2][2].value = 'John'
    YAML_PARSE_EXPECTED_NODES[2][2].childCount = 0

    // Test 3: name: John\nage: 30\nactive: true
    YAML_PARSE_EXPECTED_NODES[3][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[3][1].key = ''
    YAML_PARSE_EXPECTED_NODES[3][1].childCount = 3
    YAML_PARSE_EXPECTED_NODES[3][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[3][2].key = 'name'
    YAML_PARSE_EXPECTED_NODES[3][2].value = 'John'
    YAML_PARSE_EXPECTED_NODES[3][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[3][3].key = 'age'
    YAML_PARSE_EXPECTED_NODES[3][3].value = '30'
    YAML_PARSE_EXPECTED_NODES[3][4].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[3][4].key = 'active'
    YAML_PARSE_EXPECTED_NODES[3][4].value = 'true'

    // Test 4: []
    YAML_PARSE_EXPECTED_NODES[4][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[4][1].key = ''
    YAML_PARSE_EXPECTED_NODES[4][1].childCount = 0

    // Test 5: - 1\n- 2\n- 3\n- 4\n- 5
    YAML_PARSE_EXPECTED_NODES[5][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[5][1].key = ''
    YAML_PARSE_EXPECTED_NODES[5][1].childCount = 5
    YAML_PARSE_EXPECTED_NODES[5][2].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[5][2].value = '1'
    YAML_PARSE_EXPECTED_NODES[5][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[5][3].value = '2'
    YAML_PARSE_EXPECTED_NODES[5][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[5][4].value = '3'
    YAML_PARSE_EXPECTED_NODES[5][5].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[5][5].value = '4'
    YAML_PARSE_EXPECTED_NODES[5][6].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[5][6].value = '5'

    // Test 6: - 1\n- two\n- true\n- null\n- false
    YAML_PARSE_EXPECTED_NODES[6][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[6][1].key = ''
    YAML_PARSE_EXPECTED_NODES[6][1].childCount = 5
    YAML_PARSE_EXPECTED_NODES[6][2].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[6][2].value = '1'
    YAML_PARSE_EXPECTED_NODES[6][3].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[6][3].value = 'two'
    YAML_PARSE_EXPECTED_NODES[6][4].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[6][4].value = 'true'
    YAML_PARSE_EXPECTED_NODES[6][5].type = NAV_YAML_VALUE_TYPE_NULL
    YAML_PARSE_EXPECTED_NODES[6][6].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[6][6].value = 'false'

    // Test 7: user:\n  name: John\n  age: 30
    YAML_PARSE_EXPECTED_NODES[7][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[7][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[7][2].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[7][2].key = 'user'
    YAML_PARSE_EXPECTED_NODES[7][2].childCount = 2
    YAML_PARSE_EXPECTED_NODES[7][3].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[7][3].key = 'name'
    YAML_PARSE_EXPECTED_NODES[7][3].value = 'John'
    YAML_PARSE_EXPECTED_NODES[7][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[7][4].key = 'age'
    YAML_PARSE_EXPECTED_NODES[7][4].value = '30'

    // Test 8: - - 1\n  - 2\n- - 3\n  - 4
    YAML_PARSE_EXPECTED_NODES[8][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[8][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[8][2].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[8][2].childCount = 2
    YAML_PARSE_EXPECTED_NODES[8][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[8][3].value = '1'
    YAML_PARSE_EXPECTED_NODES[8][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[8][4].value = '2'
    YAML_PARSE_EXPECTED_NODES[8][5].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[8][5].childCount = 2
    YAML_PARSE_EXPECTED_NODES[8][6].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[8][6].value = '3'
    YAML_PARSE_EXPECTED_NODES[8][7].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[8][7].value = '4'

    // Test 9: - id: 1\n- id: 2
    YAML_PARSE_EXPECTED_NODES[9][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[9][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[9][2].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[9][2].childCount = 1
    YAML_PARSE_EXPECTED_NODES[9][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[9][3].key = 'id'
    YAML_PARSE_EXPECTED_NODES[9][3].value = '1'
    YAML_PARSE_EXPECTED_NODES[9][4].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[9][4].childCount = 1
    YAML_PARSE_EXPECTED_NODES[9][5].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[9][5].key = 'id'
    YAML_PARSE_EXPECTED_NODES[9][5].value = '2'

    // Test 10: numbers:\n  - 1\n  - 2\n  - 3\ncount: 3
    YAML_PARSE_EXPECTED_NODES[10][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[10][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[10][2].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[10][2].key = 'numbers'
    YAML_PARSE_EXPECTED_NODES[10][2].childCount = 3
    YAML_PARSE_EXPECTED_NODES[10][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[10][3].value = '1'
    YAML_PARSE_EXPECTED_NODES[10][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[10][4].value = '2'
    YAML_PARSE_EXPECTED_NODES[10][5].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[10][5].value = '3'
    YAML_PARSE_EXPECTED_NODES[10][6].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[10][6].key = 'count'
    YAML_PARSE_EXPECTED_NODES[10][6].value = '3'

    // Test 11: null_value: null\ntrue_value: true\nfalse_value: false
    YAML_PARSE_EXPECTED_NODES[11][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[11][1].childCount = 3
    YAML_PARSE_EXPECTED_NODES[11][2].type = NAV_YAML_VALUE_TYPE_NULL
    YAML_PARSE_EXPECTED_NODES[11][2].key = 'null_value'
    YAML_PARSE_EXPECTED_NODES[11][3].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[11][3].key = 'true_value'
    YAML_PARSE_EXPECTED_NODES[11][3].value = 'true'
    YAML_PARSE_EXPECTED_NODES[11][4].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[11][4].key = 'false_value'
    YAML_PARSE_EXPECTED_NODES[11][4].value = 'false'

    // Test 12: pi: 3.14\ne: 2.718
    YAML_PARSE_EXPECTED_NODES[12][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[12][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[12][2].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[12][2].key = 'pi'
    YAML_PARSE_EXPECTED_NODES[12][2].value = '3.14'
    YAML_PARSE_EXPECTED_NODES[12][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[12][3].key = 'e'
    YAML_PARSE_EXPECTED_NODES[12][3].value = '2.718'

    // Test 13: - -1\n- -42\n- -999
    YAML_PARSE_EXPECTED_NODES[13][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[13][1].childCount = 3
    YAML_PARSE_EXPECTED_NODES[13][2].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[13][2].value = '-1'
    YAML_PARSE_EXPECTED_NODES[13][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[13][3].value = '-42'
    YAML_PARSE_EXPECTED_NODES[13][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[13][4].value = '-999'

    // Test 14: items: [1, 2, 3, 4, 5]
    YAML_PARSE_EXPECTED_NODES[14][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[14][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[14][2].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[14][2].key = 'items'
    YAML_PARSE_EXPECTED_NODES[14][2].childCount = 5
    YAML_PARSE_EXPECTED_NODES[14][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[14][3].value = '1'
    YAML_PARSE_EXPECTED_NODES[14][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[14][4].value = '2'
    YAML_PARSE_EXPECTED_NODES[14][5].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[14][5].value = '3'
    YAML_PARSE_EXPECTED_NODES[14][6].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[14][6].value = '4'
    YAML_PARSE_EXPECTED_NODES[14][7].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[14][7].value = '5'

    // Test 15: server: {host: localhost, port: 8080}
    YAML_PARSE_EXPECTED_NODES[15][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[15][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[15][2].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[15][2].key = 'server'
    YAML_PARSE_EXPECTED_NODES[15][2].childCount = 2
    YAML_PARSE_EXPECTED_NODES[15][3].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[15][3].key = 'host'
    YAML_PARSE_EXPECTED_NODES[15][3].value = 'localhost'
    YAML_PARSE_EXPECTED_NODES[15][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[15][4].key = 'port'
    YAML_PARSE_EXPECTED_NODES[15][4].value = '8080'

    // Test 16: a:\n  b:\n    c:\n      d:\n        e: 1
    YAML_PARSE_EXPECTED_NODES[16][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[16][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[16][2].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[16][2].key = 'a'
    YAML_PARSE_EXPECTED_NODES[16][2].childCount = 1
    YAML_PARSE_EXPECTED_NODES[16][3].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[16][3].key = 'b'
    YAML_PARSE_EXPECTED_NODES[16][3].childCount = 1
    YAML_PARSE_EXPECTED_NODES[16][4].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[16][4].key = 'c'
    YAML_PARSE_EXPECTED_NODES[16][4].childCount = 1
    YAML_PARSE_EXPECTED_NODES[16][5].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[16][5].key = 'd'
    YAML_PARSE_EXPECTED_NODES[16][5].childCount = 1
    YAML_PARSE_EXPECTED_NODES[16][6].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[16][6].key = 'e'
    YAML_PARSE_EXPECTED_NODES[16][6].value = '1'

    // Test 17: - 1\n- 2\n...\n- 10
    YAML_PARSE_EXPECTED_NODES[17][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[17][1].childCount = 10
    YAML_PARSE_EXPECTED_NODES[17][2].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[17][2].value = '1'
    YAML_PARSE_EXPECTED_NODES[17][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[17][3].value = '2'
    YAML_PARSE_EXPECTED_NODES[17][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[17][4].value = '3'
    YAML_PARSE_EXPECTED_NODES[17][5].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[17][5].value = '4'
    YAML_PARSE_EXPECTED_NODES[17][6].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[17][6].value = '5'
    YAML_PARSE_EXPECTED_NODES[17][7].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[17][7].value = '6'
    YAML_PARSE_EXPECTED_NODES[17][8].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[17][8].value = '7'
    YAML_PARSE_EXPECTED_NODES[17][9].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[17][9].value = '8'
    YAML_PARSE_EXPECTED_NODES[17][10].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[17][10].value = '9'
    YAML_PARSE_EXPECTED_NODES[17][11].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[17][11].value = '10'

    // Test 18: users:\n  - name: John\n    age: 30\n  - name: Jane\n    age: 25\ncount: 2
    YAML_PARSE_EXPECTED_NODES[18][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[18][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[18][2].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[18][2].key = 'users'
    YAML_PARSE_EXPECTED_NODES[18][2].childCount = 2
    YAML_PARSE_EXPECTED_NODES[18][3].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[18][3].childCount = 2
    YAML_PARSE_EXPECTED_NODES[18][4].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[18][4].key = 'name'
    YAML_PARSE_EXPECTED_NODES[18][4].value = 'John'
    YAML_PARSE_EXPECTED_NODES[18][5].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[18][5].key = 'age'
    YAML_PARSE_EXPECTED_NODES[18][5].value = '30'
    YAML_PARSE_EXPECTED_NODES[18][6].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[18][6].childCount = 2
    YAML_PARSE_EXPECTED_NODES[18][7].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[18][7].key = 'name'
    YAML_PARSE_EXPECTED_NODES[18][7].value = 'Jane'
    YAML_PARSE_EXPECTED_NODES[18][8].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[18][8].key = 'age'
    YAML_PARSE_EXPECTED_NODES[18][8].value = '25'
    YAML_PARSE_EXPECTED_NODES[18][9].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[18][9].key = 'count'
    YAML_PARSE_EXPECTED_NODES[18][9].value = '2'

    // Test 21: Single-quoted string
    YAML_PARSE_EXPECTED_NODES[21][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[21][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[21][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[21][2].key = 'message'
    YAML_PARSE_EXPECTED_NODES[21][2].value = 'Hello, World!'

    // Test 22: Double-quoted string
    YAML_PARSE_EXPECTED_NODES[22][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[22][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[22][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[22][2].key = 'message'
    YAML_PARSE_EXPECTED_NODES[22][2].value = 'Hello, World!'

    // Test 23: Escaped characters in double-quoted
    YAML_PARSE_EXPECTED_NODES[23][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[23][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[23][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[23][2].key = 'message'
    YAML_PARSE_EXPECTED_NODES[23][2].value = "'Line 1', 10, 'Line 2', 9, 'Tabbed'"

    // Test 24: Empty string (explicit)
    YAML_PARSE_EXPECTED_NODES[24][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[24][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[24][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[24][2].key = 'empty'
    YAML_PARSE_EXPECTED_NODES[24][2].value = ''

    // Test 25: Boolean yes/no
    YAML_PARSE_EXPECTED_NODES[25][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[25][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[25][2].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[25][2].key = 'yes_value'
    YAML_PARSE_EXPECTED_NODES[25][2].value = 'yes'
    YAML_PARSE_EXPECTED_NODES[25][3].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[25][3].key = 'no_value'
    YAML_PARSE_EXPECTED_NODES[25][3].value = 'no'

    // Test 26: Boolean on/off
    YAML_PARSE_EXPECTED_NODES[26][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[26][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[26][2].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[26][2].key = 'on_value'
    YAML_PARSE_EXPECTED_NODES[26][2].value = 'on'
    YAML_PARSE_EXPECTED_NODES[26][3].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[26][3].key = 'off_value'
    YAML_PARSE_EXPECTED_NODES[26][3].value = 'off'

    // Test 27: Boolean mixed case
    YAML_PARSE_EXPECTED_NODES[27][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[27][1].childCount = 4
    YAML_PARSE_EXPECTED_NODES[27][2].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[27][2].key = 'bool1'
    YAML_PARSE_EXPECTED_NODES[27][2].value = 'Yes'
    YAML_PARSE_EXPECTED_NODES[27][3].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[27][3].key = 'bool2'
    YAML_PARSE_EXPECTED_NODES[27][3].value = 'NO'
    YAML_PARSE_EXPECTED_NODES[27][4].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[27][4].key = 'bool3'
    YAML_PARSE_EXPECTED_NODES[27][4].value = 'True'
    YAML_PARSE_EXPECTED_NODES[27][5].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[27][5].key = 'bool4'
    YAML_PARSE_EXPECTED_NODES[27][5].value = 'FALSE'

    // Test 28: Null variants
    YAML_PARSE_EXPECTED_NODES[28][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[28][1].childCount = 4
    YAML_PARSE_EXPECTED_NODES[28][2].type = NAV_YAML_VALUE_TYPE_NULL
    YAML_PARSE_EXPECTED_NODES[28][2].key = 'null1'
    YAML_PARSE_EXPECTED_NODES[28][3].type = NAV_YAML_VALUE_TYPE_NULL
    YAML_PARSE_EXPECTED_NODES[28][3].key = 'null2'
    YAML_PARSE_EXPECTED_NODES[28][4].type = NAV_YAML_VALUE_TYPE_NULL
    YAML_PARSE_EXPECTED_NODES[28][4].key = 'null3'
    YAML_PARSE_EXPECTED_NODES[28][5].type = NAV_YAML_VALUE_TYPE_NULL
    YAML_PARSE_EXPECTED_NODES[28][5].key = 'null4'

    // Test 29: Positive numbers with +
    YAML_PARSE_EXPECTED_NODES[29][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[29][1].childCount = 3
    YAML_PARSE_EXPECTED_NODES[29][2].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[29][2].value = '+1'
    YAML_PARSE_EXPECTED_NODES[29][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[29][3].value = '+42'
    YAML_PARSE_EXPECTED_NODES[29][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[29][4].value = '+3.14'

    // Test 30: Hexadecimal numbers (parsed as strings)
    YAML_PARSE_EXPECTED_NODES[30][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[30][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[30][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[30][2].key = 'hex'
    YAML_PARSE_EXPECTED_NODES[30][2].value = '0x1A'
    YAML_PARSE_EXPECTED_NODES[30][3].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[30][3].key = 'hex2'
    YAML_PARSE_EXPECTED_NODES[30][3].value = '0xFF'

    // Test 31: Octal numbers (parsed as strings)
    YAML_PARSE_EXPECTED_NODES[31][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[31][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[31][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[31][2].key = 'octal'
    YAML_PARSE_EXPECTED_NODES[31][2].value = '0o12'
    YAML_PARSE_EXPECTED_NODES[31][3].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[31][3].key = 'octal2'
    YAML_PARSE_EXPECTED_NODES[31][3].value = '0o77'

    // Test 32: Scientific notation (parsed as strings)
    YAML_PARSE_EXPECTED_NODES[32][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[32][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[32][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[32][2].key = 'sci1'
    YAML_PARSE_EXPECTED_NODES[32][2].value = '1.23e+2'
    YAML_PARSE_EXPECTED_NODES[32][3].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[32][3].key = 'sci2'
    YAML_PARSE_EXPECTED_NODES[32][3].value = '4.56e-3'

    // Test 33: Infinity and NaN (parsed as strings)
    YAML_PARSE_EXPECTED_NODES[33][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[33][1].childCount = 3
    YAML_PARSE_EXPECTED_NODES[33][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[33][2].key = 'inf_val'
    YAML_PARSE_EXPECTED_NODES[33][2].value = '.inf'
    YAML_PARSE_EXPECTED_NODES[33][3].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[33][3].key = 'neg_inf'
    YAML_PARSE_EXPECTED_NODES[33][3].value = '-.inf'
    YAML_PARSE_EXPECTED_NODES[33][4].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[33][4].key = 'not_num'
    YAML_PARSE_EXPECTED_NODES[33][4].value = '.nan'

    // Test 34: Inline comments (comments stripped but spaces preserved)
    YAML_PARSE_EXPECTED_NODES[34][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[34][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[34][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[34][2].key = 'name'
    YAML_PARSE_EXPECTED_NODES[34][2].value = 'John  '
    YAML_PARSE_EXPECTED_NODES[34][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[34][3].key = 'age'
    YAML_PARSE_EXPECTED_NODES[34][3].value = '30  '

    // Test 35: Full-line comments
    YAML_PARSE_EXPECTED_NODES[35][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[35][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[35][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[35][2].key = 'name'
    YAML_PARSE_EXPECTED_NODES[35][2].value = 'John'
    YAML_PARSE_EXPECTED_NODES[35][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[35][3].key = 'age'
    YAML_PARSE_EXPECTED_NODES[35][3].value = '30'

    // Test 36: Empty flow mapping
    YAML_PARSE_EXPECTED_NODES[36][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[36][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[36][2].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[36][2].key = 'data'
    YAML_PARSE_EXPECTED_NODES[36][2].childCount = 0

    // Test 37: Empty flow sequence
    YAML_PARSE_EXPECTED_NODES[37][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[37][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[37][2].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[37][2].key = 'items'
    YAML_PARSE_EXPECTED_NODES[37][2].childCount = 0

    // Test 38: Nested flow sequences
    YAML_PARSE_EXPECTED_NODES[38][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[38][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[38][2].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[38][2].childCount = 2
    YAML_PARSE_EXPECTED_NODES[38][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[38][3].value = '1'
    YAML_PARSE_EXPECTED_NODES[38][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[38][4].value = '2'
    YAML_PARSE_EXPECTED_NODES[38][5].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[38][5].childCount = 2
    YAML_PARSE_EXPECTED_NODES[38][6].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[38][6].value = '3'
    YAML_PARSE_EXPECTED_NODES[38][7].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[38][7].value = '4'

    // Test 39: Nested flow mappings
    YAML_PARSE_EXPECTED_NODES[39][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[39][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[39][2].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[39][2].key = 'outer'
    YAML_PARSE_EXPECTED_NODES[39][2].childCount = 1
    YAML_PARSE_EXPECTED_NODES[39][3].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[39][3].key = 'inner'
    YAML_PARSE_EXPECTED_NODES[39][3].value = 'value'

    // Test 40: Mixed flow in block
    YAML_PARSE_EXPECTED_NODES[40][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[40][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[40][2].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[40][2].key = 'coords'
    YAML_PARSE_EXPECTED_NODES[40][2].childCount = 3
    YAML_PARSE_EXPECTED_NODES[40][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[40][3].value = '1'
    YAML_PARSE_EXPECTED_NODES[40][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[40][4].value = '2'
    YAML_PARSE_EXPECTED_NODES[40][5].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[40][5].value = '3'
    YAML_PARSE_EXPECTED_NODES[40][6].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[40][6].key = 'name'
    YAML_PARSE_EXPECTED_NODES[40][6].value = 'point'

    // Test 41: Flow mapping in block sequence
    YAML_PARSE_EXPECTED_NODES[41][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[41][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[41][2].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[41][2].childCount = 2
    YAML_PARSE_EXPECTED_NODES[41][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[41][3].key = 'id'
    YAML_PARSE_EXPECTED_NODES[41][3].value = '1'
    YAML_PARSE_EXPECTED_NODES[41][4].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[41][4].key = 'name'
    YAML_PARSE_EXPECTED_NODES[41][4].value = 'Alice'
    YAML_PARSE_EXPECTED_NODES[41][5].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[41][5].childCount = 2
    YAML_PARSE_EXPECTED_NODES[41][6].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[41][6].key = 'id'
    YAML_PARSE_EXPECTED_NODES[41][6].value = '2'
    YAML_PARSE_EXPECTED_NODES[41][7].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[41][7].key = 'name'
    YAML_PARSE_EXPECTED_NODES[41][7].value = 'Bob'

    // Test 42: Complex nested block
    YAML_PARSE_EXPECTED_NODES[42][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[42][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[42][2].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[42][2].key = 'servers'
    YAML_PARSE_EXPECTED_NODES[42][2].childCount = 2
    YAML_PARSE_EXPECTED_NODES[42][3].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[42][3].key = 'production'
    YAML_PARSE_EXPECTED_NODES[42][3].childCount = 2
    YAML_PARSE_EXPECTED_NODES[42][4].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[42][4].key = 'host'
    YAML_PARSE_EXPECTED_NODES[42][4].value = 'prod.example.com'
    YAML_PARSE_EXPECTED_NODES[42][5].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[42][5].key = 'port'
    YAML_PARSE_EXPECTED_NODES[42][5].value = '443'
    YAML_PARSE_EXPECTED_NODES[42][6].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[42][6].key = 'staging'
    YAML_PARSE_EXPECTED_NODES[42][6].childCount = 2
    YAML_PARSE_EXPECTED_NODES[42][7].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[42][7].key = 'host'
    YAML_PARSE_EXPECTED_NODES[42][7].value = 'staging.example.com'
    YAML_PARSE_EXPECTED_NODES[42][8].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[42][8].key = 'port'
    YAML_PARSE_EXPECTED_NODES[42][8].value = '8080'

    // Test 43: Sequence with deeply mixed types
    YAML_PARSE_EXPECTED_NODES[43][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[43][1].childCount = 5
    YAML_PARSE_EXPECTED_NODES[43][2].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[43][2].value = '123'
    YAML_PARSE_EXPECTED_NODES[43][3].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[43][3].value = 'text'
    YAML_PARSE_EXPECTED_NODES[43][4].type = NAV_YAML_VALUE_TYPE_BOOLEAN
    YAML_PARSE_EXPECTED_NODES[43][4].value = 'true'
    YAML_PARSE_EXPECTED_NODES[43][5].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[43][5].childCount = 2
    YAML_PARSE_EXPECTED_NODES[43][6].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[43][6].value = '1'
    YAML_PARSE_EXPECTED_NODES[43][7].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[43][7].value = '2'
    YAML_PARSE_EXPECTED_NODES[43][8].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[43][8].childCount = 1
    YAML_PARSE_EXPECTED_NODES[43][9].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[43][9].key = 'key'
    YAML_PARSE_EXPECTED_NODES[43][9].value = 'value'

    // Test 44: Deep nesting level 10
    YAML_PARSE_EXPECTED_NODES[44][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[44][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[44][2].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[44][2].key = 'a'
    YAML_PARSE_EXPECTED_NODES[44][2].childCount = 1
    YAML_PARSE_EXPECTED_NODES[44][3].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[44][3].key = 'b'
    YAML_PARSE_EXPECTED_NODES[44][3].childCount = 1
    YAML_PARSE_EXPECTED_NODES[44][4].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[44][4].key = 'c'
    YAML_PARSE_EXPECTED_NODES[44][4].childCount = 1
    YAML_PARSE_EXPECTED_NODES[44][5].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[44][5].key = 'd'
    YAML_PARSE_EXPECTED_NODES[44][5].childCount = 1
    YAML_PARSE_EXPECTED_NODES[44][6].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[44][6].key = 'e'
    YAML_PARSE_EXPECTED_NODES[44][6].childCount = 1
    YAML_PARSE_EXPECTED_NODES[44][7].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[44][7].key = 'f'
    YAML_PARSE_EXPECTED_NODES[44][7].childCount = 1
    YAML_PARSE_EXPECTED_NODES[44][8].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[44][8].key = 'g'
    YAML_PARSE_EXPECTED_NODES[44][8].childCount = 1
    YAML_PARSE_EXPECTED_NODES[44][9].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[44][9].key = 'h'
    YAML_PARSE_EXPECTED_NODES[44][9].childCount = 1
    YAML_PARSE_EXPECTED_NODES[44][10].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[44][10].key = 'i'
    YAML_PARSE_EXPECTED_NODES[44][10].childCount = 1
    YAML_PARSE_EXPECTED_NODES[44][11].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[44][11].key = 'j'
    YAML_PARSE_EXPECTED_NODES[44][11].value = 'deep'

    // Test 45: Simple sequence continuation
    YAML_PARSE_EXPECTED_NODES[45][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[45][1].childCount = 3
    YAML_PARSE_EXPECTED_NODES[45][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[45][2].value = 'item1'
    YAML_PARSE_EXPECTED_NODES[45][3].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[45][3].value = 'item2'
    YAML_PARSE_EXPECTED_NODES[45][4].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[45][4].value = 'item3'

    // Test 46: Special characters in keys
    YAML_PARSE_EXPECTED_NODES[46][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[46][1].childCount = 3
    YAML_PARSE_EXPECTED_NODES[46][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[46][2].key = '127.0.0.1'
    YAML_PARSE_EXPECTED_NODES[46][2].value = 'localhost'
    YAML_PARSE_EXPECTED_NODES[46][3].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[46][3].key = 'my-key'
    YAML_PARSE_EXPECTED_NODES[46][3].value = 'value'
    YAML_PARSE_EXPECTED_NODES[46][4].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[46][4].key = 'my_key_2'
    YAML_PARSE_EXPECTED_NODES[46][4].value = 'value2'

    // Test 47: String that looks like number
    YAML_PARSE_EXPECTED_NODES[47][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[47][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[47][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[47][2].key = 'version'
    YAML_PARSE_EXPECTED_NODES[47][2].value = '1.0'

    // Test 48: String that looks like boolean
    YAML_PARSE_EXPECTED_NODES[48][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[48][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[48][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[48][2].key = 'status'
    YAML_PARSE_EXPECTED_NODES[48][2].value = 'false'

    // Test 49: Complex flow and block mix - Complete tree
    YAML_PARSE_EXPECTED_NODES[49][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[49][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[49][2].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[49][2].key = 'data'
    YAML_PARSE_EXPECTED_NODES[49][2].childCount = 2
    // First item {id: 1, tags: [a, b, c]}
    YAML_PARSE_EXPECTED_NODES[49][3].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[49][3].childCount = 2
    YAML_PARSE_EXPECTED_NODES[49][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[49][4].key = 'id'
    YAML_PARSE_EXPECTED_NODES[49][4].value = '1'
    YAML_PARSE_EXPECTED_NODES[49][5].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[49][5].key = 'tags'
    YAML_PARSE_EXPECTED_NODES[49][5].childCount = 3
    YAML_PARSE_EXPECTED_NODES[49][6].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[49][6].value = 'a'
    YAML_PARSE_EXPECTED_NODES[49][7].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[49][7].value = 'b'
    YAML_PARSE_EXPECTED_NODES[49][8].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[49][8].value = 'c'
    // Second item {id: 2, tags: [d, e, f]}
    YAML_PARSE_EXPECTED_NODES[49][9].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[49][9].childCount = 2
    YAML_PARSE_EXPECTED_NODES[49][10].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[49][10].key = 'id'
    YAML_PARSE_EXPECTED_NODES[49][10].value = '2'
    YAML_PARSE_EXPECTED_NODES[49][11].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[49][11].key = 'tags'
    YAML_PARSE_EXPECTED_NODES[49][11].childCount = 3
    YAML_PARSE_EXPECTED_NODES[49][12].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[49][12].value = 'd'
    YAML_PARSE_EXPECTED_NODES[49][13].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[49][13].value = 'e'
    YAML_PARSE_EXPECTED_NODES[49][14].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[49][14].value = 'f'

    // Test 50: Empty mappings in sequence
    YAML_PARSE_EXPECTED_NODES[50][1].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[50][1].childCount = 3
    YAML_PARSE_EXPECTED_NODES[50][2].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[50][2].childCount = 0
    YAML_PARSE_EXPECTED_NODES[50][3].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[50][3].childCount = 1
    YAML_PARSE_EXPECTED_NODES[50][4].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[50][4].key = 'name'
    YAML_PARSE_EXPECTED_NODES[50][4].value = 'test'
    YAML_PARSE_EXPECTED_NODES[50][5].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[50][5].childCount = 0

    // Test 51: Empty sequence in mapping
    YAML_PARSE_EXPECTED_NODES[51][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[51][1].childCount = 2
    YAML_PARSE_EXPECTED_NODES[51][2].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[51][2].key = 'empty'
    YAML_PARSE_EXPECTED_NODES[51][2].childCount = 0
    YAML_PARSE_EXPECTED_NODES[51][3].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[51][3].key = 'filled'
    YAML_PARSE_EXPECTED_NODES[51][3].childCount = 2
    YAML_PARSE_EXPECTED_NODES[51][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[51][4].value = '1'
    YAML_PARSE_EXPECTED_NODES[51][5].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[51][5].value = '2'

    // Test 52: Zero values
    YAML_PARSE_EXPECTED_NODES[52][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[52][1].childCount = 3
    YAML_PARSE_EXPECTED_NODES[52][2].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[52][2].key = 'zero_int'
    YAML_PARSE_EXPECTED_NODES[52][2].value = '0'
    YAML_PARSE_EXPECTED_NODES[52][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[52][3].key = 'zero_float'
    YAML_PARSE_EXPECTED_NODES[52][3].value = '0.0'
    YAML_PARSE_EXPECTED_NODES[52][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[52][4].key = 'neg_zero'
    YAML_PARSE_EXPECTED_NODES[52][4].value = '-0'

    // Test 53: Very long number
    YAML_PARSE_EXPECTED_NODES[53][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[53][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[53][2].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[53][2].key = 'large'
    YAML_PARSE_EXPECTED_NODES[53][2].value = '9223372036854775807'

    // Test 54: Matrix of sequences
    YAML_PARSE_EXPECTED_NODES[54][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[54][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[54][2].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[54][2].key = 'matrix'
    YAML_PARSE_EXPECTED_NODES[54][2].childCount = 3
    YAML_PARSE_EXPECTED_NODES[54][3].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[54][3].childCount = 3
    YAML_PARSE_EXPECTED_NODES[54][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[54][4].value = '1'
    YAML_PARSE_EXPECTED_NODES[54][5].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[54][5].value = '2'
    YAML_PARSE_EXPECTED_NODES[54][6].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[54][6].value = '3'
    YAML_PARSE_EXPECTED_NODES[54][7].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[54][7].childCount = 3
    YAML_PARSE_EXPECTED_NODES[54][8].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[54][8].value = '4'
    YAML_PARSE_EXPECTED_NODES[54][9].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[54][9].value = '5'
    YAML_PARSE_EXPECTED_NODES[54][10].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[54][10].value = '6'
    YAML_PARSE_EXPECTED_NODES[54][11].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    YAML_PARSE_EXPECTED_NODES[54][11].childCount = 3
    YAML_PARSE_EXPECTED_NODES[54][12].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[54][12].value = '7'
    YAML_PARSE_EXPECTED_NODES[54][13].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[54][13].value = '8'
    YAML_PARSE_EXPECTED_NODES[54][14].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[54][14].value = '9'

    // Test 55: Compact mapping
    YAML_PARSE_EXPECTED_NODES[55][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[55][1].childCount = 5
    YAML_PARSE_EXPECTED_NODES[55][2].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[55][2].key = 'a'
    YAML_PARSE_EXPECTED_NODES[55][2].value = '1'
    YAML_PARSE_EXPECTED_NODES[55][3].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[55][3].key = 'b'
    YAML_PARSE_EXPECTED_NODES[55][3].value = '2'
    YAML_PARSE_EXPECTED_NODES[55][4].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[55][4].key = 'c'
    YAML_PARSE_EXPECTED_NODES[55][4].value = '3'
    YAML_PARSE_EXPECTED_NODES[55][5].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[55][5].key = 'd'
    YAML_PARSE_EXPECTED_NODES[55][5].value = '4'
    YAML_PARSE_EXPECTED_NODES[55][6].type = NAV_YAML_VALUE_TYPE_NUMBER
    YAML_PARSE_EXPECTED_NODES[55][6].key = 'e'
    YAML_PARSE_EXPECTED_NODES[55][6].value = '5'

    // Test 56: Empty string "" using $QT$ syntax
    YAML_PARSE_EXPECTED_NODES[56][1].type = NAV_YAML_VALUE_TYPE_MAPPING
    YAML_PARSE_EXPECTED_NODES[56][1].childCount = 1
    YAML_PARSE_EXPECTED_NODES[56][2].type = NAV_YAML_VALUE_TYPE_STRING
    YAML_PARSE_EXPECTED_NODES[56][2].key = 'text'
    YAML_PARSE_EXPECTED_NODES[56][2].value = ''

    set_length_array(YAML_PARSE_EXPECTED_NODES, 56)
}


DEFINE_CONSTANT

constant char YAML_PARSE_EXPECTED_RESULT[56] = {
    true,   // Test 1: Empty mapping
    true,   // Test 2: Simple mapping
    true,   // Test 3: Multiple properties
    true,   // Test 4: Empty sequence
    true,   // Test 5: Number sequence
    true,   // Test 6: Mixed sequence
    true,   // Test 7: Nested mapping
    true,   // Test 8: Nested sequence
    true,   // Test 9: Sequence of mappings
    true,   // Test 10: Mapping with sequence
    true,   // Test 11: All literals
    true,   // Test 12: Decimal numbers
    true,   // Test 13: Negative numbers
    true,   // Test 14: Flow sequence
    true,   // Test 15: Flow mapping
    true,   // Test 16: Deep nesting
    true,   // Test 17: Large sequence
    true,   // Test 18: Complex structure
    false,  // Test 19: Invalid - trailing comma
    false,  // Test 20: Invalid - unclosed bracket
    true,   // Test 21: Single-quoted string
    true,   // Test 22: Double-quoted string
    true,   // Test 23: Escape sequences
    true,   // Test 24: Empty string
    true,   // Test 25: Boolean yes/no
    true,   // Test 26: Boolean on/off
    true,   // Test 27: Boolean mixed case
    true,   // Test 28: Null variants
    true,   // Test 29: Positive numbers
    true,   // Test 30: Hexadecimal
    true,   // Test 31: Octal
    true,   // Test 32: Scientific notation
    true,   // Test 33: Infinity/NaN
    true,   // Test 34: Inline comments
    true,   // Test 35: Full-line comments
    true,   // Test 36: Empty flow mapping
    true,   // Test 37: Empty flow sequence
    true,   // Test 38: Nested flow sequences
    true,   // Test 39: Nested flow mappings
    true,   // Test 40: Mixed flow in block
    true,   // Test 41: Flow in block sequence
    true,   // Test 42: Complex nested block
    true,   // Test 43: Mixed types sequence
    true,   // Test 44: Deep nesting level 10
    true,   // Test 45: Sequence continuation
    true,   // Test 46: Special chars in keys
    true,   // Test 47: String like number
    true,   // Test 48: String like boolean
    true,   // Test 49: Flow/block mix
    true,   // Test 50: Empty mappings in sequence
    true,   // Test 51: Empty sequence in mapping
    true,   // Test 52: Zero values
    true,   // Test 53: Very long number
    true,   // Test 54: Matrix sequences
    true,   // Test 55: Compact mapping
    true    // Test 56: Empty string with $QT$ syntax
}

constant integer YAML_PARSE_EXPECTED_NODE_COUNT[56] = {
    1,      // Test 1: {} = 1 node
    2,      // Test 2: {name:string} = 2 nodes
    4,      // Test 3: {name:string, age:number, active:bool} = 4 nodes
    1,      // Test 4: [] = 1 node
    6,      // Test 5: [1,2,3,4,5] = 6 nodes
    6,      // Test 6: [1,"two",true,null,false] = 6 nodes
    4,      // Test 7: {user:{name:string, age:number}} = 4 nodes
    7,      // Test 8: [[1,2],[3,4]] = 7 nodes
    5,      // Test 9: [{id:1},{id:2}] = 5 nodes
    6,      // Test 10: {numbers:[1,2,3],count:3} = 6 nodes
    4,      // Test 11: {null:null, true:true, false:false} = 4 nodes
    3,      // Test 12: {pi:3.14, e:2.718} = 3 nodes
    4,      // Test 13: [-1,-42,-999] = 4 nodes
    7,      // Test 14: {items:[1,2,3,4,5]} = 7 nodes
    4,      // Test 15: {server:{host:string, port:number}} = 4 nodes
    6,      // Test 16: Deep nesting 5 levels = 6 nodes
    11,     // Test 17: [1,2,3,4,5,6,7,8,9,10] = 11 nodes
    9,      // Test 18: Complex structure = 9 nodes
    0,      // Test 19: Error case
    0,      // Test 20: Error case
    2,      // Test 21: Single-quoted = 2 nodes
    2,      // Test 22: Double-quoted = 2 nodes
    2,      // Test 23: Escape sequences = 2 nodes
    2,      // Test 24: Empty string = 2 nodes
    3,      // Test 25: yes/no = 3 nodes
    3,      // Test 26: on/off = 3 nodes
    5,      // Test 27: Mixed case booleans = 5 nodes
    5,      // Test 28: Null variants = 5 nodes
    4,      // Test 29: Positive numbers = 4 nodes
    3,      // Test 30: Hexadecimal = 3 nodes
    3,      // Test 31: Octal = 3 nodes
    3,      // Test 32: Scientific = 3 nodes
    4,      // Test 33: Infinity/NaN = 4 nodes
    3,      // Test 34: Inline comments = 3 nodes
    3,      // Test 35: Full-line comments = 3 nodes
    2,      // Test 36: Empty flow mapping = 2 nodes
    2,      // Test 37: Empty flow sequence = 2 nodes
    7,      // Test 38: Nested flow sequences = 7 nodes
    3,      // Test 39: Nested flow mappings = 3 nodes
    6,      // Test 40: Mixed flow/block = 6 nodes
    7,      // Test 41: Flow in block sequence = 7 nodes
    8,      // Test 42: Complex nested block = 8 nodes
    9,      // Test 43: Mixed types = 9 nodes
    11,     // Test 44: Deep nesting level 10 = 11 nodes
    4,      // Test 45: Sequence continuation = 4 nodes
    4,      // Test 46: Special chars = 4 nodes
    2,      // Test 47: String like number = 2 nodes
    2,      // Test 48: String like boolean = 2 nodes
    14,     // Test 49: Flow/block mix = 14 nodes
    5,      // Test 50: Empty mappings = 5 nodes
    5,      // Test 51: Empty sequence = 5 nodes
    4,      // Test 52: Zero values = 4 nodes
    2,      // Test 53: Very long number = 2 nodes
    14,     // Test 54: Matrix = 14 nodes
    6,      // Test 55: Compact mapping = 6 nodes
    2       // Test 56: Empty string with $QT$ = 2 nodes
}

constant integer YAML_PARSE_EXPECTED_ROOT_TYPE[56] = {
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 1
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 2
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 3
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 4
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 5
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 6
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 7
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 8
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 9
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 10
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 11
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 12
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 13
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 14
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 15
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 16
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 17
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 18
    0,                              // Test 19: Error
    0,                              // Test 20: Error
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 21
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 22
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 23
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 24
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 25
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 26
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 27
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 28
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 29
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 30
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 31
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 32
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 33
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 34
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 35
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 36
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 37
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 38
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 39
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 40
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 41
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 42
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 43
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 44
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 45
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 46
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 47
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 48
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 49
    NAV_YAML_VALUE_TYPE_SEQUENCE,   // Test 50
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 51
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 52
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 53
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 54
    NAV_YAML_VALUE_TYPE_MAPPING,    // Test 55
    NAV_YAML_VALUE_TYPE_MAPPING     // Test 56
}

constant integer YAML_PARSE_EXPECTED_ROOT_CHILD_COUNT[56] = {
    0,      // Test 1: {} = 0 children
    1,      // Test 2: {name:...} = 1 child
    3,      // Test 3: {name:..., age:..., active:...} = 3 children
    0,      // Test 4: [] = 0 children
    5,      // Test 5: [1,2,3,4,5] = 5 children
    5,      // Test 6: [1,"two",true,null,false] = 5 children
    1,      // Test 7: {user:{...}} = 1 child
    2,      // Test 8: [[1,2],[3,4]] = 2 children
    2,      // Test 9: [{id:1},{id:2}] = 2 children
    2,      // Test 10: {numbers:[...], count:...} = 2 children
    3,      // Test 11: {null:..., true:..., false:...} = 3 children
    2,      // Test 12: {pi:..., e:...} = 2 children
    3,      // Test 13: [-1,-42,-999] = 3 children
    1,      // Test 14: {items:[...]} = 1 child
    1,      // Test 15: {server:{...}} = 1 child
    1,      // Test 16: {a:{...}} = 1 child
    10,     // Test 17: [1,2,3,4,5,6,7,8,9,10] = 10 children
    2,      // Test 18: {users:[...], count:...} = 2 children
    0,      // Test 19: Error
    0,      // Test 20: Error
    1,      // Test 21: {message:...} = 1 child
    1,      // Test 22: {message:...} = 1 child
    1,      // Test 23: {message:...} = 1 child
    1,      // Test 24: {empty:...} = 1 child
    2,      // Test 25: {yes:..., no:...} = 2 children
    2,      // Test 26: {on:..., off:...} = 2 children
    4,      // Test 27: {bool1, bool2, bool3, bool4} = 4 children
    4,      // Test 28: {null1, null2, null3, null4} = 4 children
    3,      // Test 29: [+1, +42, +3.14] = 3 children
    2,      // Test 30: {hex, hex2} = 2 children
    2,      // Test 31: {octal, octal2} = 2 children
    2,      // Test 32: {sci1, sci2} = 2 children
    3,      // Test 33: {inf, neg_inf, nan} = 3 children
    2,      // Test 34: {name, age} = 2 children
    2,      // Test 35: {name, age} = 2 children
    1,      // Test 36: {data:{}} = 1 child
    1,      // Test 37: {items:[]} = 1 child
    2,      // Test 38: [[1,2],[3,4]] = 2 children
    1,      // Test 39: {outer:{...}} = 1 child
    2,      // Test 40: {coords:[...], name:...} = 2 children
    2,      // Test 41: [{...}, {...}] = 2 children
    1,      // Test 42: {servers:{...}} = 1 child
    5,      // Test 43: [123, text, true, [...], {...}] = 5 children
    1,      // Test 44: {a:{...}} = 1 child
    3,      // Test 45: [item1, item2, item3] = 3 children
    3,      // Test 46: {127.0.0.1, my-key, my_key_2} = 3 children
    1,      // Test 47: {version:...} = 1 child
    1,      // Test 48: {status:...} = 1 child
    1,      // Test 49: {data:[...]} = 1 child
    3,      // Test 50: [{}, {...}, {}] = 3 children
    2,      // Test 51: {empty:[], filled:[...]} = 2 children
    3,      // Test 52: {zero_int, zero_float, neg_zero} = 3 children
    1,      // Test 53: {large:...} = 1 child
    1,      // Test 54: {matrix:[...]} = 1 child
    5,      // Test 55: {a,b,c,d,e} = 5 children
    1       // Test 56: {text:""} = 1 child
}

/**
 * Recursively validate all nodes in the YAML tree against expected values
 * Returns the next index to use (or 0 on validation failure)
 */
define_function integer ValidateYamlTreeRecursive(_NAVYaml yaml,
                                                   _NAVYamlNode node,
                                                   _NAVYamlNode expectedNodes[],
                                                   integer expectedCount,
                                                   integer index,
                                                   integer depth) {
    stack_var _NAVYamlNode child
    stack_var integer nextIndex
    stack_var char indent[128]
    stack_var integer i

    if (index > expectedCount) {
        return 0  // Validation failed
    }

    #IF_DEFINED DEBUG_YAML_TREE_VALIDATION
    // Build indentation string based on depth
    indent = ''
    for (i = 1; i <= depth; i++) {
        indent = "indent, '  '"
    }

    // Log node validation with proper indentation
    if (length_array(node.key) > 0) {
        NAVLog("indent, 'Validating: ', NAVYamlGetNodeType(node.type), ' "', node.key, '"'")
    }
    else {
        NAVLog("indent, 'Validating: ', NAVYamlGetNodeType(node.type)")
    }
    #END_IF

    // Assert current node against expected
    if (!NAVAssertIntegerEqual('Node type', expectedNodes[index].type, node.type)) {
        return 0
    }

    if (!NAVAssertStringEqual('Node key', expectedNodes[index].key, node.key)) {
        return 0
    }

    if (!NAVAssertIntegerEqual('Node childCount', expectedNodes[index].childCount, node.childCount)) {
        return 0
    }

    // Assert values based on type
    select {
        active (node.type == NAV_YAML_VALUE_TYPE_STRING): {
            #IF_DEFINED DEBUG_YAML_TREE_VALIDATION
            NAVLog("indent, '  = "', node.value, '"'")
            #END_IF

            if (!NAVAssertStringEqual('String value', expectedNodes[index].value, node.value)) {
                return 0
            }
        }
        active (node.type == NAV_YAML_VALUE_TYPE_NUMBER): {
            #IF_DEFINED DEBUG_YAML_TREE_VALIDATION
            NAVLog("indent, '  = ', node.value")
            #END_IF

            if (!NAVAssertStringEqual('Number value', expectedNodes[index].value, node.value)) {
                return 0
            }
        }
        active (node.type == NAV_YAML_VALUE_TYPE_BOOLEAN): {
            #IF_DEFINED DEBUG_YAML_TREE_VALIDATION
            NAVLog("indent, '  = ', node.value")
            #END_IF

            if (!NAVAssertStringEqual('Boolean value', expectedNodes[index].value, node.value)) {
                return 0
            }
        }
    }

    nextIndex = index + 1  // Move to next node in depth-first order

    // Recurse into children (depth-first)
    if (node.childCount > 0) {
        if (NAVYamlGetFirstChild(yaml, node, child)) {
            while (true) {
                nextIndex = ValidateYamlTreeRecursive(yaml,
                                                      child,
                                                      expectedNodes,
                                                      expectedCount,
                                                      nextIndex,
                                                      depth + 1)

                if (nextIndex == 0) {
                    return 0  // Validation failed in child
                }

                if (!NAVYamlGetNextSibling(yaml, child, child)) {
                    break
                }
            }
        }
    }

    return nextIndex  // Return next available index
}

/**
 * Validate entire YAML tree against expected node array
 */
define_function char ValidateYamlTree(_NAVYaml yaml, integer testNum) {
    stack_var _NAVYamlNode root
    stack_var integer result

    // Only validate valid test cases (skip error tests 19-20)
    if (testNum < 1 || testNum > 56 || testNum == 19 || testNum == 20) {
        return true  // Skip invalid/error test cases
    }

    if (!NAVYamlGetRootNode(yaml, root)) {
        return false
    }

    result = ValidateYamlTreeRecursive(yaml,
                                       root,
                                       YAML_PARSE_EXPECTED_NODES[testNum],
                                       YAML_PARSE_EXPECTED_NODE_COUNT[testNum],
                                       1,
                                       0)

    return result != 0  // Success if result > 0
}

define_function TestNAVYamlParse() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlParse'")

    InitializeYamlParseTestData()

    for (x = 1; x <= length_array(YAML_PARSE_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var char result

        result = NAVYamlParse(YAML_PARSE_TEST[x], yaml)

        // Assert parse result matches expected
        if (!NAVAssertBooleanEqual('Parse result should match expected',
                                    YAML_PARSE_EXPECTED_RESULT[x],
                                    result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_PARSE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        // For error cases, skip further validation
        if (!YAML_PARSE_EXPECTED_RESULT[x]) {
            NAVLogTestPassed(x)
            continue
        }

        // Assert node count
        if (!NAVAssertIntegerEqual('Node count should match expected',
                                    YAML_PARSE_EXPECTED_NODE_COUNT[x],
                                    yaml.nodeCount)) {
            NAVLogTestFailed(x,
                            itoa(YAML_PARSE_EXPECTED_NODE_COUNT[x]),
                            itoa(yaml.nodeCount))
            continue
        }

        // Assert root index is valid
        if (!NAVAssertIntegerGreaterThan('Root index should be positive',
                                         0,
                                         yaml.rootIndex)) {
            NAVLogTestFailed(x, '> 0', itoa(yaml.rootIndex))
            continue
        }

        // Assert root type
        if (!NAVAssertIntegerEqual('Root type should match expected',
                                    YAML_PARSE_EXPECTED_ROOT_TYPE[x],
                                    yaml.nodes[yaml.rootIndex].type)) {
            NAVLogTestFailed(x,
                            itoa(YAML_PARSE_EXPECTED_ROOT_TYPE[x]),
                            itoa(yaml.nodes[yaml.rootIndex].type))
            continue
        }

        // Assert root child count
        if (!NAVAssertIntegerEqual('Root childCount should match expected',
                                    YAML_PARSE_EXPECTED_ROOT_CHILD_COUNT[x],
                                    yaml.nodes[yaml.rootIndex].childCount)) {
            NAVLogTestFailed(x,
                            itoa(YAML_PARSE_EXPECTED_ROOT_CHILD_COUNT[x]),
                            itoa(yaml.nodes[yaml.rootIndex].childCount))
            continue
        }

        // Validate entire tree structure using recursive traversal
        if (!ValidateYamlTree(yaml, x)) {
            NAVLogTestFailed(x, 'Tree validation', 'failed')
            continue
        }

        // Assert no error message
        if (!NAVAssertStringEqual('Error should be empty',
                                   '',
                                   yaml.error)) {
            NAVLogTestFailed(x, '(empty)', yaml.error)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlParse'")
}
