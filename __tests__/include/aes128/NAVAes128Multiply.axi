PROGRAM_NAME='NAVAes128Multiply'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

// Test cases for multiply operation
// Each row is {input1, input2, expected_output}
DEFINE_CONSTANT
constant char MULTIPLY_TEST[][3] = {
    {$00, $00, $00},  // 0 * 0 = 0
    {$01, $01, $01},  // 1 * 1 = 1
    {$02, $02, $04},  // 2 * 2 = 4
    {$53, $09, $FD},  // Verified with Python implementation
    {$53, $0B, $5B},  // Verified with Python implementation
    {$53, $0D, $AA},  // Verified with Python implementation
    {$53, $0E, $5F},  // Verified with Python implementation
    {$FF, $0E, $8D},  // Verified with Python implementation
    {$FF, $FF, $13}   // Verified with Python implementation
}


define_function RunNAVAes128MultiplyTests() {
    stack_var integer i

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128Multiply ******************')

    for (i = 1; i <= length_array(MULTIPLY_TEST); i++) {
        stack_var char input1
        stack_var char input2
        stack_var char expected
        stack_var char result

        input1 = MULTIPLY_TEST[i][1]
        input2 = MULTIPLY_TEST[i][2]
        expected = MULTIPLY_TEST[i][3]

        result = NAVAes128Multiply(input1, input2)

        if (result != expected) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ': $', format('%02X', input1),
                   ' * $', format('%02X', input2), ' = $', format('%02X', result)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed. Expected $',
                       format('%02X', expected), ' but got $', format('%02X', result)")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed'")
    }
}
