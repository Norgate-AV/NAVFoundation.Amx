PROGRAM_NAME='NAVTomlQuerySignedLong'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_QUERY_SLONG_INPUT[10][512]
volatile char TOML_QUERY_SLONG_PATH[10][64]


define_function InitializeTomlQuerySignedLongTestData() {
    // Test 1: Positive value
    TOML_QUERY_SLONG_INPUT[1] = 'value = 1000000'
    TOML_QUERY_SLONG_PATH[1] = '.value'

    // Test 2: Negative value
    TOML_QUERY_SLONG_INPUT[2] = 'balance = -500000'
    TOML_QUERY_SLONG_PATH[2] = '.balance'

    // Test 3: Nested negative value
    TOML_QUERY_SLONG_INPUT[3] = "'[account]', 13, 10, 'deficit = -1000000', 13, 10"
    TOML_QUERY_SLONG_PATH[3] = '.account.deficit'

    // Test 4: Array with negative
    TOML_QUERY_SLONG_INPUT[4] = 'amounts = [-100000, -200000, -300000]'
    TOML_QUERY_SLONG_PATH[4] = '.amounts[2]'

    // Test 5: Array of tables with negative
    TOML_QUERY_SLONG_INPUT[5] = "'[[transaction]]', 13, 10, 'offset = -50000', 13, 10, '[[transaction]]', 13, 10, 'offset = -100000', 13, 10, '[[transaction]]', 13, 10, 'offset = -150000', 13, 10"
    TOML_QUERY_SLONG_PATH[5] = '.transaction[3].offset'

    // Test 6: Deeply nested negative
    TOML_QUERY_SLONG_INPUT[6] = "'[financial]', 13, 10, '[financial.data]', 13, 10, 'loss = -2000000', 13, 10"
    TOML_QUERY_SLONG_PATH[6] = '.financial.data.loss'

    // Test 7: Zero value
    TOML_QUERY_SLONG_INPUT[7] = 'net = 0'
    TOML_QUERY_SLONG_PATH[7] = '.net'

    // Test 8: Maximum positive value
    TOML_QUERY_SLONG_INPUT[8] = 'maxValue = 2147483647'
    TOML_QUERY_SLONG_PATH[8] = '.maxValue'

    // Test 9: Minimum negative value
    TOML_QUERY_SLONG_INPUT[9] = 'minValue = -2147483648'
    TOML_QUERY_SLONG_PATH[9] = '.minValue'

    // Test 10: Inline table with negative
    TOML_QUERY_SLONG_INPUT[10] = 'transactions = [{ amount = -12345, type = "debit" }, { amount = 67890, type = "credit" }]'
    TOML_QUERY_SLONG_PATH[10] = '.transactions[1].amount'

    set_length_array(TOML_QUERY_SLONG_INPUT, 10)
    set_length_array(TOML_QUERY_SLONG_PATH, 10)
}


define_function TestNAVTomlQuerySignedLong() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQuerySignedLong'")

    InitializeTomlQuerySignedLongTestData()

    for (x = 1; x <= length_array(TOML_QUERY_SLONG_INPUT); x++) {
        stack_var _NAVToml toml
        stack_var slong result
        stack_var slong expected

        if (!NAVTomlParse(TOML_QUERY_SLONG_INPUT[x], toml)) {
            NAVLogTestFailed(x, "'Parse success'", "'Parse failed'")
            continue
        }

        if (!NAVTomlQuerySignedLong(toml, TOML_QUERY_SLONG_PATH[x], result)) {
            NAVLogTestFailed(x, "'Query success'", "'Query failed'")
            continue
        }

        // NOTE: NetLinx compiler quirk - SLONG literal negative values
        // The NetLinx compiler does not properly handle literal negative values
        // with SLONG type (e.g., expected = -1000). This causes type conversion
        // warnings and incorrect values. To work around this, we initialize
        // expected to 0 and calculate negative values programmatically using
        // subtraction (e.g., expected = 0 - 1000 or expected - type_cast(1000)).
        expected = 0

        switch (x) {
            case 1: expected = type_cast(1000000)          // Test 1: Positive value
            case 2: expected = expected - type_cast(500000) // Test 2: Negative value
            case 3: expected = expected - type_cast(1000000) // Test 3: Nested negative
            case 4: expected = expected - type_cast(200000) // Test 4: Array with negative
            case 5: expected = expected - type_cast(150000) // Test 5: Array of tables
            case 6: expected = expected - type_cast(2000000) // Test 6: Deeply nested
            case 7: expected = 0                           // Test 7: Zero value
            case 8: expected = type_cast(2147483647)       // Test 8: Max positive
            case 9: expected = expected - type_cast(2147483648) // Test 9: Min negative
            case 10: expected = expected - type_cast(12345) // Test 10: Inline table
        }

        if (!NAVAssertSignedLongEqual('NAVTomlQuerySignedLong value',
                                      expected,
                                      result)) {
            NAVLogTestFailed(x,
                            itoa(expected),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlQuerySignedLong'")
}

