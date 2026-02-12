PROGRAM_NAME='NAVYamlQueryNull'

DEFINE_VARIABLE

volatile char YAML_QUERY_NULL_TEST_YAML[14][512]
volatile char YAML_QUERY_NULL_TEST_QUERY[14][64]


define_function InitializeYamlQueryNullTestData() {
    // Test 1: NAVYamlQueryString with null value
    YAML_QUERY_NULL_TEST_YAML[1] = "'name: null', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[1] = '.name'

    // Test 2: NAVYamlQueryFloat with null value
    YAML_QUERY_NULL_TEST_YAML[2] = "'value: null', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[2] = '.value'

    // Test 3: NAVYamlQueryInteger with null value
    YAML_QUERY_NULL_TEST_YAML[3] = "'count: null', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[3] = '.count'

    // Test 4: NAVYamlQuerySignedInteger with null value
    YAML_QUERY_NULL_TEST_YAML[4] = "'offset: null', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[4] = '.offset'

    // Test 5: NAVYamlQueryLong with null value
    YAML_QUERY_NULL_TEST_YAML[5] = "'timestamp: null', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[5] = '.timestamp'

    // Test 6: NAVYamlQuerySignedLong with null value
    YAML_QUERY_NULL_TEST_YAML[6] = "'id: null', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[6] = '.id'

    // Test 7: NAVYamlQueryBoolean with null value
    YAML_QUERY_NULL_TEST_YAML[7] = "'enabled: null', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[7] = '.enabled'

    // Test 8: NAVYamlToStringArray with null element
    YAML_QUERY_NULL_TEST_YAML[8] = "'names:', 13, 10,
                                     '  - Alice', 13, 10,
                                     '  - null', 13, 10,
                                     '  - Charlie', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[8] = '.names'

    // Test 9: NAVYamlToFloatArray with null element
    YAML_QUERY_NULL_TEST_YAML[9] = "'values:', 13, 10,
                                     '  - 1.5', 13, 10,
                                     '  - null', 13, 10,
                                     '  - 3.5', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[9] = '.values'

    // Test 10: NAVYamlToIntegerArray with null element
    YAML_QUERY_NULL_TEST_YAML[10] = "'ports:', 13, 10,
                                      '  - 8080', 13, 10,
                                      '  - null', 13, 10,
                                      '  - 9090', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[10] = '.ports'

    // Test 11: NAVYamlToSignedIntegerArray with null element
    YAML_QUERY_NULL_TEST_YAML[11] = "'offsets:', 13, 10,
                                      '  - -100', 13, 10,
                                      '  - null', 13, 10,
                                      '  - 100', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[11] = '.offsets'

    // Test 12: NAVYamlToLongArray with null element
    YAML_QUERY_NULL_TEST_YAML[12] = "'timestamps:', 13, 10,
                                      '  - 1234567890', 13, 10,
                                      '  - null', 13, 10,
                                      '  - 9876543210', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[12] = '.timestamps'

    // Test 13: NAVYamlToSignedLongArray with null element
    YAML_QUERY_NULL_TEST_YAML[13] = "'ids:', 13, 10,
                                      '  - -1234567890', 13, 10,
                                      '  - null', 13, 10,
                                      '  - 1234567890', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[13] = '.ids'

    // Test 14: NAVYamlToBooleanArray with null element
    YAML_QUERY_NULL_TEST_YAML[14] = "'flags:', 13, 10,
                                      '  - true', 13, 10,
                                      '  - null', 13, 10,
                                      '  - false', 13, 10"
    YAML_QUERY_NULL_TEST_QUERY[14] = '.flags'

    set_length_array(YAML_QUERY_NULL_TEST_YAML, 14)
    set_length_array(YAML_QUERY_NULL_TEST_QUERY, 14)
}


define_function TestNAVYamlQueryNull() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryNull'")

    InitializeYamlQueryNullTestData()

    for (x = 1; x <= length_array(YAML_QUERY_NULL_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var char strResult[256]
        stack_var float floatResult
        stack_var integer intResult
        stack_var sinteger sintResult
        stack_var long longResult
        stack_var slong slongResult
        stack_var char boolResult
        stack_var char charArrayResult[10][256]
        stack_var float floatArrayResult[10]
        stack_var integer intArrayResult[10]
        stack_var sinteger sintArrayResult[10]
        stack_var long longArrayResult[10]
        stack_var slong slongArrayResult[10]
        stack_var char boolArrayResult[10]
        stack_var char shouldFail

        if (!NAVYamlParse(YAML_QUERY_NULL_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        shouldFail = false

        select {
            active (x == 1): shouldFail = NAVYamlQueryString(yaml, YAML_QUERY_NULL_TEST_QUERY[x], strResult)
            active (x == 2): shouldFail = NAVYamlQueryFloat(yaml, YAML_QUERY_NULL_TEST_QUERY[x], floatResult)
            active (x == 3): shouldFail = NAVYamlQueryInteger(yaml, YAML_QUERY_NULL_TEST_QUERY[x], intResult)
            active (x == 4): shouldFail = NAVYamlQuerySignedInteger(yaml, YAML_QUERY_NULL_TEST_QUERY[x], sintResult)
            active (x == 5): shouldFail = NAVYamlQueryLong(yaml, YAML_QUERY_NULL_TEST_QUERY[x], longResult)
            active (x == 6): shouldFail = NAVYamlQuerySignedLong(yaml, YAML_QUERY_NULL_TEST_QUERY[x], slongResult)
            active (x == 7): shouldFail = NAVYamlQueryBoolean(yaml, YAML_QUERY_NULL_TEST_QUERY[x], boolResult)
            active (x == 8): shouldFail = NAVYamlQueryStringArray(yaml, YAML_QUERY_NULL_TEST_QUERY[x], charArrayResult)
            active (x == 9): shouldFail = NAVYamlQueryFloatArray(yaml, YAML_QUERY_NULL_TEST_QUERY[x], floatArrayResult)
            active (x == 10): shouldFail = NAVYamlQueryIntegerArray(yaml, YAML_QUERY_NULL_TEST_QUERY[x], intArrayResult)
            active (x == 11): shouldFail = NAVYamlQuerySignedIntegerArray(yaml, YAML_QUERY_NULL_TEST_QUERY[x], sintArrayResult)
            active (x == 12): shouldFail = NAVYamlQueryLongArray(yaml, YAML_QUERY_NULL_TEST_QUERY[x], longArrayResult)
            active (x == 13): shouldFail = NAVYamlQuerySignedLongArray(yaml, YAML_QUERY_NULL_TEST_QUERY[x], slongArrayResult)
            active (x == 14): shouldFail = NAVYamlQueryBooleanArray(yaml, YAML_QUERY_NULL_TEST_QUERY[x], boolArrayResult)
        }

        if (shouldFail) {
            NAVLogTestFailed(x, 'Query should fail (null)', 'Query succeeded')
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQueryNull'")
}
