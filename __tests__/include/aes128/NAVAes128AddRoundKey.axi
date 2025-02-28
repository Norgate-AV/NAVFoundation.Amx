PROGRAM_NAME='NAVAes128AddRoundKey'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

constant char ADDROUNDKEY_TEST[][][4] = {
    // Test case 1: All zeros
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 2: From FIPS-197 Appendix A.1 - initial AddRoundKey
    {
        {$32, $88, $31, $e0},
        {$43, $5a, $31, $37},
        {$f6, $30, $98, $07},
        {$a8, $8d, $a2, $34}
    },

    // Test case 3: Simple pattern to verify XOR operation
    {
        {$aa, $aa, $aa, $aa},  // Pattern of alternating 1s and 0s
        {$55, $55, $55, $55},  // Opposite pattern
        {$ff, $ff, $ff, $ff},  // All 1s
        {$00, $00, $00, $00}   // All 0s
    }
}

// Round keys for each test case
constant char ADDROUNDKEY_KEYS[][][4] = {
    // Test case 1: All zeros key
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 2: FIPS-197 first round key
    {
        {$2b, $7e, $15, $16},
        {$28, $ae, $d2, $a6},
        {$ab, $f7, $15, $88},
        {$09, $cf, $4f, $3c}
    },

    // Test case 3: Simple pattern key
    {
        {$55, $55, $55, $55},  // Opposite of first row input
        {$aa, $aa, $aa, $aa},  // Opposite of second row input
        {$00, $00, $00, $00},  // XOR with all 1s
        {$ff, $ff, $ff, $ff}   // XOR with all 0s
    }
}

// Expected results that match column-major implementation directly
constant char ADDROUNDKEY_EXPECTED[][][4] = {
    // Test case 1: All zeros XOR all zeros = all zeros
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 2: Correct values for column-major XORing
    {
        {$19, $F6, $24, $F6},
        {$6B, $F4, $E3, $91},
        {$5D, $C7, $8D, $8F},
        {$A1, $42, $ED, $08}
    },

    // Test case 3: Correct values for column-major XORing
    {
        {$FF, $FF, $FF, $FF},
        {$FF, $FF, $FF, $FF},
        {$FF, $FF, $FF, $FF},
        {$FF, $FF, $FF, $FF}
    }
}

define_function RunNAVAes128AddRoundKeyTests() {
    stack_var integer i
    stack_var char state[4][4]
    stack_var char roundKey[176]
    stack_var char expected[4][4]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128AddRoundKey ******************')

    for (i = 1; i <= length_array(ADDROUNDKEY_TEST); i++) {
        stack_var integer j, k
        stack_var char failed

        // Setup test state and expected matrices
        SetupMatrix(ADDROUNDKEY_TEST[i], state)
        SetupMatrix(ADDROUNDKEY_EXPECTED[i], expected)

        // Simply pack round keys in column-major order directly
        for (j = 1; j <= 4; j++) {  // Column index
            for (k = 1; k <= 4; k++) {  // Row index
                roundKey[((j-1)*4) + k] = ADDROUNDKEY_KEYS[i][k][j]
            }
        }

        // Call the actual AddRoundKey function
        NAVAes128AddRoundKey(0, state, roundKey)

        // Compare result with expected
        for (j = 1; j <= 4; j++) {
            for (k = 1; k <= 4; k++) {
                if (state[j][k] != expected[j][k]) {
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed at position [',
                              itoa(j), '][', itoa(k), ']'")
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected $', format('%02X', expected[j][k]),
                              ' but got $', format('%02X', state[j][k])")
                    failed = true
                }
            }
        }

        if (failed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Input state:'")
            NAVAes128LogStateMatrix(ADDROUNDKEY_TEST[i])
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Round key matrix:'")
            NAVAes128LogStateMatrix(ADDROUNDKEY_KEYS[i])
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Output state:'")
            NAVAes128LogStateMatrix(state)
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Expected state:'")
            NAVAes128LogStateMatrix(expected)
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed'")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed'")
    }
}
