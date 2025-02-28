PROGRAM_NAME='NAVAes128ECBEncryptBlock'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// AES-128 test vectors structure: key, plaintext, expected ciphertext
constant char AES_TEST_VECTORS[5][3][16] = {
    // Test Vector 1: FIPS-197 Appendix C.1
    {
        {$2b, $7e, $15, $16, $28, $ae, $d2, $a6, $ab, $f7, $15, $88, $09, $cf, $4f, $3c}, // key
        {$6b, $c1, $be, $e2, $2e, $40, $9f, $96, $e9, $3d, $7e, $11, $73, $93, $17, $2a}, // plaintext
        {$3a, $d7, $7b, $b4, $0d, $7a, $36, $60, $a8, $9e, $ca, $f3, $24, $66, $ef, $97}  // expected ciphertext
    },

    // Test Vector 2: All zeros plaintext - corrected expected value
    {
        {$2b, $7e, $15, $16, $28, $ae, $d2, $a6, $ab, $f7, $15, $88, $09, $cf, $4f, $3c}, // key
        {$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00}, // plaintext
        {$7d, $f7, $6b, $0c, $1a, $b8, $99, $b3, $3e, $42, $f0, $47, $b9, $1b, $54, $6f}  // corrected ciphertext
    },

    // Test Vector 3: All zeros key - corrected expected value
    {
        {$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00}, // key
        {$6b, $c1, $be, $e2, $2e, $40, $9f, $96, $e9, $3d, $7e, $11, $73, $93, $17, $2a}, // plaintext
        {$cf, $2e, $a3, $8a, $12, $3b, $e2, $07, $65, $eb, $8c, $5c, $56, $ca, $f2, $24}  // corrected ciphertext
    },

    // Test Vector 4: Simple pattern plaintext - corrected expected value
    {
        {$2b, $7e, $15, $16, $28, $ae, $d2, $a6, $ab, $f7, $15, $88, $09, $cf, $4f, $3c}, // key
        {$aa, $aa, $aa, $aa, $bb, $bb, $bb, $bb, $cc, $cc, $cc, $cc, $dd, $dd, $dd, $dd}, // plaintext
        {$1e, $1f, $21, $61, $d7, $75, $70, $2b, $e3, $b8, $bf, $69, $ff, $12, $a1, $89}  // corrected ciphertext
    },

    // Test Vector 5: NIST SP800-38A F.1.1
    {
        {$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f}, // key
        {$00, $11, $22, $33, $44, $55, $66, $77, $88, $99, $aa, $bb, $cc, $dd, $ee, $ff}, // plaintext
        {$69, $c4, $e0, $d8, $6a, $7b, $04, $30, $d8, $cd, $b7, $80, $70, $b4, $c5, $5a}  // expected ciphertext
    }
}

define_function RunNAVAes128ECBEncryptBlockTests() {
    stack_var _NAVAesContext context
    stack_var char plaintext[16]
    stack_var sinteger result
    stack_var integer i, j, testNum, failedAtByte
    stack_var char state[4][4]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128ECBEncryptBlock ******************')

    for (testNum = 1; testNum <= length_array(AES_TEST_VECTORS); testNum++) {
        // Copy the plaintext and key for current test vector
        for (i = 1; i <= 16; i++) {
            plaintext[i] = AES_TEST_VECTORS[testNum][2][i] // plaintext is the 2nd item
        }
        set_length_array(plaintext, 16)

        // Initialize context with the key for this test
        result = NAVAes128ContextInit(context, AES_TEST_VECTORS[testNum][1]) // key is the 1st item
        if (result != NAV_AES_SUCCESS) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ': Context initialization failed with error: ', NAVAes128GetError(result)")
            continue
        }

        // Encrypt the block
        NAVAes128ECBEncryptBlock(context, plaintext)

        // Check if result matches expected ciphertext
        failedAtByte = 0
        for (i = 1; i <= 16; i++) {
            if (plaintext[i] != AES_TEST_VECTORS[testNum][3][i]) { // expected ciphertext is the 3rd item
                failedAtByte = i
                break
            }
        }

        if (failedAtByte > 0) {
            // Detailed logging only if test fails
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' failed at byte ', itoa(failedAtByte),
                       ', expected $', format('%02X', AES_TEST_VECTORS[testNum][3][failedAtByte]),
                       ', got $', format('%02X', plaintext[failedAtByte])")

            // Show detailed input and output
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' Key     : ', NAVByteArrayToNetLinxHexString(AES_TEST_VECTORS[testNum][1])")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' Plaintext: ', NAVByteArrayToNetLinxHexString(AES_TEST_VECTORS[testNum][2])")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' Expected : ', NAVByteArrayToNetLinxHexString(AES_TEST_VECTORS[testNum][3])")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' Actual   : ', NAVByteArrayToNetLinxHexString(plaintext)")

            // Show round keys for debugging
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Round keys for test ', itoa(testNum), ':'")
            NAVAes128LogAllRoundKeys(context.RoundKey)

            // Debug the final state matrix
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Final state matrix for test ', itoa(testNum), ':'")
            NAVAes128BufferToState(plaintext, state)
            NAVAes128LogStateMatrix(state)
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' passed'")
        }
    }
}
