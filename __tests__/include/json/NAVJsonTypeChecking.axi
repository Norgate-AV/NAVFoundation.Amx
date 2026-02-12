PROGRAM_NAME='NAVJsonTypeChecking'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_TYPE_CHECK_TEST[10][256]


define_function InitializeJsonTypeCheckTestData() {
    // Test 1: Object
    JSON_TYPE_CHECK_TEST[1] = '{"name":"test"}'

    // Test 2: Array
    JSON_TYPE_CHECK_TEST[2] = '[1,2,3]'

    // Test 3: String
    JSON_TYPE_CHECK_TEST[3] = '{"value":"text"}'

    // Test 4: Number
    JSON_TYPE_CHECK_TEST[4] = '{"value":42}'

    // Test 5: True
    JSON_TYPE_CHECK_TEST[5] = '{"value":true}'

    // Test 6: False
    JSON_TYPE_CHECK_TEST[6] = '{"value":false}'

    // Test 7: Null
    JSON_TYPE_CHECK_TEST[7] = '{"value":null}'

    // Test 8: Nested object
    JSON_TYPE_CHECK_TEST[8] = '{"outer":{"inner":true}}'

    // Test 9: Array with mixed types
    JSON_TYPE_CHECK_TEST[9] = '[123,"text",true,false,null]'

    // Test 10: Complex structure
    JSON_TYPE_CHECK_TEST[10] = '{"data":[1,2,3],"name":"test","active":true}'

    set_length_array(JSON_TYPE_CHECK_TEST, 10)
}


DEFINE_CONSTANT

// Expected results for root node type checks (tests 1-10)
constant char JSON_TYPE_CHECK_ROOT_IS_OBJECT[10] = {
    true,   // Test 1: Object
    false,  // Test 2: Array
    true,   // Test 3: Object
    true,   // Test 4: Object
    true,   // Test 5: Object
    true,   // Test 6: Object
    true,   // Test 7: Object
    true,   // Test 8: Object
    false,  // Test 9: Array
    true    // Test 10: Object
}

constant char JSON_TYPE_CHECK_ROOT_IS_ARRAY[10] = {
    false,  // Test 1: Object
    true,   // Test 2: Array
    false,  // Test 3: Object
    false,  // Test 4: Object
    false,  // Test 5: Object
    false,  // Test 6: Object
    false,  // Test 7: Object
    false,  // Test 8: Object
    true,   // Test 9: Array
    false   // Test 10: Object
}

// Expected results for first child type checks (where applicable)
constant char JSON_TYPE_CHECK_FIRST_CHILD_IS_STRING[10] = {
    true,   // Test 1: "name":"test"
    false,  // Test 2: 1
    true,   // Test 3: "value":"text"
    false,  // Test 4: "value":42
    false,  // Test 5: "value":true
    false,  // Test 6: "value":false
    false,  // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    false,  // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char JSON_TYPE_CHECK_FIRST_CHILD_IS_NUMBER[10] = {
    false,  // Test 1: "name":"test"
    true,   // Test 2: 1
    false,  // Test 3: "value":"text"
    true,   // Test 4: "value":42
    false,  // Test 5: "value":true
    false,  // Test 6: "value":false
    false,  // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    true,   // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char JSON_TYPE_CHECK_FIRST_CHILD_IS_BOOLEAN[10] = {
    false,  // Test 1: "name":"test"
    false,  // Test 2: 1
    false,  // Test 3: "value":"text"
    false,  // Test 4: "value":42
    true,   // Test 5: "value":true
    true,   // Test 6: "value":false
    false,  // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    false,  // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char JSON_TYPE_CHECK_FIRST_CHILD_IS_TRUE[10] = {
    false,  // Test 1: "name":"test"
    false,  // Test 2: 1
    false,  // Test 3: "value":"text"
    false,  // Test 4: "value":42
    true,   // Test 5: "value":true
    false,  // Test 6: "value":false
    false,  // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    false,  // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char JSON_TYPE_CHECK_FIRST_CHILD_IS_FALSE[10] = {
    false,  // Test 1: "name":"test"
    false,  // Test 2: 1
    false,  // Test 3: "value":"text"
    false,  // Test 4: "value":42
    false,  // Test 5: "value":true
    true,   // Test 6: "value":false
    false,  // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    false,  // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char JSON_TYPE_CHECK_FIRST_CHILD_IS_NULL[10] = {
    false,  // Test 1: "name":"test"
    false,  // Test 2: 1
    false,  // Test 3: "value":"text"
    false,  // Test 4: "value":42
    false,  // Test 5: "value":true
    false,  // Test 6: "value":false
    true,   // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    false,  // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char JSON_TYPE_CHECK_FIRST_CHILD_IS_OBJECT[10] = {
    false,  // Test 1: "name":"test"
    false,  // Test 2: 1
    false,  // Test 3: "value":"text"
    false,  // Test 4: "value":42
    false,  // Test 5: "value":true
    false,  // Test 6: "value":false
    false,  // Test 7: "value":null
    true,   // Test 8: "outer":{...}
    false,  // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char JSON_TYPE_CHECK_FIRST_CHILD_IS_ARRAY[10] = {
    false,  // Test 1: "name":"test"
    false,  // Test 2: 1
    false,  // Test 3: "value":"text"
    false,  // Test 4: "value":42
    false,  // Test 5: "value":true
    false,  // Test 6: "value":false
    false,  // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    false,  // Test 9: 123
    true    // Test 10: "data":[...]
}


