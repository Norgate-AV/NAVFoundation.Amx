PROGRAM_NAME='NAVXmlQueryString'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_STRING_TEST_XML[10][512]
volatile char XML_QUERY_STRING_TEST_QUERY[10][64]


define_function InitializeXmlQueryStringTestData() {
    // Test 1: Simple root text content
    XML_QUERY_STRING_TEST_XML[1] = '<message>hello</message>'
    XML_QUERY_STRING_TEST_QUERY[1] = '.'

    // Test 2: Element text content
    XML_QUERY_STRING_TEST_XML[2] = '<person><name>John</name></person>'
    XML_QUERY_STRING_TEST_QUERY[2] = '.name'

    // Test 3: Nested element text content
    XML_QUERY_STRING_TEST_XML[3] = '<root><user><name>Jane</name></user></root>'
    XML_QUERY_STRING_TEST_QUERY[3] = '.user.name'

    // Test 4: Element by index
    XML_QUERY_STRING_TEST_XML[4] = '<items><item>first</item><item>second</item><item>third</item></items>'
    XML_QUERY_STRING_TEST_QUERY[4] = '.item[2]'

    // Test 5: Element in indexed parent
    XML_QUERY_STRING_TEST_XML[5] = '<root><book><title>A</title></book><book><title>B</title></book><book><title>C</title></book></root>'
    XML_QUERY_STRING_TEST_QUERY[5] = '.book[3].title'

    // Test 6: Empty string value
    XML_QUERY_STRING_TEST_XML[6] = '<data><value></value></data>'
    XML_QUERY_STRING_TEST_QUERY[6] = '.value'

    // Test 7: Text with whitespace
    XML_QUERY_STRING_TEST_XML[7] = '<data><text>Hello World</text></data>'
    XML_QUERY_STRING_TEST_QUERY[7] = '.text'

    // Test 8: Deeply nested property
    XML_QUERY_STRING_TEST_XML[8] = '<root><config><server><host>localhost</host></server></config></root>'
    XML_QUERY_STRING_TEST_QUERY[8] = '.config.server.host'

    // Test 9: Element after array index
    XML_QUERY_STRING_TEST_XML[9] = '<root><items><item><label>Item1</label></item><item><label>Item2</label></item></items></root>'
    XML_QUERY_STRING_TEST_QUERY[9] = '.items.item[1].label'

    // Test 10: Multiple nested levels
    XML_QUERY_STRING_TEST_XML[10] = '<root><data><users><user><name>Alice</name></user><user><name>Bob</name></user></users></data></root>'
    XML_QUERY_STRING_TEST_QUERY[10] = '.data.users.user[2].name'

    set_length_array(XML_QUERY_STRING_TEST_XML, 10)
    set_length_array(XML_QUERY_STRING_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant char XML_QUERY_STRING_EXPECTED[10][64] = {
    'hello',       // Test 1
    'John',        // Test 2
    'Jane',        // Test 3
    'second',      // Test 4
    'C',           // Test 5
    '',            // Test 6: Empty string
    'Hello World', // Test 7
    'localhost',   // Test 8
    'Item1',       // Test 9
    'Bob'          // Test 10
}


define_function TestNAVXmlQueryString() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQueryString'")

    InitializeXmlQueryStringTestData()

    for (x = 1; x <= length_array(XML_QUERY_STRING_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var char result[256]

        if (!NAVXmlParse(XML_QUERY_STRING_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryString(xml, XML_QUERY_STRING_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertStringEqual('NAVXmlQueryString value',
                                  XML_QUERY_STRING_EXPECTED[x],
                                  result)) {
            NAVLogTestFailed(x,
                            XML_QUERY_STRING_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQueryString'")
}
