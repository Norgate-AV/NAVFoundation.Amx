PROGRAM_NAME='NAVXmlParse'

// Uncomment to enable detailed tree validation debug logging
// #DEFINE DEBUG_XML_TREE_VALIDATION


DEFINE_VARIABLE

volatile char XML_PARSE_TEST[50][1024]
volatile _NAVXmlNode XML_PARSE_EXPECTED_NODES[50][50]  // Max 50 nodes per test

define_function InitializeXmlParseTestData() {
    // Test 1: Empty element
    XML_PARSE_TEST[1] = '<root/>'

    // Test 2: Simple element with text
    XML_PARSE_TEST[2] = '<root>Hello World</root>'

    // Test 3: Element with single attribute
    XML_PARSE_TEST[3] = '<root id="123"/>'

    // Test 4: Element with text and attribute
    XML_PARSE_TEST[4] = '<root id="123">Hello</root>'

    // Test 5: Nested elements
    XML_PARSE_TEST[5] = '<root><child>Text</child></root>'

    // Test 6: Multiple children
    XML_PARSE_TEST[6] = '<root><child1/><child2/><child3/></root>'

    // Test 7: Element with multiple attributes
    XML_PARSE_TEST[7] = '<root id="123" name="test" value="42"/>'

    // Test 8: Nested elements with attributes
    XML_PARSE_TEST[8] = '<root id="1"><child name="test">Value</child></root>'

    // Test 9: Mixed content (text and elements)
    XML_PARSE_TEST[9] = '<root>Before<child/>After</root>'

    // Test 10: CDATA section
    XML_PARSE_TEST[10] = '<root><![CDATA[<special>content</special>]]></root>'

    // Test 11: Comment (should be preserved)
    XML_PARSE_TEST[11] = '<root><!-- This is a comment --><child/></root>'

    // Test 12: Processing instruction
    XML_PARSE_TEST[12] = '<root><?target data?><child/></root>'

    // Test 13: Deep nesting (5 levels)
    XML_PARSE_TEST[13] = '<l1><l2><l3><l4><l5>Deep</l5></l4></l3></l2></l1>'

    // Test 14: Multiple siblings with text
    XML_PARSE_TEST[14] = '<root><name>John</name><age>30</age><city>NYC</city></root>'

    // Test 15: Entity references
    XML_PARSE_TEST[15] = '<root>Text with &lt;entities&gt; &amp; &quot;quotes&quot;</root>'

    // Test 16: Namespace with prefix
    XML_PARSE_TEST[16] = '<ns:root xmlns:ns="http://example.com"/>'

    // Test 17: Complex structure
    XML_PARSE_TEST[17] = '<root><users><user id="1"><name>John</name><email>john@test.com</email></user><user id="2"><name>Jane</name><email>jane@test.com</email></user></users></root>'

    // Test 18: Empty elements and text
    XML_PARSE_TEST[18] = '<root><empty/><notempty>Text</notempty></root>'

    // Test 19: Whitespace handling
    XML_PARSE_TEST[19] = "'<root>', $0A, $0A, '<child>  Text  </child>', $0A, $0A, '</root>'"

    // Test 20: Mixed content with CDATA and comments
    XML_PARSE_TEST[20] = '<root>Text1<!-- comment --><child><![CDATA[CDATA]]></child>Text2</root>'

    // Test 21: ERROR - Unclosed tag
    XML_PARSE_TEST[21] = '<root><child></root>'

    // Test 22: ERROR - Missing closing bracket
    XML_PARSE_TEST[22] = '<root<child/></root>'

    // Test 23: ERROR - Mismatched tags
    XML_PARSE_TEST[23] = '<root></notroot>'

    // Test 24: ERROR - Invalid attribute syntax
    XML_PARSE_TEST[24] = '<root id=value/>'

    // Test 25: ERROR - Unexpected content after root
    XML_PARSE_TEST[25] = '<root/><extra/>'

    // Test 26: Multiple namespace declarations
    XML_PARSE_TEST[26] = '<root xmlns:a="http://a.com" xmlns:b="http://b.com"><a:child/><b:child/></root>'

    // Test 27: Default namespace
    XML_PARSE_TEST[27] = '<root xmlns="http://default.com"><child/></root>'

    // Test 28: Multiple processing instructions
    XML_PARSE_TEST[28] = '<root><?xml-stylesheet href="style.css"?><?custom data?></root>'

    // Test 29: Processing instructions at different locations
    XML_PARSE_TEST[29] = '<?xml-stylesheet href="s.css"?><root><?target data?></root>'

    // Test 30: Multiple comments
    XML_PARSE_TEST[30] = '<root><!-- comment1 --><!-- comment2 --><child/><!-- comment3 --></root>'

    // Test 31: Adjacent CDATA sections
    XML_PARSE_TEST[31] = '<root><![CDATA[part1]]><![CDATA[part2]]></root>'

    // Test 32: Empty CDATA section
    XML_PARSE_TEST[32] = '<root><![CDATA[]]></root>'

    // Test 33: Empty comment
    XML_PARSE_TEST[33] = '<root><!----></root>'

    // Test 34: Numeric entity references
    XML_PARSE_TEST[34] = '<root>&#65;&#66;&#67;</root>'

    // Test 35: Hex numeric entity references
    XML_PARSE_TEST[35] = '<root>&#x41;&#x42;&#x43;</root>'

    // Test 36: Mixed entity types
    XML_PARSE_TEST[36] = '<root>&lt;tag&gt; &#65; &#x42; &amp;</root>'

    // Test 37: Attributes with entity references
    XML_PARSE_TEST[37] = '<root id="&lt;value&gt;" title="A&amp;B"/>'

    // Test 38: Long element name
    XML_PARSE_TEST[38] = '<VeryLongElementNameToTestParserCapabilities><child/></VeryLongElementNameToTestParserCapabilities>'

    // Test 39: Many attributes
    XML_PARSE_TEST[39] = '<root id="1" name="test" value="123" class="main" style="color:red" data-custom="value"/>'

    // Test 40: Self-closing with namespace
    XML_PARSE_TEST[40] = '<ns:root xmlns:ns="http://test.com"/>'

    // Test 41: Nested namespace redefinition
    XML_PARSE_TEST[41] = '<root xmlns:a="http://a1.com"><child xmlns:a="http://a2.com"><a:item/></child></root>'

    // Test 42: Multiple namespace declarations on one element
    XML_PARSE_TEST[42] = '<root xmlns="http://default.com" xmlns:a="http://a.com" xmlns:b="http://b.com" xmlns:c="http://c.com"/>'

    // Test 43: Complex real-world-like XML (config snippet)
    XML_PARSE_TEST[43] = '<config version="1.0"><server host="localhost" port="8080"><ssl enabled="true"/></server><logging level="debug"/></config>'

    // Test 44: Deeply nested mixed content
    XML_PARSE_TEST[44] = '<a>Text1<b>Text2<c>Text3<d>Text4</d></c></b>Text5</a>'

    // Test 45: Root with all node types as children
    XML_PARSE_TEST[45] = '<root>Text<!-- comment --><?target data?><child/><![CDATA[cdata]]></root>'

    // Test 46: Multiple attributes with special characters
    XML_PARSE_TEST[46] = '<root url="http://example.com/path?a=1&amp;b=2" title="&quot;Quoted&quot;"/>'

    // Test 47: Very long text content
    XML_PARSE_TEST[47] = '<root>This is a very long text content that should be handled correctly by the parser without any issues regardless of length</root>'

    // Test 48: Multiple levels of nesting with attributes
    XML_PARSE_TEST[48] = '<a id="1"><b id="2"><c id="3"><d id="4"/></c></b></a>'

    // Test 49: Mixed content with multiple text nodes
    XML_PARSE_TEST[49] = '<root>Start<a/>Middle1<b/>Middle2<c/>End</root>'

    // Test 50: Complex structure with all features combined
    XML_PARSE_TEST[50] = '<root xmlns:ns="http://ns.com" version="2.0"><!-- Config --><ns:item id="1">Value</ns:item><?process data?><![CDATA[Raw<>Data]]></root>'

    set_length_array(XML_PARSE_TEST, 50)

    InitializeExpectedNodes()
}

