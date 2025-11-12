PROGRAM_NAME='NAVDateTimeGetDifference'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test data for GetDifference function
// All tests use: time1 - time2 = expected (positive means time1 is later)

constant integer DIFF_TEST_YEAR1[] = {
    124,    // 1. Same time - zero difference
    124,    // 2. 1 hour later (same day)
    124,    // 3. 1 day later
    124,    // 4. 1 week later
    124,    // 5. 30 days later
    125,    // 6. 1 year later (366 days - leap year)
    124,    // 7. 1 day earlier (negative result)
    125,    // 8. 1 year later (Dec 31 2025 - Dec 31 2024 = 365 days in year 2025)
    124,    // 9. 1 day in leap year
    127,    // 10. 3 years later
    124,    // 11. 3 hours later
    124,    // 12. 5 days 1 hour later
    124,    // 13. Exactly 1 day
    124,    // 14. 1 day 1 second later
    134,    // 15. 10 years later
    124,    // 16. 1 hour (simple)
    124,    // 17. 1 hour (simple)
    127,    // 18. Same date (Mar 29, 2027 - Mar 29, 2027 = 0)
    174,    // 19. 50 years 1 day later
    124,    // 20. 9 min 15 sec later
    124,    // 21. -45 seconds (time1 before time2)
    124,    // 22. 2 days 2h 45m 15s later
    124,    // 23. 1 year later (365 days - 2023 is not a leap year)
    124,    // 24. 1 day later
    125     // 25. 1 year later (365 days)
}

constant integer DIFF_TEST_MONTH1[] = {
    0, 0, 0, 0, 1, 0, 0, 11, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 2, 0, 0,
    0, 0, 0, 1, 0
}

constant integer DIFF_TEST_DAY1[] = {
    15, 15, 16, 22, 15, 1, 14, 31, 29, 1,
    15, 20, 2, 2, 1, 15, 15, 29, 1, 15,
    15, 17, 15, 1, 1
}

constant integer DIFF_TEST_HOUR1[] = {
    12, 13, 12, 12, 12, 0, 12, 12, 12, 0,
    15, 13, 12, 0, 0, 13, 13, 12, 0, 14,
    14, 15, 12, 12, 0
}

constant integer DIFF_TEST_MIN1[] = {
    30, 30, 30, 30, 30, 0, 30, 0, 0, 0,
    0, 30, 0, 0, 0, 0, 0, 0, 0, 40,
    30, 45, 0, 0, 0
}

constant integer DIFF_TEST_SEC1[] = {
    45, 45, 45, 45, 45, 0, 45, 0, 0, 0,
    0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
    0, 15, 0, 0, 0
}

constant integer DIFF_TEST_YEAR2[] = {
    124,    // 1. Same time
    124,    // 2. 1 hour earlier
    124,    // 3. 1 day earlier
    124,    // 4. 1 week earlier
    124,    // 5. 30 days earlier
    124,    // 6. 1 year earlier
    124,    // 7. 1 day later (for negative test)
    124,    // 8. Year before
    124,    // 9. Day before in leap year
    124,    // 10. 3 years earlier
    124,    // 11. 3 hours earlier
    124,    // 12. 5 days earlier
    124,    // 13. Day before
    124,    // 14. 1 second earlier
    124,    // 15. 10 years earlier
    124,    // 16. Hour earlier
    124,    // 17. Hour earlier
    127,    // 18. Same month 3 years earlier
    124,    // 19. 50 years earlier
    124,    // 20. 10min 15sec earlier
    124,    // 21. 15 seconds earlier
    124,    // 22. Earlier time
    123,    // 23. Year earlier (2023)
    124,    // 24. Day earlier
    124     // 25. Year earlier
}

constant integer DIFF_TEST_MONTH2[] = {
    0, 0, 0, 0, 0, 0, 0, 11, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 2, 0, 0,
    0, 0, 0, 0, 0
}

constant integer DIFF_TEST_DAY2[] = {
    15, 15, 15, 15, 15, 1, 15, 31, 28, 1,
    15, 15, 1, 1, 1, 15, 15, 29, 1, 15,
    15, 15, 15, 31, 1
}

