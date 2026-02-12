PROGRAM_NAME='NAVJsonQueryNull'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_NULL_TEST_JSON[14][512]
volatile char JSON_QUERY_NULL_TEST_QUERY[14][64]


define_function InitializeJsonQueryNullTestData() {
    // Test 1: NAVJsonQueryString with null value
    JSON_QUERY_NULL_TEST_JSON[1] = '{"name":null}'
    JSON_QUERY_NULL_TEST_QUERY[1] = '.name'

    // Test 2: NAVJsonQueryFloat with null value
    JSON_QUERY_NULL_TEST_JSON[2] = '{"value":null}'
    JSON_QUERY_NULL_TEST_QUERY[2] = '.value'

    // Test 3: NAVJsonQueryInteger with null value
    JSON_QUERY_NULL_TEST_JSON[3] = '{"count":null}'
    JSON_QUERY_NULL_TEST_QUERY[3] = '.count'

    // Test 4: NAVJsonQuerySignedInteger with null value
    JSON_QUERY_NULL_TEST_JSON[4] = '{"offset":null}'
    JSON_QUERY_NULL_TEST_QUERY[4] = '.offset'

    // Test 5: NAVJsonQueryLong with null value
    JSON_QUERY_NULL_TEST_JSON[5] = '{"timestamp":null}'
    JSON_QUERY_NULL_TEST_QUERY[5] = '.timestamp'

    // Test 6: NAVJsonQuerySignedLong with null value
    JSON_QUERY_NULL_TEST_JSON[6] = '{"id":null}'
    JSON_QUERY_NULL_TEST_QUERY[6] = '.id'

    // Test 7: NAVJsonQueryBoolean with null value
    JSON_QUERY_NULL_TEST_JSON[7] = '{"enabled":null}'
    JSON_QUERY_NULL_TEST_QUERY[7] = '.enabled'

    // Test 8: NAVJsonToStringArray with null element
    JSON_QUERY_NULL_TEST_JSON[8] = '{"names":["Alice",null,"Charlie"]}'
    JSON_QUERY_NULL_TEST_QUERY[8] = '.names'

    // Test 9: NAVJsonToFloatArray with null element
    JSON_QUERY_NULL_TEST_JSON[9] = '{"values":[1.5,null,3.5]}'
    JSON_QUERY_NULL_TEST_QUERY[9] = '.values'

    // Test 10: NAVJsonToIntegerArray with null element
    JSON_QUERY_NULL_TEST_JSON[10] = '{"ports":[8080,null,9090]}'
    JSON_QUERY_NULL_TEST_QUERY[10] = '.ports'

    // Test 11: NAVJsonToSignedIntegerArray with null element
    JSON_QUERY_NULL_TEST_JSON[11] = '{"offsets":[-100,null,100]}'
    JSON_QUERY_NULL_TEST_QUERY[11] = '.offsets'

    // Test 12: NAVJsonToLongArray with null element
    JSON_QUERY_NULL_TEST_JSON[12] = '{"timestamps":[1234567890,null,9876543210]}'
    JSON_QUERY_NULL_TEST_QUERY[12] = '.timestamps'

    // Test 13: NAVJsonToSignedLongArray with null element
    JSON_QUERY_NULL_TEST_JSON[13] = '{"ids":[-1234567890,null,1234567890]}'
    JSON_QUERY_NULL_TEST_QUERY[13] = '.ids'

    // Test 14: NAVJsonToBooleanArray with null element
    JSON_QUERY_NULL_TEST_JSON[14] = '{"flags":[true,null,false]}'
    JSON_QUERY_NULL_TEST_QUERY[14] = '.flags'

    set_length_array(JSON_QUERY_NULL_TEST_JSON, 14)
    set_length_array(JSON_QUERY_NULL_TEST_QUERY, 14)
}


define_function TestNAVJsonQueryNull() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQueryNull'")

    InitializeJsonQueryNullTestData()

    for (x = 1; x <= length_array(JSON_QUERY_NULL_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var char result
        stack_var char stringResult[NAV_MAX_BUFFER]
        stack_var float floatResult
        stack_var integer intResult
        stack_var sinteger sintResult
        stack_var long longResult
        stack_var slong slongResult
        stack_var char boolResult
        stack_var _NAVJsonNode arrayNode
        stack_var char stringArray[10][NAV_MAX_BUFFER]
        stack_var float floatArray[10]
        stack_var integer intArray[10]
        stack_var sinteger sintArray[10]
        stack_var long longArray[10]
        stack_var slong slongArray[10]
        stack_var char boolArray[10]

        if (!NAVJsonParse(JSON_QUERY_NULL_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        select {
            active (x == 1): {
                result = NAVJsonQueryString(json, JSON_QUERY_NULL_TEST_QUERY[x], stringResult)
            }
            active (x == 2): {
                result = NAVJsonQueryFloat(json, JSON_QUERY_NULL_TEST_QUERY[x], floatResult)
            }
            active (x == 3): {
                result = NAVJsonQueryInteger(json, JSON_QUERY_NULL_TEST_QUERY[x], intResult)
            }
            active (x == 4): {
                result = NAVJsonQuerySignedInteger(json, JSON_QUERY_NULL_TEST_QUERY[x], sintResult)
            }
            active (x == 5): {
                result = NAVJsonQueryLong(json, JSON_QUERY_NULL_TEST_QUERY[x], longResult)
            }
            active (x == 6): {
                result = NAVJsonQuerySignedLong(json, JSON_QUERY_NULL_TEST_QUERY[x], slongResult)
            }
            active (x == 7): {
                result = NAVJsonQueryBoolean(json, JSON_QUERY_NULL_TEST_QUERY[x], boolResult)
            }
            active (x >= 8 && x <= 14): {
                if (!NAVJsonQuery(json, JSON_QUERY_NULL_TEST_QUERY[x], arrayNode)) {
                    NAVLogTestFailed(x, 'Query array success', 'Query array failed')
                    continue
                }

                select {
                    active (x == 8): {
                        result = NAVJsonToStringArray(json, arrayNode, stringArray)
                    }
                    active (x == 9): {
                        result = NAVJsonToFloatArray(json, arrayNode, floatArray)
                    }
                    active (x == 10): {
                        result = NAVJsonToIntegerArray(json, arrayNode, intArray)
                    }
                    active (x == 11): {
                        result = NAVJsonToSignedIntegerArray(json, arrayNode, sintArray)
                    }
                    active (x == 12): {
                        result = NAVJsonToLongArray(json, arrayNode, longArray)
                    }
                    active (x == 13): {
                        result = NAVJsonToSignedLongArray(json, arrayNode, slongArray)
                    }
                    active (x == 14): {
                        result = NAVJsonToBooleanArray(json, arrayNode, boolArray)
                    }
                }
            }
        }

        if (!NAVAssertBooleanEqual('Query should return false for null', false, result)) {
            NAVLogTestFailed(x, 'false', 'true')
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQueryNull'")
}