define_function InitializeExpectedNodes() {
    // Test 1: <root/>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[1][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[1][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[1][1].childCount = 0

    // Test 2: <root>Hello World</root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[2][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[2][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[2][1].childCount = 1
    // Node 2: text node
    XML_PARSE_EXPECTED_NODES[2][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[2][2].value = 'Hello World'

    // Test 3: <root id="123"/>
    // Node 1: root element with attribute
    XML_PARSE_EXPECTED_NODES[3][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[3][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[3][1].childCount = 0

    // Test 4: <root id="123">Hello</root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[4][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[4][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[4][1].childCount = 1
    // Node 2: text node
    XML_PARSE_EXPECTED_NODES[4][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[4][2].value = 'Hello'

    // Test 5: <root><child>Text</child></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[5][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[5][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[5][1].childCount = 1
    // Node 2: child element
    XML_PARSE_EXPECTED_NODES[5][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[5][2].name = 'child'
    XML_PARSE_EXPECTED_NODES[5][2].childCount = 1
    // Node 3: text node
    XML_PARSE_EXPECTED_NODES[5][3].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[5][3].value = 'Text'

    // Test 6: <root><child1/><child2/><child3/></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[6][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[6][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[6][1].childCount = 3
    // Node 2: child1 element
    XML_PARSE_EXPECTED_NODES[6][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[6][2].name = 'child1'
    XML_PARSE_EXPECTED_NODES[6][2].childCount = 0
    // Node 3: child2 element
    XML_PARSE_EXPECTED_NODES[6][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[6][3].name = 'child2'
    XML_PARSE_EXPECTED_NODES[6][3].childCount = 0
    // Node 4: child3 element
    XML_PARSE_EXPECTED_NODES[6][4].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[6][4].name = 'child3'
    XML_PARSE_EXPECTED_NODES[6][4].childCount = 0

    // Test 7: <root id="123" name="test" value="42"/>
    // Node 1: root element with 3 attributes
    XML_PARSE_EXPECTED_NODES[7][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[7][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[7][1].childCount = 0

    // Test 8: <root id="1"><child name="test">Value</child></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[8][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[8][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[8][1].childCount = 1
    // Node 2: child element
    XML_PARSE_EXPECTED_NODES[8][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[8][2].name = 'child'
    XML_PARSE_EXPECTED_NODES[8][2].childCount = 1
    // Node 3: text node
    XML_PARSE_EXPECTED_NODES[8][3].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[8][3].value = 'Value'

    // Test 9: <root>Before<child/>After</root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[9][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[9][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[9][1].childCount = 3
    // Node 2: text node "Before"
    XML_PARSE_EXPECTED_NODES[9][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[9][2].value = 'Before'
    // Node 3: child element
    XML_PARSE_EXPECTED_NODES[9][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[9][3].name = 'child'
    XML_PARSE_EXPECTED_NODES[9][3].childCount = 0
    // Node 4: text node "After"
    XML_PARSE_EXPECTED_NODES[9][4].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[9][4].value = 'After'

    // Test 10: <root><![CDATA[<special>content</special>]]></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[10][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[10][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[10][1].childCount = 1
    // Node 2: CDATA node
    XML_PARSE_EXPECTED_NODES[10][2].type = NAV_XML_TYPE_CDATA
    XML_PARSE_EXPECTED_NODES[10][2].value = '<special>content</special>'

    // Test 11: <root><!-- This is a comment --><child/></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[11][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[11][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[11][1].childCount = 2
    // Node 2: comment node
    XML_PARSE_EXPECTED_NODES[11][2].type = NAV_XML_TYPE_COMMENT
    XML_PARSE_EXPECTED_NODES[11][2].value = ' This is a comment '
    // Node 3: child element
    XML_PARSE_EXPECTED_NODES[11][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[11][3].name = 'child'
    XML_PARSE_EXPECTED_NODES[11][3].childCount = 0

    // Test 12: <root><?target data?><child/></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[12][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[12][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[12][1].childCount = 2
    // Node 2: PI node (target in name, data in value)
    XML_PARSE_EXPECTED_NODES[12][2].type = NAV_XML_TYPE_PI
    XML_PARSE_EXPECTED_NODES[12][2].name = 'target'
    XML_PARSE_EXPECTED_NODES[12][2].value = 'data'
    // Node 3: child element
    XML_PARSE_EXPECTED_NODES[12][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[12][3].name = 'child'
    XML_PARSE_EXPECTED_NODES[12][3].childCount = 0

    // Test 13: <l1><l2><l3><l4><l5>Deep</l5></l4></l3></l2></l1>
    // Node 1: l1 element
    XML_PARSE_EXPECTED_NODES[13][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[13][1].name = 'l1'
    XML_PARSE_EXPECTED_NODES[13][1].childCount = 1
    // Node 2: l2 element
    XML_PARSE_EXPECTED_NODES[13][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[13][2].name = 'l2'
    XML_PARSE_EXPECTED_NODES[13][2].childCount = 1
    // Node 3: l3 element
    XML_PARSE_EXPECTED_NODES[13][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[13][3].name = 'l3'
    XML_PARSE_EXPECTED_NODES[13][3].childCount = 1
    // Node 4: l4 element
    XML_PARSE_EXPECTED_NODES[13][4].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[13][4].name = 'l4'
    XML_PARSE_EXPECTED_NODES[13][4].childCount = 1
    // Node 5: l5 element
    XML_PARSE_EXPECTED_NODES[13][5].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[13][5].name = 'l5'
    XML_PARSE_EXPECTED_NODES[13][5].childCount = 1
    // Node 6: text node
    XML_PARSE_EXPECTED_NODES[13][6].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[13][6].value = 'Deep'

    // Test 14: <root><name>John</name><age>30</age><city>NYC</city></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[14][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[14][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[14][1].childCount = 3
    // Node 2: name element
    XML_PARSE_EXPECTED_NODES[14][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[14][2].name = 'name'
    XML_PARSE_EXPECTED_NODES[14][2].childCount = 1
    // Node 3: text node "John"
    XML_PARSE_EXPECTED_NODES[14][3].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[14][3].value = 'John'
    // Node 4: age element
    XML_PARSE_EXPECTED_NODES[14][4].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[14][4].name = 'age'
    XML_PARSE_EXPECTED_NODES[14][4].childCount = 1
    // Node 5: text node "30"
    XML_PARSE_EXPECTED_NODES[14][5].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[14][5].value = '30'
    // Node 6: city element
    XML_PARSE_EXPECTED_NODES[14][6].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[14][6].name = 'city'
    XML_PARSE_EXPECTED_NODES[14][6].childCount = 1
    // Node 7: text node "NYC"
    XML_PARSE_EXPECTED_NODES[14][7].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[14][7].value = 'NYC'

    // Test 15: <root>Text with &lt;entities&gt; &amp; &quot;quotes&quot;</root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[15][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[15][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[15][1].childCount = 1
    // Node 2: text node with decoded entities
    XML_PARSE_EXPECTED_NODES[15][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[15][2].value = 'Text with <entities> & "quotes"'

    // Test 16: <ns:root xmlns:ns="http://example.com"/>
    // Node 1: root element with namespace
    XML_PARSE_EXPECTED_NODES[16][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[16][1].name = 'ns:root'
    XML_PARSE_EXPECTED_NODES[16][1].childCount = 0

    // Test 17: Complex structure
    // <root><users><user id="1"><name>John</name><email>john@test.com</email></user><user id="2"><name>Jane</name><email>jane@test.com</email></user></users></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[17][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[17][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[17][1].childCount = 1
    // Node 2: users element
    XML_PARSE_EXPECTED_NODES[17][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[17][2].name = 'users'
    XML_PARSE_EXPECTED_NODES[17][2].childCount = 2
    // Node 3: user element (id="1")
    XML_PARSE_EXPECTED_NODES[17][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[17][3].name = 'user'
    XML_PARSE_EXPECTED_NODES[17][3].childCount = 2
    // Node 4: name element
    XML_PARSE_EXPECTED_NODES[17][4].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[17][4].name = 'name'
    XML_PARSE_EXPECTED_NODES[17][4].childCount = 1
    // Node 5: text node "John"
    XML_PARSE_EXPECTED_NODES[17][5].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[17][5].value = 'John'
    // Node 6: email element
    XML_PARSE_EXPECTED_NODES[17][6].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[17][6].name = 'email'
    XML_PARSE_EXPECTED_NODES[17][6].childCount = 1
    // Node 7: text node "john@test.com"
    XML_PARSE_EXPECTED_NODES[17][7].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[17][7].value = 'john@test.com'
    // Node 8: user element (id="2")
    XML_PARSE_EXPECTED_NODES[17][8].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[17][8].name = 'user'
    XML_PARSE_EXPECTED_NODES[17][8].childCount = 2
    // Node 9: name element
    XML_PARSE_EXPECTED_NODES[17][9].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[17][9].name = 'name'
    XML_PARSE_EXPECTED_NODES[17][9].childCount = 1
    // Node 10: text node "Jane"
    XML_PARSE_EXPECTED_NODES[17][10].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[17][10].value = 'Jane'
    // Node 11: email element
    XML_PARSE_EXPECTED_NODES[17][11].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[17][11].name = 'email'
    XML_PARSE_EXPECTED_NODES[17][11].childCount = 1
    // Node 12: text node "jane@test.com"
    XML_PARSE_EXPECTED_NODES[17][12].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[17][12].value = 'jane@test.com'

    // Test 18: <root><empty/><notempty>Text</notempty></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[18][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[18][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[18][1].childCount = 2
    // Node 2: empty element
    XML_PARSE_EXPECTED_NODES[18][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[18][2].name = 'empty'
    XML_PARSE_EXPECTED_NODES[18][2].childCount = 0
    // Node 3: notempty element
    XML_PARSE_EXPECTED_NODES[18][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[18][3].name = 'notempty'
    XML_PARSE_EXPECTED_NODES[18][3].childCount = 1
    // Node 4: text node "Text"
    XML_PARSE_EXPECTED_NODES[18][4].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[18][4].value = 'Text'

    // Test 19: Whitespace handling - depends on parser implementation
    // <root>  <child>  Text  </child>  </root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[19][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[19][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[19][1].childCount = 1
    // Node 2: child element
    XML_PARSE_EXPECTED_NODES[19][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[19][2].name = 'child'
    XML_PARSE_EXPECTED_NODES[19][2].childCount = 1
    // Node 3: text node "  Text  "
    XML_PARSE_EXPECTED_NODES[19][3].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[19][3].value = '  Text  '

    // Test 20: <root>Text1<!-- comment --><child><![CDATA[CDATA]]></child>Text2</root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[20][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[20][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[20][1].childCount = 4
    // Node 2: text node "Text1"
    XML_PARSE_EXPECTED_NODES[20][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[20][2].value = 'Text1'
    // Node 3: comment node
    XML_PARSE_EXPECTED_NODES[20][3].type = NAV_XML_TYPE_COMMENT
    XML_PARSE_EXPECTED_NODES[20][3].value = ' comment '
    // Node 4: child element
    XML_PARSE_EXPECTED_NODES[20][4].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[20][4].name = 'child'
    XML_PARSE_EXPECTED_NODES[20][4].childCount = 1
    // Node 5: CDATA node
    XML_PARSE_EXPECTED_NODES[20][5].type = NAV_XML_TYPE_CDATA
    XML_PARSE_EXPECTED_NODES[20][5].value = 'CDATA'
    // Node 6: text node "Text2"
    XML_PARSE_EXPECTED_NODES[20][6].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[20][6].value = 'Text2'

    // Test 26: Multiple namespace declarations
    // <root xmlns:a="..." xmlns:b="..."><a:child/><b:child/></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[26][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[26][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[26][1].childCount = 2
    // Node 2: a:child
    XML_PARSE_EXPECTED_NODES[26][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[26][2].name = 'a:child'
    XML_PARSE_EXPECTED_NODES[26][2].childCount = 0
    // Node 3: b:child
    XML_PARSE_EXPECTED_NODES[26][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[26][3].name = 'b:child'
    XML_PARSE_EXPECTED_NODES[26][3].childCount = 0

    // Test 27: Default namespace
    // <root xmlns="..."><child/></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[27][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[27][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[27][1].childCount = 1
    // Node 2: child element
    XML_PARSE_EXPECTED_NODES[27][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[27][2].name = 'child'
    XML_PARSE_EXPECTED_NODES[27][2].childCount = 0

    // Test 28: Multiple processing instructions
    // <root><?xml-stylesheet ...?><?custom data?></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[28][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[28][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[28][1].childCount = 2
    // Node 2: xml-stylesheet PI
    XML_PARSE_EXPECTED_NODES[28][2].type = NAV_XML_TYPE_PI
    XML_PARSE_EXPECTED_NODES[28][2].name = 'xml-stylesheet'
    XML_PARSE_EXPECTED_NODES[28][2].value = 'href="style.css"'
    // Node 3: custom PI
    XML_PARSE_EXPECTED_NODES[28][3].type = NAV_XML_TYPE_PI
    XML_PARSE_EXPECTED_NODES[28][3].name = 'custom'
    XML_PARSE_EXPECTED_NODES[28][3].value = 'data'

    // Test 29: PI at different locations (prolog + inside root)
    // <?xml-stylesheet ...?><root><?target data?></root>
    // Node 1: xml-stylesheet PI (prolog)
    XML_PARSE_EXPECTED_NODES[29][1].type = NAV_XML_TYPE_PI
    XML_PARSE_EXPECTED_NODES[29][1].name = 'xml-stylesheet'
    XML_PARSE_EXPECTED_NODES[29][1].value = 'href="s.css"'
    // Node 2: root element
    XML_PARSE_EXPECTED_NODES[29][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[29][2].name = 'root'
    XML_PARSE_EXPECTED_NODES[29][2].childCount = 1
    // Node 3: target PI inside root
    XML_PARSE_EXPECTED_NODES[29][3].type = NAV_XML_TYPE_PI
    XML_PARSE_EXPECTED_NODES[29][3].name = 'target'
    XML_PARSE_EXPECTED_NODES[29][3].value = 'data'

    // Test 30: Multiple comments
    // <root><!-- c1 --><!-- c2 --><child/><!-- c3 --></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[30][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[30][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[30][1].childCount = 4
    // Node 2: comment1
    XML_PARSE_EXPECTED_NODES[30][2].type = NAV_XML_TYPE_COMMENT
    XML_PARSE_EXPECTED_NODES[30][2].value = ' comment1 '
    // Node 3: comment2
    XML_PARSE_EXPECTED_NODES[30][3].type = NAV_XML_TYPE_COMMENT
    XML_PARSE_EXPECTED_NODES[30][3].value = ' comment2 '
    // Node 4: child element
    XML_PARSE_EXPECTED_NODES[30][4].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[30][4].name = 'child'
    XML_PARSE_EXPECTED_NODES[30][4].childCount = 0
    // Node 5: comment3
    XML_PARSE_EXPECTED_NODES[30][5].type = NAV_XML_TYPE_COMMENT
    XML_PARSE_EXPECTED_NODES[30][5].value = ' comment3 '

    // Test 31: Adjacent CDATA sections
    // <root><![CDATA[part1]]><![CDATA[part2]]></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[31][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[31][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[31][1].childCount = 2
    // Node 2: CDATA part1
    XML_PARSE_EXPECTED_NODES[31][2].type = NAV_XML_TYPE_CDATA
    XML_PARSE_EXPECTED_NODES[31][2].value = 'part1'
    // Node 3: CDATA part2
    XML_PARSE_EXPECTED_NODES[31][3].type = NAV_XML_TYPE_CDATA
    XML_PARSE_EXPECTED_NODES[31][3].value = 'part2'

    // Test 32: Empty CDATA section
    // <root><![CDATA[]]></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[32][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[32][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[32][1].childCount = 1
    // Node 2: empty CDATA
    XML_PARSE_EXPECTED_NODES[32][2].type = NAV_XML_TYPE_CDATA
    XML_PARSE_EXPECTED_NODES[32][2].value = ''

    // Test 33: Empty comment
    // <root><!----></root>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[33][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[33][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[33][1].childCount = 1
    // Node 2: empty comment
    XML_PARSE_EXPECTED_NODES[33][2].type = NAV_XML_TYPE_COMMENT
    XML_PARSE_EXPECTED_NODES[33][2].value = ''

    // Test 34: Numeric entity references &#65;&#66;&#67; = ABC
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[34][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[34][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[34][1].childCount = 1
    // Node 2: text "ABC"
    XML_PARSE_EXPECTED_NODES[34][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[34][2].value = 'ABC'

    // Test 35: Hex numeric entity references &#x41;&#x42;&#x43; = ABC
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[35][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[35][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[35][1].childCount = 1
    // Node 2: text "ABC"
    XML_PARSE_EXPECTED_NODES[35][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[35][2].value = 'ABC'

    // Test 36: Mixed entity types
    // <root>&lt;tag&gt; &#65; &#x42; &amp;</root> = "<tag> A B &"
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[36][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[36][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[36][1].childCount = 1
    // Node 2: text
    XML_PARSE_EXPECTED_NODES[36][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[36][2].value = '<tag> A B &'

    // Test 37: Attributes with entity references
    // <root id="&lt;value&gt;" title="A&amp;B"/>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[37][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[37][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[37][1].childCount = 0

    // Test 38: Long element name
    // Node 1: VeryLongElementNameToTestParserCapabilities
    XML_PARSE_EXPECTED_NODES[38][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[38][1].name = 'VeryLongElementNameToTestParserCapabilities'
    XML_PARSE_EXPECTED_NODES[38][1].childCount = 1
    // Node 2: child
    XML_PARSE_EXPECTED_NODES[38][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[38][2].name = 'child'
    XML_PARSE_EXPECTED_NODES[38][2].childCount = 0

    // Test 39: Many attributes
    // <root id="1" name="test" value="123" class="main" style="color:red" data-custom="value"/>
    // Node 1: root element
    XML_PARSE_EXPECTED_NODES[39][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[39][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[39][1].childCount = 0

    // Test 40: Self-closing with namespace
    // <ns:root xmlns:ns="..."/>
    // Node 1: ns:root element
    XML_PARSE_EXPECTED_NODES[40][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[40][1].name = 'ns:root'
    XML_PARSE_EXPECTED_NODES[40][1].childCount = 0

    // Test 41: Nested namespace redefinition
    // <root xmlns:a="http://a1.com"><child xmlns:a="http://a2.com"><a:item/></child></root>
    // Node 1: root
    XML_PARSE_EXPECTED_NODES[41][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[41][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[41][1].childCount = 1
    // Node 2: child
    XML_PARSE_EXPECTED_NODES[41][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[41][2].name = 'child'
    XML_PARSE_EXPECTED_NODES[41][2].childCount = 1
    // Node 3: a:item
    XML_PARSE_EXPECTED_NODES[41][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[41][3].name = 'a:item'
    XML_PARSE_EXPECTED_NODES[41][3].childCount = 0

    // Test 42: Multiple namespace declarations on one element
    // <root xmlns="..." xmlns:a="..." xmlns:b="..." xmlns:c="..."/>
    // Node 1: root
    XML_PARSE_EXPECTED_NODES[42][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[42][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[42][1].childCount = 0

    // Test 43: Config XML
    // <config version="1.0"><server host="localhost" port="8080"><ssl enabled="true"/></server><logging level="debug"/></config>
    // Node 1: config
    XML_PARSE_EXPECTED_NODES[43][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[43][1].name = 'config'
    XML_PARSE_EXPECTED_NODES[43][1].childCount = 2
    // Node 2: server
    XML_PARSE_EXPECTED_NODES[43][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[43][2].name = 'server'
    XML_PARSE_EXPECTED_NODES[43][2].childCount = 1
    // Node 3: ssl
    XML_PARSE_EXPECTED_NODES[43][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[43][3].name = 'ssl'
    XML_PARSE_EXPECTED_NODES[43][3].childCount = 0
    // Node 4: logging
    XML_PARSE_EXPECTED_NODES[43][4].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[43][4].name = 'logging'
    XML_PARSE_EXPECTED_NODES[43][4].childCount = 0

    // Test 44: Deeply nested mixed content
    // <a>Text1<b>Text2<c>Text3<d>Text4</d></c></b>Text5</a>
    // Node 1: a
    XML_PARSE_EXPECTED_NODES[44][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[44][1].name = 'a'
    XML_PARSE_EXPECTED_NODES[44][1].childCount = 3
    // Node 2: Text1
    XML_PARSE_EXPECTED_NODES[44][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[44][2].value = 'Text1'
    // Node 3: b
    XML_PARSE_EXPECTED_NODES[44][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[44][3].name = 'b'
    XML_PARSE_EXPECTED_NODES[44][3].childCount = 2
    // Node 4: Text2
    XML_PARSE_EXPECTED_NODES[44][4].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[44][4].value = 'Text2'
    // Node 5: c
    XML_PARSE_EXPECTED_NODES[44][5].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[44][5].name = 'c'
    XML_PARSE_EXPECTED_NODES[44][5].childCount = 2
    // Node 6: Text3
    XML_PARSE_EXPECTED_NODES[44][6].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[44][6].value = 'Text3'
    // Node 7: d
    XML_PARSE_EXPECTED_NODES[44][7].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[44][7].name = 'd'
    XML_PARSE_EXPECTED_NODES[44][7].childCount = 1
    // Node 8: Text4
    XML_PARSE_EXPECTED_NODES[44][8].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[44][8].value = 'Text4'
    // Node 9: Text5
    XML_PARSE_EXPECTED_NODES[44][9].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[44][9].value = 'Text5'

    // Test 45: Root with all node types
    // <root>Text<!-- comment --><?target data?><child/><![CDATA[cdata]]></root>
    // Node 1: root
    XML_PARSE_EXPECTED_NODES[45][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[45][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[45][1].childCount = 5
    // Node 2: Text
    XML_PARSE_EXPECTED_NODES[45][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[45][2].value = 'Text'
    // Node 3: comment
    XML_PARSE_EXPECTED_NODES[45][3].type = NAV_XML_TYPE_COMMENT
    XML_PARSE_EXPECTED_NODES[45][3].value = ' comment '
    // Node 4: PI
    XML_PARSE_EXPECTED_NODES[45][4].type = NAV_XML_TYPE_PI
    XML_PARSE_EXPECTED_NODES[45][4].name = 'target'
    XML_PARSE_EXPECTED_NODES[45][4].value = 'data'
    // Node 5: child
    XML_PARSE_EXPECTED_NODES[45][5].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[45][5].name = 'child'
    XML_PARSE_EXPECTED_NODES[45][5].childCount = 0
    // Node 6: CDATA
    XML_PARSE_EXPECTED_NODES[45][6].type = NAV_XML_TYPE_CDATA
    XML_PARSE_EXPECTED_NODES[45][6].value = 'cdata'

    // Test 46: Attributes with special characters
    // <root url="http://example.com/path?a=1&amp;b=2" title="&quot;Quoted&quot;"/>
    // Node 1: root
    XML_PARSE_EXPECTED_NODES[46][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[46][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[46][1].childCount = 0

    // Test 47: Very long text
    // Node 1: root
    XML_PARSE_EXPECTED_NODES[47][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[47][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[47][1].childCount = 1
    // Node 2: long text
    XML_PARSE_EXPECTED_NODES[47][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[47][2].value = 'This is a very long text content that should be handled correctly by the parser without any issues regardless of length'

    // Test 48: Multiple levels with attributes
    // <a id="1"><b id="2"><c id="3"><d id="4"/></c></b></a>
    // Node 1: a
    XML_PARSE_EXPECTED_NODES[48][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[48][1].name = 'a'
    XML_PARSE_EXPECTED_NODES[48][1].childCount = 1
    // Node 2: b
    XML_PARSE_EXPECTED_NODES[48][2].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[48][2].name = 'b'
    XML_PARSE_EXPECTED_NODES[48][2].childCount = 1
    // Node 3: c
    XML_PARSE_EXPECTED_NODES[48][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[48][3].name = 'c'
    XML_PARSE_EXPECTED_NODES[48][3].childCount = 1
    // Node 4: d
    XML_PARSE_EXPECTED_NODES[48][4].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[48][4].name = 'd'
    XML_PARSE_EXPECTED_NODES[48][4].childCount = 0

    // Test 49: Mixed content with multiple text nodes
    // <root>Start<a/>Middle1<b/>Middle2<c/>End</root>
    // Node 1: root
    XML_PARSE_EXPECTED_NODES[49][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[49][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[49][1].childCount = 7
    // Node 2: Start
    XML_PARSE_EXPECTED_NODES[49][2].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[49][2].value = 'Start'
    // Node 3: a
    XML_PARSE_EXPECTED_NODES[49][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[49][3].name = 'a'
    XML_PARSE_EXPECTED_NODES[49][3].childCount = 0
    // Node 4: Middle1
    XML_PARSE_EXPECTED_NODES[49][4].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[49][4].value = 'Middle1'
    // Node 5: b
    XML_PARSE_EXPECTED_NODES[49][5].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[49][5].name = 'b'
    XML_PARSE_EXPECTED_NODES[49][5].childCount = 0
    // Node 6: Middle2
    XML_PARSE_EXPECTED_NODES[49][6].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[49][6].value = 'Middle2'
    // Node 7: c
    XML_PARSE_EXPECTED_NODES[49][7].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[49][7].name = 'c'
    XML_PARSE_EXPECTED_NODES[49][7].childCount = 0
    // Node 8: End
    XML_PARSE_EXPECTED_NODES[49][8].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[49][8].value = 'End'

    // Test 50: Complex structure with all features
    // <root xmlns:ns="..." version="2.0"><!-- Config --><ns:item id="1">Value</ns:item><?process data?><![CDATA[Raw<>Data]]></root>
    // Node 1: root
    XML_PARSE_EXPECTED_NODES[50][1].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[50][1].name = 'root'
    XML_PARSE_EXPECTED_NODES[50][1].childCount = 4
    // Node 2: comment
    XML_PARSE_EXPECTED_NODES[50][2].type = NAV_XML_TYPE_COMMENT
    XML_PARSE_EXPECTED_NODES[50][2].value = ' Config '
    // Node 3: ns:item
    XML_PARSE_EXPECTED_NODES[50][3].type = NAV_XML_TYPE_ELEMENT
    XML_PARSE_EXPECTED_NODES[50][3].name = 'ns:item'
    XML_PARSE_EXPECTED_NODES[50][3].childCount = 1
    // Node 4: Value
    XML_PARSE_EXPECTED_NODES[50][4].type = NAV_XML_TYPE_TEXT
    XML_PARSE_EXPECTED_NODES[50][4].value = 'Value'
    // Node 5: PI
    XML_PARSE_EXPECTED_NODES[50][5].type = NAV_XML_TYPE_PI
    XML_PARSE_EXPECTED_NODES[50][5].name = 'process'
    XML_PARSE_EXPECTED_NODES[50][5].value = 'data'
    // Node 6: CDATA
    XML_PARSE_EXPECTED_NODES[50][6].type = NAV_XML_TYPE_CDATA
    XML_PARSE_EXPECTED_NODES[50][6].value = 'Raw<>Data'

    // Set the length of each test's expected nodes array
    set_length_array(XML_PARSE_EXPECTED_NODES[1], 1)
    set_length_array(XML_PARSE_EXPECTED_NODES[2], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[3], 1)
    set_length_array(XML_PARSE_EXPECTED_NODES[4], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[5], 3)
    set_length_array(XML_PARSE_EXPECTED_NODES[6], 4)
    set_length_array(XML_PARSE_EXPECTED_NODES[7], 1)
    set_length_array(XML_PARSE_EXPECTED_NODES[8], 3)
    set_length_array(XML_PARSE_EXPECTED_NODES[9], 4)
    set_length_array(XML_PARSE_EXPECTED_NODES[10], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[11], 3)
    set_length_array(XML_PARSE_EXPECTED_NODES[12], 3)
    set_length_array(XML_PARSE_EXPECTED_NODES[13], 6)
    set_length_array(XML_PARSE_EXPECTED_NODES[14], 7)
    set_length_array(XML_PARSE_EXPECTED_NODES[15], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[16], 1)
    set_length_array(XML_PARSE_EXPECTED_NODES[17], 12)
    set_length_array(XML_PARSE_EXPECTED_NODES[18], 4)
    set_length_array(XML_PARSE_EXPECTED_NODES[19], 3)
    set_length_array(XML_PARSE_EXPECTED_NODES[20], 6)
    // Tests 21-25 are error cases - no expected nodes
    set_length_array(XML_PARSE_EXPECTED_NODES[26], 3)
    set_length_array(XML_PARSE_EXPECTED_NODES[27], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[28], 3)
    set_length_array(XML_PARSE_EXPECTED_NODES[29], 3)
    set_length_array(XML_PARSE_EXPECTED_NODES[30], 5)
    set_length_array(XML_PARSE_EXPECTED_NODES[31], 3)
    set_length_array(XML_PARSE_EXPECTED_NODES[32], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[33], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[34], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[35], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[36], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[37], 1)
    set_length_array(XML_PARSE_EXPECTED_NODES[38], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[39], 1)
    set_length_array(XML_PARSE_EXPECTED_NODES[40], 1)
    set_length_array(XML_PARSE_EXPECTED_NODES[41], 3)
    set_length_array(XML_PARSE_EXPECTED_NODES[42], 1)
    set_length_array(XML_PARSE_EXPECTED_NODES[43], 4)
    set_length_array(XML_PARSE_EXPECTED_NODES[44], 9)
    set_length_array(XML_PARSE_EXPECTED_NODES[45], 6)
    set_length_array(XML_PARSE_EXPECTED_NODES[46], 1)
    set_length_array(XML_PARSE_EXPECTED_NODES[47], 2)
    set_length_array(XML_PARSE_EXPECTED_NODES[48], 4)
    set_length_array(XML_PARSE_EXPECTED_NODES[49], 8)
    set_length_array(XML_PARSE_EXPECTED_NODES[50], 6)

    set_length_array(XML_PARSE_EXPECTED_NODES, 50)
}


DEFINE_CONSTANT

constant char XML_PARSE_EXPECTED_RESULT[50] = {
    true,   // Test 1: Empty element
    true,   // Test 2: Element with text
    true,   // Test 3: Element with attribute
    true,   // Test 4: Element with text and attribute
    true,   // Test 5: Nested elements
    true,   // Test 6: Multiple children
    true,   // Test 7: Multiple attributes
    true,   // Test 8: Nested with attributes
    true,   // Test 9: Mixed content
    true,   // Test 10: CDATA section
    true,   // Test 11: Comment
    true,   // Test 12: Processing instruction
    true,   // Test 13: Deep nesting
    true,   // Test 14: Multiple siblings with text
    true,   // Test 15: Entity references
    true,   // Test 16: Namespace
    true,   // Test 17: Complex structure
    true,   // Test 18: Empty elements and text
    true,   // Test 19: Whitespace handling
    true,   // Test 20: Mixed content with CDATA and comments
    false,  // Test 21: Invalid - unclosed tag
    false,  // Test 22: Invalid - missing bracket
    false,  // Test 23: Invalid - mismatched tags
    false,  // Test 24: Invalid - attribute syntax
    false,  // Test 25: Invalid - extra content
    true,   // Test 26: Multiple namespace declarations
    true,   // Test 27: Default namespace
    true,   // Test 28: Multiple processing instructions
    true,   // Test 29: PI at different locations
    true,   // Test 30: Multiple comments
    true,   // Test 31: Adjacent CDATA sections
    true,   // Test 32: Empty CDATA
    true,   // Test 33: Empty comment
    true,   // Test 34: Numeric entity references
    true,   // Test 35: Hex numeric entity references
    true,   // Test 36: Mixed entity types
    true,   // Test 37: Attributes with entity references
    true,   // Test 38: Long element name
    true,   // Test 39: Many attributes
    true,   // Test 40: Self-closing with namespace
    true,   // Test 41: Nested namespace redefinition
    true,   // Test 42: Multiple namespace declarations on one element
    true,   // Test 43: Config XML
    true,   // Test 44: Deeply nested mixed content
    true,   // Test 45: Root with all node types
    true,   // Test 46: Attributes with special characters
    true,   // Test 47: Very long text
    true,   // Test 48: Multiple levels with attributes
    true,   // Test 49: Mixed content with multiple text nodes
    true    // Test 50: Complex structure with all features
}

constant integer XML_PARSE_EXPECTED_NODE_COUNT[50] = {
    1,      // Test 1: <root/> = 1 node
    2,      // Test 2: <root>text</root> = 2 nodes (element + text)
    1,      // Test 3: <root id="123"/> = 1 node
    2,      // Test 4: <root id="123">Hello</root> = 2 nodes
    3,      // Test 5: <root><child>Text</child></root> = 3 nodes
    4,      // Test 6: <root><child1/><child2/><child3/></root> = 4 nodes
    1,      // Test 7: <root id="123" name="test" value="42"/> = 1 node
    3,      // Test 8: <root id="1"><child name="test">Value</child></root> = 3 nodes
    4,      // Test 9: <root>Before<child/>After</root> = 4 nodes (root + text + child + text)
    2,      // Test 10: <root><![CDATA[...]]></root> = 2 nodes (root + CDATA)
    3,      // Test 11: <root><!-- comment --><child/></root> = 3 nodes
    3,      // Test 12: <root><?target data?><child/></root> = 3 nodes
    6,      // Test 13: Deep nesting 5 levels = 6 nodes (5 elements + 1 text)
    7,      // Test 14: <root><name>John</name><age>30</age><city>NYC</city></root> = 7 nodes
    2,      // Test 15: <root>Text with entities</root> = 2 nodes
    1,      // Test 16: <ns:root xmlns:ns="..."/> = 1 node
    12,     // Test 17: Complex structure = 12 nodes
    4,      // Test 18: <root><empty/><notempty>Text</notempty></root> = 4 nodes
    3,      // Test 19: <root><child>Text</child></root> = 3 nodes (with whitespace)
    6,      // Test 20: Mixed content with CDATA and comments = 6 nodes
    0,      // Test 21: Error case
    0,      // Test 22: Error case
    0,      // Test 23: Error case
    0,      // Test 24: Error case
    0,      // Test 25: Error case
    3,      // Test 26: Multiple namespaces = 3 nodes
    2,      // Test 27: Default namespace = 2 nodes
    3,      // Test 28: Multiple PIs = 3 nodes
    3,      // Test 29: PI locations = 3 nodes (1 prolog PI + root + 1 inner PI)
    5,      // Test 30: Multiple comments = 5 nodes
    3,      // Test 31: Adjacent CDATA = 3 nodes
    2,      // Test 32: Empty CDATA = 2 nodes
    2,      // Test 33: Empty comment = 2 nodes
    2,      // Test 34: Numeric entities = 2 nodes
    2,      // Test 35: Hex entities = 2 nodes
    2,      // Test 36: Mixed entities = 2 nodes
    1,      // Test 37: Attributes with entities = 1 node
    2,      // Test 38: Long element name = 2 nodes
    1,      // Test 39: Many attributes = 1 node
    1,      // Test 40: Self-closing namespace = 1 node
    3,      // Test 41: Nested namespace redef = 3 nodes
    1,      // Test 42: Multiple xmlns on one element = 1 node
    4,      // Test 43: Config XML = 4 nodes
    9,      // Test 44: Deeply nested mixed = 9 nodes
    6,      // Test 45: All node types = 6 nodes
    1,      // Test 46: Attributes with special chars = 1 node
    2,      // Test 47: Long text = 2 nodes
    4,      // Test 48: Multiple levels with attrs = 4 nodes
    8,      // Test 49: Multiple text nodes = 8 nodes
    6       // Test 50: Complex all features = 6 nodes
}

constant integer XML_PARSE_EXPECTED_ROOT_TYPE[50] = {
    NAV_XML_TYPE_ELEMENT,      // Test 1
    NAV_XML_TYPE_ELEMENT,      // Test 2
    NAV_XML_TYPE_ELEMENT,      // Test 3
    NAV_XML_TYPE_ELEMENT,      // Test 4
    NAV_XML_TYPE_ELEMENT,      // Test 5
    NAV_XML_TYPE_ELEMENT,      // Test 6
    NAV_XML_TYPE_ELEMENT,      // Test 7
    NAV_XML_TYPE_ELEMENT,      // Test 8
    NAV_XML_TYPE_ELEMENT,      // Test 9
    NAV_XML_TYPE_ELEMENT,      // Test 10
    NAV_XML_TYPE_ELEMENT,      // Test 11
    NAV_XML_TYPE_ELEMENT,      // Test 12
    NAV_XML_TYPE_ELEMENT,      // Test 13
    NAV_XML_TYPE_ELEMENT,      // Test 14
    NAV_XML_TYPE_ELEMENT,      // Test 15
    NAV_XML_TYPE_ELEMENT,      // Test 16
    NAV_XML_TYPE_ELEMENT,      // Test 17
    NAV_XML_TYPE_ELEMENT,      // Test 18
    NAV_XML_TYPE_ELEMENT,      // Test 19
    NAV_XML_TYPE_ELEMENT,      // Test 20
    0,                              // Test 21: Error
    0,                              // Test 22: Error
    0,                              // Test 23: Error
    0,                              // Test 24: Error
    0,                              // Test 25: Error
    NAV_XML_TYPE_ELEMENT,      // Test 26
    NAV_XML_TYPE_ELEMENT,      // Test 27
    NAV_XML_TYPE_ELEMENT,      // Test 28
    NAV_XML_TYPE_ELEMENT,      // Test 29
    NAV_XML_TYPE_ELEMENT,      // Test 30
    NAV_XML_TYPE_ELEMENT,      // Test 31
    NAV_XML_TYPE_ELEMENT,      // Test 32
    NAV_XML_TYPE_ELEMENT,      // Test 33
    NAV_XML_TYPE_ELEMENT,      // Test 34
    NAV_XML_TYPE_ELEMENT,      // Test 35
    NAV_XML_TYPE_ELEMENT,      // Test 36
    NAV_XML_TYPE_ELEMENT,      // Test 37
    NAV_XML_TYPE_ELEMENT,      // Test 38
    NAV_XML_TYPE_ELEMENT,      // Test 39
    NAV_XML_TYPE_ELEMENT,      // Test 40
    NAV_XML_TYPE_ELEMENT,      // Test 41
    NAV_XML_TYPE_ELEMENT,      // Test 42
    NAV_XML_TYPE_ELEMENT,      // Test 43
    NAV_XML_TYPE_ELEMENT,      // Test 44
    NAV_XML_TYPE_ELEMENT,      // Test 45
    NAV_XML_TYPE_ELEMENT,      // Test 46
    NAV_XML_TYPE_ELEMENT,      // Test 47
    NAV_XML_TYPE_ELEMENT,      // Test 48
    NAV_XML_TYPE_ELEMENT,      // Test 49
    NAV_XML_TYPE_ELEMENT       // Test 50
}

constant integer XML_PARSE_EXPECTED_ROOT_CHILD_COUNT[50] = {
    0,      // Test 1: <root/> = 0 children
    1,      // Test 2: <root>text</root> = 1 child (text node)
    0,      // Test 3: <root id="123"/> = 0 children
    1,      // Test 4: <root id="123">Hello</root> = 1 child (text)
    1,      // Test 5: <root><child>...</child></root> = 1 child
    3,      // Test 6: <root><child1/><child2/><child3/></root> = 3 children
    0,      // Test 7: <root id="..." name="..." value="..."/> = 0 children
    1,      // Test 8: <root id="1"><child>...</child></root> = 1 child
    3,      // Test 9: <root>Before<child/>After</root> = 3 children (text + elem + text)
    1,      // Test 10: <root><![CDATA[...]]></root> = 1 child (CDATA)
    2,      // Test 11: <root><!-- comment --><child/></root> = 2 children
    2,      // Test 12: <root><?target data?><child/></root> = 2 children
    1,      // Test 13: <l1><l2>...</l2></l1> = 1 child
    3,      // Test 14: <root><name>...</name><age>...</age><city>...</city></root> = 3 children
    1,      // Test 15: <root>Text...</root> = 1 child (text)
    0,      // Test 16: <ns:root xmlns:ns="..."/> = 0 children
    1,      // Test 17: <root><users>...</users></root> = 1 child
    2,      // Test 18: <root><empty/><notempty>...</notempty></root> = 2 children
    1,      // Test 19: <root><child>...</child></root> = 1 child
    4,      // Test 20: <root>Text1<!-- comment --><child>...</child>Text2</root> = 4 children (CDATA is child of <child>)
    0,      // Test 21: Error
    0,      // Test 22: Error
    0,      // Test 23: Error
    0,      // Test 24: Error
    0,      // Test 25: Error
    2,      // Test 26: <root xmlns:a="..." xmlns:b="..."><a:child/><b:child/></root> = 2 children
    1,      // Test 27: <root xmlns="..."><child/></root> = 1 child
    2,      // Test 28: <root><?pi1 data1?><?pi2 data2?></root> = 2 children (PIs)
    1,      // Test 29: <?xml-stylesheet ...?><root><?target data?></root> = 1 child (PI inside root)
    4,      // Test 30: <root><!-- c1 --><!-- c2 --><child/><!-- c3 --></root> = 4 children
    2,      // Test 31: <root><![CDATA[First]]><![CDATA[Second]]></root> = 2 children
    1,      // Test 32: <root><![CDATA[]]></root> = 1 child (empty CDATA)
    1,      // Test 33: <root><!----></root> = 1 child (empty comment)
    1,      // Test 34: <root>&#65;&#66;&#67;</root> = 1 child (text "ABC")
    1,      // Test 35: <root>&#x41;&#x42;&#x43;</root> = 1 child (text "ABC")
    1,      // Test 36: <root>Mixed &lt; &gt; &#38; &#x22;</root> = 1 child (decoded text)
    0,      // Test 37: <root id="value&lt;&gt;"/> = 0 children
    1,      // Test 38: <VeryLongElementName.../><child/> = 1 child
    0,      // Test 39: <root id="..." name="..." ...6 attrs total/> = 0 children
    0,      // Test 40: <ns:root xmlns:ns="..."/> = 0 children
    1,      // Test 41: <root xmlns:a="..."><child xmlns:a="..." a:id="..."><a:item/></child></root> = 1 child (child element)
    0,      // Test 42: <root xmlns:a="..." xmlns:b="..." xmlns:c="..." xmlns:d="..."/> = 0 children
    2,      // Test 43: <config><setting>...</setting><option>...</option></config> = 2 children
    3,      // Test 44: <l1><l2><l3><l4>Deep</l4></l3></l2></l1> = 3 children (text + 2 elements or just 1? Need to check)
    5,      // Test 45: <root>text<!-- comment --><?pi data?><element/><![CDATA[cdata]]></root> = 5 children
    0,      // Test 46: <root url="..." text="..."/> = 0 children
    1,      // Test 47: <root>Long text...</root> = 1 child (text)
    1,      // Test 48: <a id="1"><b id="2">...</b></a> = 1 child
    7,      // Test 49: <root>Start<a/>Middle1<b/>Middle2<c/>End</root> = 7 children
    4       // Test 50: <root><!-- comment --><ns:item>Value</ns:item><?pi data?><![CDATA[]]></root> = 4 children
}

// Root element name (only used for valid test cases)
constant char XML_PARSE_EXPECTED_ROOT_NAME[50][64] = {
    'root',     // Test 1
    'root',     // Test 2
    'root',     // Test 3
    'root',     // Test 4
    'root',     // Test 5
    'root',     // Test 6
    'root',     // Test 7
    'root',     // Test 8
    'root',     // Test 9
    'root',     // Test 10
    'root',     // Test 11
    'root',     // Test 12
    'l1',       // Test 13
    'root',     // Test 14
    'root',     // Test 15
    'ns:root',  // Test 16
    'root',     // Test 17
    'root',     // Test 18
    'root',     // Test 19
    'root',     // Test 20
    '',         // Test 21: Error
    '',         // Test 22: Error
    '',         // Test 23: Error
    '',         // Test 24: Error
    '',         // Test 25: Error
    'root',     // Test 26
    'root',     // Test 27
    'root',     // Test 28
    'root',     // Test 29
    'root',     // Test 30
    'root',     // Test 31
    'root',     // Test 32
    'root',     // Test 33
    'root',     // Test 34
    'root',     // Test 35
    'root',     // Test 36
    'root',     // Test 37
    'VeryLongElementNameToTestParserCapabilities',  // Test 38
    'root',     // Test 39
    'ns:root',  // Test 40
    'root',     // Test 41
    'root',     // Test 42
    'config',   // Test 43
    'a',        // Test 44
    'root',     // Test 45
    'root',     // Test 46
    'root',     // Test 47
    'a',        // Test 48
    'root',     // Test 49
    'root'      // Test 50
}

// First child type (only used for valid test cases, 0 if no children)
constant integer XML_PARSE_EXPECTED_FIRST_CHILD_TYPE[50] = {
    0,                              // Test 1: No children
    NAV_XML_TYPE_TEXT,         // Test 2
    0,                              // Test 3: No children
    NAV_XML_TYPE_TEXT,         // Test 4
    NAV_XML_TYPE_ELEMENT,      // Test 5
    NAV_XML_TYPE_ELEMENT,      // Test 6
    0,                              // Test 7: No children
    NAV_XML_TYPE_ELEMENT,      // Test 8
    NAV_XML_TYPE_TEXT,         // Test 9
    NAV_XML_TYPE_CDATA,        // Test 10
    NAV_XML_TYPE_COMMENT,      // Test 11
    NAV_XML_TYPE_PI,           // Test 12
    NAV_XML_TYPE_ELEMENT,      // Test 13
    NAV_XML_TYPE_ELEMENT,      // Test 14
    NAV_XML_TYPE_TEXT,         // Test 15
    0,                              // Test 16: No children
    NAV_XML_TYPE_ELEMENT,      // Test 17
    NAV_XML_TYPE_ELEMENT,      // Test 18
    NAV_XML_TYPE_ELEMENT,      // Test 19
    NAV_XML_TYPE_TEXT,         // Test 20
    0,                              // Test 21: Error
    0,                              // Test 22: Error
    0,                              // Test 23: Error
    0,                              // Test 24: Error
    0,                              // Test 25: Error
    NAV_XML_TYPE_ELEMENT,      // Test 26: <a:child/>
    NAV_XML_TYPE_ELEMENT,      // Test 27: <child/>
    NAV_XML_TYPE_PI,           // Test 28: <?pi1 data1?>
    NAV_XML_TYPE_PI,           // Test 29: Root has inner PI as first child
    NAV_XML_TYPE_COMMENT,      // Test 30: <!-- c1 -->
    NAV_XML_TYPE_CDATA,        // Test 31: <![CDATA[First]]>
    NAV_XML_TYPE_CDATA,        // Test 32: <![CDATA[]]>
    NAV_XML_TYPE_COMMENT,      // Test 33: <!---->
    NAV_XML_TYPE_TEXT,         // Test 34: text "ABC"
    NAV_XML_TYPE_TEXT,         // Test 35: text "ABC"
    NAV_XML_TYPE_TEXT,         // Test 36: decoded text
    0,                              // Test 37: No children
    NAV_XML_TYPE_ELEMENT,      // Test 38: <child/>
    0,                              // Test 39: No children
    0,                              // Test 40: No children
    NAV_XML_TYPE_ELEMENT,      // Test 41: <child ...>
    0,                              // Test 42: No children
    NAV_XML_TYPE_ELEMENT,      // Test 43: <setting>...</setting>
    NAV_XML_TYPE_TEXT,         // Test 44: Text1 before element b
    NAV_XML_TYPE_TEXT,         // Test 45: text
    0,                              // Test 46: No children
    NAV_XML_TYPE_TEXT,         // Test 47: Long text
    NAV_XML_TYPE_ELEMENT,      // Test 48: <l2 id="2">...</l2>
    NAV_XML_TYPE_TEXT,         // Test 49: text1
    NAV_XML_TYPE_COMMENT       // Test 50: <!-- comment -->
}

// First child element name (only for element types)
constant char XML_PARSE_EXPECTED_FIRST_CHILD_NAME[50][64] = {
    '',         // Test 1: No children
    '',         // Test 2: Text node
    '',         // Test 3: No children
    '',         // Test 4: Text node
    'child',    // Test 5
    'child1',   // Test 6
    '',         // Test 7: No children
    'child',    // Test 8
    '',         // Test 9: Text node
    '',         // Test 10: CDATA node
    '',         // Test 11: Comment node
    'target',   // Test 12: PI node
    'l2',       // Test 13
    'name',     // Test 14
    '',         // Test 15: Text node
    '',         // Test 16: No children
    'users',    // Test 17
    'empty',    // Test 18
    'child',    // Test 19
    '',         // Test 20: Text node
    '',         // Test 21: Error
    '',         // Test 22: Error
    '',         // Test 23: Error
    '',         // Test 24: Error
    '',         // Test 25: Error
    'child',    // Test 26: Name without prefix (parser returns local name)
    'child',    // Test 27
    'xml-stylesheet',  // Test 28: PI name
    'target',   // Test 29: Inner PI name
    '',         // Test 30: Comment
    '',         // Test 31: CDATA
    '',         // Test 32: CDATA
    '',         // Test 33: Comment
    '',         // Test 34: No children
    '',         // Test 35: No children
    '',         // Test 36: No children
    '',         // Test 37: No children
    'child',    // Test 38
    '',         // Test 39: No children
    '',         // Test 40: No children
    'child',    // Test 41
    '',         // Test 42: No children
    'server',   // Test 43
    '',         // Test 44: Text node (Text1)
    '',         // Test 45: Text node
    '',         // Test 46: No children
    '',         // Test 47: Text node
    'b',        // Test 48
    '',         // Test 49: Text node
    ''          // Test 50: Comment
}

// First child text value (only for text/CDATA/comment nodes)
constant char XML_PARSE_EXPECTED_FIRST_CHILD_TEXT[50][255] = {
    '',                                     // Test 1: No children
    'Hello World',                          // Test 2
    '',                                     // Test 3: No children
    'Hello',                                // Test 4
    '',                                     // Test 5: Element, not text
    '',                                     // Test 6: Element, not text
    '',                                     // Test 7: No children
    '',                                     // Test 8: Element, not text
    'Before',                               // Test 9
    '<special>content</special>',           // Test 10: CDATA
    ' This is a comment ',                  // Test 11
    '',                                     // Test 12: PI, not text
    '',                                     // Test 13: Element, not text
    '',                                     // Test 14: Element, not text
    'Text with <entities> & "quotes"',      // Test 15
    '',                                     // Test 16: No children
    '',                                     // Test 17: Element, not text
    '',                                     // Test 18: Element, not text
    '',                                     // Test 19: Element, not text
    'Text1',                                // Test 20
    '',                                     // Test 21: Error
    '',                                     // Test 22: Error
    '',                                     // Test 23: Error
    '',                                     // Test 24: Error
    '',                                     // Test 25: Error
    '',                                     // Test 26: Element
    '',                                     // Test 27: Element
    '',                                     // Test 28: PI (not text)
    'target',                               // Test 29: PI child
    ' comment1 ',                           // Test 30: Comment
    'part1',                                // Test 31: CDATA
    '',                                     // Test 32: Empty CDATA
    '',                                     // Test 33: Empty comment
    'ABC',                                  // Test 34: &#65;&#66;&#67; decoded
    'ABC',                                  // Test 35: &#x41;&#x42;&#x43; decoded
    '<tag> A B &',                          // Test 36: &lt;tag&gt; &#65; &#x42; &amp; decoded
    '',                                     // Test 37: No children
    '',                                     // Test 38: Element
    '',                                     // Test 39: No children
    '',                                     // Test 40: No children
    '',                                     // Test 41: Element
    '',                                     // Test 42: No children
    '',                                     // Test 43: Element
    'Text1',                                // Test 44: Text1
    'Text',                                 // Test 45: Text (capital T)
    '',                                     // Test 46: No children
    'This is a very long text content that should be handled correctly by the parser without any issues regardless of length',  // Test 47
    '',                                     // Test 48: Element
    'Start',                                // Test 49: Start
    ' Config '                              // Test 50: Comment " Config "
}


define_function integer ValidateXmlTreeRecursive(_NAVXml xml,
                                                 _NAVXmlNode node,
                                                 _NAVXmlNode expectedNodes[],
                                                 integer expectedCount,
                                                 integer index,
                                                 integer depth) {
    stack_var _NAVXmlNode child
    stack_var integer nextIndex
    stack_var char indent[128]
    stack_var integer i

    #IF_DEFINED DEBUG_XML_TREE_VALIDATION
    NAVLog("'Validating node at index ', itoa(index), ' at depth ', itoa(depth)")
    #END_IF

    if (index > expectedCount) {
        #IF_DEFINED DEBUG_XML_TREE_VALIDATION
        NAVLog("'Index ', itoa(index), ' exceeds expected count ', itoa(expectedCount)")
        #END_IF

        return 0  // Validation failed
    }

    #IF_DEFINED DEBUG_XML_TREE_VALIDATION
    // Build indentation string based on depth
    indent = ''
    for (i = 1; i <= depth; i++) {
        indent = "indent, '  '"
    }

    // Log node validation with proper indentation
    if (node.type == NAV_XML_TYPE_ELEMENT || node.type == NAV_XML_TYPE_PI) {
        NAVLog("indent, 'Validating: ', itoa(node.type), ' "', node.name, '"'")
    }
    else {
        NAVLog("indent, 'Validating: ', itoa(node.type)")
    }
    #END_IF

    // Assert current node against expected
    if (!NAVAssertIntegerEqual('Node type', expectedNodes[index].type, node.type)) {
        return 0
    }

    // Validate element name (for element and PI nodes)
    if (node.type == NAV_XML_TYPE_ELEMENT || node.type == NAV_XML_TYPE_PI) {
        stack_var char actualName[NAV_XML_PARSER_MAX_ELEMENT_NAME]

        if (node.type == NAV_XML_TYPE_ELEMENT) {
            actualName = NAVXmlGetElementName(node)
        }
        else {
            actualName = node.name  // PI name
        }

        if (!NAVAssertStringEqual('Node name', expectedNodes[index].name, actualName)) {
            return 0
        }
    }

    // Validate node value (for text, CDATA, comment, PI nodes)
    if (node.type == NAV_XML_TYPE_TEXT ||
        node.type == NAV_XML_TYPE_CDATA ||
        node.type == NAV_XML_TYPE_COMMENT ||
        node.type == NAV_XML_TYPE_PI) {
        #IF_DEFINED DEBUG_XML_TREE_VALIDATION
        NAVLog("indent, '  = "', node.value, '"'")
        #END_IF

        if (!NAVAssertStringEqual('Node value', expectedNodes[index].value, node.value)) {
            return 0
        }
    }

    // Validate child count
    if (!NAVAssertIntegerEqual('Node childCount', expectedNodes[index].childCount, node.childCount)) {
        return 0
    }

    nextIndex = index + 1  // Move to next node in depth-first order

    // Recurse into children (depth-first)
    if (node.childCount > 0) {
        if (NAVXmlGetFirstChild(xml, node, child)) {
            while (true) {
                nextIndex = ValidateXmlTreeRecursive(xml,
                                                     child,
                                                     expectedNodes,
                                                     expectedCount,
                                                     nextIndex,
                                                     depth + 1)

                if (nextIndex == 0) {
                    return 0  // Validation failed in child
                }

                if (!NAVXmlGetNextSibling(xml, child, child)) {
                    break
                }
            }
        }
    }

    return nextIndex  // Return next available index
}

define_function char ValidateXmlTree(_NAVXml xml, integer testNum) {
    stack_var _NAVXmlNode root
    stack_var integer result

    #IF_DEFINED DEBUG_XML_TREE_VALIDATION
    NAVLog("'Validating XML tree structure for test ', itoa(testNum)")
    #END_IF

    // Only validate the 20 valid test cases (skip error tests 21-25)
    if (testNum < 1 || testNum > 20) {
        return true
    }

    if (!NAVXmlGetRootNode(xml, root)) {
        return false
    }

    result = ValidateXmlTreeRecursive(xml,
                                      root,
                                      XML_PARSE_EXPECTED_NODES[testNum],
                                      length_array(XML_PARSE_EXPECTED_NODES[testNum]),
                                      1,
                                      0)

    return result != 0  // Success if result > 0
}

define_function TestNAVXmlParse() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlParse'")

    InitializeXmlParseTestData()

    for (x = 1; x <= length_array(XML_PARSE_TEST); x++) {
        stack_var _NAVXml xml
        stack_var _NAVXmlNode root
        stack_var _NAVXmlNode firstChild
        stack_var char result

        result = NAVXmlParse(XML_PARSE_TEST[x], xml)

        // Assert parse result matches expected
        if (!NAVAssertBooleanEqual('Parse result',
                                    XML_PARSE_EXPECTED_RESULT[x],
                                    result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(XML_PARSE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        // For valid XML (tests 1-20)
        if (XML_PARSE_EXPECTED_RESULT[x]) {
            // Assert node count
            if (!NAVAssertIntegerEqual('Node count',
                                       XML_PARSE_EXPECTED_NODE_COUNT[x],
                                       xml.nodeCount)) {
                NAVLogTestFailed(x,
                                itoa(XML_PARSE_EXPECTED_NODE_COUNT[x]),
                                itoa(xml.nodeCount))
                continue
            }

            // Assert root index is valid
            if (!NAVAssertIntegerGreaterThan('Root index',
                                             0,
                                             xml.rootIndex)) {
                NAVLogTestFailed(x, '> 0', itoa(xml.rootIndex))
                continue
            }

            // Get root node for further assertions
            if (!NAVXmlGetRootNode(xml, root)) {
                NAVLogTestFailed(x, 'Get root node', 'failed')
                continue
            }

            // Assert root node type
            if (!NAVAssertIntegerEqual('Root type',
                                       XML_PARSE_EXPECTED_ROOT_TYPE[x],
                                       root.type)) {
                NAVLogTestFailed(x,
                                itoa(XML_PARSE_EXPECTED_ROOT_TYPE[x]),
                                itoa(root.type))
                continue
            }

            // Assert root child count
            if (!NAVAssertIntegerEqual('Root child count',
                                       XML_PARSE_EXPECTED_ROOT_CHILD_COUNT[x],
                                       root.childCount)) {
                NAVLogTestFailed(x,
                                itoa(XML_PARSE_EXPECTED_ROOT_CHILD_COUNT[x]),
                                itoa(root.childCount))
                continue
            }

            // Assert root element name
            if (!NAVAssertStringEqual('Root name',
                                      XML_PARSE_EXPECTED_ROOT_NAME[x],
                                      NAVXmlGetElementName(root))) {
                NAVLogTestFailed(x,
                                XML_PARSE_EXPECTED_ROOT_NAME[x],
                                NAVXmlGetElementName(root))
                continue
            }

            // If root has children, validate first child
            if (root.childCount > 0) {
                if (!NAVXmlGetFirstChild(xml, root, firstChild)) {
                    NAVLogTestFailed(x, 'Get first child', 'failed')
                    continue
                }

                // Assert first child type
                if (!NAVAssertIntegerEqual('First child type',
                                           XML_PARSE_EXPECTED_FIRST_CHILD_TYPE[x],
                                           firstChild.type)) {
                    NAVLogTestFailed(x,
                                    itoa(XML_PARSE_EXPECTED_FIRST_CHILD_TYPE[x]),
                                    itoa(firstChild.type))
                    continue
                }

                // If first child is an element or PI, assert name
                if (firstChild.type == NAV_XML_TYPE_ELEMENT ||
                    firstChild.type == NAV_XML_TYPE_PI) {
                    if (!NAVAssertStringEqual('First child name',
                                              XML_PARSE_EXPECTED_FIRST_CHILD_NAME[x],
                                              firstChild.name)) {
                        NAVLogTestFailed(x,
                                        XML_PARSE_EXPECTED_FIRST_CHILD_NAME[x],
                                        firstChild.name)
                        continue
                    }
                }

                // If first child has text value, assert it
                if (firstChild.type == NAV_XML_TYPE_TEXT ||
                    firstChild.type == NAV_XML_TYPE_CDATA ||
                    firstChild.type == NAV_XML_TYPE_COMMENT) {
                    if (length_array(XML_PARSE_EXPECTED_FIRST_CHILD_TEXT[x]) > 0) {
                        if (!NAVAssertStringEqual('First child text',
                                                  XML_PARSE_EXPECTED_FIRST_CHILD_TEXT[x],
                                                  firstChild.value)) {
                            NAVLogTestFailed(x,
                                            XML_PARSE_EXPECTED_FIRST_CHILD_TEXT[x],
                                            firstChild.value)
                            continue
                        }
                    }
                }
            }

            // Validate entire tree structure using recursive traversal
            if (!ValidateXmlTree(xml, x)) {
                NAVLogTestFailed(x, 'Tree validation', 'failed')
                continue
            }

            // Assert no error message
            if (!NAVAssertStringEqual('Error should be empty',
                                       '',
                                       xml.error)) {
                NAVLogTestFailed(x, '(empty)', xml.error)
                continue
            }

            NAVLogTestPassed(x)
        }
        else {
            // For error cases (tests 21-25), expect failure

            // Assert node count is 0
            if (!NAVAssertIntegerEqual('Node count',
                                       0,
                                       xml.nodeCount)) {
                NAVLogTestFailed(x, '0', itoa(xml.nodeCount))
                continue
            }

            // Assert error message exists
            if (!NAVAssertIntegerGreaterThan('Error message length',
                                             0,
                                             length_array(xml.error))) {
                NAVLogTestFailed(x, '> 0', itoa(length_array(xml.error)))
                continue
            }

            NAVLogTestPassed(x)
        }
    }

    NAVLogTestSuiteEnd("'NAVXmlParse'")
}
