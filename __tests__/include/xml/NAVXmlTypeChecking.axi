PROGRAM_NAME='NAVXmlTypeChecking'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_TYPE_CHECK_TEST[10][256]


define_function InitializeXmlTypeCheckTestData() {
    // Test 1: Element with text content
    XML_TYPE_CHECK_TEST[1] = '<root><element>text</element></root>'

    // Test 2: Element with child elements
    XML_TYPE_CHECK_TEST[2] = '<root><parent><child>value</child></parent></root>'

    // Test 3: Element with attributes
    XML_TYPE_CHECK_TEST[3] = '<root><element id="123">content</element></root>'

    // Test 4: Empty element
    XML_TYPE_CHECK_TEST[4] = '<root><empty></empty></root>'

    // Test 5: Self-closing element
    XML_TYPE_CHECK_TEST[5] = '<root><item/></root>'

    // Test 6: Mixed content (text and elements)
    XML_TYPE_CHECK_TEST[6] = '<root>text<child>value</child></root>'

    // Test 7: Element with CDATA
    XML_TYPE_CHECK_TEST[7] = '<root><data><![CDATA[raw content]]></data></root>'

    // Test 8: Element with comment
    XML_TYPE_CHECK_TEST[8] = '<root><!-- This is a comment --><element>value</element></root>'

    // Test 9: Multiple element types
    XML_TYPE_CHECK_TEST[9] = '<root><a>text</a><b/><c><d>nested</d></c></root>'

    // Test 10: Complex structure
    XML_TYPE_CHECK_TEST[10] = '<root attr="value">text<!-- comment --><child>value</child></root>'

    set_length_array(XML_TYPE_CHECK_TEST, 10)
}


DEFINE_CONSTANT

// Expected results for first child type checks
constant char XML_TYPE_CHECK_FIRST_CHILD_IS_ELEMENT[10] = {
    true,   // Test 1: element is an element
    true,   // Test 2: parent is an element
    true,   // Test 3: element is an element
    true,   // Test 4: empty is an element
    true,   // Test 5: item is an element
    false,  // Test 6: first child is text node
    true,   // Test 7: data is an element
    false,  // Test 8: first child is comment
    true,   // Test 9: a is an element
    false   // Test 10: first child is text node
}

// Whether first child has text content (for elements)
constant char XML_TYPE_CHECK_FIRST_CHILD_HAS_TEXT[10] = {
    true,   // Test 1: "text"
    false,  // Test 2: has child element, not direct text
    true,   // Test 3: "content"
    false,  // Test 4: empty
    false,  // Test 5: empty
    false,  // Test 6: first child is text node itself
    false,  // Test 7: has CDATA child, not direct text
    false,  // Test 8: first child is comment
    true,   // Test 9: "text"
    false   // Test 10: first child is text node itself
}

// Whether first child has child elements (for elements)
constant char XML_TYPE_CHECK_FIRST_CHILD_HAS_CHILDREN[10] = {
    false,  // Test 1: no children
    true,   // Test 2: has child element
    false,  // Test 3: no children
    false,  // Test 4: empty
    false,  // Test 5: empty
    false,  // Test 6: first child is text node
    true,   // Test 7: has CDATA child
    false,  // Test 8: first child is comment
    false,  // Test 9: no children (just text)
    false   // Test 10: first child is text node
}

// Expected tag name of first child (if it's an element)
constant char XML_TYPE_CHECK_FIRST_CHILD_TAG[10][32] = {
    'element',  // Test 1
    'parent',   // Test 2
    'element',  // Test 3
    'empty',    // Test 4
    'item',     // Test 5
    '',         // Test 6: text node has no tag
    'data',     // Test 7
    '',         // Test 8: comment has no tag
    'a',        // Test 9
    ''          // Test 10: text node has no tag
}


define_function TestNAVXmlTypeChecking() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlTypeChecking'")

    InitializeXmlTypeCheckTestData()

    for (x = 1; x <= length_array(XML_TYPE_CHECK_TEST); x++) {
        stack_var _NAVXml xml
        stack_var _NAVXmlNode root
        stack_var _NAVXmlNode firstChild
        stack_var char hasFirstChild
        stack_var char isElement
        stack_var char hasText
        stack_var char hasChildren
        stack_var char tag[NAV_XML_PARSER_MAX_ELEMENT_NAME]

        if (!NAVXmlParse(XML_TYPE_CHECK_TEST[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlGetRootNode(xml, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        // Get first child
        hasFirstChild = NAVXmlGetFirstChild(xml, root, firstChild)
        if (!hasFirstChild) {
            NAVLogTestFailed(x, 'Get first child', 'Failed')
            continue
        }

        // Test NAVXmlIsElement
        isElement = NAVXmlIsElement(firstChild)
        if (!NAVAssertBooleanEqual('NAVXmlIsElement',
                                    XML_TYPE_CHECK_FIRST_CHILD_IS_ELEMENT[x],
                                    isElement)) {
            NAVLogTestFailed(x,
                            itoa(XML_TYPE_CHECK_FIRST_CHILD_IS_ELEMENT[x]),
                            itoa(isElement))
            continue
        }

        // For elements, do additional checks
        if (isElement) {
            // Test NAVXmlGetTag
            tag = NAVXmlGetTag(firstChild)
            if (!NAVAssertStringEqual('Element tag',
                                      XML_TYPE_CHECK_FIRST_CHILD_TAG[x],
                                      tag)) {
                NAVLogTestFailed(x,
                                XML_TYPE_CHECK_FIRST_CHILD_TAG[x],
                                tag)
                continue
            }

            // Test if element has text content (check the node's value member)
            hasText = (firstChild.type == NAV_XML_TYPE_ELEMENT &&
                      length_array(firstChild.value) > 0)

            // Test if element has children
            hasChildren = (NAVXmlGetElementChildCount(xml, firstChild) > 0)
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlTypeChecking'")
}
