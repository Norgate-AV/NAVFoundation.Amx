PROGRAM_NAME='NAVNetIPToLong.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_NET_IP_TO_LONG_TESTS[][255] = {
    // Valid addresses
    '0.0.0.0',          //  1: All zeros      → 0
    '192.168.1.1',      //  2: Typical LAN    → $C0A80101 (3232235777)
    '10.0.0.1',         //  3: Class A private → $0A000001 (167772161)
    '172.16.5.1',       //  4: Class B private → $AC100501 (2886731009)
    '255.255.255.255',  //  5: Broadcast       → $FFFFFFFF (4294967295)
    '127.0.0.1',        //  6: Loopback        → $7F000001 (2130706433)
    '169.254.1.5',      //  7: Link-local      → $A9FE0105 (2851995909)
    '224.0.0.251',      //  8: mDNS multicast  → $E00000FB (3758096635)
    '192.168.255.255',  //  9: Subnet broadcast → $C0A8FFFF (3232301055)
    '1.2.3.4',          // 10: Sequential      → $01020304 (16909060)

    // Invalid (return 0)
    '',                 // 11: Empty string
    '256.0.0.0',        // 12: Octet out of range
    '192.168.1',        // 13: Too few octets
    'not.an.ip'         // 14: Non-numeric
}

constant long NAV_NET_IP_TO_LONG_EXPECTED[] = {
    // Valid (1-10)
    0,          //  1: 0.0.0.0
    3232235777, //  2: 192.168.1.1   ($C0A80101)
    167772161,  //  3: 10.0.0.1      ($0A000001)
    2886731009, //  4: 172.16.5.1    ($AC100501)
    4294967295, //  5: 255.255.255.255 ($FFFFFFFF)
    2130706433, //  6: 127.0.0.1     ($7F000001)
    2851995909, //  7: 169.254.1.5   ($A9FE0105)
    3758096635, //  8: 224.0.0.251   ($E00000FB)
    3232301055, //  9: 192.168.255.255 ($C0A8FFFF)
    16909060,   // 10: 1.2.3.4       ($01020304)
    // Invalid (11-14)
    0, 0, 0, 0
}

define_function TestNAVNetIPToLong() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetIPToLong')

    for (x = 1; x <= length_array(NAV_NET_IP_TO_LONG_TESTS); x++) {
        stack_var long result
        stack_var long expected

        expected = NAV_NET_IP_TO_LONG_EXPECTED[x]
        result = NAVNetIPToLong(NAV_NET_IP_TO_LONG_TESTS[x])

        if (!NAVAssertLongEqual('Should return the correct 32-bit packed value', expected, result)) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetIPToLong')
}
