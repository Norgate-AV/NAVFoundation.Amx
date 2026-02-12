PROGRAM_NAME='NAVTomlNavigationEdgeCases'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_NAVIGATION_TEST_TOML[10][512]


define_function InitializeTomlNavigationEdgeCasesTestData() {
    // Test 1: Single root value (bare key-value)
    TOML_NAVIGATION_TEST_TOML[1] = 'value = 42'

    // Test 2: Empty table
    TOML_NAVIGATION_TEST_TOML[2] = '[empty]'

    // Test 3: Empty array
    TOML_NAVIGATION_TEST_TOML[3] = 'items = []'

    // Test 4: Table with single property
    TOML_NAVIGATION_TEST_TOML[4] = "'[single]', $0A, 'value = "test"'"

    // Test 5: Array with single element
    TOML_NAVIGATION_TEST_TOML[5] = 'data = [123]'

    // Test 6: Siblings navigation - multiple properties
    TOML_NAVIGATION_TEST_TOML[6] = "'a = 1', $0A, 'b = 2', $0A, 'c = 3', $0A, 'd = 4', $0A, 'e = 5'"

    // Test 7: Siblings navigation - array elements
    TOML_NAVIGATION_TEST_TOML[7] = 'numbers = [10, 20, 30, 40, 50]'

    // Test 8: Array siblings navigation
    TOML_NAVIGATION_TEST_TOML[8] = 'items = [10, 20, 30, 40]'

    // Test 9: Parent navigation from deeply nested node
    TOML_NAVIGATION_TEST_TOML[9] = "'[outer.middle.inner]', $0A, 'value = "deep"'"

    // Test 10: Complex tree with multiple children at each level
    TOML_NAVIGATION_TEST_TOML[10] = "'[branch1]', $0A, 'leaf1 = 1', $0A, 'leaf2 = 2', $0A, '[branch2]', $0A, 'leaf3 = 3', $0A, 'leaf4 = 4'"

    set_length_array(TOML_NAVIGATION_TEST_TOML, 10)
}


DEFINE_CONSTANT

constant integer TOML_NAVIGATION_EXPECTED_CHILD_COUNT[10] = {
    1,  // Test 1 - root has one key-value
    1,  // Test 2 - empty table (table header counts as child)
    1,  // Test 3 - empty array (array variable counts as child)
    1,  // Test 4 - one property
    1,  // Test 5 - one element
    5,  // Test 6 - five properties at root
    1,  // Test 7 - root has 'numbers' variable (array is child of numbers)
    1,  // Test 8 - root has 'mixed' variable (array is child of mixed)
    1,  // Test 9 - root has one child (outer table)
    2   // Test 10 - root has two tables (branch1, branch2)
}

constant char TOML_NAVIGATION_TEST_HAS_CHILDREN[10] = {
    true,  // Test 1
    true,  // Test 2 - has table child
    true,  // Test 3 - has array child
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true,  // Test 8
    true,  // Test 9
    true   // Test 10
}

constant char TOML_NAVIGATION_TEST_CAN_GET_SIBLING[10] = {
    false, // Test 1 - single child
    false, // Test 2 - empty
    false, // Test 3 - empty array (no siblings of array itself)
    false, // Test 4 - single child
    false, // Test 5 - testing array itself, not elements
    true,  // Test 6 - multiple properties
    false, // Test 7 - single array variable (elements are children of array)
    false, // Test 8 - single array variable (elements are children of array)
    false, // Test 9 - testing single child
    true   // Test 10 - multiple tables
}


define_function TestNAVTomlNavigationEdgeCases() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlNavigationEdgeCases'")

    InitializeTomlNavigationEdgeCasesTestData()

    for (x = 1; x <= length_array(TOML_NAVIGATION_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var _NAVTomlNode root
        stack_var _NAVTomlNode firstChild
        stack_var _NAVTomlNode nextSibling
        stack_var integer childCount

        if (!NAVTomlParse(TOML_NAVIGATION_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Get root node
        root = toml.nodes[toml.rootIndex]

        // Test 1: Child count
        childCount = root.childCount
        if (!NAVAssertIntegerEqual('Child count',
                                   TOML_NAVIGATION_EXPECTED_CHILD_COUNT[x],
                                   childCount)) {
            NAVLogTestFailed(x,
                            itoa(TOML_NAVIGATION_EXPECTED_CHILD_COUNT[x]),
                            itoa(childCount))
            continue
        }

        // Test 2: Has children expectation
        if (TOML_NAVIGATION_TEST_HAS_CHILDREN[x]) {
            if (root.firstChild == 0) {
                NAVLogTestFailed(x, 'Has children', 'No children found')
                continue
            }
        } else {
            if (root.firstChild != 0) {
                NAVLogTestFailed(x, 'No children', 'Children found')
                continue
            }
        }

        // Test 3: Sibling navigation (if applicable)
        if (TOML_NAVIGATION_TEST_CAN_GET_SIBLING[x] && root.firstChild != 0) {
            firstChild = toml.nodes[root.firstChild]
            if (firstChild.nextSibling == 0) {
                NAVLogTestFailed(x, 'Has sibling', 'No sibling found')
                continue
            }

            // Verify sibling has same parent
            nextSibling = toml.nodes[firstChild.nextSibling]
            if (nextSibling.parent != firstChild.parent) {
                NAVLogTestFailed(x, 'Same parent', 'Different parent')
                continue
            }
        }

        // Test 4: Parent navigation (for nested structures)
        if (x == 9) { // Deep nesting test
            stack_var _NAVTomlNode innerNode
            stack_var _NAVTomlNode middleNode
            if (!NAVTomlQuery(toml, '.outer.middle.inner', innerNode)) {
                NAVLogTestFailed(x, 'Query inner node', 'Query failed')
                continue
            }

            // Inner should have parent (middle)
            if (innerNode.parent == 0) {
                NAVLogTestFailed(x, 'Inner has parent', 'No parent')
                continue
            }

            // Get middle node from inner's parent
            middleNode = toml.nodes[innerNode.parent]

            if (middleNode.parent == 0) {
                NAVLogTestFailed(x, 'Middle has parent', 'No parent')
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlNavigationEdgeCases'")
}
