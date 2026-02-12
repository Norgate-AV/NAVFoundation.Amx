PROGRAM_NAME='NAVTomlQueryStringArray'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_QUERY_STRING_ARRAY_TEST_TOML[10][512]
volatile char TOML_QUERY_STRING_ARRAY_TEST_QUERY[10][64]


define_function InitializeTomlQueryStringArrayTestData() {
    // Test 1: Simple root array
    TOML_QUERY_STRING_ARRAY_TEST_TOML[1] = 'colors = ["red", "green", "blue"]'
    TOML_QUERY_STRING_ARRAY_TEST_QUERY[1] = '.colors'

    // Test 2: Array with quoted strings
    TOML_QUERY_STRING_ARRAY_TEST_TOML[2] = 'names = ["Alice", "Bob", "Charlie"]'
    TOML_QUERY_STRING_ARRAY_TEST_QUERY[2] = '.names'

    // Test 3: Nested array property
    TOML_QUERY_STRING_ARRAY_TEST_TOML[3] = "'[database]', 13, 10, 'hosts = ["localhost", "server1", "server2"]', 13, 10"
    TOML_QUERY_STRING_ARRAY_TEST_QUERY[3] = '.database.hosts'

    // Test 4: Empty strings
    TOML_QUERY_STRING_ARRAY_TEST_TOML[4] = 'empties = ["", "", ""]'
    TOML_QUERY_STRING_ARRAY_TEST_QUERY[4] = '.empties'

    // Test 5: Array with escape sequences
    TOML_QUERY_STRING_ARRAY_TEST_TOML[5] = 'escaped = ["line1\nline2", "tab\there"]'
    TOML_QUERY_STRING_ARRAY_TEST_QUERY[5] = '.escaped'

    // Test 6: Mixed string types
    TOML_QUERY_STRING_ARRAY_TEST_TOML[6] = 'paths = [''C:\Windows'', ''D:\Data'', ''E:\Backup'']'
    TOML_QUERY_STRING_ARRAY_TEST_QUERY[6] = '.paths'

    // Test 7: Empty array
    TOML_QUERY_STRING_ARRAY_TEST_TOML[7] = 'empty = []'
    TOML_QUERY_STRING_ARRAY_TEST_QUERY[7] = '.empty'

    // Test 8: Single element array
    TOML_QUERY_STRING_ARRAY_TEST_TOML[8] = 'single = ["only"]'
    TOML_QUERY_STRING_ARRAY_TEST_QUERY[8] = '.single'

    // Test 9: Unicode strings
    TOML_QUERY_STRING_ARRAY_TEST_TOML[9] = 'unicode = ["Hello", "World", "Test"]'
    TOML_QUERY_STRING_ARRAY_TEST_QUERY[9] = '.unicode'

    // Test 10: Nested path with array
    TOML_QUERY_STRING_ARRAY_TEST_TOML[10] = "'[server]', 13, 10, '[server.networks]', 13, 10, 'interfaces = ["eth0", "eth1"]', 13, 10"
    TOML_QUERY_STRING_ARRAY_TEST_QUERY[10] = '.server.networks.interfaces'

    set_length_array(TOML_QUERY_STRING_ARRAY_TEST_TOML, 10)
    set_length_array(TOML_QUERY_STRING_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer TOML_QUERY_STRING_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    2,  // Test 5
    3,  // Test 6
    0,  // Test 7 (empty)
    1,  // Test 8
    3,  // Test 9
    2   // Test 10
}

constant char TOML_QUERY_STRING_ARRAY_EXPECTED[10][3][64] = {
    {'red', 'green', 'blue'},                       // Test 1
    {'Alice', 'Bob', 'Charlie'},                    // Test 2
    {'localhost', 'server1', 'server2'},            // Test 3
    {'', '', ''},                                   // Test 4
    {{'l', 'i', 'n', 'e', '1', $0A, 'l', 'i', 'n', 'e', '2'}, {'t', 'a', 'b', $09, 'h', 'e', 'r', 'e'}},  // Test 5 (escaped characters as individual chars)
    {'C:\Windows', 'D:\Data', 'E:\Backup'},         // Test 6
    {''},                                           // Test 7 (empty)
    {'only'},                                       // Test 8
    {'Hello', 'World', 'Test'},                     // Test 9
    {'eth0', 'eth1'}                                // Test 10
}


define_function TestNAVTomlQueryStringArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQueryStringArray'")

    InitializeTomlQueryStringArrayTestData()

    for (x = 1; x <= length_array(TOML_QUERY_STRING_ARRAY_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var char result[100][256]
        stack_var integer i
        stack_var char failed

        if (!NAVTomlParse(TOML_QUERY_STRING_ARRAY_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQueryStringArray(toml, TOML_QUERY_STRING_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   TOML_QUERY_STRING_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(TOML_QUERY_STRING_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertStringEqual("'Array element ', itoa(i)",
                                     TOML_QUERY_STRING_ARRAY_EXPECTED[x][i],
                                     result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', TOML_QUERY_STRING_ARRAY_EXPECTED[x][i]",
                                "'Element ', itoa(i), ': ', result[i]")

                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlQueryStringArray'")
}
