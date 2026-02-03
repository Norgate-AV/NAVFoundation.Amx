PROGRAM_NAME='NAVXmlLexerTokenize'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_VARIABLE

volatile char XML_LEXER_TOKENIZE_TEST[50][1024]

define_function InitializeXmlLexerTokenizeTestData() {
    // Test 1: Empty self-closing element
    XML_LEXER_TOKENIZE_TEST[1] = '<root/>'

    // Test 2: Simple element with text
    XML_LEXER_TOKENIZE_TEST[2] = '<tag>text</tag>'

    // Test 3: Element with attribute
    XML_LEXER_TOKENIZE_TEST[3] = '<element name="value"/>'

    // Test 4: Element with multiple attributes
    XML_LEXER_TOKENIZE_TEST[4] = '<tag attr1="val1" attr2="val2">content</tag>'

    // Test 5: XML declaration
    XML_LEXER_TOKENIZE_TEST[5] = '<?xml version="1.0"?>'

    // Test 6: Comment
    XML_LEXER_TOKENIZE_TEST[6] = '<!-- This is a comment -->'

    // Test 7: CDATA section
    XML_LEXER_TOKENIZE_TEST[7] = '<![CDATA[Some <data> here]]>'

    // Test 8: Nested elements
    XML_LEXER_TOKENIZE_TEST[8] = '<outer><inner>text</inner></outer>'

    // Test 9: Empty element pair
    XML_LEXER_TOKENIZE_TEST[9] = '<empty></empty>'

    // Test 10: Element with entity reference
    XML_LEXER_TOKENIZE_TEST[10] = '<tag>text &lt; more</tag>'

    // Test 11: Attribute with entity
    XML_LEXER_TOKENIZE_TEST[11] = '<tag attr="value &amp; more"/>'

    // Test 12: Multiple elements
    XML_LEXER_TOKENIZE_TEST[12] = '<first/><second/>'

    // Test 13: Invalid - unterminated tag
    XML_LEXER_TOKENIZE_TEST[13] = '<tag'

    // Test 14: Invalid - unterminated attribute
    XML_LEXER_TOKENIZE_TEST[14] = '<tag attr="value'

    // Test 15: Element with whitespace
    XML_LEXER_TOKENIZE_TEST[15] = '<tag  attr = "value" ></tag>'

    // Test 16: DOCTYPE declaration
    XML_LEXER_TOKENIZE_TEST[16] = '<!DOCTYPE root>'

    // Test 17: Processing instruction
    XML_LEXER_TOKENIZE_TEST[17] = '<?target data?>'

    // Test 18: Text with multiple entities
    XML_LEXER_TOKENIZE_TEST[18] = '<tag>&lt;&gt;&amp;&quot;&apos;</tag>'

    // Test 19: Element with numeric character reference
    XML_LEXER_TOKENIZE_TEST[19] = '<tag>&#65;&#x42;</tag>'

    // Test 20: Complex nested structure
    XML_LEXER_TOKENIZE_TEST[20] = '<root><a x="1"><b>text</b></a></root>'

    // Test 21: Namespaced element
    XML_LEXER_TOKENIZE_TEST[21] = '<ns:element xmlns:ns="uri"/>'

    // Test 22: Mixed content (text and elements interspersed)
    XML_LEXER_TOKENIZE_TEST[22] = '<p>This is <b>bold</b> text.</p>'

    // Test 23: Single-quoted attribute
    XML_LEXER_TOKENIZE_TEST[23] = '<tag attr=''value''/>'

    // Test 24: Empty attribute value
    XML_LEXER_TOKENIZE_TEST[24] = '<tag attr=""/>'

    // Test 25: Hyphenated element name
    XML_LEXER_TOKENIZE_TEST[25] = '<my-element/>'

    // Test 26: Element with underscore
    XML_LEXER_TOKENIZE_TEST[26] = '<my_element/>'

    // Test 27: Element with numbers
    XML_LEXER_TOKENIZE_TEST[27] = '<element123/>'

    // Test 28: Multiple comments
    XML_LEXER_TOKENIZE_TEST[28] = '<!-- First --><!-- Second -->'

    // Test 29: Multiple CDATA sections
    XML_LEXER_TOKENIZE_TEST[29] = '<![CDATA[data1]]><![CDATA[data2]]>'

    // Test 30: Attribute with hyphen and underscore
    XML_LEXER_TOKENIZE_TEST[30] = '<tag my-attr="1" my_attr2="2"/>'

    // Test 31: Deeply nested elements (5 levels)
    XML_LEXER_TOKENIZE_TEST[31] = '<a><b><c><d><e>deep</e></d></c></b></a>'

    // Test 32: Mixed case element names
    XML_LEXER_TOKENIZE_TEST[32] = '<MyElement/>'

    // Test 33: Sequential empty elements
    XML_LEXER_TOKENIZE_TEST[33] = '<a/><b/><c/>'

    // Test 34: CDATA with special characters
    XML_LEXER_TOKENIZE_TEST[34] = '<![CDATA[<tag>& "test"]]>'

    // Test 35: Comment with special characters
    XML_LEXER_TOKENIZE_TEST[35] = '<!-- <tag> & "test" -->'

    // Test 36: Hex character reference (lowercase)
    XML_LEXER_TOKENIZE_TEST[36] = '<tag>&#x41;&#x42;</tag>'

    // Test 37: Hex character reference (uppercase X)
    XML_LEXER_TOKENIZE_TEST[37] = '<tag>&#X41;&#X42;</tag>'

    // Test 38: Multiple processing instructions
    XML_LEXER_TOKENIZE_TEST[38] = '<?xml version="1.0"?><?xml-stylesheet type="text/css"?>'

    // Test 39: Element with multiple namespaces
    XML_LEXER_TOKENIZE_TEST[39] = '<root xmlns:a="uri1" xmlns:b="uri2"/>'

    // Test 40: Text with leading/trailing whitespace
    XML_LEXER_TOKENIZE_TEST[40] = '<tag>  text  </tag>'

    set_length_array(XML_LEXER_TOKENIZE_TEST, 40)
}


