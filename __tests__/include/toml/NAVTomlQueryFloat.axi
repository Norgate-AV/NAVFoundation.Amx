PROGRAM_NAME='NAVTomlQueryFloat'

#include 'NAVFoundation.Toml.axi'

DEFINE_VARIABLE

volatile char TOML_QUERY_FLOAT_INPUT[15][2048]
volatile char TOML_QUERY_FLOAT_PATH[15][256]

constant char TOML_QUERY_FLOAT_EXPECTED_RESULT[] = {
    true,   // Test 1: Simple float
    true,   // Test 2: Negative float
    true,   // Test 3: Float with exponent
    false,  // Test 4: Positive infinity (NetLinx has no inf representation)
    false,  // Test 5: Negative infinity (NetLinx has no inf representation)
    false,  // Test 6: Not a number (NetLinx has no NaN representation)
    true,   // Test 7: Float with underscores
    true,   // Test 8: Nested float
    true,   // Test 9: Float in array element
    true,   // Test 10: Float in inline table
    false,  // Test 11: Query string as float (should fail)
    false,  // Test 12: Query boolean as float (should fail)
    false,  // Test 13: Query integer as float (should fail)
    true,   // Test 14: Large exponent
    true    // Test 15: Negative exponent
}

constant float TOML_QUERY_FLOAT_EXPECTED_VALUE[] = {
    3.14159,        // Test 1
    -273.15,        // Test 2
    5.0e+22,        // Test 3
    1.0,            // Test 4: Placeholder for inf (cannot represent in array)
    -1.0,           // Test 5: Placeholder for -inf
    0.0,            // Test 6: Placeholder for nan
    3.141592653,    // Test 7
    9.8,            // Test 8
    2.5,            // Test 9
    99.99,          // Test 10
    0.0,            // Test 11 (not used, fail case)
    0.0,            // Test 12 (not used, fail case)
    0.0,            // Test 13 (not used, fail case)
    1.0e+10,        // Test 14
    1.0e-10         // Test 15
}


define_function InitializeTomlQueryFloatTestData() {
    // Test 1: Simple float
    TOML_QUERY_FLOAT_INPUT[1] = 'pi = 3.14159'
    TOML_QUERY_FLOAT_PATH[1] = '.pi'

    // Test 2: Negative float
    TOML_QUERY_FLOAT_INPUT[2] = 'absolute_zero = -273.15'
    TOML_QUERY_FLOAT_PATH[2] = '.absolute_zero'

    // Test 3: Float with exponent
    TOML_QUERY_FLOAT_INPUT[3] = 'big = 5e+22'
    TOML_QUERY_FLOAT_PATH[3] = '.big'

    // Test 4: Positive infinity
    TOML_QUERY_FLOAT_INPUT[4] = 'infinity = inf'
    TOML_QUERY_FLOAT_PATH[4] = '.infinity'

    // Test 5: Negative infinity
    TOML_QUERY_FLOAT_INPUT[5] = 'minus_infinity = -inf'
    TOML_QUERY_FLOAT_PATH[5] = '.minus_infinity'

    // Test 6: Not a number (NaN)
    TOML_QUERY_FLOAT_INPUT[6] = 'not_a_number = nan'
    TOML_QUERY_FLOAT_PATH[6] = '.not_a_number'

    // Test 7: Float with underscores
    TOML_QUERY_FLOAT_INPUT[7] = 'precise = 3.141_592_653'
    TOML_QUERY_FLOAT_PATH[7] = '.precise'

    // Test 8: Nested float
    TOML_QUERY_FLOAT_INPUT[8] = "'[physics]', 13, 10, 'gravity = 9.8', 13, 10"
    TOML_QUERY_FLOAT_PATH[8] = '.physics.gravity'

    // Test 9: Float in array element
    TOML_QUERY_FLOAT_INPUT[9] = 'values = [1.5, 2.5, 3.5]'
    TOML_QUERY_FLOAT_PATH[9] = '.values[2]'

    // Test 10: Float in inline table
    TOML_QUERY_FLOAT_INPUT[10] = 'product = { price = 99.99 }'
    TOML_QUERY_FLOAT_PATH[10] = '.product.price'

    // Test 11: Query string as float (should fail)
    TOML_QUERY_FLOAT_INPUT[11] = 'text = "not a float"'
    TOML_QUERY_FLOAT_PATH[11] = '.text'

    // Test 12: Query boolean as float (should fail)
    TOML_QUERY_FLOAT_INPUT[12] = 'flag = true'
    TOML_QUERY_FLOAT_PATH[12] = '.flag'

    // Test 13: Query integer as float (should fail)
    TOML_QUERY_FLOAT_INPUT[13] = 'count = 42'
    TOML_QUERY_FLOAT_PATH[13] = '.count'

    // Test 14: Large exponent
    TOML_QUERY_FLOAT_INPUT[14] = 'huge = 1e+10'
    TOML_QUERY_FLOAT_PATH[14] = '.huge'

    // Test 15: Negative exponent
    TOML_QUERY_FLOAT_INPUT[15] = 'tiny = 1e-10'
    TOML_QUERY_FLOAT_PATH[15] = '.tiny'

    set_length_array(TOML_QUERY_FLOAT_INPUT, 15)
    set_length_array(TOML_QUERY_FLOAT_PATH, 15)
}


define_function TestNAVTomlQueryFloat() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQueryFloat'")

    InitializeTomlQueryFloatTestData()

    for (x = 1; x <= length_array(TOML_QUERY_FLOAT_INPUT); x++) {
        stack_var _NAVToml toml
        stack_var float result
        stack_var char queryResult

        // Parse TOML
        if (!NAVTomlParse(TOML_QUERY_FLOAT_INPUT[x], toml)) {
            NAVLogTestFailed(x, "'Parse success'", "'Parse failed'")
            continue
        }

        // Execute float query
        queryResult = NAVTomlQueryFloat(toml, TOML_QUERY_FLOAT_PATH[x], result)

        // Assert query result
        if (TOML_QUERY_FLOAT_EXPECTED_RESULT[x]) {
            // Expected to succeed
            if (!queryResult) {
                NAVLogTestFailed(x, "'Query success'", "'Query failed'")
                continue
            }
            // Special handling for inf and nan (can't directly compare)
            if (x == 4) {
                // Test positive infinity
                if (result <= 0.0) {
                    NAVLogTestFailed(x, "'inf'", ftoa(result))
                    continue
                }
            } else if (x == 5) {
                // Test negative infinity
                if (result >= 0.0) {
                    NAVLogTestFailed(x, "'-inf'", ftoa(result))
                    continue
                }
            } else if (x == 6) {
                // Test NaN - just verify query succeeded
                // NaN != NaN, so we can't use direct comparison
            } else {
                if (!NAVAssertFloatEqual('Float value should match',
                                         TOML_QUERY_FLOAT_EXPECTED_VALUE[x],
                                         result)) {
                    NAVLogTestFailed(x,
                                    ftoa(TOML_QUERY_FLOAT_EXPECTED_VALUE[x]),
                                    ftoa(result))
                    continue
                }
            }
        } else {
            // Expected to fail
            if (queryResult) {
                NAVLogTestFailed(x, "'Query failed'", "'Query succeeded'")
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlQueryFloat'")
}

