PROGRAM_NAME='NAVNetSplitHostPort.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVNetSplitHostPort
constant char NAV_NET_SPLIT_HOST_PORT_TESTS[][255] = {
    // Valid formats with port
    '192.168.1.1:8080',         // 1: IP with port
    'example.com:8080',         // 2: Hostname with port
    '127.0.0.1:80',             // 3: Localhost with port
    '10.0.0.1:443',             // 4: Private IP with port
    'server.local:3000',        // 5: Local hostname with port
    '192.168.1.1:1',            // 6: Minimum port (1)
    '192.168.1.1:65535',        // 7: Maximum port (65535)
    '192.168.1.1:0',            // 8: Port 0 (technically valid)
    ' 192.168.1.1:8080 ',       // 9: With whitespace (trimmed)
    'my-server.com:9999',       // 10: Hostname with hyphen

    // Valid formats without port
    '192.168.1.1',              // 11: IP only (no port)
    'example.com',              // 12: Hostname only (no port)
    'localhost',                // 13: Simple hostname (no port)
    ' 192.168.1.1 ',            // 14: IP with whitespace, no port

    // Invalid formats
    '',                         // 15: Empty string
    '   ',                      // 16: Whitespace only
    ':8080',                    // 17: Port only (no host)
    '192.168.1.1:',             // 18: Trailing colon (no port)
    ':',                        // 19: Colon only
    '192.168.1.1:abc',          // 20: Non-numeric port
    '192.168.1.1:12a34',        // 21: Port with letters
    '192.168.1.1:-80',          // 22: Negative port
    '192.168.1.1:65536',        // 23: Port too large (> 65535)
    '192.168.1.1:999999',       // 24: Port way too large
    '192.168.1.1:80:80',        // 25: Multiple colons
    '192.168.1.1::8080',        // 26: Double colon
    '192.168.1.1: 8080',        // 27: Space after colon
    '192.168.1.1 : 8080',       // 28: Spaces around colon
    '192.168.1.1:8080extra',    // 29: Text after port
    'host:port:extra',          // 30: Too many colons
    {'1', '9', '2', '.', '1', '6', '8', '.', '1', '.', '1', ':', $09, '8', '0', '8', '0'}  // 31: Tab in port
}

// Expected results: true = should parse successfully, false = should fail
constant char NAV_NET_SPLIT_HOST_PORT_EXPECTED_RESULT[] = {
    // Valid with port (1-10)
    true, true, true, true, true, true, true, true, true, true,
    // Valid without port (11-14)
    true, true, true, true,
    // Invalid (15-31)
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false
}

// Expected host values for valid tests (first 14)
constant char NAV_NET_SPLIT_HOST_PORT_EXPECTED_HOST[][255] = {
    '192.168.1.1',
    'example.com',
    '127.0.0.1',
    '10.0.0.1',
    'server.local',
    '192.168.1.1',
    '192.168.1.1',
    '192.168.1.1',
    '192.168.1.1',
    'my-server.com',
    '192.168.1.1',
    'example.com',
    'localhost',
    '192.168.1.1'
}

// Expected port values for valid tests (first 14)
constant integer NAV_NET_SPLIT_HOST_PORT_EXPECTED_PORT[] = {
    8080,
    8080,
    80,
    443,
    3000,
    1,
    65535,
    0,
    8080,
    9999,
    0,    // No port specified
    0,    // No port specified
    0,    // No port specified
    0     // No port specified
}

define_function TestNAVNetSplitHostPort() {
    stack_var integer x
    stack_var integer validCount

    NAVLogTestSuiteStart('NAVNetSplitHostPort')

    validCount = 0

    for (x = 1; x <= length_array(NAV_NET_SPLIT_HOST_PORT_TESTS); x++) {
        stack_var char result
        stack_var char host[NAV_MAX_BUFFER]
        stack_var integer port
        stack_var char shouldPass

        shouldPass = NAV_NET_SPLIT_HOST_PORT_EXPECTED_RESULT[x]
        result = NAVNetSplitHostPort(NAV_NET_SPLIT_HOST_PORT_TESTS[x], host, port)

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

        // If should pass, validate host and port
        {
            stack_var char failed

            validCount++
            failed = false

            // Check host
            if (!NAVAssertStringEqual('Should have the correct host value', NAV_NET_SPLIT_HOST_PORT_EXPECTED_HOST[validCount], host)) {
                NAVLogTestFailed(x, NAV_NET_SPLIT_HOST_PORT_EXPECTED_HOST[validCount], host)
                failed = true
            }

            if (failed) {
                continue
            }

            // Check port
            if (!NAVAssertIntegerEqual('Should have the correct port value', NAV_NET_SPLIT_HOST_PORT_EXPECTED_PORT[validCount], port)) {
                NAVLogTestFailed(x, itoa(NAV_NET_SPLIT_HOST_PORT_EXPECTED_PORT[validCount]), itoa(port))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetSplitHostPort')
}
