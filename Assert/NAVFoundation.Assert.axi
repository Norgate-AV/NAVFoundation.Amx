PROGRAM_NAME='NAVFoundation.Assert'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ASSERT__
#DEFINE __NAV_FOUNDATION_ASSERT__ 'NAVFoundation.Assert'

#include 'NAVFoundation.Int64.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


/**
 * @function NAVAssertCharEqual
 * @description Test if two char values are equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {char} expected - Expected value
 * @param {char} actual - Actual value
 *
 * @returns {char} true if equal, false otherwise
 */
define_function char NAVAssertCharEqual(char testName[], char expected, char actual) {
    if (expected == actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', itoa(actual)")
        return false
    }
}


/**
 * @function NAVAssertWideCharEqual
 * @description Test if two widechar values are equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {widechar} expected - Expected value
 * @param {widechar} actual - Actual value
 *
 * @returns {char} true if equal, false otherwise
 */
define_function char NAVAssertWideCharEqual(char testName[], widechar expected, widechar actual) {
    if (expected == actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', itoa(actual)")
        return false
    }
}


/**
 * @function NAVAssertIntegerEqual
 * @description Test if two integer values are equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {integer} expected - Expected value
 * @param {integer} actual - Actual value
 *
 * @returns {char} true if equal, false otherwise
 */
define_function char NAVAssertIntegerEqual(char testName[], integer expected, integer actual) {
    if (expected == actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', itoa(actual)")
        return false
    }
}


/**
 * @function NAVAssertSignedIntegerEqual
 * @description Test if two signed integer values are equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {sinteger} expected - Expected value
 * @param {sinteger} actual - Actual value
 *
 * @returns {char} true if equal, false otherwise
 */
define_function char NAVAssertSignedIntegerEqual(char testName[], sinteger expected, sinteger actual) {
    if (expected == actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', itoa(actual)")
        return false
    }
}


/**
 * @function NAVAssertLongEqual
 * @description Test if two long values are equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {long} expected - Expected value
 * @param {long} actual - Actual value
 *
 * @returns {char} true if equal, false otherwise
 */
define_function char NAVAssertLongEqual(char testName[], long expected, long actual) {
    if (expected == actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', itoa(actual)")
        return false
    }
}


/**
 * @function NAVAssertSignedLongEqual
 * @description Test if two signed long values are equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {slong} expected - Expected value
 * @param {slong} actual - Actual value
 *
 * @returns {char} true if equal, false otherwise
 */
define_function char NAVAssertSignedLongEqual(char testName[], slong expected, slong actual) {
    if (expected == actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', itoa(actual)")
        return false
    }
}


/**
 * @function NAVAssertFloatEqual
 * @description Test if two float values are equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {float} expected - Expected value
 * @param {float} actual - Actual value
 *
 * @returns {char} true if equal, false otherwise
 */
define_function char NAVAssertFloatEqual(char testName[], float expected, float actual) {
    if (expected == actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', ftoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', ftoa(actual)")
        return false
    }
}


/**
 * @function NAVAssertDoubleEqual
 * @description Test if two double values are equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {double} expected - Expected value
 * @param {double} actual - Actual value
 *
 * @returns {char} true if equal, false otherwise
 */
define_function char NAVAssertDoubleEqual(char testName[], double expected, double actual) {
    if (expected == actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', ftoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', ftoa(actual)")
        return false
    }
}


/**
 * @function NAVAssertBooleanEqual
 * @description Test if two boolean values are equal and log the result.
 *              This is an alias for NAVAssertCharEqual for better readability.
 *
 * @param {char[]} testName - Name of the test
 * @param {char} expected - Expected boolean value (0 or 1)
 * @param {char} actual - Actual boolean value (0 or 1)
 *
 * @returns {char} true if equal, false otherwise
 */
define_function char NAVAssertBooleanEqual(char testName[], char expected, char actual) {
    return NAVAssertCharEqual(testName, expected, actual)
}


/**
 * @function NAVAssertStringEqual
 * @description Test if two string values are equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {char[]} expected - Expected string
 * @param {char[]} actual - Actual string
 *
 * @returns {char} true if equal, false otherwise
 */
define_function char NAVAssertStringEqual(char testName[], char expected[], char actual[]) {
    if (expected == actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: "', expected, '"'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : "', actual, '"'")
        return false
    }
}


/**
 * @function NAVAssertInt64Equal
 * @description Test if two Int64 values are equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {_NAVInt64} expected - Expected value
 * @param {_NAVInt64} actual - Actual value
 *
 * @returns {char} true if equal, false otherwise
 */
define_function char NAVAssertInt64Equal(char testName[], _NAVInt64 expected, _NAVInt64 actual) {
    if (expected.Hi == actual.Hi && expected.Lo == actual.Lo) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected $', format('%08x', expected.Hi), format('%08x', expected.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got      $', format('%08x', actual.Hi), format('%08x', actual.Lo)")
        return false
    }
}


