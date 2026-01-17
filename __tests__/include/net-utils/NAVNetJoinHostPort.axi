PROGRAM_NAME='NAVNetJoinHostPort.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVNetJoinHostPort - host inputs
constant char NAV_NET_JOIN_HOST_PORT_HOST_TESTS[][255] = {
    // Valid hosts
    '192.168.1.1',          // 1: IP address
    'example.com',          // 2: Hostname
    '127.0.0.1',            // 3: Localhost IP
    'localhost',            // 4: Localhost name
    '10.0.0.1',             // 5: Private IP
    'server.local',         // 6: Local hostname
    'my-server.com',        // 7: Hostname with hyphen
    '255.255.255.255',      // 8: Max IP
    '0.0.0.0',              // 9: Min IP
    'test123.example.org',  // 10: Complex hostname

    // Invalid hosts
    '',                     // 11: Empty host
    '   ',                  // 12: Whitespace only host
    '192.168.1.1',          // 13: Valid host but will test with invalid port
    '192.168.1.1',          // 14: Valid host but will test with invalid port
    '192.168.1.1'           // 15: Valid host but will test with invalid port
}

// Test cases for NAVNetJoinHostPort - port inputs
constant integer NAV_NET_JOIN_HOST_PORT_PORT_TESTS[] = {
    // Valid ports (matching valid hosts 1-10)
    8080,
    8080,
    80,
    3000,
    443,
    22,
    9999,
    65535,
    1,
    0,

    // Invalid combinations (matching invalid hosts 11-15)
    8080,       // 11: Valid port but empty host
    8080,       // 12: Valid port but whitespace host
    -1,         // 13: Negative port
    65536,      // 14: Port too large
    999999      // 15: Port way too large
}

// Expected results: true = should succeed, false = should fail
constant char NAV_NET_JOIN_HOST_PORT_EXPECTED_RESULT[] = {
    // Valid (1-10)
    true, true, true, true, true, true, true, true, true, true,
    // Invalid (11-15)
    false, false, false, false, false
}

// Expected output strings for valid tests (first 10)
constant char NAV_NET_JOIN_HOST_PORT_EXPECTED_OUTPUT[][255] = {
    '192.168.1.1:8080',
    'example.com:8080',
    '127.0.0.1:80',
    'localhost:3000',
    '10.0.0.1:443',
    'server.local:22',
    'my-server.com:9999',
    '255.255.255.255:65535',
    '0.0.0.0:1',
    'test123.example.org:0'
}


define_function TestNAVNetJoinHostPort() {
    stack_var integer x
    stack_var integer validCount

    NAVLog("'***************** NAVNetJoinHostPort *****************'")

    validCount = 0

    for (x = 1; x <= length_array(NAV_NET_JOIN_HOST_PORT_HOST_TESTS); x++) {
        stack_var char result[NAV_MAX_BUFFER]
        stack_var char shouldPass

        shouldPass = NAV_NET_JOIN_HOST_PORT_EXPECTED_RESULT[x]
        result = NAVNetJoinHostPort(NAV_NET_JOIN_HOST_PORT_HOST_TESTS[x],
                                    NAV_NET_JOIN_HOST_PORT_PORT_TESTS[x])

        if (shouldPass) {
            // Should succeed - verify output matches expected
            validCount++

            if (!NAVAssertStringEqual('Should result in the correct host:port format', NAV_NET_JOIN_HOST_PORT_EXPECTED_OUTPUT[validCount], result)) {
                NAVLogTestFailed(x, NAV_NET_JOIN_HOST_PORT_EXPECTED_OUTPUT[validCount], result)
                continue
            }
        }
        else {
            // Should fail - verify empty string returned
            if (!NAVAssertStringEqual('Should return empty string for invalid input', '', result)) {
                NAVLogTestFailed(x, "''", result)
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
