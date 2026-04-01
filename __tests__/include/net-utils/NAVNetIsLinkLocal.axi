PROGRAM_NAME='NAVNetIsLinkLocal.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_NET_IS_LINK_LOCAL_TESTS[][255] = {
    // Link-local: 169.254.0.0/16 (true)
    '169.254.0.0',      //  1: network address
    '169.254.0.1',      //  2: first host
    '169.254.1.5',      //  3: typical APIPA address
    '169.254.100.200',  //  4: mid-range
    '169.254.255.255',  //  5: last address in range

    // Not link-local (false)
    '169.253.0.1',      //  6: one octet below
    '169.255.0.1',      //  7: one octet above
    '168.254.0.1',      //  8: first octet differs
    '170.254.0.1',      //  9: first octet above
    '192.168.1.1',      // 10: private RFC 1918
    '10.0.0.1',         // 11: private RFC 1918

    // Invalid
    '',                 // 12: empty
    '256.254.0.0'       // 13: invalid
}

constant char NAV_NET_IS_LINK_LOCAL_EXPECTED[] = {
    // Link-local (1-5)
    true, true, true, true, true,
    // Not link-local (6-11)
    false, false, false, false, false, false,
    // Invalid (12-13)
    false, false
}

define_function TestNAVNetIsLinkLocal() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetIsLinkLocal')

    for (x = 1; x <= length_array(NAV_NET_IS_LINK_LOCAL_TESTS); x++) {
        stack_var char result
        stack_var char expected

        expected = NAV_NET_IS_LINK_LOCAL_EXPECTED[x]
        result = NAVNetIsLinkLocal(NAV_NET_IS_LINK_LOCAL_TESTS[x])

        if (!NAVAssertBooleanEqual('Should correctly identify link-local addresses', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetIsLinkLocal')
}
