#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Assert.axi'

// #DEFINE JSMN_DEBUG
// #DEFINE JSMN_STRICT
#DEFINE JSMN_PARENT_LINKS
#include 'NAVFoundation.Jsmn.axi'

DEFINE_VARIABLE

// Test cases are initialized in InitializeJsmnTestData()
volatile char JSMN_TEST[128][2048]
volatile char JSMN_TEST_ENABLED[128]
volatile integer JSMN_TEST_LENGTH[128]  // Custom parse length (0 = use full string length)

DEFINE_CONSTANT

// C JSMN Test Suite - Exact mapping from test/tests.c
// Test counts represent expected token count or error code
constant sinteger JSMN_EXPECTED_COUNT[] = {
    // test_empty (3 tests)
    1,                      // Test 1: {}
    1,                      // Test 2: []
    3,                      // Test 3: [{},{}]

    // test_object (10 tests - 5 basic + 5 strict errors)
    3,                      // Test 4: {"a":0}
    3,                      // Test 5: {"a":[]}
    5,                      // Test 6: {"a":{},"b":{}}
    7,                      // Test 7: multiline Day/Month/Year
    5,                      // Test 8: {"a": 0, "b": "c"}
    JSMN_ERROR_INVAL,       // Test 9: {"a"\n0} - strict mode
    JSMN_ERROR_INVAL,       // Test 10: {"a", 0} - strict mode
    JSMN_ERROR_INVAL,       // Test 11: {"a": {2}} - strict mode
    JSMN_ERROR_INVAL,       // Test 12: {"a": {2: 3}} - strict mode
    JSMN_ERROR_INVAL,       // Test 13: {"a": {"a": 2 3}} - strict mode

    // test_array (2 tests)
    2,                      // Test 14: [10]
    JSMN_ERROR_INVAL,       // Test 15: {"a": 1]

    // test_primitive (5 tests)
    3,                      // Test 16: {"boolVar" : true }
    3,                      // Test 17: {"boolVar" : false }
    3,                      // Test 18: {"nullVar" : null }
    3,                      // Test 19: {"intVar" : 12}
    3,                      // Test 20: {"floatVar" : 12.345}

    // test_string (10 tests - 7 valid + 3 errors)
    3,                      // Test 21: {"strVar" : "hello world"}
    3,                      // Test 22: {"strVar" : "escapes: \/\r\n\t\b\f\"\\"}
    3,                      // Test 23: {"strVar": ""}
    3,                      // Test 24: {"a":"\uAbcD"}
    3,                      // Test 25: {"a":"str\u0000"}
    3,                      // Test 26: {"a":"\uFFFFstr"}
    4,                      // Test 27: {"a":["\u0280"]}
    JSMN_ERROR_INVAL,       // Test 28: {"a":"str\uFFGFstr"} - Invalid: G is not a hex digit
    JSMN_ERROR_INVAL,       // Test 29: {"a":"str\u@FfF"} - Invalid: @ is not a hex digit
    JSMN_ERROR_INVAL,       // Test 30: {{"a":["\u028"]} - Invalid: Only 3 hex digits, must be 4

    // test_partial_string (1 test)
    5,                      // Test 31: {"x": "va\\ue", "y": "value y"}

    // test_partial_array (1 test - strict mode only)
    6,                      // Test 32: [ 1, true, [123, "hello"]]

    // test_array_nomem (1 test)
    6,                      // Test 33: [ 1, true, [123, "hello"]]

    // test_unquoted_keys (1 test)
    4,                      // Test 34: key1: "value"\nkey2 : 123

    // test_issue_22 (1 test)
    61,                     // Test 35: Large tilemap JSON (C test just checks >= 0)

    // test_issue_27 (1 test)
    JSMN_ERROR_PART,        // Test 36: { "name" : "Jack", "age" : 27 } { "name" : "Anna",

    // test_input_length (1 test)
    3,                      // Test 37: {"a": 0}garbage (length=8)

    // test_count (10 tests - token counting only)
    1,                      // Test 38: {}
    1,                      // Test 39: []
    2,                      // Test 40: [[]]
    3,                      // Test 41: [[], []]
    3,                      // Test 42: [[], []]
    7,                      // Test 43: [[], [[]], [[], []]]
    5,                      // Test 44: ["a", [[], []]]
    5,                      // Test 45: [[], "[], [[]]", [[]]]
    4,                      // Test 46: [1, 2, 3]
    7,                      // Test 47: [1, 2, [3, "a"], null]

    // test_nonstrict (3 tests)
    2,                      // Test 48: a: 0garbage
    6,                      // Test 49: Day : 26\nMonth : Sep\n\nYear: 12
    2,                      // Test 50: "key {1": 1234

    // test_unmatched_brackets (6 tests)
    JSMN_ERROR_INVAL,       // Test 51: "key 1": 1234}
    JSMN_ERROR_PART,        // Test 52: {"key 1": 1234
    JSMN_ERROR_INVAL,       // Test 53: {"key 1": 1234}}
    JSMN_ERROR_INVAL,       // Test 54: "key 1"}: 1234
    3,                      // Test 55: {"key {1": 1234}
    JSMN_ERROR_PART,        // Test 56: {"key 1":{"key 2": 1234}

    // test_object_key (5 tests - 1 basic + 4 strict errors)
    3,                      // Test 57: {"key": 1}
    JSMN_ERROR_INVAL,       // Test 58: {true: 1} - strict mode
    JSMN_ERROR_INVAL,       // Test 59: {1: 1} - strict mode
    JSMN_ERROR_INVAL,       // Test 60: {{"key": 1}: 2} - strict mode
    JSMN_ERROR_INVAL        // Test 61: {[1,2]: 2} - strict mode
}

