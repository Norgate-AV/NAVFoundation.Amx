PROGRAM_NAME='NAVYamlTypeChecking'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_TYPE_CHECK_TEST[10][256]


define_function InitializeYamlTypeCheckTestData() {
    // Test 1: Mapping
    YAML_TYPE_CHECK_TEST[1] = 'name: test'

    // Test 2: Sequence (block)
    YAML_TYPE_CHECK_TEST[2] = "'- 1', 13, 10, '- 2', 13, 10, '- 3'"

    // Test 3: String value
    YAML_TYPE_CHECK_TEST[3] = 'value: text'

    // Test 4: Number value
    YAML_TYPE_CHECK_TEST[4] = 'value: 42'

    // Test 5: Boolean true
    YAML_TYPE_CHECK_TEST[5] = 'value: true'

    // Test 6: Boolean false
    YAML_TYPE_CHECK_TEST[6] = 'value: false'

    // Test 7: Null value
    YAML_TYPE_CHECK_TEST[7] = 'value: null'

    // Test 8: Nested mapping
    YAML_TYPE_CHECK_TEST[8] = "'outer:', 13, 10, '  inner: true'"

    // Test 9: Sequence with mixed types
    YAML_TYPE_CHECK_TEST[9] = "'- 123', 13, 10, '- text', 13, 10, '- true', 13, 10, '- false', 13, 10, '- null'"

    // Test 10: Complex structure
    YAML_TYPE_CHECK_TEST[10] = "'data:', 13, 10, '  - 1', 13, 10, '  - 2', 13, 10, '  - 3', 13, 10, 'name: test', 13, 10, 'active: yes'"

    set_length_array(YAML_TYPE_CHECK_TEST, 10)
}


DEFINE_CONSTANT

// Expected results for root node type checks (tests 1-10)
constant char YAML_TYPE_CHECK_ROOT_IS_MAPPING[10] = {
    true,   // Test 1: Mapping
    false,  // Test 2: Sequence
    true,   // Test 3: Mapping
    true,   // Test 4: Mapping
    true,   // Test 5: Mapping
    true,   // Test 6: Mapping
    true,   // Test 7: Mapping
    true,   // Test 8: Mapping
    false,  // Test 9: Sequence
    true    // Test 10: Mapping
}

constant char YAML_TYPE_CHECK_ROOT_IS_SEQUENCE[10] = {
    false,  // Test 1: Mapping
    true,   // Test 2: Sequence
    false,  // Test 3: Mapping
    false,  // Test 4: Mapping
    false,  // Test 5: Mapping
    false,  // Test 6: Mapping
    false,  // Test 7: Mapping
    false,  // Test 8: Mapping
    true,   // Test 9: Sequence
    false   // Test 10: Mapping
}

// Expected results for first child type checks (where applicable)
constant char YAML_TYPE_CHECK_FIRST_CHILD_IS_STRING[10] = {
    true,   // Test 1: "name":"test"
    false,  // Test 2: 1
    true,   // Test 3: "value":"text"
    false,  // Test 4: "value":42
    false,  // Test 5: "value":true
    false,  // Test 6: "value":false
    false,  // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    false,  // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char YAML_TYPE_CHECK_FIRST_CHILD_IS_NUMBER[10] = {
    false,  // Test 1: "name":"test"
    true,   // Test 2: 1
    false,  // Test 3: "value":"text"
    true,   // Test 4: "value":42
    false,  // Test 5: "value":true
    false,  // Test 6: "value":false
    false,  // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    true,   // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char YAML_TYPE_CHECK_FIRST_CHILD_IS_BOOLEAN[10] = {
    false,  // Test 1: "name":"test"
    false,  // Test 2: 1
    false,  // Test 3: "value":"text"
    false,  // Test 4: "value":42
    true,   // Test 5: "value":true
    true,   // Test 6: "value":false
    false,  // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    false,  // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char YAML_TYPE_CHECK_FIRST_CHILD_IS_NULL[10] = {
    false,  // Test 1: "name":"test"
    false,  // Test 2: 1
    false,  // Test 3: "value":"text"
    false,  // Test 4: "value":42
    false,  // Test 5: "value":true
    false,  // Test 6: "value":false
    true,   // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    false,  // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char YAML_TYPE_CHECK_FIRST_CHILD_IS_MAPPING[10] = {
    false,  // Test 1: "name":"test"
    false,  // Test 2: 1
    false,  // Test 3: "value":"text"
    false,  // Test 4: "value":42
    false,  // Test 5: "value":true
    false,  // Test 6: "value":false
    false,  // Test 7: "value":null
    true,   // Test 8: "outer":{...}
    false,  // Test 9: 123
    false   // Test 10: "data":[...]
}

