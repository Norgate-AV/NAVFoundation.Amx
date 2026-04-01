PROGRAM_NAME='NAVNetCalculateNetworkAddress.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// --- NAVNetCalculateNetworkAddress (IP + dotted-decimal mask) ---

constant char NAV_NET_CALCULATE_NETWORK_ADDRESS_IP_TESTS[][255] = {
    // Valid
    '192.168.1.100',    //  1: /24
    '10.0.0.50',        //  2: /23
    '172.16.5.1',       //  3: /16
    '10.10.10.5',       //  4: /30 → low 2 bits masked off
    '192.168.1.1',      //  5: /32 → host mask; network = IP itself
    '10.0.0.1',         //  6: /0  → entire space; network = 0.0.0.0
    '192.168.1.255',    //  7: broadcast addr as input (still valid)

    // Invalid
    '',                 //  8: empty IP
    '192.168.1.1',      //  9: invalid mask
    '192.168.1.1'       // 10: empty mask
}

constant char NAV_NET_CALCULATE_NETWORK_ADDRESS_MASK_TESTS[][255] = {
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

// Expected network address; empty string indicates expected failure
constant char NAV_NET_CALCULATE_NETWORK_ADDRESS_EXPECTED[][255] = {
    '192.168.1.0',
    '10.0.0.0',
    '172.16.0.0',
    '10.10.10.4',
    '192.168.1.1',
    '0.0.0.0',
    '192.168.1.0',
    '',
    '',
    ''
}

// --- NAVNetCalculateNetworkAddressFromPrefix (IP + integer prefix) ---

constant char NAV_NET_CALCULATE_NETWORK_ADDRESS_FROM_PREFIX_IP_TESTS[][255] = {
    // Valid
    '192.168.1.100',    //  1: /24
    '10.0.0.50',        //  2: /23
    '172.16.5.1',       //  3: /16
    '10.10.10.5',       //  4: /30
    '192.168.1.1',      //  5: /32 → network = IP itself
    '10.0.0.1',         //  6: /0  → network = 0.0.0.0
    '10.0.0.1',         //  7: /8

    // Invalid
    '',                 //  8: empty IP
    '192.168.1.1'       //  9: prefix out of range
}

constant integer NAV_NET_CALCULATE_NETWORK_ADDRESS_FROM_PREFIX_PREFIX_TESTS[] = {
    24, 23, 16, 30, 32, 0, 8,
    24, 33
}

constant char NAV_NET_CALCULATE_NETWORK_ADDRESS_FROM_PREFIX_EXPECTED[][255] = {
    '192.168.1.0',
    '10.0.0.0',
    '172.16.0.0',
    '10.10.10.4',
    '192.168.1.1',
    '0.0.0.0',
    '10.0.0.0',
    '',
    ''
}

define_function TestNAVNetCalculateNetworkAddress() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetCalculateNetworkAddress')

    for (x = 1; x <= length_array(NAV_NET_CALCULATE_NETWORK_ADDRESS_IP_TESTS); x++) {
        stack_var char result[16]
        stack_var char expected[16]

        expected = NAV_NET_CALCULATE_NETWORK_ADDRESS_EXPECTED[x]
        result = NAVNetCalculateNetworkAddress(NAV_NET_CALCULATE_NETWORK_ADDRESS_IP_TESTS[x],
                                               NAV_NET_CALCULATE_NETWORK_ADDRESS_MASK_TESTS[x])

        if (!NAVAssertStringEqual('Should return the correct network address', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetCalculateNetworkAddress')
}

define_function TestNAVNetCalculateNetworkAddressFromPrefix() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetCalculateNetworkAddressFromPrefix')

    for (x = 1; x <= length_array(NAV_NET_CALCULATE_NETWORK_ADDRESS_FROM_PREFIX_IP_TESTS); x++) {
        stack_var char result[16]
        stack_var char expected[16]

        expected = NAV_NET_CALCULATE_NETWORK_ADDRESS_FROM_PREFIX_EXPECTED[x]
        result = NAVNetCalculateNetworkAddressFromPrefix(
                    NAV_NET_CALCULATE_NETWORK_ADDRESS_FROM_PREFIX_IP_TESTS[x],
                    NAV_NET_CALCULATE_NETWORK_ADDRESS_FROM_PREFIX_PREFIX_TESTS[x])

        if (!NAVAssertStringEqual('Should return the correct network address', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetCalculateNetworkAddressFromPrefix')
}
