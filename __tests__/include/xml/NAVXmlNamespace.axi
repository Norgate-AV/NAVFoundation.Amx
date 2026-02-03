PROGRAM_NAME='NAVXmlNamespace'

DEFINE_VARIABLE

volatile char XML_NAMESPACE_TEST_XML[12][512]
volatile char XML_NAMESPACE_TEST_QUERY[12][64]


define_function InitializeXmlNamespaceTestData() {
    // Test 1: Simple namespace declaration
    XML_NAMESPACE_TEST_XML[1] = '<root xmlns="http://example.com"><item>value</item></root>'
    XML_NAMESPACE_TEST_QUERY[1] = '.item'

    // Test 2: Namespace with prefix - verify parsing succeeds
    XML_NAMESPACE_TEST_XML[2] = '<root xmlns:ns="http://example.com/ns" attr="http://example.com/ns"><ns:item>content</ns:item></root>'
    XML_NAMESPACE_TEST_QUERY[2] = '.@attr'

    // Test 3: Default namespace
    XML_NAMESPACE_TEST_XML[3] = '<root xmlns="http://default.com"><element>text</element></root>'
    XML_NAMESPACE_TEST_QUERY[3] = '.element'

    // Test 4: Multiple namespaces - verify parsing with regular attribute
    XML_NAMESPACE_TEST_XML[4] = '<root xmlns:a="http://a.com" xmlns:b="http://b.com" ns="http://a.com"><a:item>data</a:item></root>'
    XML_NAMESPACE_TEST_QUERY[4] = '.@ns'

    // Test 5: Namespace on child element
    XML_NAMESPACE_TEST_XML[5] = '<root><item xmlns="http://child.com">child</item></root>'
    XML_NAMESPACE_TEST_QUERY[5] = '.item'

    // Test 6: Query regular attribute after namespace declaration
    XML_NAMESPACE_TEST_XML[6] = '<root xmlns:pre="http://prefix.com" url="http://prefix.com"><pre:item>prefixed</pre:item></root>'
    XML_NAMESPACE_TEST_QUERY[6] = '.@url'

    // Test 7: Query element after namespace declaration
    XML_NAMESPACE_TEST_XML[7] = '<root xmlns:ns="http://example.com/ns"><item>http://example.com/ns</item></root>'
    XML_NAMESPACE_TEST_QUERY[7] = '.item'

    // Test 8: Nested namespace override
    XML_NAMESPACE_TEST_XML[8] = '<root xmlns="http://outer.com"><item xmlns="http://inner.com">nested</item></root>'
    XML_NAMESPACE_TEST_QUERY[8] = '.item'

    // Test 9: Multiple namespace declarations - verify with regular attribute
    XML_NAMESPACE_TEST_XML[9] = '<root xmlns:x="http://x.com" xmlns:y="http://y.com" xmlns:z="http://z.com" ref="http://x.com"><x:item>multi</x:item></root>'
    XML_NAMESPACE_TEST_QUERY[9] = '.@ref'

    // Test 10: Namespace with URN - verify with regular attribute
    XML_NAMESPACE_TEST_XML[10] = '<root xmlns:uri="urn:schemas-example:config" schema="urn:schemas-example:config"><uri:item>uri</uri:item></root>'
    XML_NAMESPACE_TEST_QUERY[10] = '.@schema'

    // Test 11: Query unprefixed element alongside prefixed elements
    XML_NAMESPACE_TEST_XML[11] = '<root xmlns:test="http://test.com"><test:parent>data</test:parent><child>http://test.com</child></root>'
    XML_NAMESPACE_TEST_QUERY[11] = '.child'

    // Test 12: Empty namespace declaration
    XML_NAMESPACE_TEST_XML[12] = '<root xmlns=""><item>empty</item></root>'
    XML_NAMESPACE_TEST_QUERY[12] = '.item'

    set_length_array(XML_NAMESPACE_TEST_XML, 12)
    set_length_array(XML_NAMESPACE_TEST_QUERY, 12)
}


DEFINE_CONSTANT

constant char XML_NAMESPACE_EXPECTED[12][64] = {
    'value',                      // Test 1
    'http://example.com/ns',      // Test 2 - attr value
    'text',                       // Test 3
    'http://a.com',               // Test 4 - ns attr
    'child',                      // Test 5
    'http://prefix.com',          // Test 6 - url attr
    'http://example.com/ns',      // Test 7 - item element
    'nested',                     // Test 8
    'http://x.com',               // Test 9 - ref attr
    'urn:schemas-example:config', // Test 10 - schema attr
    'http://test.com',            // Test 11 - child element
    'empty'                       // Test 12
}


define_function TestNAVXmlNamespace() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlNamespace'")

    InitializeXmlNamespaceTestData()

    for (x = 1; x <= length_array(XML_NAMESPACE_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var char result[256]

        if (!NAVXmlParse(XML_NAMESPACE_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryString(xml, XML_NAMESPACE_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertStringEqual('NAVXmlNamespace value',
                                  XML_NAMESPACE_EXPECTED[x],
                                  result)) {
            NAVLogTestFailed(x,
                            XML_NAMESPACE_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlNamespace'")
}
