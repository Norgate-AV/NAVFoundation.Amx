PROGRAM_NAME='NAVTomlGetParentNode'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_PARENT_TEST[10][512]


define_function InitializeTomlGetParentNodeTestData() {
    // Test 1: Root has no parent
    TOML_PARENT_TEST[1] = 'value = 42'

    // Test 2: Simple key-value - property parent is root
    TOML_PARENT_TEST[2] = 'key = "value"'

    // Test 3: Array - element parent is root
    TOML_PARENT_TEST[3] = 'items = [1, 2, 3]'

    // Test 4: Nested table depth 2
    TOML_PARENT_TEST[4] = "'[outer]', 13, 10, '[outer.inner]', 13, 10, 'value = "test"', 13, 10"

    // Test 5: Array of tables depth 2
    TOML_PARENT_TEST[5] = "'[[items]]', 13, 10, 'id = 1', 13, 10"

    // Test 6: Nested table depth 3
    TOML_PARENT_TEST[6] = "'[a]', 13, 10, '[a.b]', 13, 10, '[a.b.c]', 13, 10, 'value = "deep"', 13, 10"

    // Test 7: Inline table
    TOML_PARENT_TEST[7] = 'point = { x = 10, y = 20 }'

    // Test 8: Mixed table and array - depth 3
    TOML_PARENT_TEST[8] = "'[root]', 13, 10, 'items = [{ value = ', $22, 'test', $22, ' }]', 13, 10"

    // Test 9: Complex tree - navigate from various depths
    TOML_PARENT_TEST[9] = "'[level1]', 13, 10, '[level1.level2]', 13, 10, '[level1.level2.level3]', 13, 10, 'level4 = "value"', 13, 10"

    // Test 10: Multiple siblings - test parent from different children
    TOML_PARENT_TEST[10] = "'[parent]', 13, 10, 'child1 = "a"', 13, 10, 'child2 = "b"', 13, 10, 'child3 = "c"', 13, 10"

    set_length_array(TOML_PARENT_TEST, 10)
}


DEFINE_CONSTANT

constant char TOML_PARENT_TEST_QUERY[10][128] = {
    '.',                            // Test 1 - root
    '.key',                         // Test 2 - property
    '.items[1]',                    // Test 3 - first element (1-based)
    '.outer.inner.value',           // Test 4 - nested property
    '.items[1].id',                 // Test 5 - array of tables element property (1-based)
    '.a.b.c.value',                 // Test 6 - depth 3
    '.point.x',                     // Test 7 - inline table property
    '.root.items[1].value',         // Test 8 - mixed (1-based)
    '.level1.level2.level3.level4', // Test 9 - depth 4
    '.parent.child2'                // Test 10 - middle sibling
}

constant char TOML_PARENT_EXPECTED_HAS_PARENT[10] = {
    false, // Test 1 - root has no parent
    true,  // Test 2 - property has parent
    true,  // Test 3 - element has parent
    true,  // Test 4 - nested has parent
    true,  // Test 5 - nested has parent
    true,  // Test 6 - depth 3 has parent
    true,  // Test 7 - inline table property has parent
    true,  // Test 8 - mixed has parent
    true,  // Test 9 - depth 4 has parent
    true   // Test 10 - sibling has parent
}


define_function TestNAVTomlGetParentNode() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlGetParentNode'")

    InitializeTomlGetParentNodeTestData()

    for (x = 1; x <= length_array(TOML_PARENT_TEST); x++) {
        stack_var _NAVToml toml
        stack_var _NAVTomlNode node
        stack_var _NAVTomlNode parent
        stack_var char hasParent

        if (!NAVTomlParse(TOML_PARENT_TEST[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Get the node to test
        if (!NAVTomlQuery(toml, TOML_PARENT_TEST_QUERY[x], node)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Get parent
        hasParent = NAVTomlGetParentNode(toml, node, parent)

        if (!NAVAssertBooleanEqual('Has parent',
                                   TOML_PARENT_EXPECTED_HAS_PARENT[x],
                                   hasParent)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_PARENT_EXPECTED_HAS_PARENT[x]),
                            NAVBooleanToString(hasParent))
            continue
        }

        // For nodes that should have a parent, verify parent is valid
        if (TOML_PARENT_EXPECTED_HAS_PARENT[x]) {
            stack_var _NAVTomlNode firstChild

            if (!hasParent) {
                NAVLogTestFailed(x, 'Has parent', 'No parent')
                continue
            }

            // Verify parent's child can be found (parent-child relationship is valid)
            if (!NAVTomlGetFirstChild(toml, parent, firstChild)) {
                NAVLogTestFailed(x, 'Parent has children', 'Parent has no children')
                continue
            }
        } else {
            // Root should return false for GetParent
            if (hasParent) {
                NAVLogTestFailed(x, 'Root has no parent', 'Root has parent')
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlGetParentNode'")
}
