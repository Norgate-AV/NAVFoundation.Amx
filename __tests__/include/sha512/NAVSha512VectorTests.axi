PROGRAM_NAME='NAVSha512VectorTests'

#IF_NOT_DEFINED __NAV_SHA512_VECTOR_TESTS__
#DEFINE __NAV_SHA512_VECTOR_TESTS__ 'NAVSha512VectorTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.Cryptography.Sha512.h.axi'

DEFINE_CONSTANT
// Standard SHA-512 test vectors from NIST
constant char TEST_VECTOR_INPUTS[][100] = {
    '',         // Empty string
    'a',        // Single character
    'abc',      // Three characters
    'message digest',  // Common test phrase
    'abcdefghijklmnopqrstuvwxyz',  // Alphabet
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'  // Alphanumeric
}

// Expected SHA-512 outputs for the inputs above (lowercase hex)
constant char TEST_VECTOR_OUTPUTS[][130] = {
    'cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e',
    '1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f5302860c652bf08d560252aa5e74210546f369fbbbce8c12cfc7957b2652fe9a75',
    'ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f',
    '107dbf389d9e9f71a3a95f6c055b9251bc5268c2be16d6c13492ea45b0199f3309e16455ab1e96118e8a905d5597b72038ddb372a89826046de66687bb420e7c',
    '4dbff86cc2ca1bae1e16468a05cb9881c97f1753bce3619034898faa1aabe429955a1bf8ec483d7421fe3c1646613a59ed5441fb0f321389f77f48a879c7b1f1',
    '1e07be23c26a86ea37ea810c8ec7809352515a970e9253c26f536cfc7a9996c45c8370583e0a78fa4a90041d71a4ceab7423f19c71b9d5a3e01249f0bebd5894'
}

define_function integer RunTestVector(integer index) {
    stack_var char digest[64]
    stack_var char hexDigest[128]
    stack_var char expected[128]
    stack_var integer i

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Test ', itoa(index+1), ' - "', TEST_VECTOR_INPUTS[index+1], '" ====='")

    // Get SHA-512 hash
    digest = NAVSha512GetHash(TEST_VECTOR_INPUTS[index+1])

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

define_function integer RunNAVSha512VectorTests() {
    stack_var integer i, passed, total

    total = length_array(TEST_VECTOR_INPUTS)
    passed = 0

    // Run all test vectors
    for (i = 0; i < total; i++) {
        passed = passed + RunTestVector(i)
    }

    if (passed == total) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'All SHA-512 test vectors passed!'")
        return 1
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Some SHA-512 test vectors failed!'")
        return 0
    }
}

#END_IF // __NAV_SHA512_VECTOR_TESTS__

