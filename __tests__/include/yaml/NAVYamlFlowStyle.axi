PROGRAM_NAME='NAVYamlFlowStyle'

#include 'NAVFoundation.Yaml.axi'


DEFINE_CONSTANT

constant char YAML_FLOW_TEST[10][512] = {
    // Test 1: Simple flow sequence
    '[1, 2, 3, 4, 5]',

    // Test 2: Simple flow mapping
    '{name: John, age: 30, city: NYC}',

    // Test 3: Nested flow sequences
    '[[1, 2], [3, 4], [5, 6]]',

    // Test 4: Nested flow mappings
    '{person: {name: Jane, age: 25}, location: {city: LA, state: CA}}',

    // Test 5: Mixed flow - sequence of mappings
    '[{id: 1, name: a}, {id: 2, name: b}, {id: 3, name: c}]',

    // Test 6: Mixed flow - mapping with sequence values
    '{items: [1, 2, 3], names: [a, b, c], flags: [true, false]}',

    // Test 7: Empty flow sequence
    '[]',

    // Test 8: Empty flow mapping
    '{}',

    // Test 9: Flow sequence with mixed types
    '[true, 123, text, null, {key: value}]',

    // Test 10: Complex nested flow structure
    '{data: {items: [{id: 1, values: [10, 20]}, {id: 2, values: [30, 40]}]}}'
}

constant integer YAML_FLOW_EXPECTED_CHILD_COUNT[10] = {
    5,  // Test 1 - five elements
    3,  // Test 2 - three properties
    3,  // Test 3 - three nested sequences
    2,  // Test 4 - two properties (person, location)
    3,  // Test 5 - three mapping elements
    3,  // Test 6 - three properties
    0,  // Test 7 - empty
    0,  // Test 8 - empty
    5,  // Test 9 - five mixed elements
    1   // Test 10 - one property (data)
}

constant char YAML_FLOW_TEST_QUERY[10][64] = {
    '.[3]',              // Test 1 - third element (1-based)
    '.age',              // Test 2 - age property
    '.[2].[1]',          // Test 3 - second sequence, first element (1-based: 3)
    '.person.name',      // Test 4 - nested property
    '.[2].id',           // Test 5 - second mapping's id (1-based: 2)
    '.items.[2]',        // Test 6 - second item (1-based: 2)
    '.',                 // Test 7 - root (empty)
    '.',                 // Test 8 - root (empty)
    '.[5].key',          // Test 9 - fifth element nested mapping (1-based)
    '.data.items.[1].values.[2]' // Test 10 - first item, second value (1-based: 20)
}

constant integer YAML_FLOW_EXPECTED_VALUE[10] = {
    3,   // Test 1
    30,  // Test 2
    3,   // Test 3
    0,   // Test 4 - string value
    2,   // Test 5
    2,   // Test 6
    0,   // Test 7
    0,   // Test 8
    0,   // Test 9 - string value
    20   // Test 10
}


define_function TestNAVYamlFlowStyle() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlFlowStyle'")

    for (x = 1; x <= length_array(YAML_FLOW_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode root
        stack_var _NAVYamlNode node
        stack_var integer childCount
        stack_var integer value
        stack_var char str[128]

        if (!NAVYamlParse(YAML_FLOW_TEST[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlGetRootNode(yaml, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        // Test child count
        childCount = NAVYamlGetChildCount(root)
        if (!NAVAssertIntegerEqual('Root child count',
                                  YAML_FLOW_EXPECTED_CHILD_COUNT[x],
                                  childCount)) {
            NAVLogTestFailed(x,
                            itoa(YAML_FLOW_EXPECTED_CHILD_COUNT[x]),
                            itoa(childCount))
            continue
        }

        // Test query to specific values
        if (!NAVYamlQuery(yaml, YAML_FLOW_TEST_QUERY[x], node)) {
            // Empty collections won't have queryable children
            if (x == 7 || x == 8) {
                NAVLogTestPassed(x)
                continue
            }
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // For non-string values, validate the value
        if (x == 1 || x == 2 || x == 3 || x == 5 || x == 6 || x == 10) {
            if (!NAVYamlQueryInteger(yaml, YAML_FLOW_TEST_QUERY[x], value)) {
                NAVLogTestFailed(x, 'Query integer value', 'Query failed')
                continue
            }

            if (!NAVAssertIntegerEqual('Flow style value',
                                      YAML_FLOW_EXPECTED_VALUE[x],
                                      value)) {
                NAVLogTestFailed(x,
                                itoa(YAML_FLOW_EXPECTED_VALUE[x]),
                                itoa(value))
                continue
            }
        }
        // For string values, just validate query success
        else if (x == 4 || x == 9) {
            if (!NAVYamlQueryString(yaml, YAML_FLOW_TEST_QUERY[x], str)) {
                NAVLogTestFailed(x, 'Query string value', 'Query failed')
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlFlowStyle'")
}
