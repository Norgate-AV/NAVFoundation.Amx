PROGRAM_NAME='NAVXmlNodeHelpers'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_NODE_HELPER_TEST[10][512]


define_function InitializeXmlNodeHelperTestData() {
    // Test 1: Simple element with child elements
    XML_NODE_HELPER_TEST[1] = '<root><a>1</a><b>2</b><c>3</c></root>'

    // Test 2: Simple array of elements
    XML_NODE_HELPER_TEST[2] = '<root><item>A</item><item>B</item><item>C</item></root>'

    // Test 3: Element with nested structure
    XML_NODE_HELPER_TEST[3] = '<root><parent><child1>A</child1><child2>B</child2></parent></root>'

    // Test 4: Element with attributes
    XML_NODE_HELPER_TEST[4] = '<root><element id="123" name="test">value</element></root>'

    // Test 5: Empty element
    XML_NODE_HELPER_TEST[5] = '<root></root>'

    // Test 6: Self-closing element with attributes
    XML_NODE_HELPER_TEST[6] = '<root><item id="1"/><item id="2"/></root>'

    // Test 7: Mixed content
    XML_NODE_HELPER_TEST[7] = '<root><data>text<nested>value</nested></data></root>'

    // Test 8: Multiple levels with attributes
    XML_NODE_HELPER_TEST[8] = '<root id="r"><level1 id="l1"><level2 id="l2">content</level2></level1></root>'

    // Test 9: Large number of siblings
    XML_NODE_HELPER_TEST[9] = '<root><a/><b/><c/><d/><e/><f/><g/><h/><i/><j/></root>'

    // Test 10: Complex nested structure
    XML_NODE_HELPER_TEST[10] = '<root><group1><item>A</item></group1><group2><item>B</item><item>C</item></group2></root>'

    set_length_array(XML_NODE_HELPER_TEST, 10)
}


DEFINE_CONSTANT

// Expected element child counts for root
constant integer XML_NODE_HELPER_EXPECTED_CHILD_COUNT[10] = {
    3,  // Test 1: 3 children (a, b, c)
    3,  // Test 2: 3 items
    1,  // Test 3: 1 child (parent)
    1,  // Test 4: 1 child (element)
    0,  // Test 5: Empty
    2,  // Test 6: 2 items
    1,  // Test 7: 1 child (data)
    1,  // Test 8: 1 child (level1)
    10, // Test 9: 10 siblings
    2   // Test 10: 2 groups
}

// Expected tag names of first child
constant char XML_NODE_HELPER_EXPECTED_FIRST_CHILD_TAG[10][32] = {
    'a',       // Test 1
    'item',    // Test 2
    'parent',  // Test 3
    'element', // Test 4
    '',        // Test 5: No child
    'item',    // Test 6
    'data',    // Test 7
    'level1',  // Test 8
    'a',       // Test 9
    'group1'   // Test 10
}

// Whether first child has attributes
constant char XML_NODE_HELPER_FIRST_CHILD_HAS_ATTRS[10] = {
    false,  // Test 1
    false,  // Test 2
    false,  // Test 3
    true,   // Test 4: element has attributes
    false,  // Test 5: No child
    true,   // Test 6: item has id attribute
    false,  // Test 7
    true,   // Test 8: level1 has id attribute
    false,  // Test 9
    false   // Test 10
}


define_function TestNAVXmlNodeHelpers() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlNodeHelpers'")

    InitializeXmlNodeHelperTestData()

    for (x = 1; x <= length_array(XML_NODE_HELPER_TEST); x++) {
        stack_var _NAVXml xml
        stack_var _NAVXmlNode root
        stack_var _NAVXmlNode firstChild
        stack_var integer childCount
        stack_var char firstChildTag[NAV_XML_PARSER_MAX_ELEMENT_NAME]
        stack_var char hasFirstChild
        stack_var char hasAttrs

        if (!NAVXmlParse(XML_NODE_HELPER_TEST[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlGetRootNode(xml, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        // Test NAVXmlGetElementChildCount
        childCount = NAVXmlGetElementChildCount(xml, root)
        if (!NAVAssertIntegerEqual('NAVXmlGetElementChildCount',
                                    XML_NODE_HELPER_EXPECTED_CHILD_COUNT[x],
                                    childCount)) {
            NAVLogTestFailed(x,
                            itoa(XML_NODE_HELPER_EXPECTED_CHILD_COUNT[x]),
                            itoa(childCount))
            continue
        }

        // Test NAVXmlGetFirstChild
        hasFirstChild = NAVXmlGetFirstChild(xml, root, firstChild)
        if (childCount > 0) {
            if (!hasFirstChild) {
                NAVLogTestFailed(x, 'Get first child', 'Failed')
                continue
            }

            // Test NAVXmlGetTag
            firstChildTag = NAVXmlGetTag(firstChild)
            if (!NAVAssertStringEqual('First child tag',
                                      XML_NODE_HELPER_EXPECTED_FIRST_CHILD_TAG[x],
                                      firstChildTag)) {
                NAVLogTestFailed(x,
                                XML_NODE_HELPER_EXPECTED_FIRST_CHILD_TAG[x],
                                firstChildTag)
                continue
            }

            // Test if first child has attributes
            hasAttrs = (firstChild.firstAttr > 0)
            if (!NAVAssertBooleanEqual('First child has attributes',
                                        XML_NODE_HELPER_FIRST_CHILD_HAS_ATTRS[x],
                                        hasAttrs)) {
                NAVLogTestFailed(x,
                                itoa(XML_NODE_HELPER_FIRST_CHILD_HAS_ATTRS[x]),
                                itoa(hasAttrs))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlNodeHelpers'")
}
