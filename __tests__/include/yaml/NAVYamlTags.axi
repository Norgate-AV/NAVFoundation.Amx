PROGRAM_NAME='NAVYamlTags'

#IF_NOT_DEFINED __NAV_YAML_TAGS_TEST__
#DEFINE __NAV_YAML_TAGS_TEST__ 'NAVYamlTags.Test'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_TAGS_TEST[20][1024]


define_function InitializeYamlTagsTestData() {
    // Test 1: Tagged string scalar
    YAML_TAGS_TEST[1] = 'value: !!str 123'

    // Test 2: Tagged integer scalar
    YAML_TAGS_TEST[2] = 'number: !!int 42'

    // Test 3: Tagged float scalar
    YAML_TAGS_TEST[3] = 'pi: !!float 3.14'

    // Test 4: Tagged boolean scalar
    YAML_TAGS_TEST[4] = 'flag: !!bool true'

    // Test 5: Tagged null scalar
    YAML_TAGS_TEST[5] = 'empty: !!null ~'

    // Test 6: Tagged sequence
    YAML_TAGS_TEST[6] = 'items: !!seq [1, 2, 3]'

    // Test 7: Tagged mapping
    YAML_TAGS_TEST[7] = 'config: !!map {key: value}'

    // Test 8: Local tag
    YAML_TAGS_TEST[8] = 'custom: !mytag value'

    // Test 9: Multiple tagged values in mapping
    YAML_TAGS_TEST[9] = "
        'str_val: !!str 456', 13, 10,
        'int_val: !!int 789', 13, 10
    "

    // Test 10: Tagged value in block sequence
    YAML_TAGS_TEST[10] = "
        '- !!str first', 13, 10,
        '- !!int 42', 13, 10
    "

    // Test 11: Verbatim tag
    YAML_TAGS_TEST[11] = 'data: !<tag:example.com,2002:type> value'

    // Test 12: Tag with nested structure
    YAML_TAGS_TEST[12] = "
        'user: !!map', 13, 10,
        '  name: John', 13, 10,
        '  age: 30', 13, 10
    "

    // Test 13: Tag application retrieval
    YAML_TAGS_TEST[13] = 'tagged: !!str hello'

    // Test 14: Mixed tagged and untagged
    YAML_TAGS_TEST[14] = "
        'tagged: !!str 123', 13, 10,
        'untagged: 456', 13, 10
    "

    // Test 15: Tag with quoted string
    YAML_TAGS_TEST[15] = 'message: !!str "hello world"'

    // Test 16: Tag with anchor
    YAML_TAGS_TEST[16] = 'base: &id1 !!str value'

    // Test 17: Multiple tag types
    YAML_TAGS_TEST[17] = "
        's: !!str text', 13, 10,
        'i: !!int 10', 13, 10,
        'f: !!float 1.5', 13, 10,
        'b: !!bool yes', 13, 10,
        'n: !!null', 13, 10
    "

    // Test 18: Tag in flow sequence
    YAML_TAGS_TEST[18] = '[!!str a, !!int 1, !!bool true]'

    // Test 19: Tag with block scalar
    YAML_TAGS_TEST[19] = "
        'text: !!str |', 13, 10,
        '  Line 1', 13, 10,
        '  Line 2', 13, 10
    "

    // Test 20: Tag preservation through parsing
    YAML_TAGS_TEST[20] = 'value: !!int 999'

    set_length_array(YAML_TAGS_TEST, 20)
}


DEFINE_CONSTANT

constant char YAML_TAGS_EXPECTED_RESULT[] = {
    true,   // Test 1: Tagged string
    true,   // Test 2: Tagged integer
    true,   // Test 3: Tagged float
    true,   // Test 4: Tagged boolean
    true,   // Test 5: Tagged null
    true,   // Test 6: Tagged sequence
    true,   // Test 7: Tagged mapping
    true,   // Test 8: Local tag
    true,   // Test 9: Multiple tagged values
    true,   // Test 10: Tagged in sequence
    true,   // Test 11: Verbatim tag
    true,   // Test 12: Tag with nested structure
    true,   // Test 13: Tag retrieval
    true,   // Test 14: Mixed tagged/untagged
    true,   // Test 15: Tag with quoted string
    true,   // Test 16: Tag with anchor
    true,   // Test 17: Multiple tag types
    true,   // Test 18: Tag in flow sequence
    true,   // Test 19: Tag with block scalar
    true    // Test 20: Tag preservation
}


