#include 'NAVFoundation.Testing.axi'

DEFINE_VARIABLE

volatile _NAVUnitTestSuite testSuite

volatile char names[][NAV_MAX_BUFFER] = {
    'Eve',
    'Charlie',
    'George',
    'Frank',
    'Dave',
    'Alice',
    'Hank',
    'Bob',
    'Ivan',
    'Iva'
}


define_function TestStringCompare(char value[][]) {
    stack_var sinteger result
    stack_var integer x

    for (x = 1; x <= max_length_array(value) - 1; x++) {
        // NAVLog("'Comparing "', value[x], '" to "', value[x + 1], '"'")
        result = NAVStringCompare(value[x], value[x + 1])

        if (result < 0) {
            NAVLog("'Result: "', value[x], '" is Less than "', value[x + 1], '"'")
            continue
        }

        if (result > 0) {
            NAVLog("'Result: "', value[x], '" is Greater than "', value[x + 1], '"'")
            continue
        }

        NAVLog("'Result: "', value[x], '" is Equal to "', value[x + 1], '"'")
    }
}





define_function InitializeTestSuite(_NAVUnitTestSuite suite) {

    stack_var _NAVUnitTestWithStringResult test1
    stack_var _NAVUnitTestWithStringResult test2

    NAVUnitTestSuiteInit(suite, 'First Test Suite', 'A suite of tests to test the NAV Unit Test Suite')

    NAVUnitTestWithStringResultInit(test1, 'NAVStripRight', 'should remove 1 character from the end of the string')
    NAVUnitTestSuiteAddTestWithStringResult(suite, test1)

    NAVUnitTestWithStringResultInit(test1, 'NAVStripLeft', 'should remove 1 character from the beginning of the string')
    NAVUnitTestSuiteAddTestWithStringResult(suite, test2)

    //NAVUnitTestSuiteRun(suite)
}