DEFINE_CONSTANT

constant char XML_LEXER_TOKENIZE_EXPECTED_RESULT[] = {
    true,   // Test 1: Empty self-closing element
    true,   // Test 2: Simple element with text
    true,   // Test 3: Element with attribute
    true,   // Test 4: Element with multiple attributes
    true,   // Test 5: XML declaration
    true,   // Test 6: Comment
    true,   // Test 7: CDATA section
    true,   // Test 8: Nested elements
    true,   // Test 9: Empty element pair
    true,   // Test 10: Element with entity reference
    true,   // Test 11: Attribute with entity
    true,   // Test 12: Multiple elements
    true,   // Test 13: Unterminated tag (lexer accepts, parser would reject)
    false,  // Test 14: Invalid - unterminated attribute
    true,   // Test 15: Element with whitespace
    true,   // Test 16: DOCTYPE declaration
    true,   // Test 17: Processing instruction
    true,   // Test 18: Text with multiple entities
    true,   // Test 19: Element with numeric character reference
    true,   // Test 20: Complex nested structure
    true,   // Test 21: Namespaced element
    true,   // Test 22: Mixed content
    true,   // Test 23: Single-quoted attribute
    true,   // Test 24: Empty attribute value
    true,   // Test 25: Hyphenated element name
    true,   // Test 26: Element with underscore
    true,   // Test 27: Element with numbers
    true,   // Test 28: Multiple comments
    true,   // Test 29: Multiple CDATA sections
    true,   // Test 30: Attribute with hyphen and underscore
    true,   // Test 31: Deeply nested elements
    true,   // Test 32: Mixed case element names
    true,   // Test 33: Sequential empty elements
    true,   // Test 34: CDATA with special characters
    true,   // Test 35: Comment with special characters
    true,   // Test 36: Hex character reference (lowercase)
    true,   // Test 37: Hex character reference (uppercase X)
    true,   // Test 38: Multiple processing instructions
    true,   // Test 39: Element with multiple namespaces
    true    // Test 40: Text with leading/trailing whitespace
}

