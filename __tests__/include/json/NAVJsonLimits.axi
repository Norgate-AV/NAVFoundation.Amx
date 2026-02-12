PROGRAM_NAME='NAVJsonLimits'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_LIMITS_TEST_JSON[10][16384]
volatile long JSON_LIMITS_EXPECTED_NUMBER[10]
volatile char JSON_LIMITS_TEST_QUERY[10][128]


define_function InitializeJsonLimitsTestData() {
    stack_var integer i
    stack_var char temp[16384]
    stack_var char longKey[128]

    // Initialize expected numbers
    JSON_LIMITS_EXPECTED_NUMBER[1] = 0
    JSON_LIMITS_EXPECTED_NUMBER[2] = 123
    JSON_LIMITS_EXPECTED_NUMBER[3] = 0
    JSON_LIMITS_EXPECTED_NUMBER[4] = 0
    JSON_LIMITS_EXPECTED_NUMBER[5] = type_cast(4294967295)
    JSON_LIMITS_EXPECTED_NUMBER[6] = 0
    JSON_LIMITS_EXPECTED_NUMBER[7] = 0
    JSON_LIMITS_EXPECTED_NUMBER[8] = type_cast(999)
    JSON_LIMITS_EXPECTED_NUMBER[9] = 0
    JSON_LIMITS_EXPECTED_NUMBER[10] = 0
    set_length_array(JSON_LIMITS_EXPECTED_NUMBER, 10)

    // Initialize test queries
    JSON_LIMITS_TEST_QUERY[1] = '.description'
    // Test 2 - build 63-char key query
    longKey = '.'
    for (i = 1; i <= 63; i++) {
        longKey = "longKey, 'k'"
    }

    JSON_LIMITS_TEST_QUERY[2] = longKey
    JSON_LIMITS_TEST_QUERY[3] = '.'
    JSON_LIMITS_TEST_QUERY[4] = '.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o'
    JSON_LIMITS_TEST_QUERY[5] = '.bigNumber'
    JSON_LIMITS_TEST_QUERY[6] = '.'
    JSON_LIMITS_TEST_QUERY[7] = '.empty'
    JSON_LIMITS_TEST_QUERY[8] = '.l1.l2.l3.l4.l5.l6.l7.l8.l9.l10.l11.l12.l13.l14.l15'
    JSON_LIMITS_TEST_QUERY[9] = '.'
    JSON_LIMITS_TEST_QUERY[10] = '.nested.deep.path.test'
    set_length_array(JSON_LIMITS_TEST_QUERY, 10)

    // Test 1: Very long string value (200 characters)
    temp = '{"description":"'
    for (i = 1; i <= 200; i++) {
        temp = "temp, 'a'"
    }
    temp = "temp, '"}'"
    JSON_LIMITS_TEST_JSON[1] = temp

    // Test 2: Very long key (63 characters - at limit)
    temp = '{"'
    for (i = 1; i <= 63; i++) {
        temp = "temp, 'k'"
    }
    temp = "temp, '":123}'"
    JSON_LIMITS_TEST_JSON[2] = temp

    // Test 3: Many tokens - array with 100 elements
    temp = '['
    for (i = 1; i <= 100; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        temp = "temp, itoa(i)"
    }
    temp = "temp, ']'"
    JSON_LIMITS_TEST_JSON[3] = temp

    // Test 4: Many nodes - deeply nested structure with many properties
    temp = '{"a":{"b":{"c":{"d":{"e":{"f":{"g":{"h":{"i":{"j":{"k":{"l":{"m":{"n":{"o":"deep"}}}}}}}}}}}}}}}'
    JSON_LIMITS_TEST_JSON[4] = temp

    // Test 5: Large number value (max unsigned long)
    JSON_LIMITS_TEST_JSON[5] = '{"bigNumber":4294967295}'

    // Test 6: Many object properties (50 properties)
    temp = '{'
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        temp = "temp, '"key', itoa(i), '":', itoa(i)"
    }
    temp = "temp, '}'"
    JSON_LIMITS_TEST_JSON[6] = temp

    // Test 7: Empty structures (minimal tokens)
    JSON_LIMITS_TEST_JSON[7] = '{"empty":{},"array":[],"string":""}'

    // Test 8: Maximum query path depth (15 levels)
    JSON_LIMITS_TEST_JSON[8] = '{"l1":{"l2":{"l3":{"l4":{"l5":{"l6":{"l7":{"l8":{"l9":{"l10":{"l11":{"l12":{"l13":{"l14":{"l15":999}}}}}}}}}}}}}}}'

    // Test 9: Array with 200 boolean elements
    temp = '['
    for (i = 1; i <= 200; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        if (i mod 2) {
            temp = "temp, 'true'"
        } else {
            temp = "temp, 'false'"
        }
    }
    temp = "temp, ']'"
    JSON_LIMITS_TEST_JSON[9] = temp

    // Test 10: Complex structure mixing all limits
    temp = '{"data":['
    for (i = 1; i <= 20; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        temp = "temp, '{"id":', itoa(i), ',"value":', itoa(i * 10), '}'"
    }
    temp = "temp, '],'"
    temp = "temp, '"nested":{"deep":{"path":{"test":true}}}'"
    temp = "temp, '}'"
    JSON_LIMITS_TEST_JSON[10] = temp

    set_length_array(JSON_LIMITS_TEST_JSON, 10)
}


