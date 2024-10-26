PROGRAM_NAME='NAVRegexCompile'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char COMPILE_TEST[][255] = {
    '/\d+/',
    '/\w+/',
    '/\w*/',
    '/\s/',
    '/\s+/',
    '/\s*/',
    '/\d\w?\s/',
    '/\d\w\s+/',
    '/\d?\w\s*/',
    '/\D+/',
    '/\D*/',
    '/\D\s/',
    '/\W+/',
    '/\S*/',
    '/^[a-zA-Z0-9_]+$/',
    '/^[Hh]ello,\s[Ww]orld!$/',
    // '/^\d{3}-\d{2}-\d{4}$/',
    '/^"[^"]*"/',
    // '/^([a-zA-Z_]\w*)\s*=\s*([^;#].*)/',
    '/.*/',    // Match everything, including epsilon (empty string)
    '/\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/'      // Match an IP address
}


define_function RegexCompileSetupExpected(integer id, _NAVRegexParser parser) {
    switch (id) {
        case 1: {
            parser.pattern.value = '\d+'
            parser.pattern.length = 3
            parser.pattern.cursor = 1

            parser.count = 2

            parser.state[1].type = REGEX_TYPE_DIGIT
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_PLUS
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0
        }
        case 2: {
            parser.pattern.value = '\w+'
            parser.pattern.length = 3
            parser.pattern.cursor = 1

            parser.count = 2

            parser.state[1].type = REGEX_TYPE_ALPHA
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_PLUS
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0
        }
        case 3: {
            parser.pattern.value = '\w*'
            parser.pattern.length = 3
            parser.pattern.cursor = 1

            parser.count = 2

            parser.state[1].type = REGEX_TYPE_ALPHA
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_STAR
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0
        }
        case 4: {
            parser.pattern.value = '\s'
            parser.pattern.length = 2
            parser.pattern.cursor = 1

            parser.count = 1

            parser.state[1].type = REGEX_TYPE_WHITESPACE
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0
        }
        case 5: {
            parser.pattern.value = '\s+'
            parser.pattern.length = 3
            parser.pattern.cursor = 1

            parser.count = 2

            parser.state[1].type = REGEX_TYPE_WHITESPACE
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_PLUS
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0
        }
        case 6: {
            parser.pattern.value = '\s*'
            parser.pattern.length = 3
            parser.pattern.cursor = 1

            parser.count = 2

            parser.state[1].type = REGEX_TYPE_WHITESPACE
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_STAR
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0
        }
        case 7: {
            parser.pattern.value = '\d\w?\s'
            parser.pattern.length = 7
            parser.pattern.cursor = 1

            parser.count = 4

            parser.state[1].type = REGEX_TYPE_DIGIT
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_ALPHA
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0

            parser.state[3].type = REGEX_TYPE_QUESTIONMARK
            // parser.state[3].value = 0
            parser.state[3].charclass.length = 0
            parser.state[3].charclass.cursor = 0
            // parser.state[3].charclass.value = 0

            parser.state[4].type = REGEX_TYPE_WHITESPACE
            // parser.state[4].value = 0
            parser.state[4].charclass.length = 0
            parser.state[4].charclass.cursor = 0
            // parser.state[4].charclass.value = 0
        }
        case 8: {
            parser.pattern.value = '\d\w\s+'
            parser.pattern.length = 7
            parser.pattern.cursor = 1

            parser.count = 4

            parser.state[1].type = REGEX_TYPE_DIGIT
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_ALPHA
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0

            parser.state[3].type = REGEX_TYPE_WHITESPACE
            // parser.state[3].value = 0
            parser.state[3].charclass.length = 0
            parser.state[3].charclass.cursor = 0
            // parser.state[3].charclass.value = 0

            parser.state[4].type = REGEX_TYPE_PLUS
            // parser.state[4].value = 0
            parser.state[4].charclass.length = 0
            parser.state[4].charclass.cursor = 0
            // parser.state[4].charclass.value = 0
        }
        case 9: {
            parser.pattern.value = '\d?\w\s*'
            parser.pattern.length = 8
            parser.pattern.cursor = 1

            parser.count = 5

            parser.state[1].type = REGEX_TYPE_DIGIT
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_QUESTIONMARK
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0

            parser.state[3].type = REGEX_TYPE_ALPHA
            // parser.state[3].value = 0
            parser.state[3].charclass.length = 0
            parser.state[3].charclass.cursor = 0
            // parser.state[3].charclass.value = 0

            parser.state[4].type = REGEX_TYPE_WHITESPACE
            // parser.state[4].value = 0
            parser.state[4].charclass.length = 0
            parser.state[4].charclass.cursor = 0
            // parser.state[4].charclass.value = 0

            parser.state[5].type = REGEX_TYPE_STAR
            // parser.state[5].value = 0
            parser.state[5].charclass.length = 0
            parser.state[5].charclass.cursor = 0
            // parser.state[5].charclass.value = 0
        }
        case 10: {
            parser.pattern.value = '\D+'
            parser.pattern.length = 3
            parser.pattern.cursor = 1

            parser.count = 2

            parser.state[1].type = REGEX_TYPE_NOT_DIGIT
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_PLUS
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0
        }
        case 11: {
            parser.pattern.value = '\D*'
            parser.pattern.length = 3
            parser.pattern.cursor = 1

            parser.count = 2

            parser.state[1].type = REGEX_TYPE_NOT_DIGIT
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_STAR
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0
        }
        case 12: {
            parser.pattern.value = '\D\s'
            parser.pattern.length = 4
            parser.pattern.cursor = 1

            parser.count = 2

            parser.state[1].type = REGEX_TYPE_NOT_DIGIT
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_WHITESPACE
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0
        }
        case 13: {
            parser.pattern.value = '\W+'
            parser.pattern.length = 3
            parser.pattern.cursor = 1

            parser.count = 2

            parser.state[1].type = REGEX_TYPE_NOT_ALPHA
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_PLUS
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0
        }
        case 14: {
            parser.pattern.value = '\S*'
            parser.pattern.length = 3
            parser.pattern.cursor = 1

            parser.count = 2

            parser.state[1].type = REGEX_TYPE_NOT_WHITESPACE
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_STAR
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0
        }
        case 15: {
            parser.pattern.value = '^[a-zA-Z0-9_]+$'
            parser.pattern.length = 15
            parser.pattern.cursor = 1

            parser.count = 4

            parser.state[1].type = REGEX_TYPE_BEGIN
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_CHAR_CLASS
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 10
            parser.state[2].charclass.cursor = 0
            parser.state[2].charclass.value = 'a-zA-Z0-9_'

            parser.state[3].type = REGEX_TYPE_PLUS
            // parser.state[3].value = 0
            parser.state[3].charclass.length = 0
            parser.state[3].charclass.cursor = 0
            // parser.state[3].charclass.value = 0

            parser.state[4].type = REGEX_TYPE_END
            // parser.state[4].value = 0
            parser.state[4].charclass.length = 0
            parser.state[4].charclass.cursor = 0
            // parser.state[4].charclass.value = 0
        }
        case 16: {
            parser.pattern.value = '^[Hh]ello,\s[Ww]orld!$'
            parser.pattern.length = 22
            parser.pattern.cursor = 1

            parser.count = 15

            parser.state[1].type = REGEX_TYPE_BEGIN
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_CHAR_CLASS
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 2
            parser.state[2].charclass.cursor = 0
            parser.state[2].charclass.value = 'Hh'

            parser.state[3].type = REGEX_TYPE_CHAR
            parser.state[3].value = 'e'
            parser.state[3].charclass.length = 0
            parser.state[3].charclass.cursor = 0
            // parser.state[3].charclass.value = 0

            parser.state[4].type = REGEX_TYPE_CHAR
            parser.state[4].value = 'l'
            parser.state[4].charclass.length = 0
            parser.state[4].charclass.cursor = 0
            // parser.state[4].charclass.value = 0

            parser.state[5].type = REGEX_TYPE_CHAR
            parser.state[5].value = 'l'
            parser.state[5].charclass.length = 0
            parser.state[5].charclass.cursor = 0
            // parser.state[5].charclass.value = 0

            parser.state[6].type = REGEX_TYPE_CHAR
            parser.state[6].value = 'o'
            parser.state[6].charclass.length = 0
            parser.state[6].charclass.cursor = 0
            // parser.state[6].charclass.value = 0

            parser.state[7].type = REGEX_TYPE_CHAR
            parser.state[7].value = ','
            parser.state[7].charclass.length = 0
            parser.state[7].charclass.cursor = 0
            // parser.state[7].charclass.value = 0

            parser.state[8].type = REGEX_TYPE_WHITESPACE
            // parser.state[8].value = 0
            parser.state[8].charclass.length = 0
            parser.state[8].charclass.cursor = 0
            // parser.state[8].charclass.value = 0

            parser.state[9].type = REGEX_TYPE_CHAR_CLASS
            // parser.state[9].value = 0
            parser.state[9].charclass.length = 2
            parser.state[9].charclass.cursor = 0
            parser.state[9].charclass.value = 'Ww'

            parser.state[10].type = REGEX_TYPE_CHAR
            parser.state[10].value = 'o'
            parser.state[10].charclass.length = 0
            parser.state[10].charclass.cursor = 0
            // parser.state[10].charclass.value = 0

            parser.state[11].type = REGEX_TYPE_CHAR
            parser.state[11].value = 'r'
            parser.state[11].charclass.length = 0
            parser.state[11].charclass.cursor = 0
            // parser.state[11].charclass.value = 0

            parser.state[12].type = REGEX_TYPE_CHAR
            parser.state[12].value = 'l'
            parser.state[12].charclass.length = 0
            parser.state[12].charclass.cursor = 0
            // parser.state[12].charclass.value = 0

            parser.state[13].type = REGEX_TYPE_CHAR
            parser.state[13].value = 'd'
            parser.state[13].charclass.length = 0
            parser.state[13].charclass.cursor = 0
            // parser.state[13].charclass.value = 0

            parser.state[14].type = REGEX_TYPE_CHAR
            parser.state[14].value = '!'
            parser.state[14].charclass.length = 0
            parser.state[14].charclass.cursor = 0
            // parser.state[14].charclass.value = 0

            parser.state[15].type = REGEX_TYPE_END
            // parser.state[15].value = 0
            parser.state[15].charclass.length = 0
            parser.state[15].charclass.cursor = 0
            // parser.state[15].charclass.value = 0
        }
        case 17: {
            parser.pattern.value = '^"[^"]*"'
            parser.pattern.length = 8
            parser.pattern.cursor = 1

            parser.count = 5

            parser.state[1].type = REGEX_TYPE_BEGIN
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_CHAR
            parser.state[2].value = '"'
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0

            parser.state[3].type = REGEX_TYPE_INV_CHAR_CLASS
            // parser.state[3].value = 0
            parser.state[3].charclass.length = 1
            parser.state[3].charclass.cursor = 0
            parser.state[3].charclass.value = '"'

            parser.state[4].type = REGEX_TYPE_STAR
            // parser.state[4].value = 0
            parser.state[4].charclass.length = 0
            parser.state[4].charclass.cursor = 0
            // parser.state[4].charclass.value = 0

            parser.state[5].type = REGEX_TYPE_CHAR
            parser.state[5].value = '"'
            parser.state[5].charclass.length = 0
            parser.state[5].charclass.cursor = 0
            // parser.state[5].charclass.value = 0
        }
        // case 18: {
        //     parser.pattern.value = '^([a-zA-Z_]\w*)\s*=\s*([^;#].*)'
        //     parser.pattern.length = 31
        //     parser.pattern.cursor = 1

        //     parser.count = 17

        //     parser.state[1].type = REGEX_TYPE_BEGIN
        //     // parser.state[1].value = 0
        //     parser.state[1].charclass.length = 0
        //     parser.state[1].charclass.cursor = 0
        //     // parser.state[1].charclass.value = 0

        //     parser.state[2].type = REGEX_TYPE_GROUP
        //     // parser.state[2].value = 0
        //     parser.state[2].charclass.length = 0
        //     parser.state[2].charclass.cursor = 0
        //     // parser.state[2].charclass.value = 0

        //     parser.state[2].type = REGEX_TYPE_CHAR_CLASS
        //     // parser.state[2].value = 0
        //     parser.state[2].charclass.length = 7
        //     parser.state[2].charclass.cursor = 0
        //     parser.state[2].charclass.value = 'a-zA-Z_'

        //     parser.state[3].type = REGEX_TYPE_CHAR_CLASS
        // }
        case 18: {
            parser.pattern.value = '.*'
            parser.pattern.length = 2
            parser.pattern.cursor = 1

            parser.count = 2

            parser.state[1].type = REGEX_TYPE_DOT
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_STAR
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0
        }
        case 19: {
            parser.pattern.value = '\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d'
            parser.pattern.length = 38
            parser.pattern.cursor = 1

            parser.count = 23

            parser.state[1].type = REGEX_TYPE_DIGIT
            // parser.state[1].value = 0
            parser.state[1].charclass.length = 0
            parser.state[1].charclass.cursor = 0
            // parser.state[1].charclass.value = 0

            parser.state[2].type = REGEX_TYPE_QUESTIONMARK
            // parser.state[2].value = 0
            parser.state[2].charclass.length = 0
            parser.state[2].charclass.cursor = 0
            // parser.state[2].charclass.value = 0

            parser.state[3].type = REGEX_TYPE_DIGIT
            // parser.state[3].value = 0
            parser.state[3].charclass.length = 0
            parser.state[3].charclass.cursor = 0
            // parser.state[3].charclass.value = 0

            parser.state[4].type = REGEX_TYPE_QUESTIONMARK
            // parser.state[4].value = 0
            parser.state[4].charclass.length = 0
            parser.state[4].charclass.cursor = 0
            // parser.state[4].charclass.value = 0

            parser.state[5].type = REGEX_TYPE_DIGIT
            // parser.state[5].value = 0
            parser.state[5].charclass.length = 0
            parser.state[5].charclass.cursor = 0
            // parser.state[5].charclass.value = 0

            parser.state[6].type = REGEX_TYPE_CHAR
            parser.state[6].value = '.'
            parser.state[6].charclass.length = 0
            parser.state[6].charclass.cursor = 0
            // parser.state[6].charclass.value = 0

            parser.state[7].type = REGEX_TYPE_DIGIT
            // parser.state[7].value = 0
            parser.state[7].charclass.length = 0
            parser.state[7].charclass.cursor = 0
            // parser.state[7].charclass.value = 0

            parser.state[8].type = REGEX_TYPE_QUESTIONMARK
            // parser.state[8].value = 0
            parser.state[8].charclass.length = 0
            parser.state[8].charclass.cursor = 0
            // parser.state[8].charclass.value = 0

            parser.state[9].type = REGEX_TYPE_DIGIT
            // parser.state[9].value = 0
            parser.state[9].charclass.length = 0
            parser.state[9].charclass.cursor = 0
            // parser.state[9].charclass.value = 0

            parser.state[10].type = REGEX_TYPE_QUESTIONMARK
            // parser.state[10].value = 0
            parser.state[10].charclass.length = 0
            parser.state[10].charclass.cursor = 0
            // parser.state[10].charclass.value = 0

            parser.state[11].type = REGEX_TYPE_DIGIT
            // parser.state[11].value = 0
            parser.state[11].charclass.length = 0
            parser.state[11].charclass.cursor = 0
            // parser.state[11].charclass.value = 0

            parser.state[12].type = REGEX_TYPE_CHAR
            parser.state[12].value = '.'
            parser.state[12].charclass.length = 0
            parser.state[12].charclass.cursor = 0
            // parser.state[12].charclass.value = 0

            parser.state[13].type = REGEX_TYPE_DIGIT
            // parser.state[13].value = 0
            parser.state[13].charclass.length = 0
            parser.state[13].charclass.cursor = 0
            // parser.state[13].charclass.value = 0

            parser.state[14].type = REGEX_TYPE_QUESTIONMARK
            // parser.state[14].value = 0
            parser.state[14].charclass.length = 0
            parser.state[14].charclass.cursor = 0
            // parser.state[14].charclass.value = 0

            parser.state[15].type = REGEX_TYPE_DIGIT
            // parser.state[15].value = 0
            parser.state[15].charclass.length = 0
            parser.state[15].charclass.cursor = 0
            // parser.state[15].charclass.value = 0

            parser.state[16].type = REGEX_TYPE_QUESTIONMARK
            // parser.state[16].value = 0
            parser.state[16].charclass.length = 0
            parser.state[16].charclass.cursor = 0
            // parser.state[16].charclass.value = 0

            parser.state[17].type = REGEX_TYPE_DIGIT
            // parser.state[17].value = 0
            parser.state[17].charclass.length = 0
            parser.state[17].charclass.cursor = 0
            // parser.state[17].charclass.value = 0

            parser.state[18].type = REGEX_TYPE_CHAR
            parser.state[18].value = '.'
            parser.state[18].charclass.length = 0
            parser.state[18].charclass.cursor = 0
            // parser.state[18].charclass.value = 0

            parser.state[19].type = REGEX_TYPE_DIGIT
            // parser.state[19].value = 0
            parser.state[19].charclass.length = 0
            parser.state[19].charclass.cursor = 0
            // parser.state[19].charclass.value = 0

            parser.state[20].type = REGEX_TYPE_QUESTIONMARK
            // parser.state[20].value = 0
            parser.state[20].charclass.length = 0
            parser.state[20].charclass.cursor = 0
            // parser.state[20].charclass.value = 0

            parser.state[21].type = REGEX_TYPE_DIGIT
            // parser.state[21].value = 0
            parser.state[21].charclass.length = 0
            parser.state[21].charclass.cursor = 0
            // parser.state[21].charclass.value = 0

            parser.state[22].type = REGEX_TYPE_QUESTIONMARK
            // parser.state[22].value = 0
            parser.state[22].charclass.length = 0
            parser.state[22].charclass.cursor = 0
            // parser.state[22].charclass.value = 0

            parser.state[23].type = REGEX_TYPE_DIGIT
            // parser.state[23].value = 0
            parser.state[23].charclass.length = 0
            parser.state[23].charclass.cursor = 0
            // parser.state[23].charclass.value = 0
        }
    }
}


