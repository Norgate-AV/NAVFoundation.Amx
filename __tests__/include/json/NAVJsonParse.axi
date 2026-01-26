PROGRAM_NAME='NAVJsonParse'

#include 'NAVFoundation.Json.axi'

// Uncomment to enable detailed tree validation debug logging
// #DEFINE DEBUG_JSON_TREE_VALIDATION


DEFINE_VARIABLE

volatile char JSON_PARSE_TEST[25][1024]
volatile _NAVJsonNode JSON_PARSE_EXPECTED_NODES[25][50]  // Max 50 nodes per test

define_function InitializeJsonParseTestData() {
    // Test 1: Empty object
    JSON_PARSE_TEST[1] = '{}'

    // Test 2: Simple object with one property
    JSON_PARSE_TEST[2] = '{"name":"John"}'

    // Test 3: Object with multiple properties
    JSON_PARSE_TEST[3] = '{"name":"John","age":30,"active":true}'

    // Test 4: Empty array
    JSON_PARSE_TEST[4] = '[]'

    // Test 5: Array with numbers
    JSON_PARSE_TEST[5] = '[1,2,3,4,5]'

    // Test 6: Array with mixed types
    JSON_PARSE_TEST[6] = '[1,"two",true,null,false]'

    // Test 7: Nested object
    JSON_PARSE_TEST[7] = '{"user":{"name":"John","age":30}}'

    // Test 8: Nested array
    JSON_PARSE_TEST[8] = '[[1,2],[3,4]]'

    // Test 9: Array of objects
    JSON_PARSE_TEST[9] = '[{"id":1},{"id":2}]'

    // Test 10: Object with array
    JSON_PARSE_TEST[10] = '{"numbers":[1,2,3],"count":3}'

    // Test 11: All literal types
    JSON_PARSE_TEST[11] = '{"null":null,"true":true,"false":false}'

    // Test 12: Numbers with decimals
    JSON_PARSE_TEST[12] = '{"pi":3.14,"e":2.718}'

    // Test 13: Negative numbers
    JSON_PARSE_TEST[13] = '[-1,-42,-999]'

    // Test 14: Numbers with exponents
    JSON_PARSE_TEST[14] = '[1e10,2.5E-3,1.23e+4]'

    // Test 15: String with escapes
    JSON_PARSE_TEST[15] = '{"text":"Hello\nWorld"}'

    // Test 16: Deep nesting (depth 5)
    JSON_PARSE_TEST[16] = '{"a":{"b":{"c":{"d":{"e":1}}}}}'

    // Test 17: Large array
    JSON_PARSE_TEST[17] = '[1,2,3,4,5,6,7,8,9,10]'

    // Test 18: Complex nested structure
    JSON_PARSE_TEST[18] = '{"users":[{"name":"John","age":30},{"name":"Jane","age":25}],"count":2}'

    // Test 19: Empty strings
    JSON_PARSE_TEST[19] = '{"empty":"","also":""}'

    // Test 20: Zero values
    JSON_PARSE_TEST[20] = '[0,0.0,-0]'

    // Test 21: Invalid - unterminated string
    JSON_PARSE_TEST[21] = '{"name":"John'

    // Test 22: Invalid - unexpected character
    JSON_PARSE_TEST[22] = '{@}'

    // Test 23: Invalid - trailing comma in object
    JSON_PARSE_TEST[23] = '{"name":"John",}'

    // Test 24: Invalid - missing colon
    JSON_PARSE_TEST[24] = '{"name" "John"}'

    // Test 25: Invalid - extra token after root
    JSON_PARSE_TEST[25] = '{}extra'

    set_length_array(JSON_PARSE_TEST, 25)

    InitializeExpectedNodes()
}

