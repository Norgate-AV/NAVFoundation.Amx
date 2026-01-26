PROGRAM_NAME='NAVJsonNavigationEdgeCases'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_NAVIGATION_TEST_JSON[10][512]


define_function InitializeJsonNavigationEdgeCasesTestData() {
    // Test 1: Single root value (no children)
    JSON_NAVIGATION_TEST_JSON[1] = '42'

    // Test 2: Empty object
    JSON_NAVIGATION_TEST_JSON[2] = '{}'

    // Test 3: Empty array
    JSON_NAVIGATION_TEST_JSON[3] = '[]'

    // Test 4: Object with single property
    JSON_NAVIGATION_TEST_JSON[4] = '{"single":"value"}'

    // Test 5: Array with single element
    JSON_NAVIGATION_TEST_JSON[5] = '[123]'

    // Test 6: Siblings navigation - multiple properties
    JSON_NAVIGATION_TEST_JSON[6] = '{"a":1,"b":2,"c":3,"d":4,"e":5}'

    // Test 7: Siblings navigation - array elements
    JSON_NAVIGATION_TEST_JSON[7] = '[10,20,30,40,50]'

    // Test 8: Mixed siblings - array with different types
    JSON_NAVIGATION_TEST_JSON[8] = '[true,"text",123,null,{"key":"value"}]'

    // Test 9: Parent navigation from deeply nested node
    JSON_NAVIGATION_TEST_JSON[9] = '{"outer":{"middle":{"inner":"value"}}}'

    // Test 10: Complex tree with multiple children at each level
    JSON_NAVIGATION_TEST_JSON[10] = '{"branch1":{"leaf1":1,"leaf2":2},"branch2":{"leaf3":3,"leaf4":4}}'

    set_length_array(JSON_NAVIGATION_TEST_JSON, 10)
}


DEFINE_CONSTANT

constant integer JSON_NAVIGATION_EXPECTED_CHILD_COUNT[10] = {
    0,  // Test 1 - primitive has no children
    0,  // Test 2 - empty object
    0,  // Test 3 - empty array
    1,  // Test 4 - one property
    1,  // Test 5 - one element
    5,  // Test 6 - five properties
    5,  // Test 7 - five elements
    5,  // Test 8 - five mixed elements
    1,  // Test 9 - outer has one child (middle)
    2   // Test 10 - root object has two branches
}

constant char JSON_NAVIGATION_TEST_HAS_CHILDREN[10] = {
    false, // Test 1
    false, // Test 2
    false, // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true,  // Test 8
    true,  // Test 9
    true   // Test 10
}

constant char JSON_NAVIGATION_TEST_CAN_GET_SIBLING[10] = {
    false, // Test 1 - no siblings
    false, // Test 2 - empty
    false, // Test 3 - empty
    false, // Test 4 - single child, no sibling
    false, // Test 5 - single element, no sibling
    true,  // Test 6 - multiple properties
    true,  // Test 7 - multiple elements
    true,  // Test 8 - multiple elements
    false, // Test 9 - testing single child
    true   // Test 10 - multiple branches
}


define_function TestNAVJsonNavigationEdgeCases() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonNavigationEdgeCases'")

    InitializeJsonNavigationEdgeCasesTestData()

    for (x = 1; x <= length_array(JSON_NAVIGATION_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var _NAVJsonNode root
        stack_var _NAVJsonNode firstChild
        stack_var _NAVJsonNode nextSibling
        stack_var _NAVJsonNode parent
        stack_var integer childCount
        stack_var char hasChildren
        stack_var char canGetSibling

        if (!NAVJsonParse(JSON_NAVIGATION_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Get root node
        if (!NAVJsonGetRootNode(json, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        // Test child count
        childCount = NAVJsonGetChildCount(root)
        if (!NAVAssertIntegerEqual('Child count',
                                  JSON_NAVIGATION_EXPECTED_CHILD_COUNT[x],
                                  childCount)) {
            NAVLogTestFailed(x,
                            itoa(JSON_NAVIGATION_EXPECTED_CHILD_COUNT[x]),
                            itoa(childCount))
            continue
        }

        // Test has children
        hasChildren = (childCount > 0)
        if (!NAVAssertBooleanEqual('Has children',
                                   JSON_NAVIGATION_TEST_HAS_CHILDREN[x],
                                   hasChildren)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_NAVIGATION_TEST_HAS_CHILDREN[x]),
                            NAVBooleanToString(hasChildren))
            continue
        }

        // Test getting first child (should match expected)
        if (JSON_NAVIGATION_TEST_HAS_CHILDREN[x]) {
            if (!NAVJsonGetFirstChild(json, root, firstChild)) {
                NAVLogTestFailed(x, 'Get first child success', 'Get first child failed')
                continue
            }

            // Test parent navigation from child
            if (!NAVJsonGetParentNode(json, firstChild, parent)) {
                NAVLogTestFailed(x, 'Get parent success', 'Get parent failed')
                continue
            }

            // Verify parent was successfully retrieved (parent field should be non-zero for non-root nodes)
            if (firstChild.parent == 0) {
                NAVLogTestFailed(x, 'Child has parent reference', 'Child has no parent')
                continue
            }

            // Test sibling navigation
            canGetSibling = NAVJsonGetNextNode(json, firstChild, nextSibling)
            if (!NAVAssertBooleanEqual('Can get sibling',
                                      JSON_NAVIGATION_TEST_CAN_GET_SIBLING[x],
                                      canGetSibling)) {
                NAVLogTestFailed(x,
                                NAVBooleanToString(JSON_NAVIGATION_TEST_CAN_GET_SIBLING[x]),
                                NAVBooleanToString(canGetSibling))
                continue
            }
        }

        // Test root has no parent
        if (NAVJsonGetParentNode(json, root, parent)) {
            NAVLogTestFailed(x, 'Root has no parent', 'Root has parent')
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonNavigationEdgeCases'")
}
