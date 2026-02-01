PROGRAM_NAME='NAVNetParseIPAddr.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVNetParseIPAddr
constant char NAV_NET_PARSE_IPADDR_TESTS[][255] = {
    // Valid IP:port combinations
    '192.168.1.1:8080',         // 1: Standard format
    '127.0.0.1:80',             // 2: Localhost with port
    '10.0.0.1:443',             // 3: Private IP with HTTPS port
    '8.8.8.8:53',               // 4: DNS server with DNS port
    '255.255.255.255:65535',    // 5: Max IP with max port
    '0.0.0.0:1',                // 6: Min IP with min port
    '192.168.1.1:0',            // 7: IP with port 0
    ' 192.168.1.1:8080 ',       // 8: With whitespace
    '172.16.0.1:3000',          // 9: Private network
    '203.0.113.1:22',           // 10: TEST-NET-3 with SSH port

    // Valid IP without port
    '192.168.1.1',              // 11: IP only (no port)
    '127.0.0.1',                // 12: Localhost only
    ' 192.168.1.1 ',            // 13: IP with whitespace, no port

    // Invalid - bad IP format
    '256.1.1.1:8080',           // 14: Invalid IP (octet > 255)
    '192.168.1:8080',           // 15: Invalid IP (too few octets)
    '192.168.1.1.1:8080',       // 16: Invalid IP (too many octets)
    '192.168.01.1:8080',        // 17: Invalid IP (leading zero)
    'abc.def.ghi.jkl:8080',     // 18: Invalid IP (letters)

    // Invalid - bad port format
    '192.168.1.1:',             // 19: Missing port after colon
    '192.168.1.1:abc',          // 20: Non-numeric port
    '192.168.1.1:65536',        // 21: Port too large
    '192.168.1.1:-80',          // 22: Negative port
    '192.168.1.1:12a34',        // 23: Port with letters

    // Invalid - bad overall format
    '',                         // 24: Empty string
    '   ',                      // 25: Whitespace only
    ':8080',                    // 26: Port only (no IP)
    '192.168.1.1::8080',        // 27: Double colon
    'hostname:8080',            // 28: Hostname instead of IP
    '192.168.1.1:80:80'         // 29: Multiple colons
}

// Expected results: true = should parse successfully, false = should fail
constant char NAV_NET_PARSE_IPADDR_EXPECTED_RESULT[] = {
    // Valid with port (1-10)
    true, true, true, true, true, true, true, true, true, true,
    // Valid without port (11-13)
    true, true, true,
    // Invalid (14-29)
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false
}

// Expected port values for valid tests (first 13)
constant integer NAV_NET_PARSE_IPADDR_EXPECTED_PORT[] = {
    8080,
    80,
    443,
    53,
    65535,
    1,
    0,
    8080,
    3000,
    22,
    0,    // No port specified
    0,    // No port specified
    0     // No port specified
}

// Expected IP octets for valid tests (first 13)
constant char NAV_NET_PARSE_IPADDR_EXPECTED_OCTETS[][4] = {
    {192, 168, 1, 1},
    {127, 0, 0, 1},
    {10, 0, 0, 1},
    {8, 8, 8, 8},
    {255, 255, 255, 255},
    {0, 0, 0, 0},
    {192, 168, 1, 1},
    {192, 168, 1, 1},
    {172, 16, 0, 1},
    {203, 0, 113, 1},
    {192, 168, 1, 1},
    {127, 0, 0, 1},
    {192, 168, 1, 1}
}

// Expected IP strings for valid tests (first 13)
constant char NAV_NET_PARSE_IPADDR_EXPECTED_STRINGS[][45] = {
    '192.168.1.1',
    '127.0.0.1',
    '10.0.0.1',
    '8.8.8.8',
    '255.255.255.255',
    '0.0.0.0',
    '192.168.1.1',
    '192.168.1.1',
    '172.16.0.1',
    '203.0.113.1',
    '192.168.1.1',
    '127.0.0.1',
    '192.168.1.1'
}

define_function TestNAVNetParseIPAddr() {
    stack_var integer x
    stack_var integer validCount

    NAVLogTestSuiteStart('NAVNetParseIPAddr')

    validCount = 0

    for (x = 1; x <= length_array(NAV_NET_PARSE_IPADDR_TESTS); x++) {
        stack_var char result
        stack_var _NAVIPAddr addr
        stack_var char shouldPass

        shouldPass = NAV_NET_PARSE_IPADDR_EXPECTED_RESULT[x]
        result = NAVNetParseIPAddr(NAV_NET_PARSE_IPADDR_TESTS[x], addr)

        // Check if result matches expectation
        if (!NAVAssertBooleanEqual('Should parse with the expected result', shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        if (!shouldPass) {
            // If should fail, no further checks needed
            NAVLogTestPassed(x)
            continue
        }

        // If should pass, validate IP and port
        {
            stack_var char failed
            stack_var integer y

            validCount++
            failed = false

            // Check IP version
            if (!NAVAssertCharEqual('Should have IP version 4', 4, addr.IP.Version)) {
                NAVLogTestFailed(x, '4', itoa(addr.IP.Version))
                failed = true
            }

            if (failed) {
                continue
            }

            // Check each octet
            for (y = 1; y <= 4; y++) {
                if (!NAVAssertCharEqual("'Should have the correct octet ', itoa(y), ' value'", NAV_NET_PARSE_IPADDR_EXPECTED_OCTETS[validCount][y], addr.IP.Octets[y])) {
                    NAVLogTestFailed(x, itoa(NAV_NET_PARSE_IPADDR_EXPECTED_OCTETS[validCount][y]), itoa(addr.IP.Octets[y]))
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }

            // Check normalized string
            if (!NAVAssertStringEqual('Should result in the correct normalized IP address', NAV_NET_PARSE_IPADDR_EXPECTED_STRINGS[validCount], addr.IP.Address)) {
                NAVLogTestFailed(x, NAV_NET_PARSE_IPADDR_EXPECTED_STRINGS[validCount], addr.IP.Address)
                continue
            }

            // Check port
            if (!NAVAssertIntegerEqual('Should have the correct port value', NAV_NET_PARSE_IPADDR_EXPECTED_PORT[validCount], addr.Port)) {
                NAVLogTestFailed(x, itoa(NAV_NET_PARSE_IPADDR_EXPECTED_PORT[validCount]), itoa(addr.Port))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetParseIPAddr')
}
