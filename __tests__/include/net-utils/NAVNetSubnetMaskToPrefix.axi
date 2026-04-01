PROGRAM_NAME='NAVNetSubnetMaskToPrefix.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_NET_SUBNET_MASK_TO_PREFIX_TESTS[][255] = {
    // Valid contiguous masks
    '0.0.0.0',          //  1: /0
    '128.0.0.0',        //  2: /1
    '255.0.0.0',        //  3: /8
    '255.128.0.0',      //  4: /9
    '255.255.0.0',      //  5: /16
    '255.255.128.0',    //  6: /17
    '255.255.254.0',    //  7: /23
    '255.255.255.0',    //  8: /24
    '255.255.255.128',  //  9: /25
    '255.255.255.192',  // 10: /26
    '255.255.255.224',  // 11: /27
    '255.255.255.240',  // 12: /28
    '255.255.255.248',  // 13: /29
    '255.255.255.252',  // 14: /30
    '255.255.255.254',  // 15: /31
    '255.255.255.255',  // 16: /32

    // Invalid masks (return 255)
    '',                 // 17: Empty string
    '255.255.1.0',      // 18: Non-power-of-two octet value
    '255.128.255.0',    // 19: Non-contiguous (128 followed by 255)
    '0.255.0.0',        // 20: Non-contiguous (0 followed by 255)
    '255.255.255.100',  // 21: Invalid octet value (100)
    '256.0.0.0',        // 22: Octet out of range
    'not.a.mask'        // 23: Non-numeric
}

// Valid tests return the prefix length; invalid tests return 255 (sentinel)
constant integer NAV_NET_SUBNET_MASK_TO_PREFIX_EXPECTED[] = {
    // Valid (1-16)
    0, 1, 8, 9, 16, 17, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
    // Invalid (17-23)
    255, 255, 255, 255, 255, 255, 255
}

define_function TestNAVNetSubnetMaskToPrefix() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVNetSubnetMaskToPrefix')

    for (x = 1; x <= length_array(NAV_NET_SUBNET_MASK_TO_PREFIX_TESTS); x++) {
        stack_var integer result
        stack_var integer expected

        expected = NAV_NET_SUBNET_MASK_TO_PREFIX_EXPECTED[x]
        result = NAVNetSubnetMaskToPrefix(NAV_NET_SUBNET_MASK_TO_PREFIX_TESTS[x])

        if (!NAVAssertIntegerEqual('Should return the correct prefix length', expected, result)) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetSubnetMaskToPrefix')
}
