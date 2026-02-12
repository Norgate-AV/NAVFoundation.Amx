PROGRAM_NAME='NAVXmlQueryLong'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_LONG_TEST_XML[10][512]
volatile char XML_QUERY_LONG_TEST_QUERY[10][64]


define_function InitializeXmlQueryLongTestData() {
    // Test 1: Simple value
    XML_QUERY_LONG_TEST_XML[1] = '<value>100000</value>'
    XML_QUERY_LONG_TEST_QUERY[1] = '.'

    // Test 2: Element property
    XML_QUERY_LONG_TEST_XML[2] = '<data><timestamp>1609459200</timestamp></data>'
    XML_QUERY_LONG_TEST_QUERY[2] = '.timestamp'

    // Test 3: Nested element property
    XML_QUERY_LONG_TEST_XML[3] = '<root><data><bytes>2147483647</bytes></data></root>'
    XML_QUERY_LONG_TEST_QUERY[3] = '.data.bytes'

    // Test 4: Element by index
    XML_QUERY_LONG_TEST_XML[4] = '<items><item>1000000</item><item>2000000</item><item>3000000</item></items>'
    XML_QUERY_LONG_TEST_QUERY[4] = '.item[2]'

    // Test 5: Element in indexed parent
    XML_QUERY_LONG_TEST_XML[5] = '<root><data><size>100000</size></data><data><size>200000</size></data><data><size>300000</size></data></root>'
    XML_QUERY_LONG_TEST_QUERY[5] = '.data[3].size'

    // Test 6: Deeply nested property
    XML_QUERY_LONG_TEST_XML[6] = '<root><system><memory><total>4294967295</total></memory></system></root>'
    XML_QUERY_LONG_TEST_QUERY[6] = '.system.memory.total'

    // Test 7: Zero value
    XML_QUERY_LONG_TEST_XML[7] = '<data><counter>0</counter></data>'
    XML_QUERY_LONG_TEST_QUERY[7] = '.counter'

    // Test 8: Large value
    XML_QUERY_LONG_TEST_XML[8] = '<file><fileSize>999999999</fileSize></file>'
    XML_QUERY_LONG_TEST_QUERY[8] = '.fileSize'

    // Test 9: Float to long conversion (truncates)
    XML_QUERY_LONG_TEST_XML[9] = '<data><value>123456.789</value></data>'
    XML_QUERY_LONG_TEST_QUERY[9] = '.value'

    // Test 10: Property after array index
    XML_QUERY_LONG_TEST_XML[10] = '<root><records><record><id>1000000</id></record><record><id>2000000</id></record></records></root>'
    XML_QUERY_LONG_TEST_QUERY[10] = '.records.record[1].id'

    set_length_array(XML_QUERY_LONG_TEST_XML, 10)
    set_length_array(XML_QUERY_LONG_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant long XML_QUERY_LONG_EXPECTED[10] = {
    100000,      // Test 1
    1609459200,  // Test 2
    2147483647,  // Test 3
    2000000,     // Test 4
    300000,      // Test 5
    4294967295,  // Test 6
    0,           // Test 7
    999999999,   // Test 8
    123456,      // Test 9 (truncated)
    1000000      // Test 10
}


define_function TestNAVXmlQueryLong() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQueryLong'")

    InitializeXmlQueryLongTestData()

    for (x = 1; x <= length_array(XML_QUERY_LONG_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var long result

        if (!NAVXmlParse(XML_QUERY_LONG_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryLong(xml, XML_QUERY_LONG_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertLongEqual('NAVXmlQueryLong value',
                                XML_QUERY_LONG_EXPECTED[x],
                                result)) {
            NAVLogTestFailed(x,
                            itoa(XML_QUERY_LONG_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQueryLong'")
}
