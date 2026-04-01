PROGRAM_NAME='NAVNetCalculateHostCount.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant integer NAV_NET_CALCULATE_HOST_COUNT_TESTS[] = {
    // Valid prefix lengths
    0,   //  1: entire address space
    8,   //  2: /8  class A
    16,  //  3: /16 class B
    23,  //  4: /23
    24,  //  5: /24 class C (most common)
    25,  //  6: /25
    30,  //  7: /30 point-to-point (2 usable)
    31,  //  8: returns 0 (RFC 3021 P2P link, no usable hosts in traditional sense)
    32,  //  9: returns 0 (host route)
    // Invalid
    33,  // 10: out of range → 0
    255  // 11: out of range → 0
}

constant long NAV_NET_CALCULATE_HOST_COUNT_EXPECTED[] = {
    4294967294, //  1: 2^32 - 2 ($FFFFFFFE)
    16777214,   //  2: 2^24 - 2
    65534,      //  3: 2^16 - 2
    510,        //  4: 2^9  - 2
    254,        //  5: 2^8  - 2
    126,        //  6: 2^7  - 2
    2,          //  7: 2^2  - 2
    0,          //  8: special case
    0,          //  9: special case
    0,          // 10: invalid
    0           // 11: invalid
}

define_function TestNAVNetCalculateHostCount() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetCalculateHostCount')

    for (x = 1; x <= length_array(NAV_NET_CALCULATE_HOST_COUNT_TESTS); x++) {
        stack_var long result
        stack_var long expected

        expected = NAV_NET_CALCULATE_HOST_COUNT_EXPECTED[x]
        result = NAVNetCalculateHostCount(NAV_NET_CALCULATE_HOST_COUNT_TESTS[x])

        if (!NAVAssertLongEqual('Should return the correct usable host count', expected, result)) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetCalculateHostCount')
}
