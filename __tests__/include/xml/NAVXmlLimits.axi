PROGRAM_NAME='NAVXmlLimits'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_LIMITS_TEST_XML[10][15000]
volatile char XML_LIMITS_TEST_QUERY[10][256]


define_function InitializeXmlLimitsTestData() {
    stack_var integer i
    stack_var char tempXml[15000]
    stack_var char longString[512]
    stack_var char veryLongString[1024]

    // Generate a 200-character string
    longString = ''
    for (i = 1; i <= 20; i++) {
        longString = "longString, '0123456789'"
    }

    // Generate a 500-character string
    veryLongString = ''
    for (i = 1; i <= 50; i++) {
        veryLongString = "veryLongString, '0123456789'"
    }

    // Test 1: Long text content (200 characters)
    XML_LIMITS_TEST_XML[1] = "'<root><text>', longString, '</text></root>'"
    XML_LIMITS_TEST_QUERY[1] = '.text'

    // Test 2: Very long text content (500 characters)
    XML_LIMITS_TEST_XML[2] = "'<root><content>', veryLongString, '</content></root>'"
    XML_LIMITS_TEST_QUERY[2] = '.content'

    // Test 3: Long attribute value (100 characters)
    tempXml = ''
    for (i = 1; i <= 10; i++) {
        tempXml = "tempXml, '0123456789'"
    }
    XML_LIMITS_TEST_XML[3] = "'<root><element attr=', $22, tempXml, $22, '>value</element></root>'"
    XML_LIMITS_TEST_QUERY[3] = '.element@attr'

    // Test 4: Long element name (63 characters - typical max for element names)
    tempXml = 'VeryLongElementNameThatIsExactlySixtyThreeCharactersInLengthYes'
    XML_LIMITS_TEST_XML[4] = "'<root><', tempXml, '>content</', tempXml, '></root>'"
    XML_LIMITS_TEST_QUERY[4] = "'.',tempXml"

    // Test 5: Many sibling elements (100+)
    tempXml = '<root><container>'
    for (i = 1; i <= 100; i++) {
        tempXml = "tempXml, '<item>', itoa(i), '</item>'"
    }
    tempXml = "tempXml, '</container></root>'"
    XML_LIMITS_TEST_XML[5] = tempXml
    XML_LIMITS_TEST_QUERY[5] = '.container.item[100]'

    // Test 6: Deep nesting (15 levels)
    tempXml = '<root>'
    for (i = 1; i <= 15; i++) {
        tempXml = "tempXml, '<level', itoa(i), '>'"
    }
    tempXml = "tempXml, 'deep'"
    for (i = 15; i >= 1; i--) {
        tempXml = "tempXml, '</level', itoa(i), '>'"
    }
    tempXml = "tempXml, '</root>'"
    XML_LIMITS_TEST_XML[6] = tempXml
    XML_LIMITS_TEST_QUERY[6] = '.level1.level2.level3.level4.level5.level6.level7.level8.level9.level10.level11.level12.level13.level14.level15'

    // Test 7: Many attributes on single element (20 attributes)
    tempXml = '<root><element '
    for (i = 1; i <= 20; i++) {
        tempXml = "tempXml, 'attr', itoa(i), '=', $22, 'value', itoa(i), $22, ' '"
    }
    tempXml = "tempXml, '>content</element></root>'"
    XML_LIMITS_TEST_XML[7] = tempXml
    XML_LIMITS_TEST_QUERY[7] = '.element@attr10'

    // Test 8: Maximum 32-bit unsigned integer value (4294967295)
    XML_LIMITS_TEST_XML[8] = '<root><maxint>4294967295</maxint></root>'
    XML_LIMITS_TEST_QUERY[8] = '.maxint'

    // Test 9: Empty elements with many siblings (50 empty)
    tempXml = '<root><items>'
    for (i = 1; i <= 50; i++) {
        tempXml = "tempXml, '<item/>'"
    }
    tempXml = "tempXml, '</items></root>'"
    XML_LIMITS_TEST_XML[9] = tempXml
    XML_LIMITS_TEST_QUERY[9] = '.items.item[25]'

    // Test 10: Complex structure combining multiple limits
    tempXml = '<root>'
    for (i = 1; i <= 50; i++) {
        tempXml = "tempXml, '<record id=', $22, itoa(i), $22, '>'"
        tempXml = "tempXml, '<data>Content for record ', itoa(i), '</data>'"
        tempXml = "tempXml, '</record>'"
    }
    tempXml = "tempXml, '</root>'"
    XML_LIMITS_TEST_XML[10] = tempXml
    XML_LIMITS_TEST_QUERY[10] = '.record[25].data'

    set_length_array(XML_LIMITS_TEST_XML, 10)
    set_length_array(XML_LIMITS_TEST_QUERY, 10)
}


DEFINE_CONSTANT

// Expected results for each test
// For Test 1 & 2, we expect the query to succeed but we'll just check length
constant integer XML_LIMITS_EXPECTED_LENGTH[10] = {
    200,    // Test 1: 200-char string
    500,    // Test 2: 500-char string
    100,    // Test 3: 100-char attribute
    7,      // Test 4: "content"
    3,      // Test 5: "100"
    4,      // Test 6: "deep"
    7,      // Test 7: "value10"
    10,     // Test 8: "4294967295"
    0,      // Test 9: Empty element
    21      // Test 10: "Content for record 25"
}

// Whether query should succeed
constant char XML_LIMITS_SUCCESS[10] = {
    true,   // Test 1
    true,   // Test 2
    true,   // Test 3
    true,   // Test 4
    true,   // Test 5
    true,   // Test 6
    true,   // Test 7
    true,   // Test 8
    true,   // Test 9: Empty element returns empty string
    true    // Test 10
}


define_function TestNAVXmlLimits() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlLimits'")

    InitializeXmlLimitsTestData()

    for (x = 1; x <= length_array(XML_LIMITS_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var char result[1024]
        stack_var char success

        if (!NAVXmlParse(XML_LIMITS_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        success = NAVXmlQueryString(xml, XML_LIMITS_TEST_QUERY[x], result)

        if (!NAVAssertBooleanEqual('Query success',
                                    XML_LIMITS_SUCCESS[x],
                                    success)) {
            NAVLogTestFailed(x,
                            itoa(XML_LIMITS_SUCCESS[x]),
                            itoa(success))
            continue
        }

        if (success) {
            if (!NAVAssertIntegerEqual('Result length',
                                       XML_LIMITS_EXPECTED_LENGTH[x],
                                       length_array(result))) {
                NAVLogTestFailed(x,
                                itoa(XML_LIMITS_EXPECTED_LENGTH[x]),
                                itoa(length_array(result)))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlLimits'")
}
