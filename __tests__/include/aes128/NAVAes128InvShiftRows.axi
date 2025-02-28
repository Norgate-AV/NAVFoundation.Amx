PROGRAM_NAME='NAVAes128InvShiftRows'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// Test cases with input and expected output after InvShiftRows
constant char INVSHIFTROWS_TEST[][][4] = {
    // Test case 1: All zeros
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 2: Simple values 1-16
    {
        {$01, $05, $09, $0D},
        {$02, $06, $0A, $0E},
        {$03, $07, $0B, $0F},
        {$04, $08, $0C, $10}
    },

    // Test case 3: FIPS-197 example after ShiftRows
    {
        {$d4, $e0, $b8, $1e},
        {$27, $bf, $b4, $41},
        {$11, $98, $5d, $52},
        {$ae, $f1, $e5, $30}
    },

    // Test case 4: Alternating bits pattern
    {
        {$AA, $AA, $AA, $AA},
        {$55, $55, $55, $55},
        {$AA, $AA, $AA, $AA},
        {$55, $55, $55, $55}
    },

    // Test case 5: FIPS-197 example after InvShiftRows
    {
        {$d4, $e0, $b8, $1e},
        {$41, $27, $bf, $b4},
        {$5d, $52, $11, $98},
        {$30, $ae, $f1, $e5}
    },

    // Test case 6: Single value in different positions
    {
        {$00, $00, $00, $00},
        {$00, $01, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 7: All the same value
    {
        {$FF, $FF, $FF, $FF},
        {$FF, $FF, $FF, $FF},
        {$FF, $FF, $FF, $FF},
        {$FF, $FF, $FF, $FF}
    },

    // Test case 8: Sequence in columns
    {
        {$01, $02, $03, $04},
        {$05, $06, $07, $08},
        {$09, $0A, $0B, $0C},
        {$0D, $0E, $0F, $10}
    }
}

// Expected outputs after inverse shift rows operation
constant char INVSHIFTROWS_EXPECTED[][][4] = {
    // Test case 1: All zeros remain unchanged
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 2: Simple values inverted
    {
        {$01, $05, $09, $0D},
        {$0E, $02, $06, $0A},
        {$0B, $0F, $03, $07},
        {$08, $0C, $10, $04}
    },

    // Test case 3: Fix expected output for FIPS-197 example
    {
        {$d4, $e0, $b8, $1e},
        {$41, $27, $bf, $b4},
        {$5d, $52, $11, $98},
        {$f1, $e5, $30, $ae}  // Fixed: row 4 shifts right by 3 (left by 1)
    },

    // Test case 4: Alternating bits pattern (unchanged due to same values in each row)
    {
        {$AA, $AA, $AA, $AA},
        {$55, $55, $55, $55},
        {$AA, $AA, $AA, $AA},
        {$55, $55, $55, $55}
    },

    // Test case 5: Fix expected output
    {
        {$d4, $e0, $b8, $1e},
        {$b4, $41, $27, $bf},  // Fixed: row 2 shifts right by 1
        {$11, $98, $5d, $52},
        {$ae, $f1, $e5, $30}  // Fixed: row 4 shifts right by 3
    },

    // Test case 6: Fix expected output
    {
        {$00, $00, $00, $00},
        {$00, $00, $01, $00},  // Fixed: row 2 shifts right by 1
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 7: All the same value (unchanged)
    {
        {$FF, $FF, $FF, $FF},
        {$FF, $FF, $FF, $FF},
        {$FF, $FF, $FF, $FF},
        {$FF, $FF, $FF, $FF}
    },

    // Test case 8: Sequence in columns inverted
    {
        {$01, $02, $03, $04},
        {$08, $05, $06, $07},
        {$0B, $0C, $09, $0A},
        {$0E, $0F, $10, $0D}
    }
}


define_function RunNAVAes128InvShiftRowsTests() {
    stack_var integer testNum
    stack_var char state[4][4]
    stack_var char expected[4][4]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128InvShiftRows ******************')

    // Test each input/expected pair
    for (testNum = 1; testNum <= length_array(INVSHIFTROWS_TEST); testNum++) {
        stack_var integer passed

        // Setup test state matrix
        SetupMatrix(INVSHIFTROWS_TEST[testNum], state)

        // Setup expected result
        SetupMatrix(INVSHIFTROWS_EXPECTED[testNum], expected)

        // Call the inverse shift rows operation
        NAVAes128InvShiftRows(state)

        // Check if result matches expected
        passed = CompareMatrices(state, expected)

        if (passed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' passed'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' failed'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Input state:'")
            NAVAes128LogStateMatrix(INVSHIFTROWS_TEST[testNum])
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected state after InvShiftRows:'")
            NAVAes128LogStateMatrix(expected)
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Actual state after InvShiftRows:'")
            NAVAes128LogStateMatrix(state)
        }
    }

    // Test inverse of forward operation (ShiftRows followed by InvShiftRows)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Additional test: ShiftRows followed by InvShiftRows'")
    {
        stack_var char original[4][4]
        stack_var char processed[4][4]
        stack_var integer i, j
        stack_var integer passed

        // Create a test matrix with unique values
        for (i = 1; i <= 4; i++) {
            for (j = 1; j <= 4; j++) {
                original[i][j] = type_cast(((i - 1) * 4 + j - 1))
                processed[i][j] = original[i][j]
            }
        }

        // Apply ShiftRows
        NAVAes128ShiftRows(processed)

        // Then apply InvShiftRows to reverse it
        NAVAes128InvShiftRows(processed)

        // Check if we got the original matrix back
        passed = CompareMatrices(original, processed)

        if (passed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Inverse test passed: ShiftRows + InvShiftRows = Identity'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Inverse test failed: ShiftRows + InvShiftRows != Identity'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Original matrix:'")
            NAVAes128LogStateMatrix(original)
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'After ShiftRows+InvShiftRows:'")
            NAVAes128LogStateMatrix(processed)
        }
    }
}
