#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

/**
 * Tests for NAVResolveUrl function
 * RFC 3986 Section 5: Reference Resolution
 *
 * This test suite covers the RFC 3986 reference resolution examples
 * from Section 5.4 (Reference Resolution Examples)
 */
define_function TestNAVResolveUrl() {
    stack_var integer testNum
    stack_var char result[NAV_MAX_BUFFER]
    stack_var char base[NAV_MAX_BUFFER]

    NAVLog('***************** NAVResolveUrl - Reference Resolution *****************')

    // Base URL used for RFC 3986 Section 5.4 examples
    base = 'http://a/b/c/d;p?q'

    // Normal Examples (RFC 3986 Section 5.4.1)

    // Test 1: Absolute URL (returned as-is)
    testNum = 1
    result = NAVResolveUrl(base, 'http://example.com/path')

    if (!NAVAssertStringEqual('Should return absolute URL as-is', 'http://example.com/path', result)) {
        NAVLogTestFailed(testNum, 'http://example.com/path', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 2: Protocol-relative reference
    testNum = 2
    result = NAVResolveUrl(base, '//example.com/path')

    if (!NAVAssertStringEqual('Should resolve protocol-relative URL', 'http://example.com/path', result)) {
        NAVLogTestFailed(testNum, 'http://example.com/path', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 3: Absolute path
    testNum = 3
    result = NAVResolveUrl(base, '/x/y')

    if (!NAVAssertStringEqual('Should resolve absolute path', 'http://a/x/y', result)) {
        NAVLogTestFailed(testNum, 'http://a/x/y', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 4: Relative path - sibling
    testNum = 4
    result = NAVResolveUrl(base, 'g')

    if (!NAVAssertStringEqual('Should resolve relative path (sibling)', 'http://a/b/c/g', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 5: Relative path - current directory
    testNum = 5
    result = NAVResolveUrl(base, './g')

    if (!NAVAssertStringEqual('Should resolve relative path (./)', 'http://a/b/c/g', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 6: Relative path - subdirectory
    testNum = 6
    result = NAVResolveUrl(base, 'g/')

    if (!NAVAssertStringEqual('Should resolve relative path (subdirectory)', 'http://a/b/c/g/', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g/', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 7: Root-relative path
    testNum = 7
    result = NAVResolveUrl(base, '/g')

    if (!NAVAssertStringEqual('Should resolve root-relative path', 'http://a/g', result)) {
        NAVLogTestFailed(testNum, 'http://a/g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 8: Query replacement
    testNum = 8
    result = NAVResolveUrl(base, '?y')

    if (!NAVAssertStringEqual('Should replace query string', 'http://a/b/c/d;p?y', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/d;p?y', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 9: Path with query
    testNum = 9
    result = NAVResolveUrl(base, 'g?y')

    if (!NAVAssertStringEqual('Should resolve path with query', 'http://a/b/c/g?y', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g?y', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 10: Fragment only
    testNum = 10
    result = NAVResolveUrl(base, '#s')

    if (!NAVAssertStringEqual('Should replace fragment', 'http://a/b/c/d;p?q#s', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/d;p?q#s', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 11: Path with fragment
    testNum = 11
    result = NAVResolveUrl(base, 'g#s')

    if (!NAVAssertStringEqual('Should resolve path with fragment', 'http://a/b/c/g#s', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g#s', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 12: Path with query and fragment
    testNum = 12
    result = NAVResolveUrl(base, 'g?y#s')

    if (!NAVAssertStringEqual('Should resolve path with query and fragment', 'http://a/b/c/g?y#s', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g?y#s', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 13: Semicolon in path
    testNum = 13
    result = NAVResolveUrl(base, ';x')

    if (!NAVAssertStringEqual('Should resolve path with semicolon', 'http://a/b/c/;x', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/;x', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 14: Path with semicolon and query
    testNum = 14
    result = NAVResolveUrl(base, 'g;x?y#s')

    if (!NAVAssertStringEqual('Should resolve complex path', 'http://a/b/c/g;x?y#s', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g;x?y#s', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 15: Empty reference (remove fragment from base)
    testNum = 15
    result = NAVResolveUrl(base, '')

    if (!NAVAssertStringEqual('Should return base without fragment', 'http://a/b/c/d;p?q', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/d;p?q', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 16: Current directory (dot)
    testNum = 16
    result = NAVResolveUrl(base, '.')

    if (!NAVAssertStringEqual('Should resolve dot to current directory', 'http://a/b/c/', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 17: Current directory with slash
    testNum = 17
    result = NAVResolveUrl(base, './')

    if (!NAVAssertStringEqual('Should resolve dot-slash', 'http://a/b/c/', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 18: Parent directory
    testNum = 18
    result = NAVResolveUrl(base, '..')

    if (!NAVAssertStringEqual('Should resolve parent directory', 'http://a/b/', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 19: Parent directory with slash
    testNum = 19
    result = NAVResolveUrl(base, '../')

    if (!NAVAssertStringEqual('Should resolve parent directory with slash', 'http://a/b/', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 20: Parent directory then file
    testNum = 20
    result = NAVResolveUrl(base, '../g')

    if (!NAVAssertStringEqual('Should resolve parent then file', 'http://a/b/g', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 21: Two levels up
    testNum = 21
    result = NAVResolveUrl(base, '../..')

    if (!NAVAssertStringEqual('Should resolve two levels up', 'http://a/', result)) {
        NAVLogTestFailed(testNum, 'http://a/', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 22: Two levels up with slash
    testNum = 22
    result = NAVResolveUrl(base, '../../')

    if (!NAVAssertStringEqual('Should resolve two levels up with slash', 'http://a/', result)) {
        NAVLogTestFailed(testNum, 'http://a/', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 23: Two levels up then file
    testNum = 23
    result = NAVResolveUrl(base, '../../g')

    if (!NAVAssertStringEqual('Should resolve two levels up then file', 'http://a/g', result)) {
        NAVLogTestFailed(testNum, 'http://a/g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Abnormal Examples (RFC 3986 Section 5.4.2)

    // Test 24: Too many parent references (should stay at root)
    testNum = 24
    result = NAVResolveUrl(base, '../../../g')

    if (!NAVAssertStringEqual('Should not go above root', 'http://a/g', result)) {
        NAVLogTestFailed(testNum, 'http://a/g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 25: Excessive parent references
    testNum = 25
    result = NAVResolveUrl(base, '../../../../g')

    if (!NAVAssertStringEqual('Should handle excessive parent refs', 'http://a/g', result)) {
        NAVLogTestFailed(testNum, 'http://a/g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 26: Remove dot segments from absolute path
    testNum = 26
    result = NAVResolveUrl(base, '/./g')

    if (!NAVAssertStringEqual('Should remove dot from absolute path', 'http://a/g', result)) {
        NAVLogTestFailed(testNum, 'http://a/g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 27: Remove double-dot segments from absolute path
    testNum = 27
    result = NAVResolveUrl(base, '/../g')

    if (!NAVAssertStringEqual('Should handle parent dir in absolute path', 'http://a/g', result)) {
        NAVLogTestFailed(testNum, 'http://a/g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 28: Relative path with unnecessary dots
    testNum = 28
    result = NAVResolveUrl(base, 'g.')

    if (!NAVAssertStringEqual('Should resolve path ending with dot', 'http://a/b/c/g.', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g.', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 29: Relative path with dot prefix
    testNum = 29
    result = NAVResolveUrl(base, '.g')

    if (!NAVAssertStringEqual('Should resolve path starting with dot', 'http://a/b/c/.g', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/.g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 30: Relative path with double dots
    testNum = 30
    result = NAVResolveUrl(base, 'g..')

    if (!NAVAssertStringEqual('Should resolve path with double dots', 'http://a/b/c/g..', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g..', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 31: Relative path with prefix double dots
    testNum = 31
    result = NAVResolveUrl(base, '..g')

    if (!NAVAssertStringEqual('Should resolve path with prefix double dots', 'http://a/b/c/..g', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/..g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 32: Complex nested path
    testNum = 32
    result = NAVResolveUrl(base, './../g')

    if (!NAVAssertStringEqual('Should resolve complex nested path', 'http://a/b/g', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/g', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 33: Nonsensical path
    testNum = 33
    result = NAVResolveUrl(base, './g/.')

    if (!NAVAssertStringEqual('Should normalize nonsensical path', 'http://a/b/c/g/', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g/', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 34: Path with double slashes
    testNum = 34
    result = NAVResolveUrl(base, 'g/./h')

    if (!NAVAssertStringEqual('Should resolve path with dot segment', 'http://a/b/c/g/h', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g/h', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 35: Path with parent reference in middle
    testNum = 35
    result = NAVResolveUrl(base, 'g/../h')

    if (!NAVAssertStringEqual('Should resolve path with parent in middle', 'http://a/b/c/h', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/h', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 36: Path with semicolon and equals
    testNum = 36
    result = NAVResolveUrl(base, 'g;x=1/./y')

    if (!NAVAssertStringEqual('Should resolve path with params', 'http://a/b/c/g;x=1/y', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/g;x=1/y', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 37: Path with params and parent ref
    testNum = 37
    result = NAVResolveUrl(base, 'g;x=1/../y')

    if (!NAVAssertStringEqual('Should resolve path with params and parent', 'http://a/b/c/y', result)) {
        NAVLogTestFailed(testNum, 'http://a/b/c/y', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Additional practical tests

    // Test 38: HTTPS base with relative path
    testNum = 38
    result = NAVResolveUrl('https://example.com/api/v1/users', 'posts')

    if (!NAVAssertStringEqual('Should resolve HTTPS relative path', 'https://example.com/api/v1/posts', result)) {
        NAVLogTestFailed(testNum, 'https://example.com/api/v1/posts', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 39: Base with port and relative path
    testNum = 39
    result = NAVResolveUrl('http://localhost:8080/app/page', 'admin')

    if (!NAVAssertStringEqual('Should preserve port in resolution', 'http://localhost:8080/app/admin', result)) {
        NAVLogTestFailed(testNum, 'http://localhost:8080/app/admin', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 40: Base with default port (should be omitted)
    testNum = 40
    result = NAVResolveUrl('http://example.com:80/path', 'file.html')

    if (!NAVAssertStringEqual('Should omit default port in result', 'http://example.com/file.html', result)) {
        NAVLogTestFailed(testNum, 'http://example.com/file.html', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }
}