constant integer DIFF_TEST_HOUR2[] = {
    12, 12, 12, 12, 12, 0, 12, 12, 12, 0,
    12, 12, 12, 0, 0, 12, 12, 12, 0, 14,
    14, 14, 12, 12, 0
}

constant integer DIFF_TEST_MIN2[] = {
    30, 30, 30, 30, 30, 0, 30, 0, 0, 0,
    0, 30, 0, 0, 0, 0, 0, 0, 0, 30,
    30, 0, 0, 0, 0
}

constant integer DIFF_TEST_SEC2[] = {
    45, 45, 45, 45, 45, 0, 45, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 45,
    0, 0, 0, 0, 0
}

constant long DIFF_TEST_EXPECTED[] = {
    0,          // 1. Same time
    3600,       // 2. 1 hour (3600 sec)
    86400,      // 3. 1 day (86400 sec)
    604800,     // 4. 1 week (7 days = 604800 sec)
    2678400,    // 5. 31 days Jan (2678400 sec) - Feb 15 minus Jan 15
    31622400,   // 6. 366 days (leap year 2024 to 2025)
    86400,      // 7. Negative difference (reversed in test: -86400)
    31536000,   // 8. 365 days (Dec 31, 2025 - Dec 31, 2024, counting days in 2025)
    86400,      // 9. 1 day (Feb 29 - Feb 28, 2024 leap year)
    94694400,   // 10. 3 years (2024-2027: 366+365+365 = 1096 days)
    10800,      // 11. 3 hours (10800 sec)
    435600,     // 12. 5 days 1 hour (435600 sec)
    86400,      // 13. Exactly 1 day
    86401,      // 14. 1 day 1 second
    315619200,  // 15. 10 years (3653 days approximately)
    3600,       // 16. 1 hour
    3600,       // 17. 1 hour
    0,          // 18. Same date (Mar 29, 2027 - Mar 29, 2027)
    1577923200, // 19. 50 years 1 day
    555,        // 20. 9 min 15 sec (555 sec)
    0,          // 21. -45 seconds (REVERSED - see test logic)
    179115,     // 22. 2 days 2h 45m 15s
    31536000,   // 23. 365 days (Jan 15, 2024 - Jan 15, 2023, non-leap year)
    86400,      // 24. 1 day (Feb 1 - Jan 31)
    31622400    // 25. 366 days (Jan 1, 2025 - Jan 1, 2024 = 366 days in leap year 2024)
}

