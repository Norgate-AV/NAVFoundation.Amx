PROGRAM_NAME='NAVJsonObjectArrayHelpers'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_OBJECT_ARRAY_HELPER_TEST[10][512]


define_function InitializeJsonObjectArrayHelperTestData() {
    // Test 1: Simple object with properties
    JSON_OBJECT_ARRAY_HELPER_TEST[1] = '{"name":"John","age":30,"city":"NYC"}'

    // Test 2: Simple array with elements
    JSON_OBJECT_ARRAY_HELPER_TEST[2] = '[10,20,30,40,50]'

    // Test 3: Object with nested object
    JSON_OBJECT_ARRAY_HELPER_TEST[3] = '{"user":{"name":"Jane","role":"admin"}}'

    // Test 4: Object with nested array
    JSON_OBJECT_ARRAY_HELPER_TEST[4] = '{"scores":[95,87,92]}'

    // Test 5: Array with nested objects
    JSON_OBJECT_ARRAY_HELPER_TEST[5] = '[{"id":1},{"id":2},{"id":3}]'

    // Test 6: Empty object
    JSON_OBJECT_ARRAY_HELPER_TEST[6] = '{}'

    // Test 7: Empty array
    JSON_OBJECT_ARRAY_HELPER_TEST[7] = '[]'

    // Test 8: Object with mixed types
    JSON_OBJECT_ARRAY_HELPER_TEST[8] = '{"text":"hello","number":42,"flag":true,"data":null}'

    // Test 9: Array with mixed types
    JSON_OBJECT_ARRAY_HELPER_TEST[9] = '["text",123,true,false,null]'

    // Test 10: Complex nested structure
    JSON_OBJECT_ARRAY_HELPER_TEST[10] = '{"items":[{"name":"A","value":1},{"name":"B","value":2}]}'

    set_length_array(JSON_OBJECT_ARRAY_HELPER_TEST, 10)
}


DEFINE_CONSTANT

// Expected child counts
constant integer JSON_OBJECT_ARRAY_HELPER_EXPECTED_CHILD_COUNT[10] = {
    3,  // Test 1: 3 properties (name, age, city)
    5,  // Test 2: 5 array elements
    1,  // Test 3: 1 property (user)
    1,  // Test 4: 1 property (scores)
    3,  // Test 5: 3 array elements
    0,  // Test 6: Empty object
    0,  // Test 7: Empty array
    4,  // Test 8: 4 properties
    5,  // Test 9: 5 array elements
    1   // Test 10: 1 property (items)
}

// Expected results for HasProperty with "name" key
constant char JSON_OBJECT_ARRAY_HELPER_HAS_NAME_PROPERTY[10] = {
    true,   // Test 1: Has "name"
    false,  // Test 2: Array (no properties)
    false,  // Test 3: Has "user" but not "name"
    false,  // Test 4: Has "scores" but not "name"
    false,  // Test 5: Array (no properties)
    false,  // Test 6: Empty object
    false,  // Test 7: Empty array
    false,  // Test 8: Has "text" but not "name"
    false,  // Test 9: Array (no properties)
    false   // Test 10: Has "items" but not "name"
}

// Expected results for GetPropertyByKey with "age" key (success/failure)
constant char JSON_OBJECT_ARRAY_HELPER_HAS_AGE_PROPERTY[10] = {
    true,   // Test 1: Has "age"
    false,  // Test 2: Array
    false,  // Test 3: No "age"
    false,  // Test 4: No "age"
    false,  // Test 5: Array
    false,  // Test 6: Empty
    false,  // Test 7: Array
    false,  // Test 8: No "age"
    false,  // Test 9: Array
    false   // Test 10: No "age"
}

// Expected "age" property values (when present)
constant float JSON_OBJECT_ARRAY_HELPER_EXPECTED_AGE_VALUE[10] = {
    30.0,  // Test 1
    0.0,   // Test 2 (N/A)
    0.0,   // Test 3 (N/A)
    0.0,   // Test 4 (N/A)
    0.0,   // Test 5 (N/A)
    0.0,   // Test 6 (N/A)
    0.0,   // Test 7 (N/A)
    0.0,   // Test 8 (N/A)
    0.0,   // Test 9 (N/A)
    0.0    // Test 10 (N/A)
}

// Expected results for GetArrayElement (index 1) success
constant char JSON_OBJECT_ARRAY_HELPER_HAS_ELEMENT_1[10] = {
    false,  // Test 1: Object
    true,   // Test 2: Array with 5 elements
    false,  // Test 3: Object
    false,  // Test 4: Object
    true,   // Test 5: Array with 3 elements
    false,  // Test 6: Object
    false,  // Test 7: Empty array
    false,  // Test 8: Object
    true,   // Test 9: Array with 5 elements
    false   // Test 10: Object
}

// Expected first array element types (for arrays)
constant char JSON_OBJECT_ARRAY_HELPER_ELEMENT_1_IS_NUMBER[10] = {
    false,  // Test 1: Object
    true,   // Test 2: Index 1 = 20 (number)
    false,  // Test 3: Object
    false,  // Test 4: Object
    false,  // Test 5: Index 1 = second object
    false,  // Test 6: Object
    false,  // Test 7: Empty array
    false,  // Test 8: Object
    true,   // Test 9: Index 1 = 123 (number) - 0-based indexing!
    false   // Test 10: Object
}

