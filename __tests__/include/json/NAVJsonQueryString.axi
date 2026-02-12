PROGRAM_NAME='NAVJsonQueryString'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_STRING_TEST_JSON[10][512]
volatile char JSON_QUERY_STRING_TEST_QUERY[10][64]


define_function InitializeJsonQueryStringTestData() {
    // Test 1: Simple root string
    JSON_QUERY_STRING_TEST_JSON[1] = '"hello"'
    JSON_QUERY_STRING_TEST_QUERY[1] = '.'

    // Test 2: Object property
    JSON_QUERY_STRING_TEST_JSON[2] = '{"name":"John"}'
    JSON_QUERY_STRING_TEST_QUERY[2] = '.name'

    // Test 3: Nested object property
    JSON_QUERY_STRING_TEST_JSON[3] = '{"user":{"name":"Jane"}}'
    JSON_QUERY_STRING_TEST_QUERY[3] = '.user.name'

    // Test 4: Array element
    JSON_QUERY_STRING_TEST_JSON[4] = '["first", "second", "third"]'
    JSON_QUERY_STRING_TEST_QUERY[4] = '.[2]'

    // Test 5: Object in array
    JSON_QUERY_STRING_TEST_JSON[5] = '[{"title":"A"}, {"title":"B"}, {"title":"C"}]'
    JSON_QUERY_STRING_TEST_QUERY[5] = '.[3].title'

    // Test 6: Empty string value
    JSON_QUERY_STRING_TEST_JSON[6] = '{"value":""}'
    JSON_QUERY_STRING_TEST_QUERY[6] = '.value'

    // Test 7: String with special characters
    JSON_QUERY_STRING_TEST_JSON[7] = '{"text":"Hello\nWorld"}'
    JSON_QUERY_STRING_TEST_QUERY[7] = '.text'

    // Test 8: Deeply nested property
    JSON_QUERY_STRING_TEST_JSON[8] = '{"config":{"server":{"host":"localhost"}}}'
    JSON_QUERY_STRING_TEST_QUERY[8] = '.config.server.host'

    // Test 9: Property after array index
    JSON_QUERY_STRING_TEST_JSON[9] = '{"items":[{"label":"Item1"},{"label":"Item2"}]}'
    JSON_QUERY_STRING_TEST_QUERY[9] = '.items[1].label'

    // Test 10: Multiple nested levels
    JSON_QUERY_STRING_TEST_JSON[10] = '{"data":{"users":[{"name":"Alice"},{"name":"Bob"}]}}'
    JSON_QUERY_STRING_TEST_QUERY[10] = '.data.users[2].name'

    set_length_array(JSON_QUERY_STRING_TEST_JSON, 10)
    set_length_array(JSON_QUERY_STRING_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant char JSON_QUERY_STRING_EXPECTED[10][64] = {
    'hello',       // Test 1
    'John',        // Test 2
    'Jane',        // Test 3
    'second',      // Test 4
    'C',           // Test 5
    '',            // Test 6: Empty string
    {'H', 'e', 'l', 'l', 'o', $0A, 'W', 'o', 'r', 'l', 'd'},       // Test 7
    'localhost',   // Test 8
    'Item1',       // Test 9
    'Bob'          // Test 10
}


define_function TestNAVJsonQueryString() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQueryString'")

    InitializeJsonQueryStringTestData()

    for (x = 1; x <= length_array(JSON_QUERY_STRING_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var char result[256]

        if (!NAVJsonParse(JSON_QUERY_STRING_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQueryString(json, JSON_QUERY_STRING_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertStringEqual('NAVJsonQueryString value',
                                  JSON_QUERY_STRING_EXPECTED[x],
                                  result)) {
            NAVLogTestFailed(x,
                            JSON_QUERY_STRING_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQueryString'")
}
