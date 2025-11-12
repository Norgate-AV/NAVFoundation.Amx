PROGRAM_NAME='NAVDateTimeTimespecPast'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test data for TimespecPast function
// Use dates relative to a known reference point (Jan 1, 2024)
// Format: Year, Month, Day, Hour, Min, Sec, Expected (relative to "now")

constant integer PAST_TEST_YEAR[] = {
    123,    // 1. One year ago - clearly past
    124,    // 2. One month ago - clearly past
    124,    // 3. One week ago - clearly past
    124,    // 4. Yesterday - clearly past
    124,    // 5. One hour ago - clearly past
    124,    // 6. One minute ago - clearly past
    126,    // 7. One year in future (2026) - clearly NOT past
    125,    // 8. Future month (Dec 2025) - clearly NOT past
    125,    // 9. Future week (Dec 2025) - clearly NOT past
    125,    // 10. Tomorrow (Dec 2025) - clearly NOT past
    125,    // 11. Future hour (Nov 2025) - clearly NOT past
    125,    // 12. Future minute (Nov 2025) - clearly NOT past
    120,    // 13. Multiple years ago (2020)
    130,    // 14. Multiple years in future (2030)
    70,     // 15. Epoch start (Jan 1, 1970) - definitely past
    124,    // 16. Start of 2024 - should be past if we're later in year
    126,    // 17. Start of 2026 - future
    123,    // 18. End of 2023 - past
    124,    // 19. Leap day 2024 - context dependent
    100,    // 20. Y2K (2000) - definitely past
    124,    // 21. DST transition (Mar 31, 2024) - context dependent
    124,    // 22. DST transition (Oct 27, 2024) - context dependent
    123,    // 23. One second ago (relative) - past
    124,    // 24. One second ahead (relative) - future
    124     // 25. Same second (edge case) - technically not past
}

constant integer PAST_TEST_MONTH[] = {
    0, 11, 11, 11, 11, 11,     // Past tests
    0, 11, 11, 11, 10, 10,     // Future tests (2026, Dec 2025, Dec 2025, Dec 2025, Nov 2025, Nov 2025)
    0, 0, 0, 0, 0, 11,         // Boundary tests
    1, 0, 2, 9,                // Special dates
    11, 11, 11                 // Same-time edge cases
}

constant integer PAST_TEST_DAY[] = {
    1, 1, 25, 31, 31, 31,      // Past tests
    1, 1, 20, 20, 13, 12,      // Future tests (Jan 2026, Dec 1 2025, Dec 20 2025, Dec 20 2025, Nov 13 2025, Nov 12 2025)
    1, 1, 1, 1, 1, 31,         // Boundary tests
    29, 1, 31, 27,             // Special dates
    31, 31, 31                 // Same-time edge cases
}

constant integer PAST_TEST_HOUR[] = {
    0, 0, 0, 0, 11, 11,        // Past tests (relative)
    0, 0, 0, 0, 23, 23,        // Future tests (future dates, any hour is fine)
    0, 0, 0, 0, 0, 23,         // Boundary tests
    0, 0, 12, 12,              // Special dates
    11, 12, 12                 // Same-time edge cases
}

constant integer PAST_TEST_MIN[] = {
    0, 0, 0, 0, 0, 59,         // Past tests
    0, 0, 0, 0, 0, 30,         // Future tests
    0, 0, 0, 0, 0, 59,         // Boundary tests
    0, 0, 0, 0,                // Special dates
    59, 0, 0                   // Same-time edge cases
}

constant integer PAST_TEST_SEC[] = {
    0, 0, 0, 0, 0, 0,          // Past tests
    0, 0, 0, 0, 0, 0,          // Future tests
    0, 0, 0, 0, 0, 59,         // Boundary tests
    0, 0, 0, 0,                // Special dates
    58, 1, 0                   // Same-time edge cases
}

// Note: These expectations assume tests run on a date around Jan 1, 2024, 12:00:00
// Some tests are marked as 'context-dependent' and may need adjustment
constant char PAST_TEST_EXPECTED[] = {
    true,   // 1. 2023 - past
    true,   // 2. Dec 1, 2023 - past
    true,   // 3. Dec 25, 2023 - past
    true,   // 4. Dec 31, 2023 - past
    true,   // 5. Dec 31, 2023 11:00 - past
    true,   // 6. Dec 31, 2023 11:59 - past
    false,  // 7. Jan 1, 2026 - future
    false,  // 8. Dec 1, 2025 - future
    false,  // 9. Dec 20, 2025 - future
    false,  // 10. Dec 20, 2025 - future
    false,  // 11. Nov 13, 2025 23:00 - future
    false,  // 12. Nov 12, 2025 23:30 - future
    true,   // 13. 2020 - definitely past
    false,  // 14. 2030 - definitely future
    true,   // 15. 1970 - definitely past
    true,   // 16. Start of 2024 - past (if we're later)
    false,  // 17. Start of 2026 - future
    true,   // 18. End of 2023 - past
    true,   // 19. Feb 29, 2024 - context dependent (likely past)
    true,   // 20. Y2K - definitely past
    true,   // 21. Mar 31, 2024 - context dependent
    true,   // 22. Oct 27, 2024 - context dependent
    true,   // 23. One second ago - past
    false,  // 24. One second ahead - future
    false   // 25. Same second - not past (equal time)
}

