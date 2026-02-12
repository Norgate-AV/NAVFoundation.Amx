PROGRAM_NAME='NAVXmlDeepNesting'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_DEEP_NESTING_TEST_XML[10][1024]
volatile char XML_DEEP_NESTING_TEST_QUERY[10][128]


define_function InitializeXmlDeepNestingTestData() {
    // Test 1: Depth 5 - nested elements
    XML_DEEP_NESTING_TEST_XML[1] = '<root><l1><l2><l3><l4><l5>deep</l5></l4></l3></l2></l1></root>'
    XML_DEEP_NESTING_TEST_QUERY[1] = '.l1.l2.l3.l4.l5'

    // Test 2: Depth 10 - very deep nesting
    XML_DEEP_NESTING_TEST_XML[2] = '<root><l1><l2><l3><l4><l5><l6><l7><l8><l9><l10>deepest</l10></l9></l8></l7></l6></l5></l4></l3></l2></l1></root>'
    XML_DEEP_NESTING_TEST_QUERY[2] = '.l1.l2.l3.l4.l5.l6.l7.l8.l9.l10'

    // Test 3: Depth 15 - extremely deep nesting
    XML_DEEP_NESTING_TEST_XML[3] = '<root><l1><l2><l3><l4><l5><l6><l7><l8><l9><l10><l11><l12><l13><l14><l15>limit</l15></l14></l13></l12></l11></l10></l9></l8></l7></l6></l5></l4></l3></l2></l1></root>'
    XML_DEEP_NESTING_TEST_QUERY[3] = '.l1.l2.l3.l4.l5.l6.l7.l8.l9.l10.l11.l12.l13.l14.l15'

    // Test 4: Mixed nesting with multiple children at each level
    XML_DEEP_NESTING_TEST_XML[4] = '<root><level1><a>1</a><b><c>deep</c></b></level1></root>'
    XML_DEEP_NESTING_TEST_QUERY[4] = '.level1.b.c'

    // Test 5: Deep nesting with attributes
    XML_DEEP_NESTING_TEST_XML[5] = '<root><l1 id="1"><l2 id="2"><l3 id="3">value</l3></l2></l1></root>'
    XML_DEEP_NESTING_TEST_QUERY[5] = '.l1.l2.l3'

    // Test 6: Deep nesting with multiple siblings at leaf
    XML_DEEP_NESTING_TEST_XML[6] = '<root><a><b><c><d>first</d><d>second</d></c></b></a></root>'
    XML_DEEP_NESTING_TEST_QUERY[6] = '.a.b.c.d[1]'

    // Test 7: Query intermediate level
    XML_DEEP_NESTING_TEST_XML[7] = '<root><l1><l2><l3>mid</l3></l2></l1></root>'
    XML_DEEP_NESTING_TEST_QUERY[7] = '.l1.l2'

    // Test 8: Deep nesting with text at multiple levels
    XML_DEEP_NESTING_TEST_XML[8] = '<root><a>outer<b>middle<c>inner</c></b></a></root>'
    XML_DEEP_NESTING_TEST_QUERY[8] = '.a.b.c'

    // Test 9: Depth 7 with indexed access
    XML_DEEP_NESTING_TEST_XML[9] = '<root><l1><l2><l3><l4><l5><l6><item>A</item><item>B</item></l6></l5></l4></l3></l2></l1></root>'
    XML_DEEP_NESTING_TEST_QUERY[9] = '.l1.l2.l3.l4.l5.l6.item[2]'

    // Test 10: Depth 8 with attribute query
    XML_DEEP_NESTING_TEST_XML[10] = '<root><l1><l2><l3><l4><l5><l6><l7><l8 attr="success">content</l8></l7></l6></l5></l4></l3></l2></l1></root>'
    XML_DEEP_NESTING_TEST_QUERY[10] = '.l1.l2.l3.l4.l5.l6.l7.l8@attr'

    set_length_array(XML_DEEP_NESTING_TEST_XML, 10)
    set_length_array(XML_DEEP_NESTING_TEST_QUERY, 10)
}


DEFINE_CONSTANT

// Expected string results for each test
constant char XML_DEEP_NESTING_EXPECTED[10][32] = {
    'deep',       // Test 1: Depth 5
    'deepest',    // Test 2: Depth 10
    'limit',      // Test 3: Depth 15
    'deep',       // Test 4: Mixed nesting
    'value',      // Test 5: With attributes
    'first',      // Test 6: First of siblings
    'mid',        // Test 7: Intermediate level returns descendant text
    'inner',      // Test 8: Text at multiple levels
    'B',          // Test 9: Depth 7 with index
    'success'     // Test 10: Attribute query
}

// Whether each test should succeed
constant char XML_DEEP_NESTING_SUCCESS[10] = {
    true,   // Test 1
    true,   // Test 2
    true,   // Test 3
    true,   // Test 4
    true,   // Test 5
    true,   // Test 6
    true,   // Test 7: Returns descendant text content
    true,   // Test 8
    true,   // Test 9
    true    // Test 10
}


define_function TestNAVXmlDeepNesting() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlDeepNesting'")

    InitializeXmlDeepNestingTestData()

    for (x = 1; x <= length_array(XML_DEEP_NESTING_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var char result[NAV_MAX_BUFFER]
        stack_var char success

        if (!NAVXmlParse(XML_DEEP_NESTING_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        success = NAVXmlQueryString(xml, XML_DEEP_NESTING_TEST_QUERY[x], result)

        if (!NAVAssertBooleanEqual('Query success',
                                    XML_DEEP_NESTING_SUCCESS[x],
                                    success)) {
            NAVLogTestFailed(x,
                            itoa(XML_DEEP_NESTING_SUCCESS[x]),
                            itoa(success))
            continue
        }

        if (success) {
            if (!NAVAssertStringEqual('Queried value',
                                      XML_DEEP_NESTING_EXPECTED[x],
                                      result)) {
                NAVLogTestFailed(x,
                                XML_DEEP_NESTING_EXPECTED[x],
                                result)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlDeepNesting'")
}
