PROGRAM_NAME='NAVTomlTreeInfo'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_TREE_INFO_TEST[10][1024]


define_function InitializeTomlTreeInfoTestData() {
    // Test 1: Simple table with 2 nodes (root + 1 property)
    TOML_TREE_INFO_TEST[1] = 'a = 1'

    // Test 2: Simple array with 4 nodes (root + 1 array + 3 elements)
    TOML_TREE_INFO_TEST[2] = 'items = [1, 2, 3]'

    // Test 3: Nested table - depth 2
    TOML_TREE_INFO_TEST[3] = "'[outer]', 13, 10, 'inner = true'"

    // Test 4: Nested arrays - depth 2
    TOML_TREE_INFO_TEST[4] = 'items = [[1, 2], [3, 4]]'

    // Test 5: Deep nesting - depth 4
    TOML_TREE_INFO_TEST[5] = "'[a.b.c]', 13, 10, 'd = 1'"

    // Test 6: Empty inline table - 1 node, depth 0
    TOML_TREE_INFO_TEST[6] = 'empty = {}'

    // Test 7: Empty array - 1 node, depth 0
    TOML_TREE_INFO_TEST[7] = 'items = []'

    // Test 8: Wide structure - many siblings
    TOML_TREE_INFO_TEST[8] = "'a = 1', 13, 10, 'b = 2', 13, 10, 'c = 3', 13, 10, 'd = 4', 13, 10, 'e = 5'"

    // Test 9: Array of tables with properties
    TOML_TREE_INFO_TEST[9] = "'[[users]]', 13, 10, 'name = "A"', 13, 10, 'age = 25', 13, 10, '[[users]]', 13, 10, 'name = "B"', 13, 10, 'age = 30'"

    // Test 10: Complex structure with nested tables and arrays
    TOML_TREE_INFO_TEST[10] = "'[data.items]', 13, 10, 'values = [1, 2, 3]', 13, 10, '[data.meta]', 13, 10, 'count = 3', 13, 10, 'active = true'"

    set_length_array(TOML_TREE_INFO_TEST, 10)
}


DEFINE_CONSTANT

// Expected node counts
constant integer TOML_TREE_INFO_EXPECTED_NODE_COUNT[10] = {
    2,   // Test 1: root + 1 property
    5,   // Test 2: root + items array + 3 elements
    3,   // Test 3: root + outer table + inner property
    8,   // Test 4: root + items array + 2 sub-arrays + 4 elements
    5,   // Test 5: root + a table + b table + c table + d property
    2,   // Test 6: root + empty inline table
    2,   // Test 7: root + empty array
    6,   // Test 8: root + 5 properties
    8,   // Test 9: root + users (table_array) + 2 tables + (2 props each) = 1+1+2+2+2
    10   // Test 10: root + data table + items table + meta table + array + (3 elements + 2 properties)
}

// Expected max depths
constant integer TOML_TREE_INFO_EXPECTED_MAX_DEPTH[10] = {
    1,  // Test 1: root -> property value
    2,  // Test 2: root -> array -> element
    2,  // Test 3: root -> outer table -> property
    3,  // Test 4: root -> array -> sub-array -> element
    4,  // Test 5: root -> a -> b -> c -> d
    1,  // Test 6: root -> inline table (empty)
    1,  // Test 7: root -> array (empty)
    1,  // Test 8: root -> property
    3,  // Test 9: root -> users (table array) -> table element -> property
    4   // Test 10: root -> data -> items/meta -> property/values -> array element
}


define_function TestNAVTomlTreeInfo() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlTreeInfo'")

    InitializeTomlTreeInfoTestData()

    for (x = 1; x <= length_array(TOML_TREE_INFO_TEST); x++) {
        stack_var _NAVToml toml
        stack_var integer nodeCount
        stack_var sinteger maxDepth

        if (!NAVTomlParse(TOML_TREE_INFO_TEST[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Test NAVTomlGetNodeCount
        nodeCount = NAVTomlGetNodeCount(toml)
        if (!NAVAssertIntegerEqual('NAVTomlGetNodeCount',
                                    TOML_TREE_INFO_EXPECTED_NODE_COUNT[x],
                                    nodeCount)) {
            NAVLogTestFailed(x,
                            itoa(TOML_TREE_INFO_EXPECTED_NODE_COUNT[x]),
                            itoa(nodeCount))
            continue
        }

        // Test NAVTomlGetMaxDepth
        maxDepth = NAVTomlGetMaxDepth(toml)
        if (!NAVAssertIntegerEqual('NAVTomlGetMaxDepth',
                                    TOML_TREE_INFO_EXPECTED_MAX_DEPTH[x],
                                    type_cast(maxDepth))) {
            NAVLogTestFailed(x,
                            itoa(TOML_TREE_INFO_EXPECTED_MAX_DEPTH[x]),
                            itoa(maxDepth))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlTreeInfo'")
}