constant integer XML_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[] = {
    5,      // Test 1: <, root, /, >, EOF
    9,      // Test 2: <, tag, >, text, <, /, tag, >, EOF
    8,      // Test 3: <, element, name, =, "value", /, >, EOF
    15,     // Test 4: <, tag, attr1, =, "val1", attr2, =, "val2", >, content, <, /, tag, >, EOF
    2,      // Test 5: PI token, EOF
    2,      // Test 6: COMMENT, EOF
    2,      // Test 7: CDATA, EOF
    16,     // Test 8: <, outer, >, <, inner, >, text, <, /, inner, >, <, /, outer, >, EOF
    8,      // Test 9: <, empty, >, <, /, empty, >, EOF
    9,      // Test 10: <, tag, >, text, <, /, tag, >, EOF
    8,      // Test 11: <, tag, attr, =, "value", /, >, EOF
    9,      // Test 12: <, first, /, >, <, second, /, >, EOF
    3,      // Test 13: <, tag, EOF (unterminated - lexer accepts)
    0,      // Test 14: Error case
    11,     // Test 15: <, tag, attr, =, "value", >, <, /, tag, >, EOF
    2,      // Test 16: DOCTYPE, EOF
    2,      // Test 17: PI, EOF
    9,      // Test 18: <, tag, >, text, <, /, tag, >, EOF
    9,      // Test 19: <, tag, >, text, <, /, tag, >, EOF
    26,     // Test 20: Complex nested structure
    8,      // Test 21: <, ns:element, xmlns:ns, =, "uri", /, >, EOF
    18,     // Test 22: <, p, >, This is , <, b, >, bold, <, /, b, >, text., <, /, p, >, EOF
    8,      // Test 23: <, tag, attr, =, 'value', /, >, EOF
    8,      // Test 24: <, tag, attr, =, "", /, >, EOF
    5,      // Test 25: <, my-element, /, >, EOF
    5,      // Test 26: <, my_element, /, >, EOF
    5,      // Test 27: <, element123, /, >, EOF
    3,      // Test 28: COMMENT, COMMENT, EOF
    3,      // Test 29: CDATA, CDATA, EOF
    11,     // Test 30: <, tag, my-attr, =, "1", my_attr2, =, "2", /, >, EOF
    37,     // Test 31: Deeply nested (5 levels) + EOF
    5,      // Test 32: <, MyElement, /, >, EOF
    13,     // Test 33: <, a, /, >, <, b, /, >, <, c, /, >, EOF
    2,      // Test 34: CDATA, EOF
    2,      // Test 35: COMMENT, EOF
    9,      // Test 36: <, tag, >, text, <, /, tag, >, EOF
    9,      // Test 37: <, tag, >, text, <, /, tag, >, EOF
    3,      // Test 38: PI, PI, EOF
    11,     // Test 39: <, root, xmlns:a, =, "uri1", xmlns:b, =, "uri2", /, >, EOF
    9       // Test 40: <, tag, >, text, <, /, tag, >, EOF
}


