PROGRAM_NAME='NAVSha384VectorTests'

#IF_NOT_DEFINED __NAV_SHA384_VECTOR_TESTS__
#DEFINE __NAV_SHA384_VECTOR_TESTS__ 'NAVSha384VectorTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.Cryptography.Sha384.h.axi'

DEFINE_CONSTANT
// Standard SHA-384 test vectors from NIST
constant char TEST_VECTOR_INPUTS[][100] = {
    '',         // Empty string
    'a',        // Single character
    'abc',      // Three characters
    'message digest',  // Common test phrase
    'abcdefghijklmnopqrstuvwxyz',  // Alphabet
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'  // Alphanumeric
}

// Expected SHA-384 outputs for the inputs above (lowercase hex)
constant char TEST_VECTOR_OUTPUTS[][100] = {
    '38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b',
    '54a59b9f22b0b80880d8427e548b7c23abd873486e1f035dce9cd697e85175033caa88e6d57bc35efae0b5afd3145f31',
    'cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7',
    '473ed35167ec1f5d8e550368a3db39be54639f828868e9454c239fc8b52e3c61dbd0d8b4de1390c256dcbb5d5fd99cd5',
    'feb67349df3db6f5924815d6c3dc133f091809213731fe5c7b5f4999e463479ff2877f5f2936fa63bb43784b12f3ebb4',
    '1761336e3f7cbfe51deb137f026f89e01a448e3b1fafa64039c1464ee8732f11a5341a6f41e0c202294736ed64db1a84'
}

define_function integer RunTestVector(integer index) {
    stack_var char digest[48]
    stack_var char hexDigest[96]
    stack_var char expected[96]
    stack_var integer i

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Test ', itoa(index+1), ' - "', TEST_VECTOR_INPUTS[index+1], '" ====='")

    // Get SHA-384 hash
    digest = NAVSha384GetHash(TEST_VECTOR_INPUTS[index+1])

    // Convert binary digest to hex string (all lowercase)
    hexDigest = NAVHexToString(digest)

    expected = TEST_VECTOR_OUTPUTS[index+1]

    // Output debug info
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', expected")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', hexDigest")

    // Compare the result
    if (hexDigest == expected) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(index+1), ' passed.'")
        return 1
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(index+1), ' failed.'")
        return 0
    }
}

define_function integer RunNAVSha384VectorTests() {
    stack_var integer i, passed, total

    total = length_array(TEST_VECTOR_INPUTS)
    passed = 0

    // Run all test vectors
    for (i = 0; i < total; i++) {
        passed = passed + RunTestVector(i)
    }

    if (passed == total) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'All SHA-384 test vectors passed!'")
        return 1
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Some SHA-384 test vectors failed!'")
        return 0
    }
}

#END_IF // __NAV_SHA384_VECTOR_TESTS__

