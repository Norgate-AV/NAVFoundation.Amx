PROGRAM_NAME='NAVYamlAnchorsAliases'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_ANCHOR_TEST[10][1024]


DEFINE_CONSTANT

constant char YAML_ANCHOR_EXPECTED_PARSE_SUCCESS[10] = {
    true,  // Test 1
    true,  // Test 2
    true,  // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    false, // Test 7 - forward reference should fail
    true,  // Test 8
    true,  // Test 9
    true   // Test 10
}

constant char YAML_ANCHOR_EXPECTED_QUERY_SUCCESS[10] = {
    true,  // Test 1
    true,  // Test 2
    true,  // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true,  // Test 8
    true,  // Test 9
    true   // Test 10
}

constant char YAML_ANCHOR_EXPECTED_NAME[10][32] = {
    'anchor',    // Test 1
    'person',    // Test 2
    'list',      // Test 3
    'a',         // Test 4 - testing first anchor
    'defaults',  // Test 5
    'item',      // Test 6
    'anchor',    // Test 7
    'base',      // Test 8
    'defaults',  // Test 9
    'data'       // Test 10
}

constant char YAML_ANCHOR_NODE_QUERY[10][64] = {
    '.original',      // Test 1
    '.name',          // Test 2
    '.items',         // Test 3
    '.first',         // Test 4
    '.config',        // Test 5
    '.[1]',           // Test 6
    '.original',      // Test 7
    '.base',          // Test 8
    '.defaults',      // Test 9
    '.source'         // Test 10
}

constant char YAML_ANCHOR_EXPECTED_HAS_ANCHOR[10] = {
    true,  // Test 1
    true,  // Test 2
    true,  // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true,  // Test 8
    true,  // Test 9
    true   // Test 10
}


define_function InitializeYamlAnchorTestData() {
    // Test 1: Simple anchor and alias
    YAML_ANCHOR_TEST[1] = "'original: &anchor', 13, 10, '  value: test', 13, 10, 'copy: *anchor'"

    // Test 2: Anchor on scalar value
    YAML_ANCHOR_TEST[2] = "'name: &person John', 13, 10, 'reference: *person'"

    // Test 3: Anchor on sequence
    YAML_ANCHOR_TEST[3] = "'items: &list', 13, 10, '  - a', 13, 10, '  - b', 13, 10, '  - c', 13, 10, 'copy: *list'"

    // Test 4: Multiple anchors in document
    YAML_ANCHOR_TEST[4] = "'first: &a 1', 13, 10, 'second: &b 2', 13, 10, 'ref1: *a', 13, 10, 'ref2: *b'"

    // Test 5: Anchor on nested mapping
    YAML_ANCHOR_TEST[5] = "'config: &defaults', 13, 10, '  timeout: 30', 13, 10, '  retries: 3', 13, 10, 'production: *defaults'"

    // Test 6: Anchor in sequence element
    YAML_ANCHOR_TEST[6] = "'- &item', 13, 10, '    id: 1', 13, 10, '    name: test', 13, 10, '- *item'"

    // Test 7: Alias before anchor definition (forward reference)
    YAML_ANCHOR_TEST[7] = "'reference: *anchor', 13, 10, 'original: &anchor value'"

    // Test 8: Nested aliases
    YAML_ANCHOR_TEST[8] = "'base: &base', 13, 10, '  value: 100', 13, 10, 'copy1: &copy *base', 13, 10, 'copy2: *copy'"

    // Test 9: Anchor with merge key
    YAML_ANCHOR_TEST[9] = "'defaults: &defaults', 13, 10, '  a: 1', 13, 10, '  b: 2', 13, 10, 'override:', 13, 10, '  <<: *defaults', 13, 10, '  b: 3'"

    // Test 10: Multiple aliases to same anchor
    YAML_ANCHOR_TEST[10] = "'source: &data', 13, 10, '  key: value', 13, 10, 'ref1: *data', 13, 10, 'ref2: *data', 13, 10, 'ref3: *data'"

    set_length_array(YAML_ANCHOR_TEST, 10)
}


define_function TestNAVYamlAnchorsAliases() {
    stack_var integer x

    InitializeYamlAnchorTestData()

    NAVLogTestSuiteStart("'NAVYamlAnchorsAliases'")

    for (x = 1; x <= length_array(YAML_ANCHOR_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode node
        stack_var char anchorName[128]
        stack_var char result

        result = NAVYamlParse(YAML_ANCHOR_TEST[x], yaml)

        if (!NAVAssertBooleanEqual('Parse success', YAML_ANCHOR_EXPECTED_PARSE_SUCCESS[x], result)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // If parse was expected to fail and did fail, test passes
        if (!YAML_ANCHOR_EXPECTED_PARSE_SUCCESS[x]) {
            NAVLogTestPassed(x)
            continue
        }

        result = NAVYamlQuery(yaml, YAML_ANCHOR_NODE_QUERY[x], node)

        // Test query to anchored node
        if (!NAVAssertBooleanEqual('Query success', YAML_ANCHOR_EXPECTED_QUERY_SUCCESS[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Test that anchor can be retrieved
        if (YAML_ANCHOR_EXPECTED_HAS_ANCHOR[x]) {
            anchorName = NAVYamlGetAnchor(node)

            if (!NAVAssertIntegerGreaterThan('Has anchor', 0, length_array(anchorName))) {
                NAVLogTestFailed(x, 'Has anchor', 'No anchor found')
                continue
            }

            // Verify anchor name matches expected
            if (!NAVAssertStringEqual('Anchor name',
                                     YAML_ANCHOR_EXPECTED_NAME[x],
                                     anchorName)) {
                NAVLogTestFailed(x,
                                YAML_ANCHOR_EXPECTED_NAME[x],
                                anchorName)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlAnchorsAliases'")
}