define_function TestNAVDateTimeTimespecPast() {
    stack_var integer x
    stack_var _NAVTimespec now
    stack_var char isNowValid
    stack_var _NAVTimespec testTime
    stack_var char expected
    stack_var char result
    stack_var long testEpoch
    stack_var long nowEpoch

    NAVLog("'***************** NAVDateTimeTimespecPast *****************'")

    // Get current time for reference
    isNowValid = NAVDateTimeGetTimespecNow(now)

    if (!isNowValid) {
        NAVLog("'ERROR: Failed to get current time for reference'")
        return
    }

    // Log reference time
    NAVLog("'Reference time (now):'")
    NAVLog("'  Year: ', itoa(now.Year + 1900)")
    NAVLog("'  Month: ', itoa(now.Month + 1)")
    NAVLog("'  Day: ', itoa(now.MonthDay)")
    NAVLog("'  Hour: ', itoa(now.Hour)")
    NAVLog("'  Minute: ', itoa(now.Minute)")
    NAVLog("'  Second: ', itoa(now.Seconds)")

    for (x = 1; x <= length_array(PAST_TEST_EXPECTED); x++) {
        // Build test timespec
        testTime.Year = PAST_TEST_YEAR[x]
        testTime.Month = PAST_TEST_MONTH[x]
        testTime.MonthDay = PAST_TEST_DAY[x]
        testTime.Hour = PAST_TEST_HOUR[x]
        testTime.Minute = PAST_TEST_MIN[x]
        testTime.Seconds = PAST_TEST_SEC[x]
        testTime.WeekDay = 1  // Dummy value
        testTime.YearDay = NAVDateTimeGetYearDay(testTime)

        // For context-dependent tests (19-25), calculate expected based on actual current time
        if (x >= 19 && x <= 25) {
            testEpoch = NAVDateTimeGetEpoch(testTime)
            nowEpoch = NAVDateTimeGetEpoch(now)

            expected = (testEpoch < nowEpoch)
        }
        else {
            expected = PAST_TEST_EXPECTED[x]
        }

        result = NAVDateTimeTimespecPast(testTime)

        if (!NAVAssertBooleanEqual('Should determine if time is in past', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            NAVLog("'  Test time: ', itoa(testTime.Year + 1900), '-', format('%02d', testTime.Month + 1), '-', format('%02d', testTime.MonthDay), ' ', format('%02d', testTime.Hour), ':', format('%02d', testTime.Minute), ':', format('%02d', testTime.Seconds)")
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVDateTimeTimespecPastEdgeCases() {
    stack_var _NAVTimespec now
    stack_var _NAVTimespec testTime
    stack_var char result
    stack_var long nowEpoch

    NAVLog("'***************** NAVDateTimeTimespecPast - Edge Cases *****************'")

    // Get current time
    NAVDateTimeGetTimespecNow(now)
    nowEpoch = NAVDateTimeGetEpoch(now)

    // Test 1: Exact same time as now (should be false - not in the past)
    testTime = now
    result = NAVDateTimeTimespecPast(testTime)
    if (!NAVAssertBooleanEqual('Should return false for current time', false, result)) {
        NAVLogTestFailed(1, 'false', NAVBooleanToString(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: 1 second in the past
    NAVDateTimeEpochToTimespec(nowEpoch - 1, testTime)
    result = NAVDateTimeTimespecPast(testTime)
    if (!NAVAssertBooleanEqual('Should return true for 1 second ago', true, result)) {
        NAVLogTestFailed(2, 'true', NAVBooleanToString(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: 1 second in the future
    NAVDateTimeEpochToTimespec(nowEpoch + 1, testTime)
    result = NAVDateTimeTimespecPast(testTime)
    if (!NAVAssertBooleanEqual('Should return false for 1 second ahead', false, result)) {
        NAVLogTestFailed(3, 'false', NAVBooleanToString(result))
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test 4: Far in the past (Jan 1, 1970 - Unix epoch)
    testTime.Year = 70
    testTime.Month = 0
    testTime.MonthDay = 1
    testTime.Hour = 0
    testTime.Minute = 0
    testTime.Seconds = 0
    testTime.YearDay = 1

    result = NAVDateTimeTimespecPast(testTime)
    if (!NAVAssertBooleanEqual('Should return true for Unix epoch', true, result)) {
        NAVLogTestFailed(4, 'true', NAVBooleanToString(result))
    }
    else {
        NAVLogTestPassed(4)
    }

    // Test 5: Far in the future (Jan 1, 2050)
    testTime.Year = 150
    testTime.Month = 0
    testTime.MonthDay = 1
    testTime.Hour = 0
    testTime.Minute = 0
    testTime.Seconds = 0
    testTime.YearDay = 1

    result = NAVDateTimeTimespecPast(testTime)
    if (!NAVAssertBooleanEqual('Should return false for year 2050', false, result)) {
        NAVLogTestFailed(5, 'false', NAVBooleanToString(result))
    }
    else {
        NAVLogTestPassed(5)
    }

    // Test 6: Leap second edge case (23:59:59)
    NAVDateTimeEpochToTimespec(nowEpoch - 86400, testTime)
    testTime.Hour = 23
    testTime.Minute = 59
    testTime.Seconds = 59

    result = NAVDateTimeTimespecPast(testTime)
    if (!NAVAssertBooleanEqual('Should handle end of day correctly', true, result)) {
        NAVLogTestFailed(6, 'true', NAVBooleanToString(result))
    }
    else {
        NAVLogTestPassed(6)
    }

    // Test 7: Start of day (00:00:00)
    NAVDateTimeEpochToTimespec(nowEpoch + 86400, testTime)
    testTime.Hour = 0
    testTime.Minute = 0
    testTime.Seconds = 0

    result = NAVDateTimeTimespecPast(testTime)
    if (!NAVAssertBooleanEqual('Should handle start of day correctly', false, result)) {
        NAVLogTestFailed(7, 'false', NAVBooleanToString(result))
    }
    else {
        NAVLogTestPassed(7)
    }
}