/**
 * Test Suite: YAML Tag Support
 *
 * Tests tokenization, parsing, and API for YAML type tags.
 *
 * Covers:
 * - Named tags (!!str, !!int, !!float, !!bool, !!null)
 * - Collection tags (!!seq, !!map)
 * - Local tags (!custom)
 * - Verbatim tags (!<tag:example.com,2002:type>)
 * - Tag application and retrieval
 */
define_function TestNAVYamlTags() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlTags'")

    InitializeYamlTagsTestData()

    for (x = 1; x <= length_array(YAML_TAGS_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var char result
        stack_var _NAVYamlNode node

        result = NAVYamlParse(YAML_TAGS_TEST[x], yaml)

        if (!NAVAssertBooleanEqual('Should match expected result',
                                   YAML_TAGS_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_TAGS_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        if (!YAML_TAGS_EXPECTED_RESULT[x]) {
            // Expected failure case
            NAVLogTestPassed(x)
            continue
        }

        // Verify parsing succeeded and tag was stored
        switch (x) {
            case 1: {
                // Tagged string: value: !!str 123
                if (NAVYamlQuery(yaml, '.value', node)) {
                    if (NAVAssertStringEqual('Tag should be !!str',
                                            '!!str',
                                            node.tag)) {
                        if (NAVAssertStringEqual('Value should be 123',
                                                '123',
                                                node.value)) {
                            NAVLogTestPassed(x)
                        } else {
                            NAVLogTestFailed(x, '123', node.value)
                        }
                    } else {
                        NAVLogTestFailed(x, '!!str', node.tag)
                    }
                } else {
                    NAVLogTestFailed(x, 'Query should succeed', 'Query failed')
                }
            }
            case 2: {
                // Tagged integer: number: !!int 42
                if (NAVYamlQuery(yaml, '.number', node)) {
                    if (NAVAssertStringEqual('Tag should be !!int',
                                            '!!int',
                                            node.tag)) {
                        if (NAVAssertStringEqual('Value should be 42',
                                                '42',
                                                node.value)) {
                            NAVLogTestPassed(x)
                        } else {
                            NAVLogTestFailed(x, '42', node.value)
                        }
                    } else {
                        NAVLogTestFailed(x, '!!int', node.tag)
                    }
                } else {
                    NAVLogTestFailed(x, 'Query should succeed', 'Query failed')
                }
            }
            case 3: {
                // Tagged float: pi: !!float 3.14
                if (NAVYamlQuery(yaml, '.pi', node)) {
                    if (NAVAssertStringEqual('Tag should be !!float',
                                            '!!float',
                                            node.tag)) {
                        NAVLogTestPassed(x)
                    } else {
                        NAVLogTestFailed(x, '!!float', node.tag)
                    }
                } else {
                    NAVLogTestFailed(x, 'Query should succeed', 'Query failed')
                }
            }
            case 13: {
                // Tag retrieval: tagged: !!str hello
                if (NAVYamlQuery(yaml, '.tagged', node)) {
                    if (NAVAssertStringEqual('Tag should be !!str',
                                            '!!str',
                                            node.tag)) {
                        if (NAVAssertStringEqual('Value should be hello',
                                                'hello',
                                                node.value)) {
                            NAVLogTestPassed(x)
                        } else {
                            NAVLogTestFailed(x, 'hello', node.value)
                        }
                    } else {
                        NAVLogTestFailed(x, '!!str', node.tag)
                    }
                } else {
                    NAVLogTestFailed(x, 'Query should succeed', 'Query failed')
                }
            }
            case 20: {
                // Tag preservation: value: !!int 999
                if (NAVYamlQuery(yaml, '.value', node)) {
                    if (NAVAssertStringEqual('Tag should be !!int',
                                            '!!int',
                                            node.tag)) {
                        if (NAVAssertIntegerEqual('Value should parse as 999',
                                                 999,
                                                 atoi(node.value))) {
                            NAVLogTestPassed(x)
                        } else {
                            NAVLogTestFailed(x, '999', node.value)
                        }
                    } else {
                        NAVLogTestFailed(x, '!!int', node.tag)
                    }
                } else {
                    NAVLogTestFailed(x, 'Query should succeed', 'Query failed')
                }
            }
            default: {
                // For other tests, just verify it parsed successfully
                if (NAVAssertIntegerGreaterThan('Should have nodes',
                                               0,
                                               yaml.nodeCount)) {
                    NAVLogTestPassed(x)
                } else {
                    NAVLogTestFailed(x, '> 0 nodes', itoa(yaml.nodeCount))
                }
            }
        }
    }

    NAVLogTestSuiteEnd("'NAVYamlTags'")
}


#END_IF // __NAV_YAML_TAGS_TEST__