DEFINE_CONSTANT

constant integer JSON_LIMITS_EXPECTED_LENGTH[10] = {
    200,  // Test 1 - string length
    0,    // Test 2 - just parse success
    100,  // Test 3 - array count
    0,    // Test 4 - just query success
    0,    // Test 5 - big number test
    50,   // Test 6 - property count
    0,    // Test 7 - empty structures
    0,    // Test 8 - deep path value
    200,  // Test 9 - array count
    0     // Test 10 - nested query
}

constant char JSON_LIMITS_EXPECTED_STRING[10][256] = {
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', // Test 1
    '',        // Test 2
    '',        // Test 3
    'deep',    // Test 4
    '',        // Test 5
    '',        // Test 6
    '',        // Test 7
    '',        // Test 8
    '',        // Test 9
    ''         // Test 10
}

constant char JSON_LIMITS_EXPECTED_BOOLEAN[10] = {
    false, // Test 1
    false, // Test 2
    false, // Test 3
    false, // Test 4
    false, // Test 5
    false, // Test 6
    false, // Test 7
    false, // Test 8
    false, // Test 9
    true   // Test 10
}


define_function TestNAVJsonLimits() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonLimits'")

    InitializeJsonLimitsTestData()

    for (x = 1; x <= length_array(JSON_LIMITS_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var _NAVJsonNode node
        stack_var char strResult[256]
        stack_var long numResult
        stack_var char boolResult
        stack_var integer count

        if (!NAVJsonParse(JSON_LIMITS_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        select {
            active (x == 1): {  // Long string test
                if (!NAVJsonQueryString(json, JSON_LIMITS_TEST_QUERY[x], strResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertIntegerEqual('String length',
                                          JSON_LIMITS_EXPECTED_LENGTH[x],
                                          length_array(strResult))) {
                    NAVLogTestFailed(x,
                                    itoa(JSON_LIMITS_EXPECTED_LENGTH[x]),
                                    itoa(length_array(strResult)))
                    continue
                }
            }
            active (x == 2): {  // Long key test
                if (!NAVJsonQuery(json, '.', node)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVJsonQueryLong(json, JSON_LIMITS_TEST_QUERY[x], numResult)) {
                    NAVLogTestFailed(x, 'Long key query success', 'Long key query failed')
                    continue
                }

                if (!NAVAssertLongEqual('Long key value',
                                       JSON_LIMITS_EXPECTED_NUMBER[x],
                                       numResult)) {
                    NAVLogTestFailed(x,
                                    itoa(JSON_LIMITS_EXPECTED_NUMBER[x]),
                                    itoa(numResult))
                    continue
                }
            }
            active (x == 3 || x == 6 || x == 9): {  // Array/object count tests
                if (!NAVJsonQuery(json, JSON_LIMITS_TEST_QUERY[x], node)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                count = NAVJsonGetChildCount(node)

                if (!NAVAssertIntegerEqual('Child count',
                                          JSON_LIMITS_EXPECTED_LENGTH[x],
                                          count)) {
                    NAVLogTestFailed(x,
                                    itoa(JSON_LIMITS_EXPECTED_LENGTH[x]),
                                    itoa(count))
                    continue
                }
            }
            active (x == 4): {  // Deep path string test
                if (!NAVJsonQueryString(json, JSON_LIMITS_TEST_QUERY[x], strResult)) {
                    NAVLogTestFailed(x, 'Deep query success', 'Deep query failed')
                    continue
                }

                if (!NAVAssertStringEqual('Deep path value',
                                         JSON_LIMITS_EXPECTED_STRING[x],
                                         strResult)) {
                    NAVLogTestFailed(x,
                                    JSON_LIMITS_EXPECTED_STRING[x],
                                    strResult)
                    continue
                }
            }
            active (x == 5 || x == 8): {  // Big number test
                if (!NAVJsonQueryLong(json, JSON_LIMITS_TEST_QUERY[x], numResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertLongEqual('Large number value',
                                       JSON_LIMITS_EXPECTED_NUMBER[x],
                                       numResult)) {
                    NAVLogTestFailed(x,
                                    itoa(JSON_LIMITS_EXPECTED_NUMBER[x]),
                                    itoa(numResult))
                    continue
                }
            }
            active (x == 7): {  // Empty structures test
                if (!NAVJsonQuery(json, JSON_LIMITS_TEST_QUERY[x], node)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVJsonIsObject(node)) {
                    NAVLogTestFailed(x, 'Is object', 'Not an object')
                    continue
                }

                count = NAVJsonGetChildCount(node)

                if (!NAVAssertIntegerEqual('Empty object count', 0, count)) {
                    NAVLogTestFailed(x, '0', itoa(count))
                    continue
                }
            }
            active (x == 10): {  // Complex structure boolean test
                if (!NAVJsonQueryBoolean(json, JSON_LIMITS_TEST_QUERY[x], boolResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertBooleanEqual('Nested boolean value',
                                          JSON_LIMITS_EXPECTED_BOOLEAN[x],
                                          boolResult)) {
                    NAVLogTestFailed(x,
                                    NAVBooleanToString(JSON_LIMITS_EXPECTED_BOOLEAN[x]),
                                    NAVBooleanToString(boolResult))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonLimits'")
}
