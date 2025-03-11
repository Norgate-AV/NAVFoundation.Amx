#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Assert.axi'

define_function RunAssertTests() {
    // Basic assertion tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running Basic Assertion Tests ====='")

    // Test assert true with true condition (should pass)
    NAVAssert(1, "'Assert true test'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Assert true test passed'")

    // Test assert equals with equal values (should pass)
    NAVAssertEquals(5, 5, "'Assert equals test'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Assert equals test passed'")

    // Test assert not equals with different values (should pass)
    NAVAssertNotEquals(5, 10, "'Assert not equals test'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Assert not equals test passed'")

    // Test string assertion (should pass)
    NAVAssertStringsEqual('test', 'test', "'Assert strings equal test'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Assert strings equal test passed'")

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'All assertion tests completed'")
}
