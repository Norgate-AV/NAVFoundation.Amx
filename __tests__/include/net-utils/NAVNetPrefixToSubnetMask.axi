PROGRAM_NAME='NAVNetPrefixToSubnetMask.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Prefix inputs (0-32 valid, >32 invalid)
constant integer NAV_NET_PREFIX_TO_SUBNET_MASK_TESTS[] = {
    // Valid (0-32)
    0, 1, 8, 9, 16, 17, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
    // Invalid (>32)
    33, 255
}

// Expected dotted-decimal mask; empty string indicates expected failure
constant char NAV_NET_PREFIX_TO_SUBNET_MASK_EXPECTED[][255] = {
    // Valid (1-16)
    '0.0.0.0',
    '128.0.0.0',
    '255.0.0.0',
    '255.128.0.0',
    '255.255.0.0',
    '255.255.128.0',
    '255.255.254.0',
    '255.255.255.0',
    '255.255.255.128',
    '255.255.255.192',
    '255.255.255.224',
    '255.255.255.240',
    '255.255.255.248',
    '255.255.255.252',
    '255.255.255.254',
    '255.255.255.255',
    // Invalid (17-18)
    '',
    ''
}

define_function TestNAVNetPrefixToSubnetMask() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetPrefixToSubnetMask')

    for (x = 1; x <= length_array(NAV_NET_PREFIX_TO_SUBNET_MASK_TESTS); x++) {
        stack_var char result[16]
        stack_var char expected[16]

        expected = NAV_NET_PREFIX_TO_SUBNET_MASK_EXPECTED[x]
        result = NAVNetPrefixToSubnetMask(NAV_NET_PREFIX_TO_SUBNET_MASK_TESTS[x])

        if (!NAVAssertStringEqual('Should return the correct subnet mask', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetPrefixToSubnetMask')
}