define_function InitializeExpectedNodes() {
    // Test 1: {}
    // Node 1: root object
    JSON_PARSE_EXPECTED_NODES[1][1].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[1][1].key = ''
    JSON_PARSE_EXPECTED_NODES[1][1].childCount = 0

    // Test 2: {"name":"John"}
    // Node 1: root object
    JSON_PARSE_EXPECTED_NODES[2][1].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[2][1].key = ''
    JSON_PARSE_EXPECTED_NODES[2][1].childCount = 1
    // Node 2: "name":"John"
    JSON_PARSE_EXPECTED_NODES[2][2].type = NAV_JSON_VALUE_TYPE_STRING
    JSON_PARSE_EXPECTED_NODES[2][2].key = 'name'
    JSON_PARSE_EXPECTED_NODES[2][2].value = 'John'
    JSON_PARSE_EXPECTED_NODES[2][2].childCount = 0

    // Test 3: {"name":"John","age":30,"active":true}
    // Node 1: root object
    JSON_PARSE_EXPECTED_NODES[3][1].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[3][1].key = ''
    JSON_PARSE_EXPECTED_NODES[3][1].childCount = 3
    // Node 2: "name":"John"
    JSON_PARSE_EXPECTED_NODES[3][2].type = NAV_JSON_VALUE_TYPE_STRING
    JSON_PARSE_EXPECTED_NODES[3][2].key = 'name'
    JSON_PARSE_EXPECTED_NODES[3][2].value = 'John'
    // Node 3: "age":30
    JSON_PARSE_EXPECTED_NODES[3][3].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[3][3].key = 'age'
    JSON_PARSE_EXPECTED_NODES[3][3].value = '30'
    // Node 4: "active":true
    JSON_PARSE_EXPECTED_NODES[3][4].type = NAV_JSON_VALUE_TYPE_TRUE
    JSON_PARSE_EXPECTED_NODES[3][4].key = 'active'
    JSON_PARSE_EXPECTED_NODES[3][4].value = 'true'

    // Test 4: []
    // Node 1: root array
    JSON_PARSE_EXPECTED_NODES[4][1].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[4][1].key = ''
    JSON_PARSE_EXPECTED_NODES[4][1].childCount = 0

    // Test 5: [1,2,3,4,5]
    // Node 1: root array
    JSON_PARSE_EXPECTED_NODES[5][1].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[5][1].key = ''
    JSON_PARSE_EXPECTED_NODES[5][1].childCount = 5
    // Nodes 2-6: numbers
    JSON_PARSE_EXPECTED_NODES[5][2].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[5][2].value = '1'
    JSON_PARSE_EXPECTED_NODES[5][3].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[5][3].value = '2'
    JSON_PARSE_EXPECTED_NODES[5][4].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[5][4].value = '3'
    JSON_PARSE_EXPECTED_NODES[5][5].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[5][5].value = '4'
    JSON_PARSE_EXPECTED_NODES[5][6].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[5][6].value = '5'

    // Test 6: [1,"two",true,null,false]
    // Node 1: root array
    JSON_PARSE_EXPECTED_NODES[6][1].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[6][1].key = ''
    JSON_PARSE_EXPECTED_NODES[6][1].childCount = 5
    // Node 2: 1
    JSON_PARSE_EXPECTED_NODES[6][2].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[6][2].value = '1'
    // Node 3: "two"
    JSON_PARSE_EXPECTED_NODES[6][3].type = NAV_JSON_VALUE_TYPE_STRING
    JSON_PARSE_EXPECTED_NODES[6][3].value = 'two'
    // Node 4: true
    JSON_PARSE_EXPECTED_NODES[6][4].type = NAV_JSON_VALUE_TYPE_TRUE
    JSON_PARSE_EXPECTED_NODES[6][4].value = 'true'
    // Node 5: null
    JSON_PARSE_EXPECTED_NODES[6][5].type = NAV_JSON_VALUE_TYPE_NULL
    // Node 6: false
    JSON_PARSE_EXPECTED_NODES[6][6].type = NAV_JSON_VALUE_TYPE_FALSE
    JSON_PARSE_EXPECTED_NODES[6][6].value = 'false'

    // Test 7: {"user":{"name":"John","age":30}}
    // Node 1: root object
    JSON_PARSE_EXPECTED_NODES[7][1].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[7][1].childCount = 1
    // Node 2: "user": object
    JSON_PARSE_EXPECTED_NODES[7][2].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[7][2].key = 'user'
    JSON_PARSE_EXPECTED_NODES[7][2].childCount = 2
    // Node 3: "name":"John"
    JSON_PARSE_EXPECTED_NODES[7][3].type = NAV_JSON_VALUE_TYPE_STRING
    JSON_PARSE_EXPECTED_NODES[7][3].key = 'name'
    JSON_PARSE_EXPECTED_NODES[7][3].value = 'John'
    // Node 4: "age":30
    JSON_PARSE_EXPECTED_NODES[7][4].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[7][4].key = 'age'
    JSON_PARSE_EXPECTED_NODES[7][4].value = '30'

    // Test 8: [[1,2],[3,4]]
    // Node 1: root array
    JSON_PARSE_EXPECTED_NODES[8][1].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[8][1].childCount = 2
    // Node 2: [1,2]
    JSON_PARSE_EXPECTED_NODES[8][2].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[8][2].childCount = 2
    // Node 3: 1
    JSON_PARSE_EXPECTED_NODES[8][3].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[8][3].value = '1'
    // Node 4: 2
    JSON_PARSE_EXPECTED_NODES[8][4].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[8][4].value = '2'
    // Node 5: [3,4]
    JSON_PARSE_EXPECTED_NODES[8][5].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[8][5].childCount = 2
    // Node 6: 3
    JSON_PARSE_EXPECTED_NODES[8][6].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[8][6].value = '3'
    // Node 7: 4
    JSON_PARSE_EXPECTED_NODES[8][7].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[8][7].value = '4'

    // Test 9: [{"id":1},{"id":2}]
    // Node 1: root array
    JSON_PARSE_EXPECTED_NODES[9][1].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[9][1].childCount = 2
    // Node 2: {"id":1}
    JSON_PARSE_EXPECTED_NODES[9][2].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[9][2].childCount = 1
    // Node 3: "id":1
    JSON_PARSE_EXPECTED_NODES[9][3].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[9][3].key = 'id'
    JSON_PARSE_EXPECTED_NODES[9][3].value = '1'
    // Node 4: {"id":2}
    JSON_PARSE_EXPECTED_NODES[9][4].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[9][4].childCount = 1
    // Node 5: "id":2
    JSON_PARSE_EXPECTED_NODES[9][5].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[9][5].key = 'id'
    JSON_PARSE_EXPECTED_NODES[9][5].value = '2'

    // Test 10: {"numbers":[1,2,3],"count":3}
    // Node 1: root object
    JSON_PARSE_EXPECTED_NODES[10][1].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[10][1].childCount = 2
    // Node 2: "numbers":[1,2,3]
    JSON_PARSE_EXPECTED_NODES[10][2].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[10][2].key = 'numbers'
    JSON_PARSE_EXPECTED_NODES[10][2].childCount = 3
    // Node 3: 1
    JSON_PARSE_EXPECTED_NODES[10][3].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[10][3].value = '1'
    // Node 4: 2
    JSON_PARSE_EXPECTED_NODES[10][4].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[10][4].value = '2'
    // Node 5: 3
    JSON_PARSE_EXPECTED_NODES[10][5].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[10][5].value = '3'
    // Node 6: "count":3
    JSON_PARSE_EXPECTED_NODES[10][6].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[10][6].key = 'count'
    JSON_PARSE_EXPECTED_NODES[10][6].value = '3'

    // Test 11: {"null":null,"true":true,"false":false}
    // Node 1: root object
    JSON_PARSE_EXPECTED_NODES[11][1].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[11][1].childCount = 3
    // Node 2: "null":null
    JSON_PARSE_EXPECTED_NODES[11][2].type = NAV_JSON_VALUE_TYPE_NULL
    JSON_PARSE_EXPECTED_NODES[11][2].key = 'null'
    // Node 3: "true":true
    JSON_PARSE_EXPECTED_NODES[11][3].type = NAV_JSON_VALUE_TYPE_TRUE
    JSON_PARSE_EXPECTED_NODES[11][3].key = 'true'
    JSON_PARSE_EXPECTED_NODES[11][3].value = 'true'
    // Node 4: "false":false
    JSON_PARSE_EXPECTED_NODES[11][4].type = NAV_JSON_VALUE_TYPE_FALSE
    JSON_PARSE_EXPECTED_NODES[11][4].key = 'false'
    JSON_PARSE_EXPECTED_NODES[11][4].value = 'false'

    // Test 12: {"pi":3.14,"e":2.718}
    // Node 1: root object
    JSON_PARSE_EXPECTED_NODES[12][1].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[12][1].childCount = 2
    // Node 2: "pi":3.14
    JSON_PARSE_EXPECTED_NODES[12][2].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[12][2].key = 'pi'
    JSON_PARSE_EXPECTED_NODES[12][2].value = '3.14'
    // Node 3: "e":2.718
    JSON_PARSE_EXPECTED_NODES[12][3].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[12][3].key = 'e'
    JSON_PARSE_EXPECTED_NODES[12][3].value = '2.718'

    // Test 13: [-1,-42,-999]
    // Node 1: root array
    JSON_PARSE_EXPECTED_NODES[13][1].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[13][1].childCount = 3
    // Node 2: -1
    JSON_PARSE_EXPECTED_NODES[13][2].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[13][2].value = '-1'
    // Node 3: -42
    JSON_PARSE_EXPECTED_NODES[13][3].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[13][3].value = '-42'
    // Node 4: -999
    JSON_PARSE_EXPECTED_NODES[13][4].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[13][4].value = '-999'

    // Test 14: [1e10,2.5E-3,1.23e+4]
    // Node 1: root array
    JSON_PARSE_EXPECTED_NODES[14][1].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[14][1].childCount = 3
    // Node 2: 1e10
    JSON_PARSE_EXPECTED_NODES[14][2].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[14][2].value = '1e10'
    // Node 3: 2.5E-3
    JSON_PARSE_EXPECTED_NODES[14][3].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[14][3].value = '2.5E-3'
    // Node 4: 1.23e+4
    JSON_PARSE_EXPECTED_NODES[14][4].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[14][4].value = '1.23e+4'

    // Test 15: {"text":"Hello\nWorld"}
    // Node 1: root object
    JSON_PARSE_EXPECTED_NODES[15][1].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[15][1].childCount = 1
    // Node 2: "text":"Hello\nWorld"
    JSON_PARSE_EXPECTED_NODES[15][2].type = NAV_JSON_VALUE_TYPE_STRING
    JSON_PARSE_EXPECTED_NODES[15][2].key = 'text'
    JSON_PARSE_EXPECTED_NODES[15][2].value = "'Hello', $0A, 'World'"

    // Test 16: {"a":{"b":{"c":{"d":{"e":1}}}}}
    // Node 1: root object
    JSON_PARSE_EXPECTED_NODES[16][1].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[16][1].childCount = 1
    // Node 2: "a":{...}
    JSON_PARSE_EXPECTED_NODES[16][2].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[16][2].key = 'a'
    JSON_PARSE_EXPECTED_NODES[16][2].childCount = 1
    // Node 3: "b":{...}
    JSON_PARSE_EXPECTED_NODES[16][3].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[16][3].key = 'b'
    JSON_PARSE_EXPECTED_NODES[16][3].childCount = 1
    // Node 4: "c":{...}
    JSON_PARSE_EXPECTED_NODES[16][4].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[16][4].key = 'c'
    JSON_PARSE_EXPECTED_NODES[16][4].childCount = 1
    // Node 5: "d":{...}
    JSON_PARSE_EXPECTED_NODES[16][5].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[16][5].key = 'd'
    JSON_PARSE_EXPECTED_NODES[16][5].childCount = 1
    // Node 6: "e":1
    JSON_PARSE_EXPECTED_NODES[16][6].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[16][6].key = 'e'
    JSON_PARSE_EXPECTED_NODES[16][6].value = '1'

    // Test 17: [1,2,3,4,5,6,7,8,9,10]
    // Node 1: root array
    JSON_PARSE_EXPECTED_NODES[17][1].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[17][1].childCount = 10
    // Nodes 2-11: numbers 1-10
    JSON_PARSE_EXPECTED_NODES[17][2].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[17][2].value = '1'
    JSON_PARSE_EXPECTED_NODES[17][3].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[17][3].value = '2'
    JSON_PARSE_EXPECTED_NODES[17][4].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[17][4].value = '3'
    JSON_PARSE_EXPECTED_NODES[17][5].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[17][5].value = '4'
    JSON_PARSE_EXPECTED_NODES[17][6].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[17][6].value = '5'
    JSON_PARSE_EXPECTED_NODES[17][7].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[17][7].value = '6'
    JSON_PARSE_EXPECTED_NODES[17][8].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[17][8].value = '7'
    JSON_PARSE_EXPECTED_NODES[17][9].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[17][9].value = '8'
    JSON_PARSE_EXPECTED_NODES[17][10].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[17][10].value = '9'
    JSON_PARSE_EXPECTED_NODES[17][11].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[17][11].value = '10'

    // Test 18: {"users":[{"name":"John","age":30},{"name":"Jane","age":25}],"count":2}
    // Node 1: root object
    JSON_PARSE_EXPECTED_NODES[18][1].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[18][1].childCount = 2
    // Node 2: "users":[...]
    JSON_PARSE_EXPECTED_NODES[18][2].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[18][2].key = 'users'
    JSON_PARSE_EXPECTED_NODES[18][2].childCount = 2
    // Node 3: {"name":"John","age":30}
    JSON_PARSE_EXPECTED_NODES[18][3].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[18][3].childCount = 2
    // Node 4: "name":"John"
    JSON_PARSE_EXPECTED_NODES[18][4].type = NAV_JSON_VALUE_TYPE_STRING
    JSON_PARSE_EXPECTED_NODES[18][4].key = 'name'
    JSON_PARSE_EXPECTED_NODES[18][4].value = 'John'
    // Node 5: "age":30
    JSON_PARSE_EXPECTED_NODES[18][5].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[18][5].key = 'age'
    JSON_PARSE_EXPECTED_NODES[18][5].value = '30'
    // Node 6: {"name":"Jane","age":25}
    JSON_PARSE_EXPECTED_NODES[18][6].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[18][6].childCount = 2
    // Node 7: "name":"Jane"
    JSON_PARSE_EXPECTED_NODES[18][7].type = NAV_JSON_VALUE_TYPE_STRING
    JSON_PARSE_EXPECTED_NODES[18][7].key = 'name'
    JSON_PARSE_EXPECTED_NODES[18][7].value = 'Jane'
    // Node 8: "age":25
    JSON_PARSE_EXPECTED_NODES[18][8].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[18][8].key = 'age'
    JSON_PARSE_EXPECTED_NODES[18][8].value = '25'
    // Node 9: "count":2
    JSON_PARSE_EXPECTED_NODES[18][9].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[18][9].key = 'count'
    JSON_PARSE_EXPECTED_NODES[18][9].value = '2'

    // Test 19: {"empty":"","also":""}
    // Node 1: root object
    JSON_PARSE_EXPECTED_NODES[19][1].type = NAV_JSON_VALUE_TYPE_OBJECT
    JSON_PARSE_EXPECTED_NODES[19][1].childCount = 2
    // Node 2: "empty":""
    JSON_PARSE_EXPECTED_NODES[19][2].type = NAV_JSON_VALUE_TYPE_STRING
    JSON_PARSE_EXPECTED_NODES[19][2].key = 'empty'
    JSON_PARSE_EXPECTED_NODES[19][2].value = ''
    // Node 3: "also":""
    JSON_PARSE_EXPECTED_NODES[19][3].type = NAV_JSON_VALUE_TYPE_STRING
    JSON_PARSE_EXPECTED_NODES[19][3].key = 'also'
    JSON_PARSE_EXPECTED_NODES[19][3].value = ''

    // Test 20: [0,0.0,-0]
    // Node 1: root array
    JSON_PARSE_EXPECTED_NODES[20][1].type = NAV_JSON_VALUE_TYPE_ARRAY
    JSON_PARSE_EXPECTED_NODES[20][1].childCount = 3
    // Node 2: 0
    JSON_PARSE_EXPECTED_NODES[20][2].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[20][2].value = '0'
    // Node 3: 0.0
    JSON_PARSE_EXPECTED_NODES[20][3].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[20][3].value = '0.0'
    // Node 4: -0
    JSON_PARSE_EXPECTED_NODES[20][4].type = NAV_JSON_VALUE_TYPE_NUMBER
    JSON_PARSE_EXPECTED_NODES[20][4].value = '-0'

    set_length_array(JSON_PARSE_EXPECTED_NODES, 20)
}


