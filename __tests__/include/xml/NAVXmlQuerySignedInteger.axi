PROGRAM_NAME='NAVXmlQuerySignedInteger'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_SINTEGER_TEST_XML[10][512]
volatile char XML_QUERY_SINTEGER_TEST_QUERY[10][64]


define_function InitializeXmlQuerySignedIntegerTestData() {
    // Test 1: Positive value
    XML_QUERY_SINTEGER_TEST_XML[1] = '<value>42</value>'
    XML_QUERY_SINTEGER_TEST_QUERY[1] = '.'

    // Test 2: Negative value
    XML_QUERY_SINTEGER_TEST_XML[2] = '<data><temperature>-15</temperature></data>'
    XML_QUERY_SINTEGER_TEST_QUERY[2] = '.temperature'

    // Test 3: Nested negative value
    XML_QUERY_SINTEGER_TEST_XML[3] = '<root><sensor><offset>-100</offset></sensor></root>'
    XML_QUERY_SINTEGER_TEST_QUERY[3] = '.sensor.offset'

    // Test 4: Element by index with negative
    XML_QUERY_SINTEGER_TEST_XML[4] = '<items><item>-10</item><item>-20</item><item>-30</item></items>'
    XML_QUERY_SINTEGER_TEST_QUERY[4] = '.item[2]'

    // Test 5: Element in indexed parent with negative
    XML_QUERY_SINTEGER_TEST_XML[5] = '<root><data><delta>-5</delta></data><data><delta>-10</delta></data><data><delta>-15</delta></data></root>'
    XML_QUERY_SINTEGER_TEST_QUERY[5] = '.data[3].delta'

    // Test 6: Deeply nested negative
    XML_QUERY_SINTEGER_TEST_XML[6] = '<root><data><calibration><adjustment>-50</adjustment></calibration></data></root>'
    XML_QUERY_SINTEGER_TEST_QUERY[6] = '.data.calibration.adjustment'

    // Test 7: Zero value
    XML_QUERY_SINTEGER_TEST_XML[7] = '<data><baseline>0</baseline></data>'
    XML_QUERY_SINTEGER_TEST_QUERY[7] = '.baseline'

    // Test 8: Maximum positive value
    XML_QUERY_SINTEGER_TEST_XML[8] = '<data><maxValue>32767</maxValue></data>'
    XML_QUERY_SINTEGER_TEST_QUERY[8] = '.maxValue'

    // Test 9: Maximum negative value
    XML_QUERY_SINTEGER_TEST_XML[9] = '<data><minValue>-32768</minValue></data>'
    XML_QUERY_SINTEGER_TEST_QUERY[9] = '.minValue'

    // Test 10: Property after array index
    XML_QUERY_SINTEGER_TEST_XML[10] = '<root><readings><reading><value>-123</value></reading><reading><value>456</value></reading></readings></root>'
    XML_QUERY_SINTEGER_TEST_QUERY[10] = '.readings.reading[1].value'

    set_length_array(XML_QUERY_SINTEGER_TEST_XML, 10)
    set_length_array(XML_QUERY_SINTEGER_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant sinteger XML_QUERY_SINTEGER_EXPECTED[10] = {
    42,      // Test 1
    -15,     // Test 2
    -100,    // Test 3
    -20,     // Test 4
    -15,     // Test 5
    -50,     // Test 6
    0,       // Test 7
    32767,   // Test 8
    -32768,  // Test 9
    -123     // Test 10
}


define_function TestNAVXmlQuerySignedInteger() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQuerySignedInteger'")

    InitializeXmlQuerySignedIntegerTestData()

    for (x = 1; x <= length_array(XML_QUERY_SINTEGER_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var sinteger result

        if (!NAVXmlParse(XML_QUERY_SINTEGER_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQuerySignedInteger(xml, XML_QUERY_SINTEGER_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertSignedIntegerEqual('NAVXmlQuerySignedInteger value',
                                         XML_QUERY_SINTEGER_EXPECTED[x],
                                         result)) {
            NAVLogTestFailed(x,
                            itoa(XML_QUERY_SINTEGER_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQuerySignedInteger'")
}