// Expected token types for each test
constant integer XML_LEXER_TOKENIZE_EXPECTED_TYPES[][] = {
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_PI,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_COMMENT,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_CDATA,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Error case - no tokens expected
        0
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_DOCTYPE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_PI,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 21: Namespaced element
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 22: Mixed content
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 23: Single-quoted attribute
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 24: Empty attribute value
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 25: Hyphenated element name
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 26: Element with underscore
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 27: Element with numbers
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 28: Multiple comments
        NAV_XML_TOKEN_TYPE_COMMENT,
        NAV_XML_TOKEN_TYPE_COMMENT,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 29: Multiple CDATA sections
        NAV_XML_TOKEN_TYPE_CDATA,
        NAV_XML_TOKEN_TYPE_CDATA,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 30: Attribute with hyphen and underscore
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 31: Deeply nested elements (5 levels)
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 32: Mixed case element names
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 33: Sequential empty elements
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 34: CDATA with special characters
        NAV_XML_TOKEN_TYPE_CDATA,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 35: Comment with special characters
        NAV_XML_TOKEN_TYPE_COMMENT,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 36: Hex character reference (lowercase)
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 37: Hex character reference (uppercase X)
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 38: Multiple processing instructions
        NAV_XML_TOKEN_TYPE_PI,
        NAV_XML_TOKEN_TYPE_PI,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 39: Element with multiple namespaces
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_EQUALS,
        NAV_XML_TOKEN_TYPE_STRING,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    },
    {
        // Test 40: Text with leading/trailing whitespace
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_TEXT,
        NAV_XML_TOKEN_TYPE_TAG_OPEN,
        NAV_XML_TOKEN_TYPE_SLASH,
        NAV_XML_TOKEN_TYPE_IDENTIFIER,
        NAV_XML_TOKEN_TYPE_TAG_CLOSE,
        NAV_XML_TOKEN_TYPE_EOF
    }
}

