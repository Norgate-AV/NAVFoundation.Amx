PROGRAM_NAME='NAVXmlValueGetters'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_VALUE_GETTER_TEST[10][512]


define_function InitializeXmlValueGetterTestData() {
    // Test 1: String value
    XML_VALUE_GETTER_TEST[1] = '<root><name>John Doe</name></root>'

    // Test 2: Integer value
    XML_VALUE_GETTER_TEST[2] = '<root><age>42</age></root>'

    // Test 3: Float value
    XML_VALUE_GETTER_TEST[3] = '<root><price>19.99</price></root>'

    // Test 4: Boolean value (true as text)
    XML_VALUE_GETTER_TEST[4] = '<root><active>true</active></root>'

    // Test 5: Boolean value (false as text)
    XML_VALUE_GETTER_TEST[5] = '<root><enabled>false</enabled></root>'

    // Test 6: Element with attribute
    XML_VALUE_GETTER_TEST[6] = '<root><element id="123">content</element></root>'

    // Test 7: Empty text
    XML_VALUE_GETTER_TEST[7] = '<root><text></text></root>'

    // Test 8: Zero number
    XML_VALUE_GETTER_TEST[8] = '<root><count>0</count></root>'

    // Test 9: Negative number
    XML_VALUE_GETTER_TEST[9] = '<root><temperature>-15</temperature></root>'

    // Test 10: Multiple elements
    XML_VALUE_GETTER_TEST[10] = '<root><id>100</id><label>Item A</label><visible>true</visible></root>'

    set_length_array(XML_VALUE_GETTER_TEST, 10)
}


DEFINE_CONSTANT

// Expected string values (text content)
constant char XML_VALUE_GETTER_EXPECTED_STRING[10][64] = {
    'John Doe',  // Test 1
    '42',        // Test 2
    '19.99',     // Test 3
    'true',      // Test 4
    'false',     // Test 5
    'content',   // Test 6
    '',          // Test 7: empty
    '0',         // Test 8
    '-15',       // Test 9
    '100'        // Test 10: first element's value
}

// Expected integer values (when applicable)
constant integer XML_VALUE_GETTER_EXPECTED_INTEGER[10] = {
    0,    // Test 1 (not a number)
    42,   // Test 2
    19,   // Test 3 (truncated)
    0,    // Test 4 (not a number)
    0,    // Test 5 (not a number)
    0,    // Test 6 (not a number)
    0,    // Test 7 (empty)
    0,    // Test 8
    0,    // Test 9 (negative, will be 0 for unsigned)
    100   // Test 10
}

// Expected tag names of first child
constant char XML_VALUE_GETTER_EXPECTED_TAG[10][32] = {
    'name',        // Test 1
    'age',         // Test 2
    'price',       // Test 3
    'active',      // Test 4
    'enabled',     // Test 5
    'element',     // Test 6
    'text',        // Test 7
    'count',       // Test 8
    'temperature', // Test 9
    'id'           // Test 10: first element
}

// Which tests have string values
constant char XML_VALUE_GETTER_HAS_STRING[10] = {
    true,   // Test 1
    true,   // Test 2
    true,   // Test 3
    true,   // Test 4
    true,   // Test 5
    true,   // Test 6
    false,  // Test 7: empty
    true,   // Test 8
    true,   // Test 9
    true    // Test 10
}

// Expected attribute values (for Test 6)
constant char XML_VALUE_GETTER_EXPECTED_ATTR[10][64] = {
    '',     // Test 1: no attributes
    '',     // Test 2: no attributes
    '',     // Test 3: no attributes
    '',     // Test 4: no attributes
    '',     // Test 5: no attributes
    '123',  // Test 6: id="123"
    '',     // Test 7: no attributes
    '',     // Test 8: no attributes
    '',     // Test 9: no attributes
    ''      // Test 10: no attributes
}


define_function TestNAVXmlValueGetters() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlValueGetters'")

    InitializeXmlValueGetterTestData()

    for (x = 1; x <= length_array(XML_VALUE_GETTER_TEST); x++) {
        stack_var _NAVXml xml
        stack_var _NAVXmlNode root
        stack_var _NAVXmlNode firstChild
        stack_var char textContent[NAV_MAX_BUFFER]
        stack_var char tag[NAV_XML_PARSER_MAX_ELEMENT_NAME]
        stack_var char attrValue[NAV_MAX_BUFFER]

        if (!NAVXmlParse(XML_VALUE_GETTER_TEST[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlGetRootNode(xml, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        if (!NAVXmlGetFirstChild(xml, root, firstChild)) {
            NAVLogTestFailed(x, 'Get first child', 'Failed')
            continue
        }

        // Test NAVXmlGetTag
        tag = NAVXmlGetTag(firstChild)
        if (!NAVAssertStringEqual('NAVXmlGetTag',
                                  XML_VALUE_GETTER_EXPECTED_TAG[x],
                                  tag)) {
            NAVLogTestFailed(x,
                            XML_VALUE_GETTER_EXPECTED_TAG[x],
                            tag)
            continue
        }

        // Test text content (element nodes have text as child nodes)
        textContent = ''
        if (firstChild.firstChild > 0) {
            // Element has a child - should be text node
            stack_var _NAVXmlNode textNode
            textNode = xml.nodes[firstChild.firstChild]
            if (textNode.type == NAV_XML_TYPE_TEXT) {
                textContent = textNode.value
            }
        }

        if (XML_VALUE_GETTER_HAS_STRING[x]) {
            if (!NAVAssertStringEqual('Text content',
                                      XML_VALUE_GETTER_EXPECTED_STRING[x],
                                      textContent)) {
                NAVLogTestFailed(x,
                                XML_VALUE_GETTER_EXPECTED_STRING[x],
                                textContent)
                continue
            }
        }

        // Test NAVXmlGetAttribute (for Test 6)
        if (length_array(XML_VALUE_GETTER_EXPECTED_ATTR[x]) > 0) {
            if (!NAVXmlGetAttribute(xml, firstChild, 'id', attrValue)) {
                NAVLogTestFailed(x, 'Get attribute', 'Failed')
                continue
            }
            if (!NAVAssertStringEqual('Attribute value',
                                      XML_VALUE_GETTER_EXPECTED_ATTR[x],
                                      attrValue)) {
                NAVLogTestFailed(x,
                                XML_VALUE_GETTER_EXPECTED_ATTR[x],
                                attrValue)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlValueGetters'")
}
