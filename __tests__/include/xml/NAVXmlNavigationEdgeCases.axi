PROGRAM_NAME='NAVXmlNavigationEdgeCases'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_NAVIGATION_TEST_XML[15][512]


define_function InitializeXmlNavigationEdgeCasesTestData() {
    // Test 1: Single root element with text (no child elements)
    XML_NAVIGATION_TEST_XML[1] = '<root>value</root>'

    // Test 2: Empty element (no children, no text)
    XML_NAVIGATION_TEST_XML[2] = '<root></root>'

    // Test 3: Self-closing empty element
    XML_NAVIGATION_TEST_XML[3] = '<root/>'

    // Test 4: Element with single child
    XML_NAVIGATION_TEST_XML[4] = '<root><child>value</child></root>'

    // Test 5: Element with text and single child element (mixed content)
    XML_NAVIGATION_TEST_XML[5] = '<root>text<child>value</child></root>'

    // Test 6: Multiple sibling elements
    XML_NAVIGATION_TEST_XML[6] = '<root><a>1</a><b>2</b><c>3</c><d>4</d><e>5</e></root>'

    // Test 7: Array of same-named elements
    XML_NAVIGATION_TEST_XML[7] = '<root><item>A</item><item>B</item><item>C</item><item>D</item><item>E</item></root>'

    // Test 8: Mixed sibling types (elements, text, comments)
    XML_NAVIGATION_TEST_XML[8] = '<root>text<!-- comment --><element>value</element></root>'

    // Test 9: Deeply nested single-child chain
    XML_NAVIGATION_TEST_XML[9] = '<root><level1><level2><level3>value</level3></level2></level1></root>'

    // Test 10: Complex tree with multiple children at each level
    XML_NAVIGATION_TEST_XML[10] = '<root><branch1><leaf1>1</leaf1><leaf2>2</leaf2></branch1><branch2><leaf3>3</leaf3><leaf4>4</leaf4></branch2></root>'

    // Test 11: Text before and after child element
    XML_NAVIGATION_TEST_XML[11] = '<root>before<child>value</child>after</root>'

    // Test 12: Multiple text nodes with elements
    XML_NAVIGATION_TEST_XML[12] = '<root>text1<a>A</a>text2<b>B</b>text3</root>'

    // Test 13: Text, comment, and element interleaved
    XML_NAVIGATION_TEST_XML[13] = '<root>start<!-- comment1 --><element>value</element><!-- comment2 -->end</root>'

    // Test 14: Nested mixed content
    XML_NAVIGATION_TEST_XML[14] = '<root><parent>outer<child>inner</child>text</parent></root>'

    // Test 15: Text with whitespace between elements
    XML_NAVIGATION_TEST_XML[15] = '<root>  <a>1</a>  <b>2</b>  <c>3</c>  </root>'

    set_length_array(XML_NAVIGATION_TEST_XML, 15)
}


DEFINE_CONSTANT

// Expected element child count (excludes text nodes, comments, etc.)
constant integer XML_NAVIGATION_EXPECTED_CHILD_COUNT[15] = {
    0,  // Test 1 - text node, no element children
    0,  // Test 2 - empty
    0,  // Test 3 - self-closing empty
    1,  // Test 4 - one child
    1,  // Test 5 - one child element (text doesn't count as element)
    5,  // Test 6 - five siblings
    5,  // Test 7 - five items
    1,  // Test 8 - one element (text and comment don't count)
    1,  // Test 9 - single child at root level
    2,  // Test 10 - two branches
    1,  // Test 11 - one element (text before/after doesn't count)
    2,  // Test 12 - two elements (text between doesn't count)
    1,  // Test 13 - one element (text and comments don't count)
    1,  // Test 14 - one parent element
    3   // Test 15 - three elements (whitespace doesn't count)
}

