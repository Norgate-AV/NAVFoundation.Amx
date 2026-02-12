PROGRAM_NAME='NAVYamlNavigationEdgeCases'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_NAVIGATION_TEST[10][512]


define_function InitializeYamlNavigationEdgeCasesTestData() {
    // Test 1: Single root scalar value (no children)
    YAML_NAVIGATION_TEST[1] = '42'

    // Test 2: Empty mapping
    YAML_NAVIGATION_TEST[2] = '{}'

    // Test 3: Empty sequence
    YAML_NAVIGATION_TEST[3] = '[]'

    // Test 4: Mapping with single property
    YAML_NAVIGATION_TEST[4] = "'single: value'"

    // Test 5: Sequence with single element
    YAML_NAVIGATION_TEST[5] = '[123]'

    // Test 6: Multiple properties in mapping
    YAML_NAVIGATION_TEST[6] = "'a: 1', 13, 10, 'b: 2', 13, 10, 'c: 3', 13, 10, 'd: 4', 13, 10, 'e: 5'"

    // Test 7: Multiple elements in sequence
    YAML_NAVIGATION_TEST[7] = '[10, 20, 30, 40, 50]'

    // Test 8: Mixed types in sequence
    YAML_NAVIGATION_TEST[8] = '[true, text, 123, null, {key: value}]'

    // Test 9: Parent navigation from deeply nested node
    YAML_NAVIGATION_TEST[9] = "'outer:', 13, 10, '  middle:', 13, 10, '    inner: value'"

    // Test 10: Complex tree with multiple children at each level
    YAML_NAVIGATION_TEST[10] = "'branch1:', 13, 10, '  leaf1: 1', 13, 10, '  leaf2: 2', 13, 10, 'branch2:', 13, 10, '  leaf3: 3', 13, 10, '  leaf4: 4'"

    set_length_array(YAML_NAVIGATION_TEST, 10)
}


DEFINE_CONSTANT

constant integer YAML_NAVIGATION_EXPECTED_CHILD_COUNT[10] = {
    0,  // Test 1 - scalar has no children
    0,  // Test 2 - empty mapping
    0,  // Test 3 - empty sequence
    1,  // Test 4 - one property
    1,  // Test 5 - one element
    5,  // Test 6 - five properties
    5,  // Test 7 - five elements
    5,  // Test 8 - five mixed elements
    1,  // Test 9 - outer has one child (middle)
    2   // Test 10 - root mapping has two branches
}

constant char YAML_NAVIGATION_TEST_HAS_CHILDREN[10] = {
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


define_function TestNAVYamlNavigationEdgeCases() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlNavigationEdgeCases'")

    InitializeYamlNavigationEdgeCasesTestData()

    for (x = 1; x <= length_array(YAML_NAVIGATION_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode root
        stack_var _NAVYamlNode firstChild
        stack_var _NAVYamlNode parent
        stack_var integer childCount
        stack_var char hasChildren

        if (!NAVYamlParse(YAML_NAVIGATION_TEST[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Get root node
        if (!NAVYamlGetRootNode(yaml, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        // Test child count
        childCount = NAVYamlGetChildCount(root)
        if (!NAVAssertIntegerEqual('Child count',
                                  YAML_NAVIGATION_EXPECTED_CHILD_COUNT[x],
                                  childCount)) {
            NAVLogTestFailed(x,
                            itoa(YAML_NAVIGATION_EXPECTED_CHILD_COUNT[x]),
                            itoa(childCount))
            continue
        }

        // Test has children
        hasChildren = (childCount > 0)
        if (!NAVAssertBooleanEqual('Has children',
                                   YAML_NAVIGATION_TEST_HAS_CHILDREN[x],
                                   hasChildren)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_NAVIGATION_TEST_HAS_CHILDREN[x]),
                            NAVBooleanToString(hasChildren))
            continue
        }

        // Test getting first child (should match expected)
        if (YAML_NAVIGATION_TEST_HAS_CHILDREN[x]) {
            if (!NAVYamlGetFirstChild(yaml, root, firstChild)) {
                NAVLogTestFailed(x, 'Get first child success', 'Get first child failed')
                continue
            }

            // Test parent navigation from child
            if (!NAVYamlGetParent(yaml, firstChild, parent)) {
                NAVLogTestFailed(x, 'Get parent success', 'Get parent failed')
                continue
            }

            // Verify parent matches root (comparing parent index field)
            if (!NAVAssertIntegerEqual('Parent is root',
                                      firstChild.parent,
                                      yaml.rootIndex)) {
                NAVLogTestFailed(x,
                                itoa(yaml.rootIndex),
                                itoa(firstChild.parent))
                continue
            }
        }

        // Test root has no parent (parent should return false)
        if (NAVYamlGetParent(yaml, root, parent)) {
            NAVLogTestFailed(x, 'Root has no parent', 'Root has parent')
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlNavigationEdgeCases'")
}
