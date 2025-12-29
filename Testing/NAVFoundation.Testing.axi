PROGRAM_NAME='NAVFoundation.Testing'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_TESTING__
#DEFINE __NAV_FOUNDATION_TESTING__ 'NAVFoundation.Testing'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

constant integer NAV_MAX_TESTS                          = 50

constant integer NAV_TEST_MAX_STRING_ARRAY_SIZE         = 255
constant integer NAV_TEST_MAX_INTEGER_ARRAY_SIZE        = 255

constant integer NAV_TEST_TYPE_STRING_RESULT            = 1
constant integer NAV_TEST_TYPE_STRING_ARRAY_RESULT      = 2
constant integer NAV_TEST_TYPE_INTEGER_RESULT           = 3
constant integer NAV_TEST_TYPE_INTEGER_ARRAY_RESULT     = 4


DEFINE_TYPE

struct _NAVUnitTestProperties {
    char Name[NAV_MAX_CHARS]
    char Description[NAV_MAX_CHARS]
    char Message[NAV_MAX_CHARS]
    integer Skip
    integer Passed
}


struct _NAVUnitTestStringResult {
    char Expected[NAV_MAX_BUFFER]
    char Actual[NAV_MAX_BUFFER]
}


struct _NAVUnitTestStringArrayResult {
    char Expected[NAV_TEST_MAX_STRING_ARRAY_SIZE][NAV_MAX_BUFFER]
    char Actual[NAV_TEST_MAX_STRING_ARRAY_SIZE][NAV_MAX_BUFFER]
}


struct _NAVUnitTestIntegerResult {
    integer Expected
    integer Actual
}


struct _NAVUnitTestIntegerArrayResult {
    integer Expected[NAV_TEST_MAX_INTEGER_ARRAY_SIZE]
    integer Actual[NAV_TEST_MAX_INTEGER_ARRAY_SIZE]
}


struct _NAVUnitTestWithStringResult  {
    _NAVUnitTestProperties Properties
    _NAVUnitTestStringResult Result
}


struct _NAVUnitTestWithStringArrayResult  {
    _NAVUnitTestProperties Properties
    _NAVUnitTestStringArrayResult Result
}


struct _NAVUnitTestWithIntegerResult  {
    _NAVUnitTestProperties Properties
    _NAVUnitTestIntegerResult Result
}


struct _NAVUnitTestWithIntegerArrayResult  {
    _NAVUnitTestProperties Properties
    _NAVUnitTestIntegerArrayResult Result
}


struct _NAVUnitTestSuite {
    char Name[NAV_MAX_CHARS]
    char Description[NAV_MAX_CHARS]
    char Message[NAV_MAX_CHARS]

    integer Passed
    integer Total
    integer PassedCount
    integer FailedCount
    integer SkippedCount

    integer Type[NAV_MAX_TESTS]
    _NAVUnitTestWithStringResult StringResultTest[NAV_MAX_TESTS]
    _NAVUnitTestWithStringArrayResult StringArrayResultTest[NAV_MAX_TESTS]
    _NAVUnitTestWithIntegerResult IntegerResultTest[NAV_MAX_TESTS]
    _NAVUnitTestWithIntegerArrayResult IntegerArrayResultTest[NAV_MAX_TESTS]
}


define_function NAVUnitTestSuiteInit(_NAVUnitTestSuite suite, char name[], char description[]) {
    suite.Name = name
    suite.Description = description
    suite.Message = ""
    suite.Passed = 0
    suite.Total = 0
    suite.PassedCount = 0
    suite.FailedCount = 0
    suite.SkippedCount = 0
}


define_function NAVUnitTestSuiteAddTestWithStringResult(_NAVUnitTestSuite suite, _NAVUnitTestWithStringResult test) {
    if (suite.Total >= NAV_MAX_TESTS) {
        NAVLog("'NAVUnitTestSuiteAddTestWithStringResult(): Maximum number of tests reached'")
        return
    }

    suite.Total++
    suite.Type[suite.Total] = NAV_TEST_TYPE_STRING_RESULT

    // set_length_array(suite.StringResultTest[suite.Total], suite.Total)

    // suite.StringResultTest[suite.Total].Properties.Name = name
    // suite.StringResultTest[suite.Total].Properties.Description = description
    // suite.StringResultTest[suite.Total].Properties.Message = ""
    // suite.StringResultTest[suite.Total].Properties.Skip = skip
    // suite.StringResultTest[suite.Total].Properties.Passed = 0
    // suite.StringResultTest[suite.Total].Result.Expected = expected
    // suite.StringResultTest[suite.Total].Result.Actual = actual

    suite.StringResultTest[suite.Total] = test
}


define_function NAVUnitTestWithStringResultInit(_NAVUnitTestWithStringResult test, char name[], char description[]) {
    test.Properties.Name = name
    test.Properties.Description = description
    test.Properties.Message = ""
    test.Properties.Skip = false
    test.Properties.Passed = false
}


// define_function NAVUnitTestSuiteRun(_NAVUnitTestSuite suite) {
//     stack_var integer x

//     for (x = 1; x <= suite.Total; x++) {
//         switch (suite.Type[x]) {
//             case NAV_TEST_TYPE_STRING_RESULT: {
//                 stack_var _NAVUnitTestWithStringResult test

//                 test = suite.StringResultTest[x]

//                 NAVUnitTestRunWithStringResult(suite, test)
//             }
//         }
//     }
// }


// define_function NAVUnitTestRunWithStringResult(_NAVUnitTestSuite suite, _NAVUnitTestWithStringResult test) {
//     if (test.Properties.Skip) {
//         test.Properties.Message = "Test skipped"
//         test.Properties.Passed = false
//         suite.SkippedCount++
//         return
//     }

//     // Invoke a callback function to run the test
//     #IF_DEFINED NAV_TEST_CALLBACK
//     NAV_TEST_CALLBACK(test)
//     #END_IF

define_function NAVLogTestPassed(integer test) {
    NAVLog("'Test ', itoa(test), ' passed'")
}


define_function NAVLogTestFailed(integer test, char expected[], char result[]) {
    stack_var char message[NAV_MAX_BUFFER]

    message = "'Test ', itoa(test), ' failed'"

    // Show comparison if expected has content OR if result has content
    // This covers cases where:
    // - expected='abc', result='xyz' → Show both
    // - expected='abc', result='' → Show expected, got empty
    // - expected='', result='xyz' → Show expected empty, got xyz
    // - expected='', result='' → Show expected empty, got empty
    if (length_array(expected) || length_array(result)) {
        message = "message, '. Expected: "', expected, '"'"
        message = "message, ', but got: "', result, '".'"
    }

    NAVLog(message)
}


#END_IF // __NAV_FOUNDATION_TESTING__
