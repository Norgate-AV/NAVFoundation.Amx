PROGRAM_NAME='NAVTomlQueryBooleanArray'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[10][512]
volatile char TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[10][64]


define_function InitializeTomlQueryBooleanArrayTestData() {
    // Test 1: Simple root array
    TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[1] = 'flags = [true, false, true]'
    TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[1] = '.flags'

    // Test 2: Array property with all true
    TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[2] = 'enabled = [true, true, true, true]'
    TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[2] = '.enabled'

    // Test 3: Nested array property
    TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[3] = "'[options]', 13, 10, 'settings = [false, false, false]', 13, 10"
    TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[3] = '.options.settings'

    // Test 4: Array with all false
    TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[4] = 'disabled = [false, false]'
    TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[4] = '.disabled'

    // Test 5: Mixed pattern
    TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[5] = 'mixed = [true, false, true, false, true]'
    TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[5] = '.mixed'

    // Test 6: Alternating pattern
    TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[6] = 'alt = [false, true, false, true]'
    TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[6] = '.alt'

    // Test 7: Empty array
    TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[7] = 'empty = []'
    TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[7] = '.empty'

    // Test 8: Single true element
    TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[8] = 'single = [true]'
    TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[8] = '.single'

    // Test 9: Single false element
    TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[9] = 'off = [false]'
    TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[9] = '.off'

    // Test 10: Nested path with array
    TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[10] = "'[features]', 13, 10, '[features.toggles]', 13, 10, 'active = [true, true, false, true]', 13, 10"
    TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[10] = '.features.toggles.active'

    set_length_array(TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML, 10)
    set_length_array(TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer TOML_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    4,  // Test 2
    3,  // Test 3
    2,  // Test 4
    5,  // Test 5
    4,  // Test 6
    0,  // Test 7 (empty)
    1,  // Test 8
    1,  // Test 9
    4   // Test 10
}

constant char TOML_QUERY_BOOLEAN_ARRAY_EXPECTED[10][5] = {
    {true, false, true},                    // Test 1
    {true, true, true, true},               // Test 2
    {false, false, false},                  // Test 3
    {false, false},                         // Test 4
    {true, false, true, false, true},       // Test 5
    {false, true, false, true},             // Test 6
    {false},                                // Test 7 (empty)
    {true},                                 // Test 8
    {false},                                // Test 9
    {true, true, false, true}               // Test 10
}


define_function TestNAVTomlQueryBooleanArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQueryBooleanArray'")

    InitializeTomlQueryBooleanArrayTestData()

    for (x = 1; x <= length_array(TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var char result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVTomlParse(TOML_QUERY_BOOLEAN_ARRAY_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQueryBooleanArray(toml, TOML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   TOML_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(TOML_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertBooleanEqual("'Array element ', itoa(i)",
                                      TOML_QUERY_BOOLEAN_ARRAY_EXPECTED[x][i],
                                      result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', NAVBooleanToString(TOML_QUERY_BOOLEAN_ARRAY_EXPECTED[x][i])",
                                "'Element ', itoa(i), ': ', NAVBooleanToString(result[i])")

                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlQueryBooleanArray'")
}
