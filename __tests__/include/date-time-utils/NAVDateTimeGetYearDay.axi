PROGRAM_NAME='NAVDateTimeGetYearDay'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data for GetYearDay function
// Test case structure: { year (since 1900), month (0-11), day, expected yearday (1-366) }

constant integer YEARDAY_TEST_YEAR[] = {
    120,    // 2020 (leap year)
    120,    // 2020 (leap year)
    120,    // 2020 (leap year)
    120,    // 2020 (leap year)
    120,    // 2020 (leap year)
    120,    // 2020 (leap year)
    123,    // 2023 (regular year)
    123,    // 2023 (regular year)
    123,    // 2023 (regular year)
    123,    // 2023 (regular year)
    123,    // 2023 (regular year)
    123,    // 2023 (regular year)
    100,    // 2000 (leap year - century leap year)
    100,    // 2000 (leap year - century leap year)
    124     // 2024 (leap year)
}

constant integer YEARDAY_TEST_MONTH[] = {
    0,      // January
    1,      // February
    1,      // February (leap day)
    2,      // March (after leap day)
    11,     // December
    5,      // June
    0,      // January
    1,      // February
    2,      // March
    6,      // July
    11,     // December
    10,     // November
    1,      // February (leap year)
    2,      // March (after leap day)
    11      // December (leap year)
}

constant integer YEARDAY_TEST_DAY[] = {
    1,      // Jan 1
    1,      // Feb 1
    29,     // Feb 29 (leap day)
    1,      // Mar 1
    31,     // Dec 31
    15,     // Jun 15
    1,      // Jan 1
    1,      // Feb 1
    1,      // Mar 1
    4,      // Jul 4
    31,     // Dec 31
    15,     // Nov 15
    29,     // Feb 29 (leap year)
    1,      // Mar 1 (after leap day)
    31      // Dec 31 (leap year)
}

constant integer YEARDAY_EXPECTED[] = {
    1,      // Jan 1 = 1
    32,     // Feb 1 = 31 + 1 = 32
    60,     // Feb 29 = 31 + 29 = 60 (leap year)
    61,     // Mar 1 = 31 + 29 + 1 = 61 (leap year)
    366,    // Dec 31 = 366 (leap year)
    167,    // Jun 15 = 31+29+31+30+31+15 = 167 (leap year)
    1,      // Jan 1 = 1
    32,     // Feb 1 = 31 + 1 = 32
    60,     // Mar 1 = 31 + 28 + 1 = 60 (regular year)
    185,    // Jul 4 = 31+28+31+30+31+30+4 = 185 (regular year)
    365,    // Dec 31 = 365 (regular year)
    319,    // Nov 15 = 31+28+31+30+31+30+31+31+30+31+15 = 319
    60,     // Feb 29 = 31 + 29 = 60 (leap year)
    61,     // Mar 1 = 31 + 29 + 1 = 61 (leap year)
    366     // Dec 31 = 366 (leap year)
}

define_function TestNAVDateTimeGetYearDay() {
    stack_var integer x

    NAVLog("'***************** NAVDateTimeGetYearDay *****************'")

    for (x = 1; x <= length_array(YEARDAY_TEST_YEAR); x++) {
        stack_var _NAVTimespec timespec
        stack_var integer expected
        stack_var integer result

        // Populate timespec with test data
        timespec.Year = YEARDAY_TEST_YEAR[x]
        timespec.Month = YEARDAY_TEST_MONTH[x]
        timespec.MonthDay = YEARDAY_TEST_DAY[x]

        expected = YEARDAY_EXPECTED[x]
        result = NAVDateTimeGetYearDay(timespec)

        if (!NAVAssertIntegerEqual('Should calculate year day correctly', expected, result)) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
