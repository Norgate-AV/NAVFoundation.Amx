PROGRAM_NAME='NAVDateTimeGetLastSundayInMonth'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test data for GetLastSundayInMonth function
// Format: Year, Month (1-12), Expected Day

constant integer LAST_SUNDAY_TEST_YEAR[] = {
    // 2024 - Leap year
    2024,   // 1. January 2024 (31 days, starts on Monday)
    2024,   // 2. February 2024 (29 days, leap year)
    2024,   // 3. March 2024 (31 days) - DST starts
    2024,   // 4. April 2024 (30 days)
    2024,   // 5. May 2024 (31 days)
    2024,   // 6. June 2024 (30 days)
    2024,   // 7. July 2024 (31 days)
    2024,   // 8. August 2024 (31 days)
    2024,   // 9. September 2024 (30 days)
    2024,   // 10. October 2024 (31 days) - DST ends
    2024,   // 11. November 2024 (30 days)
    2024,   // 12. December 2024 (31 days)
    // 2023 - Regular year
    2023,   // 13. January 2023
    2023,   // 14. February 2023 (28 days, regular year)
    2023,   // 15. March 2023 - DST starts
    2023,   // 16. October 2023 - DST ends
    2023,   // 17. December 2023
    // 2025 - Regular year
    2025,   // 18. March 2025 - DST starts
    2025,   // 19. October 2025 - DST ends
    // Edge cases
    2020,   // 20. February 2020 (29 days, leap year)
    2021,   // 21. February 2021 (28 days, regular year)
    2000,   // 22. February 2000 (29 days, divisible by 400)
    2100,   // 23. February 2100 (28 days, divisible by 100 but not 400)
    // Months ending on different days
    2024,   // 24. Month ending on Sunday (if Jan 2024 ends on Wed, last Sun is 28th)
    2022,   // 25. January 2022 (month ending on Monday)
    2021,   // 26. March 2021 (31 days)
    2020,   // 27. March 2020 (31 days) - DST 2020
    2020,   // 28. October 2020 - DST 2020
    2019,   // 29. March 2019 - DST 2019
    2019    // 30. October 2019 - DST 2019
}

constant integer LAST_SUNDAY_TEST_MONTH[] = {
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,    // 2024 all months
    1, 2, 3, 10, 12,                           // 2023 selected months
    3, 10,                                     // 2025 DST months
    2, 2, 2, 2,                               // Leap year edge cases
    1, 1, 3, 3, 10, 3, 10                     // Various months
}

constant integer LAST_SUNDAY_EXPECTED[] = {
    28,     // 1. Jan 2024 - last Sunday is 28th
    25,     // 2. Feb 2024 - last Sunday is 25th (leap year)
    31,     // 3. Mar 2024 - last Sunday is 31st (DST transition)
    28,     // 4. Apr 2024 - last Sunday is 28th
    26,     // 5. May 2024 - last Sunday is 26th
    30,     // 6. Jun 2024 - last Sunday is 30th
    28,     // 7. Jul 2024 - last Sunday is 28th
    25,     // 8. Aug 2024 - last Sunday is 25th
    29,     // 9. Sep 2024 - last Sunday is 29th
    27,     // 10. Oct 2024 - last Sunday is 27th (DST transition)
    24,     // 11. Nov 2024 - last Sunday is 24th
    29,     // 12. Dec 2024 - last Sunday is 29th
    29,     // 13. Jan 2023 - last Sunday is 29th
    26,     // 14. Feb 2023 - last Sunday is 26th (regular year)
    26,     // 15. Mar 2023 - last Sunday is 26th (DST transition)
    29,     // 16. Oct 2023 - last Sunday is 29th (DST transition)
    31,     // 17. Dec 2023 - last Sunday is 31st
    30,     // 18. Mar 2025 - last Sunday is 30th (DST transition)
    26,     // 19. Oct 2025 - last Sunday is 26th (DST transition)
    23,     // 20. Feb 2020 - last Sunday is 23rd (leap year)
    28,     // 21. Feb 2021 - last Sunday is 28th (regular year)
    27,     // 22. Feb 2000 - last Sunday is 27th (leap year, div by 400)
    28,     // 23. Feb 2100 - last Sunday is 28th (NOT leap year)
    28,     // 24. Jan 2024 - last Sunday is 28th
    30,     // 25. Jan 2022 - last Sunday is 30th
    28,     // 26. Mar 2021 - last Sunday is 28th
    29,     // 27. Mar 2020 - last Sunday is 29th (DST)
    25,     // 28. Oct 2020 - last Sunday is 25th (DST)
    31,     // 29. Mar 2019 - last Sunday is 31st (DST)
    27      // 30. Oct 2019 - last Sunday is 27th (DST)
}

// DST Validation test data
constant integer DST_START_YEARS[] = {2020, 2021, 2022, 2023, 2024, 2025}
constant integer DST_START_DAYS[] = {29, 28, 27, 26, 31, 30}
constant integer DST_END_YEARS[] = {2020, 2021, 2022, 2023, 2024, 2025}
constant integer DST_END_DAYS[] = {25, 31, 30, 29, 27, 26}

define_function TestNAVDateTimeGetLastSundayInMonth() {
    stack_var integer x
    stack_var integer year
    stack_var integer month
    stack_var integer expected
    stack_var integer result

    NAVLog("'***************** NAVDateTimeGetLastSundayInMonth *****************'")

    for (x = 1; x <= length_array(LAST_SUNDAY_EXPECTED); x++) {
        year = LAST_SUNDAY_TEST_YEAR[x]
        month = LAST_SUNDAY_TEST_MONTH[x]
        expected = LAST_SUNDAY_EXPECTED[x]

        NAVStopwatchStart()
        result = NAVDateTimeGetLastSundayInMonth(year, month)

        if (!NAVAssertIntegerEqual('Should find last Sunday correctly', expected, result)) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            NAVLog("'  Year: ', itoa(year), ', Month: ', itoa(month)")
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }

    NAVStopwatchStop()
}

