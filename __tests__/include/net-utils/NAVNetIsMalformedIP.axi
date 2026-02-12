PROGRAM_NAME='NAVNetIsMalformedIP.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_NET_IS_MALFORMED_IP_TESTS[][255] = {
    // Valid hostnames (should return false - NOT malformed IP)
    'example.com',              // 1: Simple hostname
    'www.example.com',          // 2: Subdomain
    'mail.example.co.uk',       // 3: Multiple subdomains
    'localhost',                // 4: Single label
    'my-server',                // 5: Hostname with hyphen
    'server_1',                 // 6: Hostname with underscore
    'example123',               // 7: Hostname with numbers
    '192abc',                   // 8: Mix of digits and letters
    'abc192',                   // 9: Letters then digits
    '192-168-1-1',              // 10: Hyphens instead of dots
    'server:8080',              // 11: Hostname with port
    'example.com:80',           // 12: FQDN with port
    '',                         // 13: Empty string

    // Malformed IPs (should return true - looks like IP but invalid)
    '256.1.1.1',                // 14: Octet out of range
    '192.168.1.256',            // 15: Last octet out of range
    '999.999.999.999',          // 16: All octets out of range
    '192.168.1',                // 17: Too few octets
    '192.168',                  // 18: Too few octets
    '192',                      // 19: Single number
    '192.168.1.1.1',            // 20: Too many octets
    '192.168..1',               // 21: Empty octet (double dots)
    '.192.168.1.1',             // 22: Leading dot
    '192.168.1.1.',             // 23: Trailing dot
    '...',                      // 24: Only dots
    '1.2.3.4.5.6',              // 25: Six octets
    '0.0.0.0',                  // 26: Valid format but could be malformed context
    '192.168.01.1',             // 27: Leading zero (malformed per strict RFC)
    '10.0.0.1',                 // 28: Valid format
    '....',                     // 29: Only dots (4)
    '1.2.3.',                   // 30: Three octets with trailing dot
    '.1.2.3',                   // 31: Three octets with leading dot
    '1..2.3',                   // 32: Empty second octet
    '1.2..3',                   // 33: Empty third octet
    '300.200.100.50',           // 34: First octet out of range
    '100.300.200.50',           // 35: Second octet out of range
    '100.200.300.50',           // 36: Third octet out of range
    '100.200.50.300',           // 37: Fourth octet out of range
    '999999999.1.1.1',          // 38: Huge first octet
    '1.999999999.1.1',          // 39: Huge second octet
    '1.1.999999999.1',          // 40: Huge third octet
    '1.1.1.999999999',          // 41: Huge fourth octet
    '0.0.0.',                   // 42: Three zeros with trailing dot
    '.0.0.0',                   // 43: Three zeros with leading dot
    '192.168.1.1.1.1.1.1',      // 44: Many octets
    '1.',                       // 45: Single digit with trailing dot
    '.1',                       // 46: Single digit with leading dot
    '12.34',                    // 47: Two octets only
    '1.2.3.4.5',                // 48: Five octets
    '256.256.256.256'           // 49: All octets at boundary (256)
}

constant char NAV_NET_IS_MALFORMED_IP_EXPECTED_RESULT[] = {
    // Valid hostnames - NOT malformed IPs (1-13)
    false, false, false, false, false, false, false, false, false, false,
    false, false, false,

    // Malformed IPs - contains only digits and dots (14-49)
    true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true
}

define_function TestNAVNetIsMalformedIP() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetIsMalformedIP')

    for (x = 1; x <= length_array(NAV_NET_IS_MALFORMED_IP_TESTS); x++) {
        stack_var char result
        stack_var char expected

        expected = NAV_NET_IS_MALFORMED_IP_EXPECTED_RESULT[x]
        result = NAVNetIsMalformedIP(NAV_NET_IS_MALFORMED_IP_TESTS[x])

        if (!NAVAssertBooleanEqual('Should detect malformed IP correctly', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetIsMalformedIP')
}
