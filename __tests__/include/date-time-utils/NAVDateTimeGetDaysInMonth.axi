PROGRAM_NAME='NAVDateTimeGetDaysInMonth'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data for GetDaysInMonth function
// Structure: { month (1-12), year, expected days }

constant integer DAYS_IN_MONTH_TEST_MONTH[] = {
    1,      // January
    2,      // February (regular year)
    2,      // February (leap year)
    2,      // February (century leap year - 2000)
    2,      // February (non-leap century - 1900)
    2,      // February (non-leap century - 2100)
    3,      // March
    4,      // April
    5,      // May
    6,      // June
    7,      // July
    8,      // August
    9,      // September
    10,     // October
    11,     // November
    12,     // December
    2,      // February (another leap year)
    2,      // February (another regular year)
    1,      // January (different year)
    12      // December (different year)
}

constant integer DAYS_IN_MONTH_TEST_YEAR[] = {
    2023,   // Regular year
    2023,   // Regular year (Feb)
    2024,   // Leap year (Feb)
    2000,   // Century leap year (Feb)
    1900,   // Non-leap century (Feb)
    2100,   // Non-leap century (Feb)
    2023,   // Regular year
    2023,   // Regular year
    2023,   // Regular year
    2023,   // Regular year
    2023,   // Regular year
    2023,   // Regular year
    2023,   // Regular year
    2023,   // Regular year
    2023,   // Regular year
    2023,   // Regular year
    2020,   // Leap year (Feb)
    2019,   // Regular year (Feb)
    2024,   // Leap year
    2024    // Leap year
}

constant integer DAYS_IN_MONTH_EXPECTED[] = {
    31,     // January
    28,     // February (regular year)
    29,     // February (leap year)
    29,     // February (century leap year)
    28,     // February (non-leap century)
    28,     // February (non-leap century)
    31,     // March
    30,     // April
    31,     // May
    30,     // June
    31,     // July
    31,     // August
    30,     // September
    31,     // October
    30,     // November
    31,     // December
    29,     // February (leap year)
    28,     // February (regular year)
    31,     // January
    31      // December
}

define_function TestNAVDateTimeGetDaysInMonth() {
    stack_var integer x

    NAVLog("'***************** NAVDateTimeGetDaysInMonth *****************'")

    for (x = 1; x <= length_array(DAYS_IN_MONTH_TEST_MONTH); x++) {
        stack_var integer expected
        stack_var integer result
        stack_var integer month
        stack_var integer year

        month = DAYS_IN_MONTH_TEST_MONTH[x]
        year = DAYS_IN_MONTH_TEST_YEAR[x]
        expected = DAYS_IN_MONTH_EXPECTED[x]
        result = NAVDateTimeGetDaysInMonth(month, year)

        if (!NAVAssertIntegerEqual('Should return correct days in month', expected, result)) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVDateTimeGetDaysInMonthInvalidInput() {
    stack_var integer result

    NAVLog("'***************** NAVDateTimeGetDaysInMonth - Invalid Input *****************'")

    // Test 1: Invalid month - too low (0)
    result = NAVDateTimeGetDaysInMonth(0, 2023)
    if (!NAVAssertIntegerEqual('Should return 0 for month = 0', 0, result)) {
        NAVLogTestFailed(1, '0', itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Invalid month - too high (13)
    result = NAVDateTimeGetDaysInMonth(13, 2023)
    if (!NAVAssertIntegerEqual('Should return 0 for month = 13', 0, result)) {
        NAVLogTestFailed(2, '0', itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Invalid year - zero
    result = NAVDateTimeGetDaysInMonth(1, 0)
    if (!NAVAssertIntegerEqual('Should return 0 for year = 0', 0, result)) {
        NAVLogTestFailed(3, '0', itoa(result))
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test 4: Both invalid
    result = NAVDateTimeGetDaysInMonth(15, 0)
    if (!NAVAssertIntegerEqual('Should return 0 for both invalid', 0, result)) {
        NAVLogTestFailed(4, '0', itoa(result))
    }
    else {
        NAVLogTestPassed(4)
    }
}

define_function TestNAVDateTimeGetDaysInMonthLeapYearEdgeCases() {
    stack_var integer result

    NAVLog("'***************** NAVDateTimeGetDaysInMonth - Leap Year Edge Cases *****************'")

    // Test 1: Year 2000 (divisible by 400 - IS a leap year)
    result = NAVDateTimeGetDaysInMonth(2, 2000)
    if (!NAVAssertIntegerEqual('Feb 2000 should have 29 days', 29, result)) {
        NAVLogTestFailed(1, '29', itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Year 1900 (divisible by 100, not by 400 - NOT a leap year)
    result = NAVDateTimeGetDaysInMonth(2, 1900)
    if (!NAVAssertIntegerEqual('Feb 1900 should have 28 days', 28, result)) {
        NAVLogTestFailed(2, '28', itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Year 2100 (divisible by 100, not by 400 - NOT a leap year)
    result = NAVDateTimeGetDaysInMonth(2, 2100)
    if (!NAVAssertIntegerEqual('Feb 2100 should have 28 days', 28, result)) {
        NAVLogTestFailed(3, '28', itoa(result))
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test 4: Year 2400 (divisible by 400 - IS a leap year)
    result = NAVDateTimeGetDaysInMonth(2, 2400)
    if (!NAVAssertIntegerEqual('Feb 2400 should have 29 days', 29, result)) {
        NAVLogTestFailed(4, '29', itoa(result))
    }
    else {
        NAVLogTestPassed(4)
    }

    // Test 5: Year 2004 (divisible by 4, not by 100 - IS a leap year)
    result = NAVDateTimeGetDaysInMonth(2, 2004)
    if (!NAVAssertIntegerEqual('Feb 2004 should have 29 days', 29, result)) {
        NAVLogTestFailed(5, '29', itoa(result))
    }
    else {
        NAVLogTestPassed(5)
    }

    // Test 6: Year 2003 (not divisible by 4 - NOT a leap year)
    result = NAVDateTimeGetDaysInMonth(2, 2003)
    if (!NAVAssertIntegerEqual('Feb 2003 should have 28 days', 28, result)) {
        NAVLogTestFailed(6, '28', itoa(result))
    }
    else {
        NAVLogTestPassed(6)
    }

    // Test 7: Non-February month in leap year (should be same as regular year)
    result = NAVDateTimeGetDaysInMonth(4, 2024)
    if (!NAVAssertIntegerEqual('April 2024 should have 30 days', 30, result)) {
        NAVLogTestFailed(7, '30', itoa(result))
    }
    else {
        NAVLogTestPassed(7)
    }
}