define_function TestNAVDateTimeGetLastSundayInMonthEdgeCases() {
    stack_var integer result

    NAVLog("'***************** NAVDateTimeGetLastSundayInMonth - Edge Cases *****************'")

    // Test 1: Month where last day IS a Sunday (verify it returns that day)
    // March 2024 - 31st is a Sunday
    result = NAVDateTimeGetLastSundayInMonth(2024, 3)
    if (!NAVAssertIntegerEqual('Should handle month ending on Sunday', 31, result)) {
        NAVLogTestFailed(1, '31', itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Month where last day is Saturday (last Sunday is 7 days before)
    // June 2024 - 30th is a Sunday, but let's test a month ending on Saturday
    // February 2025 - 28th is a Friday, so last Sunday is 23rd
    result = NAVDateTimeGetLastSundayInMonth(2025, 2)
    if (!NAVAssertIntegerEqual('Should handle month ending on non-Sunday', 23, result)) {
        NAVLogTestFailed(2, '23', itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: February in leap year with specific Sunday pattern
    result = NAVDateTimeGetLastSundayInMonth(2024, 2)
    if (!NAVAssertIntegerEqual('Should handle leap year February', 25, result)) {
        NAVLogTestFailed(3, '25', itoa(result))
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test 4: February in non-leap year
    result = NAVDateTimeGetLastSundayInMonth(2023, 2)
    if (!NAVAssertIntegerEqual('Should handle regular year February', 26, result)) {
        NAVLogTestFailed(4, '26', itoa(result))
    }
    else {
        NAVLogTestPassed(4)
    }

    // Test 5: Verify DST start for UK 2024 (should be March 31)
    result = NAVDateTimeGetLastSundayInMonth(2024, 3)
    if (!NAVAssertIntegerEqual('Should match UK DST start 2024', 31, result)) {
        NAVLogTestFailed(5, '31', itoa(result))
    }
    else {
        NAVLogTestPassed(5)
    }

    // Test 6: Verify DST end for UK 2024 (should be October 27)
    result = NAVDateTimeGetLastSundayInMonth(2024, 10)
    if (!NAVAssertIntegerEqual('Should match UK DST end 2024', 27, result)) {
        NAVLogTestFailed(6, '27', itoa(result))
    }
    else {
        NAVLogTestPassed(6)
    }

    // Test 7: Century year divisible by 400 (leap year)
    result = NAVDateTimeGetLastSundayInMonth(2000, 2)
    if (!NAVAssertIntegerEqual('Should handle year 2000 February', 27, result)) {
        NAVLogTestFailed(7, '27', itoa(result))
    }
    else {
        NAVLogTestPassed(7)
    }

    // Test 8: Century year NOT divisible by 400 (not leap year)
    result = NAVDateTimeGetLastSundayInMonth(2100, 2)
    if (!NAVAssertIntegerEqual('Should handle year 2100 February', 28, result)) {
        NAVLogTestFailed(8, '28', itoa(result))
    }
    else {
        NAVLogTestPassed(8)
    }

    // Test 9: December with various patterns (31 days)
    result = NAVDateTimeGetLastSundayInMonth(2023, 12)
    if (!NAVAssertIntegerEqual('Should handle December 2023', 31, result)) {
        NAVLogTestFailed(9, '31', itoa(result))
    }
    else {
        NAVLogTestPassed(9)
    }

    // Test 10: 30-day month (September)
    result = NAVDateTimeGetLastSundayInMonth(2024, 9)
    if (!NAVAssertIntegerEqual('Should handle 30-day month', 29, result)) {
        NAVLogTestFailed(10, '29', itoa(result))
    }
    else {
        NAVLogTestPassed(10)
    }
}

define_function TestNAVDateTimeGetLastSundayInMonthDSTValidation() {
    stack_var integer result
    stack_var integer year
    stack_var integer x

    NAVLog("'***************** NAVDateTimeGetLastSundayInMonth - DST Validation *****************'")

    // Verify DST transitions for multiple years (UK rules)
    // March transitions (DST starts)
    for (x = 1; x <= length_array(DST_START_YEARS); x++) {
        year = DST_START_YEARS[x]
        result = NAVDateTimeGetLastSundayInMonth(year, 3)

        if (!NAVAssertIntegerEqual('Should match known DST start date', DST_START_DAYS[x], result)) {
            NAVLogTestFailed(x, itoa(DST_START_DAYS[x]), itoa(result))
            NAVLog("'  Year: ', itoa(year), ' March'")
            continue
        }

        NAVLogTestPassed(x)
    }

    // October transitions (DST ends)
    for (x = 1; x <= length_array(DST_END_YEARS); x++) {
        year = DST_END_YEARS[x]
        result = NAVDateTimeGetLastSundayInMonth(year, 10)

        if (!NAVAssertIntegerEqual('Should match known DST end date', DST_END_DAYS[x], result)) {
            NAVLogTestFailed(x + length_array(DST_START_YEARS), itoa(DST_END_DAYS[x]), itoa(result))
            NAVLog("'  Year: ', itoa(year), ' October'")
            continue
        }

        NAVLogTestPassed(x + length_array(DST_START_YEARS))
    }
}
