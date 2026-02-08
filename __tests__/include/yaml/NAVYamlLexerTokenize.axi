PROGRAM_NAME='NAVYamlLexerTokenize'

DEFINE_VARIABLE

volatile char YAML_LEXER_TOKENIZE_TEST[70][2048]

define_function InitializeYamlLexerTokenizeTestData() {
    // Test 1: Empty mapping (flow style)
    YAML_LEXER_TOKENIZE_TEST[1] = '{}'

    // Test 2: Simple key-value
    YAML_LEXER_TOKENIZE_TEST[2] = 'name: John'

    // Test 3: Multiple keys
    YAML_LEXER_TOKENIZE_TEST[3] = "
        'name: John', 13, 10,
        'age: 30', 13, 10
    "

    // Test 4: Empty sequence (flow style)
    YAML_LEXER_TOKENIZE_TEST[4] = '[]'

    // Test 5: Flow sequence with numbers
    YAML_LEXER_TOKENIZE_TEST[5] = '[1, 2, 3]'

    // Test 6: Block sequence
    YAML_LEXER_TOKENIZE_TEST[6] = "
        '- item1', 13, 10,
        '- item2', 13, 10,
        '- item3', 13, 10
    "

    // Test 7: Nested mapping
    YAML_LEXER_TOKENIZE_TEST[7] = "
        'user:', 13, 10,
        '  name: John', 13, 10,
        '  age: 30', 13, 10
    "

    // Test 8: Flow mapping
    YAML_LEXER_TOKENIZE_TEST[8] = '{name: John, age: 30}'

    // Test 9: Boolean values
    YAML_LEXER_TOKENIZE_TEST[9] = "
        'true_val: true', 13, 10,
        'false_val: false', 13, 10,
        'yes_val: yes', 13, 10,
        'no_val: no', 13, 10
    "

    // Test 10: Null values
    YAML_LEXER_TOKENIZE_TEST[10] = "
        'null_val: null', 13, 10,
        'tilde: ~', 13, 10,
        'empty:', 13, 10
    "

    // Test 11: Quoted strings
    YAML_LEXER_TOKENIZE_TEST[11] = "
        'single: ''quoted value''', 13, 10,
        'double: "quoted value"', 13, 10
    "

    // Test 12: Numbers
    YAML_LEXER_TOKENIZE_TEST[12] = "
        'integer: 42', 13, 10,
        'negative: -10', 13, 10,
        'float: 3.14', 13, 10
    "

    // Test 13: Comment
    YAML_LEXER_TOKENIZE_TEST[13] = "
        'key: value  # this is a comment', 13, 10
    "

    // Test 14: Document marker
    YAML_LEXER_TOKENIZE_TEST[14] = "
        '---', 13, 10,
        'name: John', 13, 10
    "

    // Test 15: Sequence of mappings
    YAML_LEXER_TOKENIZE_TEST[15] = "
        '- name: John', 13, 10,
        '  age: 30', 13, 10,
        '- name: Jane', 13, 10,
        '  age: 25', 13, 10
    "

    // Test 16: Empty lines
    YAML_LEXER_TOKENIZE_TEST[16] = "
        'key1: value1', 13, 10,
        13, 10,
        'key2: value2', 13, 10
    "

    // Test 17: Deeply indented
    YAML_LEXER_TOKENIZE_TEST[17] = "
        'level1:', 13, 10,
        '  level2:', 13, 10,
        '    level3:', 13, 10,
        '      key: value', 13, 10
    "

    // Test 18: Mixed flow and block
    YAML_LEXER_TOKENIZE_TEST[18] = "
        'items: [1, 2, 3]', 13, 10,
        'nested:', 13, 10,
        '  key: value', 13, 10
    "

    // Test 19: Invalid - inconsistent indentation increments
    YAML_LEXER_TOKENIZE_TEST[19] = "
        'key:', 13, 10,
        '  bad', 13, 10,
        '   indent', 13, 10
    "

    // Test 20: Colon in value
    YAML_LEXER_TOKENIZE_TEST[20] = 'url: http://example.com'

    // Test 21: Document end marker
    YAML_LEXER_TOKENIZE_TEST[21] = "
        'data: value', 13, 10,
        '...', 13, 10
    "

    // Test 22: Anchor definition
    YAML_LEXER_TOKENIZE_TEST[22] = '&anchor value'

    // Test 23: Alias reference
    YAML_LEXER_TOKENIZE_TEST[23] = 'ref: *anchor'

    // Test 24: Tag
    YAML_LEXER_TOKENIZE_TEST[24] = 'number: !!int 42'

    // Test 25: Literal block scalar
    YAML_LEXER_TOKENIZE_TEST[25] = "
        'text: |', 13, 10,
        '  Line 1', 13, 10,
        '  Line 2', 13, 10
    "

    // Test 26: Folded block scalar
    YAML_LEXER_TOKENIZE_TEST[26] = "
        'text: >', 13, 10,
        '  Folded', 13, 10,
        '  Text', 13, 10
    "

    // Test 27: Multiple documents
    YAML_LEXER_TOKENIZE_TEST[27] = "
        '---', 13, 10,
        'doc1: first', 13, 10,
        '---', 13, 10,
        'doc2: second', 13, 10
    "

    // Test 28: Escaped characters in double quotes
    YAML_LEXER_TOKENIZE_TEST[28] = "'text: ', 34, 'Line 1', 92, 'n', 'Line 2', 34"

    // Test 29: Single quotes with escaped quote
    YAML_LEXER_TOKENIZE_TEST[29] = "'text: ', 39, 'It', 39, 39, 's working', 39"

    // Test 30: Empty flow sequence
    YAML_LEXER_TOKENIZE_TEST[30] = 'items: []'

    // Test 31: Empty flow mapping
    YAML_LEXER_TOKENIZE_TEST[31] = 'config: {}'

    // Test 32: Trailing comma in sequence (structural error - parser should reject)
    YAML_LEXER_TOKENIZE_TEST[32] = '[1, 2, 3,]'

    // Test 33: Unbalanced left bracket (structural error - parser should reject)
    YAML_LEXER_TOKENIZE_TEST[33] = '[1, 2, 3'

    // Test 34: Unbalanced right bracket (structural error - parser should reject)
    YAML_LEXER_TOKENIZE_TEST[34] = '1, 2, 3]'

    // Test 35: Unbalanced left brace (structural error - parser should reject)
    YAML_LEXER_TOKENIZE_TEST[35] = '{key: value'

    // Test 36: Unbalanced right brace (structural error - parser should reject)
    YAML_LEXER_TOKENIZE_TEST[36] = 'key: value}'

    // Test 37: Very deep nesting (6 levels)
    YAML_LEXER_TOKENIZE_TEST[37] = "
        'l1:', 13, 10,
        '  l2:', 13, 10,
        '    l3:', 13, 10,
        '      l4:', 13, 10,
        '        l5:', 13, 10,
        '          l6: value', 13, 10
    "

    // Test 38: Large flow array
    YAML_LEXER_TOKENIZE_TEST[38] = 'nums: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]'

    // Test 39: Comment at start of line
    YAML_LEXER_TOKENIZE_TEST[39] = "
        '# Comment line', 13, 10,
        'key: value', 13, 10
    "

    // Test 40: Comment after mapping
    YAML_LEXER_TOKENIZE_TEST[40] = "
        'key: value', 13, 10,
        '# Comment at end', 13, 10
    "

    // Test 41: Key with special chars (needs quotes)
    YAML_LEXER_TOKENIZE_TEST[41] = "
        39, 'key:with:colons', 39, ': value'
    "

    // Test 42: Mixed quotes
    YAML_LEXER_TOKENIZE_TEST[42] = "
        'single: ', 39, 'quoted', 39, 13, 10,
        'double: ', 34, 'quoted', 34, 13, 10
    "

    // Test 43: Null value variations
    YAML_LEXER_TOKENIZE_TEST[43] = "
        'null1: null', 13, 10,
        'null2: Null', 13, 10,
        'null3: NULL', 13, 10,
        'null4: ~', 13, 10
    "

    // Test 44: Boolean value variations
    YAML_LEXER_TOKENIZE_TEST[44] = "
        'on_val: on', 13, 10,
        'off_val: off', 13, 10,
        'ON_val: ON', 13, 10,
        'OFF_val: OFF', 13, 10
    "

    // Test 45: Multiple dedents (back from deep nesting)
    YAML_LEXER_TOKENIZE_TEST[45] = "
        'level1:', 13, 10,
        '  level2:', 13, 10,
        '    level3: value', 13, 10,
        'back_to_root: value', 13, 10
    "

    // Test 46: Complex real-world config
    YAML_LEXER_TOKENIZE_TEST[46] = "
        'server:', 13, 10,
        '  host: localhost', 13, 10,
        '  port: 8080', 13, 10,
        '  ssl: true', 13, 10,
        'database:', 13, 10,
        '  name: mydb', 13, 10,
        '  user: admin', 13, 10
    "

    // Test 47: Sequence with nested mappings
    YAML_LEXER_TOKENIZE_TEST[47] = "
        'users:', 13, 10,
        '  - name: Alice', 13, 10,
        '    role: admin', 13, 10,
        '  - name: Bob', 13, 10,
        '    role: user', 13, 10
    "

    // Test 48: Flow sequence with nested flow mapping
    YAML_LEXER_TOKENIZE_TEST[48] = 'data: [{id: 1}, {id: 2}]'

    // Test 49: Empty key (invalid in strict YAML)
    YAML_LEXER_TOKENIZE_TEST[49] = ': value'

    // Test 50: Whitespace-only line between keys
    YAML_LEXER_TOKENIZE_TEST[50] = "
        'key1: value1', 13, 10,
        '  ', 13, 10,
        'key2: value2', 13, 10
    "

    // Test 51: Invalid - colon without space
    YAML_LEXER_TOKENIZE_TEST[51] = 'name:test'

    // Test 52: Invalid - dash without space at start of line
    YAML_LEXER_TOKENIZE_TEST[52] = "'-item1', 13, 10, '- item2', 13, 10"

    // Test 53: Invalid - odd indentation (5 spaces)
    YAML_LEXER_TOKENIZE_TEST[53] = "
        'data:', 13, 10,
        '     value: test', 13, 10
    "

    // Test 54: Valid - empty string with quotes
    YAML_LEXER_TOKENIZE_TEST[54] = "'text: ', 34, 34"

    // Regression tests for anchor/alias identifier parsing
    // Test 55: Anchor followed by space and value (should split)
    YAML_LEXER_TOKENIZE_TEST[55] = 'key: &anchor value'

    // Test 56: Alias followed by space and value (should split)
    YAML_LEXER_TOKENIZE_TEST[56] = 'ref: *alias remaining'

    // Test 57: Anchor with hyphen and underscore in name
    YAML_LEXER_TOKENIZE_TEST[57] = 'data: &my-anchor_123 content'

    // Test 58: Multiple anchors on different lines
    YAML_LEXER_TOKENIZE_TEST[58] = "
        'first: &a1 val1', 13, 10,
        'second: &b2 val2', 13, 10
    "

    // Test 59: Anchor in flow sequence
    YAML_LEXER_TOKENIZE_TEST[59] = '[&item value, other]'

    // Test 60: Alias in mapping key position
    YAML_LEXER_TOKENIZE_TEST[60] = "'*key: value', 13, 10"

    // Test 61: Literal block scalar with one trailing blank line (chomping keep)
    YAML_LEXER_TOKENIZE_TEST[61] = "'text: |+', 13, 10, '  Line 1', 13, 10, 13, 10"

    // Test 62: Literal block scalar with multiple trailing blank lines
    YAML_LEXER_TOKENIZE_TEST[62] = "'text: |+', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, 13, 10, 13, 10"

    // Test 63: Folded block scalar with trailing blank line
    YAML_LEXER_TOKENIZE_TEST[63] = "'text: >+', 13, 10, '  Line 1', 13, 10, 13, 10"

    // Test 64: Literal block scalar with blank line in middle of content
    YAML_LEXER_TOKENIZE_TEST[64] = "'text: |', 13, 10, '  Line 1', 13, 10, 13, 10, '  Line 2', 13, 10"

    // Test 65: Block scalar followed by another key (verifies block mode exit on dedent)
    YAML_LEXER_TOKENIZE_TEST[65] = "'text: |', 13, 10, '  Content', 13, 10, 'key2: value2', 13, 10"

    // Test 66: YAML version directive
    YAML_LEXER_TOKENIZE_TEST[66] = "'%YAML 1.2', 13, 10, '---', 13, 10, 'key: value', 13, 10"

    // Test 67: TAG directive
    YAML_LEXER_TOKENIZE_TEST[67] = "'%TAG ! tag:yaml.org,2002:', 13, 10, '---', 13, 10, 'key: value', 13, 10"

    // Test 68: Multiple directives
    YAML_LEXER_TOKENIZE_TEST[68] = "'%YAML 1.2', 13, 10, '%TAG ! tag:yaml.org,2002:', 13, 10, '---', 13, 10, 'data: test', 13, 10"

    // Test 69: Directive with comment
    YAML_LEXER_TOKENIZE_TEST[69] = "'%YAML 1.2  # Comment', 13, 10, 'key: value', 13, 10"

    // Test 70: Directive followed by document
    YAML_LEXER_TOKENIZE_TEST[70] = "'%YAML 1.2', 13, 10, 'name: test', 13, 10, 'value: 123', 13, 10"

    set_length_array(YAML_LEXER_TOKENIZE_TEST, 70)
}