DEFINE_CONSTANT

constant char JSON_PARSE_EXPECTED_RESULT[25] = {
    true,   // Test 1: Empty object
    true,   // Test 2: Simple object
    true,   // Test 3: Multiple properties
    true,   // Test 4: Empty array
    true,   // Test 5: Number array
    true,   // Test 6: Mixed array
    true,   // Test 7: Nested object
    true,   // Test 8: Nested array
    true,   // Test 9: Array of objects
    true,   // Test 10: Object with array
    true,   // Test 11: All literals
    true,   // Test 12: Decimal numbers
    true,   // Test 13: Negative numbers
    true,   // Test 14: Numbers with exponents
    true,   // Test 15: String with escapes
    true,   // Test 16: Deep nesting
    true,   // Test 17: Large array
    true,   // Test 18: Complex structure
    true,   // Test 19: Empty strings
    true,   // Test 20: Zero values
    false,  // Test 21: Invalid - unterminated string
    false,  // Test 22: Invalid - unexpected character
    false,  // Test 23: Invalid - trailing comma
    false,  // Test 24: Invalid - missing colon
    false   // Test 25: Invalid - extra token
}

constant integer JSON_PARSE_EXPECTED_NODE_COUNT[25] = {
    1,      // Test 1: {} = 1 node
    2,      // Test 2: {name:string} = 2 nodes
    4,      // Test 3: {name:string, age:number, active:bool} = 4 nodes
    1,      // Test 4: [] = 1 node
    6,      // Test 5: [1,2,3,4,5] = 6 nodes
    6,      // Test 6: [1,"two",true,null,false] = 6 nodes
    4,      // Test 7: {user:{name:string, age:number}} = 4 nodes
    7,      // Test 8: [[1,2],[3,4]] = 7 nodes (root array + 2 inner arrays + 4 numbers)
    5,      // Test 9: [{id:1},{id:2}] = 5 nodes
    6,      // Test 10: {numbers:[1,2,3],count:3} = 6 nodes
    4,      // Test 11: {null:null, true:true, false:false} = 4 nodes
    3,      // Test 12: {pi:3.14, e:2.718} = 3 nodes
    4,      // Test 13: [-1,-42,-999] = 4 nodes
    4,      // Test 14: [1e10,2.5E-3,1.23e+4] = 4 nodes
    2,      // Test 15: {text:"Hello\nWorld"} = 2 nodes
    6,      // Test 16: Deep nesting 5 levels = 6 nodes
    11,     // Test 17: [1,2,3,4,5,6,7,8,9,10] = 11 nodes
    9,      // Test 18: Complex structure = 9 nodes
    3,      // Test 19: {empty:"", also:""} = 3 nodes
    4,      // Test 20: [0,0.0,-0] = 4 nodes
    0,      // Test 21: Error case
    0,      // Test 22: Error case
    0,      // Test 23: Error case
    0,      // Test 24: Error case
    0       // Test 25: Error case
}