// Whether root has element children
constant char XML_NAVIGATION_TEST_HAS_CHILDREN[15] = {
    false, // Test 1
    false, // Test 2
    false, // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true,  // Test 8
    true,  // Test 9
    true,  // Test 10
    true,  // Test 11
    true,  // Test 12
    true,  // Test 13
    true,  // Test 14
    true   // Test 15
}

// Whether first child has a next sibling
constant char XML_NAVIGATION_TEST_FIRST_CHILD_HAS_SIBLING[15] = {
    false, // Test 1 - no children
    false, // Test 2 - no children
    false, // Test 3 - no children
    false, // Test 4 - single child
    false, // Test 5 - single child element
    true,  // Test 6 - multiple siblings
    true,  // Test 7 - multiple items
    false, // Test 8 - single element
    false, // Test 9 - single child
    true,  // Test 10 - multiple branches
    false, // Test 11 - single element
    true,  // Test 12 - two elements
    false, // Test 13 - single element
    false, // Test 14 - single parent
    true   // Test 15 - three elements
}


define_function TestNAVXmlNavigationEdgeCases() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlNavigationEdgeCases'")

    InitializeXmlNavigationEdgeCasesTestData()

    for (x = 1; x <= length_array(XML_NAVIGATION_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var _NAVXmlNode root
        stack_var _NAVXmlNode firstChild
        stack_var _NAVXmlNode nextSibling
        stack_var integer childCount
        stack_var char hasChildren
        stack_var char hasFirstChild
        stack_var char firstChildHasSibling

        if (!NAVXmlParse(XML_NAVIGATION_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Get root node
        if (!NAVXmlGetRootNode(xml, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        // Test child count
        childCount = NAVXmlGetElementChildCount(xml, root)
        if (!NAVAssertIntegerEqual('Child count',
                                    XML_NAVIGATION_EXPECTED_CHILD_COUNT[x],
                                    childCount)) {
            NAVLogTestFailed(x,
                            itoa(XML_NAVIGATION_EXPECTED_CHILD_COUNT[x]),
                            itoa(childCount))
            continue
        }

        // Test has children
        hasChildren = (childCount > 0)
        if (!NAVAssertBooleanEqual('Has children',
                                    XML_NAVIGATION_TEST_HAS_CHILDREN[x],
                                    hasChildren)) {
            NAVLogTestFailed(x,
                            itoa(XML_NAVIGATION_TEST_HAS_CHILDREN[x]),
                            itoa(hasChildren))
            continue
        }

        // Test first child and siblings
        hasFirstChild = NAVXmlGetFirstChild(xml, root, firstChild)

        // Skip non-element nodes to find first element child
        while (hasFirstChild && firstChild.type != NAV_XML_TYPE_ELEMENT) {
            hasFirstChild = NAVXmlGetNextSibling(xml, firstChild, firstChild)
        }

        if (hasChildren) {
            if (!hasFirstChild) {
                NAVLogTestFailed(x, 'Get first child', 'Failed to get first child')
                continue
            }

            // Test if first child has sibling (element sibling)
            firstChildHasSibling = NAVXmlGetNextSibling(xml, firstChild, nextSibling)

            // Skip non-element nodes to find next element sibling
            while (firstChildHasSibling && nextSibling.type != NAV_XML_TYPE_ELEMENT) {
                firstChildHasSibling = NAVXmlGetNextSibling(xml, nextSibling, nextSibling)
            }

            if (!NAVAssertBooleanEqual('First child has sibling',
                                        XML_NAVIGATION_TEST_FIRST_CHILD_HAS_SIBLING[x],
                                        firstChildHasSibling)) {
                NAVLogTestFailed(x,
                                itoa(XML_NAVIGATION_TEST_FIRST_CHILD_HAS_SIBLING[x]),
                                itoa(firstChildHasSibling))
                continue
            }
        } else {
            if (hasFirstChild) {
                NAVLogTestFailed(x, 'No first child expected', 'Got first child')
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlNavigationEdgeCases'")
}
