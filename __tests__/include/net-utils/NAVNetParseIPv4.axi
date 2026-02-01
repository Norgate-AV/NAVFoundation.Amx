PROGRAM_NAME='NAVNetParseIPv4.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// All IPv4 test cases
constant char NAV_NET_PARSE_IPV4_TESTS[][255] = {
    // Valid addresses
    '0.0.0.0',              // 1: Minimum valid address
    '255.255.255.255',      // 2: Maximum valid address
    '192.168.1.1',          // 3: Common private network
    '10.0.0.1',             // 4: Private network
    '172.16.0.1',           // 5: Private network
    '8.8.8.8',              // 6: Google DNS
    '127.0.0.1',            // 7: Localhost
    '1.2.3.4',              // 8: Simple address
    '100.100.100.100',      // 9: 3-digit octets
    '192.0.2.1',            // 10: TEST-NET-1 (RFC 5737)
    '198.51.100.1',         // 11: TEST-NET-2 (RFC 5737)
    '203.0.113.1',          // 12: TEST-NET-3 (RFC 5737)
    '224.0.0.1',            // 13: Multicast
    '239.255.255.255',      // 14: Multicast max
    '169.254.1.1',          // 15: Link-local
    ' 192.168.1.1',         // 16: Leading whitespace (trimmed)
    '192.168.1.1 ',         // 17: Trailing whitespace (trimmed)
    '  192.168.1.1  ',      // 18: Both whitespace (trimmed)

    // Invalid addresses
    '',                     // 19: Empty string
    '256.1.1.1',            // 20: Octet > 255
    '1.256.1.1',            // 21: Octet > 255
    '1.1.256.1',            // 22: Octet > 255
    '1.1.1.256',            // 23: Octet > 255
    '1.1.1',                // 24: Too few octets
    '1.1',                  // 25: Too few octets
    '1',                    // 26: Too few octets
    '1.1.1.1.1',            // 27: Too many octets
    '1.1.1.1.1.1',          // 28: Too many octets
    '192.168.1',            // 29: Missing octet
    '192.168..1',           // 30: Empty octet
    '192..168.1',           // 31: Empty octet
    '.192.168.1.1',         // 32: Leading dot
    '192.168.1.1.',         // 33: Trailing dot
    '192.168.01.1',         // 34: Leading zero
    '192.168.001.1',        // 35: Leading zeros
    '01.168.1.1',           // 36: Leading zero in first octet
    '192.168.1.01',         // 37: Leading zero in last octet
    'abc.def.ghi.jkl',      // 38: Letters
    '192.168.a.1',          // 39: Letter in octet
    '192.168.1.1a',         // 40: Letter after digit
    'a192.168.1.1',         // 41: Letter before digit
    '192 .168.1.1',         // 42: Space in address
    '192. 168.1.1',         // 43: Space after dot
    '192.168 .1.1',         // 44: Space before dot
    '192.168.-1.1',         // 45: Negative number
    '192.168.1.-1',         // 46: Negative number
    '1111.1.1.1',           // 47: Octet too large
    '192.168.1.1.1.1.1',    // 48: Way too many octets
    '....',                 // 49: Only dots
    '192.168.1,1',          // 50: Wrong separator
    '192.168.1;1',          // 51: Wrong separator
    '192/168/1/1',          // 52: Wrong separator
    '192:168:1:1',          // 53: IPv6-style separator
    '   ',                  // 54: Whitespace only
    {' ', ' ', $09, ' ', ' '},               // 55: Tabs and spaces
    '+192.168.1.1',         // 56: Leading plus sign
    '192.+168.1.1',         // 57: Plus in middle
    '192.168.1.1+',         // 58: Trailing plus
    '-192.168.1.1',         // 59: Leading minus (already tested as negative, but explicit)
    '192.-168.1.1',         // 60: Minus in middle
    '192.168.1.1-',         // 61: Trailing minus
    '999999999999999.1.1.1',  // 62: Octet overflow (huge number)
    '192.168.1.999999999',  // 63: Last octet overflow
    '192.168.1.1 extra',    // 64: Trailing non-whitespace
    'extra 192.168.1.1',    // 65: Leading non-whitespace
    '192.168.1.1extra',     // 66: No space, trailing text
    {'1', '9', '2', $09, '.', '1', '6', '8', '.', '1', '.', '1'},        // 67: Tab before dot
    {'1', '9', '2', '.', $09, '1', '6', '8', '.', '1', '.', '1'},        // 68: Tab after dot
    {'1', '9', '2', '.', '1', '6', '8', $0A, '.', '1', '.', '1'},        // 69: Newline
    '192..168.1.1'          // 70: Double dots (empty octet, already tested but explicit)
}