define_function TestNAVJsonTypeChecking() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonTypeChecking'")

    InitializeJsonTypeCheckTestData()

    for (x = 1; x <= length_array(JSON_TYPE_CHECK_TEST); x++) {
        stack_var _NAVJson json
        stack_var _NAVJsonNode root
        stack_var _NAVJsonNode child

        if (!NAVJsonParse(JSON_TYPE_CHECK_TEST[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonGetRootNode(json, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        // Test root node type checking
        if (!NAVAssertBooleanEqual('NAVJsonIsObject for root',
                                    JSON_TYPE_CHECK_ROOT_IS_OBJECT[x],
                                    NAVJsonIsObject(root))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_TYPE_CHECK_ROOT_IS_OBJECT[x]),
                            NAVBooleanToString(NAVJsonIsObject(root)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVJsonIsArray for root',
                                    JSON_TYPE_CHECK_ROOT_IS_ARRAY[x],
                                    NAVJsonIsArray(root))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_TYPE_CHECK_ROOT_IS_ARRAY[x]),
                            NAVBooleanToString(NAVJsonIsArray(root)))
            continue
        }

        // Get first child for further testing
        if (!NAVJsonGetFirstChild(json, root, child)) {
            NAVLogTestFailed(x, 'Get first child success', 'Get first child failed')
            continue
        }

        // Test first child type checking
        if (!NAVAssertBooleanEqual('NAVJsonIsString for first child',
                                    JSON_TYPE_CHECK_FIRST_CHILD_IS_STRING[x],
                                    NAVJsonIsString(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_TYPE_CHECK_FIRST_CHILD_IS_STRING[x]),
                            NAVBooleanToString(NAVJsonIsString(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVJsonIsNumber for first child',
                                    JSON_TYPE_CHECK_FIRST_CHILD_IS_NUMBER[x],
                                    NAVJsonIsNumber(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_TYPE_CHECK_FIRST_CHILD_IS_NUMBER[x]),
                            NAVBooleanToString(NAVJsonIsNumber(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVJsonIsBoolean for first child',
                                    JSON_TYPE_CHECK_FIRST_CHILD_IS_BOOLEAN[x],
                                    NAVJsonIsBoolean(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_TYPE_CHECK_FIRST_CHILD_IS_BOOLEAN[x]),
                            NAVBooleanToString(NAVJsonIsBoolean(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVJsonIsTrue for first child',
                                    JSON_TYPE_CHECK_FIRST_CHILD_IS_TRUE[x],
                                    NAVJsonIsTrue(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_TYPE_CHECK_FIRST_CHILD_IS_TRUE[x]),
                            NAVBooleanToString(NAVJsonIsTrue(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVJsonIsFalse for first child',
                                    JSON_TYPE_CHECK_FIRST_CHILD_IS_FALSE[x],
                                    NAVJsonIsFalse(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_TYPE_CHECK_FIRST_CHILD_IS_FALSE[x]),
                            NAVBooleanToString(NAVJsonIsFalse(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVJsonIsNull for first child',
                                    JSON_TYPE_CHECK_FIRST_CHILD_IS_NULL[x],
                                    NAVJsonIsNull(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_TYPE_CHECK_FIRST_CHILD_IS_NULL[x]),
                            NAVBooleanToString(NAVJsonIsNull(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVJsonIsObject for first child',
                                    JSON_TYPE_CHECK_FIRST_CHILD_IS_OBJECT[x],
                                    NAVJsonIsObject(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_TYPE_CHECK_FIRST_CHILD_IS_OBJECT[x]),
                            NAVBooleanToString(NAVJsonIsObject(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVJsonIsArray for first child',
                                    JSON_TYPE_CHECK_FIRST_CHILD_IS_ARRAY[x],
                                    NAVJsonIsArray(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_TYPE_CHECK_FIRST_CHILD_IS_ARRAY[x]),
                            NAVBooleanToString(NAVJsonIsArray(child)))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonTypeChecking'")
}
