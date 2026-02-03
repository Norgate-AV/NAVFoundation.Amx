PROGRAM_NAME='NAVXmlGetParentNode'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_GET_PARENT_NODE_TEST_XML[10][512]
volatile char XML_GET_PARENT_NODE_TEST_QUERY[10][64]


define_function InitializeXmlGetParentNodeTestData() {
    // Test 1: Simple parent-child relationship
    XML_GET_PARENT_NODE_TEST_XML[1] = '<root><child>value</child></root>'
    XML_GET_PARENT_NODE_TEST_QUERY[1] = '.child'

    // Test 2: Multiple levels - get parent of deeply nested node
    XML_GET_PARENT_NODE_TEST_XML[2] = '<root><a><b><c>value</c></b></a></root>'
    XML_GET_PARENT_NODE_TEST_QUERY[2] = '.a.b.c'

    // Test 3: Sibling elements - parent should be same
    XML_GET_PARENT_NODE_TEST_XML[3] = '<root><child1>a</child1><child2>b</child2></root>'
    XML_GET_PARENT_NODE_TEST_QUERY[3] = '.child1'

    // Test 4: Root element (has no parent)
    XML_GET_PARENT_NODE_TEST_XML[4] = '<root>value</root>'
    XML_GET_PARENT_NODE_TEST_QUERY[4] = '.'

    // Test 5: Element with attributes
    XML_GET_PARENT_NODE_TEST_XML[5] = '<root><parent id="1"><child name="test">value</child></parent></root>'
    XML_GET_PARENT_NODE_TEST_QUERY[5] = '.parent.child'

    // Test 6: Multiple children with same name
    XML_GET_PARENT_NODE_TEST_XML[6] = '<root><items><item>A</item><item>B</item></items></root>'
    XML_GET_PARENT_NODE_TEST_QUERY[6] = '.items.item[2]'

    // Test 7: Empty parent element
    XML_GET_PARENT_NODE_TEST_XML[7] = '<root><parent><child>value</child></parent></root>'
    XML_GET_PARENT_NODE_TEST_QUERY[7] = '.parent.child'

    // Test 8: Deep nesting - 5 levels
    XML_GET_PARENT_NODE_TEST_XML[8] = '<root><l1><l2><l3><l4><l5>value</l5></l4></l3></l2></l1></root>'
    XML_GET_PARENT_NODE_TEST_QUERY[8] = '.l1.l2.l3.l4.l5'

    // Test 9: Mixed content - element with text and child
    XML_GET_PARENT_NODE_TEST_XML[9] = '<root><parent>text<child>value</child></parent></root>'
    XML_GET_PARENT_NODE_TEST_QUERY[9] = '.parent.child'

    // Test 10: Query second level element
    XML_GET_PARENT_NODE_TEST_XML[10] = '<root><level1><level2>value</level2></level1></root>'
    XML_GET_PARENT_NODE_TEST_QUERY[10] = '.level1.level2'

    set_length_array(XML_GET_PARENT_NODE_TEST_XML, 10)
    set_length_array(XML_GET_PARENT_NODE_TEST_QUERY, 10)
}


DEFINE_CONSTANT

// Expected parent tag names (empty string if no parent)
constant char XML_GET_PARENT_NODE_EXPECTED_PARENT_TAG[10][32] = {
    'root',    // Test 1: child's parent is root
    'b',       // Test 2: c's parent is b
    'root',    // Test 3: child1's parent is root
    '',        // Test 4: root has no parent
    'parent',  // Test 5: child's parent is parent
    'items',   // Test 6: item[2]'s parent is items
    'parent',  // Test 7: child's parent is parent
    'l4',      // Test 8: l5's parent is l4
    'parent',  // Test 9: child's parent is parent
    'level1'   // Test 10: level2's parent is level1
}

// Whether getting parent should succeed (false only for root)
constant char XML_GET_PARENT_NODE_HAS_PARENT[10] = {
    true,   // Test 1
    true,   // Test 2
    true,   // Test 3
    false,  // Test 4: root has no parent
    true,   // Test 5
    true,   // Test 6
    true,   // Test 7
    true,   // Test 8
    true,   // Test 9
    true    // Test 10
}


define_function TestNAVXmlGetParentNode() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlGetParentNode'")

    InitializeXmlGetParentNodeTestData()

    for (x = 1; x <= length_array(XML_GET_PARENT_NODE_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var _NAVXmlNode node
        stack_var _NAVXmlNode parent
        stack_var char hasParent
        stack_var char parentTag[NAV_XML_PARSER_MAX_ELEMENT_NAME]

        if (!NAVXmlParse(XML_GET_PARENT_NODE_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Query to get the target node
        if (!NAVXmlQuery(xml, XML_GET_PARENT_NODE_TEST_QUERY[x], node)) {
            NAVLogTestFailed(x, 'Query node success', 'Query failed')
            continue
        }

        // Try to get parent node
        hasParent = NAVXmlGetParentNode(xml, node, parent)

        // Test if has parent matches expectation
        if (!NAVAssertBooleanEqual('Has parent',
                                    XML_GET_PARENT_NODE_HAS_PARENT[x],
                                    hasParent)) {
            NAVLogTestFailed(x,
                            itoa(XML_GET_PARENT_NODE_HAS_PARENT[x]),
                            itoa(hasParent))
            continue
        }

        // If should have parent, verify parent tag name
        if (hasParent) {
            parentTag = NAVXmlGetTag(parent)
            if (!NAVAssertStringEqual('Parent tag name',
                                      XML_GET_PARENT_NODE_EXPECTED_PARENT_TAG[x],
                                      parentTag)) {
                NAVLogTestFailed(x,
                                XML_GET_PARENT_NODE_EXPECTED_PARENT_TAG[x],
                                parentTag)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlGetParentNode'")
}
