PROGRAM_NAME='NAVXmlTreeInfo'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_TREE_INFO_TEST[10][512]


define_function InitializeXmlTreeInfoTestData() {
    // Test 1: Simple element with one child
    XML_TREE_INFO_TEST[1] = '<root><child>value</child></root>'

    // Test 2: Array of elements
    XML_TREE_INFO_TEST[2] = '<root><item>1</item><item>2</item><item>3</item></root>'

    // Test 3: Nested structure - depth 2
    XML_TREE_INFO_TEST[3] = '<root><outer><inner>true</inner></outer></root>'

    // Test 4: Nested array - depth 2
    XML_TREE_INFO_TEST[4] = '<root><group><item>1</item><item>2</item></group><group><item>3</item><item>4</item></group></root>'

    // Test 5: Deep nesting - depth 4
    XML_TREE_INFO_TEST[5] = '<root><a><b><c><d>1</d></c></b></a></root>'

    // Test 6: Empty element - depth 0
    XML_TREE_INFO_TEST[6] = '<root></root>'

    // Test 7: Self-closing empty element
    XML_TREE_INFO_TEST[7] = '<root/>'

    // Test 8: Wide structure - many siblings
    XML_TREE_INFO_TEST[8] = '<root><a>1</a><b>2</b><c>3</c><d>4</d><e>5</e></root>'

    // Test 9: Mixed depth and width
    XML_TREE_INFO_TEST[9] = '<root><users><user><name>A</name><age>25</age></user><user><name>B</name><age>30</age></user></users></root>'

    // Test 10: Complex structure
    XML_TREE_INFO_TEST[10] = '<root><data><items><item>1</item><item>2</item><item>3</item></items><meta><count>3</count><active>true</active></meta></data></root>'

    set_length_array(XML_TREE_INFO_TEST, 10)
}


DEFINE_CONSTANT

// Expected node counts (element nodes only)
constant integer XML_TREE_INFO_EXPECTED_NODE_COUNT[10] = {
    2,   // Test 1: root + child
    4,   // Test 2: root + 3 items
    3,   // Test 3: root + outer + inner
    7,   // Test 4: root + 2 groups + 4 items
    5,   // Test 5: root + a + b + c + d
    1,   // Test 6: root only
    1,   // Test 7: root only
    6,   // Test 8: root + 5 children
    8,   // Test 9: root + users + 2 users + (2 + 2 fields)
    9    // Test 10: root + data + items + meta + (3 items + 2 fields)
}

// Expected max depths (levels below root)
constant integer XML_TREE_INFO_EXPECTED_MAX_DEPTH[10] = {
    1,  // Test 1: root -> child
    1,  // Test 2: root -> item
    2,  // Test 3: root -> outer -> inner
    2,  // Test 4: root -> group -> item
    4,  // Test 5: root -> a -> b -> c -> d
    0,  // Test 6: empty
    0,  // Test 7: empty
    1,  // Test 8: root -> child
    3,  // Test 9: root -> users -> user -> name/age
    3   // Test 10: root -> data -> items/meta -> item/count/active
}


define_function TestNAVXmlTreeInfo() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlTreeInfo'")

    InitializeXmlTreeInfoTestData()

    for (x = 1; x <= length_array(XML_TREE_INFO_TEST); x++) {
        stack_var _NAVXml xml
        stack_var integer nodeCount
        stack_var sinteger maxDepth

        if (!NAVXmlParse(XML_TREE_INFO_TEST[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // Test NAVXmlGetNodeCount
        nodeCount = NAVXmlGetNodeCount(xml)
        if (!NAVAssertIntegerEqual('NAVXmlGetNodeCount',
                                    XML_TREE_INFO_EXPECTED_NODE_COUNT[x],
                                    nodeCount)) {
            NAVLogTestFailed(x,
                            itoa(XML_TREE_INFO_EXPECTED_NODE_COUNT[x]),
                            itoa(nodeCount))
            continue
        }

        // Test NAVXmlGetMaxDepth
        maxDepth = NAVXmlGetMaxDepth(xml)
        if (!NAVAssertIntegerEqual('NAVXmlGetMaxDepth',
                                    XML_TREE_INFO_EXPECTED_MAX_DEPTH[x],
                                    type_cast(maxDepth))) {
            NAVLogTestFailed(x,
                            itoa(XML_TREE_INFO_EXPECTED_MAX_DEPTH[x]),
                            itoa(maxDepth))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlTreeInfo'")
}
