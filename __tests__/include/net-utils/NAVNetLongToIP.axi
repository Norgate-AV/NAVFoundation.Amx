PROGRAM_NAME='NAVNetLongToIP.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// NAVNetLongToIP always succeeds — every long produces a valid dotted-decimal string
constant long NAV_NET_LONG_TO_IP_TESTS[] = {
    0,          //  1: $00000000 → '0.0.0.0'
    3232235777, //  2: $C0A80101 → '192.168.1.1'
    167772161,  //  3: $0A000001 → '10.0.0.1'
    2886731009, //  4: $AC100501 → '172.16.5.1'
    4294967295, //  5: $FFFFFFFF → '255.255.255.255'
    2130706433, //  6: $7F000001 → '127.0.0.1'
    2851995909, //  7: $A9FE0105 → '169.254.1.5'
    3758096635, //  8: $E00000FB → '224.0.0.251'
    16909060,   //  9: $01020304 → '1.2.3.4'
    2886729728  // 10: $AC100000 → '172.16.0.0'
}

constant char NAV_NET_LONG_TO_IP_EXPECTED[][255] = {
    '0.0.0.0',
    '192.168.1.1',
    '10.0.0.1',
    '172.16.5.1',
    '255.255.255.255',
    '127.0.0.1',
    '169.254.1.5',
    '224.0.0.251',
    '1.2.3.4',
    '172.16.0.0'
}

define_function TestNAVNetLongToIP() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetLongToIP')

    for (x = 1; x <= length_array(NAV_NET_LONG_TO_IP_TESTS); x++) {
        stack_var char result[16]
        stack_var char expected[16]

        expected = NAV_NET_LONG_TO_IP_EXPECTED[x]
        result = NAVNetLongToIP(NAV_NET_LONG_TO_IP_TESTS[x])

        if (!NAVAssertStringEqual('Should return the correct dotted-decimal string', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetLongToIP')
}
