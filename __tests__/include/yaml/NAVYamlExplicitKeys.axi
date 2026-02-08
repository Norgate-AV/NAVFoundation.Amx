PROGRAM_NAME='NAVYamlExplicitKeys'

#IF_NOT_DEFINED __NAV_YAML_EXPLICIT_KEYS_TEST__
#DEFINE __NAV_YAML_EXPLICIT_KEYS_TEST__ 'NAVYamlExplicitKeys.Test'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_EXPLICIT_KEYS_TEST[15][1024]


define_function InitializeYamlExplicitKeysTestData() {
    // Test 1: Simple explicit key
    YAML_EXPLICIT_KEYS_TEST[1] = "
        '? key', 13, 10,
        ': value', 13, 10
    "

    // Test 2: Explicit key with space
    YAML_EXPLICIT_KEYS_TEST[2] = '? simple: value'

    // Test 3: Plain scalar containing ? without space
    YAML_EXPLICIT_KEYS_TEST[3] = 'question?: answer'

    // Test 4: Multiple explicit keys
    YAML_EXPLICIT_KEYS_TEST[4] = "
        '? key1', 13, 10,
        ': value1', 13, 10,
        '? key2', 13, 10,
        ': value2', 13, 10
    "

    // Test 5: Explicit key with quoted string
    YAML_EXPLICIT_KEYS_TEST[5] = "
        '? ', 34, 'complex key', 34, 13, 10,
        ': value', 13, 10
    "

    // Test 6: Complex key with flow sequence
    YAML_EXPLICIT_KEYS_TEST[6] = "
        '? [a, b]', 13, 10,
        ': value', 13, 10
    "

    // Test 7: Complex key with flow mapping
    YAML_EXPLICIT_KEYS_TEST[7] = "
        '? {x: 1}', 13, 10,
        ': value', 13, 10
    "

    // Test 8: Explicit key in block mapping
    YAML_EXPLICIT_KEYS_TEST[8] = "
        'data:', 13, 10,
        '  ? key', 13, 10,
        '  : value', 13, 10
    "

    // Test 9: Question mark not followed by space (plain scalar)
    YAML_EXPLICIT_KEYS_TEST[9] = 'key: value?'

    // Test 10: Explicit key followed by mapping value
    YAML_EXPLICIT_KEYS_TEST[10] = "
        '? explicit', 13, 10,
        ':  ', 13, 10,
        '  nested: value', 13, 10
    "

    // Test 11: Simple explicit key (compact form)
    YAML_EXPLICIT_KEYS_TEST[11] = '? k: v'

    // Test 12: Explicit key with plain scalar
    YAML_EXPLICIT_KEYS_TEST[12] = "
        '? mykey', 13, 10,
        ': myvalue', 13, 10
    "

    // Test 13: ? at start of line
    YAML_EXPLICIT_KEYS_TEST[13] = "
        '?', 13, 10,
        ': empty_key', 13, 10
    "

    // Test 14: Explicit key with colon in value
    YAML_EXPLICIT_KEYS_TEST[14] = "
        '? key', 13, 10,
        ': http://example.com', 13, 10
    "

    // Test 15: Mixed explicit and implicit keys
    YAML_EXPLICIT_KEYS_TEST[15] = "
        'implicit: value1', 13, 10,
        '? explicit', 13, 10,
        ': value2', 13, 10
    "

    set_length_array(YAML_EXPLICIT_KEYS_TEST, 15)
}


DEFINE_CONSTANT

constant char YAML_EXPLICIT_KEYS_EXPECTED_RESULT[] = {
    true,   // Test 1: Simple explicit key
    true,   // Test 2: Explicit key with space
    true,   // Test 3: Plain scalar with ?
    true,   // Test 4: Multiple explicit keys
    true,   // Test 5: Quoted string key
    true,   // Test 6: Complex key with sequence
    true,   // Test 7: Complex key with mapping
    true,   // Test 8: Explicit key in block
    true,   // Test 9: ? in plain scalar
    true,   // Test 10: Explicit key with nested value
    true,   // Test 11: Compact explicit key
    true,   // Test 12: Explicit key plain
    true,   // Test 13: Empty explicit key
    true,   // Test 14: Explicit key with colon in value
    true    // Test 15: Mixed keys
}


