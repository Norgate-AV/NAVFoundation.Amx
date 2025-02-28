PROGRAM_NAME='NAVPbkdf2Shared'

#IF_NOT_DEFINED __NAV_PBKDF2_SHARED__
#DEFINE __NAV_PBKDF2_SHARED__ 'NAVPbkdf2Shared'

#include 'NAVFoundation.Core.axi'

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

// Helper function to copy data from constant array to destination array
// This is needed because we store test vectors as constants
define_function format_to_array(char dest[], char source[]) {
    stack_var integer i
    stack_var integer len

    // First, determine the length to copy based on source array
    len = length_array(source)

    // Initialize destination array with the correct length
    set_length_array(dest, len)

    // Copy data from source to destination
    for (i = 1; i <= len; i++) {
        dest[i] = source[i]
    }
}

#END_IF // __NAV_PBKDF2_SHARED__