constant sinteger JSMN_EXPECTED_START[][NAV_MAX_JSMN_TOKENS] = {
    // test_empty
    {1,2},                          // Test 1: {}
    {1,2},                          // Test 2: []
    {1,2,5},                        // Test 3: [{},{}]

    // test_object
    {1,3,6},                        // Test 4: {"a":0}
    {1,3,6},                        // Test 5: {"a":[]}
    {-1,-1,-1,-1,-1,-1},            // Test 6: {"a":{},"b":{}} - positions not checked in C
    {-1,-1,-1,-1,-1,-1,-1,-1},      // Test 7: multiline
    {-1,-1,-1,-1,-1,-1},            // Test 8: {"a": 0, "b": "c"}
    {0},                            // Test 9: error
    {0},                            // Test 10: error
    {0},                            // Test 11: error
    {0},                            // Test 12: error
    {0},                            // Test 13: error

    // test_array
    {-1,-1,-1},                     // Test 14: [10]
    {0},                            // Test 15: error

    // test_primitive
    {-1,-1,-1,-1},                  // Test 16: true
    {-1,-1,-1,-1},                  // Test 17: false
    {-1,-1,-1,-1},                  // Test 18: null
    {-1,-1,-1,-1},                  // Test 19: 12
    {-1,-1,-1,-1},                  // Test 20: 12.345

    // test_string
    {-1,-1,-1,-1},                  // Test 21: hello world
    {-1,-1,-1,-1},                  // Test 22: escapes
    {-1,-1,-1,-1},                  // Test 23: empty string
    {-1,-1,-1,-1},                  // Test 24: \uAbcD
    {-1,-1,-1,-1},                  // Test 25: str\u0000
    {-1,-1,-1,-1},                  // Test 26: \uFFFFstr
    {-1,-1,-1,-1,-1},               // Test 27: ["\u0280"]
    {0},                            // Test 28: error
    {0},                            // Test 29: error
    {0},                            // Test 30: error

    // test_partial_string
    {-1,-1,-1,-1,-1,-1},            // Test 31

    // test_partial_array
    {-1,-1,-1,-1,-1,-1,-1},         // Test 32

    // test_array_nomem
    {-1,-1,-1,-1,-1,-1,-1},         // Test 33

    // test_unquoted_keys
    {-1,-1,-1,-1,-1},               // Test 34

    // test_issue_22 (61 tokens - positions not validated)
    {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}, // Test 35

    // test_issue_27
    {0},                            // Test 36: error

    // test_input_length
    {-1,-1,-1,-1},                  // Test 37

    // test_count (positions not validated - just counting)
    {-1}, {-1}, {-1,-1}, {-1,-1,-1}, {-1,-1,-1}, {-1,-1,-1,-1,-1,-1,-1}, {-1,-1,-1,-1,-1}, {-1,-1,-1,-1,-1}, {-1,-1,-1,-1}, {-1,-1,-1,-1,-1,-1,-1}, // Tests 38-47

    // test_nonstrict
    {-1,-1,-1},                     // Test 48
    {-1,-1,-1,-1,-1,-1,-1},         // Test 49
    {-1,-1,-1},                     // Test 50

    // test_unmatched_brackets
    {0},                            // Test 51: error
    {0},                            // Test 52: error
    {0},                            // Test 53: error
    {0},                            // Test 54: error
    {1,3,12},                       // Test 55: {"key {1": 1234}
    {0},                            // Test 56: error

    // test_object_key
    {1,3,9},                        // Test 57: {"key": 1}
    {0}, {0}, {0}, {0}              // Tests 58-61: errors
}

