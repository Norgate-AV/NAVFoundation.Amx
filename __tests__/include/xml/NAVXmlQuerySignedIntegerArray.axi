PROGRAM_NAME='NAVXmlQuerySignedIntegerArray'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_SINTEGER_ARRAY_TEST_XML[10][1024]
volatile char XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[10][64]


define_function InitializeXmlQuerySignedIntegerArrayTestData() {
    // Test 1: Simple root array with mixed signs
    XML_QUERY_SINTEGER_ARRAY_TEST_XML[1] = '<items><item>-100</item><item>200</item><item>-300</item></items>'
    XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Nested array property with negatives
    XML_QUERY_SINTEGER_ARRAY_TEST_XML[2] = '<root><temperatures><temperature>-15</temperature><temperature>-10</temperature><temperature>-5</temperature><temperature>0</temperature><temperature>5</temperature></temperatures></root>'
    XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[2] = '.temperatures'

    // Test 3: Deeply nested array
    XML_QUERY_SINTEGER_ARRAY_TEST_XML[3] = '<root><sensor><offsets><offset>-100</offset><offset>-50</offset><offset>0</offset></offsets></sensor></root>'
    XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[3] = '.sensor.offsets'

    // Test 4: Array after index
    XML_QUERY_SINTEGER_ARRAY_TEST_XML[4] = '<root><group><item>-10</item><item>-20</item></group><group><item>-30</item><item>-40</item><item>-50</item></group></root>'
    XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[4] = '.group[2]'

    // Test 5: Array with zeros
    XML_QUERY_SINTEGER_ARRAY_TEST_XML[5] = '<data><baseline><base>0</base><base>0</base><base>0</base></baseline></data>'
    XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[5] = '.baseline'

    // Test 6: Large negative values
    XML_QUERY_SINTEGER_ARRAY_TEST_XML[6] = '<data><deltas><delta>-10000</delta><delta>-20000</delta><delta>-30000</delta></deltas></data>'
    XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[6] = '.deltas'

    // Test 7: Extreme values
    XML_QUERY_SINTEGER_ARRAY_TEST_XML[7] = '<values><value>32767</value><value>-32768</value></values>'
    XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    XML_QUERY_SINTEGER_ARRAY_TEST_XML[8] = '<empty></empty>'
    XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[8] = '.'

    // Test 9: Single negative element
    XML_QUERY_SINTEGER_ARRAY_TEST_XML[9] = '<data><single><value>-42</value></single></data>'
    XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    XML_QUERY_SINTEGER_ARRAY_TEST_XML[10] = '<root><readings><reading><vals><val>-1</val><val>-2</val></vals></reading><reading><vals><val>-3</val><val>-4</val></vals></reading></readings></root>'
    XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[10] = '.readings.reading[2].vals'

    set_length_array(XML_QUERY_SINTEGER_ARRAY_TEST_XML, 10)
    set_length_array(XML_QUERY_SINTEGER_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer XML_QUERY_SINTEGER_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    5,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    3,  // Test 6
    2,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant sinteger XML_QUERY_SINTEGER_ARRAY_EXPECTED[10][5] = {
    {-100, 200, -300},                  // Test 1
    {-15, -10, -5, 0, 5},               // Test 2
    {-100, -50, 0},                     // Test 3
    {-30, -40, -50},                    // Test 4
    {0, 0, 0},                          // Test 5
    {-10000, -20000, -30000},           // Test 6
    {32767, -32768},                    // Test 7
    {0},                                // Test 8 (empty)
    {-42},                              // Test 9
    {-3, -4}                            // Test 10
}


define_function TestNAVXmlQuerySignedIntegerArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQuerySignedIntegerArray'")

    InitializeXmlQuerySignedIntegerArrayTestData()

    for (x = 1; x <= length_array(XML_QUERY_SINTEGER_ARRAY_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var sinteger result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVXmlParse(XML_QUERY_SINTEGER_ARRAY_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQuerySignedIntegerArray(xml, XML_QUERY_SINTEGER_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   XML_QUERY_SINTEGER_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(XML_QUERY_SINTEGER_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertSignedIntegerEqual("'Array element ', itoa(i)",
                                            XML_QUERY_SINTEGER_ARRAY_EXPECTED[x][i],
                                            result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(XML_QUERY_SINTEGER_ARRAY_EXPECTED[x][i])",
                                "'Element ', itoa(i), ': ', itoa(result[i])")

                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQuerySignedIntegerArray'")
}
