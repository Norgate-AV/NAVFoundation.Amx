PROGRAM_NAME='NAVJsonQuery'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_TEST_JSON[10][512]
volatile char JSON_QUERY_TEST_QUERY[10][64]


define_function InitializeJsonQueryTestData() {
    // Test 1: Root object
    JSON_QUERY_TEST_JSON[1] = '{"name":"John","age":30}'
    JSON_QUERY_TEST_QUERY[1] = '.'

    // Test 2: Nested object
    JSON_QUERY_TEST_JSON[2] = '{"user":{"id":123,"name":"Jane"}}'
    JSON_QUERY_TEST_QUERY[2] = '.user'

    // Test 3: Deeply nested object
    JSON_QUERY_TEST_JSON[3] = '{"data":{"config":{"settings":{"timeout":5000}}}}'
    JSON_QUERY_TEST_QUERY[3] = '.data.config.settings'

    // Test 4: Root array
    JSON_QUERY_TEST_JSON[4] = '[1, 2, 3, 4, 5]'
    JSON_QUERY_TEST_QUERY[4] = '.'

    // Test 5: Array property
    JSON_QUERY_TEST_JSON[5] = '{"items":[{"id":1},{"id":2},{"id":3}]}'
    JSON_QUERY_TEST_QUERY[5] = '.items'

    // Test 6: Object in array
    JSON_QUERY_TEST_JSON[6] = '[{"name":"Alice","age":25},{"name":"Bob","age":30}]'
    JSON_QUERY_TEST_QUERY[6] = '.[1]'

    // Test 7: Nested object in array
    JSON_QUERY_TEST_JSON[7] = '{"users":[{"profile":{"name":"Charlie"}},{"profile":{"name":"David"}}]}'
    JSON_QUERY_TEST_QUERY[7] = '.users[2].profile'

    // Test 8: Array in nested object
    JSON_QUERY_TEST_JSON[8] = '{"response":{"data":{"records":[10,20,30]}}}'
    JSON_QUERY_TEST_QUERY[8] = '.response.data.records'

    // Test 9: Empty object
    JSON_QUERY_TEST_JSON[9] = '{"empty":{}}'
    JSON_QUERY_TEST_QUERY[9] = '.empty'

    // Test 10: Empty array
    JSON_QUERY_TEST_JSON[10] = '{"list":[]}'
    JSON_QUERY_TEST_QUERY[10] = '.list'

    set_length_array(JSON_QUERY_TEST_JSON, 10)
    set_length_array(JSON_QUERY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

// Expected node types
constant integer JSON_QUERY_EXPECTED_TYPE[10] = {
    NAV_JSON_TYPE_OBJ,  // Test 1
    NAV_JSON_TYPE_OBJ,  // Test 2
    NAV_JSON_TYPE_OBJ,  // Test 3
    NAV_JSON_TYPE_ARR,  // Test 4
    NAV_JSON_TYPE_ARR,  // Test 5
    NAV_JSON_TYPE_OBJ,  // Test 6
    NAV_JSON_TYPE_OBJ,  // Test 7
    NAV_JSON_TYPE_ARR,  // Test 8
    NAV_JSON_TYPE_OBJ,  // Test 9
    NAV_JSON_TYPE_ARR   // Test 10
}

// Expected child counts (for validation)
constant integer JSON_QUERY_EXPECTED_CHILD_COUNT[10] = {
    2,  // Test 1: {name, age}
    2,  // Test 2: {id, name}
    1,  // Test 3: {timeout}
    5,  // Test 4: [1,2,3,4,5]
    3,  // Test 5: [{id:1},{id:2},{id:3}]
    2,  // Test 6: {name, age}
    1,  // Test 7: {name}
    3,  // Test 8: [10,20,30]
    0,  // Test 9: {} (empty)
    0   // Test 10: [] (empty)
}

// Expected first property key (for objects)
constant char JSON_QUERY_EXPECTED_FIRST_KEY[10][32] = {
    'name',      // Test 1
    'id',        // Test 2
    'timeout',   // Test 3
    '',          // Test 4 (array)
    '',          // Test 5 (array)
    'name',      // Test 6
    'name',      // Test 7
    '',          // Test 8 (array)
    '',          // Test 9 (empty object)
    ''           // Test 10 (array)
}


define_function TestNAVJsonQuery() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQuery'")

    InitializeJsonQueryTestData()

    for (x = 1; x <= length_array(JSON_QUERY_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var _NAVJsonNode result
        stack_var _NAVJsonNode firstChild
        stack_var char keyValue[64]

        if (!NAVJsonParse(JSON_QUERY_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQuery(json, JSON_QUERY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Validate node type
        select {
            active (JSON_QUERY_EXPECTED_TYPE[x] == NAV_JSON_TYPE_OBJ): {
                if (!NAVJsonIsObject(result)) {
                    NAVLogTestFailed(x, 'Node type: OBJECT', "'Node type: ', NAVJsonGetNodeType(result.type)")
                    continue
                }
            }
            active (JSON_QUERY_EXPECTED_TYPE[x] == NAV_JSON_TYPE_ARR): {
                if (!NAVJsonIsArray(result)) {
                    NAVLogTestFailed(x, 'Node type: ARRAY', "'Node type: ', NAVJsonGetNodeType(result.type)")
                    continue
                }
            }
        }

        // Validate child count
        if (!NAVAssertIntegerEqual('Child count',
                                   JSON_QUERY_EXPECTED_CHILD_COUNT[x],
                                   NAVJsonGetChildCount(result))) {
            NAVLogTestFailed(x,
                            "'Expected children: ', itoa(JSON_QUERY_EXPECTED_CHILD_COUNT[x])",
                            "'Got children: ', itoa(NAVJsonGetChildCount(result))")
            continue
        }

        // For non-empty objects, validate first key
        if (JSON_QUERY_EXPECTED_TYPE[x] == NAV_JSON_TYPE_OBJ &&
            JSON_QUERY_EXPECTED_CHILD_COUNT[x] > 0) {

            if (!NAVJsonGetFirstChild(json, result, firstChild)) {
                NAVLogTestFailed(x, 'Get first child success', 'Get first child failed')
                continue
            }

            keyValue = NAVJsonGetKey(firstChild)
            if (!NAVAssertStringEqual('First property key',
                                      JSON_QUERY_EXPECTED_FIRST_KEY[x],
                                      keyValue)) {
                NAVLogTestFailed(x,
                                JSON_QUERY_EXPECTED_FIRST_KEY[x],
                                keyValue)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQuery'")
}