constant integer JSON_PARSE_EXPECTED_ROOT_TYPE[25] = {
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 1
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 2
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 3
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 4
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 5
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 6
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 7
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 8
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 9
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 10
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 11
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 12
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 13
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 14
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 15
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 16
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 17
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 18
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 19
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 20
    0,                              // Test 21: Error
    0,                              // Test 22: Error
    0,                              // Test 23: Error
    0,                              // Test 24: Error
    0                               // Test 25: Error
}

constant integer JSON_PARSE_EXPECTED_ROOT_CHILD_COUNT[25] = {
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
    3,      // Test 14: [1e10,2.5E-3,1.23e+4] = 3 children
    1,      // Test 15: {text:...} = 1 child
    1,      // Test 16: {a:{...}} = 1 child
    10,     // Test 17: [1,2,3,4,5,6,7,8,9,10] = 10 children
    2,      // Test 18: {users:[...], count:...} = 2 children
    2,      // Test 19: {empty:"", also:""} = 2 children
    3,      // Test 20: [0,0.0,-0] = 3 children
    0,      // Test 21: Error
    0,      // Test 22: Error
    0,      // Test 23: Error
    0,      // Test 24: Error
    0       // Test 25: Error
}

// First child key for objects, empty for arrays (only used for valid test cases)
constant char JSON_PARSE_EXPECTED_FIRST_CHILD_KEY[20][64] = {
    '',         // Test 1: No children
    'name',     // Test 2
    'name',     // Test 3
    '',         // Test 4: Array
    '',         // Test 5: Array
    '',         // Test 6: Array
    'user',     // Test 7
    '',         // Test 8: Array
    '',         // Test 9: Array
    'numbers',  // Test 10
    'null',     // Test 11
    'pi',       // Test 12
    '',         // Test 13: Array
    '',         // Test 14: Array
    'text',     // Test 15
    'a',        // Test 16
    '',         // Test 17: Array
    'users',    // Test 18
    'empty',    // Test 19
    ''          // Test 20: Array
}

