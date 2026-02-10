PROGRAM_NAME='NAVTomlLimits'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_LIMITS_TEST_TOML[10][16384]
volatile long TOML_LIMITS_EXPECTED_NUMBER[10]
volatile char TOML_LIMITS_TEST_QUERY[10][256]


define_function InitializeTomlLimitsTestData() {
    stack_var integer i
    stack_var integer j
    stack_var char temp[16384]
    stack_var char longKey[128]

    // Initialize expected numbers
    TOML_LIMITS_EXPECTED_NUMBER[1] = 0
    TOML_LIMITS_EXPECTED_NUMBER[2] = 123
    TOML_LIMITS_EXPECTED_NUMBER[3] = 0
    TOML_LIMITS_EXPECTED_NUMBER[4] = 0
    TOML_LIMITS_EXPECTED_NUMBER[5] = type_cast(4294967295)
    TOML_LIMITS_EXPECTED_NUMBER[6] = 0
    TOML_LIMITS_EXPECTED_NUMBER[7] = 0
    TOML_LIMITS_EXPECTED_NUMBER[8] = type_cast(999)
    TOML_LIMITS_EXPECTED_NUMBER[9] = 0
    TOML_LIMITS_EXPECTED_NUMBER[10] = 0
    set_length_array(TOML_LIMITS_EXPECTED_NUMBER, 10)

    // Initialize test queries
    TOML_LIMITS_TEST_QUERY[1] = '.description'

    // Test 2 - build 63-char key query
    longKey = '.'
    for (i = 1; i <= 63; i++) {
        longKey = "longKey, 'k'"
    }
    TOML_LIMITS_TEST_QUERY[2] = longKey

    TOML_LIMITS_TEST_QUERY[3] = '.values'
    TOML_LIMITS_TEST_QUERY[4] = '.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o'
    TOML_LIMITS_TEST_QUERY[5] = '.bigNumber'
    TOML_LIMITS_TEST_QUERY[6] = '.data'
    TOML_LIMITS_TEST_QUERY[7] = '.empty'
    TOML_LIMITS_TEST_QUERY[8] = '.l1.l2.l3.l4.l5.l6.l7.l8.l9.l10.l11.l12.l13.l14.l15'
    TOML_LIMITS_TEST_QUERY[9] = '.matrix'
    TOML_LIMITS_TEST_QUERY[10] = '.nested.deep.path.test'
    set_length_array(TOML_LIMITS_TEST_QUERY, 10)

    // Test 1: Very long string value (200 characters)
    temp = 'description = "'
    for (i = 1; i <= 200; i++) {
        temp = "temp, 'a'"
    }
    temp = "temp, '"'"
    TOML_LIMITS_TEST_TOML[1] = temp

    // Test 2: Very long key (63 characters - at limit)
    temp = ''
    for (i = 1; i <= 63; i++) {
        temp = "temp, 'k'"
    }
    temp = "temp, ' = 123'"
    TOML_LIMITS_TEST_TOML[2] = temp

    // Test 3: Many tokens - array with 100 elements
    temp = 'values = ['
    for (i = 1; i <= 100; i++) {
        if (i > 1) {
            temp = "temp, ', '"
        }
        temp = "temp, itoa(i)"
    }
    temp = "temp, ']'"
    TOML_LIMITS_TEST_TOML[3] = temp

    // Test 4: Many nodes - deeply nested structure with many properties
    temp = "'[a.b.c.d.e.f.g.h.i.j.k.l.m.n.o]', $0A, 'value = "deep"'"
    TOML_LIMITS_TEST_TOML[4] = temp

    // Test 5: Large number value (max unsigned long)
    TOML_LIMITS_TEST_TOML[5] = 'bigNumber = 4294967295'

    // Test 6: Many table properties (50 properties)
    temp = "'[data]', $0A"
    for (i = 1; i <= 50; i++) {
        temp = "temp, 'key', itoa(i), ' = ', itoa(i), $0A"
    }
    TOML_LIMITS_TEST_TOML[6] = temp

    // Test 7: Empty structures (minimal tokens)
    TOML_LIMITS_TEST_TOML[7] = "'[empty]', $0A, 'array = []', $0A, 'string = ""'"

    // Test 8: Maximum query path depth (15 levels)
    TOML_LIMITS_TEST_TOML[8] = "'[l1.l2.l3.l4.l5.l6.l7.l8.l9.l10.l11.l12.l13.l14.l15]', $0A, 'value = 999'"

    // Test 9: Large 2D array (10x10)
    temp = 'matrix = ['
    for (i = 1; i <= 10; i++) {
        if (i > 1) {
            temp = "temp, ', '"
        }
        temp = "temp, '['"
        for (j = 1; j <= 10; j++) {
            if (j > 1) {
                temp = "temp, ', '"
            }
            temp = "temp, itoa((i - 1) * 10 + j)"
        }
        temp = "temp, ']'"
    }
    temp = "temp, ']'"
    TOML_LIMITS_TEST_TOML[9] = temp

    // Test 10: Very long dotted key chain
    temp = "'[nested.deep.path.test]', $0A, 'value = 42'"
    TOML_LIMITS_TEST_TOML[10] = temp

    set_length_array(TOML_LIMITS_TEST_TOML, 10)
}


