PROGRAM_NAME='NAVSnapiParseShared'

#IF_NOT_DEFINED __NAV_SNAPI_PARSE_SHARED__
#DEFINE __NAV_SNAPI_PARSE_SHARED__ 'NAVSnapiParseShared'

DEFINE_CONSTANT

constant char SNAPI_PARSE_BASIC_TEST[][255] = {
    'INPUT-HDMI,1',                             // 1: Simple input command
    '?VERSION',                                  // 2: Simple query command
    'FOO-"bar,baz"',                            // 3: Input with quoted string containing comma
    'COMMAND-,ARG2,"""ARG3"""',                 // 4: Mixed arguments with escaped quotes
    'HEADER-Value,ANOTHER,"Complex,Value",',     // 5: Complex input with multiple tokens and trailing comma
    'POWER',                                     // 6: Header only, no dash
    'VOLUME-50',                                 // 7: Single parameter
    'TEXT-""',                                   // 8: Empty quoted string parameter
    'DATA-,,,',                                  // 9: Multiple empty parameters
    'CMD-" Leading space"',                     // 10: Leading whitespace in quoted string
    'CMD-"Trailing space "',                    // 11: Trailing whitespace in quoted string
    'CMD-" Both sides "',                       // 12: Both leading and trailing whitespace
    'CMD-ARG1 WITH SPACES,ARG2',                // 13: Whitespace in unquoted parameter
    'SPECIAL-@#$%,~/\\',                         // 14: Special characters in parameters
    'ESCAPE-"Quote""inside"',                  // 15: Escaped quote at end of word
    'MULTI-""""',                               // 16: Double escaped quotes (empty with escaped quote)
    'COMBO-A,"B",C,"D,E",F',                    // 17: Mix of quoted and unquoted
    'NUMBERS-123,456.789,"-10"',                // 18: Numeric parameters (negative must be quoted)
    'LONG-A,B,C,D,E,F,G,H,I,J',                 // 19: Many parameters
    'WHITESPACE- , , ',                         // 20: Parameters with just whitespace
    'DASH-test-value,another-one',              // 21: Dash in unquoted parameters (after first separator)
    'QUERY-param1,"?query",param2',             // 22: Question mark in quoted parameter
    'MIXED-value-with-dashes,"data?query"',     // 23: Both dash and question mark in parameters
    'UNQUOTED-data?test,value',                 // 24: Unquoted question mark in parameter
    'SWITCH--,-,--,?-,?'                        // 25: Edge case with multiple dashes and question marks
}

constant char SNAPI_PARSE_BASIC_EXPECTED_HEADER_VALUES[][50] = {
    'INPUT',
    '?VERSION',
    'FOO',
    'COMMAND',
    'HEADER',
    'POWER',
    'VOLUME',
    'TEXT',
    'DATA',
    'CMD',
    'CMD',
    'CMD',
    'CMD',
    'SPECIAL',
    'ESCAPE',
    'MULTI',
    'COMBO',
    'NUMBERS',
    'LONG',
    'WHITESPACE',
    'DASH',
    'QUERY',
    'MIXED',
    'UNQUOTED',
    'SWITCH'
}

constant integer SNAPI_PARSE_BASIC_EXPECTED_ARG_COUNTS[] = {
    2,
    0,
    1,
    3,
    4,
    0,
    1,
    1,
    4,
    1,
    1,
    1,
    2,
    2,
    1,
    1,
    5,
    3,
    10,
    3,
    2,
    3,
    2,
    2,
    5
}

constant char SNAPI_PARSE_BASIC_EXPECTED_ARG_VALUES[][][50] = {
    {
        'HDMI',
        '1'
    },
    {
        // No args for query
        ''
    },
    {
        'bar,baz'
    },
    {
        '',
        'ARG2',
        '"ARG3"'
    },
    {
        'Value',
        'ANOTHER',
        'Complex,Value',
        ''
    },
    {
        // No args, header only
        ''
    },
    {
        '50'
    },
    {
        ''
    },
    {
        '',
        '',
        '',
        ''
    },
    {
        ' Leading space'
    },
    {
        'Trailing space '
    },
    {
        ' Both sides '
    },
    {
        'ARG1 WITH SPACES',
        'ARG2'
    },
    {
        '@#$%',
        '~/\\'
    },
    {
        'Quote"inside'
    },
    {
        '"'
    },
    {
        'A',
        'B',
        'C',
        'D,E',
        'F'
    },
    {
        '123',
        '456.789',
        '-10'
    },
    {
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J'
    },
    {
        ' ',
        ' ',
        ' '
    },
    {
        'test-value',
        'another-one'
    },
    {
        'param1',
        '?query',
        'param2'
    },
    {
        'value-with-dashes',
        'data?query'
    },
    {
        'data?test',
        'value'
    },
    {
        '-',
        '-',
        '--',
        '?-',
        '?'
    }
}

#END_IF
