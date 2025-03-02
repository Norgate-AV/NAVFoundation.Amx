PROGRAM_NAME='NAVQueueInit'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Queue.axi'

DEFINE_CONSTANT

integer QUEUE_INIT_TEST_SIZE = 5

constant integer QUEUE_INIT_TEST_CASES[][] = {
    // { test_size, expected_capacity }
    { 5, 5 },                   // Normal case
    { -1, NAV_MAX_QUEUE_ITEMS },  // Negative input
    { 0, NAV_MAX_QUEUE_ITEMS },   // Zero input
    { NAV_MAX_QUEUE_ITEMS + 10, NAV_MAX_QUEUE_ITEMS }  // Too large input
}


define_function TestNAVQueueInit() {
    stack_var integer x
    stack_var _NAVQueue queue

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVQueueInit *****************'")

    for (x = 1; x <= length_array(QUEUE_INIT_TEST_CASES); x++) {
        stack_var integer test_size
        stack_var integer expected_capacity

        test_size = QUEUE_INIT_TEST_CASES[x][1]
        expected_capacity = QUEUE_INIT_TEST_CASES[x][2]

        // Test queue initialization
        NAVQueueInit(queue, test_size)

        // Test capacity setting
        if (!NAVAssertIntegerEqual(queue.Capacity, expected_capacity)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected capacity: ', itoa(expected_capacity), ' but got: ', itoa(queue.Capacity)")
            continue
        }

        // Test head initialization
        if (!NAVAssertIntegerEqual(queue.Head, 0)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected Head: 0 but got: ', itoa(queue.Head)")
            continue
        }

        // Test tail initialization
        if (!NAVAssertIntegerEqual(queue.Tail, queue.Capacity)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected Tail: ', itoa(queue.Capacity), ' but got: ', itoa(queue.Tail)")
            continue
        }

        // Test count initialization
        if (!NAVAssertIntegerEqual(queue.Count, 0)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected Count: 0 but got: ', itoa(queue.Count)")
            continue
        }

        // Test items initialization
        if (!NAVAssertStringEqual(queue.Items[1], 'NAV_NULL')) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected Items[1]: NAV_NULL but got: ', queue.Items[1]")
            continue
        }

        NAVLogTestPassed(x)
    }
}
