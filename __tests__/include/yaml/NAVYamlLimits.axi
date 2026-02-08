PROGRAM_NAME='NAVYamlLimits'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_LIMITS_TEST[10][16384]


define_function InitializeYamlLimitsTestData() {
    stack_var integer i
    stack_var char temp[16384]

    // Test 1: Very long string (200 characters)
    temp = "'value: '"
    for (i = 1; i < 201; i++) {
        temp = "temp, 'a'"
    }
    // Don't append closing quote - it would become part of the unquoted value
    YAML_LIMITS_TEST[1] = temp

    // Test 2: Long key name (63 characters - near practical limit)
    temp = ''''
    for (i = 1; i < 64; i++) {
        temp = "temp, 'k'"
    }
    temp = "temp, ''': value'"  // Close the quoted key before colon
    YAML_LIMITS_TEST[2] = temp

    // Test 3: Many tokens (100 element sequence)
    temp = "'values:', 13, 10"
    for (i = 1; i <= 100; i++) {
        temp = "temp, '  - ', itoa(i), 13, 10"
    }
    YAML_LIMITS_TEST[3] = temp

    // Test 4: Deep nesting (15 levels)
    temp = "'a:', 13, 10, '  b:', 13, 10, '    c:', 13, 10, '      d:', 13, 10, '        e:', 13, 10, '          f:', 13, 10, '            g:', 13, 10, '              h:', 13, 10, '                i:', 13, 10, '                  j:', 13, 10, '                    k:', 13, 10, '                      l:', 13, 10, '                        m:', 13, 10, '                          n:', 13, 10, '                            o: value'"
    YAML_LIMITS_TEST[4] = temp

    // Test 5: Large number (max unsigned long)
    YAML_LIMITS_TEST[5] = "'value: 4294967295'"

    // Test 6: Many properties (50 properties)
    temp = ''
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, 13, 10"
        }
        temp = "temp, 'key', itoa(i), ': value', itoa(i)"
    }
    YAML_LIMITS_TEST[6] = temp

    // Test 7: Empty sequence
    YAML_LIMITS_TEST[7] = "'items: []'"

    // Test 8: Empty mapping
    YAML_LIMITS_TEST[8] = "'data: {}'"

    // Test 9: Deep query path (15 levels)
    YAML_LIMITS_TEST[9] = YAML_LIMITS_TEST[4]

    // Test 10: Mixed complex structure
    temp = "'root:', 13, 10, '  items:', 13, 10"
    for (i = 1; i <= 20; i++) {
        temp = "temp, '    - id: ', itoa(i), 13, 10, '      name: item', itoa(i), 13, 10"
    }
    temp = "temp, '  properties:', 13, 10"
    for (i = 1; i <= 20; i++) {
        if (i > 1) {
            temp = "temp, 13, 10"
        }
        temp = "temp, '    prop', itoa(i), ': ', itoa(i * 10)"
    }
    YAML_LIMITS_TEST[10] = temp

    set_length_array(YAML_LIMITS_TEST, 10)
}


DEFINE_CONSTANT

constant char YAML_LIMITS_TEST_QUERY[10][128] = {
    '.value',                                             // Test 1 - long string
    '',                                                   // Test 2 - long key (get root)
    '.values',                                            // Test 3 - many tokens
    '.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o',                   // Test 4 - deep nesting
    '.value',                                             // Test 5 - large number
    '.',                                                  // Test 6 - many properties
    '.items',                                             // Test 7 - empty sequence
    '.data',                                              // Test 8 - empty mapping
    '.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o',                   // Test 9 - deep query path
    '.root.items'                                         // Test 10 - complex structure
}

constant long YAML_LIMITS_EXPECTED_NUMBER[10] = {
    200,          // Test 1 - string length
    0,            // Test 2 - long key (validate parse)
    100,          // Test 3 - child count
    0,            // Test 4 - deep nesting (validate query)
    4294967295,   // Test 5 - large number value
    50,           // Test 6 - property count
    0,            // Test 7 - empty sequence child count
    0,            // Test 8 - empty mapping child count
    0,            // Test 9 - deep query (validate query)
    20            // Test 10 - items child count
}


define_function TestNAVYamlLimits() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlLimits'")

    InitializeYamlLimitsTestData()

    for (x = 1; x <= length_array(YAML_LIMITS_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode node
        stack_var long count
        stack_var char str[16384]
        stack_var long value

        if (!NAVYamlParse(YAML_LIMITS_TEST[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        select {
            // Test 1: Validate long string length
            active (x == 1): {
                if (!NAVYamlQueryString(yaml, YAML_LIMITS_TEST_QUERY[x], str)) {
                    NAVLogTestFailed(x, 'Query string success', 'Query string failed')
                    continue
                }

                if (!NAVAssertLongEqual('Long string length',
                                          YAML_LIMITS_EXPECTED_NUMBER[x],
                                          length_array(str))) {
                    NAVLogTestFailed(x,
                                    itoa(YAML_LIMITS_EXPECTED_NUMBER[x]),
                                    itoa(length_array(str)))
                    continue
                }
            }

            // Test 2: Validate long key (just parse success)
            active (x == 2): {
                // Parse success is sufficient validation
            }

            // Test 3, 6: Validate child count
            active (x == 3 || x == 6 || x == 7 || x == 8 || x == 10): {
                if (length_array(YAML_LIMITS_TEST_QUERY[x]) == 0 ||
                    YAML_LIMITS_TEST_QUERY[x] == '.') {
                    if (!NAVYamlGetRootNode(yaml, node)) {
                        NAVLogTestFailed(x, 'Get root success', 'Get root failed')
                        continue
                    }
                } else {
                    if (!NAVYamlQuery(yaml, YAML_LIMITS_TEST_QUERY[x], node)) {
                        NAVLogTestFailed(x, 'Query success', 'Query failed')
                        continue
                    }
                }

                count = NAVYamlGetChildCount(node)

                if (!NAVAssertLongEqual('Child count',
                                          YAML_LIMITS_EXPECTED_NUMBER[x],
                                          count)) {
                    NAVLogTestFailed(x,
                                    itoa(YAML_LIMITS_EXPECTED_NUMBER[x]),
                                    itoa(count))
                    continue
                }
            }

            // Test 4, 9: Validate deep query success
            active (x == 4 || x == 9): {
                if (!NAVYamlQuery(yaml, YAML_LIMITS_TEST_QUERY[x], node)) {
                    NAVLogTestFailed(x, 'Deep query success', 'Deep query failed')
                    continue
                }
            }

            // Test 5: Validate large number
            active (x == 5): {
                if (!NAVYamlQueryLong(yaml, YAML_LIMITS_TEST_QUERY[x], value)) {
                    NAVLogTestFailed(x, 'Query long success', 'Query long failed')
                    continue
                }

                if (!NAVAssertLongEqual('Large number value',
                                       YAML_LIMITS_EXPECTED_NUMBER[x],
                                       value)) {
                    NAVLogTestFailed(x,
                                    itoa(YAML_LIMITS_EXPECTED_NUMBER[x]),
                                    itoa(value))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlLimits'")
}
