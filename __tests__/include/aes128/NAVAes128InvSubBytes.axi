PROGRAM_NAME='NAVAes128InvSubBytes'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// Test cases with input and expected output after InvSubBytes
constant char INVSUBBYTES_TEST[8][4][4] = {
    // Test case 1: All zeros
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 2: All 0x63 (which is the S-box value for 0x00)
    {
        {$63, $63, $63, $63},
        {$63, $63, $63, $63},
        {$63, $63, $63, $63},
        {$63, $63, $63, $63}
    },

    // Test case 3: FIPS-197 example after SubBytes
    {
        {$d4, $e0, $b8, $1e},
        {$bf, $b4, $41, $27},
        {$5d, $52, $11, $98},
        {$30, $ae, $f1, $e5}
    },

    // Test case 4: Various values from different parts of the S-box
    {
        {$7c, $82, $7d, $f2},
        {$6b, $c9, $76, $fa},
        {$2b, $6f, $c5, $30},
        {$01, $67, $ab, $fe}
    },

    // Test case 5: FIPS-197 example values that will be transformed
    {
        {$49, $45, $7f, $77},
        {$db, $39, $02, $de},
        {$87, $53, $d2, $96},
        {$3b, $6c, $d6, $62}
    },

    // Test case 6: Edge cases
    {
        {$ff, $01, $aa, $55},
        {$f0, $0f, $cc, $33},
        {$80, $08, $88, $22},
        {$7f, $07, $77, $11}
    },

    // Test case 7: Repeated values
    {
        {$e5, $e5, $e5, $e5},
        {$b4, $b4, $b4, $b4},
        {$c5, $c5, $c5, $c5},
        {$ff, $ff, $ff, $ff}
    },

    // Test case 8: Boundary values
    {
        {$00, $01, $02, $03},
        {$fc, $fd, $fe, $ff},
        {$7f, $80, $81, $82},
        {$bf, $c0, $c1, $c2}
    }
}

// Expected outputs after inverse substitution
// These values are computed using the inverse S-box
constant char INVSUBBYTES_EXPECTED[8][4][4] = {
    // Test case 1: All zeros -> values from InvSBox[0]
    {
        {$52, $52, $52, $52},
        {$52, $52, $52, $52},
        {$52, $52, $52, $52},
        {$52, $52, $52, $52}
    },

    // Test case 2: All 0x63 -> values from InvSBox[0x63] = 0x00
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 3: Update to match standard RSBOX for the inputs
    {
        {$19, $A0, $9A, $E9},
        {$F4, $C6, $F8, $3D},
        {$8D, $48, $E3, $E2},
        {$08, $BE, $2B, $2A}
    },

    // Test case 4: Updated with correct RSBOX values
    {
        {$01, $11, $13, $04},
        {$05, $12, $0F, $14},
        {$0B, $06, $07, $08},
        {$09, $0A, $0E, $0C}
    },

    // Test case 5: Updated with correct RSBOX values
    {
        {$A4, $68, $6B, $02},
        {$9F, $5B, $6A, $9C},
        {$EA, $50, $7F, $35},
        {$49, $B8, $4A, $AB}
    },

    // Test case 6: Updated with correct RSBOX values
    {
        {$7D, $09, $62, $ED},
        {$17, $FB, $27, $66},
        {$3A, $BF, $97, $94},
        {$6B, $38, $02, $E3}
    },

    // Test case 7: Updated with correct RSBOX values
    {
        {$2A, $2A, $2A, $2A},
        {$C6, $C6, $C6, $C6},
        {$07, $07, $07, $07},
        {$7D, $7D, $7D, $7D}
    },

    // Test case 8: Updated with correct RSBOX values
    {
        {$52, $09, $6A, $D5},
        {$55, $21, $0C, $7D},
        {$6B, $3A, $91, $11},
        {$F4, $1F, $DD, $A8}
    }
}

// Add this helper function to verify RSBOX mappings directly
define_function integer VerifyRSBOXMapping(integer testNum) {
    stack_var integer i, j
    stack_var integer index
    stack_var char input, expected, actual
    stack_var integer passCount, failCount
    stack_var char msg[100]

    passCount = 0
    failCount = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'=== RSBOX Direct Verification for Test ', itoa(testNum), ' ==='")

    for (i = 1; i <= 4; i++) {
        for (j = 1; j <= 4; j++) {
            // Get the input value from test
            input = INVSUBBYTES_TEST[testNum][i][j]

            // Look up directly in RSBOX
            index = input + 1  // +1 for NetLinx
            actual = RSBOX[index]

            // Get expected value from test vector
            expected = INVSUBBYTES_EXPECTED[testNum][i][j]

            if (actual == expected) {
                passCount++
            } else {
                failCount++
                msg = "'✗ Position [', itoa(i), ',', itoa(j), ']: Input $', format('%02X', input),
                      ' -> Expected: $', format('%02X', expected),
                      ', Actual RSBOX lookup: $', format('%02X', actual)"
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, msg)
            }
        }
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Verification results: ', itoa(passCount), ' passed, ', itoa(failCount), ' failed'")

    return (failCount == 0)
}

// Update the test runner function to use the verification
define_function RunNAVAes128InvSubBytesTests() {
    stack_var integer testNum
    stack_var char state[4][4]
    stack_var char expected[4][4]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128InvSubBytes ******************')

    // Test each input/expected pair
    for (testNum = 1; testNum <= length_array(INVSUBBYTES_TEST); testNum++) {
        stack_var integer passed

        // Setup test state matrix
        SetupMatrix(INVSUBBYTES_TEST[testNum], state)

        // Setup expected result
        SetupMatrix(INVSUBBYTES_EXPECTED[testNum], expected)

        // Call the inverse substitution operation
        NAVAes128InvSubBytes(state)

        // Check if result matches expected
        passed = CompareMatrices(state, expected)

        if (passed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' passed'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' failed'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Input state:'")
            NAVAes128LogStateMatrix(INVSUBBYTES_TEST[testNum])
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected state after InvSubBytes:'")
            NAVAes128LogStateMatrix(expected)
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Actual state after InvSubBytes:'")
            NAVAes128LogStateMatrix(state)
        }
    }

    // Test inverse of forward operation (SubBytes followed by InvSubBytes)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Additional test: SubBytes followed by InvSubBytes'")
    {
        stack_var char original[4][4]
        stack_var char processed[4][4]
        stack_var integer i, j
        stack_var integer passed

        // Create a test matrix with various values
        for (i = 1; i <= 4; i++) {
            for (j = 1; j <= 4; j++) {
                original[i][j] = type_cast(((i * j * 13) & 255))
                processed[i][j] = original[i][j]
            }
        }

        // Apply SubBytes
        NAVAes128SubBytes(processed)

        // Then apply InvSubBytes to reverse it
        NAVAes128InvSubBytes(processed)

        // Check if we got the original matrix back
        passed = CompareMatrices(original, processed)

        if (passed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Inverse test passed: SubBytes + InvSubBytes = Identity'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Inverse test failed: SubBytes + InvSubBytes != Identity'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Original matrix:'")
            NAVAes128LogStateMatrix(original)
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'After SubBytes+InvSubBytes:'")
            NAVAes128LogStateMatrix(processed)
        }
    }

    // For each failing test, add verification
    for (testNum = 3; testNum <= 8; testNum++) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Verifying RSBOX mapping for Test ', itoa(testNum)")
        VerifyRSBOXMapping(testNum)
    }
}