constant sinteger JSMN_EXPECTED_END[][NAV_MAX_JSMN_TOKENS] = {
    // test_empty
    {3},                            // Test 1: {}
    {3},                            // Test 2: []
    {8,4,7},                        // Test 3: [{},{}]

    // test_object
    {8,4,7},                        // Test 4: {"a":0}
    {9,4,8},                        // Test 5: {"a":[]}
    {-1,-1,-1,-1,-1,-1},            // Test 6: not checked
    {-1,-1,-1,-1,-1,-1,-1,-1},      // Test 7: not checked
    {-1,-1,-1,-1,-1,-1},            // Test 8: not checked
    {0}, {0}, {0}, {0}, {0},        // Tests 9-13: errors

    // test_array
    {-1,-1,-1},                     // Test 14: [10]
    {0},                            // Test 15: error

    // test_primitive
    {-1,-1,-1,-1},                  // Test 16-20
    {-1,-1,-1,-1},
    {-1,-1,-1,-1},
    {-1,-1,-1,-1},
    {-1,-1,-1,-1},

    // test_string
    {-1,-1,-1,-1},                  // Tests 21-27
    {-1,-1,-1,-1},
    {-1,-1,-1,-1},
    {-1,-1,-1,-1},
    {-1,-1,-1,-1},
    {-1,-1,-1,-1},
    {-1,-1,-1,-1,-1},
    {0}, {0}, {0},                  // Tests 28-30: errors

    // test_partial_string
    {-1,-1,-1,-1,-1,-1},            // Test 31

    // test_partial_array
    {-1,-1,-1,-1,-1,-1,-1},         // Test 32

    // test_array_nomem
    {-1,-1,-1,-1,-1,-1,-1},         // Test 33

    // test_unquoted_keys
    {-1,-1,-1,-1,-1},               // Test 34

    // test_issue_22 (61 tokens - positions not validated)
    {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}, // Test 35

    // test_issue_27
    {0},                            // Test 36: error

    // test_input_length
    {-1,-1,-1,-1},                  // Test 37

    // test_count (positions not validated - just counting)
    {-1}, {-1}, {-1,-1}, {-1,-1,-1}, {-1,-1,-1}, {-1,-1,-1,-1,-1,-1,-1}, {-1,-1,-1,-1,-1}, {-1,-1,-1,-1,-1}, {-1,-1,-1,-1}, {-1,-1,-1,-1,-1,-1,-1}, // Tests 38-47

    // test_nonstrict
    {-1,-1,-1},                     // Test 48
    {-1,-1,-1,-1,-1,-1,-1},         // Test 49
    {-1,-1,-1},                     // Test 50

    // test_unmatched_brackets
    {0}, {0}, {0}, {0},             // Tests 51-54: errors
    {17,9,16},                      // Test 55: {"key {1": 1234}
    {0},                            // Test 56: error

    // test_object_key
    {11,6,10},                      // Test 57
    {0}, {0}, {0}, {0}              // Tests 58-61: errors
}