// First child type (only used for valid test cases)
constant integer JSON_PARSE_EXPECTED_FIRST_CHILD_TYPE[20] = {
    0,                              // Test 1: No children
    NAV_JSON_VALUE_TYPE_STRING,     // Test 2
    NAV_JSON_VALUE_TYPE_STRING,     // Test 3
    0,                              // Test 4: No children
    NAV_JSON_VALUE_TYPE_NUMBER,     // Test 5
    NAV_JSON_VALUE_TYPE_NUMBER,     // Test 6
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 7
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 8
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 9
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 10
    NAV_JSON_VALUE_TYPE_NULL,       // Test 11
    NAV_JSON_VALUE_TYPE_NUMBER,     // Test 12
    NAV_JSON_VALUE_TYPE_NUMBER,     // Test 13
    NAV_JSON_VALUE_TYPE_NUMBER,     // Test 14
    NAV_JSON_VALUE_TYPE_STRING,     // Test 15
    NAV_JSON_VALUE_TYPE_OBJECT,     // Test 16
    NAV_JSON_VALUE_TYPE_NUMBER,     // Test 17
    NAV_JSON_VALUE_TYPE_ARRAY,      // Test 18
    NAV_JSON_VALUE_TYPE_STRING,     // Test 19
    NAV_JSON_VALUE_TYPE_NUMBER      // Test 20
}

