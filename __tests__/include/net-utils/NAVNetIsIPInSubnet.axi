PROGRAM_NAME='NAVNetIsIPInSubnet.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// --- NAVNetIsIPInSubnet (IP + network + dotted-decimal mask) ---

constant char NAV_NET_IS_IP_IN_SUBNET_IP_TESTS[][255] = {
    // Should return true
    '192.168.1.100',    //  1: typical host in /24
    '192.168.1.0',      //  2: network address itself
    '192.168.1.255',    //  3: broadcast address
    '10.0.0.50',        //  4: first half of /23
    '10.0.1.50',        //  5: second half of /23 (same subnet)
    '192.168.1.1',      //  6: /32 host route — only exact match
    '172.16.15.1',      //  7: host within /16

    // Should return false
    '192.168.2.1',      //  8: wrong /24
    '10.0.2.1',         //  9: outside /23 (third block)
    '192.168.2.0',      // 10: /32 — different address

    // Invalid inputs (return false)
    '',                 // 11: empty IP
    '192.168.1.1',      // 12: invalid mask
    '192.168.1.1'       // 13: empty mask
}

constant char NAV_NET_IS_IP_IN_SUBNET_NETWORK_TESTS[][255] = {
    '192.168.1.0',      //  1
    '192.168.1.0',      //  2
    '192.168.1.0',      //  3
    '10.0.0.0',         //  4
    '10.0.0.0',         //  5
    '192.168.1.1',      //  6
    '172.16.0.0',       //  7
    '192.168.1.0',      //  8
    '10.0.0.0',         //  9
    '192.168.1.1',      // 10
    '192.168.1.0',      // 11
    '192.168.1.0',      // 12
    '192.168.1.0'       // 13
}

constant char NAV_NET_IS_IP_IN_SUBNET_MASK_TESTS[][255] = {
    '255.255.255.0',    //  1: /24
    '255.255.255.0',    //  2: /24
    '255.255.255.0',    //  3: /24
    '255.255.254.0',    //  4: /23
    '255.255.254.0',    //  5: /23
    '255.255.255.255',  //  6: /32
    '255.255.0.0',      //  7: /16
    '255.255.255.0',    //  8: /24
    '255.255.254.0',    //  9: /23
    '255.255.255.255',  // 10: /32
    '255.255.255.0',    // 11: IP invalid
    '255.255.1.0',      // 12: non-contiguous mask
    ''                  // 13: empty mask
}

constant char NAV_NET_IS_IP_IN_SUBNET_EXPECTED[] = {
    true, true, true, true, true, true, true,
    false, false, false,
    false, false, false
}

// --- NAVNetIsIPInSubnetFromPrefix (IP + network + integer prefix) ---

constant char NAV_NET_IS_IP_IN_SUBNET_FROM_PREFIX_IP_TESTS[][255] = {
    // true
    '192.168.1.100',    //  1: /24
    '10.0.0.50',        //  2: /23 first half
    '10.0.1.50',        //  3: /23 second half

    // false
    '192.168.2.1',      //  4: wrong /24
    '10.0.2.1',         //  5: outside /23

    // invalid
    '',                 //  6: empty IP
    '192.168.1.1'       //  7: prefix out of range
}

constant char NAV_NET_IS_IP_IN_SUBNET_FROM_PREFIX_NETWORK_TESTS[][255] = {
    '192.168.1.0',
    '10.0.0.0',
    '10.0.0.0',
    '192.168.1.0',
    '10.0.0.0',
    '192.168.1.0',
    '192.168.1.0'
}

constant integer NAV_NET_IS_IP_IN_SUBNET_FROM_PREFIX_PREFIX_TESTS[] = {
    24, 23, 23,
    24, 23,
    24, 33
}

constant char NAV_NET_IS_IP_IN_SUBNET_FROM_PREFIX_EXPECTED[] = {
    true, true, true,
    false, false,
    false, false
}

define_function TestNAVNetIsIPInSubnet() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetIsIPInSubnet')

    for (x = 1; x <= length_array(NAV_NET_IS_IP_IN_SUBNET_IP_TESTS); x++) {
        stack_var char result
        stack_var char expected

        expected = NAV_NET_IS_IP_IN_SUBNET_EXPECTED[x]
        result = NAVNetIsIPInSubnet(NAV_NET_IS_IP_IN_SUBNET_IP_TESTS[x],
                                    NAV_NET_IS_IP_IN_SUBNET_NETWORK_TESTS[x],
                                    NAV_NET_IS_IP_IN_SUBNET_MASK_TESTS[x])

        if (!NAVAssertBooleanEqual('Should correctly determine subnet membership', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetIsIPInSubnet')
}

define_function TestNAVNetIsIPInSubnetFromPrefix() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetIsIPInSubnetFromPrefix')

    for (x = 1; x <= length_array(NAV_NET_IS_IP_IN_SUBNET_FROM_PREFIX_IP_TESTS); x++) {
        stack_var char result
        stack_var char expected

        expected = NAV_NET_IS_IP_IN_SUBNET_FROM_PREFIX_EXPECTED[x]
        result = NAVNetIsIPInSubnetFromPrefix(NAV_NET_IS_IP_IN_SUBNET_FROM_PREFIX_IP_TESTS[x],
                                              NAV_NET_IS_IP_IN_SUBNET_FROM_PREFIX_NETWORK_TESTS[x],
                                              NAV_NET_IS_IP_IN_SUBNET_FROM_PREFIX_PREFIX_TESTS[x])

        if (!NAVAssertBooleanEqual('Should correctly determine subnet membership', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetIsIPInSubnetFromPrefix')
}
