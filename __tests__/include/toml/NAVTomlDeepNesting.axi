PROGRAM_NAME='NAVTomlDeepNesting'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_DEEP_NESTING_TEST_TOML[10][1024]
volatile char TOML_DEEP_NESTING_TEST_QUERY[10][128]


define_function InitializeTomlDeepNestingTestData() {
    // Test 1: 5 levels of nested tables
    TOML_DEEP_NESTING_TEST_TOML[1] = "'[a.b.c.d]', $0A, 'e = "deep"'"
    TOML_DEEP_NESTING_TEST_QUERY[1] = '.a.b.c.d.e'

    // Test 2: 5 levels of nested arrays
    TOML_DEEP_NESTING_TEST_TOML[2] = 'nested = [[[[["value"]]]]]'
    TOML_DEEP_NESTING_TEST_QUERY[2] = '.nested[1][1][1][1][1]'

    // Test 3: Mixed nesting - tables with inline arrays
    TOML_DEEP_NESTING_TEST_TOML[3] = "'[[items]]', $0A, 'data = [{ value = 42 }]'"
    TOML_DEEP_NESTING_TEST_QUERY[3] = '.items[1].data[1].value'

    // Test 4: 10 levels deep table nesting
    TOML_DEEP_NESTING_TEST_TOML[4] = "'[l1.l2.l3.l4.l5.l6.l7.l8.l9.l10]', $0A, 'enabled = true'"
    TOML_DEEP_NESTING_TEST_QUERY[4] = '.l1.l2.l3.l4.l5.l6.l7.l8.l9.l10.enabled'

    // Test 5: 10 levels deep array nesting
    TOML_DEEP_NESTING_TEST_TOML[5] = 'data = [[[[[[[[[[123]]]]]]]]]]'
    TOML_DEEP_NESTING_TEST_QUERY[5] = '.data[1][1][1][1][1][1][1][1][1][1]'

    // Test 6: Deep nesting with mixed types
    TOML_DEEP_NESTING_TEST_TOML[6] = "'[config.settings.options]', $0A, 'flags = [ { enabled = true } ]'"
    TOML_DEEP_NESTING_TEST_QUERY[6] = '.config.settings.options.flags[1].enabled'

    // Test 7: Array of tables with inline table properties
    TOML_DEEP_NESTING_TEST_TOML[7] = "'[[items]]', $0A, 'a = { b = { c = 1 } }', $0A, '[[items]]', $0A, 'a = { b = { c = 2 } }'"
    TOML_DEEP_NESTING_TEST_QUERY[7] = '.items[2].a.b.c'

    // Test 8: 15 levels deep table nesting (testing limits)
    TOML_DEEP_NESTING_TEST_TOML[8] = "'[l1.l2.l3.l4.l5.l6.l7.l8.l9.l10.l11.l12.l13.l14.l15]', $0A, 'value = "bottom"'"
    TOML_DEEP_NESTING_TEST_QUERY[8] = '.l1.l2.l3.l4.l5.l6.l7.l8.l9.l10.l11.l12.l13.l14.l15.value'

    // Test 9: Deep array within table
    TOML_DEEP_NESTING_TEST_TOML[9] = 'matrix = [[[[{ x = 99 }]]]]'
    TOML_DEEP_NESTING_TEST_QUERY[9] = '.matrix[1][1][1][1].x'

    // Test 10: Multiple paths at same depth
    TOML_DEEP_NESTING_TEST_TOML[10] = "'[a.b.c]', $0A, 'x = 1', $0A, 'y = 2'"
    TOML_DEEP_NESTING_TEST_QUERY[10] = '.a.b.c.y'

    set_length_array(TOML_DEEP_NESTING_TEST_TOML, 10)
    set_length_array(TOML_DEEP_NESTING_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant char TOML_DEEP_NESTING_EXPECTED_STRING[10][64] = {
    'deep',      // Test 1
    'value',     // Test 2
    '',          // Test 3 - integer
    '',          // Test 4 - boolean
    '',          // Test 5 - integer
    '',          // Test 6 - boolean
    '',          // Test 7 - integer
    'bottom',    // Test 8
    '',          // Test 9 - integer
    ''           // Test 10 - integer
}

constant integer TOML_DEEP_NESTING_EXPECTED_INTEGER[10] = {
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

constant char TOML_DEEP_NESTING_EXPECTED_BOOLEAN[10] = {
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

constant char TOML_DEEP_NESTING_TEST_TYPE[10] = {
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


define_function TestNAVTomlDeepNesting() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlDeepNesting'")

    InitializeTomlDeepNestingTestData()

    for (x = 1; x <= length_array(TOML_DEEP_NESTING_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var _NAVTomlNode result

        if (!NAVTomlParse(TOML_DEEP_NESTING_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQuery(toml, TOML_DEEP_NESTING_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        switch (TOML_DEEP_NESTING_TEST_TYPE[x]) {
            case 1: { // String
                stack_var char stringResult[64]
                if (!NAVTomlQueryString(toml, TOML_DEEP_NESTING_TEST_QUERY[x], stringResult)) {
                    NAVLogTestFailed(x, 'QueryString success', 'QueryString failed')
                    continue
                }
                if (!NAVAssertStringEqual('NAVTomlQuery deep nesting',
                                         TOML_DEEP_NESTING_EXPECTED_STRING[x],
                                         stringResult)) {
                    NAVLogTestFailed(x,
                                    TOML_DEEP_NESTING_EXPECTED_STRING[x],
                                    stringResult)
                    continue
                }
            }
            case 2: { // Integer
                stack_var integer intResult
                if (!NAVTomlQueryInteger(toml, TOML_DEEP_NESTING_TEST_QUERY[x], intResult)) {
                    NAVLogTestFailed(x, 'QueryInteger success', 'QueryInteger failed')
                    continue
                }
                if (!NAVAssertIntegerEqual('NAVTomlQuery deep nesting',
                                          TOML_DEEP_NESTING_EXPECTED_INTEGER[x],
                                          intResult)) {
                    NAVLogTestFailed(x,
                                    itoa(TOML_DEEP_NESTING_EXPECTED_INTEGER[x]),
                                    itoa(intResult))
                    continue
                }
            }
            case 3: { // Boolean
                stack_var char boolResult
                if (!NAVTomlQueryBoolean(toml, TOML_DEEP_NESTING_TEST_QUERY[x], boolResult)) {
                    NAVLogTestFailed(x, 'QueryBoolean success', 'QueryBoolean failed')
                    continue
                }
                if (!NAVAssertBooleanEqual('NAVTomlQuery deep nesting',
                                          TOML_DEEP_NESTING_EXPECTED_BOOLEAN[x],
                                          boolResult)) {
                    NAVLogTestFailed(x,
                                    NAVBooleanToString(TOML_DEEP_NESTING_EXPECTED_BOOLEAN[x]),
                                    NAVBooleanToString(boolResult))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlDeepNesting'")
}