DEFINE_CONSTANT

constant char YAML_LEXER_TOKENIZE_EXPECTED_RESULT[] = {
    true,   // Test 1: Empty mapping
    true,   // Test 2: Simple key-value
    true,   // Test 3: Multiple keys
    true,   // Test 4: Empty sequence
    true,   // Test 5: Flow sequence with numbers
    true,   // Test 6: Block sequence
    true,   // Test 7: Nested mapping
    true,   // Test 8: Flow mapping
    true,   // Test 9: Boolean values
    true,   // Test 10: Null values
    true,   // Test 11: Quoted strings
    true,   // Test 12: Numbers
    true,   // Test 13: Comment
    true,   // Test 14: Document marker
    true,   // Test 15: Sequence of mappings
    true,   // Test 16: Empty lines
    true,   // Test 17: Deeply indented
    true,   // Test 18: Mixed flow and block
    false,  // Test 19: Invalid - inconsistent indentation
    true,   // Test 20: Colon in value
    true,   // Test 21: Document end marker
    true,   // Test 22: Anchor definition
    true,   // Test 23: Alias reference
    true,   // Test 24: Tag
    true,   // Test 25: Literal block scalar
    true,   // Test 26: Folded block scalar
    true,   // Test 27: Multiple documents
    true,   // Test 28: Escaped characters in double quotes
    true,   // Test 29: Single quotes with escaped quote
    true,   // Test 30: Empty flow sequence
    true,   // Test 31: Empty flow mapping
    true,   // Test 32: Trailing comma (lexer accepts, parser should reject)
    true,   // Test 33: Unclosed bracket (lexer accepts, parser should reject)
    true,   // Test 34: Unopened bracket (lexer accepts, parser should reject)
    true,   // Test 35: Unclosed brace (lexer accepts, parser should reject)
    true,   // Test 36: Unopened brace (lexer accepts, parser should reject)
    true,   // Test 37: Very deep nesting
    true,   // Test 38: Large flow array
    true,   // Test 39: Comment at start of line
    true,   // Test 40: Comment after mapping
    true,   // Test 41: Key with special chars (quoted)
    true,   // Test 42: Mixed quotes
    true,   // Test 43: Null value variations
    true,   // Test 44: Boolean value variations
    true,   // Test 45: Multiple dedents
    true,   // Test 46: Complex real-world config
    true,   // Test 47: Sequence with nested mappings
    true,   // Test 48: Flow sequence with nested flow mapping
    true,   // Test 49: Empty key edge case
    true,   // Test 50: Whitespace-only line between keys
    true,   // Test 51: Lexer accepts colon without space (parser validates)
    true,   // Test 52: Lexer accepts dash without space (parser validates)
    false,  // Test 53: Invalid - odd indentation
    true,   // Test 54: Empty string with quotes
    true,   // Test 55: Anchor followed by space and value
    true,   // Test 56: Alias followed by space and value
    true,   // Test 57: Anchor with hyphen and underscore in name
    true,   // Test 58: Multiple anchors on different lines
    true,   // Test 59: Anchor in flow sequence
    true,   // Test 60: Alias in mapping key position
    true,   // Test 61: Literal with trailing blank line (blank line emits NEWLINE)
    true,   // Test 62: Literal with multiple trailing blank lines
    true,   // Test 63: Folded with trailing blank line
    true,   // Test 64: Literal with blank line in middle
    true,   // Test 65: Block scalar followed by another key
    true,   // Test 66: YAML version directive
    true,   // Test 67: TAG directive
    true,   // Test 68: Multiple directives
    true,   // Test 69: Directive with comment
    true    // Test 70: Directive followed by document
}

