PROGRAM_NAME='NAVDateTimeIsLeapYear'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant integer LEAP_YEAR_TEST[] = {
    1900,   // divisible by 100, not by 400 - NOT a leap year
    1996,   // divisible by 4, not by 100 - leap year
    2000,   // divisible by 400 - leap year
    2001,   // not divisible by 4 - NOT a leap year
    2004,   // divisible by 4, not by 100 - leap year
    2008,   // divisible by 4, not by 100 - leap year
    2012,   // divisible by 4, not by 100 - leap year
    2016,   // divisible by 4, not by 100 - leap year
    2020,   // divisible by 4, not by 100 - leap year
    2024,   // divisible by 4, not by 100 - leap year
    2100,   // divisible by 100, not by 400 - NOT a leap year
    2200,   // divisible by 100, not by 400 - NOT a leap year
    2300,   // divisible by 100, not by 400 - NOT a leap year
    2400,   // divisible by 400 - leap year
    1999,   // not divisible by 4 - NOT a leap year
    2003,   // not divisible by 4 - NOT a leap year
    2019,   // not divisible by 4 - NOT a leap year
    2023,   // not divisible by 4 - NOT a leap year
    1600,   // divisible by 400 - leap year
    1700,   // divisible by 100, not by 400 - NOT a leap year
    1800    // divisible by 100, not by 400 - NOT a leap year
}

constant char LEAP_YEAR_EXPECTED[] = {
    false,  // 1900
    true,   // 1996
    true,   // 2000
    false,  // 2001
    true,   // 2004
    true,   // 2008
    true,   // 2012
    true,   // 2016
    true,   // 2020
    true,   // 2024
    false,  // 2100
    false,  // 2200
    false,  // 2300
    true,   // 2400
    false,  // 1999
    false,  // 2003
    false,  // 2019
    false,  // 2023
    true,   // 1600
    false,  // 1700
    false   // 1800
}

define_function TestNAVDateTimeIsLeapYear() {
    stack_var integer x

    NAVLog("'***************** NAVDateTimeIsLeapYear *****************'")

    for (x = 1; x <= length_array(LEAP_YEAR_TEST); x++) {
        stack_var char expected
        stack_var char result
        stack_var integer year

        year = LEAP_YEAR_TEST[x]
        expected = LEAP_YEAR_EXPECTED[x]
        result = NAVDateTimeIsLeapYear(year)

        if (!NAVAssertBooleanEqual('Should determine leap year correctly', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
