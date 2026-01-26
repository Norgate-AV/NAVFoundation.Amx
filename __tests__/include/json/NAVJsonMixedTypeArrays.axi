PROGRAM_NAME='NAVJsonMixedTypeArrays'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_MIXED_TYPE_ARRAY_TEST_JSON[10][512]


define_function InitializeJsonMixedTypeArrayTestData() {
    // Test 1: Array with mixed string and number
    JSON_MIXED_TYPE_ARRAY_TEST_JSON[1] = '["text", 123]'

    // Test 2: Array with mixed number and boolean
    JSON_MIXED_TYPE_ARRAY_TEST_JSON[2] = '[42, true, false]'

    // Test 3: Array with string, number, boolean
    JSON_MIXED_TYPE_ARRAY_TEST_JSON[3] = '["hello", 42, true]'

    // Test 4: Array with null and other types
    JSON_MIXED_TYPE_ARRAY_TEST_JSON[4] = '[null, "text", 123]'

    // Test 5: Array with objects and primitives
    JSON_MIXED_TYPE_ARRAY_TEST_JSON[5] = '[{"id":1}, "text", 42]'

    // Test 6: Array with arrays and primitives
    JSON_MIXED_TYPE_ARRAY_TEST_JSON[6] = '[[1,2], "text", 42]'

    // Test 7: Array with boolean and string
    JSON_MIXED_TYPE_ARRAY_TEST_JSON[7] = '[true, "false", false]'

    // Test 8: Array with number and string numbers
    JSON_MIXED_TYPE_ARRAY_TEST_JSON[8] = '[42, "42", 43]'

    // Test 9: Homogeneous string array (should succeed)
    JSON_MIXED_TYPE_ARRAY_TEST_JSON[9] = '["a", "b", "c"]'

    // Test 10: Homogeneous number array (should succeed)
    JSON_MIXED_TYPE_ARRAY_TEST_JSON[10] = '[1, 2, 3]'

    set_length_array(JSON_MIXED_TYPE_ARRAY_TEST_JSON, 10)
}


DEFINE_CONSTANT

// Expected success for string array extraction (only Test 9 should succeed)
constant char JSON_MIXED_TYPE_ARRAY_STRING_SUCCESS[10] = {
    false, // Test 1: Has number
    false, // Test 2: Has boolean
    false, // Test 3: Has number and boolean
    false, // Test 4: Has null
    false, // Test 5: Has object
    false, // Test 6: Has array
    false, // Test 7: Has boolean
    false, // Test 8: Has number
    true,  // Test 9: All strings - SHOULD SUCCEED
    false  // Test 10: All numbers
}

// Expected success for float array extraction (only Test 10 should succeed)
constant char JSON_MIXED_TYPE_ARRAY_FLOAT_SUCCESS[10] = {
    false, // Test 1: Has string
    false, // Test 2: Has boolean
    false, // Test 3: Has string and boolean
    false, // Test 4: Has null and string
    false, // Test 5: Has object and string
    false, // Test 6: Has array and string
    false, // Test 7: All booleans
    false, // Test 8: Has string
    false, // Test 9: All strings
    true   // Test 10: All numbers - SHOULD SUCCEED
}

// Expected success for boolean array extraction (Test 2 has 2 booleans but also number)
constant char JSON_MIXED_TYPE_ARRAY_BOOLEAN_SUCCESS[10] = {
    false, // Test 1: Has string and number
    false, // Test 2: Has number with booleans
    false, // Test 3: Has string and number
    false, // Test 4: Has null and string
    false, // Test 5: Has object
    false, // Test 6: Has array
    false, // Test 7: Has string with booleans
    false, // Test 8: Has numbers and string
    false, // Test 9: All strings
    false  // Test 10: All numbers
}


define_function TestNAVJsonMixedTypeArrays() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonMixedTypeArrays'")

    InitializeJsonMixedTypeArrayTestData()

    for (x = 1; x <= length_array(JSON_MIXED_TYPE_ARRAY_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var _NAVJsonNode root
        stack_var char stringResult[10][64]
        stack_var float floatResult[10]
        stack_var char booleanResult[10]
        stack_var char stringSuccess
        stack_var char floatSuccess
        stack_var char booleanSuccess

        if (!NAVJsonParse(JSON_MIXED_TYPE_ARRAY_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonGetRootNode(json, root)) {
            NAVLogTestFailed(x, 'Get root node', 'Failed to get root')
            continue
        }

        // Test string array extraction
        stringSuccess = NAVJsonToStringArray(json, root, stringResult)
        if (!NAVAssertBooleanEqual('NAVJsonToStringArray mixed type',
                                   JSON_MIXED_TYPE_ARRAY_STRING_SUCCESS[x],
                                   stringSuccess)) {
            NAVLogTestFailed(x,
                            "'String: ', NAVBooleanToString(JSON_MIXED_TYPE_ARRAY_STRING_SUCCESS[x])",
                            "'String: ', NAVBooleanToString(stringSuccess)")
            continue
        }

        // Test float array extraction
        floatSuccess = NAVJsonToFloatArray(json, root, floatResult)
        if (!NAVAssertBooleanEqual('NAVJsonToFloatArray mixed type',
                                   JSON_MIXED_TYPE_ARRAY_FLOAT_SUCCESS[x],
                                   floatSuccess)) {
            NAVLogTestFailed(x,
                            "'Float: ', NAVBooleanToString(JSON_MIXED_TYPE_ARRAY_FLOAT_SUCCESS[x])",
                            "'Float: ', NAVBooleanToString(floatSuccess)")
            continue
        }

        // Test boolean array extraction
        booleanSuccess = NAVJsonToBooleanArray(json, root, booleanResult)
        if (!NAVAssertBooleanEqual('NAVJsonToBooleanArray mixed type',
                                   JSON_MIXED_TYPE_ARRAY_BOOLEAN_SUCCESS[x],
                                   booleanSuccess)) {
            NAVLogTestFailed(x,
                            "'Boolean: ', NAVBooleanToString(JSON_MIXED_TYPE_ARRAY_BOOLEAN_SUCCESS[x])",
                            "'Boolean: ', NAVBooleanToString(booleanSuccess)")
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonMixedTypeArrays'")
}
