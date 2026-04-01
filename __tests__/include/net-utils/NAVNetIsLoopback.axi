PROGRAM_NAME='NAVNetIsLoopback.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_NET_IS_LOOPBACK_TESTS[][255] = {
    // Loopback: 127.0.0.0/8 (true)
    '127.0.0.0',        //  1: network address
    '127.0.0.1',        //  2: canonical loopback
    '127.0.0.255',      //  3: last address in first /24
    '127.1.2.3',        //  4: non-standard loopback
    '127.255.255.255',  //  5: last address in range

    // Not loopback (false)
    '128.0.0.1',        //  6: first address outside 127/8
    '126.255.255.255',  //  7: last address before 127/8
    '192.168.1.1',      //  8: private
    '10.0.0.1',         //  9: private
    '8.8.8.8',          // 10: public

    // Invalid
    '',                 // 11: empty
    '256.0.0.1'         // 12: invalid
}

constant char NAV_NET_IS_LOOPBACK_EXPECTED[] = {
    // Loopback (1-5)
    true, true, true, true, true,
    // Not loopback (6-10)
    false, false, false, false, false,
    // Invalid (11-12)
    false, false
}

define_function TestNAVNetIsLoopback() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetIsLoopback')

    for (x = 1; x <= length_array(NAV_NET_IS_LOOPBACK_TESTS); x++) {
        stack_var char result
        stack_var char expected

        expected = NAV_NET_IS_LOOPBACK_EXPECTED[x]
        result = NAVNetIsLoopback(NAV_NET_IS_LOOPBACK_TESTS[x])

        if (!NAVAssertBooleanEqual('Should correctly identify loopback addresses', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetIsLoopback')
}
