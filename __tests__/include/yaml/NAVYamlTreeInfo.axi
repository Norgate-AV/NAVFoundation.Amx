PROGRAM_NAME='NAVYamlTreeInfo'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_TREE_INFO_TEST[10][1024]


define_function InitializeYamlTreeInfoTestData() {
    // Test 1: Simple mapping with 2 nodes (root + 1 property)
    YAML_TREE_INFO_TEST[1] = "'a: 1'"

    // Test 2: Simple sequence with 4 nodes (root + 3 elements)
    YAML_TREE_INFO_TEST[2] = "'- 1', 13, 10, '- 2', 13, 10, '- 3'"

    // Test 3: Nested mapping - depth 2
    YAML_TREE_INFO_TEST[3] = "'outer:', 13, 10, '  inner: true'"

    // Test 4: Nested sequence - depth 2
    YAML_TREE_INFO_TEST[4] = "'- [1, 2]', 13, 10, '- [3, 4]'"

    // Test 5: Deep nesting - depth 4
    YAML_TREE_INFO_TEST[5] = "'a:', 13, 10, '  b:', 13, 10, '    c:', 13, 10, '      d: 1'"

    // Test 6: Empty mapping - 1 node, depth 0
    YAML_TREE_INFO_TEST[6] = "'{}'"

    // Test 7: Empty sequence - 1 node, depth 0
    YAML_TREE_INFO_TEST[7] = "'[]'"

    // Test 8: Wide structure - many siblings
    YAML_TREE_INFO_TEST[8] = "'a: 1', 13, 10, 'b: 2', 13, 10, 'c: 3', 13, 10, 'd: 4', 13, 10, 'e: 5'"

    // Test 9: Mixed depth and width
    YAML_TREE_INFO_TEST[9] = "'users:', 13, 10, '  - name: A', 13, 10, '    age: 25', 13, 10, '  - name: B', 13, 10, '    age: 30'"

    // Test 10: Complex structure
    YAML_TREE_INFO_TEST[10] = "'data:', 13, 10, '  items:', 13, 10, '    - 1', 13, 10, '    - 2', 13, 10, '    - 3', 13, 10, '  meta:', 13, 10, '    count: 3', 13, 10, '    active: true'"

    set_length_array(YAML_TREE_INFO_TEST, 10)
}


DEFINE_CONSTANT

// Expected node counts
constant integer YAML_TREE_INFO_EXPECTED_NODE_COUNT[10] = {
    2,   // Test 1: root + 1 property (key:value pair counted as 1)
    4,   // Test 2: root + 3 sequence elements
    3,   // Test 3: root + outer property + inner property
    7,   // Test 4: root + 2 sub-sequences + 4 elements
    5,   // Test 5: root + a + b + c + d
    1,   // Test 6: root only (empty mapping)
    1,   // Test 7: root only (empty sequence)
    6,   // Test 8: root + 5 properties
    8,   // Test 9: root + users + 2 mappings + (2 properties each)
    9    // Test 10: root + data + items + meta + (3 elements + 2 properties)
}

// Expected max depths
constant integer YAML_TREE_INFO_EXPECTED_MAX_DEPTH[10] = {
    1,  // Test 1: mapping -> property value
    1,  // Test 2: sequence -> element
    2,  // Test 3: mapping -> outer -> inner
    2,  // Test 4: sequence -> sub-sequence -> element
    4,  // Test 5: mapping -> a -> b -> c -> d
    0,  // Test 6: mapping only (empty)
    0,  // Test 7: sequence only (empty)
    1,  // Test 8: mapping -> property
    3,  // Test 9: mapping -> users -> sequence -> mapping -> property
    3   // Test 10: mapping -> data -> items/meta -> element/property
}


define_function TestNAVYamlTreeInfo() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlTreeInfo'")

    InitializeYamlTreeInfoTestData()

    for (x = 1; x <= length_array(YAML_TREE_INFO_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var integer nodeCount
        stack_var sinteger maxDepth

        if (!NAVYamlParse(YAML_TREE_INFO_TEST[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Test NAVYamlGetNodeCount
        nodeCount = NAVYamlGetNodeCount(yaml)
        if (!NAVAssertIntegerEqual('NAVYamlGetNodeCount',
                                    YAML_TREE_INFO_EXPECTED_NODE_COUNT[x],
                                    nodeCount)) {
            NAVLogTestFailed(x,
                            itoa(YAML_TREE_INFO_EXPECTED_NODE_COUNT[x]),
                            itoa(nodeCount))
            continue
        }

        // Test NAVYamlGetMaxDepth
        maxDepth = NAVYamlGetMaxDepth(yaml)
        if (!NAVAssertIntegerEqual('NAVYamlGetMaxDepth',
                                    YAML_TREE_INFO_EXPECTED_MAX_DEPTH[x],
                                    type_cast(maxDepth))) {
            NAVLogTestFailed(x,
                            itoa(YAML_TREE_INFO_EXPECTED_MAX_DEPTH[x]),
                            itoa(maxDepth))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlTreeInfo'")
}

