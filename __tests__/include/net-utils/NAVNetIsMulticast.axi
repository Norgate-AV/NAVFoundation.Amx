PROGRAM_NAME='NAVNetIsMulticast.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_NET_IS_MULTICAST_TESTS[][255] = {
    // Multicast: 224.0.0.0/4 — first octet 224-239 (true)
    '224.0.0.0',        //  1: base of range
    '224.0.0.1',        //  2: all-hosts (RFC 1112)
    '224.0.0.251',      //  3: mDNS
    '224.0.0.252',      //  4: LLMNR
    '232.0.0.0',        //  5: Source-Specific Multicast base
    '239.0.0.0',        //  6: organisation-local scope base
    '239.255.255.250',  //  7: SSDP (UPnP)
    '239.255.255.255',  //  8: last address in 224/4

    // Not multicast (false)
    '223.255.255.255',  //  9: just below the multicast range
    '240.0.0.0',        // 10: just above (reserved / experimental)
    '192.168.1.1',      // 11: private
    '10.0.0.1',         // 12: private
    '8.8.8.8',          // 13: public
    '127.0.0.1',        // 14: loopback

    // Invalid
    '',                 // 15: empty
    '256.0.0.1'         // 16: invalid
}

constant char NAV_NET_IS_MULTICAST_EXPECTED[] = {
    // Multicast (1-8)
    true, true, true, true, true, true, true, true,
    // Not multicast (9-14)
    false, false, false, false, false, false,
    // Invalid (15-16)
    false, false
}

define_function TestNAVNetIsMulticast() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetIsMulticast')

    for (x = 1; x <= length_array(NAV_NET_IS_MULTICAST_TESTS); x++) {
        stack_var char result
        stack_var char expected

        expected = NAV_NET_IS_MULTICAST_EXPECTED[x]
        result = NAVNetIsMulticast(NAV_NET_IS_MULTICAST_TESTS[x])

        if (!NAVAssertBooleanEqual('Should correctly identify multicast addresses', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetIsMulticast')
}
