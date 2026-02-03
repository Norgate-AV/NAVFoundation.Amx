PROGRAM_NAME='NAVXmlQueryStringArray'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_STRING_ARRAY_TEST_XML[10][1024]
volatile char XML_QUERY_STRING_ARRAY_TEST_QUERY[10][64]


define_function InitializeXmlQueryStringArrayTestData() {
    // Test 1: Simple root array
    XML_QUERY_STRING_ARRAY_TEST_XML[1] = '<items><item>first</item><item>second</item><item>third</item></items>'
    XML_QUERY_STRING_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Nested array property
    XML_QUERY_STRING_ARRAY_TEST_XML[2] = '<root><names><name>Alice</name><name>Bob</name><name>Charlie</name></names></root>'
    XML_QUERY_STRING_ARRAY_TEST_QUERY[2] = '.names'

    // Test 3: Deeply nested array
    XML_QUERY_STRING_ARRAY_TEST_XML[3] = '<root><data><values><value>A</value><value>B</value><value>C</value></values></data></root>'
    XML_QUERY_STRING_ARRAY_TEST_QUERY[3] = '.data.values'

    // Test 4: Array with longer strings
    XML_QUERY_STRING_ARRAY_TEST_XML[4] = '<list><item>Hello World</item><item>Goodbye World</item></list>'
    XML_QUERY_STRING_ARRAY_TEST_QUERY[4] = '.'

    // Test 5: Empty string values
    XML_QUERY_STRING_ARRAY_TEST_XML[5] = '<data><value></value><value>not empty</value><value></value></data>'
    XML_QUERY_STRING_ARRAY_TEST_QUERY[5] = '.'

    // Test 6: Mixed content
    XML_QUERY_STRING_ARRAY_TEST_XML[6] = '<root><items><item>One</item><item>Two</item><item>Three</item><item>Four</item></items></root>'
    XML_QUERY_STRING_ARRAY_TEST_QUERY[6] = '.items'

    // Test 7: Single element
    XML_QUERY_STRING_ARRAY_TEST_XML[7] = '<container><element>solo</element></container>'
    XML_QUERY_STRING_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array (no child elements with text)
    XML_QUERY_STRING_ARRAY_TEST_XML[8] = '<empty></empty>'
    XML_QUERY_STRING_ARRAY_TEST_QUERY[8] = '.'

    // Test 9: Array after index
    XML_QUERY_STRING_ARRAY_TEST_XML[9] = '<root><group><item>A</item><item>B</item></group><group><item>C</item><item>D</item></group></root>'
    XML_QUERY_STRING_ARRAY_TEST_QUERY[9] = '.group[2]'

    // Test 10: Deeply nested with index
    XML_QUERY_STRING_ARRAY_TEST_XML[10] = '<root><data><records><record><tag>Tag1</tag><tag>Tag2</tag></record><record><tag>Tag3</tag><tag>Tag4</tag></record></records></data></root>'
    XML_QUERY_STRING_ARRAY_TEST_QUERY[10] = '.data.records.record[2]'

    set_length_array(XML_QUERY_STRING_ARRAY_TEST_XML, 10)
    set_length_array(XML_QUERY_STRING_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer XML_QUERY_STRING_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    2,  // Test 4
    3,  // Test 5
    4,  // Test 6
    1,  // Test 7
    0,  // Test 8 (empty)
    2,  // Test 9
    2   // Test 10
}

constant char XML_QUERY_STRING_ARRAY_EXPECTED[10][5][64] = {
    {'first', 'second', 'third'},                   // Test 1
    {'Alice', 'Bob', 'Charlie'},                    // Test 2
    {'A', 'B', 'C'},                                // Test 3
    {'Hello World', 'Goodbye World'},               // Test 4
    {'', 'not empty', ''},                          // Test 5
    {'One', 'Two', 'Three', 'Four'},                // Test 6
    {'solo'},                                       // Test 7
    {''},                                           // Test 8 (empty)
    {'C', 'D'},                                     // Test 9
    {'Tag3', 'Tag4'}                                // Test 10
}


define_function TestNAVXmlQueryStringArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQueryStringArray'")

    InitializeXmlQueryStringArrayTestData()

    for (x = 1; x <= length_array(XML_QUERY_STRING_ARRAY_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var char result[100][256]
        stack_var integer i
        stack_var char failed

        if (!NAVXmlParse(XML_QUERY_STRING_ARRAY_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryStringArray(xml, XML_QUERY_STRING_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   XML_QUERY_STRING_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(XML_QUERY_STRING_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertStringEqual("'Array element ', itoa(i)",
                                      XML_QUERY_STRING_ARRAY_EXPECTED[x][i],
                                      result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', XML_QUERY_STRING_ARRAY_EXPECTED[x][i]",
                                "'Element ', itoa(i), ': ', result[i]")
                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQueryStringArray'")
}
