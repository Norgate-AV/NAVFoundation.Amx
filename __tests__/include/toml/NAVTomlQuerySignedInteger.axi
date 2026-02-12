PROGRAM_NAME='NAVTomlQuerySignedInteger'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_QUERY_SINTEGER_INPUT[10][512]
volatile char TOML_QUERY_SINTEGER_PATH[10][64]


define_function InitializeTomlQuerySignedIntegerTestData() {
    // Test 1: Positive value
    TOML_QUERY_SINTEGER_INPUT[1] = 'value = 42'
    TOML_QUERY_SINTEGER_PATH[1] = '.value'

    // Test 2: Negative value
    TOML_QUERY_SINTEGER_INPUT[2] = 'temperature = -15'
    TOML_QUERY_SINTEGER_PATH[2] = '.temperature'

    // Test 3: Nested negative value
    TOML_QUERY_SINTEGER_INPUT[3] = "'[sensor]', 13, 10, 'offset = -100', 13, 10"
    TOML_QUERY_SINTEGER_PATH[3] = '.sensor.offset'

    // Test 4: Array with negative
    TOML_QUERY_SINTEGER_INPUT[4] = 'readings = [-10, -20, -30]'
    TOML_QUERY_SINTEGER_PATH[4] = '.readings[2]'

    // Test 5: Object in array of tables with negative
    TOML_QUERY_SINTEGER_INPUT[5] = "'[[data]]', 13, 10, 'delta = -5', 13, 10, '[[data]]', 13, 10, 'delta = -10', 13, 10, '[[data]]', 13, 10, 'delta = -15', 13, 10"
    TOML_QUERY_SINTEGER_PATH[5] = '.data[3].delta'

    // Test 6: Deeply nested negative
    TOML_QUERY_SINTEGER_INPUT[6] = "'[config]', 13, 10, '[config.calibration]', 13, 10, 'adjustment = -50', 13, 10"
    TOML_QUERY_SINTEGER_PATH[6] = '.config.calibration.adjustment'

    // Test 7: Zero value
    TOML_QUERY_SINTEGER_INPUT[7] = 'baseline = 0'
    TOML_QUERY_SINTEGER_PATH[7] = '.baseline'

    // Test 8: Maximum positive value
    TOML_QUERY_SINTEGER_INPUT[8] = 'maxValue = 32767'
    TOML_QUERY_SINTEGER_PATH[8] = '.maxValue'

    // Test 9: Maximum negative value
    TOML_QUERY_SINTEGER_INPUT[9] = 'minValue = -32768'
    TOML_QUERY_SINTEGER_PATH[9] = '.minValue'

    // Test 10: Inline table with negative
    TOML_QUERY_SINTEGER_INPUT[10] = 'reading = { value = -123, unit = "C" }'
    TOML_QUERY_SINTEGER_PATH[10] = '.reading.value'

    set_length_array(TOML_QUERY_SINTEGER_INPUT, 10)
    set_length_array(TOML_QUERY_SINTEGER_PATH, 10)
}


DEFINE_CONSTANT

constant sinteger TOML_QUERY_SINTEGER_EXPECTED[10] = {
    42,      // Test 1
    -15,     // Test 2
    -100,    // Test 3
    -20,     // Test 4
    -15,     // Test 5
    -50,     // Test 6
    0,       // Test 7
    32767,   // Test 8
    -32768,  // Test 9
    -123     // Test 10
}


define_function TestNAVTomlQuerySignedInteger() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQuerySignedInteger'")

    InitializeTomlQuerySignedIntegerTestData()

    for (x = 1; x <= length_array(TOML_QUERY_SINTEGER_INPUT); x++) {
        stack_var _NAVToml toml
        stack_var sinteger result

        if (!NAVTomlParse(TOML_QUERY_SINTEGER_INPUT[x], toml)) {
            NAVLogTestFailed(x, "'Parse success'", "'Parse failed'")
            continue
        }

        if (!NAVTomlQuerySignedInteger(toml, TOML_QUERY_SINTEGER_PATH[x], result)) {
            NAVLogTestFailed(x, "'Query success'", "'Query failed'")
            continue
        }

        if (!NAVAssertSignedIntegerEqual('NAVTomlQuerySignedInteger value',
                                         TOML_QUERY_SINTEGER_EXPECTED[x],
                                         result)) {
            NAVLogTestFailed(x,
                            itoa(TOML_QUERY_SINTEGER_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlQuerySignedInteger'")
}

