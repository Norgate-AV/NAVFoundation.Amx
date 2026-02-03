PROGRAM_NAME='NAVXmlQueryBooleanArray'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_BOOLEAN_ARRAY_TEST_XML[10][1024]
volatile char XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[10][64]


define_function InitializeXmlQueryBooleanArrayTestData() {
    // Test 1: Simple root array
    XML_QUERY_BOOLEAN_ARRAY_TEST_XML[1] = '<items><item>true</item><item>false</item><item>true</item></items>'
    XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Nested array property
    XML_QUERY_BOOLEAN_ARRAY_TEST_XML[2] = '<root><flags><flag>false</flag><flag>true</flag><flag>false</flag></flags></root>'
    XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[2] = '.flags'

    // Test 3: Deeply nested array
    XML_QUERY_BOOLEAN_ARRAY_TEST_XML[3] = '<root><settings><enabled><enable>true</enable><enable>true</enable><enable>false</enable></enabled></settings></root>'
    XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[3] = '.settings.enabled'

    // Test 4: Array after index
    XML_QUERY_BOOLEAN_ARRAY_TEST_XML[4] = '<root><group><item>true</item><item>false</item></group><group><item>false</item><item>true</item><item>false</item></group></root>'
    XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[4] = '.group[2]'

    // Test 5: Array with all true
    XML_QUERY_BOOLEAN_ARRAY_TEST_XML[5] = '<data><switches><switch>true</switch><switch>true</switch><switch>true</switch></switches></data>'
    XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[5] = '.switches'

    // Test 6: Array with all false
    XML_QUERY_BOOLEAN_ARRAY_TEST_XML[6] = '<data><disabled><disable>false</disable><disable>false</disable><disable>false</disable></disabled></data>'
    XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[6] = '.disabled'

    // Test 7: Mixed array
    XML_QUERY_BOOLEAN_ARRAY_TEST_XML[7] = '<values><value>true</value><value>false</value><value>false</value><value>true</value><value>true</value></values>'
    XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    XML_QUERY_BOOLEAN_ARRAY_TEST_XML[8] = '<empty></empty>'
    XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[8] = '.'

    // Test 9: Single element array
    XML_QUERY_BOOLEAN_ARRAY_TEST_XML[9] = '<data><single><value>true</value></single></data>'
    XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    XML_QUERY_BOOLEAN_ARRAY_TEST_XML[10] = '<root><devices><device><states><state>true</state><state>false</state></states></device><device><states><state>false</state><state>true</state></states></device></devices></root>'
    XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[10] = '.devices.device[2].states'

    set_length_array(XML_QUERY_BOOLEAN_ARRAY_TEST_XML, 10)
    set_length_array(XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer XML_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    3,  // Test 6
    5,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant char XML_QUERY_BOOLEAN_ARRAY_EXPECTED[10][5] = {
    {true, false, true},                // Test 1
    {false, true, false},               // Test 2
    {true, true, false},                // Test 3
    {false, true, false},               // Test 4
    {true, true, true},                 // Test 5
    {false, false, false},              // Test 6
    {true, false, false, true, true},   // Test 7
    {false},                            // Test 8 (empty)
    {true},                             // Test 9
    {false, true}                       // Test 10
}


define_function TestNAVXmlQueryBooleanArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQueryBooleanArray'")

    InitializeXmlQueryBooleanArrayTestData()

    for (x = 1; x <= length_array(XML_QUERY_BOOLEAN_ARRAY_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var char result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVXmlParse(XML_QUERY_BOOLEAN_ARRAY_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryBooleanArray(xml, XML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   XML_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(XML_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertBooleanEqual("'Array element ', itoa(i)",
                                      XML_QUERY_BOOLEAN_ARRAY_EXPECTED[x][i],
                                      result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', NAVBooleanToString(XML_QUERY_BOOLEAN_ARRAY_EXPECTED[x][i])",
                                "'Element ', itoa(i), ': ', NAVBooleanToString(result[i])")

                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQueryBooleanArray'")
}