/**
 * @function NAVAssertStringNotEqual
 * @description Test if two string values are not equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {char[]} expected - Value that should not match
 * @param {char[]} actual - Actual value
 *
 * @returns {char} true if not equal (test passed), false otherwise
 */
define_function char NAVAssertStringNotEqual(char testName[], char expected[], char actual[]) {
    if (expected != actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected different from: "', expected, '"'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                    : "', actual, '"'")
        return false
    }
}

/**
 * @function NAVAssertIntegerNotEqual
 * @description Test if two integer values are not equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {integer} expected - Value that should not match
 * @param {integer} actual - Actual value
 *
 * @returns {char} true if not equal (test passed), false otherwise
 */
define_function char NAVAssertIntegerNotEqual(char testName[], integer expected, integer actual) {
    if (expected != actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected different from: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                    : ', itoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertIntegerGreaterThan
 * @description Test if actual integer value is greater than expected value and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {integer} expected - Value that actual should be greater than
 * @param {integer} actual - Actual value
 *
 * @returns {char} true if actual > expected (test passed), false otherwise
 */
define_function char NAVAssertIntegerGreaterThan(char testName[], integer expected, integer actual) {
    if (actual > expected) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected greater than: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                  : ', itoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertIntegerLessThan
 * @description Test if actual integer value is less than expected value and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {integer} expected - Value that actual should be less than
 * @param {integer} actual - Actual value
 *
 * @returns {char} true if actual < expected (test passed), false otherwise
 */
define_function char NAVAssertIntegerLessThan(char testName[], integer expected, integer actual) {
    if (actual < expected) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected less than: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got               : ', itoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertIntegerGreaterThanOrEqual
 * @description Test if actual integer value is greater than or equal to expected value and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {integer} expected - Value that actual should be greater than or equal to
 * @param {integer} actual - Actual value
 *
 * @returns {char} true if actual >= expected (test passed), false otherwise
 */
define_function char NAVAssertIntegerGreaterThanOrEqual(char testName[], integer expected, integer actual) {
    if (actual >= expected) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected greater than or equal to: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                              : ', itoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertIntegerLessThanOrEqual
 * @description Test if actual integer value is less than or equal to expected value and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {integer} expected - Value that actual should be less than or equal to
 * @param {integer} actual - Actual value
 *
 * @returns {char} true if actual <= expected (test passed), false otherwise
 */
define_function char NAVAssertIntegerLessThanOrEqual(char testName[], integer expected, integer actual) {
    if (actual <= expected) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected less than or equal to: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                           : ', itoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertFloatNotEqual
 * @description Test if two float values are not equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {float} expected - Value that should not match
 * @param {float} actual - Actual value
 *
 * @returns {char} true if not equal (test passed), false otherwise
 */
define_function char NAVAssertFloatNotEqual(char testName[], float expected, float actual) {
    if (expected != actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected different from: ', ftoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                    : ', ftoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertFloatGreaterThan
 * @description Test if actual float value is greater than expected value and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {float} expected - Value that actual should be greater than
 * @param {float} actual - Actual value
 *
 * @returns {char} true if actual > expected (test passed), false otherwise
 */
define_function char NAVAssertFloatGreaterThan(char testName[], float expected, float actual) {
    if (actual > expected) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected greater than: ', ftoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                  : ', ftoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertFloatLessThan
 * @description Test if actual float value is less than expected value and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {float} expected - Value that actual should be less than
 * @param {float} actual - Actual value
 *
 * @returns {char} true if actual < expected (test passed), false otherwise
 */
define_function char NAVAssertFloatLessThan(char testName[], float expected, float actual) {
    if (actual < expected) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected less than: ', ftoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got               : ', ftoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertFloatGreaterThanOrEqual
 * @description Test if actual float value is greater than or equal to expected value and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {float} expected - Value that actual should be greater than or equal to
 * @param {float} actual - Actual value
 *
 * @returns {char} true if actual >= expected (test passed), false otherwise
 */
define_function char NAVAssertFloatGreaterThanOrEqual(char testName[], float expected, float actual) {
    if (actual >= expected) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected greater than or equal to: ', ftoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                              : ', ftoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertFloatLessThanOrEqual
 * @description Test if actual float value is less than or equal to expected value and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {float} expected - Value that actual should be less than or equal to
 * @param {float} actual - Actual value
 *
 * @returns {char} true if actual <= expected (test passed), false otherwise
 */
define_function char NAVAssertFloatLessThanOrEqual(char testName[], float expected, float actual) {
    if (actual <= expected) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected less than or equal to: ', ftoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                           : ', ftoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertTrue
 * @description Test if a condition is true
 *
 * @param {char[]} testName - Name of the test
 * @param {char} condition - Condition to test
 *
 * @returns {char} true if condition is true, false otherwise
 */
define_function char NAVAssertTrue(char testName[], char condition) {
    if (condition == true) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: true'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : false'")
        return false
    }
}

/**
 * @function NAVAssertFalse
 * @description Test if a condition is false
 *
 * @param {char[]} testName - Name of the test
 * @param {char} condition - Condition to test
 *
 * @returns {char} true if condition is false, false otherwise
 */
define_function char NAVAssertFalse(char testName[], char condition) {
    if (condition == false) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: false'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : true'")
        return false
    }
}

/**
 * @function NAVAssertCharNotEqual
 * @description Test if two char values are not equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {char} expected - Value that should not match
 * @param {char} actual - Actual value
 *
 * @returns {char} true if not equal (test passed), false otherwise
 */
define_function char NAVAssertCharNotEqual(char testName[], char expected, char actual) {
    if (expected != actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected different from: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                    : ', itoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertWideCharNotEqual
 * @description Test if two widechar values are not equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {widechar} expected - Value that should not match
 * @param {widechar} actual - Actual value
 *
 * @returns {char} true if not equal (test passed), false otherwise
 */
define_function char NAVAssertWideCharNotEqual(char testName[], widechar expected, widechar actual) {
    if (expected != actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected different from: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                    : ', itoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertSignedIntegerNotEqual
 * @description Test if two signed integer values are not equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {sinteger} expected - Value that should not match
 * @param {sinteger} actual - Actual value
 *
 * @returns {char} true if not equal (test passed), false otherwise
 */
define_function char NAVAssertSignedIntegerNotEqual(char testName[], sinteger expected, sinteger actual) {
    if (expected != actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected different from: ', itoa(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                    : ', itoa(actual)")
        return false
    }
}

/**
 * @function NAVAssertInt64NotEqual
 * @description Test if two Int64 values are not equal and log the result
 *
 * @param {char[]} testName - Name of the test
 * @param {_NAVInt64} expected - Value that should not match
 * @param {_NAVInt64} actual - Actual value
 *
 * @returns {char} true if not equal (test passed), false otherwise
 */
define_function char NAVAssertInt64NotEqual(char testName[], _NAVInt64 expected, _NAVInt64 actual) {
    if (expected.Hi != actual.Hi || expected.Lo != actual.Lo) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected different from $', format('%08x', expected.Hi), format('%08x', expected.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got                    $', format('%08x', actual.Hi), format('%08x', actual.Lo)")
        return false
    }
}

/**
 * @function NAVAssertStringContains
 * @description Test if a string contains a substring
 *
 * @param {char[]} testName - Name of the test
 * @param {char[]} searchString - String to find
 * @param {char[]} stringToSearch - String to search in
 *
 * @returns {char} true if stringToSearch contains searchString, false otherwise
 */
define_function char NAVAssertStringContains(char testName[], char searchString[], char stringToSearch[]) {
    if (find_string(stringToSearch, searchString, 1) > 0) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected to find: "', searchString, '"'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'In string       : "', stringToSearch, '"'")
        return false
    }
}

/**
 * @function NAVAssertStringStartsWith
 * @description Test if a string starts with the specified prefix
 *
 * @param {char[]} testName - Name of the test
 * @param {char[]} prefix - Expected prefix
 * @param {char[]} str - String to test
 *
 * @returns {char} true if str starts with prefix, false otherwise
 */
define_function char NAVAssertStringStartsWith(char testName[], char prefix[], char str[]) {
    if (length_array(prefix) <= length_array(str) &&
        left_string(str, length_array(prefix)) == prefix) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected to start with: "', prefix, '"'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got string           : "', str, '"'")
        return false
    }
}

/**
 * @function NAVAssertStringEndsWith
 * @description Test if a string ends with the specified suffix
 *
 * @param {char[]} testName - Name of the test
 * @param {char[]} suffix - Expected suffix
 * @param {char[]} str - String to test
 *
 * @returns {char} true if str ends with suffix, false otherwise
 */
define_function char NAVAssertStringEndsWith(char testName[], char suffix[], char str[]) {
    if (length_array(suffix) <= length_array(str) &&
        right_string(str, length_array(suffix)) == suffix) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected to end with: "', suffix, '"'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got string         : "', str, '"'")
        return false
    }
}

/**
 * @function NAVAssertFloatAlmostEqual
 * @description Test if two float values are almost equal within a given epsilon
 *
 * @param {char[]} testName - Name of the test
 * @param {float} expected - Expected value
 * @param {float} actual - Actual value
 * @param {float} epsilon - Maximum allowed difference
 *
 * @returns {char} true if |expected-actual| <= epsilon, false otherwise
 */
define_function char NAVAssertFloatAlmostEqual(char testName[], float expected, float actual, float epsilon) {
    stack_var float diff

    // Calculate absolute difference
    diff = expected - actual
    if (diff < 0) {
        diff = -diff
    }

    if (diff <= epsilon) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', ftoa(expected), ' ±', ftoa(epsilon)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', ftoa(actual), ' (diff: ', ftoa(diff), ')'")
        return false
    }
}

#END_IF // __NAV_FOUNDATION_ASSERT__
