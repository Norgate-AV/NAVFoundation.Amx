PROGRAM_NAME='NAVUrlPathNormalization'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Url.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// RFC 3986 Section 5.2.4 Path Normalization Test Cases
// These test the removal of dot-segments from URL paths

constant char PATH_NORMALIZATION_URLS[][NAV_MAX_BUFFER] = {
    // RFC 3986 Section 5.4.2 Examples
    'http://example.com/a/b/c/./../../g',           // 1: Complex dot-segment removal
    'http://example.com/mid/content=5/../6',        // 2: Relative with parent
    'http://example.com/a/./b/../c',                // 3: Current and parent segments
    'http://example.com/./this:that',               // 4: Leading current directory

    // Single dot-segment removal (current directory)
    'http://example.com/a/b/c/.',                   // 5: Trailing current directory
    'http://example.com/a/b/c/./',                  // 6: Trailing current directory with slash
    'http://example.com/./a/b/c',                   // 7: Leading current directory
    'http://example.com/a/./b/./c',                 // 8: Multiple current directories
    'http://example.com/a/./././b',                 // 9: Consecutive current directories

    // Double dot-segment removal (parent directory)
    'http://example.com/a/b/c/..',                  // 10: Trailing parent directory
    'http://example.com/a/b/c/../',                 // 11: Trailing parent directory with slash
    'http://example.com/a/b/c/../..',               // 12: Two parent directories
    'http://example.com/a/b/c/../../',              // 13: Two parent directories with slash
    'http://example.com/a/b/c/../../../',           // 14: Three parent directories (goes to root)
    'http://example.com/a/b/../c/../d',             // 15: Multiple scattered parent directories

    // Duplicate slash removal
    'http://example.com//a//b//c',                  // 16: Multiple duplicate slashes
    'http://example.com/a///b////c',                // 17: Various duplicate slashes
    'http://example.com///',                        // 18: Only slashes

    // Complex combinations
    'http://example.com/a/b/c/./../../d/../e',      // 19: Mixed dot-segments
    'http://example.com/./a/../b/./c/../d',         // 20: Alternating dot-segments
    'http://example.com//a/./b/..//c',              // 21: Slashes and dot-segments

    // Root path scenarios
    'http://example.com/',                          // 22: Just root (should stay root)
    'http://example.com/.',                         // 23: Root with current directory
    'http://example.com/./',                        // 24: Root with current directory and slash
    'http://example.com/..',                        // 25: Root with parent (can't go above root)
    'http://example.com/../',                       // 26: Root with parent and slash

    // Paths with query and fragment
    'http://example.com/a/./b?query=1',             // 27: Current directory before query
    'http://example.com/a/../b?query=1',            // 28: Parent directory before query
    'http://example.com/a/b/c/./../../g?q=1#frag',  // 29: Complex with query and fragment
    'http://example.com/a/./b#fragment',            // 30: Current directory before fragment
    'http://example.com/a/../b#fragment',           // 31: Parent directory before fragment

    // Empty and edge cases
    'http://example.com',                           // 32: No path (empty)
    'http://example.com/a',                         // 33: Simple path (no normalization needed)
    'http://example.com/a/b/c',                     // 34: Normal path (no normalization needed)

    // Trailing slashes preservation
    'http://example.com/a/b/',                      // 35: Trailing slash (should be preserved)
    'http://example.com/a/./b/',                    // 36: Current directory with trailing slash
    'http://example.com/a/b/../c/',                 // 37: Parent directory with trailing slash

    // Edge case: dot-segments that look like file extensions
    'http://example.com/file.txt',                  // 38: File with extension (not a dot-segment)
    'http://example.com/path/to/file.txt',          // 39: Path to file with extension
    'http://example.com/a.b/c.d/file.txt',          // 40: Multiple dots in path components

    // Relative paths (no scheme/host)
    'http://example.com/./relative/path',           // 41: Relative with current directory
    'http://example.com/../relative/path',          // 42: Relative with parent directory

    // Port and userinfo with path normalization
    'http://example.com:8080/a/./b/../c',           // 43: With port
    'http://user:pass@example.com/a/../b',          // 44: With userinfo
    'http://user:pass@example.com:8080/a/./b',      // 45: With userinfo and port

    // IPv6 with path normalization
    'http://[::1]/a/./b/../c',                      // 46: IPv6 localhost
    'http://[2001:db8::1]/a/b/c/./../../g',         // 47: IPv6 address

    // Special characters in path (should not affect normalization)
    'http://example.com/a%20b/./c',                 // 48: Percent-encoded space
    'http://example.com/a+b/../c',                  // 49: Plus sign
    'http://example.com/path%2Fwith%2Fencoded/./slashes', // 50: Encoded slashes

    // Multiple consecutive dot-segments
    'http://example.com/a/b/../../c',               // 51: Two parent directories
    'http://example.com/a/b/c/../../../d',          // 52: Three parent directories to root then down
    'http://example.com/a/./././b',                 // 53: Multiple consecutive current directories

    // Dot-segments at different positions
    'http://example.com/./././',                    // 54: Only current directories
    'http://example.com/../../../',                 // 55: Only parent directories (can't go above root)

    // Real-world scenarios
    'http://cdn.example.com/assets/../images/logo.png',      // 56: CDN asset path
    'http://api.example.com/v1/users/../admin/settings',     // 57: API endpoint
    'http://example.com/public/./../../private/data',        // 58: Security test (shouldn't escape public)
    'http://example.com/docs/./guide/../../api/reference'    // 59: Documentation path
}

