PROGRAM_NAME='NAVJsonGetParentNode'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_GET_PARENT_NODE_TEST_JSON[10][512]


define_function InitializeJsonGetParentNodeTestData() {
    // Test 1: Root node has no parent
    JSON_GET_PARENT_NODE_TEST_JSON[1] = '{"root":true}'

    // Test 2: Object property parent is root
    JSON_GET_PARENT_NODE_TEST_JSON[2] = '{"child":42}'

    // Test 3: Nested object - grandchild to child
    JSON_GET_PARENT_NODE_TEST_JSON[3] = '{"parent":{"child":{"grandchild":"value"}}}'

    // Test 4: Array element parent is array
    JSON_GET_PARENT_NODE_TEST_JSON[4] = '[1,2,3]'

    // Test 5: Object in array - object parent is array
    JSON_GET_PARENT_NODE_TEST_JSON[5] = '[{"item":1}, {"item":2}]'

    // Test 6: Property in object in array
    JSON_GET_PARENT_NODE_TEST_JSON[6] = '[{"name":"A","value":1}]'

    // Test 7: Deeply nested structure
    JSON_GET_PARENT_NODE_TEST_JSON[7] = '{"level1":{"level2":{"level3":"deep"}}}'

    // Test 8: Array with nested arrays
    JSON_GET_PARENT_NODE_TEST_JSON[8] = '[[1,2],[3,4]]'

    // Test 9: Multiple properties at same level
    JSON_GET_PARENT_NODE_TEST_JSON[9] = '{"a":1,"b":2,"c":3}'

    // Test 10: Complex mixed structure
    JSON_GET_PARENT_NODE_TEST_JSON[10] = '{"data":[{"items":[1,2,3]}]}'

    set_length_array(JSON_GET_PARENT_NODE_TEST_JSON, 10)
}


DEFINE_CONSTANT

// Expected: can get parent (false for root, true for children)
constant char JSON_GET_PARENT_NODE_EXPECTED_HAS_PARENT[10] = {
    false, // Test 1: Root has no parent
    true,  // Test 2: Property has parent (root)
    true,  // Test 3: Grandchild has parent
    true,  // Test 4: Array element has parent
    true,  // Test 5: Object in array has parent
    true,  // Test 6: Property has parent
    true,  // Test 7: Deep property has parent
    true,  // Test 8: Nested array has parent
    true,  // Test 9: Property has parent
    true   // Test 10: Nested structure has parent
}


define_function TestNAVJsonGetParentNode() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonGetParentNode'")

    InitializeJsonGetParentNodeTestData()

    for (x = 1; x <= length_array(JSON_GET_PARENT_NODE_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var _NAVJsonNode root
        stack_var _NAVJsonNode child
        stack_var _NAVJsonNode parent
        stack_var char hasParent

        if (!NAVJsonParse(JSON_GET_PARENT_NODE_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonGetRootNode(json, root)) {
            NAVLogTestFailed(x, 'Get root node', 'Failed to get root')
            continue
        }

        // For test 1, test root node has no parent
        if (x == 1) {
            hasParent = NAVJsonGetParentNode(json, root, parent)
            if (!NAVAssertBooleanEqual('NAVJsonGetParentNode root',
                                       JSON_GET_PARENT_NODE_EXPECTED_HAS_PARENT[x],
                                       hasParent)) {
                NAVLogTestFailed(x,
                                NAVBooleanToString(JSON_GET_PARENT_NODE_EXPECTED_HAS_PARENT[x]),
                                NAVBooleanToString(hasParent))
                continue
            }
        }
        // For other tests, get first child and check it has a parent
        else {
            if (!NAVJsonGetFirstChild(json, root, child)) {
                NAVLogTestFailed(x, 'Get first child', 'Failed to get child')
                continue
            }

            hasParent = NAVJsonGetParentNode(json, child, parent)
            if (!NAVAssertBooleanEqual('NAVJsonGetParentNode child',
                                       JSON_GET_PARENT_NODE_EXPECTED_HAS_PARENT[x],
                                       hasParent)) {
                NAVLogTestFailed(x,
                                NAVBooleanToString(JSON_GET_PARENT_NODE_EXPECTED_HAS_PARENT[x]),
                                NAVBooleanToString(hasParent))
                continue
            }

            // Verify parent is root
            if (hasParent) {
                if (!NAVAssertBooleanEqual('Parent is root',
                                          true,
                                          (parent.type == root.type))) {
                    NAVLogTestFailed(x, 'Parent is root', 'Parent is not root')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonGetParentNode'")
}
