PROGRAM_NAME='NAVYamlGetParentNode'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_PARENT_TEST[10][512]


define_function InitializeYamlGetParentNodeTestData() {
    // Test 1: Root has no parent
    YAML_PARENT_TEST[1] = '42'

    // Test 2: Simple mapping - property parent is root
    YAML_PARENT_TEST[2] = 'key: value'

    // Test 3: Simple sequence - element parent is root
    YAML_PARENT_TEST[3] = '[1, 2, 3]'

    // Test 4: Nested mapping depth 2
    YAML_PARENT_TEST[4] = "
        'outer:', 13, 10,
        '  inner: value'
    "

    // Test 5: Nested sequence depth 2
    YAML_PARENT_TEST[5] = "
        '-', 13, 10,
        '  - item'
    "

    // Test 6: Nested mapping depth 3
    YAML_PARENT_TEST[6] = "
        'a:', 13, 10,
        '  b:', 13, 10,
        '    c: value'
    "

    // Test 7: Nested sequence depth 3
    YAML_PARENT_TEST[7] = "
        '-', 13, 10,
        '  -', 13, 10,
        '    - deepvalue'
    "

    // Test 8: Mixed mapping and sequence - depth 3
    YAML_PARENT_TEST[8] = "
        'root:', 13, 10,
        '  - item:', 13, 10,
        '    value: test'
    "

    // Test 9: Complex tree - navigate from various depths
    YAML_PARENT_TEST[9] = "
        'level1:', 13, 10,
        '  level2:', 13, 10,
        '    level3:', 13, 10,
        '      level4: value'
    "

    // Test 10: Multiple siblings - test parent from different children
    YAML_PARENT_TEST[10] = "
        'parent:', 13, 10,
        '  child1: a', 13, 10,
        '  child2: b', 13, 10,
        '  child3: c'
    "

    set_length_array(YAML_PARENT_TEST, 10)
}


DEFINE_CONSTANT

constant char YAML_PARENT_TEST_QUERY[10][128] = {
    '.',                           // Test 1 - root
    '.key',                        // Test 2 - property
    '.[1]',                        // Test 3 - first element (1-based)
    '.outer.inner',                // Test 4 - nested property
    '.[1].[1]',                    // Test 5 - nested element (1-based)
    '.a.b.c',                      // Test 6 - depth 3
    '.[1].[1].[1]',                // Test 7 - depth 3 (1-based)
    '.root.[1].item.value',        // Test 8 - mixed (1-based)
    '.level1.level2.level3.level4', // Test 9 - depth 4
    '.parent.child2'               // Test 10 - middle sibling
}

constant char YAML_PARENT_EXPECTED_HAS_PARENT[10] = {
    false, // Test 1 - root has no parent
    true,  // Test 2 - property has parent
    true,  // Test 3 - element has parent
    true,  // Test 4 - nested has parent
    true,  // Test 5 - nested has parent
    true,  // Test 6 - depth 3 has parent
    true,  // Test 7 - depth 3 has parent
    true,  // Test 8 - mixed has parent
    true,  // Test 9 - depth 4 has parent
    true   // Test 10 - sibling has parent
}


define_function TestNAVYamlGetParentNode() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlGetParentNode'")

    InitializeYamlGetParentNodeTestData()

    for (x = 1; x <= length_array(YAML_PARENT_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode node
        stack_var _NAVYamlNode parent
        stack_var char hasParent

        if (!NAVYamlParse(YAML_PARENT_TEST[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Get the node to test
        if (!NAVYamlQuery(yaml, YAML_PARENT_TEST_QUERY[x], node)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Get parent
        hasParent = NAVYamlGetParent(yaml, node, parent)

        if (!NAVAssertBooleanEqual('Has parent',
                                   YAML_PARENT_EXPECTED_HAS_PARENT[x],
                                   hasParent)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_PARENT_EXPECTED_HAS_PARENT[x]),
                            NAVBooleanToString(hasParent))
            continue
        }

        // For nodes that should have a parent, verify parent is valid
        if (YAML_PARENT_EXPECTED_HAS_PARENT[x]) {
            stack_var _NAVYamlNode firstChild

            if (!hasParent) {
                NAVLogTestFailed(x, 'Has parent', 'No parent')
                continue
            }

            // Verify parent's child can be found (parent-child relationship is valid)
            if (!NAVYamlGetFirstChild(yaml, parent, firstChild)) {
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

    NAVLogTestSuiteEnd("'NAVYamlGetParentNode'")
}