constant char PATH_NORMALIZATION_EXPECTED[][NAV_MAX_BUFFER] = {
    // RFC 3986 Section 5.4.2 Examples
    '/a/g',                                         // 1
    '/mid/6',                                       // 2
    '/a/c',                                         // 3
    '/this:that',                                   // 4

    // Single dot-segment removal
    '/a/b/c',                                       // 5
    '/a/b/c/',                                      // 6
    '/a/b/c',                                       // 7
    '/a/b/c',                                       // 8
    '/a/b',                                         // 9

    // Double dot-segment removal
    '/a/b',                                         // 10
    '/a/b/',                                        // 11
    '/a',                                           // 12
    '/a/',                                          // 13
    '/',                                            // 14
    '/a/d',                                         // 15

    // Duplicate slash removal
    '/a/b/c',                                       // 16
    '/a/b/c',                                       // 17
    '/',                                            // 18

    // Complex combinations
    '/a/e',                                         // 19
    '/b/d',                                         // 20
    '/a/c',                                         // 21

    // Root path scenarios
    '/',                                            // 22
    '/',                                            // 23
    '/',                                            // 24
    '/',                                            // 25
    '/',                                            // 26

    // Paths with query and fragment (query/fragment not normalized)
    '/a/b',                                         // 27
    '/b',                                           // 28
    '/a/g',                                         // 29
    '/a/b',                                         // 30
    '/b',                                           // 31

    // Empty and edge cases
    '',                                             // 32
    '/a',                                           // 33
    '/a/b/c',                                       // 34

    // Trailing slashes preservation
    '/a/b/',                                        // 35
    '/a/b/',                                        // 36
    '/a/c/',                                        // 37

    // Edge case: dot-segments that look like file extensions
    '/file.txt',                                    // 38
    '/path/to/file.txt',                            // 39
    '/a.b/c.d/file.txt',                            // 40

    // Relative paths
    '/relative/path',                               // 41
    '/relative/path',                               // 42

    // Port and userinfo with path normalization
    '/a/c',                                         // 43
    '/b',                                           // 44
    '/a/b',                                         // 45

    // IPv6 with path normalization
    '/a/c',                                         // 46
    '/a/g',                                         // 47

    // Special characters in path
    '/a%20b/c',                                     // 48
    '/c',                                           // 49
    '/path%2Fwith%2Fencoded/slashes',               // 50

    // Multiple consecutive dot-segments
    '/c',                                           // 51
    '/d',                                           // 52
    '/a/b',                                         // 53

    // Dot-segments at different positions
    '/',                                            // 54
    '/',                                            // 55

    // Real-world scenarios
    '/images/logo.png',                             // 56
    '/v1/admin/settings',                           // 57
    '/private/data',                                // 58
    '/api/reference'                                // 59 (fixed: /docs/./guide/../.. resolves to /)
}


/**
 * Test URL path normalization
 * Tests that paths are normalized according to RFC 3986 Section 5.2.4
 */
define_function TestNAVUrlPathNormalization() {
    stack_var integer x

    NAVLog("'***************** URL Path Normalization *****************'")

    for (x = 1; x <= length_array(PATH_NORMALIZATION_URLS); x++) {
        stack_var _NAVUrl url
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result

        expected = PATH_NORMALIZATION_EXPECTED[x]

        result = NAVParseUrl(PATH_NORMALIZATION_URLS[x], url)

        // Parse the URL (which should normalize the path automatically)
        if (!NAVAssertTrue('Should parse URL', result)) {
            NAVLogTestFailed(x, 'Valid URL', 'Invalid URL')
            continue
        }

        if (!NAVAssertStringEqual('Should normalize path correctly', expected, url.Path)) {
            NAVLogTestFailed(x, expected, url.Path)
            continue
        }

        NAVLogTestPassed(x)
    }
}
/**
 * Test the NAVUrlNormalizePath function directly
 * Tests the function in isolation from URL parsing
 */
define_function TestNAVUrlNormalizePathFunction() {
    stack_var integer x

    // Test data for direct function calls (just paths, no URLs)
    stack_var char testPaths[10][NAV_MAX_BUFFER]
    stack_var char expectedResults[10][NAV_MAX_BUFFER]

    NAVLog("'***************** NAVUrlNormalizePath Function *****************'")

    testPaths[1] = '/a/b/c/./../../g'
    expectedResults[1] = '/a/g'

    testPaths[2] = '/mid/content=5/../6'
    expectedResults[2] = '/mid/6'

    testPaths[3] = '/a/./b/../c'
    expectedResults[3] = '/a/c'

    testPaths[4] = '/a/b/c/.'
    expectedResults[4] = '/a/b/c'

    testPaths[5] = '/a/b/c/./'
    expectedResults[5] = '/a/b/c/'

    testPaths[6] = '/a/b/c/..'
    expectedResults[6] = '/a/b'

    testPaths[7] = '/a/b/c/../'
    expectedResults[7] = '/a/b/'

    testPaths[8] = '//a//b//c'
    expectedResults[8] = '/a/b/c'

    testPaths[9] = '/'
    expectedResults[9] = '/'

    testPaths[10] = ''
    expectedResults[10] = ''

    set_length_array(testPaths, 10)
    set_length_array(expectedResults, 10)

    for (x = 1; x <= length_array(testPaths); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = expectedResults[x]
        result = NAVUrlNormalizePath(testPaths[x])

        if (!NAVAssertStringEqual('Should normalize path correctly', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
