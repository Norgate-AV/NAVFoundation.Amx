PROGRAM_NAME='NAVAes128Decrypt'


define_function RunNAVAes128DecryptTests() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128Decrypt ******************')

    for (x = 1; x <= length_array(TEST); x++) {
        stack_var char result[2048]

        // Fix: Swap the parameters here too for consistency
        result = NAVAes128Decrypt(TEST[x][2], EXPECTED[x])

        if (result != TEST[x][1]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected hex: "', NAVByteArrayToNetLinxHexString(TEST[x][1]), '"'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Actual hex  : "', NAVByteArrayToNetLinxHexString(result), '"'")

            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' passed'")
    }
}