// Expected token values for each test
constant char XML_LEXER_TOKENIZE_EXPECTED_VALUES[][][NAV_XML_LEXER_MAX_TOKEN_LENGTH] = {
    {
        '<',
        'root',
        '/',
        '>',
        ''
    },
    {
        '<',
        'tag',
        '>',
        'text',
        '<',
        '/',
        'tag',
        '>',
        ''
    },
    {
        '<',
        'element',
        'name',
        '=',
        'value',
        '/',
        '>',
        ''
    },
    {
        '<',
        'tag',
        'attr1',
        '=',
        'val1',
        'attr2',
        '=',
        'val2',
        '>',
        'content',
        '<',
        '/',
        'tag',
        '>',
        ''
    },
    {
        'xml version="1.0"',
        ''
    },
    {
        ' This is a comment ',
        ''
    },
    {
        'Some <data> here',
        ''
    },
    {
        '<',
        'outer',
        '>',
        '<',
        'inner',
        '>',
        'text',
        '<',
        '/',
        'inner',
        '>',
        '<',
        '/',
        'outer',
        '>',
        ''
    },
    {
        '<',
        'empty',
        '>',
        '<',
        '/',
        'empty',
        '>',
        ''
    },
    {
        '<',
        'tag',
        '>',
        'text < more',
        '<',
        '/',
        'tag',
        '>',
        ''
    },
    {
        '<',
        'tag',
        'attr',
        '=',
        'value & more',
        '/',
        '>',
        ''
    },
    {
        '<',
        'first',
        '/',
        '>',
        '<',
        'second',
        '/',
        '>',
        ''
    },
    {
        '<',
        'tag',
        ''
    },
    {
        // Error case - no values expected
        ''
    },
    {
        '<',
        'tag',
        'attr',
        '=',
        'value',
        '>',
        '<',
        '/',
        'tag',
        '>',
        ''
    },
    {
        ' root>',
        ''
    },
    {
        'target data',
        ''
    },
    {
        '<',
        'tag',
        '>',
        '<>&"''',
        '<',
        '/',
        'tag',
        '>',
        ''
    },
    {
        '<',
        'tag',
        '>',
        'AB',
        '<',
        '/',
        'tag',
        '>',
        ''
    },
    {
        '<',
        'root',
        '>',
        '<',
        'a',
        'x',
        '=',
        '1',
        '>',
        '<',
        'b',
        '>',
        'text',
        '<',
        '/',
        'b',
        '>',
        '<',
        '/',
        'a',
        '>',
        '<',
        '/',
        'root',
        '>',
        ''
    },
    {
        // Test 21: Namespaced element
        '<',
        'ns:element',
        'xmlns:ns',
        '=',
        'uri',
        '/',
        '>',
        ''
    },
    {
        // Test 22: Mixed content
        '<',
        'p',
        '>',
        'This is ',
        '<',
        'b',
        '>',
        'bold',
        '<',
        '/',
        'b',
        '>',
        ' text.',
        '<',
        '/',
        'p',
        '>',
        ''
    },
    {
        // Test 23: Single-quoted attribute
        '<',
        'tag',
        'attr',
        '=',
        'value',
        '/',
        '>',
        ''
    },
    {
        // Test 24: Empty attribute value
        '<',
        'tag',
        'attr',
        '=',
        '',
        '/',
        '>',
        ''
    },
    {
        // Test 25: Hyphenated element name
        '<',
        'my-element',
        '/',
        '>',
        ''
    },
    {
        // Test 26: Element with underscore
        '<',
        'my_element',
        '/',
        '>',
        ''
    },
    {
        // Test 27: Element with numbers
        '<',
        'element123',
        '/',
        '>',
        ''
    },
    {
        // Test 28: Multiple comments
        ' First ',
        ' Second ',
        ''
    },
    {
        // Test 29: Multiple CDATA sections
        'data1',
        'data2',
        ''
    },
    {
        // Test 30: Attribute with hyphen and underscore
        '<',
        'tag',
        'my-attr',
        '=',
        '1',
        'my_attr2',
        '=',
        '2',
        '/',
        '>',
        ''
    },
    {
        // Test 31: Deeply nested elements (5 levels)
        '<',
        'a',
        '>',
        '<',
        'b',
        '>',
        '<',
        'c',
        '>',
        '<',
        'd',
        '>',
        '<',
        'e',
        '>',
        'deep',
        '<',
        '/',
        'e',
        '>',
        '<',
        '/',
        'd',
        '>',
        '<',
        '/',
        'c',
        '>',
        '<',
        '/',
        'b',
        '>',
        '<',
        '/',
        'a',
        '>',
        ''
    },
    {
        // Test 32: Mixed case element names
        '<',
        'MyElement',
        '/',
        '>',
        ''
    },
    {
        // Test 33: Sequential empty elements
        '<',
        'a',
        '/',
        '>',
        '<',
        'b',
        '/',
        '>',
        '<',
        'c',
        '/',
        '>',
        ''
    },
    {
        // Test 34: CDATA with special characters
        '<tag>& "test"',
        ''
    },
    {
        // Test 35: Comment with special characters
        ' <tag> & "test" ',
        ''
    },
    {
        // Test 36: Hex character reference (lowercase)
        '<',
        'tag',
        '>',
        'AB',
        '<',
        '/',
        'tag',
        '>',
        ''
    },
    {
        // Test 37: Hex character reference (uppercase X)
        '<',
        'tag',
        '>',
        'AB',
        '<',
        '/',
        'tag',
        '>',
        ''
    },
    {
        // Test 38: Multiple processing instructions
        'xml version="1.0"',
        'xml-stylesheet type="text/css"',
        ''
    },
    {
        // Test 39: Element with multiple namespaces
        '<',
        'root',
        'xmlns:a',
        '=',
        'uri1',
        'xmlns:b',
        '=',
        'uri2',
        '/',
        '>',
        ''
    },
    {
        // Test 40: Text with leading/trailing whitespace
        '<',
        'tag',
        '>',
        '  text  ',
        '<',
        '/',
        'tag',
        '>',
        ''
    }
}


