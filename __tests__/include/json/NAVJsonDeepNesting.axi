PROGRAM_NAME='NAVJsonDeepNesting'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_DEEP_NESTING_TEST_JSON[10][1024]
volatile char JSON_DEEP_NESTING_TEST_QUERY[10][128]


define_function InitializeJsonDeepNestingTestData() {
    // Test 1: 5 levels of nested objects
    JSON_DEEP_NESTING_TEST_JSON[1] = '{"a":{"b":{"c":{"d":{"e":"deep"}}}}}'
    JSON_DEEP_NESTING_TEST_QUERY[1] = '.a.b.c.d.e'

    // Test 2: 5 levels of nested arrays
    JSON_DEEP_NESTING_TEST_JSON[2] = '[[[[["nested"]]]]]'
    JSON_DEEP_NESTING_TEST_QUERY[2] = '.[1][1][1][1][1]'

    // Test 3: Mixed nesting - objects and arrays
    JSON_DEEP_NESTING_TEST_JSON[3] = '{"items":[{"data":[{"value":42}]}]}'
    JSON_DEEP_NESTING_TEST_QUERY[3] = '.items[1].data[1].value'

    // Test 4: 10 levels deep object nesting
    JSON_DEEP_NESTING_TEST_JSON[4] = '{"l1":{"l2":{"l3":{"l4":{"l5":{"l6":{"l7":{"l8":{"l9":{"l10":true}}}}}}}}}}'
    JSON_DEEP_NESTING_TEST_QUERY[4] = '.l1.l2.l3.l4.l5.l6.l7.l8.l9.l10'

    // Test 5: 10 levels deep array nesting
    JSON_DEEP_NESTING_TEST_JSON[5] = '[[[[[[[[[[123]]]]]]]]]]'
    JSON_DEEP_NESTING_TEST_QUERY[5] = '.[1][1][1][1][1][1][1][1][1][1]'

    // Test 6: Deep nesting with mixed types
    JSON_DEEP_NESTING_TEST_JSON[6] = '{"config":{"settings":{"options":{"flags":[{"enabled":true}]}}}}'
    JSON_DEEP_NESTING_TEST_QUERY[6] = '.config.settings.options.flags[1].enabled'

    // Test 7: Array of objects with deep properties
    JSON_DEEP_NESTING_TEST_JSON[7] = '[{"a":{"b":{"c":1}}},{"a":{"b":{"c":2}}}]'
    JSON_DEEP_NESTING_TEST_QUERY[7] = '.[2].a.b.c'

    // Test 8: 15 levels deep object nesting (testing limits)
    JSON_DEEP_NESTING_TEST_JSON[8] = '{"l1":{"l2":{"l3":{"l4":{"l5":{"l6":{"l7":{"l8":{"l9":{"l10":{"l11":{"l12":{"l13":{"l14":{"l15":"bottom"}}}}}}}}}}}}}}}'
    JSON_DEEP_NESTING_TEST_QUERY[8] = '.l1.l2.l3.l4.l5.l6.l7.l8.l9.l10.l11.l12.l13.l14.l15'

    // Test 9: Deep array within object
    JSON_DEEP_NESTING_TEST_JSON[9] = '{"matrix":[[[[{"x":99}]]]]}'
    JSON_DEEP_NESTING_TEST_QUERY[9] = '.matrix[1][1][1][1].x'

    // Test 10: Multiple paths at same depth
    JSON_DEEP_NESTING_TEST_JSON[10] = '{"a":{"b":{"c":{"x":1,"y":2}}}}'
    JSON_DEEP_NESTING_TEST_QUERY[10] = '.a.b.c.y'

    set_length_array(JSON_DEEP_NESTING_TEST_JSON, 10)
    set_length_array(JSON_DEEP_NESTING_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant char JSON_DEEP_NESTING_EXPECTED_STRING[10][64] = {
    'deep',      // Test 1
    'nested',    // Test 2
    '',          // Test 3 - integer
    '',          // Test 4 - boolean
    '',          // Test 5 - integer
    '',          // Test 6 - boolean
    '',          // Test 7 - integer
    'bottom',    // Test 8
    '',          // Test 9 - integer
    ''           // Test 10 - integer
}

constant integer JSON_DEEP_NESTING_EXPECTED_INTEGER[10] = {
    0,    // Test 1 - string
    0,    // Test 2 - string
    42,   // Test 3
    0,    // Test 4 - boolean
    123,  // Test 5
    0,    // Test 6 - boolean
    2,    // Test 7
    0,    // Test 8 - string
    99,   // Test 9
    2     // Test 10
}

constant char JSON_DEEP_NESTING_EXPECTED_BOOLEAN[10] = {
    false, // Test 1 - string
    false, // Test 2 - string
    false, // Test 3 - integer
    true,  // Test 4
    false, // Test 5 - integer
    true,  // Test 6
    false, // Test 7 - integer
    false, // Test 8 - string
    false, // Test 9 - integer
    false  // Test 10 - integer
}

constant char JSON_DEEP_NESTING_TEST_TYPE[10] = {
    1,  // Test 1 - string
    1,  // Test 2 - string
    2,  // Test 3 - integer
    3,  // Test 4 - boolean
    2,  // Test 5 - integer
    3,  // Test 6 - boolean
    2,  // Test 7 - integer
    1,  // Test 8 - string
    2,  // Test 9 - integer
    2   // Test 10 - integer
}


define_function TestNAVJsonDeepNesting() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonDeepNesting'")

    InitializeJsonDeepNestingTestData()

    for (x = 1; x <= length_array(JSON_DEEP_NESTING_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var char strResult[64]
        stack_var integer intResult
        stack_var char boolResult

        if (!NAVJsonParse(JSON_DEEP_NESTING_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        switch (JSON_DEEP_NESTING_TEST_TYPE[x]) {
            case 1: {  // String test
                if (!NAVJsonQueryString(json, JSON_DEEP_NESTING_TEST_QUERY[x], strResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertStringEqual('Deep nesting string value',
                                         JSON_DEEP_NESTING_EXPECTED_STRING[x],
                                         strResult)) {
                    NAVLogTestFailed(x,
                                    JSON_DEEP_NESTING_EXPECTED_STRING[x],
                                    strResult)
                    continue
                }
            }
            case 2: {  // Integer test
                if (!NAVJsonQueryInteger(json, JSON_DEEP_NESTING_TEST_QUERY[x], intResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertIntegerEqual('Deep nesting integer value',
                                          JSON_DEEP_NESTING_EXPECTED_INTEGER[x],
                                          intResult)) {
                    NAVLogTestFailed(x,
                                    itoa(JSON_DEEP_NESTING_EXPECTED_INTEGER[x]),
                                    itoa(intResult))
                    continue
                }
            }
            case 3: {  // Boolean test
                if (!NAVJsonQueryBoolean(json, JSON_DEEP_NESTING_TEST_QUERY[x], boolResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertBooleanEqual('Deep nesting boolean value',
                                          JSON_DEEP_NESTING_EXPECTED_BOOLEAN[x],
                                          boolResult)) {
                    NAVLogTestFailed(x,
                                    NAVBooleanToString(JSON_DEEP_NESTING_EXPECTED_BOOLEAN[x]),
                                    NAVBooleanToString(boolResult))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonDeepNesting'")
}
