PROGRAM_NAME='NAVAes128StateToBuffer'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// Test vectors for StateToBuffer
constant char STATE_TEST_MATRICES[3][4][4] = {
    // Test 1: Sequential values to clearly show column-major ordering
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

// Expected output buffers after StateToBuffer
constant char EXPECTED_BUFFERS[][16] = {
    // Test 1: Sequential values
    {
        $00, $10, $20, $30,  // First column
        $01, $11, $21, $31,  // Second column
        $02, $12, $22, $32,  // Third column
        $03, $13, $23, $33   // Fourth column
    },

    // Test 2: FIPS-197 example state
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

define_function RunNAVAes128StateToBufferTests() {
    stack_var integer i
    stack_var char buffer[16]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128StateToBuffer ******************')

    for (i = 1; i <= length_array(STATE_TEST_MATRICES); i++) {
        stack_var integer j
        stack_var char failed

        // Test StateToBuffer conversion
        NAVAes128StateToBuffer(STATE_TEST_MATRICES[i], buffer)

        // Verify buffer against expected output
        for (j = 1; j <= 16; j++) {
            if (buffer[j] != EXPECTED_BUFFERS[i][j]) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed at position ', itoa(j)")
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected ', format('$%02X', EXPECTED_BUFFERS[i][j]), ' but got ', format('$%02X', buffer[j])")
                failed = true
            }
        }

        if (failed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Input state matrix:'")
            NAVAes128LogStateMatrix(STATE_TEST_MATRICES[i])

            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Output buffer: ', NAVByteArrayToNetLinxHexString(buffer)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Expected buffer: ', NAVByteArrayToNetLinxHexString(EXPECTED_BUFFERS[i])")

            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed'")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed'")
    }
}
