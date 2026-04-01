PROGRAM_NAME='NAVNetCalculateBroadcast.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// --- NAVNetCalculateBroadcast (IP + dotted-decimal mask) ---

constant char NAV_NET_CALCULATE_BROADCAST_IP_TESTS[][255] = {
    // Valid
    '192.168.1.100',    //  1: /24  → last octet becomes 255
    '10.0.0.50',        //  2: /23  → spans two octets
    '172.16.5.1',       //  3: /16  → last two octets become 255
    '10.10.10.5',       //  4: /30  → only last 2 bits host
    '192.168.1.1',      //  5: /32  → host route; broadcast = IP itself
    '10.0.0.1',         //  6: /0   → entire space; broadcast = 255.255.255.255
    '192.168.0.0',      //  7: network address as input (still valid)

    // Invalid
    '',                 //  8: empty IP
    '192.168.1.1',      //  9: invalid mask value
    '192.168.1.1'       // 10: empty mask
}

constant char NAV_NET_CALCULATE_BROADCAST_MASK_TESTS[][255] = {
    '255.255.255.0',    //  1
    '255.255.254.0',    //  2
    '255.255.0.0',      //  3
    '255.255.255.252',  //  4
    '255.255.255.255',  //  5
    '0.0.0.0',          //  6
    '255.255.255.0',    //  7

    '255.255.255.0',    //  8: IP invalid
    '255.255.1.0',      //  9: non-contiguous mask
    ''                  // 10: mask empty
}

// Expected broadcast; empty string indicates expected failure
constant char NAV_NET_CALCULATE_BROADCAST_EXPECTED[][255] = {
    '192.168.1.255',
    '10.0.1.255',
    '172.16.255.255',
    '10.10.10.7',
    '192.168.1.1',
    '255.255.255.255',
    '192.168.0.255',
    '',
    '',
    ''
}

// --- NAVNetCalculateBroadcastFromPrefix (IP + integer prefix) ---

constant char NAV_NET_CALCULATE_BROADCAST_FROM_PREFIX_IP_TESTS[][255] = {
    // Valid
    '192.168.1.100',    //  1: /24
    '10.0.0.50',        //  2: /23
    '172.16.5.1',       //  3: /16
    '10.10.10.5',       //  4: /30
    '192.168.1.0',      //  5: /32 → broadcast = IP itself
    '0.0.0.0',          //  6: /0  → broadcast = 255.255.255.255
    '10.0.0.1',         //  7: /8

    // Invalid
    '',                 //  8: empty IP
    '192.168.1.1'       //  9: prefix out of range
}

constant integer NAV_NET_CALCULATE_BROADCAST_FROM_PREFIX_PREFIX_TESTS[] = {
    24, 23, 16, 30, 32, 0, 8,
    24, 33
}

constant char NAV_NET_CALCULATE_BROADCAST_FROM_PREFIX_EXPECTED[][255] = {
    '192.168.1.255',
    '10.0.1.255',
    '172.16.255.255',
    '10.10.10.7',
    '192.168.1.0',
    '255.255.255.255',
    '10.255.255.255',
    '',
    ''
}

define_function TestNAVNetCalculateBroadcast() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetCalculateBroadcast')

    for (x = 1; x <= length_array(NAV_NET_CALCULATE_BROADCAST_IP_TESTS); x++) {
        stack_var char result[16]
        stack_var char expected[16]

        expected = NAV_NET_CALCULATE_BROADCAST_EXPECTED[x]
        result = NAVNetCalculateBroadcast(NAV_NET_CALCULATE_BROADCAST_IP_TESTS[x],
                                          NAV_NET_CALCULATE_BROADCAST_MASK_TESTS[x])

        if (!NAVAssertStringEqual('Should return the correct broadcast address', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetCalculateBroadcast')
}

define_function TestNAVNetCalculateBroadcastFromPrefix() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetCalculateBroadcastFromPrefix')

    for (x = 1; x <= length_array(NAV_NET_CALCULATE_BROADCAST_FROM_PREFIX_IP_TESTS); x++) {
        stack_var char result[16]
        stack_var char expected[16]

        expected = NAV_NET_CALCULATE_BROADCAST_FROM_PREFIX_EXPECTED[x]
        result = NAVNetCalculateBroadcastFromPrefix(
                    NAV_NET_CALCULATE_BROADCAST_FROM_PREFIX_IP_TESTS[x],
                    NAV_NET_CALCULATE_BROADCAST_FROM_PREFIX_PREFIX_TESTS[x])

        if (!NAVAssertStringEqual('Should return the correct broadcast address', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetCalculateBroadcastFromPrefix')
}
