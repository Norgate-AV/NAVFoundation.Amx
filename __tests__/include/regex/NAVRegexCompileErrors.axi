PROGRAM_NAME='NAVRegexCompileErrors'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_COMPILE_ERROR_PATTERNS[][255] = {
    // Character class errors
    '/[abc/',               // 1: Unclosed character class
    '/[a-z/',               // 2: Unclosed character class with range
    '/[[nested]/',          // 3: Unclosed outer character class

    // Group errors
    '/(abc/',               // 4: Unclosed group
    '/abc)/',               // 5: Unopened group (extra closing paren)
    '/(abc(def)/',          // 6: Unclosed outer group with closed inner
    '/((abc)/',             // 7: Unclosed outer of nested groups
    '/(abc(def/',           // 8: Multiple unclosed groups

    // Quantifier errors
    '/+abc/',               // 9: Quantifier at start (nothing to quantify)
    '/*abc/',               // 10: Star at start (nothing to quantify)
    '/?abc/',               // 11: Question mark at start (nothing to quantify)
    '/a++/',                // 12: Consecutive quantifiers
    '/a**/',                // 13: Consecutive stars
    '/a+*/',                // 14: Plus followed by star
    '/a*+/',                // 15: Star followed by plus
    '/a?+/',                // 16: Question mark followed by plus

    // Bounded quantifier errors
    '/a{/',                 // 17: Unclosed bounded quantifier
    '/a{3/',                // 18: Unclosed bounded quantifier with number
    '/a{3,/',               // 19: Unclosed bounded quantifier with range start
    '/a{3,5/',              // 20: Unclosed bounded quantifier with range
    '/a{}/',                // 21: Empty bounded quantifier
    '/a{,5}/',              // 22: Missing min value
    '/a{5,3}/',             // 23: Max less than min (invalid range)
    '/a{abc}/',             // 24: Non-numeric content in braces
    '/a{3,2,1}/',           // 25: Too many commas in bounded quantifier
    '/{3}abc/',             // 26: Bounded quantifier at start (nothing to quantify)

    // Escape sequence errors
    '/abc\/',               // 27: Trailing backslash (incomplete escape)
    '/\/',                  // 28: Pattern with only backslash

    // Mixed errors
    '/[abc(def/',           // 29: Unclosed char class and unclosed group
    '/(abc[def/',           // 30: Unclosed group and unclosed char class
    '/[abc]+{2}/',          // 31: Quantifier followed by bounded quantifier
    '/a{2}+/',              // 32: Bounded quantifier followed by plus

    // Group limit errors (if we want to test max 50 groups)
    '/()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()/',  // 33: Exactly 51 groups (should fail)

    // Empty pattern edge cases
    '//',                   // 34: Completely empty pattern
    '/\//',                 // 35: Just escaped forward slash

    // Invalid escape sequences (depending on your implementation)
    '/\k/',                 // 36: Invalid escape character (if not supported)
    '/\z/'                  // 37: Invalid escape character (if not supported)
}


define_function TestNAVRegexCompileErrors() {
    stack_var integer x

    NAVLog("'***************** NAVRegexCompile - Error Cases *****************'")

    for (x = 1; x <= length_array(REGEX_COMPILE_ERROR_PATTERNS); x++) {
        stack_var _NAVRegexParser parser
        stack_var char result

        result = NAVRegexCompile(REGEX_COMPILE_ERROR_PATTERNS[x], parser)

        if (!NAVAssertFalse('Should fail to compile', result)) {
            NAVLogTestFailed(x, 'false', 'true')
            continue
        }

        NAVLogTestPassed(x)
    }
}