// First child string value (only for string types)
constant char JSON_PARSE_EXPECTED_FIRST_CHILD_STRING[20][255] = {
    '',         // Test 1: No children
    'John',     // Test 2: name:"John"
    'John',     // Test 3: name:"John"
    '',         // Test 4
    '',         // Test 5
    '',         // Test 6
    '',         // Test 7
    '',         // Test 8
    '',         // Test 9
    '',         // Test 10
    '',         // Test 11
    '',         // Test 12
    '',         // Test 13
    '',         // Test 14
    {'H', 'e', 'l', 'l', 'o', $0A, 'W', 'o', 'r', 'l', 'd'},    // Test 15: text:"Hello\nWorld"
    '',         // Test 16
    '',         // Test 17
    '',         // Test 18
    '',         // Test 19: empty:""
    ''          // Test 20
}

// First child number value (only for number types)
constant float JSON_PARSE_EXPECTED_FIRST_CHILD_NUMBER[20] = {
    0.0,    // Test 1
    0.0,    // Test 2
    0.0,    // Test 3
    0.0,    // Test 4
    1.0,    // Test 5: [1,...]
    1.0,    // Test 6: [1,...]
    0.0,    // Test 7
    0.0,    // Test 8
    0.0,    // Test 9
    0.0,    // Test 10
    0.0,    // Test 11
    3.14,   // Test 12: pi:3.14
    -1.0,   // Test 13: [-1,...]
    1.0e10, // Test 14: [1e10,...]
    0.0,    // Test 15
    0.0,    // Test 16
    1.0,    // Test 17: [1,...]
    0.0,    // Test 18
    0.0,    // Test 19
    0.0     // Test 20: [0,...]
}

