PROGRAM_NAME='NAVYamlDeepNesting'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_DEEP_NESTING_TEST[10][8192]


define_function InitializeYamlDeepNestingTestData() {
    // Test 1: Depth 5 - mappings only
    YAML_DEEP_NESTING_TEST[1] = "
        'a:', 13, 10,
        '  b:', 13, 10,
        '    c:', 13, 10,
        '      d:', 13, 10,
        '        e: value'
    "

    // Test 2: Depth 10 - mappings only
    YAML_DEEP_NESTING_TEST[2] = "
        'a:', 13, 10,
        '  b:', 13, 10,
        '    c:', 13, 10,
        '      d:', 13, 10,
        '        e:', 13, 10,
        '          f:', 13, 10,
        '            g:', 13, 10,
        '              h:', 13, 10,
        '                i:', 13, 10,
        '                  j: value'
    "

    // Test 3: Depth 15 - mappings only
    YAML_DEEP_NESTING_TEST[3] = "
        'a:', 13, 10,
        '  b:', 13, 10,
        '    c:', 13, 10,
        '      d:', 13, 10,
        '        e:', 13, 10,
        '          f:', 13, 10,
        '            g:', 13, 10,
        '              h:', 13, 10,
        '                i:', 13, 10,
        '                  j:', 13, 10,
        '                    k:', 13, 10,
        '                      l:', 13, 10,
        '                        m:', 13, 10,
        '                          n:', 13, 10,
        '                            o: value'
    "

    // Test 4: Depth 5 - sequences only (block style)
    YAML_DEEP_NESTING_TEST[4] = "
        '-', 13, 10,
        '  -', 13, 10,
        '    -', 13, 10,
        '      -', 13, 10,
        '        - value'
    "

    // Test 5: Depth 10 - sequences only (block style)
    YAML_DEEP_NESTING_TEST[5] = "
        '-', 13, 10,
        '  -', 13, 10,
        '    -', 13, 10,
        '      -', 13, 10,
        '        -', 13, 10,
        '          -', 13, 10,
        '            -', 13, 10,
        '              -', 13, 10,
        '                -', 13, 10,
        '                  - value'
    "

    // Test 6: Depth 5 - mixed mapping and sequence (2-space indents)
    YAML_DEEP_NESTING_TEST[6] = "
        'a:', 13, 10,
        '  - b:', 13, 10,
        '    - c:', 13, 10,
        '      - d:', 13, 10,
        '        - value'
    "

    // Test 7: Depth 8 - mixed with mappings starting (2-space indents)
    YAML_DEEP_NESTING_TEST[7] = "
        'root:', 13, 10,
        '  items:', 13, 10,
        '    - id: 1', 13, 10,
        '      data:', 13, 10,
        '        - value: test', 13, 10,
        '          nested:', 13, 10,
        '            - deep:', 13, 10,
        '              final: end'
    "

    // Test 8: Depth 6 - sequence of mappings of sequences (2-space indents)
    YAML_DEEP_NESTING_TEST[8] = "
        '- data:', 13, 10,
        '  - item:', 13, 10,
        '    - value:', 13, 10,
        '      - nested:', 13, 10,
        '        - final: end'
    "

    // Test 9: Depth 12 - alternating mapping/sequence (2-space indents)
    YAML_DEEP_NESTING_TEST[9] = "
        'a:', 13, 10,
        '  - b:', 13, 10,
        '    - c:', 13, 10,
        '      - d:', 13, 10,
        '        - e:', 13, 10,
        '          - f:', 13, 10,
        '            - g:', 13, 10,
        '              - h:', 13, 10,
        '                - i:', 13, 10,
        '                  - j:', 13, 10,
        '                    - k:', 13, 10,
        '                      - value'
    "

    // Test 10: Depth 4 - complex structure with multiple children at each level (2-space indents)
    YAML_DEEP_NESTING_TEST[10] = "
        'root:', 13, 10,
        '  level1a:', 13, 10,
        '    level2a: val1', 13, 10,
        '    level2b:', 13, 10,
        '      - item1', 13, 10,
        '      - item2:', 13, 10,
        '        level4: value', 13, 10,
        '  level1b: val2'
    "

    set_length_array(YAML_DEEP_NESTING_TEST, 10)
}


DEFINE_CONSTANT

constant sinteger YAML_DEEP_NESTING_EXPECTED_DEPTH[10] = {
    5,   // Test 1
    10,  // Test 2
    15,  // Test 3
    5,   // Test 4
    10,  // Test 5
    8,   // Test 6 - mixed mapping/sequence creates more depth
    9,   // Test 7 - complex mixed structure
    10,  // Test 8 - sequence of mappings of sequences
    22,  // Test 9 - alternating creates double depth
    6    // Test 10 - actual depth to level4
}

constant char YAML_DEEP_NESTING_TEST_QUERY[10][128] = {
    '.a.b.c.d.e',                                    // Test 1
    '.a.b.c.d.e.f.g.h.i.j',                         // Test 2
    '.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o',              // Test 3
    '.[1].[1].[1].[1].[1]',                         // Test 4 (1-based)
    '.[1].[1].[1].[1].[1].[1].[1].[1].[1].[1]',   // Test 5 (1-based)
    '.a.[1].b.[1].c.[1].d.[1]',                     // Test 6 (1-based)
    '.root.items.[1].data.[1].nested.[1].deep.final', // Test 7 (1-based)
    '.[1].data.[1].item.[1].value.[1].nested.[1].final', // Test 8 (1-based)
    '',                                              // Test 9 - skip query (too many tokens)
    '.root.level1a.level2b.[2].item2.level4'        // Test 10 (1-based second element)
}


define_function TestNAVYamlDeepNesting() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlDeepNesting'")

    InitializeYamlDeepNestingTestData()

    for (x = 1; x <= length_array(YAML_DEEP_NESTING_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode node
        stack_var sinteger maxDepth
        stack_var char str[128]

        if (!NAVYamlParse(YAML_DEEP_NESTING_TEST[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Validate max depth
        maxDepth = NAVYamlGetMaxDepth(yaml)

        if (!NAVAssertSignedIntegerEqual('Deep nesting max depth',
                                  YAML_DEEP_NESTING_EXPECTED_DEPTH[x],
                                  maxDepth)) {
            NAVLogTestFailed(x,
                            itoa(YAML_DEEP_NESTING_EXPECTED_DEPTH[x]),
                            itoa(maxDepth))
            continue
        }

        // Validate deep query can reach deepest node
        if (length_array(YAML_DEEP_NESTING_TEST_QUERY[x])) {
            if (!NAVYamlQuery(yaml, YAML_DEEP_NESTING_TEST_QUERY[x], node)) {
                NAVLogTestFailed(x, 'Deep query success', 'Deep query failed')
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlDeepNesting'")
}
