PROGRAM_NAME='NAVFoundation.FileUtils.Tests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.FileUtils.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


DEFINE_CONSTANT


DEFINE_TYPE


DEFINE_VARIABLE


define_function ListDirectory() {
    stack_var _NAVFileEntity entities[255]
    stack_var slong count
    stack_var integer x

    count = NAVReadDirectory('/', entities)
    if (count < 0) {
        NAVLog('Error reading directory')
        return
    }

    if (count == 0) {
        NAVLog('No files found')
        return
    }

    for (x = 1; x <= length_array(entities); x++) {
        stack_var _NAVFileEntity entity

        entity = entities[x]

        NAVLog("'Entity ', itoa(x), ' Name: ', entity.Name")
        NAVLog("'Entity ', itoa(x), ' BaseName: ', entity.BaseName")
        NAVLog("'Entity ', itoa(x), ' Extension: ', entity.Extension")
        NAVLog("'Entity ', itoa(x), ' Path: ', entity.Path")
        NAVLog("'Entity ', itoa(x), ' Parent: ', entity.Parent")
        NAVLog("'Entity ', itoa(x), ' IsDirectory: ', NAVBooleanToString(entity.IsDirectory)")
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
}


define_function NAVUnitTestWithStringResultCallback(_NAVUnitTestWithStringResult test) {
    stack_var string result

    if (NAVUnitTestGetName(test) == 'NAVStripRight') {
        result = NAVStripRight('Hello World', 1)
        NAVUnitTestWithStringResultSetResult(test, result)
        NAVUnitTestWithStringResultSetExpectedResult(test, 'Hello Worl')
    }

    if (NAVUnitTestGetName(test) == 'NAVStripLeft') {
        result = NAVStripLeft('Hello World', 1)
        NAVUnitTestWithStringResultSetResult(test, result)
        NAVUnitTestWithStringResultSetExpectedResult(test, 'ello World')
    }
}


DEFINE_START {

}


DEFINE_EVENT


