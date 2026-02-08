PROGRAM_NAME='NAVYamlLargeSequences'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_LARGE_SEQ_TEST[10][8192]


define_function InitializeYamlLargeSequencesTestData() {
    stack_var integer i
    stack_var char temp[8192]

    // Test 1: 50 element string sequence
    temp = ''
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, 13, 10"
        }
        temp = "temp, '- item', itoa(i)"
    }
    YAML_LARGE_SEQ_TEST[1] = temp

    // Test 2: 50 element integer sequence
    temp = ''
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, 13, 10"
        }
        temp = "temp, '- ', itoa(i * 10)"
    }
    YAML_LARGE_SEQ_TEST[2] = temp

    // Test 3: 100 element boolean sequence
    temp = ''
    for (i = 1; i <= 100; i++) {
        if (i > 1) {
            temp = "temp, 13, 10"
        }
        if (i mod 2) {
            temp = "temp, '- true'"
        } else {
            temp = "temp, '- false'"
        }
    }
    YAML_LARGE_SEQ_TEST[3] = temp

    // Test 4: 25 element float sequence
    temp = ''
    for (i = 1; i <= 25; i++) {
        if (i > 1) {
            temp = "temp, 13, 10"
        }
        temp = "temp, '- ', itoa(i), '.', itoa(i * 5)"
    }
    YAML_LARGE_SEQ_TEST[4] = temp

    // Test 5: Large mapping with 30 properties
    temp = ''
    for (i = 1; i <= 30; i++) {
        if (i > 1) {
            temp = "temp, 13, 10"
        }
        temp = "temp, 'prop', itoa(i), ': value', itoa(i)"
    }
    YAML_LARGE_SEQ_TEST[5] = temp

    // Test 6: Sequence of 25 mappings
    temp = ''
    for (i = 1; i <= 25; i++) {
        if (i > 1) {
            temp = "temp, 13, 10"
        }
        temp = "temp, '- id: ', itoa(i), 13, 10, '  name: item', itoa(i)"
    }
    YAML_LARGE_SEQ_TEST[6] = temp

    // Test 7: 50 element sequence with access to middle element
    temp = ''
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, 13, 10"
        }
        temp = "temp, '- ', itoa(i)"
    }
    YAML_LARGE_SEQ_TEST[7] = temp

    // Test 8: 50 element sequence with access to last element
    YAML_LARGE_SEQ_TEST[8] = YAML_LARGE_SEQ_TEST[7]

    // Test 9: Mixed type mapping with large sequence property
    temp = "'count: 50', 13, 10, 'items:', 13, 10"
    for (i = 1; i <= 50; i++) {
        temp = "temp, '  - ', itoa(i), 13, 10"
    }
    YAML_LARGE_SEQ_TEST[9] = temp

    // Test 10: Large nested structure
    temp = "'data:', 13, 10, '  - a', 13, 10, '  - b', 13, 10, '  - c', 13, 10, '  - d', 13, 10, '  - e', 13, 10, '  - f', 13, 10, '  - g', 13, 10, '  - h', 13, 10, '  - i', 13, 10, '  - j'"
    YAML_LARGE_SEQ_TEST[10] = temp

    set_length_array(YAML_LARGE_SEQ_TEST, 10)
}


DEFINE_CONSTANT

constant integer YAML_LARGE_SEQ_EXPECTED_COUNT[10] = {
    50,   // Test 1
    50,   // Test 2
    100,  // Test 3
    25,   // Test 4
    30,   // Test 5
    25,   // Test 6
    50,   // Test 7
    50,   // Test 8
    50,   // Test 9 - items sequence
    10    // Test 10 - data sequence
}

constant char YAML_LARGE_SEQ_TEST_QUERY[10][64] = {
    '.',              // Test 1 - root sequence
    '.',              // Test 2 - root sequence
    '.',              // Test 3 - root sequence
    '.',              // Test 4 - root sequence
    '.',              // Test 5 - root mapping (property count)
    '.',              // Test 6 - root sequence
    '.[25]',          // Test 7 - middle element (0-based: 24th)
    '.[50]',          // Test 8 - last element (0-based: 49th)
    '.items',         // Test 9 - nested sequence
    '.data'           // Test 10 - nested sequence
}

constant integer YAML_LARGE_SEQ_EXPECTED_VALUE[10] = {
    0,    // Test 1 - string sequence
    0,    // Test 2 - integer sequence (validate count)
    0,    // Test 3 - boolean sequence (validate count)
    0,    // Test 4 - float sequence (validate count)
    0,    // Test 5 - mapping properties (validate count)
    0,    // Test 6 - mapping sequence (validate count)
    25,   // Test 7 - middle element value
    50,   // Test 8 - last element value
    0,    // Test 9 - nested sequence (validate count)
    0     // Test 10 - nested sequence (validate count)
}


define_function TestNAVYamlLargeSequences() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlLargeSequences'")

    InitializeYamlLargeSequencesTestData()

    for (x = 1; x <= length_array(YAML_LARGE_SEQ_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode node
        stack_var integer count
        stack_var integer value

        if (!NAVYamlParse(YAML_LARGE_SEQ_TEST[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQuery(yaml, YAML_LARGE_SEQ_TEST_QUERY[x], node)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // For tests 1-6, 9-10: validate child count
        // For tests 7-8: validate element value
        if (x == 7 || x == 8) {
            if (!NAVYamlQueryInteger(yaml, YAML_LARGE_SEQ_TEST_QUERY[x], value)) {
                NAVLogTestFailed(x, 'Query element success', 'Query element failed')
                continue
            }

            if (!NAVAssertIntegerEqual('Large sequence element value',
                                      YAML_LARGE_SEQ_EXPECTED_VALUE[x],
                                      value)) {
                NAVLogTestFailed(x,
                                itoa(YAML_LARGE_SEQ_EXPECTED_VALUE[x]),
                                itoa(value))
                continue
            }
        } else {
            count = NAVYamlGetChildCount(node)

            if (!NAVAssertIntegerEqual('Large sequence/mapping child count',
                                      YAML_LARGE_SEQ_EXPECTED_COUNT[x],
                                      count)) {
                NAVLogTestFailed(x,
                                itoa(YAML_LARGE_SEQ_EXPECTED_COUNT[x]),
                                itoa(count))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlLargeSequences'")
}