define_function TestNAVXmlLexerTokenize() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlLexerTokenize'")

    InitializeXmlLexerTokenizeTestData()

    for (x = 1; x <= length_array(XML_LEXER_TOKENIZE_TEST); x++) {
        stack_var char result
        stack_var integer j
        stack_var char failed
        stack_var _NAVXmlLexer lexer

        result = NAVXmlLexerTokenize(lexer, XML_LEXER_TOKENIZE_TEST[x])

        if (!NAVAssertBooleanEqual('Should match expected result',
                                   XML_LEXER_TOKENIZE_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(XML_LEXER_TOKENIZE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        if (!XML_LEXER_TOKENIZE_EXPECTED_RESULT[x]) {
            // Expected failure case, no further checks
            NAVLogTestPassed(x)
            continue
        }

        // Assert token count
        if (!NAVAssertIntegerEqual('Token count should match',
                                   XML_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[x],
                                   lexer.tokenCount)) {
            // Debug: Print all actual tokens
            stack_var integer k
            NAVLog("'Test ', itoa(x), ': Expected ', itoa(XML_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[x]), ' tokens, got ', itoa(lexer.tokenCount)")
            for (k = 1; k <= lexer.tokenCount; k++) {
                NAVLog("'  Token ', itoa(k), ': ', NAVXmlLexerGetTokenType(lexer.tokens[k].type), ' = [', lexer.tokens[k].value, ']'")
            }

            NAVLogTestFailed(x,
                            itoa(XML_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[x]),
                            itoa(lexer.tokenCount))
            continue
        }

        // Assert each token type and value
        for (j = 1; j <= lexer.tokenCount; j++) {
            if (!NAVAssertIntegerEqual('Token type should match',
                                       XML_LEXER_TOKENIZE_EXPECTED_TYPES[x][j],
                                       lexer.tokens[j].type)) {
                // Debug: Print expected vs actual for this token
                NAVLog("'Test ', itoa(x), ' Token ', itoa(j), ': Expected ', NAVXmlLexerGetTokenType(XML_LEXER_TOKENIZE_EXPECTED_TYPES[x][j]), ', got ', NAVXmlLexerGetTokenType(lexer.tokens[j].type), ' = [', lexer.tokens[j].value, ']'")
                NAVLogTestFailed(x,
                                NAVXmlLexerGetTokenType(XML_LEXER_TOKENIZE_EXPECTED_TYPES[x][j]),
                                NAVXmlLexerGetTokenType(lexer.tokens[j].type))
                failed = true
                break
            }

            // Assert line number (all current tests are single-line, so line should be 1)
            if (!NAVAssertIntegerEqual('Token line should be 1',
                                       1,
                                       lexer.tokens[j].line)) {
                NAVLogTestFailed(x, '1', itoa(lexer.tokens[j].line))
                failed = true
                break
            }

            // Assert column number is positive
            if (!NAVAssertIntegerGreaterThan('Token column should be positive',
                                             0,
                                             lexer.tokens[j].column)) {
                NAVLogTestFailed(x, '> 0', itoa(lexer.tokens[j].column))
                failed = true
                break
            }

            // Assert start position is valid
            if (!NAVAssertIntegerGreaterThan('Token start should be positive',
                                             0,
                                             lexer.tokens[j].start)) {
                NAVLogTestFailed(x, '> 0', itoa(lexer.tokens[j].start))
                failed = true
                break
            }

            // Assert end position is valid and >= start (skip for EOF tokens)
            if (lexer.tokens[j].type != NAV_XML_TOKEN_TYPE_EOF) {
                if (!NAVAssertIntegerGreaterThanOrEqual('Token end should be >= start',
                                                        lexer.tokens[j].start,
                                                        lexer.tokens[j].end)) {
                    NAVLogTestFailed(x, "'>= ', itoa(lexer.tokens[j].start)", itoa(lexer.tokens[j].end))
                    failed = true
                    break
                }
            }

            // Skip value check for EOF token
            if (lexer.tokens[j].type == NAV_XML_TOKEN_TYPE_EOF) {
                continue
            }

            if (!NAVAssertStringEqual('Token value should match',
                                      XML_LEXER_TOKENIZE_EXPECTED_VALUES[x][j],
                                      lexer.tokens[j].value)) {
                NAVLogTestFailed(x,
                                XML_LEXER_TOKENIZE_EXPECTED_VALUES[x][j],
                                lexer.tokens[j].value)
                failed = true
                break
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlLexerTokenize'")
}
