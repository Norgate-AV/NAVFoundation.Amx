PROGRAM_NAME='NAVXmlQuery'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_TEST_XML[10][512]
volatile char XML_QUERY_TEST_QUERY[10][64]


define_function InitializeXmlQueryTestData() {
    // Test 1: Root element
    XML_QUERY_TEST_XML[1] = '<person><name>John</name><age>30</age></person>'
    XML_QUERY_TEST_QUERY[1] = '.'

    // Test 2: Nested element
    XML_QUERY_TEST_XML[2] = '<root><user><id>123</id><name>Jane</name></user></root>'
    XML_QUERY_TEST_QUERY[2] = '.user'

    // Test 3: Deeply nested element
    XML_QUERY_TEST_XML[3] = '<root><data><config><settings><timeout>5000</timeout></settings></config></data></root>'
    XML_QUERY_TEST_QUERY[3] = '.data.config.settings'

    // Test 4: Root with single child
    XML_QUERY_TEST_XML[4] = '<items><item>1</item><item>2</item><item>3</item><item>4</item><item>5</item></items>'
    XML_QUERY_TEST_QUERY[4] = '.'

    // Test 5: Multiple child elements
    XML_QUERY_TEST_XML[5] = '<root><items><item><id>1</id></item><item><id>2</id></item><item><id>3</id></item></items></root>'
    XML_QUERY_TEST_QUERY[5] = '.items'

    // Test 6: Element by index
    XML_QUERY_TEST_XML[6] = '<root><person><name>Alice</name><age>25</age></person><person><name>Bob</name><age>30</age></person></root>'
    XML_QUERY_TEST_QUERY[6] = '.person[2]'

    // Test 7: Nested element by index
    XML_QUERY_TEST_XML[7] = '<root><users><user><profile><name>Charlie</name></profile></user><user><profile><name>David</name></profile></user></users></root>'
    XML_QUERY_TEST_QUERY[7] = '.users.user[2].profile'

    // Test 8: Element in nested structure
    XML_QUERY_TEST_XML[8] = '<root><response><data><records><record>10</record><record>20</record><record>30</record></records></data></response></root>'
    XML_QUERY_TEST_QUERY[8] = '.response.data.records'

    // Test 9: Empty element
    XML_QUERY_TEST_XML[9] = '<root><empty></empty></root>'
    XML_QUERY_TEST_QUERY[9] = '.empty'

    // Test 10: Self-closing element
    XML_QUERY_TEST_XML[10] = '<root><empty/></root>'
    XML_QUERY_TEST_QUERY[10] = '.empty'

    set_length_array(XML_QUERY_TEST_XML, 10)
    set_length_array(XML_QUERY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

// Expected node types
constant integer XML_QUERY_EXPECTED_TYPE[10] = {
    NAV_XML_TYPE_ELEMENT,  // Test 1
    NAV_XML_TYPE_ELEMENT,  // Test 2
    NAV_XML_TYPE_ELEMENT,  // Test 3
    NAV_XML_TYPE_ELEMENT,  // Test 4
    NAV_XML_TYPE_ELEMENT,  // Test 5
    NAV_XML_TYPE_ELEMENT,  // Test 6
    NAV_XML_TYPE_ELEMENT,  // Test 7
    NAV_XML_TYPE_ELEMENT,  // Test 8
    NAV_XML_TYPE_ELEMENT,  // Test 9
    NAV_XML_TYPE_ELEMENT   // Test 10
}

// Expected child counts (for validation)
constant integer XML_QUERY_EXPECTED_CHILD_COUNT[10] = {
    2,  // Test 1: <name>, <age>
    2,  // Test 2: <id>, <name>
    1,  // Test 3: <timeout>
    5,  // Test 4: 5 <item> elements
    3,  // Test 5: 3 <item> elements
    2,  // Test 6: <name>, <age>
    1,  // Test 7: <name>
    3,  // Test 8: 3 <record> elements
    0,  // Test 9: empty
    0   // Test 10: self-closing empty
}

// Expected first child tag (for elements)
constant char XML_QUERY_EXPECTED_FIRST_TAG[10][32] = {
    'name',      // Test 1
    'id',        // Test 2
    'timeout',   // Test 3
    'item',      // Test 4
    'item',      // Test 5
    'name',      // Test 6
    'name',      // Test 7
    'record',    // Test 8
    '',          // Test 9 (empty)
    ''           // Test 10 (empty)
}


define_function TestNAVXmlQuery() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQuery'")

    InitializeXmlQueryTestData()

    for (x = 1; x <= length_array(XML_QUERY_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var _NAVXmlNode result
        stack_var _NAVXmlNode firstChild
        stack_var char tagValue[64]

        if (!NAVXmlParse(XML_QUERY_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQuery(xml, XML_QUERY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Validate node type
        if (!NAVXmlIsElement(result)) {
            NAVLogTestFailed(x, 'Node type: ELEMENT', "'Node type: ', NAVXmlGetNodeType(result.type)")
            continue
        }

        // Validate child count
        if (!NAVAssertIntegerEqual('Child count',
                                   XML_QUERY_EXPECTED_CHILD_COUNT[x],
                                   NAVXmlGetChildCount(result))) {
            NAVLogTestFailed(x,
                            "'Expected children: ', itoa(XML_QUERY_EXPECTED_CHILD_COUNT[x])",
                            "'Got children: ', itoa(NAVXmlGetChildCount(result))")
            continue
        }

        // For non-empty elements, validate first child tag
        if (XML_QUERY_EXPECTED_CHILD_COUNT[x] > 0) {

            if (!NAVXmlGetFirstChild(xml, result, firstChild)) {
                NAVLogTestFailed(x, 'Get first child success', 'Get first child failed')
                continue
            }

            tagValue = NAVXmlGetTag(firstChild)
            if (!NAVAssertStringEqual('First child tag',
                                      XML_QUERY_EXPECTED_FIRST_TAG[x],
                                      tagValue)) {
                NAVLogTestFailed(x,
                                XML_QUERY_EXPECTED_FIRST_TAG[x],
                                tagValue)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQuery'")
}