define_function TestNAVRegexCompile() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexCompile *****************'")

    for (x = 1; x <= length_array(COMPILE_TEST); x++) {
        stack_var _NAVRegexParser parser
        stack_var _NAVRegexParser expected

        RegexCompileSetupExpected(x, expected)

        if (!NAVRegexCompile(COMPILE_TEST[x], parser)) {
            NAVLog("'Test ', itoa(x), ' failed'")
            NAVLog("'Failed to compile pattern: "', COMPILE_TEST[x], '"'")
            continue
        }

        if (!AssertRegexParserDeepEqual(parser, expected)) {
            NAVLog("'Test ', itoa(x), ' failed'")
            NAVLog("'The compiled parser did not deep match the expected parser'")
            continue
        }

        NAVLogTestPassed(x)
    }
}


define_function char AssertRegexParserDeepEqual(_NAVRegexParser actual, _NAVRegexParser expected) {
    stack_var integer x

    if (actual.pattern.value != expected.pattern.value) {
        NAVLog("'Expected pattern value to be "', expected.pattern.value, '" but got "', actual.pattern.value, '"'")
        return false
    }

    if (actual.pattern.length != expected.pattern.length) {
        NAVLog("'Expected pattern length to be ', itoa(expected.pattern.length), ' but got ', itoa(actual.pattern.length)")
        return false
    }

    if (actual.pattern.cursor != expected.pattern.cursor) {
        NAVLog("'Expected pattern cursor to be ', itoa(expected.pattern.cursor), ' but got ', itoa(actual.pattern.cursor)")
        return false
    }

    if (actual.count != expected.count) {
        NAVLog("'Expected state count to be ', itoa(expected.count), ' but got ', itoa(actual.count)")
        return false
    }

    for (x = 1; x <= expected.count; x++) {
        if (actual.state[x].type != expected.state[x].type) {
            NAVLog("'Expected state ', itoa(x), ' type to be "', REGEX_TYPES[expected.state[x].type], '" but got "', REGEX_TYPES[actual.state[x].type], '"'")
            return false
        }

        if (actual.state[x].value != expected.state[x].value) {
            NAVLog("'Expected state ', itoa(x), ' value to be "', expected.state[x].value, '" but got "', actual.state[x].value, '"'")
            return false
        }

        if (actual.state[x].charclass.length != expected.state[x].charclass.length) {
            NAVLog("'Expected state ', itoa(x), ' charclass length to be ', itoa(expected.state[x].charclass.length), ' but got ', itoa(actual.state[x].charclass.length)")
            return false
        }

        if (actual.state[x].charclass.cursor != expected.state[x].charclass.cursor) {
            NAVLog("'Expected state ', itoa(x), ' charclass cursor to be ', itoa(expected.state[x].charclass.cursor), ' but got ', itoa(actual.state[x].charclass.cursor)")
            return false
        }

        if (actual.state[x].charclass.value != expected.state[x].charclass.value) {
            NAVLog("'Expected state ', itoa(x), ' charclass value to be "', expected.state[x].charclass.value, '" but got "', actual.state[x].charclass.value, '"'")
            return false
        }
    }

    return true
}
