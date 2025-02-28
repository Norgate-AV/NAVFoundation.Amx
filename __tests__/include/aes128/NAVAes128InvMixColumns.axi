PROGRAM_NAME='NAVAes128InvMixColumns'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// Test cases with input data (after MixColumns) and expected output after InvMixColumns
constant char INVMIXCOLUMNS_TEST[][][4] = {
    // Test case 1: All zeros
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 2: FIPS-197 example after MixColumns
    {
        {$ba, $75, $f4, $7a}, // Result of MixColumns on original input
        {$84, $a3, $fa, $d5},
        {$1f, $63, $b7, $d9},
        {$47, $6b, $f8, $7b}
    },

    // Test case 3: Simple non-zero values
    {
        {$01, $01, $01, $01},
        {$01, $01, $01, $01},
        {$01, $01, $01, $01},
        {$01, $01, $01, $01}
    },

    // Test case 4: Identity matrix after MixColumns
    {
        {$02, $03, $01, $01}, // Column 1 after MixColumns on [1,0,0,0]
        {$01, $02, $03, $01}, // Column 2 after MixColumns on [0,1,0,0]
        {$01, $01, $02, $03}, // Column 3 after MixColumns on [0,0,1,0]
        {$03, $01, $01, $02}  // Column 4 after MixColumns on [0,0,0,1]
    },

    // Test case 5: Common test pattern for GF(2^8) matrix operations
    {
        {$e5, $6e, $8b, $92},
        {$b0, $2a, $fd, $f7},
        {$c7, $76, $db, $4a},
        {$08, $d7, $9c, $c1}
    },

    // Test case 6: All the same values
    {
        {$aa, $aa, $aa, $aa},
        {$aa, $aa, $aa, $aa},
        {$aa, $aa, $aa, $aa},
        {$aa, $aa, $aa, $aa}
    },

    // Test case 7: Alternating bits
    {
        {$55, $aa, $55, $aa},
        {$aa, $55, $aa, $55},
        {$55, $aa, $55, $aa},
        {$aa, $55, $aa, $55}
    },

    // Test case 8: FIPS-197 another example
    {
        {$47, $37, $94, $ed},
        {$40, $d4, $e4, $a5},
        {$a3, $70, $3a, $a6},
        {$4c, $9f, $42, $bc}
    }
}

// Expected outputs after inverse mix columns operation
constant char INVMIXCOLUMNS_EXPECTED[][][4] = {
    // Test case 1: All zeros remain unchanged (unchanged)
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 2: Update with the actual correct inverse
    {
        {$1F, $EE, $80, $E0},
        {$F3, $41, $17, $26},
        {$76, $5F, $41, $59},
        {$FC, $2E, $97, $92}
    },

    // Test case 3: Simple non-zero values remain the same (unchanged)
    {
        {$01, $01, $01, $01},
        {$01, $01, $01, $01},
        {$01, $01, $01, $01},
        {$01, $01, $01, $01}
    },

    // Test case 4: Identity matrix expected result (unchanged)
    {
        {$01, $00, $00, $00},
        {$00, $01, $00, $00},
        {$00, $00, $01, $00},
        {$00, $00, $00, $01}
    },

    // Test case 5: Updated with actual correct inverse
    {
        {$E1, $0A, $9E, $CA},
        {$AE, $C7, $8C, $91},
        {$EC, $C3, $AC, $D5},
        {$39, $EB, $8F, $60}
    },

    // Test case 6: All same values remain the same (unchanged)
    {
        {$AA, $AA, $AA, $AA},
        {$AA, $AA, $AA, $AA},
        {$AA, $AA, $AA, $AA},
        {$AA, $AA, $AA, $AA}
    },

    // Test case 7: Updated with actual correct inverse
    {
        {$B0, $4F, $B0, $4F},
        {$4F, $B0, $4F, $B0},
        {$B0, $4F, $B0, $4F},
        {$4F, $B0, $4F, $B0}
    },

    // Test case 8: Updated with actual correct inverse
    {
        {$1D, $81, $B2, $BE},
        {$44, $DC, $A5, $33},
        {$32, $DE, $0C, $51},
        {$83, $8F, $13, $8E}
    }
}


define_function RunNAVAes128InvMixColumnsTests() {
    stack_var integer testNum
    stack_var char state[4][4]
    stack_var char expected[4][4]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128InvMixColumns ******************')

    // Test each input/expected pair
    for (testNum = 1; testNum <= length_array(INVMIXCOLUMNS_TEST); testNum++) {
        stack_var integer passed

        // Setup test state matrix
        SetupMatrix(INVMIXCOLUMNS_TEST[testNum], state)

        // Setup expected result
        SetupMatrix(INVMIXCOLUMNS_EXPECTED[testNum], expected)

        // Call the inverse mix columns operation
        NAVAes128InvMixColumns(state)

        // Check if result matches expected
        passed = CompareMatrices(state, expected)

        if (passed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' passed'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' failed'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Input state:'")
            NAVAes128LogStateMatrix(INVMIXCOLUMNS_TEST[testNum])
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected state after InvMixColumns:'")
            NAVAes128LogStateMatrix(expected)
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Actual state after InvMixColumns:'")
            NAVAes128LogStateMatrix(state)
        }
    }

    // Test inverse of forward operation (MixColumns followed by InvMixColumns)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Additional test: MixColumns followed by InvMixColumns'")
    {
        stack_var char original[4][4]
        stack_var char processed[4][4]
        stack_var integer i, j
        stack_var integer passed

        // Create a test matrix with various values
        for (i = 1; i <= 4; i++) {
            for (j = 1; j <= 4; j++) {
                original[i][j] = type_cast(((i + j) * 13) & 255)
                processed[i][j] = original[i][j]
            }
        }

        // Apply MixColumns
        NAVAes128MixColumns(processed)

        // Then apply InvMixColumns to reverse it
        NAVAes128InvMixColumns(processed)

        // Check if we got the original matrix back
        passed = CompareMatrices(original, processed)

        if (passed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Inverse test passed: MixColumns + InvMixColumns = Identity'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Inverse test failed: MixColumns + InvMixColumns != Identity'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Original matrix:'")
            NAVAes128LogStateMatrix(original)
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'After MixColumns+InvMixColumns:'")
            NAVAes128LogStateMatrix(processed)
        }
    }
}
