PROGRAM_NAME='NAVNetIsPrivateIP.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_NET_IS_PRIVATE_IP_TESTS[][255] = {
    // RFC 1918 private ranges (true)
    '10.0.0.0',         //  1: 10/8 network address
    '10.0.0.1',         //  2: 10/8 host
    '10.255.255.255',   //  3: 10/8 broadcast
    '172.16.0.0',       //  4: 172.16/12 network address
    '172.16.0.1',       //  5: 172.16/12 first host
    '172.20.5.1',       //  6: 172.16/12 middle
    '172.31.255.255',   //  7: 172.16/12 last address
    '192.168.0.0',      //  8: 192.168/16 network address
    '192.168.0.1',      //  9: 192.168/16 host
    '192.168.255.255',  // 10: 192.168/16 last address

    // Public / non-private (false)
    '8.8.8.8',          // 11: Google DNS
    '1.1.1.1',          // 12: Cloudflare DNS
    '172.15.255.255',   // 13: just below 172.16/12
    '172.32.0.0',       // 14: just above 172.31/12
    '192.167.255.255',  // 15: just below 192.168/16
    '192.169.0.0',      // 16: just above 192.168/16
    '127.0.0.1',        // 17: loopback — not RFC 1918
    '169.254.1.1',      // 18: link-local — not RFC 1918

    // Invalid
    '',                 // 19: empty
    '256.0.0.0'         // 20: invalid octet
}

constant char NAV_NET_IS_PRIVATE_IP_EXPECTED[] = {
    // RFC 1918 (1-10)
    true, true, true, true, true, true, true, true, true, true,
    // Public (11-18)
    false, false, false, false, false, false, false, false,
    // Invalid (19-20)
    false, false
}

define_function TestNAVNetIsPrivateIP() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetIsPrivateIP')

    for (x = 1; x <= length_array(NAV_NET_IS_PRIVATE_IP_TESTS); x++) {
        stack_var char result
        stack_var char expected

        expected = NAV_NET_IS_PRIVATE_IP_EXPECTED[x]
        result = NAVNetIsPrivateIP(NAV_NET_IS_PRIVATE_IP_TESTS[x])

        if (!NAVAssertBooleanEqual('Should correctly identify RFC 1918 private addresses', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetIsPrivateIP')
}
