PROGRAM_NAME='NAVXmlParserEscapeString'

#include 'NAVFoundation.XmlParser.axi'


DEFINE_VARIABLE

volatile char XML_PARSER_UNESCAPE_STRING_TEST[20][255]
volatile char XML_PARSER_UNESCAPE_STRING_EXPECTED[20][255]


define_function InitializeXmlParserUnescapeStringTestData() {
    // Test 1: Simple text (no escaping)
    XML_PARSER_UNESCAPE_STRING_TEST[1] = 'hello world'

    // Test 2: Less than entity
    XML_PARSER_UNESCAPE_STRING_TEST[2] = 'a &lt; b'

    // Test 3: Greater than entity
    XML_PARSER_UNESCAPE_STRING_TEST[3] = 'a &gt; b'

    // Test 4: Ampersand entity
    XML_PARSER_UNESCAPE_STRING_TEST[4] = 'Tom &amp; Jerry'

    // Test 5: Quote entity
    XML_PARSER_UNESCAPE_STRING_TEST[5] = 'say &quot;hello&quot;'

    // Test 6: Apostrophe entity
    XML_PARSER_UNESCAPE_STRING_TEST[6] = 'it&apos;s working'

    // Test 7: Multiple entities
    XML_PARSER_UNESCAPE_STRING_TEST[7] = '&lt;tag attr=&quot;value&quot;&gt;content &amp; more&lt;/tag&gt;'

    // Test 8: Empty string
    XML_PARSER_UNESCAPE_STRING_TEST[8] = ''

    // Test 9: All five XML entities
    XML_PARSER_UNESCAPE_STRING_TEST[9] = '&lt; &gt; &amp; &quot; &apos;'

    // Test 10: Consecutive entities
    XML_PARSER_UNESCAPE_STRING_TEST[10] = '&amp;&amp;&amp;'

    // Test 11: Entity at start
    XML_PARSER_UNESCAPE_STRING_TEST[11] = '&lt;start'

    // Test 12: Entity at end
    XML_PARSER_UNESCAPE_STRING_TEST[12] = 'end&gt;'

    // Test 13: Only entities
    XML_PARSER_UNESCAPE_STRING_TEST[13] = '&amp;&lt;&gt;&quot;&apos;'

    // Test 14: Mixed text and entities
    XML_PARSER_UNESCAPE_STRING_TEST[14] = 'a&lt;b&gt;c&amp;d&quot;e&apos;f'

    // Test 15: Repeated quotes
    XML_PARSER_UNESCAPE_STRING_TEST[15] = '&quot;&quot;&quot;&quot;&quot;&quot;'

    // Test 16: URL with entities
    XML_PARSER_UNESCAPE_STRING_TEST[16] = 'http://example.com?a=1&amp;b=2&amp;c=3'

    // Test 17: Mathematical expression
    XML_PARSER_UNESCAPE_STRING_TEST[17] = '5 &lt; 10 &amp;&amp; 10 &gt; 5'

    // Test 18: Code snippet
    XML_PARSER_UNESCAPE_STRING_TEST[18] = 'if (x &lt; y &amp;&amp; y &gt; z)'

    // Test 19: Nested entities (double-escaped)
    XML_PARSER_UNESCAPE_STRING_TEST[19] = '&amp;lt; &amp;gt; &amp;amp;'

    // Test 20: Complex mixed content
    XML_PARSER_UNESCAPE_STRING_TEST[20] = 'Price: $5 &amp; up. Size: 5&quot; x 7&quot;. Qty: &lt;100'

    set_length_array(XML_PARSER_UNESCAPE_STRING_TEST, 20)

    XML_PARSER_UNESCAPE_STRING_EXPECTED[1] = 'hello world'                              // Test 1
    XML_PARSER_UNESCAPE_STRING_EXPECTED[2] = 'a < b'                                    // Test 2
    XML_PARSER_UNESCAPE_STRING_EXPECTED[3] = 'a > b'                                    // Test 3
    XML_PARSER_UNESCAPE_STRING_EXPECTED[4] = 'Tom & Jerry'                              // Test 4
    XML_PARSER_UNESCAPE_STRING_EXPECTED[5] = 'say "hello"'                              // Test 5
    XML_PARSER_UNESCAPE_STRING_EXPECTED[6] = 'it''s working'                             // Test 6
    XML_PARSER_UNESCAPE_STRING_EXPECTED[7] = '<tag attr="value">content & more</tag>'   // Test 7
    XML_PARSER_UNESCAPE_STRING_EXPECTED[8] = ''                                         // Test 8
    XML_PARSER_UNESCAPE_STRING_EXPECTED[9] = '< > & " '''                              // Test 9
    XML_PARSER_UNESCAPE_STRING_EXPECTED[10] = '&&&'                                     // Test 10
    XML_PARSER_UNESCAPE_STRING_EXPECTED[11] = '<start'                                  // Test 11
    XML_PARSER_UNESCAPE_STRING_EXPECTED[12] = 'end>'                                    // Test 12
    XML_PARSER_UNESCAPE_STRING_EXPECTED[13] = '&<>"'''                                 // Test 13
    XML_PARSER_UNESCAPE_STRING_EXPECTED[14] = 'a<b>c&d"e''f'                          // Test 14
    XML_PARSER_UNESCAPE_STRING_EXPECTED[15] = '""""""'                                  // Test 15
    XML_PARSER_UNESCAPE_STRING_EXPECTED[16] = 'http://example.com?a=1&b=2&c=3'          // Test 16
    XML_PARSER_UNESCAPE_STRING_EXPECTED[17] = '5 < 10 && 10 > 5'                        // Test 17
    XML_PARSER_UNESCAPE_STRING_EXPECTED[18] = 'if (x < y && y > z)'                     // Test 18
    XML_PARSER_UNESCAPE_STRING_EXPECTED[19] = '&lt; &gt; &amp;'                         // Test 19
    XML_PARSER_UNESCAPE_STRING_EXPECTED[20] = 'Price: $5 & up. Size: 5" x 7". Qty: <100' // Test 20

    set_length_array(XML_PARSER_UNESCAPE_STRING_EXPECTED, 20)
}


define_function TestNAVXmlParserUnescapeString() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlParserUnescapeString'")

    InitializeXmlParserUnescapeStringTestData()

    for (x = 1; x <= length_array(XML_PARSER_UNESCAPE_STRING_TEST); x++) {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVXmlParserUnescapeString(XML_PARSER_UNESCAPE_STRING_TEST[x])

        if (!NAVAssertStringEqual('Unescaped string should match expected',
                                   XML_PARSER_UNESCAPE_STRING_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            XML_PARSER_UNESCAPE_STRING_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlParserUnescapeString'")
}