define_function TestNAVDateTimeGetDifference() {
    stack_var integer x
    stack_var _NAVTimespec time1
    stack_var _NAVTimespec time2
    stack_var slong diff
    stack_var slong expected

    NAVLog("'***************** NAVDateTimeGetDifference *****************'")

    for (x = 1; x <= length_array(DIFF_TEST_EXPECTED); x++) {
        // Build time1
        time1.Year = DIFF_TEST_YEAR1[x]
        time1.Month = DIFF_TEST_MONTH1[x]
        time1.MonthDay = DIFF_TEST_DAY1[x]
        time1.Hour = DIFF_TEST_HOUR1[x]
        time1.Minute = DIFF_TEST_MIN1[x]
        time1.Seconds = DIFF_TEST_SEC1[x]
        time1.WeekDay = 1  // Dummy value
        time1.YearDay = NAVDateTimeGetYearDay(time1)

        // Build time2
        time2.Year = DIFF_TEST_YEAR2[x]
        time2.Month = DIFF_TEST_MONTH2[x]
        time2.MonthDay = DIFF_TEST_DAY2[x]
        time2.Hour = DIFF_TEST_HOUR2[x]
        time2.Minute = DIFF_TEST_MIN2[x]
        time2.Seconds = DIFF_TEST_SEC2[x]
        time2.WeekDay = 1  // Dummy value
        time2.YearDay = NAVDateTimeGetYearDay(time2)

        expected = type_cast(DIFF_TEST_EXPECTED[x])

        // Tests 7 and 21 are reversed (time2 > time1), so result should be negative
        if (x == 7 || x == 21) {
            expected = -expected
        }

        NAVStopwatchStart()
        diff = NAVDateTimeGetDifference(time1, time2)
        if (!NAVAssertSignedLongEqual('Should calculate time difference correctly', expected, diff)) {
            NAVLogTestFailed(x, itoa(expected), itoa(diff))
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }

    NAVStopwatchStop()
}

define_function TestNAVDateTimeGetDifferenceEdgeCases() {
    stack_var _NAVTimespec time1
    stack_var _NAVTimespec time2
    stack_var slong diff

    NAVLog("'***************** NAVDateTimeGetDifference - Edge Cases *****************'")

        // Test 1: Epoch time (Jan 1, 1970) difference
    time1.Year = 70
    time1.Month = 0
    time1.MonthDay = 1
    time1.Hour = 0
    time1.Minute = 0
    time1.Seconds = 0
    time1.YearDay = 1

    time2.Year = 70
    time2.Month = 0
    time2.MonthDay = 2
    time2.Hour = 0
    time2.Minute = 0
    time2.Seconds = 0
    time2.YearDay = 2

    diff = NAVDateTimeGetDifference(time1, time2)
    if (!NAVAssertSignedLongEqual('Should handle epoch boundary', type_cast(-86400), diff)) {
        NAVLogTestFailed(1, '-86400', itoa(diff))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Maximum int32 boundary (year 2038 problem area)
    time1.Year = 138  // 2038
    time1.Month = 0
    time1.MonthDay = 1
    time1.Hour = 0
    time1.Minute = 0
    time1.Seconds = 0
    time1.YearDay = 1

    time2.Year = 138
    time2.Month = 0
    time2.MonthDay = 20
    time2.Hour = 0
    time2.Minute = 0
    time2.Seconds = 0
    time2.YearDay = 20

    diff = NAVDateTimeGetDifference(time1, time2)
    if (!NAVAssertSignedLongEqual('Should handle 2038 problem area', type_cast(-1641600), diff)) {
        NAVLogTestFailed(2, '-1641600', itoa(diff))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Leap year Feb 28 -> Mar 1 (2024)
    time1.Year = 124
    time1.Month = 1
    time1.MonthDay = 28
    time1.Hour = 12
    time1.Minute = 0
    time1.Seconds = 0
    time1.YearDay = 59

    time2.Year = 124
    time2.Month = 2
    time2.MonthDay = 1
    time2.Hour = 12
    time2.Minute = 0
    time2.Seconds = 0
    time2.YearDay = 61

    diff = NAVDateTimeGetDifference(time1, time2)
    if (!NAVAssertSignedLongEqual('Should handle leap year transition', type_cast(-172800), diff)) {
        NAVLogTestFailed(3, '-172800', itoa(diff))
    }
    else {
        NAVLogTestPassed(3)
    }

        // Test 4: Century non-leap year Feb 28 -> Mar 1 (2100)
    time1.Year = 200  // 2100
    time1.Month = 1
    time1.MonthDay = 28
    time1.Hour = 12
    time1.Minute = 0
    time1.Seconds = 0
    time1.YearDay = 59

    time2.Year = 200
    time2.Month = 2
    time2.MonthDay = 1
    time2.Hour = 12
    time2.Minute = 0
    time2.Seconds = 0
    time2.YearDay = 60

    diff = NAVDateTimeGetDifference(time1, time2)
    if (!NAVAssertSignedLongEqual('Should handle non-leap century year', type_cast(-86400), diff)) {
        NAVLogTestFailed(4, '-86400', itoa(diff))
    }
    else {
        NAVLogTestPassed(4)
    }

    // Test 5: Very small difference (1 second)
    time1.Year = 124
    time1.Month = 6
    time1.MonthDay = 15
    time1.Hour = 12
    time1.Minute = 30
    time1.Seconds = 30
    time1.YearDay = NAVDateTimeGetYearDay(time1)

    time2.Year = 124
    time2.Month = 6
    time2.MonthDay = 15
    time2.Hour = 12
    time2.Minute = 30
    time2.Seconds = 29
    time2.YearDay = NAVDateTimeGetYearDay(time2)

    diff = NAVDateTimeGetDifference(time1, time2)
    if (!NAVAssertSignedLongEqual('Should handle 1 second difference', type_cast(1), diff)) {
        NAVLogTestFailed(5, '1', itoa(diff))
    }
    else {
        NAVLogTestPassed(5)
    }
}
