PROGRAM_NAME='NAVXmlQueryBoolean'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_BOOLEAN_TEST_XML[10][512]
volatile char XML_QUERY_BOOLEAN_TEST_QUERY[10][64]


define_function InitializeXmlQueryBooleanTestData() {
    // Test 1: Simple root true
    XML_QUERY_BOOLEAN_TEST_XML[1] = '<value>true</value>'
    XML_QUERY_BOOLEAN_TEST_QUERY[1] = '.'

    // Test 2: Simple root false
    XML_QUERY_BOOLEAN_TEST_XML[2] = '<value>false</value>'
    XML_QUERY_BOOLEAN_TEST_QUERY[2] = '.'

    // Test 3: Element property true
    XML_QUERY_BOOLEAN_TEST_XML[3] = '<config><enabled>true</enabled></config>'
    XML_QUERY_BOOLEAN_TEST_QUERY[3] = '.enabled'

    // Test 4: Element property false
    XML_QUERY_BOOLEAN_TEST_XML[4] = '<system><active>false</active></system>'
    XML_QUERY_BOOLEAN_TEST_QUERY[4] = '.active'

    // Test 5: Nested element property
    XML_QUERY_BOOLEAN_TEST_XML[5] = '<root><settings><isVisible>true</isVisible></settings></root>'
    XML_QUERY_BOOLEAN_TEST_QUERY[5] = '.settings.isVisible'

    // Test 6: Element by index
    XML_QUERY_BOOLEAN_TEST_XML[6] = '<items><item>true</item><item>false</item><item>true</item></items>'
    XML_QUERY_BOOLEAN_TEST_QUERY[6] = '.item[2]'

    // Test 7: Element in indexed parent
    XML_QUERY_BOOLEAN_TEST_XML[7] = '<root><data><flag>false</flag></data><data><flag>true</flag></data><data><flag>false</flag></data></root>'
    XML_QUERY_BOOLEAN_TEST_QUERY[7] = '.data[2].flag'

    // Test 8: Deeply nested property
    XML_QUERY_BOOLEAN_TEST_XML[8] = '<root><config><options><debug>false</debug></options></config></root>'
    XML_QUERY_BOOLEAN_TEST_QUERY[8] = '.config.options.debug'

    // Test 9: Property after array index
    XML_QUERY_BOOLEAN_TEST_XML[9] = '<root><devices><device><online>true</online></device><device><online>false</online></device></devices></root>'
    XML_QUERY_BOOLEAN_TEST_QUERY[9] = '.devices.device[1].online'

    // Test 10: Multiple nested levels
    XML_QUERY_BOOLEAN_TEST_XML[10] = '<root><system><modules><module><enabled>true</enabled></module><module><enabled>false</enabled></module></modules></system></root>'
    XML_QUERY_BOOLEAN_TEST_QUERY[10] = '.system.modules.module[2].enabled'

    set_length_array(XML_QUERY_BOOLEAN_TEST_XML, 10)
    set_length_array(XML_QUERY_BOOLEAN_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant char XML_QUERY_BOOLEAN_EXPECTED[10] = {
    true,  // Test 1
    false, // Test 2
    true,  // Test 3
    false, // Test 4
    true,  // Test 5
    false, // Test 6
    true,  // Test 7
    false, // Test 8
    true,  // Test 9
    false  // Test 10
}


define_function TestNAVXmlQueryBoolean() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQueryBoolean'")

    InitializeXmlQueryBooleanTestData()

    for (x = 1; x <= length_array(XML_QUERY_BOOLEAN_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var char result

        if (!NAVXmlParse(XML_QUERY_BOOLEAN_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryBoolean(xml, XML_QUERY_BOOLEAN_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertBooleanEqual('NAVXmlQueryBoolean value',
                           XML_QUERY_BOOLEAN_EXPECTED[x],
                           result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(XML_QUERY_BOOLEAN_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQueryBoolean'")
}
