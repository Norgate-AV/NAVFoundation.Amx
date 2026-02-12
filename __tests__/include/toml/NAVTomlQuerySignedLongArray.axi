PROGRAM_NAME='NAVTomlQuerySignedLongArray'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_QUERY_SLONG_ARRAY_TEST_TOML[10][512]
volatile char TOML_QUERY_SLONG_ARRAY_TEST_QUERY[10][64]


define_function InitializeTomlQuerySignedLongArrayTestData() {
    // Test 1: Simple root array with mixed signs
    TOML_QUERY_SLONG_ARRAY_TEST_TOML[1] = 'mixed = [-1000000, 2000000, -3000000]'
    TOML_QUERY_SLONG_ARRAY_TEST_QUERY[1] = '.mixed'

    // Test 2: Array property with negatives
    TOML_QUERY_SLONG_ARRAY_TEST_TOML[2] = 'offsets = [-100000, -200000, -300000, 0, 100000]'
    TOML_QUERY_SLONG_ARRAY_TEST_QUERY[2] = '.offsets'

    // Test 3: Nested array property
    TOML_QUERY_SLONG_ARRAY_TEST_TOML[3] = "'[database]', 13, 10, 'deltas = [-1234567, -234567, -34567]', 13, 10"
    TOML_QUERY_SLONG_ARRAY_TEST_QUERY[3] = '.database.deltas'

    // Test 4: Array with zeros
    TOML_QUERY_SLONG_ARRAY_TEST_TOML[4] = 'baseline = [0, 0, 0]'
    TOML_QUERY_SLONG_ARRAY_TEST_QUERY[4] = '.baseline'

    // Test 5: Very large negative values
    TOML_QUERY_SLONG_ARRAY_TEST_TOML[5] = 'big = [-1000000000, -2000000000]'
    TOML_QUERY_SLONG_ARRAY_TEST_QUERY[5] = '.big'

    // Test 6: Extreme values
    TOML_QUERY_SLONG_ARRAY_TEST_TOML[6] = 'extremes = [2147483647, -2147483648]'
    TOML_QUERY_SLONG_ARRAY_TEST_QUERY[6] = '.extremes'

    // Test 7: Empty array
    TOML_QUERY_SLONG_ARRAY_TEST_TOML[7] = 'empty = []'
    TOML_QUERY_SLONG_ARRAY_TEST_QUERY[7] = '.empty'

    // Test 8: Single negative element
    TOML_QUERY_SLONG_ARRAY_TEST_TOML[8] = 'single = [-123456789]'
    TOML_QUERY_SLONG_ARRAY_TEST_QUERY[8] = '.single'

    // Test 9: All positive
    TOML_QUERY_SLONG_ARRAY_TEST_TOML[9] = 'positive = [1000, 10000, 100000, 1000000]'
    TOML_QUERY_SLONG_ARRAY_TEST_QUERY[9] = '.positive'

    // Test 10: Nested path with array
    TOML_QUERY_SLONG_ARRAY_TEST_TOML[10] = "'[metrics]', 13, 10, '[metrics.changes]', 13, 10, 'values = [-50000, -10000, 0, 10000, 50000]', 13, 10"
    TOML_QUERY_SLONG_ARRAY_TEST_QUERY[10] = '.metrics.changes.values'

    set_length_array(TOML_QUERY_SLONG_ARRAY_TEST_TOML, 10)
    set_length_array(TOML_QUERY_SLONG_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer TOML_QUERY_SLONG_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    5,  // Test 2
    3,  // Test 3
    3,  // Test 4
    2,  // Test 5
    2,  // Test 6
    0,  // Test 7 (empty)
    1,  // Test 8
    4,  // Test 9
    5   // Test 10
}


DEFINE_VARIABLE

// NOTE: NetLinx compiler quirk - SLONG literal negative values
// The NetLinx compiler does not properly handle literal negative values
// with SLONG type in constants. This causes type conversion warnings.
// To work around this, we initialize the array at runtime using subtraction.
volatile slong TOML_QUERY_SLONG_ARRAY_EXPECTED[10][5]


define_function InitializeTomlQuerySignedLongArrayExpectedData() {
    // Test 1: Mixed signs
    TOML_QUERY_SLONG_ARRAY_EXPECTED[1][1] = 0 - type_cast(1000000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[1][2] = type_cast(2000000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[1][3] = 0 - type_cast(3000000)

    // Test 2: Array property with negatives
    TOML_QUERY_SLONG_ARRAY_EXPECTED[2][1] = 0 - type_cast(100000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[2][2] = 0 - type_cast(200000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[2][3] = 0 - type_cast(300000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[2][4] = 0
    TOML_QUERY_SLONG_ARRAY_EXPECTED[2][5] = type_cast(100000)

    // Test 3: Nested array property
    TOML_QUERY_SLONG_ARRAY_EXPECTED[3][1] = 0 - type_cast(1234567)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[3][2] = 0 - type_cast(234567)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[3][3] = 0 - type_cast(34567)

    // Test 4: Array with zeros
    TOML_QUERY_SLONG_ARRAY_EXPECTED[4][1] = 0
    TOML_QUERY_SLONG_ARRAY_EXPECTED[4][2] = 0
    TOML_QUERY_SLONG_ARRAY_EXPECTED[4][3] = 0

    // Test 5: Very large negative values
    TOML_QUERY_SLONG_ARRAY_EXPECTED[5][1] = 0 - type_cast(1000000000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[5][2] = 0 - type_cast(2000000000)

    // Test 6: Extreme values
    TOML_QUERY_SLONG_ARRAY_EXPECTED[6][1] = type_cast(2147483647)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[6][2] = 0 - type_cast(2147483648)

    // Test 7: Empty array (no initialization needed)

    // Test 8: Single negative element
    TOML_QUERY_SLONG_ARRAY_EXPECTED[8][1] = 0 - type_cast(123456789)

    // Test 9: All positive
    TOML_QUERY_SLONG_ARRAY_EXPECTED[9][1] = type_cast(1000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[9][2] = type_cast(10000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[9][3] = type_cast(100000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[9][4] = type_cast(1000000)

    // Test 10: Nested path with array
    TOML_QUERY_SLONG_ARRAY_EXPECTED[10][1] = 0 - type_cast(50000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[10][2] = 0 - type_cast(10000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[10][3] = 0
    TOML_QUERY_SLONG_ARRAY_EXPECTED[10][4] = type_cast(10000)
    TOML_QUERY_SLONG_ARRAY_EXPECTED[10][5] = type_cast(50000)
}


define_function TestNAVTomlQuerySignedLongArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQuerySignedLongArray'")

    InitializeTomlQuerySignedLongArrayTestData()
    InitializeTomlQuerySignedLongArrayExpectedData()

    for (x = 1; x <= length_array(TOML_QUERY_SLONG_ARRAY_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var slong result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVTomlParse(TOML_QUERY_SLONG_ARRAY_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQuerySignedLongArray(toml, TOML_QUERY_SLONG_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   TOML_QUERY_SLONG_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(TOML_QUERY_SLONG_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertSignedLongEqual("'Array element ', itoa(i)",
                                         TOML_QUERY_SLONG_ARRAY_EXPECTED[x][i],
                                         result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(TOML_QUERY_SLONG_ARRAY_EXPECTED[x][i])",
                                "'Element ', itoa(i), ': ', itoa(result[i])")

                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlQuerySignedLongArray'")
}
