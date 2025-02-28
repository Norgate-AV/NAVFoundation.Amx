PROGRAM_NAME='NAVAes128Shared'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'


define_function SetupMatrix(char source[4][4], char dest[4][4]) {
    stack_var integer i, j

    for (i = 1; i <= 4; i++) {
        for (j = 1; j <= 4; j++) {
            dest[i][j] = source[i][j]
        }
    }
}


// Utility function to convert a buffer to a hex string
define_function char[NAV_MAX_BUFFER] BufferToHexString(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    result = ''
    for (i = 1; i <= length_array(buffer); i++) {
        result = "result, format('$%02X ', buffer[i])"
    }

    return result
}


// Helper function to compare two matrices
define_function integer CompareMatrices(char a[4][4], char b[4][4]) {
    stack_var integer r, c

    for (r = 1; r <= 4; r++) {
        for (c = 1; c <= 4; c++) {
            if (a[r][c] != b[r][c]) {
                return false
            }
        }
    }

    return true
}
