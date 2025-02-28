PROGRAM_NAME='NAVAes128XTime'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

// Test cases for xtime operation
// Each row is {input, expected_output}
DEFINE_CONSTANT
constant char XTIME_TEST[][2] = {
    {$00, $00},  // 0 << 1 = 0
    {$01, $02},  // 1 << 1 = 2
    {$02, $04},  // 2 << 1 = 4
    {$7F, $FE},  // 01111111 << 1 = 11111110
    {$80, $1B},  // 10000000 << 1 = 00011011 (with reduction)
    {$C3, $9D},  // 11000011 << 1 = 10000110 ^ 00011011 = 10011101 (corrected)
    {$FF, $E5}   // 11111111 << 1 = 11111110 ^ 00011011 = 11100101
}


define_function RunNAVAes128XTimeTests() {
    stack_var integer i

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128XTime ******************')

    for (i = 1; i <= length_array(XTIME_TEST); i++) {
        stack_var char input
        stack_var char expected
        stack_var char result

        input = XTIME_TEST[i][1]
        expected = XTIME_TEST[i][2]
        result = NAVAes128xtime(input)

        if (result != expected) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed. Expected $', format('%02X', expected), ' but got $', format('%02X', result)")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed'")
    }
}
