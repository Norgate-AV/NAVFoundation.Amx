PROGRAM_NAME='NAVJsonTreeInfo'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_TREE_INFO_TEST[10][512]


define_function InitializeJsonTreeInfoTestData() {
    // Test 1: Simple object with 3 nodes (root + 2 children)
    JSON_TREE_INFO_TEST[1] = '{"a":1}'

    // Test 2: Simple array with 4 nodes (root + 3 children)
    JSON_TREE_INFO_TEST[2] = '[1,2,3]'

    // Test 3: Nested object - depth 2
    JSON_TREE_INFO_TEST[3] = '{"outer":{"inner":true}}'

    // Test 4: Nested array - depth 2
    JSON_TREE_INFO_TEST[4] = '[[1,2],[3,4]]'

    // Test 5: Deep nesting - depth 4
    JSON_TREE_INFO_TEST[5] = '{"a":{"b":{"c":{"d":1}}}}'

    // Test 6: Empty object - 1 node, depth 1
    JSON_TREE_INFO_TEST[6] = '{}'

    // Test 7: Empty array - 1 node, depth 1
    JSON_TREE_INFO_TEST[7] = '[]'

    // Test 8: Wide structure - many siblings
    JSON_TREE_INFO_TEST[8] = '{"a":1,"b":2,"c":3,"d":4,"e":5}'

    // Test 9: Mixed depth and width
    JSON_TREE_INFO_TEST[9] = '{"users":[{"name":"A","age":25},{"name":"B","age":30}]}'

    // Test 10: Complex structure
    JSON_TREE_INFO_TEST[10] = '{"data":{"items":[1,2,3],"meta":{"count":3,"active":true}}}'

    set_length_array(JSON_TREE_INFO_TEST, 10)
}


DEFINE_CONSTANT

// Expected node counts
constant integer JSON_TREE_INFO_EXPECTED_NODE_COUNT[10] = {
    2,   // Test 1: root + 1 property (key:value pair counted as 1)
    4,   // Test 2: root + 3 array elements
    3,   // Test 3: root + outer property + inner property
    7,   // Test 4: root + 2 sub-arrays + 4 elements = [[1,2],[3,4]]
    5,   // Test 5: root + a + b + c + d
    1,   // Test 6: root only
    1,   // Test 7: root only
    6,   // Test 8: root + 5 properties
    8,   // Test 9: root + users + 2 objects + (2 properties each) = 1 + 1 + 2 + 4
    9    // Test 10: root + data + items + meta + (3 elements + 2 properties) = 1 + 1 + 1 + 1 + 5
}

// Expected max depths
constant integer JSON_TREE_INFO_EXPECTED_MAX_DEPTH[10] = {
    1,  // Test 1: object -> property value
    1,  // Test 2: array -> element
    2,  // Test 3: object -> outer -> inner
    2,  // Test 4: array -> sub-array -> element
    4,  // Test 5: object -> a -> b -> c -> d
    0,  // Test 6: object only (empty)
    0,  // Test 7: array only (empty)
    1,  // Test 8: object -> property
    3,  // Test 9: object -> array -> object -> property
    3   // Test 10: object -> data -> items/meta -> element/property
}


define_function TestNAVJsonTreeInfo() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonTreeInfo'")

    InitializeJsonTreeInfoTestData()

    for (x = 1; x <= length_array(JSON_TREE_INFO_TEST); x++) {
        stack_var _NAVJson json
        stack_var integer nodeCount
        stack_var sinteger maxDepth

        if (!NAVJsonParse(JSON_TREE_INFO_TEST[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Test NAVJsonGetNodeCount
        nodeCount = NAVJsonGetNodeCount(json)
        if (!NAVAssertIntegerEqual('NAVJsonGetNodeCount',
                                    JSON_TREE_INFO_EXPECTED_NODE_COUNT[x],
                                    nodeCount)) {
            NAVLogTestFailed(x,
                            itoa(JSON_TREE_INFO_EXPECTED_NODE_COUNT[x]),
                            itoa(nodeCount))
            continue
        }

        // Test NAVJsonGetMaxDepth
        maxDepth = NAVJsonGetMaxDepth(json)
        if (!NAVAssertIntegerEqual('NAVJsonGetMaxDepth',
                                    JSON_TREE_INFO_EXPECTED_MAX_DEPTH[x],
                                    type_cast(maxDepth))) {
            NAVLogTestFailed(x,
                            itoa(JSON_TREE_INFO_EXPECTED_MAX_DEPTH[x]),
                            itoa(maxDepth))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonTreeInfo'")
}