constant sinteger JSMN_EXPECTED_SIZE[][NAV_MAX_JSMN_TOKENS] = {
    // test_empty
    {0},                            // Test 1: {}
    {0},                            // Test 2: []
    {2,0,0},                        // Test 3: [{},{}]

    // test_object
    {1,1,0},                        // Test 4: {"a":0}
    {1,1,0},                        // Test 5: {"a":[]}
    {2,1,0,1,0},                    // Test 6: {"a":{},"b":{}}
    {3,1,0,1,0,1,0},                // Test 7: Day/Month/Year
    {2,1,0,1,0},                    // Test 8: {"a": 0, "b": "c"}
    {0}, {0}, {0}, {0}, {0},        // Tests 9-13: errors

    // test_array
    {1,0},                          // Test 14: [10]
    {0},                            // Test 15: error

    // test_primitive
    {1,1,0},                        // Test 16: true
    {1,1,0},                        // Test 17: false
    {1,1,0},                        // Test 18: null
    {1,1,0},                        // Test 19: 12
    {1,1,0},                        // Test 20: 12.345

    // test_string
    {1,1,0},                        // Test 21: hello world
    {1,1,0},                        // Test 22: escapes
    {1,1,0},                        // Test 23: empty string
    {1,1,0},                        // Test 24: \uAbcD
    {1,1,0},                        // Test 25: str\u0000
    {1,1,0},                        // Test 26: \uFFFFstr
    {1,1,1,0},                      // Test 27: ["\u0280"]
    {0}, {0}, {0},                  // Tests 28-30: errors

    // test_partial_string
    {2,1,0,1,0},                    // Test 31: {"x": "va\\ue", "y": "value y"}

    // test_partial_array
    {3,0,0,2,0,0},                  // Test 32: [ 1, true, [123, "hello"]]

    // test_array_nomem
    {3,0,0,2,0,0},                  // Test 33: same as above

    // test_unquoted_keys
    {2,0,1,0},                      // Test 34: key1: "value"\nkey2 : 123

    // test_issue_22 (61 tokens) - All keys have size=1, values have size=0, containers vary
    {9,1,0,1,1,9,1,2,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,1,10,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0}, // Test 35

    // test_issue_27
    {0},                            // Test 36: error

    // test_input_length
    {1,1,0},                        // Test 37: {"a": 0}

    // test_count (sizes not validated - just counting)
    {-1}, {-1}, {-1,-1}, {-1,-1,-1}, {-1,-1,-1}, {-1,-1,-1,-1,-1,-1,-1}, {-1,-1,-1,-1,-1}, {-1,-1,-1,-1,-1}, {-1,-1,-1,-1}, {-1,-1,-1,-1,-1,-1,-1}, // Tests 38-47

    // test_nonstrict
    {1,0},                          // Test 48: a: 0garbage
    {2,0,2,0,1,0},                  // Test 49: Day : 26\nMonth : Sep\n\nYear: 12
    {1,0},                          // Test 50: "key {1": 1234

    // test_unmatched_brackets
    {0}, {0}, {0}, {0},             // Tests 51-54: errors
    {1,1,0},                        // Test 55: {"key {1": 1234}
    {0},                            // Test 56: error

    // test_object_key
    {1,1,0},                        // Test 57: {"key": 1}
    {0}, {0}, {0}, {0}              // Tests 58-61: errors
}

constant integer JSMN_EXPECTED_TYPE[][NAV_MAX_JSMN_TOKENS] = {
    // test_empty
    {JSMN_TYPE_OBJECT},                                 // Test 1: {}
    {JSMN_TYPE_ARRAY},                                  // Test 2: []
    {JSMN_TYPE_ARRAY, JSMN_TYPE_OBJECT, JSMN_TYPE_OBJECT}, // Test 3: [{},{}]

    // test_object
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Test 4
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_ARRAY},     // Test 5
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_OBJECT}, // Test 6
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Test 7
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_STRING}, // Test 8
    {0}, {0}, {0}, {0}, {0},                            // Tests 9-13: errors

    // test_array
    {JSMN_TYPE_ARRAY, JSMN_TYPE_PRIMITIVE},             // Test 14
    {0},                                                // Test 15: error

    // test_primitive
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Test 16
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Test 17
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Test 18
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Test 19
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Test 20

    // test_string
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_STRING}, // Test 21
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_STRING}, // Test 22
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_STRING}, // Test 23
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_STRING}, // Test 24
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_STRING}, // Test 25
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_STRING}, // Test 26
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_ARRAY, JSMN_TYPE_STRING}, // Test 27
    {0}, {0}, {0},                                      // Tests 28-30: errors

    // test_partial_string
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_STRING}, // Test 31

    // test_partial_array
    {JSMN_TYPE_ARRAY, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_ARRAY, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING}, // Test 32

    // test_array_nomem
    {JSMN_TYPE_ARRAY, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_ARRAY, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING}, // Test 33

    // test_unquoted_keys
    {JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE}, // Test 34

    // test_issue_22 (61 tokens - all types)
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_ARRAY, JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_ARRAY, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_ARRAY, JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_STRING, JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Test 35

    // test_issue_27
    {0},                                                // Test 36: error

    // test_input_length
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Test 37

    // test_count
    {JSMN_TYPE_OBJECT}, {JSMN_TYPE_ARRAY}, {JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY}, {JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY}, {JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY}, {JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY}, {JSMN_TYPE_ARRAY, JSMN_TYPE_STRING, JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY}, {JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY, JSMN_TYPE_STRING, JSMN_TYPE_ARRAY, JSMN_TYPE_ARRAY}, {JSMN_TYPE_ARRAY, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE}, {JSMN_TYPE_ARRAY, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_ARRAY, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Tests 38-47

    // test_nonstrict
    {JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE},         // Test 48
    {JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE, JSMN_TYPE_PRIMITIVE}, // Test 49
    {JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE},            // Test 50

    // test_unmatched_brackets
    {0}, {0}, {0}, {0},                                 // Tests 51-54: errors
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Test 55
    {0},                                                // Test 56: error

    // test_object_key
    {JSMN_TYPE_OBJECT, JSMN_TYPE_STRING, JSMN_TYPE_PRIMITIVE}, // Test 57
    {0}, {0}, {0}, {0}                                  // Tests 58-61: errors
}