DEFINE_CONSTANT

constant integer TOML_LIMITS_EXPECTED_ARRAY_LENGTH[10] = {
    0,    // Test 1 - not an array
    0,    // Test 2 - not an array
    100,  // Test 3 - 100 elements
    0,    // Test 4 - not an array
    0,    // Test 5 - not an array
    50,   // Test 6 - 50 properties
    0,    // Test 7 - empty array
    0,    // Test 8 - not an array
    10,   // Test 9 - 10 rows
    0     // Test 10 - not an array
}


define_function TestNAVTomlLimits() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlLimits'")

    InitializeTomlLimitsTestData()

    for (x = 1; x <= length_array(TOML_LIMITS_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var _NAVTomlNode result

        if (!NAVTomlParse(TOML_LIMITS_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQuery(toml, TOML_LIMITS_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Verify specific values for certain tests
        switch (x) {
            case 1: { // Very long string
                stack_var char stringResult[256]
                if (NAVTomlQueryString(toml, TOML_LIMITS_TEST_QUERY[x], stringResult)) {
                    if (length_array(stringResult) != 200) {
                        NAVLogTestFailed(x, '200 chars', "itoa(length_array(stringResult)), ' chars'")
                        continue
                    }
                }
            }
            case 2: { // Long key
                stack_var long longValue
                if (NAVTomlQueryLong(toml, TOML_LIMITS_TEST_QUERY[x], longValue)) {
                    if (!NAVAssertLongEqual('Long key value',
                                           TOML_LIMITS_EXPECTED_NUMBER[x],
                                           longValue)) {
                        NAVLogTestFailed(x,
                                        NAVLongToAscii(TOML_LIMITS_EXPECTED_NUMBER[x]),
                                        NAVLongToAscii(longValue))
                        continue
                    }
                }
            }
            case 3: { // Large array
                if (!NAVAssertIntegerEqual('Array length',
                                          TOML_LIMITS_EXPECTED_ARRAY_LENGTH[x],
                                          result.childCount)) {
                    NAVLogTestFailed(x,
                                    itoa(TOML_LIMITS_EXPECTED_ARRAY_LENGTH[x]),
                                    itoa(result.childCount))
                    continue
                }
            }
            case 5: { // Large number
                stack_var long bigNumber
                if (NAVTomlQueryLong(toml, TOML_LIMITS_TEST_QUERY[x], bigNumber)) {
                    if (!NAVAssertLongEqual('Large number',
                                           TOML_LIMITS_EXPECTED_NUMBER[x],
                                           bigNumber)) {
                        NAVLogTestFailed(x,
                                        NAVLongToAscii(TOML_LIMITS_EXPECTED_NUMBER[x]),
                                        NAVLongToAscii(bigNumber))
                        continue
                    }
                }
            }
            case 6: { // Many properties
                if (!NAVAssertIntegerEqual('Property count',
                                          TOML_LIMITS_EXPECTED_ARRAY_LENGTH[x],
                                          result.childCount)) {
                    NAVLogTestFailed(x,
                                    itoa(TOML_LIMITS_EXPECTED_ARRAY_LENGTH[x]),
                                    itoa(result.childCount))
                    continue
                }
            }
            case 8: { // Deep nesting
                stack_var long deepValue
                if (NAVTomlQueryLong(toml, "TOML_LIMITS_TEST_QUERY[x], '.value'", deepValue)) {
                    if (!NAVAssertLongEqual('Deep nested value',
                                           TOML_LIMITS_EXPECTED_NUMBER[x],
                                           deepValue)) {
                        NAVLogTestFailed(x,
                                        NAVLongToAscii(TOML_LIMITS_EXPECTED_NUMBER[x]),
                                        NAVLongToAscii(deepValue))
                        continue
                    }
                }
            }
            case 9: { // 2D array
                if (!NAVAssertIntegerEqual('Matrix rows',
                                          TOML_LIMITS_EXPECTED_ARRAY_LENGTH[x],
                                          result.childCount)) {
                    NAVLogTestFailed(x,
                                    itoa(TOML_LIMITS_EXPECTED_ARRAY_LENGTH[x]),
                                    itoa(result.childCount))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlLimits'")
}
