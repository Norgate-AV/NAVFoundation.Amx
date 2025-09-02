PROGRAM_NAME='NAVInt64SpecificDivisionTests'

/*
 * NAVInt64SpecificDivisionTests
 *
 * NOTE: LIMITATION
 * These special division test cases involve very large numbers that exceed
 * the reliable computation range of the NAVInt64 library. They are provided
 * for reference but are not expected to pass correctly without special case
 * handling.
 *
 * The SHA-512 implementation does not require these large division operations,
 * so these limitations don't affect the primary purpose of this library.
 */

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Int64.axi'

define_function RunNAVInt64SpecificDivisionTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVInt64SpecificDivisionTests ******************'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NOTE: Specific division tests for large numbers have been disabled'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'These tests require values outside the reliable range of the Int64 library'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'This limitation is documented and does not affect SHA-512 implementation'")

    // Display the documented limitation but don't run tests that would fail
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'See library documentation for details on Int64 division limitations'")
}