/**
 * Test Suite: YAML Explicit Keys
 *
 * Tests tokenization and parsing of explicit key markers (?) in YAML.
 *
 * Covers:
 * - Simple explicit keys (? key: value)
 * - Complex keys with flow sequences (? [a, b]: value)
 * - Complex keys with flow mappings (? {k: v}: value)
 * - Distinguished from plain scalars containing '?'
 */
define_function TestNAVYamlExplicitKeys() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlExplicitKeys'")

    InitializeYamlExplicitKeysTestData()

    for (x = 1; x <= length_array(YAML_EXPLICIT_KEYS_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var char result
        stack_var _NAVYamlNode node

        result = NAVYamlParse(YAML_EXPLICIT_KEYS_TEST[x], yaml)

        if (!NAVAssertBooleanEqual('Should match expected result',
                                   YAML_EXPLICIT_KEYS_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_EXPLICIT_KEYS_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        if (!YAML_EXPLICIT_KEYS_EXPECTED_RESULT[x]) {
            // Expected failure case
            NAVLogTestPassed(x)
            continue
        }

        // Verify parsing succeeded
        switch (x) {
            case 1: {
                // Simple explicit key: ? key\n: value
                if (NAVYamlQuery(yaml, '.key', node)) {
                    if (NAVAssertStringEqual('Value should be value',
                                            'value',
                                            node.value)) {
                        NAVLogTestPassed(x)
                    } else {
                        NAVLogTestFailed(x, 'value', node.value)
                    }
                } else {
                    NAVLogTestFailed(x, 'Query should succeed', 'Query failed')
                }
            }
            case 2: {
                // Explicit key with space: ? simple: value
                if (NAVYamlQuery(yaml, '.simple', node)) {
                    if (NAVAssertStringEqual('Value should be value',
                                            'value',
                                            node.value)) {
                        NAVLogTestPassed(x)
                    } else {
                        NAVLogTestFailed(x, 'value', node.value)
                    }
                } else {
                    NAVLogTestFailed(x, 'Query should succeed', 'Query failed')
                }
            }
            case 3: {
                // Plain scalar with ?: question?: answer
                // Verifies ? without space is part of key name, not explicit key marker
                // Note: Query system doesn't support special chars yet, so we verify structure directly
                if (NAVAssertIntegerEqual('Root should have 1 child',
                                         1,
                                         yaml.nodes[yaml.rootIndex].childCount)) {
                    // Get the first child node (the value for key "question?")
                    node = yaml.nodes[yaml.nodes[yaml.rootIndex].firstChild]
                    if (NAVAssertStringEqual('Value should be answer',
                                            'answer',
                                            node.value)) {
                        NAVLogTestPassed(x)
                    } else {
                        NAVLogTestFailed(x, 'answer', node.value)
                    }
                } else {
                    NAVLogTestFailed(x, '1 child', itoa(yaml.nodes[yaml.rootIndex].childCount))
                }
            }
            case 12: {
                // Explicit key plain: ? mykey\n: myvalue
                if (NAVYamlQuery(yaml, '.mykey', node)) {
                    if (NAVAssertStringEqual('Value should be myvalue',
                                            'myvalue',
                                            node.value)) {
                        NAVLogTestPassed(x)
                    } else {
                        NAVLogTestFailed(x, 'myvalue', node.value)
                    }
                } else {
                    NAVLogTestFailed(x, 'Query should succeed', 'Query failed')
                }
            }
            case 15: {
                // Mixed keys
                if (NAVYamlQuery(yaml, '.implicit', node)) {
                    if (NAVAssertStringEqual('implicit should have value1',
                                            'value1',
                                            node.value)) {
                        if (NAVYamlQuery(yaml, '.explicit', node)) {
                            if (NAVAssertStringEqual('explicit should have value2',
                                                    'value2',
                                                    node.value)) {
                                NAVLogTestPassed(x)
                            } else {
                                NAVLogTestFailed(x, 'value2', node.value)
                            }
                        } else {
                            NAVLogTestFailed(x, 'Query explicit should succeed', 'Query failed')
                        }
                    } else {
                        NAVLogTestFailed(x, 'value1', node.value)
                    }
                } else {
                    NAVLogTestFailed(x, 'Query implicit should succeed', 'Query failed')
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

    NAVLogTestSuiteEnd("'NAVYamlExplicitKeys'")
}


#END_IF // __NAV_YAML_EXPLICIT_KEYS_TEST__
