PROGRAM_NAME='NAVXmlQueryLongArray'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_LONG_ARRAY_TEST_XML[10][1024]
volatile char XML_QUERY_LONG_ARRAY_TEST_QUERY[10][64]


define_function InitializeXmlQueryLongArrayTestData() {
    // Test 1: Simple root array
    XML_QUERY_LONG_ARRAY_TEST_XML[1] = '<items><item>100000</item><item>200000</item><item>300000</item></items>'
    XML_QUERY_LONG_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Nested array property
    XML_QUERY_LONG_ARRAY_TEST_XML[2] = '<root><timestamps><timestamp>1609459200</timestamp><timestamp>1609545600</timestamp><timestamp>1609632000</timestamp></timestamps></root>'
    XML_QUERY_LONG_ARRAY_TEST_QUERY[2] = '.timestamps'

    // Test 3: Deeply nested array
    XML_QUERY_LONG_ARRAY_TEST_XML[3] = '<root><system><sizes><size>1000000</size><size>2000000</size><size>3000000</size></sizes></system></root>'
    XML_QUERY_LONG_ARRAY_TEST_QUERY[3] = '.system.sizes'

    // Test 4: Array after index
    XML_QUERY_LONG_ARRAY_TEST_XML[4] = '<root><group><item>100000</item><item>200000</item></group><group><item>300000</item><item>400000</item><item>500000</item></group></root>'
    XML_QUERY_LONG_ARRAY_TEST_QUERY[4] = '.group[2]'

    // Test 5: Array with zeros
    XML_QUERY_LONG_ARRAY_TEST_XML[5] = '<data><counters><counter>0</counter><counter>0</counter><counter>0</counter></counters></data>'
    XML_QUERY_LONG_ARRAY_TEST_QUERY[5] = '.counters'

    // Test 6: Large values
    XML_QUERY_LONG_ARRAY_TEST_XML[6] = '<data><bytes><byte>2147483647</byte><byte>1000000000</byte></bytes></data>'
    XML_QUERY_LONG_ARRAY_TEST_QUERY[6] = '.bytes'

    // Test 7: Very large values
    XML_QUERY_LONG_ARRAY_TEST_XML[7] = '<values><value>4294967295</value><value>3000000000</value></values>'
    XML_QUERY_LONG_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    XML_QUERY_LONG_ARRAY_TEST_XML[8] = '<empty></empty>'
    XML_QUERY_LONG_ARRAY_TEST_QUERY[8] = '.'

    // Test 9: Single element array
    XML_QUERY_LONG_ARRAY_TEST_XML[9] = '<data><single><value>999999999</value></single></data>'
    XML_QUERY_LONG_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    XML_QUERY_LONG_ARRAY_TEST_XML[10] = '<root><records><record><ids><id>1000000</id><id>2000000</id></ids></record><record><ids><id>3000000</id><id>4000000</id></ids></record></records></root>'
    XML_QUERY_LONG_ARRAY_TEST_QUERY[10] = '.records.record[2].ids'

    set_length_array(XML_QUERY_LONG_ARRAY_TEST_XML, 10)
    set_length_array(XML_QUERY_LONG_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer XML_QUERY_LONG_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    2,  // Test 6
    2,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant long XML_QUERY_LONG_ARRAY_EXPECTED[10][5] = {
    {100000, 200000, 300000},                       // Test 1
    {1609459200, 1609545600, 1609632000},           // Test 2
    {1000000, 2000000, 3000000},                    // Test 3
    {300000, 400000, 500000},                       // Test 4
    {0, 0, 0},                                      // Test 5
    {2147483647, 1000000000},                       // Test 6
    {4294967295, 3000000000},                       // Test 7
    {0},                                            // Test 8 (empty)
    {999999999},                                    // Test 9
    {3000000, 4000000}                              // Test 10
}


define_function TestNAVXmlQueryLongArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQueryLongArray'")

    InitializeXmlQueryLongArrayTestData()

    for (x = 1; x <= length_array(XML_QUERY_LONG_ARRAY_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var long result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVXmlParse(XML_QUERY_LONG_ARRAY_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryLongArray(xml, XML_QUERY_LONG_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   XML_QUERY_LONG_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(XML_QUERY_LONG_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertLongEqual("'Array element ', itoa(i)",
                                   XML_QUERY_LONG_ARRAY_EXPECTED[x][i],
                                   result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(XML_QUERY_LONG_ARRAY_EXPECTED[x][i])",
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

    NAVLogTestSuiteEnd("'NAVXmlQueryLongArray'")
}
