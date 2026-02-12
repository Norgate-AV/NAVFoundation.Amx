PROGRAM_NAME='NAVXmlProcessingInstructions'

DEFINE_VARIABLE

volatile char XML_PROCESSING_INSTRUCTION_TEST_XML[8][512]
volatile char XML_PROCESSING_INSTRUCTION_TEST_QUERY[8][64]


define_function InitializeXmlProcessingInstructionTestData() {
    // Test 1: Custom PI before root
    XML_PROCESSING_INSTRUCTION_TEST_XML[1] = '<?custom-pi?><root><item>content</item></root>'
    XML_PROCESSING_INSTRUCTION_TEST_QUERY[1] = '.item'

    // Test 2: PI with data
    XML_PROCESSING_INSTRUCTION_TEST_XML[2] = '<?stylesheet type="text/xsl" href="style.xsl"?><root><item>value</item></root>'
    XML_PROCESSING_INSTRUCTION_TEST_QUERY[2] = '.item'

    // Test 3: Multiple PIs
    XML_PROCESSING_INSTRUCTION_TEST_XML[3] = '<?pi1?><?pi2?><root><item>data</item></root>'
    XML_PROCESSING_INSTRUCTION_TEST_QUERY[3] = '.item'

    // Test 4: PI after root element
    XML_PROCESSING_INSTRUCTION_TEST_XML[4] = '<root><item>text</item></root><?after-pi?>'
    XML_PROCESSING_INSTRUCTION_TEST_QUERY[4] = '.item'

    // Test 5: PI between elements (inside root)
    XML_PROCESSING_INSTRUCTION_TEST_XML[5] = '<root><first>first</first><?middle-pi?><second>second</second></root>'
    XML_PROCESSING_INSTRUCTION_TEST_QUERY[5] = '.first'

    // Test 6: PI with attribute-like syntax
    XML_PROCESSING_INSTRUCTION_TEST_XML[6] = '<?php echo "Hello"; ?><root><item>element</item></root>'
    XML_PROCESSING_INSTRUCTION_TEST_QUERY[6] = '.item'

    // Test 7: PI with no data (just target)
    XML_PROCESSING_INSTRUCTION_TEST_XML[7] = '<?simple?><root>simple</root>'
    XML_PROCESSING_INSTRUCTION_TEST_QUERY[7] = '.'

    // Test 8: XML declaration PI
    XML_PROCESSING_INSTRUCTION_TEST_XML[8] = '<?xml version="1.0" encoding="UTF-8"?><root>root</root>'
    XML_PROCESSING_INSTRUCTION_TEST_QUERY[8] = '.'

    set_length_array(XML_PROCESSING_INSTRUCTION_TEST_XML, 8)
    set_length_array(XML_PROCESSING_INSTRUCTION_TEST_QUERY, 8)
}


DEFINE_CONSTANT

constant char XML_PROCESSING_INSTRUCTION_EXPECTED[8][64] = {
    'content',  // Test 1
    'value',    // Test 2
    'data',     // Test 3
    'text',     // Test 4
    'first',    // Test 5
    'element',  // Test 6
    'simple',   // Test 7
    'root'      // Test 8
}


define_function TestNAVXmlProcessingInstructions() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlProcessingInstructions'")

    InitializeXmlProcessingInstructionTestData()

    for (x = 1; x <= length_array(XML_PROCESSING_INSTRUCTION_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var char result[256]

        if (!NAVXmlParse(XML_PROCESSING_INSTRUCTION_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryString(xml, XML_PROCESSING_INSTRUCTION_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertStringEqual('NAVXmlProcessingInstructions value',
                                  XML_PROCESSING_INSTRUCTION_EXPECTED[x],
                                  result)) {
            NAVLogTestFailed(x,
                            XML_PROCESSING_INSTRUCTION_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlProcessingInstructions'")
}