constant char JSON_OBJECT_ARRAY_HELPER_ELEMENT_1_IS_OBJECT[10] = {
    false,  // Test 1: Object
    false,  // Test 2: First element is number
    false,  // Test 3: Object
    false,  // Test 4: Object
    true,   // Test 5: First element is {"id":1}
    false,  // Test 6: Object
    false,  // Test 7: Empty array
    false,  // Test 8: Object
    false,  // Test 9: First element is string
    false   // Test 10: Object
}

constant char JSON_OBJECT_ARRAY_HELPER_ELEMENT_1_IS_STRING[10] = {
    false,  // Test 1: Object
    false,  // Test 2: Index 1 = number
    false,  // Test 3: Object
    false,  // Test 4: Object
    false,  // Test 5: Index 1 = object
    false,  // Test 6: Object
    false,  // Test 7: Empty array
    false,  // Test 8: Object
    false,  // Test 9: Index 1 = 123 (number), not string
    false   // Test 10: Object
}


define_function TestNAVJsonObjectArrayHelpers() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonObjectArrayHelpers'")

    InitializeJsonObjectArrayHelperTestData()

    for (x = 1; x <= length_array(JSON_OBJECT_ARRAY_HELPER_TEST); x++) {
        stack_var _NAVJson json
        stack_var _NAVJsonNode root
        stack_var _NAVJsonNode property
        stack_var _NAVJsonNode element
        stack_var integer childCount
        stack_var float ageValue

        if (!NAVJsonParse(JSON_OBJECT_ARRAY_HELPER_TEST[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonGetRootNode(json, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        // Test NAVJsonGetChildCount
        childCount = NAVJsonGetChildCount(root)
        if (!NAVAssertIntegerEqual('NAVJsonGetChildCount',
                                    JSON_OBJECT_ARRAY_HELPER_EXPECTED_CHILD_COUNT[x],
                                    childCount)) {
            NAVLogTestFailed(x,
                            itoa(JSON_OBJECT_ARRAY_HELPER_EXPECTED_CHILD_COUNT[x]),
                            itoa(childCount))
            continue
        }

        // Test NAVJsonHasProperty with "name"
        if (!NAVAssertBooleanEqual('NAVJsonHasProperty(name)',
                                    JSON_OBJECT_ARRAY_HELPER_HAS_NAME_PROPERTY[x],
                                    NAVJsonHasProperty(json, root, 'name'))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_OBJECT_ARRAY_HELPER_HAS_NAME_PROPERTY[x]),
                            NAVBooleanToString(NAVJsonHasProperty(json, root, 'name')))
            continue
        }

        // Test NAVJsonGetPropertyByKey with "age"
        if (JSON_OBJECT_ARRAY_HELPER_HAS_AGE_PROPERTY[x]) {
            if (!NAVJsonGetPropertyByKey(json, root, 'age', property)) {
                NAVLogTestFailed(x, 'GetPropertyByKey(age) success', 'GetPropertyByKey(age) failed')
                continue
            }

            if (!NAVJsonGetNumber(property, ageValue)) {
                NAVLogTestFailed(x, 'GetNumber for age success', 'GetNumber for age failed')
                continue
            }

            if (!NAVAssertFloatAlmostEqual('Age value',
                                           JSON_OBJECT_ARRAY_HELPER_EXPECTED_AGE_VALUE[x],
                                           ageValue,
                                           0.000001)) {
                NAVLogTestFailed(x,
                                ftoa(JSON_OBJECT_ARRAY_HELPER_EXPECTED_AGE_VALUE[x]),
                                ftoa(ageValue))
                continue
            }
        }
        else {
            if (NAVJsonGetPropertyByKey(json, root, 'age', property)) {
                NAVLogTestFailed(x, 'GetPropertyByKey(age) fail', 'GetPropertyByKey(age) succeeded')
                continue
            }
        }

        // Test NAVJsonGetArrayElement (index 1)
        if (JSON_OBJECT_ARRAY_HELPER_HAS_ELEMENT_1[x]) {
            if (!NAVJsonGetArrayElement(json, root, 1, element)) {
                NAVLogTestFailed(x, 'GetArrayElement(1) success', 'GetArrayElement(1) failed')
                continue
            }

            if (!NAVAssertBooleanEqual('Array element 1 is number',
                                        JSON_OBJECT_ARRAY_HELPER_ELEMENT_1_IS_NUMBER[x],
                                        NAVJsonIsNumber(element))) {
                NAVLogTestFailed(x,
                                NAVBooleanToString(JSON_OBJECT_ARRAY_HELPER_ELEMENT_1_IS_NUMBER[x]),
                                NAVBooleanToString(NAVJsonIsNumber(element)))
                continue
            }

            if (!NAVAssertBooleanEqual('Array element 1 is object',
                                        JSON_OBJECT_ARRAY_HELPER_ELEMENT_1_IS_OBJECT[x],
                                        NAVJsonIsObject(element))) {
                NAVLogTestFailed(x,
                                NAVBooleanToString(JSON_OBJECT_ARRAY_HELPER_ELEMENT_1_IS_OBJECT[x]),
                                NAVBooleanToString(NAVJsonIsObject(element)))
                continue
            }

            if (!NAVAssertBooleanEqual('Array element 1 is string',
                                        JSON_OBJECT_ARRAY_HELPER_ELEMENT_1_IS_STRING[x],
                                        NAVJsonIsString(element))) {
                NAVLogTestFailed(x,
                                NAVBooleanToString(JSON_OBJECT_ARRAY_HELPER_ELEMENT_1_IS_STRING[x]),
                                NAVBooleanToString(NAVJsonIsString(element)))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonObjectArrayHelpers'")
}
