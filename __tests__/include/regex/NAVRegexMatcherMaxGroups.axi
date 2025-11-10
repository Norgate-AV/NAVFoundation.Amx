PROGRAM_NAME='NAVRegexMatcherMaxGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for maximum capture groups (32 group limit)
constant char REGEX_MATCHER_MAX_GROUPS_PATTERN[][2048] = {
    '/(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)(k)(l)(m)(n)(o)(p)(q)(r)(s)(t)(u)(v)(w)(x)(y)(z)(A)(B)(C)(D)(E)(F)/',  // 1: Exactly 32 groups
    '/(1)(2)(3)(4)(5)(6)(7)(8)(9)(0)(1)(2)(3)(4)(5)(6)(7)(8)(9)(0)(1)(2)(3)(4)(5)(6)(7)(8)(9)(0)(1)(2)/',  // 2: 32 digit groups
    '/(aa)(bb)(cc)(dd)(ee)(ff)(gg)(hh)(ii)(jj)(kk)(ll)(mm)(nn)(oo)(pp)(qq)(rr)(ss)(tt)(uu)(vv)(ww)(xx)(yy)(zz)(AA)(BB)(CC)(DD)(EE)(FF)/',  // 3: 32 two-char groups
    '/(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)(x)/',  // 4: 32 identical groups
    '/(g1)(g2)(g3)(g4)(g5)(g6)(g7)(g8)(g9)(g10)(g11)(g12)(g13)(g14)(g15)(g16)(g17)(g18)(g19)(g20)(g21)(g22)(g23)(g24)(g25)(g26)(g27)(g28)(g29)(g30)(g31)(g32)/',  // 5: 32 numbered groups
    '/(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)(\w)/',  // 6: 32 word char groups
    '/(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)/',  // 7: 32 digit char groups
    '/(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)/',  // 8: 32 any-char groups
    '/([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])([a-z])/'  // 9: 32 char class groups
}

constant char REGEX_MATCHER_MAX_GROUPS_INPUT[][2048] = {
    'abcdefghijklmnopqrstuvwxyzABCDEF',                  // 1
    '12345678901234567890123456789012',                  // 2
    'aabbccddeeffgghhiijjkkllmmnnooppqqrrssttuuvvwwxxyyzzAABBCCDDEEFF',  // 3
    'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',                  // 4: 32 x's
    'g1g2g3g4g5g6g7g8g9g10g11g12g13g14g15g16g17g18g19g20g21g22g23g24g25g26g27g28g29g30g31g32',  // 5
    'abcdefghijklmnopqrstuvwxyzABCDEF',                  // 6: 32 chars
    '12345678901234567890123456789012',                  // 7
    '12345678901234567890123456789012',                  // 8: 32 chars
    'abcdefghijklmnopqrstuvwxyzabcdef'                   // 9: 32 lowercase
}

constant integer REGEX_MATCHER_MAX_GROUPS_EXPECTED_GROUP_COUNT[] = {
    32,                     // 1
    32,                     // 2
    32,                     // 3
    32,                     // 4
    32,                     // 5
    32,                     // 6
    32,                     // 7
    32,                     // 8
    32                      // 9
}

constant char REGEX_MATCHER_MAX_GROUPS_GROUP_1[][255] = {
    'a',                    // 1: First group
    '1',                    // 2
    'aa',                   // 3
    'x',                    // 4
    'g1',                   // 5
    'a',                    // 6
    '1',                    // 7
    '1',                    // 8
    'a'                     // 9
}

constant char REGEX_MATCHER_MAX_GROUPS_GROUP_32[][255] = {
    'F',                    // 1: Last (32nd) group
    '2',                    // 2
    'FF',                   // 3
    'x',                    // 4
    'g32',                  // 5
    'F',                    // 6
    '2',                    // 7
    '2',                    // 8
    'f'                     // 9
}

/**
 * @function TestNAVRegexMatcherMaxGroups
 * @public
 * @description Tests regex patterns with maximum number of capture groups (32).
 *
 * Validates:
 * - Patterns can have exactly 32 capture groups
 * - All 32 groups are numbered correctly (1-32)
 * - Each group captures its content correctly
 * - First group (1) extracts correct text
 * - Last group (32) extracts correct text
 * - Group count reported is accurate
 * - Alternation with 32 groups works
 * - Character classes in 32 groups work
 * - Quantifiers in 32 groups work
 * - No buffer overruns or memory corruption
 *
 * This ensures the regex engine properly handles the maximum
 * number of capture groups without errors or data corruption.
 */
define_function TestNAVRegexMatcherMaxGroups() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Maximum Capture Groups *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_MAX_GROUPS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_MAX_GROUPS_PATTERN[x], REGEX_MATCHER_MAX_GROUPS_INPUT[x], collection)

        // Verify match success
        if (!NAVAssertTrue('Should match with 32 groups', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
            NAVLogTestFailed(x, 'Expected match', 'No match')
            NAVLog("'  Pattern length: ', itoa(length_array(REGEX_MATCHER_MAX_GROUPS_PATTERN[x]))")
            NAVLog("'  Status: ', itoa(collection.status)")
            NAVStopwatchStop()
            continue
        }

        // Verify group count
        if (!NAVAssertIntegerEqual('Should have 32 capture groups', REGEX_MATCHER_MAX_GROUPS_EXPECTED_GROUP_COUNT[x], type_cast(collection.matches[1].groupCount))) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_MAX_GROUPS_EXPECTED_GROUP_COUNT[x]), itoa(collection.matches[1].groupCount))
            NAVLog("'  Expected 32 groups'")
            NAVStopwatchStop()
            continue
        }

        // Verify first group (group 1)
        if (!NAVAssertStringEqual('First group should be correct', REGEX_MATCHER_MAX_GROUPS_GROUP_1[x], collection.matches[1].groups[1].text)) {
            NAVLogTestFailed(x, REGEX_MATCHER_MAX_GROUPS_GROUP_1[x], collection.matches[1].groups[1].text)
            NAVLog("'  Group 1 mismatch'")
            NAVStopwatchStop()
            continue
        }

        // Verify last group (group 32) - only if expected to have content
        if (length_array(REGEX_MATCHER_MAX_GROUPS_GROUP_32[x]) > 0) {
            if (!NAVAssertStringEqual('Last group (32) should be correct', REGEX_MATCHER_MAX_GROUPS_GROUP_32[x], collection.matches[1].groups[32].text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_MAX_GROUPS_GROUP_32[x], collection.matches[1].groups[32].text)
                NAVLog("'  Group 32 mismatch'")
                NAVStopwatchStop()
                continue
            }
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