/**
 * Recursively validate all nodes in the JSON tree against expected values
 * Returns the next index to use (or 0 on validation failure)
 */
define_function integer ValidateJsonTreeRecursive(_NAVJson json,
                                                  _NAVJsonNode node,
                                                  _NAVJsonNode expectedNodes[],
                                                  integer expectedCount,
                                                  integer index,
                                                  integer depth) {
    stack_var _NAVJsonNode child
    stack_var integer nextIndex
    stack_var char indent[128]
    stack_var integer i

    if (index > expectedCount) {
        return 0  // Validation failed
    }

#IF_DEFINED DEBUG_JSON_TREE_VALIDATION
    // Build indentation string based on depth
    indent = ''
    for (i = 1; i <= depth; i++) {
        indent = "indent, '  '"
    }

    // Log node validation with proper indentation
    if (length_array(node.key) > 0) {
        NAVLog("indent, 'Validating: ', NAVJsonGetNodeType(node.type), ' "', node.key, '"'")
    }
    else {
        NAVLog("indent, 'Validating: ', NAVJsonGetNodeType(node.type)")
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
        active (node.type == NAV_JSON_VALUE_TYPE_STRING): {
#IF_DEFINED DEBUG_JSON_TREE_VALIDATION
            NAVLog("indent, '  = \"', node.value, '\"'")
#END_IF

            if (!NAVAssertStringEqual('String value', expectedNodes[index].value, node.value)) {
                return 0
            }
        }
        active (node.type == NAV_JSON_VALUE_TYPE_NUMBER): {
#IF_DEFINED DEBUG_JSON_TREE_VALIDATION
            NAVLog("indent, '  = ', node.value")
#END_IF

            if (!NAVAssertStringEqual('Number value', expectedNodes[index].value, node.value)) {
                return 0
            }
        }
        active (node.type == NAV_JSON_VALUE_TYPE_TRUE || node.type == NAV_JSON_VALUE_TYPE_FALSE): {
#IF_DEFINED DEBUG_JSON_TREE_VALIDATION
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
        if (NAVJsonGetFirstChild(json, node, child)) {
            while (true) {
                nextIndex = ValidateJsonTreeRecursive(json,
                                                      child,
                                                      expectedNodes,
                                                      expectedCount,
                                                      nextIndex,
                                                      depth + 1)

                if (nextIndex == 0) {
                    return 0  // Validation failed in child
                }

                if (!NAVJsonGetNextNode(json, child, child)) {
                    break
                }
            }
        }
    }

    return nextIndex  // Return next available index
}

/**
 * Validate entire JSON tree against expected node array
 */
define_function char ValidateJsonTree(_NAVJson json, integer testNum) {
    stack_var _NAVJsonNode root
    stack_var integer result

    // Only validate the 20 valid test cases (skip error tests 21-25)
    if (testNum < 1 || testNum > 20) {
        return true  // Skip invalid/error test cases
    }

    if (!NAVJsonGetRootNode(json, root)) {
        return false
    }

    result = ValidateJsonTreeRecursive(json,
                                       root,
                                       JSON_PARSE_EXPECTED_NODES[testNum],
                                       JSON_PARSE_EXPECTED_NODE_COUNT[testNum],
                                       1,
                                       0)

    return result != 0  // Success if result > 0
}

define_function  TestNAVJsonParse() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonParse'")

    InitializeJsonParseTestData()

    for (x = 1; x <= length_array(JSON_PARSE_TEST); x++) {
        stack_var _NAVJson json
        stack_var char result

        result = NAVJsonParse(JSON_PARSE_TEST[x], json)

        // Assert parse result matches expected
        if (!NAVAssertBooleanEqual('Parse result should match expected',
                                    JSON_PARSE_EXPECTED_RESULT[x],
                                    result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_PARSE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        // For error cases, skip further validation
        if (!JSON_PARSE_EXPECTED_RESULT[x]) {
            NAVLogTestPassed(x)
            continue
        }

        // Assert node count
        if (!NAVAssertIntegerEqual('Node count should match expected',
                                    JSON_PARSE_EXPECTED_NODE_COUNT[x],
                                    json.nodeCount)) {
            NAVLogTestFailed(x,
                            itoa(JSON_PARSE_EXPECTED_NODE_COUNT[x]),
                            itoa(json.nodeCount))
            continue
        }

        // Assert root index is valid
        if (!NAVAssertIntegerGreaterThan('Root index should be positive',
                                         0,
                                         json.rootIndex)) {
            NAVLogTestFailed(x, '> 0', itoa(json.rootIndex))
            continue
        }

        // Assert root type
        if (!NAVAssertIntegerEqual('Root type should match expected',
                                    JSON_PARSE_EXPECTED_ROOT_TYPE[x],
                                    json.nodes[json.rootIndex].type)) {
            NAVLogTestFailed(x,
                            itoa(JSON_PARSE_EXPECTED_ROOT_TYPE[x]),
                            itoa(json.nodes[json.rootIndex].type))
            continue
        }

        // Assert root child count
        if (!NAVAssertIntegerEqual('Root childCount should match expected',
                                    JSON_PARSE_EXPECTED_ROOT_CHILD_COUNT[x],
                                    json.nodes[json.rootIndex].childCount)) {
            NAVLogTestFailed(x,
                            itoa(JSON_PARSE_EXPECTED_ROOT_CHILD_COUNT[x]),
                            itoa(json.nodes[json.rootIndex].childCount))
            continue
        }

        // Validate entire tree structure using recursive traversal
        if (!ValidateJsonTree(json, x)) {
            NAVLogTestFailed(x, 'Tree validation', 'failed')
            continue
        }

        // Assert no error message
        if (!NAVAssertStringEqual('Error should be empty',
                                   '',
                                   json.error)) {
            NAVLogTestFailed(x, '(empty)', json.error)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonParse'")
}
