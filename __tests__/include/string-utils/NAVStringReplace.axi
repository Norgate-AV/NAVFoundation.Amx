PROGRAM_NAME='NAVStringReplace'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char STRING_REPLACE_TEST[][][NAV_MAX_BUFFER] = {
    // {input, match, replacement, normalize}
    {'hello world', 'o', 'X'},                          // Basic single char replacement
    {'hello world', 'l', 'L'},                          // Multiple occurrences
    {'the-quick-brown-fox', '-', ' '},                  // Replace separators
    {'test   string', '  ', ' '},                       // Multiple spaces to single
    {'camelCaseText', 'camel', 'CAMEL'},               // Word replacement
    {'no matches here', 'xyz', '123'},                  // No matches
    {'', 'test', 'replace'},                           // Empty string
    {'multiple  spaces', ' ', '-'},                     // Space to dash (exact)
    {'multiple  spaces', ' ', '-', 'normalize'},        // Space to dash (normalized)
    {'...dots...here...', '...', '.'},                 // Multiple char sequence
    {'snake_case_text', '_', '-'},                     // Snake to kebab
    {'kebab-case-text', '-', '_'},                     // Kebab to snake
    {'test test test', 'test', 'CHECK'},               // Multiple word replacements
    {'aaa', 'a', 'b'}                                  // All chars same
}

constant char STRING_REPLACE_EXPECTED[][NAV_MAX_BUFFER] = {
    'hellX wXrld',                    // o -> X
    'heLLo worLd',                    // l -> L
    'the quick brown fox',            // - -> space
    'test string',                    // multiple spaces -> single
    'CAMELCaseText',                  // camel -> CAMEL
    'no matches here',                // xyz -> 123 (no change)
    '',                              // empty string
    'multiple--spaces',                // space -> dash (exact)
    'multiple-spaces',                 // space -> dash (normalized)
    '.dots.here.',                    // ... -> .
    'snake-case-text',                // _ -> -
    'kebab_case_text',                // - -> _
    'CHECK CHECK CHECK',              // test -> CHECK
    'bbb'                             // a -> b
}

define_function TestNAVStringReplace() {
    stack_var integer x

    NAVLog("'***************** NAVStringReplace *****************'")

    for (x = 1; x <= length_array(STRING_REPLACE_TEST); x++) {
        stack_var char input[NAV_MAX_BUFFER]
        stack_var char match[NAV_MAX_BUFFER]
        stack_var char replacement[NAV_MAX_BUFFER]
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        input = STRING_REPLACE_TEST[x][1]
        match = STRING_REPLACE_TEST[x][2]
        replacement = STRING_REPLACE_TEST[x][3]
        expected = STRING_REPLACE_EXPECTED[x]

        if (length_array(STRING_REPLACE_TEST[x]) > 3 && STRING_REPLACE_TEST[x][4] == 'normalize') {
            result = NAVStringNormalizeAndReplace(input, match, replacement)
        }
        else {
            result = NAVStringReplace(input, match, replacement)
        }

        if (!NAVAssertStringEqual('String Replace Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
