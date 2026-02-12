PROGRAM_NAME='NAVXmlQueryInteger'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_INTEGER_TEST_XML[10][512]
volatile char XML_QUERY_INTEGER_TEST_QUERY[10][64]


define_function InitializeXmlQueryIntegerTestData() {
    // Test 1: Simple root number
    XML_QUERY_INTEGER_TEST_XML[1] = '<value>42</value>'
    XML_QUERY_INTEGER_TEST_QUERY[1] = '.'

    // Test 2: Element property
    XML_QUERY_INTEGER_TEST_XML[2] = '<device><channel>101</channel></device>'
    XML_QUERY_INTEGER_TEST_QUERY[2] = '.channel'

    // Test 3: Nested element property
    XML_QUERY_INTEGER_TEST_XML[3] = '<root><device><id>128</id></device></root>'
    XML_QUERY_INTEGER_TEST_QUERY[3] = '.device.id'

    // Test 4: Element by index
    XML_QUERY_INTEGER_TEST_XML[4] = '<items><item>100</item><item>200</item><item>300</item></items>'
    XML_QUERY_INTEGER_TEST_QUERY[4] = '.item[2]'

    // Test 5: Element in indexed parent
    XML_QUERY_INTEGER_TEST_XML[5] = '<root><server><port>80</port></server><server><port>443</port></server><server><port>8080</port></server></root>'
    XML_QUERY_INTEGER_TEST_QUERY[5] = '.server[3].port'

    // Test 6: Deeply nested property
    XML_QUERY_INTEGER_TEST_XML[6] = '<root><config><network><timeout>5000</timeout></network></config></root>'
    XML_QUERY_INTEGER_TEST_QUERY[6] = '.config.network.timeout'

    // Test 7: Zero value
    XML_QUERY_INTEGER_TEST_XML[7] = '<data><count>0</count></data>'
    XML_QUERY_INTEGER_TEST_QUERY[7] = '.count'

    // Test 8: Maximum 16-bit value
    XML_QUERY_INTEGER_TEST_XML[8] = '<data><maxValue>65535</maxValue></data>'
    XML_QUERY_INTEGER_TEST_QUERY[8] = '.maxValue'

    // Test 9: Float to integer conversion (truncates)
    XML_QUERY_INTEGER_TEST_XML[9] = '<data><value>123.456</value></data>'
    XML_QUERY_INTEGER_TEST_QUERY[9] = '.value'

    // Test 10: Property after array index
    XML_QUERY_INTEGER_TEST_XML[10] = '<root><devices><device><address>1</address></device><device><address>2</address></device></devices></root>'
    XML_QUERY_INTEGER_TEST_QUERY[10] = '.devices.device[1].address'

    set_length_array(XML_QUERY_INTEGER_TEST_XML, 10)
    set_length_array(XML_QUERY_INTEGER_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer XML_QUERY_INTEGER_EXPECTED[10] = {
    42,      // Test 1
    101,     // Test 2
    128,     // Test 3
    200,     // Test 4
    8080,    // Test 5
    5000,    // Test 6
    0,       // Test 7
    65535,   // Test 8
    123,     // Test 9 (truncated)
    1        // Test 10
}


define_function TestNAVXmlQueryInteger() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQueryInteger'")

    InitializeXmlQueryIntegerTestData()

    for (x = 1; x <= length_array(XML_QUERY_INTEGER_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var integer result

        if (!NAVXmlParse(XML_QUERY_INTEGER_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryInteger(xml, XML_QUERY_INTEGER_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('NAVXmlQueryInteger value',
                                   XML_QUERY_INTEGER_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(XML_QUERY_INTEGER_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQueryInteger'")
}
