PROGRAM_NAME='NAVAes128BufferToState'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// Test vectors for BufferToState
constant char BUFFER_TEST_INPUTS[][16] = {
    // Test 1: Sequential values to clearly show column-major ordering
    {
        $00, $10, $20, $30,  // First column
        $01, $11, $21, $31,  // Second column
        $02, $12, $22, $32,  // Third column
        $03, $13, $23, $33   // Fourth column
    },

    // Test 2: FIPS-197 example buffer
    {
        $32, $88, $31, $E0,  // First column
        $43, $5A, $31, $37,  // Second column
        $F6, $30, $98, $07,  // Third column
        $A8, $8D, $A2, $34   // Fourth column
    },

    // Test 3: All zeros
    {
        $00, $00, $00, $00,
        $00, $00, $00, $00,
        $00, $00, $00, $00,
        $00, $00, $00, $00
    }
}

// Expected state matrices after BufferToState
constant char EXPECTED_STATES[3][4][4] = {
    // Test 1: Sequential values
    {
        { $00, $01, $02, $03 },  // Row 0
        { $10, $11, $12, $13 },  // Row 1
        { $20, $21, $22, $23 },  // Row 2
        { $30, $31, $32, $33 }   // Row 3
    },

    // Test 2: FIPS-197 example state
    {
        { $32, $43, $F6, $A8 },  // Row 0
        { $88, $5A, $30, $8D },  // Row 1
        { $31, $31, $98, $A2 },  // Row 2
        { $E0, $37, $07, $34 }   // Row 3
    },

    // Test 3: All zeros
    {
        { $00, $00, $00, $00 },
        { $00, $00, $00, $00 },
        { $00, $00, $00, $00 },
        { $00, $00, $00, $00 }
    }
}

define_function RunNAVAes128BufferToStateTests() {
    stack_var integer i
    stack_var char state[4][4]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128BufferToState ******************')

    for (i = 1; i <= length_array(BUFFER_TEST_INPUTS); i++) {
        stack_var integer row, col
        stack_var char failed
        stack_var char buffer[16]

        // Copy test vector to buffer
        for (row = 1; row <= 16; row++) {
            buffer[row] = BUFFER_TEST_INPUTS[i][row]
        }

        // Test BufferToState conversion
        NAVAes128BufferToState(buffer, state)

        // Verify state matrix against expected output
        for (row = 1; row <= 4; row++) {
            for (col = 1; col <= 4; col++) {
                if (state[row][col] != EXPECTED_STATES[i][row][col]) {
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed at position [', itoa(row), ',', itoa(col), ']'")
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected ', format('$%02X', EXPECTED_STATES[i][row][col]), ' but got ', format('$%02X', state[row][col])")
                    failed = true
                }
            }
        }

        if (failed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Input buffer: ', NAVByteArrayToNetLinxHexString(buffer)")

            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Output state matrix:'")
            NAVAes128LogStateMatrix(state)

            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Expected state matrix:'")
            NAVAes128LogStateMatrix(EXPECTED_STATES[i])

            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed'")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed'")
    }
}