// Expected results: true = should parse successfully, false = should fail
constant char NAV_NET_PARSE_IPV4_EXPECTED_RESULT[] = {
    // Valid (1-18)
    true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true,
    // Invalid (19-70)
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false
}

// Expected octets for valid tests (only first 18)
constant char NAV_NET_PARSE_IPV4_EXPECTED_OCTETS[][4] = {
    { 0,   0,   0,   0   },   // 1: 0.0.0.0
    { 255, 255, 255, 255 },   // 2: 255.255.255.255
    { 192, 168, 1,   1   },   // 3: 192.168.1.1
    { 10,  0,   0,   1   },   // 4: 10.0.0.1
    { 172, 16,  0,   1   },   // 5: 172.16.0.1
    { 8,   8,   8,   8   },   // 6: 8.8.8.8
    { 127, 0,   0,   1   },   // 7: 127.0.0.1
    { 1,   2,   3,   4   },   // 8: 1.2.3.4
    { 100, 100, 100, 100 },   // 9: 100.100.100.100
    { 192, 0,   2,   1   },   // 10: 192.0.2.1
    { 198, 51,  100, 1   },   // 11: 198.51.100.1
    { 203, 0,   113, 1   },   // 12: 203.0.113.1
    { 224, 0,   0,   1   },   // 13: 224.0.0.1
    { 239, 255, 255, 255 },   // 14: 239.255.255.255
    { 169, 254, 1,   1   },   // 15: 169.254.1.1
    { 192, 168, 1,   1   },   // 16: ' 192.168.1.1' (trimmed)
    { 192, 168, 1,   1   },   // 17: '192.168.1.1 ' (trimmed)
    { 192, 168, 1,   1   }    // 18: '  192.168.1.1  ' (trimmed)
}

// Normalized strings for valid tests (expected Address field)
constant char NAV_NET_PARSE_IPV4_EXPECTED_STRINGS[][16] = {
    '0.0.0.0',
    '255.255.255.255',
    '192.168.1.1',
    '10.0.0.1',
    '172.16.0.1',
    '8.8.8.8',
    '127.0.0.1',
    '1.2.3.4',
    '100.100.100.100',
    '192.0.2.1',
    '198.51.100.1',
    '203.0.113.1',
    '224.0.0.1',
    '239.255.255.255',
    '169.254.1.1',
    '192.168.1.1',  // whitespace trimmed
    '192.168.1.1',  // whitespace trimmed
    '192.168.1.1'   // whitespace trimmed
}


define_function TestNAVNetParseIPv4() {
    stack_var integer x
    stack_var integer validCount

    NAVLogTestSuiteStart('NAVNetParseIPv4')

    validCount = 0

    for (x = 1; x <= length_array(NAV_NET_PARSE_IPV4_TESTS); x++) {
        stack_var char result
        stack_var _NAVIP ip
        stack_var char shouldPass

        shouldPass = NAV_NET_PARSE_IPV4_EXPECTED_RESULT[x]
        result = NAVNetParseIPv4(NAV_NET_PARSE_IPV4_TESTS[x], ip)

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

        // If should pass, validate octets and string
        {
            stack_var char failed
            stack_var integer y

            validCount++
            failed = false

            // Check each octet
            for (y = 1; y <= 4; y++) {
                if (!NAVAssertCharEqual("'Should have the correct octet ', itoa(y), ' value'", NAV_NET_PARSE_IPV4_EXPECTED_OCTETS[validCount][y], ip.Octets[y])) {
                    NAVLogTestFailed(x, itoa(NAV_NET_PARSE_IPV4_EXPECTED_OCTETS[validCount][y]), itoa(ip.Octets[y]))
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }

            // Check normalized string
            if (!NAVAssertStringEqual('Should result in the correct normalized IP address', NAV_NET_PARSE_IPV4_EXPECTED_STRINGS[validCount], ip.Address)) {
                NAVLogTestFailed(x, NAV_NET_PARSE_IPV4_EXPECTED_STRINGS[validCount], ip.Address)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetParseIPv4')
}
