PROGRAM_NAME='NAVInt64Shared'

/*
 * Common utility functions and definitions for Int64 tests
 */

#IF_NOT_DEFINED __NAV_INT64_SHARED__
#DEFINE __NAV_INT64_SHARED__ 'NAVInt64Shared'

#include 'NAVFoundation.Assert.axi'

/**
 * @function NAVInt64ToTestString
 * @description Helper function to create string representation of Int64 for test output
 *
 * @param {_NAVInt64} value - The Int64 value to represent as a string
 *
 * @returns {char[]} String representation in hex format
 */
define_function char[20] NAVInt64ToTestString(_NAVInt64 value) {
    return "'$', format('%08x', value.Hi), format('%08x', value.Lo)"
}

#END_IF // __NAV_INT64_SHARED__
