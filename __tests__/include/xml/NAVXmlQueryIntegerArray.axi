PROGRAM_NAME='NAVXmlQueryIntegerArray'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_INTEGER_ARRAY_TEST_XML[10][1024]
volatile char XML_QUERY_INTEGER_ARRAY_TEST_QUERY[10][64]


define_function InitializeXmlQueryIntegerArrayTestData() {
    // Test 1: Simple root array
    XML_QUERY_INTEGER_ARRAY_TEST_XML[1] = '<items><item>100</item><item>200</item><item>300</item></items>'
    XML_QUERY_INTEGER_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Nested array property
    XML_QUERY_INTEGER_ARRAY_TEST_XML[2] = '<root><channels><channel>1</channel><channel>2</channel><channel>3</channel><channel>4</channel><channel>5</channel></channels></root>'
    XML_QUERY_INTEGER_ARRAY_TEST_QUERY[2] = '.channels'

    // Test 3: Deeply nested array
    XML_QUERY_INTEGER_ARRAY_TEST_XML[3] = '<root><device><ports><port>80</port><port>443</port><port>8080</port></ports></device></root>'
    XML_QUERY_INTEGER_ARRAY_TEST_QUERY[3] = '.device.ports'

    // Test 4: Array after index
    XML_QUERY_INTEGER_ARRAY_TEST_XML[4] = '<root><group><item>10</item><item>20</item></group><group><item>30</item><item>40</item><item>50</item></group></root>'
    XML_QUERY_INTEGER_ARRAY_TEST_QUERY[4] = '.group[2]'

    // Test 5: Array with zeros
    XML_QUERY_INTEGER_ARRAY_TEST_XML[5] = '<data><counters><counter>0</counter><counter>0</counter><counter>0</counter></counters></data>'
    XML_QUERY_INTEGER_ARRAY_TEST_QUERY[5] = '.counters'

    // Test 6: Large values
    XML_QUERY_INTEGER_ARRAY_TEST_XML[6] = '<data><ids><id>10000</id><id>20000</id><id>30000</id><id>40000</id></ids></data>'
    XML_QUERY_INTEGER_ARRAY_TEST_QUERY[6] = '.ids'

    // Test 7: Max values
    XML_QUERY_INTEGER_ARRAY_TEST_XML[7] = '<values><value>255</value><value>65535</value></values>'
    XML_QUERY_INTEGER_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    XML_QUERY_INTEGER_ARRAY_TEST_XML[8] = '<empty></empty>'
    XML_QUERY_INTEGER_ARRAY_TEST_QUERY[8] = '.'

    // Test 9: Single element array
    XML_QUERY_INTEGER_ARRAY_TEST_XML[9] = '<data><single><value>42</value></single></data>'
    XML_QUERY_INTEGER_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    XML_QUERY_INTEGER_ARRAY_TEST_XML[10] = '<root><devices><device><addresses><address>1</address><address>2</address></addresses></device><device><addresses><address>3</address><address>4</address></addresses></device></devices></root>'
    XML_QUERY_INTEGER_ARRAY_TEST_QUERY[10] = '.devices.device[2].addresses'

    set_length_array(XML_QUERY_INTEGER_ARRAY_TEST_XML, 10)
    set_length_array(XML_QUERY_INTEGER_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer XML_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    5,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    4,  // Test 6
    2,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant integer XML_QUERY_INTEGER_ARRAY_EXPECTED[10][5] = {
    {100, 200, 300},                    // Test 1
    {1, 2, 3, 4, 5},                    // Test 2
    {80, 443, 8080},                    // Test 3
    {30, 40, 50},                       // Test 4
    {0, 0, 0},                          // Test 5
    {10000, 20000, 30000, 40000},       // Test 6
    {255, 65535},                       // Test 7
    {0},                                // Test 8 (empty)
    {42},                               // Test 9
    {3, 4}                              // Test 10
}


define_function TestNAVXmlQueryIntegerArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQueryIntegerArray'")

    InitializeXmlQueryIntegerArrayTestData()

    for (x = 1; x <= length_array(XML_QUERY_INTEGER_ARRAY_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var integer result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVXmlParse(XML_QUERY_INTEGER_ARRAY_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryIntegerArray(xml, XML_QUERY_INTEGER_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   XML_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(XML_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertIntegerEqual("'Array element ', itoa(i)",
                                      XML_QUERY_INTEGER_ARRAY_EXPECTED[x][i],
                                      result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(XML_QUERY_INTEGER_ARRAY_EXPECTED[x][i])",
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

    NAVLogTestSuiteEnd("'NAVXmlQueryIntegerArray'")
}