constant char YAML_TYPE_CHECK_FIRST_CHILD_IS_SEQUENCE[10] = {
    false,  // Test 1: "name":"test"
    false,  // Test 2: 1
    false,  // Test 3: "value":"text"
    false,  // Test 4: "value":42
    false,  // Test 5: "value":true
    false,  // Test 6: "value":false
    false,  // Test 7: "value":null
    false,  // Test 8: "outer":{...}
    false,  // Test 9: 123
    true    // Test 10: "data":[...]
}


define_function TestNAVYamlTypeChecking() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlTypeChecking'")

    InitializeYamlTypeCheckTestData()

    for (x = 1; x <= length_array(YAML_TYPE_CHECK_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode root
        stack_var _NAVYamlNode child

        if (!NAVYamlParse(YAML_TYPE_CHECK_TEST[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlGetRoot(yaml, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        // Test root node type checking
        if (!NAVAssertBooleanEqual('NAVYamlIsMapping for root',
                                    YAML_TYPE_CHECK_ROOT_IS_MAPPING[x],
                                    NAVYamlIsMapping(root))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_TYPE_CHECK_ROOT_IS_MAPPING[x]),
                            NAVBooleanToString(NAVYamlIsMapping(root)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVYamlIsSequence for root',
                                    YAML_TYPE_CHECK_ROOT_IS_SEQUENCE[x],
                                    NAVYamlIsSequence(root))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_TYPE_CHECK_ROOT_IS_SEQUENCE[x]),
                            NAVBooleanToString(NAVYamlIsSequence(root)))
            continue
        }

        // Get first child for further testing
        if (!NAVYamlGetFirstChild(yaml, root, child)) {
            NAVLogTestFailed(x, 'Get first child success', 'Get first child failed')
            continue
        }

        // Test first child type checking
        if (!NAVAssertBooleanEqual('NAVYamlIsString for first child',
                                    YAML_TYPE_CHECK_FIRST_CHILD_IS_STRING[x],
                                    NAVYamlIsString(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_TYPE_CHECK_FIRST_CHILD_IS_STRING[x]),
                            NAVBooleanToString(NAVYamlIsString(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVYamlIsNumber for first child',
                                    YAML_TYPE_CHECK_FIRST_CHILD_IS_NUMBER[x],
                                    NAVYamlIsNumber(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_TYPE_CHECK_FIRST_CHILD_IS_NUMBER[x]),
                            NAVBooleanToString(NAVYamlIsNumber(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVYamlIsBoolean for first child',
                                    YAML_TYPE_CHECK_FIRST_CHILD_IS_BOOLEAN[x],
                                    NAVYamlIsBoolean(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_TYPE_CHECK_FIRST_CHILD_IS_BOOLEAN[x]),
                            NAVBooleanToString(NAVYamlIsBoolean(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVYamlIsNull for first child',
                                    YAML_TYPE_CHECK_FIRST_CHILD_IS_NULL[x],
                                    NAVYamlIsNull(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_TYPE_CHECK_FIRST_CHILD_IS_NULL[x]),
                            NAVBooleanToString(NAVYamlIsNull(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVYamlIsMapping for first child',
                                    YAML_TYPE_CHECK_FIRST_CHILD_IS_MAPPING[x],
                                    NAVYamlIsMapping(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_TYPE_CHECK_FIRST_CHILD_IS_MAPPING[x]),
                            NAVBooleanToString(NAVYamlIsMapping(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVYamlIsSequence for first child',
                                    YAML_TYPE_CHECK_FIRST_CHILD_IS_SEQUENCE[x],
                                    NAVYamlIsSequence(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_TYPE_CHECK_FIRST_CHILD_IS_SEQUENCE[x]),
                            NAVBooleanToString(NAVYamlIsSequence(child)))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlTypeChecking'")
}
