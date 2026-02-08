PROGRAM_NAME='NAVYamlMappingSequenceHelpers'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_HELPERS_TEST[10][512]


define_function InitializeYamlMappingSequenceHelpersTestData() {
    // Test 1: Simple mapping with multiple properties
    YAML_HELPERS_TEST[1] = "'name: John', 13, 10, 'age: 30', 13, 10, 'city: NYC'"

    // Test 2: Simple sequence with multiple elements
    YAML_HELPERS_TEST[2] = '[10, 20, 30, 40, 50]'

    // Test 3: Nested mapping
    YAML_HELPERS_TEST[3] = "'person:', 13, 10, '  name: Jane', 13, 10, '  age: 25'"

    // Test 4: Nested sequence
    YAML_HELPERS_TEST[4] = "'- - 1', 13, 10, '  - 2', 13, 10, '- - 3', 13, 10, '  - 4'"

    // Test 5: Empty mapping
    YAML_HELPERS_TEST[5] = '{}'

    // Test 6: Empty sequence
    YAML_HELPERS_TEST[6] = '[]'

    // Test 7: Mapping with mixed value types
    YAML_HELPERS_TEST[7] = "'active: true', 13, 10, 'count: 123', 13, 10, 'name: test', 13, 10, 'data: null'"

    // Test 8: Sequence with mixed types
    YAML_HELPERS_TEST[8] = '[true, 123, text, null]'

    // Test 9: Get property by key - test multiple keys
    YAML_HELPERS_TEST[9] = "'first: a', 13, 10, 'second: b', 13, 10, 'third: c', 13, 10, 'fourth: d'"

    // Test 10: Get sequence element by index - test multiple indices
    YAML_HELPERS_TEST[10] = '[100, 200, 300, 400, 500]'

    set_length_array(YAML_HELPERS_TEST, 10)
}


DEFINE_CONSTANT

constant integer YAML_HELPERS_EXPECTED_CHILD_COUNT[10] = {
    3,  // Test 1 - three properties
    5,  // Test 2 - five elements
    1,  // Test 3 - root has one property (person), which contains two properties
    2,  // Test 4 - two nested sequences
    0,  // Test 5 - empty mapping
    0,  // Test 6 - empty sequence
    4,  // Test 7 - four properties
    4,  // Test 8 - four elements
    4,  // Test 9 - four properties
    5   // Test 10 - five elements
}

constant char YAML_HELPERS_TEST_KEY[10][32] = {
    'age',     // Test 1 - get age property
    '',        // Test 2 - N/A for sequence
    'name',    // Test 3 - get person.name
    '',        // Test 4 - N/A for sequence
    '',        // Test 5 - empty
    '',        // Test 6 - empty
    'count',   // Test 7 - get count property
    '',        // Test 8 - N/A for sequence
    'third',   // Test 9 - get third property
    ''         // Test 10 - N/A for sequence
}

constant sinteger YAML_HELPERS_TEST_INDEX[10] = {
    -1,  // Test 1 - N/A for mapping
    3,   // Test 2 - get element at index 3 (1-based: third element = 30)
    -1,  // Test 3 - N/A for mapping
    2,   // Test 4 - get second nested sequence (1-based)
    -1,  // Test 5 - empty
    -1,  // Test 6 - empty
    -1,  // Test 7 - N/A for mapping
    3,   // Test 8 - get element at index 3 (1-based: 'text')
    -1,  // Test 9 - N/A for mapping
    5    // Test 10 - get element at index 5 (1-based: fifth element = 500)
}


define_function TestNAVYamlMappingSequenceHelpers() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlMappingSequenceHelpers'")

    InitializeYamlMappingSequenceHelpersTestData()

    for (x = 1; x <= length_array(YAML_HELPERS_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode root
        stack_var _NAVYamlNode node
        stack_var integer childCount

        if (!NAVYamlParse(YAML_HELPERS_TEST[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlGetRootNode(yaml, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        // Test child count
        childCount = NAVYamlGetChildCount(root)
        if (!NAVAssertIntegerEqual('Child count',
                                  YAML_HELPERS_EXPECTED_CHILD_COUNT[x],
                                  childCount)) {
            NAVLogTestFailed(x,
                            itoa(YAML_HELPERS_EXPECTED_CHILD_COUNT[x]),
                            itoa(childCount))
            continue
        }

        // Test helper functions based on node type
        if (NAVYamlIsMapping(root)) {
            // Test GetPropertyByKey for mappings
            if (length_array(YAML_HELPERS_TEST_KEY[x]) > 0) {
                stack_var _NAVYamlNode property

                if (x == 3) {
                    // For nested test, query person node first
                    if (!NAVYamlQuery(yaml, '.person', node)) {
                        NAVLogTestFailed(x, 'Query person success', 'Query person failed')
                        continue
                    }
                } else {
                    node = root
                }

                if (!NAVYamlGetPropertyByKey(yaml, node, YAML_HELPERS_TEST_KEY[x], property)) {
                    NAVLogTestFailed(x, 'GetPropertyByKey success', 'GetPropertyByKey failed')
                    continue
                }
            }
        }
        else if (NAVYamlIsSequence(root)) {
            // Test GetSequenceElement for sequences
            if (YAML_HELPERS_TEST_INDEX[x] >= 0) {
                stack_var _NAVYamlNode element
                stack_var integer value

                // NAVYamlGetSequenceElement uses 0-based indices internally,
                // but our test indices are 1-based (matching YAML query syntax),
                // so subtract 1 for the function call
                if (!NAVYamlGetSequenceElement(yaml, root, type_cast(YAML_HELPERS_TEST_INDEX[x] - 1), element)) {
                    NAVLogTestFailed(x, 'GetSequenceElement success', 'GetSequenceElement failed')
                    continue
                }

                // For known values, validate them
                select {
                    active (x == 2): {
                        // Index 3 = 30 (third element)
                        if (!NAVYamlQueryInteger(yaml, '.[3]', value)) {
                            NAVLogTestFailed(x, 'Query element value', 'Query failed')
                            continue
                        }
                        if (value != 30) {
                            NAVLogTestFailed(x, '30', itoa(value))
                            continue
                        }
                    }
                    active (x == 10): {
                        // Index 5 = 500 (fifth element)
                        if (!NAVYamlQueryInteger(yaml, '.[5]', value)) {
                            NAVLogTestFailed(x, 'Query element value', 'Query failed')
                            continue
                        }
                        if (value != 500) {
                            NAVLogTestFailed(x, '500', itoa(value))
                            continue
                        }
                    }
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlMappingSequenceHelpers'")
}