constant char JSMN_EXPECTED_VALUE[][][2048] = {
    // test_empty
    {'{}'},                                             // Test 1
    {'[]'},                                             // Test 2
    {'[{},{}]', '{}', '{}'},                            // Test 3

    // test_object
    {'{"a":0}', 'a', '0'},                            // Test 4
    {'{"a":[]}', 'a', '[]'},                          // Test 5
    {'{"a":{},"b":{}}', 'a', '{}', 'b', '{}'},      // Test 6
    {'{', $0D, $0A, ' ', '"', 'D', 'a', 'y', '"', ':', ' ', '2', '6', ',', $0D, $0A, ' ', '"', 'M', 'o', 'n', 't', 'h', '"', ':', ' ', '9', ',', $0D, $0A, ' ', '"', 'Y', 'e', 'a', 'r', '"', ':', ' ', '1', '2', $0D, $0A, ' ', '}'}, // Test 7 (simplified)
    {'{"a": 0, "b": "c"}', 'a', '0', 'b', 'c'},   // Test 8
    {''}, {''}, {''}, {''}, {''},                       // Tests 9-13: errors

    // test_array
    {'[10]', '10'},                                     // Test 14
    {''},                                               // Test 15: error

    // test_primitive
    {'{"boolVar" : true }', 'boolVar', 'true'},       // Test 16
    {'{"boolVar" : false }', 'boolVar', 'false'},     // Test 17
    {'{"nullVar" : null }', 'nullVar', 'null'},       // Test 18
    {'{"intVar" : 12}', 'intVar', '12'},              // Test 19
    {'{"floatVar" : 12.345}', 'floatVar', '12.345'},  // Test 20

    // test_string
    {'{"strVar" : "hello world"}', 'strVar', 'hello world'}, // Test 21
    {'{"strVar" : "escapes: \\/\r\n\t\b\f\"\\\\"}', 'strVar', 'escapes: \\/\r\n\t\b\f\"\\\\'}, // Test 22
    {'{"strVar": ""}', 'strVar', ''},               // Test 23
    {'{"a":"\uAbcD"}', 'a', '\uAbcD'},            // Test 24
    {'{"a":"str\u0000"}', 'a', 'str\u0000'},      // Test 25
    {'{"a":"\uFFFFstr"}', 'a', '\uFFFFstr'},      // Test 26
    {'{"a":["\u0280"]}', 'a', '["\u0280"]', '\u0280'}, // Test 27
    {''}, {''}, {''},                                   // Tests 28-30: errors

    // test_partial_string
    {'{"x": "va\\ue", "y": "value y"}', 'x', 'va\\ue', 'y', 'value y'}, // Test 31

    // test_partial_array
    {'[ 1, true, [123, "hello"]]', '1', 'true', '[123, "hello"]', '123', 'hello'}, // Test 32

    // test_array_nomem
    {'  [ 1, true, [123, "hello"]]', '1', 'true', '[123, "hello"]', '123', 'hello'}, // Test 33

    // test_unquoted_keys
    {'key1', 'value', 'key2', '123'},                   // Test 34

    // test_issue_22 (skipping value validation for now - too large)
    {''},                                               // Test 35

    // test_issue_27
    {''},                                               // Test 36: error

    // test_input_length
    {'{"a": 0}garbage', 'a', '0'},                    // Test 37

    // test_count (values not validated)
    {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, // Tests 38-47

    // test_nonstrict
    {'a', '0garbage'},                                  // Test 48
    {'D', 'a', 'y', ' ', ':', ' ', '2', '6', $0D, $0A, 'M', 'o', 'n', 't', 'h', ' ', ':', ' ', 'S', 'e', 'p', $0D, $0A, $0D, $0A, 'Y', 'e', 'a', 'r', ':', ' ', '1', '2'},        // Test 49
    {'key {1', '1234'},                                 // Test 50

    // test_unmatched_brackets
    {''}, {''}, {''}, {''},                             // Tests 51-54: errors
    {'{"key {1": 1234}', 'key {1', '1234'},           // Test 55
    {''},                                               // Test 56: error

    // test_object_key
    {'{"key": 1}', 'key', '1'},                       // Test 57
    {''}, {''}, {''}, {''}                              // Tests 58-61: errors
}


DEFINE_FUNCTION InitializeJsmnTestData() {
    // test_empty
    JSMN_TEST_ENABLED[1] = true
    JSMN_TEST[1] = '{}'

    JSMN_TEST_ENABLED[2] = true
    JSMN_TEST[2] = '[]'

    JSMN_TEST_ENABLED[3] = true
    JSMN_TEST[3] = '[{},{}]'

    // test_object
    JSMN_TEST_ENABLED[4] = true
    JSMN_TEST[4] = '{"a":0}'

    JSMN_TEST_ENABLED[5] = true
    JSMN_TEST[5] = '{"a":[]}'

    JSMN_TEST_ENABLED[6] = true
    JSMN_TEST[6] = '{"a":{},"b":{}}'

    JSMN_TEST_ENABLED[7] = true
    JSMN_TEST[7] = "'{', $0D, $0A, ' "Day": 26,', $0D, $0A, ' "Month": 9,', $0D, $0A, ' "Year": 12', $0D, $0A, ' }'"

    JSMN_TEST_ENABLED[8] = true
    JSMN_TEST[8] = '{"a": 0, "b": "c"}'

    #IF_DEFINED JSMN_STRICT
    JSMN_TEST_ENABLED[9] = true
    JSMN_TEST[9] = "'{', '"', 'a', '"', $0d, $0a, '0', '}'"

    JSMN_TEST_ENABLED[10] = true
    JSMN_TEST[10] = '{"a", 0}'

    JSMN_TEST_ENABLED[11] = true
    JSMN_TEST[11] = '{"a": {2}}'

    JSMN_TEST_ENABLED[12] = true
    JSMN_TEST[12] = '{"a": {2: 3}}'

    JSMN_TEST_ENABLED[13] = true
    JSMN_TEST[13] = '{"a": {"a": 2 3}}'
    #END_IF

    // test_array
    JSMN_TEST_ENABLED[14] = true
    JSMN_TEST[14] = '[10]'

    JSMN_TEST_ENABLED[15] = true
    JSMN_TEST[15] = '{"a": 1]'

    // test_primitive
    JSMN_TEST_ENABLED[16] = true
    JSMN_TEST[16] = '{"boolVar" : true }'

    JSMN_TEST_ENABLED[17] = true
    JSMN_TEST[17] = '{"boolVar" : false }'

    JSMN_TEST_ENABLED[18] = true
    JSMN_TEST[18] = '{"nullVar" : null }'

    JSMN_TEST_ENABLED[19] = true
    JSMN_TEST[19] = '{"intVar" : 12}'

    JSMN_TEST_ENABLED[20] = true
    JSMN_TEST[20] = '{"floatVar" : 12.345}'

    // test_string
    JSMN_TEST_ENABLED[21] = true
    JSMN_TEST[21] = '{"strVar" : "hello world"}'

    JSMN_TEST_ENABLED[22] = true
    JSMN_TEST[22] = '{"strVar" : "escapes: \\/\r\n\t\b\f\"\\\\"}'

    JSMN_TEST_ENABLED[23] = true
    JSMN_TEST[23] = '{"strVar": ""}'

    JSMN_TEST_ENABLED[24] = true
    JSMN_TEST[24] = '{"a":"\uAbcD"}'

    JSMN_TEST_ENABLED[25] = true
    JSMN_TEST[25] = '{"a":"str\u0000"}'

    JSMN_TEST_ENABLED[26] = true
    JSMN_TEST[26] = '{"a":"\uFFFFstr"}'

    JSMN_TEST_ENABLED[27] = true
    JSMN_TEST[27] = '{"a":["\u0280"]}'

    JSMN_TEST_ENABLED[28] = true
    JSMN_TEST[28] = '{"a":"str\uFFGFstr"}'

    JSMN_TEST_ENABLED[29] = true
    JSMN_TEST[29] = '{"a":"str\u@FfF"}'

    JSMN_TEST_ENABLED[30] = true
    JSMN_TEST[30] = '{{"a":["\u028"]}'

    // test_partial_string
    JSMN_TEST_ENABLED[31] = true
    JSMN_TEST[31] = '{"x": "va\\ue", "y": "value y"}'

    // test_partial_array (strict mode only)
    #IF_DEFINED JSMN_STRICT
    JSMN_TEST_ENABLED[32] = true
    JSMN_TEST[32] = '[ 1, true, [123, "hello"]]'
    #END_IF

    // test_array_nomem
    JSMN_TEST_ENABLED[33] = true
    JSMN_TEST[33] = '  [ 1, true, [123, "hello"]]'

    // test_unquoted_keys (non-strict only)
    #IF_NOT_DEFINED JSMN_STRICT
    JSMN_TEST_ENABLED[34] = true
    JSMN_TEST[34] = "'key1: "value"', $0d, $0a, 'key2 : 123'"
    #END_IF

    // test_issue_22
    JSMN_TEST_ENABLED[35] = true
    JSMN_TEST[35] = '{ "height":10, "layers":[ { "data":[6,6], "height":10, "name":"Calque de Tile 1", "opacity":1, "type":"tilelayer", "visible":true, "width":10, "x":0, "y":0 }], "orientation":"orthogonal", "properties": { }, "tileheight":32, "tilesets":[ { "firstgid":1, "image":"..\/images\/tiles.png", "imageheight":64, "imagewidth":160, "margin":0, "name":"Tiles", "properties":{}, "spacing":0, "tileheight":32, "tilewidth":32 }], "tilewidth":32, "version":1, "width":10 }'

    // test_issue_27
    JSMN_TEST_ENABLED[36] = true
    JSMN_TEST[36] = '{ "name" : "Jack", "age" : 27 } { "name" : "Anna", '

    // test_input_length
    JSMN_TEST_ENABLED[37] = true
    JSMN_TEST[37] = '{"a": 0}garbage'
    JSMN_TEST_LENGTH[37] = 8  // Only parse first 8 characters

    // test_count
    JSMN_TEST_ENABLED[38] = true
    JSMN_TEST[38] = '{}'

    JSMN_TEST_ENABLED[39] = true
    JSMN_TEST[39] = '[]'

    JSMN_TEST_ENABLED[40] = true
    JSMN_TEST[40] = '[[]]'

    JSMN_TEST_ENABLED[41] = true
    JSMN_TEST[41] = '[[], []]'

    JSMN_TEST_ENABLED[42] = true
    JSMN_TEST[42] = '[[], []]'

    JSMN_TEST_ENABLED[43] = true
    JSMN_TEST[43] = '[[], [[]], [[], []]]'

    JSMN_TEST_ENABLED[44] = true
    JSMN_TEST[44] = '["a", [[], []]]'

    JSMN_TEST_ENABLED[45] = true
    JSMN_TEST[45] = '[[], "[], [[]]", [[]]]'

    JSMN_TEST_ENABLED[46] = true
    JSMN_TEST[46] = '[1, 2, 3]'

    JSMN_TEST_ENABLED[47] = true
    JSMN_TEST[47] = '[1, 2, [3, "a"], null]'

    // test_nonstrict (non-strict only)
    #IF_NOT_DEFINED JSMN_STRICT
    JSMN_TEST_ENABLED[48] = true
    JSMN_TEST[48] = 'a: 0garbage'

    JSMN_TEST_ENABLED[49] = true
    JSMN_TEST[49] = "'Day : 26', $0D, $0A, 'Month : Sep', $0d, $0A, $0D, $0a, 'Year: 12'"

    JSMN_TEST_ENABLED[50] = true
    JSMN_TEST[50] = '"key {1": 1234'
    #END_IF

    // test_unmatched_brackets
    JSMN_TEST_ENABLED[51] = true
    JSMN_TEST[51] = '"key 1": 1234}'

    JSMN_TEST_ENABLED[52] = true
    JSMN_TEST[52] = '{"key 1": 1234'

    JSMN_TEST_ENABLED[53] = true
    JSMN_TEST[53] = '{"key 1": 1234}}'

    JSMN_TEST_ENABLED[54] = true
    JSMN_TEST[54] = '"key 1"}: 1234'

    JSMN_TEST_ENABLED[55] = true
    JSMN_TEST[55] = '{"key {1": 1234}'

    JSMN_TEST_ENABLED[56] = true
    JSMN_TEST[56] = '{"key 1":{"key 2": 1234}'

    // test_object_key
    JSMN_TEST_ENABLED[57] = true
    JSMN_TEST[57] = '{"key": 1}'

    #IF_DEFINED JSMN_STRICT
    JSMN_TEST_ENABLED[58] = true
    JSMN_TEST[58] = '{true: 1}'

    JSMN_TEST_ENABLED[59] = true
    JSMN_TEST[59] = '{1: 1}'

    JSMN_TEST_ENABLED[60] = true
    JSMN_TEST[60] = '{{"key": 1}: 2}'

    JSMN_TEST_ENABLED[61] = true
    JSMN_TEST[61] = '{[1,2]: 2}'
    #END_IF

    set_length_array(JSMN_TEST, 61)
    set_length_array(JSMN_TEST_ENABLED, 61)
}


DEFINE_FUNCTION RunJsmnTests() {
    stack_var integer x

    NAVLogTestSuiteStart('JSMN')

    InitializeJsmnTestData()

    for (x = 1; x <= length_array(JSMN_TEST); x++) {
        stack_var JsmnParser parser
        stack_var JsmnToken tokens[NAV_MAX_JSMN_TOKENS]
        stack_var sinteger result
        stack_var integer count
        stack_var integer parseLength
        stack_var char failed

        if (!JSMN_TEST_ENABLED[x]) {
            continue
        }

        // if (x != 51) {
        //     continue
        // }

        parseLength = JSMN_TEST_LENGTH[x]
        if (parseLength == 0) {
            parseLength = length_array(JSMN_TEST[x])
        }

        jsmn_init(parser)
        result = jsmn_parse(parser, JSMN_TEST[x], parseLength, tokens, max_length_array(tokens))

        if (!NAVAssertSignedIntegerEqual('Should match expected count result', JSMN_EXPECTED_COUNT[x], result)) {
            NAVLogTestFailed(x, itoa(JSMN_EXPECTED_COUNT[x]), itoa(result))
            continue
        }

        if (JSMN_EXPECTED_COUNT[x] <= 0) {
            NAVLogTestPassed(x)
            continue
        }

        count = type_cast(result)

        {
            stack_var integer z

            for (z = 1; z <= count; z++) {
                // Validate token type
                if (!NAVAssertIntegerEqual("'Token ', itoa(z), ' type'", JSMN_EXPECTED_TYPE[x][z], tokens[z].type)) {
                    NAVLogTestFailed(x, itoa(JSMN_EXPECTED_TYPE[x][z]), itoa(tokens[z].type))
                    failed = true
                    break
                }

                // Validate start position if expected value is not -1
                if (JSMN_EXPECTED_START[x][z] != -1) {
                    if (!NAVAssertSignedIntegerEqual("'Token ', itoa(z), ' start position'", JSMN_EXPECTED_START[x][z], tokens[z].start)) {
                        NAVLogTestFailed(x, "'start=', itoa(JSMN_EXPECTED_START[x][z])", "'start=', itoa(tokens[z].start)")
                        failed = true
                        break
                    }
                }

                // Validate end position if expected value is not -1
                if (JSMN_EXPECTED_END[x][z] != -1) {
                    if (!NAVAssertSignedIntegerEqual("'Token ', itoa(z), ' end position'", JSMN_EXPECTED_END[x][z], tokens[z].end)) {
                        NAVLogTestFailed(x, "'end=', itoa(JSMN_EXPECTED_END[x][z])", "'end=', itoa(tokens[z].end)")
                        failed = true
                        break
                    }
                }

                // Validate size if expected value is not -1
                if (JSMN_EXPECTED_SIZE[x][z] != -1) {
                    if (!NAVAssertSignedIntegerEqual("'Token ', itoa(z), ' size'", JSMN_EXPECTED_SIZE[x][z], tokens[z].size)) {
                        NAVLogTestFailed(x, "'size=', itoa(JSMN_EXPECTED_SIZE[x][z])", "'size=', itoa(tokens[z].size)")
                        failed = true
                        break
                    }
                }
            }

            if (failed) {
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('JSMN')
}