constant integer YAML_LEXER_TOKENIZE_EXPECTED_TYPES[][] = {
    // Test 1: Empty mapping (flow style)
    {
        NAV_YAML_TOKEN_TYPE_LEFT_BRACE,
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 2: Simple key-value
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // John
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 3: Multiple keys
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // John
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // age
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 30
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 4: Empty sequence (flow style)
    {
        NAV_YAML_TOKEN_TYPE_LEFT_BRACKET,
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 5: Flow sequence with numbers
    {
        NAV_YAML_TOKEN_TYPE_LEFT_BRACKET,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 1
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 2
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 3
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 6: Block sequence
    {
        NAV_YAML_TOKEN_TYPE_DASH,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // item1
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DASH,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // item2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DASH,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // item3
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 7: Nested mapping with indents
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // user
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // John
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // age
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 30
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 8: Flow mapping
    {
        NAV_YAML_TOKEN_TYPE_LEFT_BRACE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // John
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // age
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 30
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 9: Boolean values (4 key-value pairs with newlines)
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // true_val
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // true
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // false_val
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // false
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // yes_val
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // yes
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // no_val
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // no
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 10: Null values
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // null_val
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // null
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // tilde
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // ~
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // empty
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 11: Quoted strings
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // single
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_STRING, // 'quoted value'
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // double
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_STRING, // "quoted value"
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 12: Numbers
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // integer
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 42
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // negative
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // -10
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // float
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 3.14
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 13: Comment
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 14: Document marker
    {
        NAV_YAML_TOKEN_TYPE_DOCUMENT_START, // ---
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // John
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 15: Sequence of mappings
    {
        NAV_YAML_TOKEN_TYPE_DASH,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // John
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // age
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 30
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_DASH,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Jane
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // age
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 25
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 16: Empty lines (empty line consumed, no extra NEWLINE token)
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key1
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value1
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key2
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 17: Deeply indented (3 levels of nesting)
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // level1
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // level2
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // level3
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 18: Mixed flow and block
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // items
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_LEFT_BRACKET,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 1
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 2
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 3
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // nested
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 19: Invalid - inconsistent indentation
    { 0 },
    // Test 20: Colon in value
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // url
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // http://example.com
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 21: Document end marker
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // data
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DOCUMENT_END, // ...
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 22: Anchor definition - FIXED: anchor name should be identifier only
    {
        NAV_YAML_TOKEN_TYPE_ANCHOR,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // anchor (identifier only)
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value (separate word)
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 23: Alias reference
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // ref
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_ALIAS,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // anchor
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 24: Tag - lexer tokenizes tag prefix and tag name separately
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // number
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_TAG,          // !!
        NAV_YAML_TOKEN_TYPE_TAG,          // int
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 42
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 25: Literal block scalar
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // text
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_LITERAL,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Line 1
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Line 2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 26: Folded block scalar
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // text
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_FOLDED,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Folded
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Text
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 27: Multiple documents
    {
        NAV_YAML_TOKEN_TYPE_DOCUMENT_START, // ---
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // doc1
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // first
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DOCUMENT_START, // ---
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // doc2
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // second
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 28: Escaped characters in double quotes
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // text
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_STRING, // "Line 1\nLine 2"
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 29: Single quotes with escaped quote
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // text
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_STRING, // 'It''s working'
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 30: Empty flow sequence
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // items
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_LEFT_BRACKET,
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 31: Empty flow mapping
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // config
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_LEFT_BRACE,
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 32: Trailing comma in sequence
    {
        NAV_YAML_TOKEN_TYPE_LEFT_BRACKET,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 1
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 2
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 3
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 33: Unbalanced left bracket
    {
        NAV_YAML_TOKEN_TYPE_LEFT_BRACKET,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 1
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 2
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 3
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 34: Unbalanced right bracket
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 1
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 2
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 3
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 35: Unbalanced left brace
    {
        NAV_YAML_TOKEN_TYPE_LEFT_BRACE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 36: Unbalanced right brace
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 37: Very deep nesting (6 levels)
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // l1
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // l2
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // l3
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // l4
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // l5
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // l6
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 38: Large flow array
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // nums
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_LEFT_BRACKET,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 1
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 2
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 3
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 4
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 5
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 6
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 7
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 8
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 9
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 10
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 39: Comment at start of line
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 40: Comment after mapping
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 41: Key with special chars (quoted)
    {
        NAV_YAML_TOKEN_TYPE_STRING, // 'key:with:colons'
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 42: Mixed quotes
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // single
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_STRING, // 'quoted'
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // double
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_STRING, // "quoted"
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 43: Null value variations
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // null1
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // null
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // null2
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Null
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // null3
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // NULL
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // null4
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // ~
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 44: Boolean value variations
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // on_val
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // on
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // off_val
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // off
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // ON_val
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // ON
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // OFF_val
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // OFF
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 45: Multiple dedents
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // level1
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // level2
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // level3
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // back_to_root
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 46: Complex real-world config
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // server
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // host
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // localhost
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // port
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 8080
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // ssl
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // true
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // database
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // mydb
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // user
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // admin
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 47: Sequence with nested mappings
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // users
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_DASH,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Alice
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // role
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // admin
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_DASH,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Bob
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // role
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // user
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 48: Flow sequence with nested flow mapping
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // data
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_LEFT_BRACKET,
        NAV_YAML_TOKEN_TYPE_LEFT_BRACE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // id
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 1
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACE,
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_LEFT_BRACE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // id
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 2
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACE,
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 49: Empty key edge case
    {
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 50: Whitespace-only line between keys
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key1
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value1
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key2
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 51: Invalid - colon without space (lexer accepts as plain scalar)
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name:test (treated as one plain scalar)
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 52: Invalid - dash without space
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // -item1 (treated as plain scalar)
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DASH,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // item2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 53: Invalid - odd indentation
    { 0 },
    // Test 54: Valid - empty string with quotes
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // text
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_STRING, // ""
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 55: Anchor followed by value (regression test)
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_ANCHOR,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // anchor (identifier only)
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value (separate word)
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 56: Alias followed by value (regression test)
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // ref
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_ALIAS,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // alias (identifier only)
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // remaining (separate word)
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 57: Anchor with hyphen and underscore in name
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // data
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_ANCHOR,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // my-anchor_123
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // content
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 58: Multiple anchors on different lines
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // first
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_ANCHOR,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // a1
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // val1
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // second
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_ANCHOR,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // b2
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // val2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 59: Anchor in flow sequence
    {
        NAV_YAML_TOKEN_TYPE_LEFT_BRACKET,
        NAV_YAML_TOKEN_TYPE_ANCHOR,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // item
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_COMMA,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // other
        NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 60: Alias in key position
    {
        NAV_YAML_TOKEN_TYPE_ALIAS,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key (identifier)
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 61: Literal with trailing blank line (NEWLINE for blank line)
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // text
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_LITERAL,      // |+
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Line 1
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_NEWLINE,      // Blank line (NEW: lexer now emits this)
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 62: Literal with multiple trailing blank lines
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // text
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_LITERAL,      // |+
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Line 1
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Line 2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_NEWLINE,      // Blank line 1
        NAV_YAML_TOKEN_TYPE_NEWLINE,      // Blank line 2
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 63: Folded with trailing blank line
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // text
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_FOLDED,       // >+
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Line 1
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_NEWLINE,      // Blank line
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 64: Literal with blank line in middle
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // text
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_LITERAL,      // |
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Line 1
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_NEWLINE,      // Blank line
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Line 2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 65: Block scalar exit on dedent
    {
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // text
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_LITERAL,      // |
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_INDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // Content
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DEDENT,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key2
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 66: YAML version directive
    {
        NAV_YAML_TOKEN_TYPE_DIRECTIVE,    // %YAML 1.2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DOCUMENT_START, // ---
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 67: TAG directive
    {
        NAV_YAML_TOKEN_TYPE_DIRECTIVE,    // %TAG ! tag:yaml.org,2002:
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DOCUMENT_START, // ---
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 68: Multiple directives
    {
        NAV_YAML_TOKEN_TYPE_DIRECTIVE,    // %YAML 1.2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DIRECTIVE,    // %TAG ! tag:yaml.org,2002:
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_DOCUMENT_START, // ---
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // data
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // test
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 69: Directive with comment
    {
        NAV_YAML_TOKEN_TYPE_DIRECTIVE,    // %YAML 1.2 (comment consumed)
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // key
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    },
    // Test 70: Directive followed by document
    {
        NAV_YAML_TOKEN_TYPE_DIRECTIVE,    // %YAML 1.2
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // name
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // test
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // value
        NAV_YAML_TOKEN_TYPE_COLON,
        NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR, // 123
        NAV_YAML_TOKEN_TYPE_NEWLINE,
        NAV_YAML_TOKEN_TYPE_EOF
    }
}

constant integer YAML_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[] = {
    3,      // Test 1: {, }, EOF
    4,      // Test 2: name, :, John, EOF
    9,      // Test 3: name, :, John, newline, age, :, 30, newline, EOF
    3,      // Test 4: [, ], EOF
    8,      // Test 5: [, 1, ,, 2, ,, 3, ], EOF
    10,     // Test 6: -, item1, newline, -, item2, newline, -, item3, newline, EOF
    14,     // Test 7: user, :, newline, indent, name, :, John, newline, age, :, 30, dedent, newline, EOF
    10,     // Test 8: {, name, :, John, ,, age, :, 30, }, EOF
    17,     // Test 9: Multiple boolean key-value pairs
    12,     // Test 10: Multiple null representations (empty: produces no token after colon)
    9,      // Test 11: Quoted strings
    13,     // Test 12: Number variants
    5,      // Test 13: key, :, value, newline, EOF
    7,      // Test 14: ---, newline, name, :, John, newline, EOF
    23,     // Test 15: Complex sequence of mappings
    9,      // Test 16: key1, :, value1, newline, key2, :, value2, newline, EOF (empty line consumed)
    20,     // Test 17: Deep nesting (6 indents + 6 dedents)
    20,     // Test 18: Mixed styles
    0,      // Test 19: Error case
    4,      // Test 20: url, :, http://example.com, EOF
    7,      // Test 21: data, :, value, newline, ..., newline, EOF
    4,      // Test 22: ANCHOR, "anchor", "value", EOF (FIXED: split anchor name from value)
    5,      // Test 23: ref, :, ALIAS, anchor, EOF
    6,      // Test 24: number, :, TAG("!!"), TAG("int"), 42, EOF
    11,     // Test 25: text, :, LITERAL, newline, INDENT, Line 1, newline, Line 2, newline, DEDENT, EOF
    11,     // Test 26: text, :, FOLDED, newline, INDENT, Folded, newline, Text, newline, DEDENT, EOF
    13,     // Test 27: ---, newline, doc1, :, first, newline, ---, newline, doc2, :, second, newline, EOF
    4,      // Test 28: text, :, "escaped", EOF
    4,      // Test 29: text, :, 'quoted', EOF
    5,      // Test 30: items, :, [, ], EOF
    5,      // Test 31: config, :, {, }, EOF
    9,      // Test 32: [, 1, ,, 2, ,, 3, ,, ], EOF (structural error for parser)
    7,      // Test 33: [, 1, ,, 2, ,, 3, EOF (structural error for parser)
    7,      // Test 34: 1, ,, 2, ,, 3, ], EOF (structural error for parser)
    5,      // Test 35: {, key, :, value, EOF (structural error for parser)
    5,      // Test 36: key, :, value, }, EOF (structural error for parser)
    30,     // Test 37: Very deep nesting (6 levels * 4 tokens + dedents)
    24,     // Test 38: nums, :, [, 10 numbers with 9 commas, ], EOF
    5,      // Test 39: key, :, value, newline, EOF (comment consumed without NEWLINE token)
    5,      // Test 40: key, :, value, newline, EOF (trailing comment consumed)
    4,      // Test 41: 'key:with:colons', :, value, EOF
    9,      // Test 42: Two quoted strings
    17,     // Test 43: Four null representations
    17,     // Test 44: Four boolean representations
    19,     // Test 45: level1, :, newline, indent, level2, :, newline, indent, level3, :, value, newline, dedent, dedent, back_to_root, :, value, newline, EOF
    31,     // Test 46: server, :, newline, indent, host, :, localhost, newline, port, :, 8080, newline, ssl, :, true, newline, dedent, database, :, newline, indent, name, :, mydb, newline, user, :, admin, newline, dedent, EOF
    28,     // Test 47: users, :, newline, indent, dash, name, :, Alice, newline, indent, role, :, admin, newline, dedent, dash, name, :, Bob, newline, indent, role, :, user, newline, dedent, dedent, EOF
    16,     // Test 48: data, :, [, {, id, :, 1, }, ,, {, id, :, 2, }, ], EOF
   3,      // Test 49: :, value, EOF (empty key)
    11,     // Test 50: key1, :, value1, newline, indent, dedent, key2, :, value2, newline, EOF
    2,      // Test 51: 'name:test' (plain scalar), EOF
    6,      // Test 52: '-item1' (plain scalar), newline, -, item2, newline, EOF
    0,      // Test 53: Error case - odd indentation
    4,      // Test 54: text, :, "", EOF
    6,      // Test 55: key, :, ANCHOR, "anchor", "value", EOF (regression test)
    6,      // Test 56: ref, :, ALIAS, "alias", "remaining", EOF (regression test)
    6,      // Test 57: data, :, ANCHOR, "my-anchor_123", "content", EOF
    13,     // Test 58: first, :, ANCHOR, "a1", "val1", newline, second, :, ANCHOR, "b2", "val2", newline, EOF
    8,      // Test 59: [, ANCHOR, "item", "value", ,, "other", ], EOF
    6,      // Test 60: ALIAS, "key", :, "value", newline, EOF
    10,     // Test 61: text, :, LITERAL, newline, INDENT, Line1, newline, newline, DEDENT, EOF
    13,     // Test 62: text, :, LITERAL, newline, INDENT, Line1, newline, Line2, newline, newline, newline, DEDENT, EOF
    10,     // Test 63: text, :, FOLDED, newline, INDENT, Line1, newline, newline, DEDENT, EOF
    12,     // Test 64: text, :, LITERAL, newline, INDENT, Line1, newline, newline, Line2, newline, DEDENT, EOF
    13,     // Test 65: text, :, LITERAL, newline, INDENT, Content, newline, DEDENT, key2, :, value2, newline, EOF
    9,      // Test 66: DIRECTIVE, newline, ---, newline, key, :, value, newline, EOF
    9,      // Test 67: DIRECTIVE, newline, ---, newline, key, :, value, newline, EOF
    11,     // Test 68: DIRECTIVE, newline, DIRECTIVE, newline, ---, newline, data, :, test, newline, EOF
    7,      // Test 69: DIRECTIVE, newline, key, :, value, newline, EOF (comment consumed)
    11      // Test 70: DIRECTIVE, newline, name, :, test, newline, value, :, 123, newline, EOF
}


define_function TestNAVYamlLexerTokenize() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlLexerTokenize'")

    InitializeYamlLexerTokenizeTestData()

    for (x = 1; x <= length_array(YAML_LEXER_TOKENIZE_TEST); x++) {
        stack_var char result
        stack_var _NAVYamlLexer lexer
        stack_var integer j
        stack_var char failed

        result = NAVYamlLexerTokenize(lexer, YAML_LEXER_TOKENIZE_TEST[x])

        if (!NAVAssertBooleanEqual('Should match expected result',
                                   YAML_LEXER_TOKENIZE_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_LEXER_TOKENIZE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        if (!YAML_LEXER_TOKENIZE_EXPECTED_RESULT[x]) {
            // Expected failure case, no further checks
            NAVLogTestPassed(x)
            continue
        }

        // Skip token type validation if first element is 0 (indicates complex test to skip)
        if (YAML_LEXER_TOKENIZE_EXPECTED_TYPES[x][1] == 0) {
            // Just do basic validation
            if (lexer.tokenCount > 0 &&
                lexer.tokens[lexer.tokenCount].type == NAV_YAML_TOKEN_TYPE_EOF) {
                NAVLogTestPassed(x)
            } else {
                NAVLogTestFailed(x, "'EOF token present'", "'Missing or invalid EOF'")
            }
            continue
        }

        // Assert token count matches expected
        if (!NAVAssertIntegerEqual('Token count should match',
                                   YAML_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[x],
                                   lexer.tokenCount)) {
            NAVLogTestFailed(x,
                            itoa(YAML_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[x]),
                            itoa(lexer.tokenCount))
            continue
        }

        // Assert each token type
        failed = false
        for (j = 1; j <= lexer.tokenCount; j++) {
            if (!NAVAssertIntegerEqual('Token type should match',
                                       YAML_LEXER_TOKENIZE_EXPECTED_TYPES[x][j],
                                       lexer.tokens[j].type)) {
                NAVLogTestFailed(x,
                                NAVYamlLexerGetTokenType(YAML_LEXER_TOKENIZE_EXPECTED_TYPES[x][j]),
                                NAVYamlLexerGetTokenType(lexer.tokens[j].type))
                failed = true
                break
            }

            // Assert line number is >= 1
            if (!NAVAssertIntegerGreaterThanOrEqual('Token line should be >= 1',
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
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlLexerTokenize'")
}
