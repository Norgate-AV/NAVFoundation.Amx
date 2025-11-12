PROGRAM_NAME='NAVDateTimeIsDst'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data: Year (since 1900), Month (0-based), Day, WeekDay (1=Sun, 7=Sat), Expected DST result
// UK DST rules: Last Sunday in March (starts) to Last Sunday in October (ends)

// 2024 DST transitions:
// - Starts: March 31, 2024 (last Sunday in March)
// - Ends: October 27, 2024 (last Sunday in October)

constant integer DST_TEST_YEAR[] = {
    // Winter months - clearly NOT in DST
    124,    // 1. Jan 15, 2024 - NOT DST
    124,    // 2. Feb 20, 2024 - NOT DST
    124,    // 3. Nov 10, 2024 - NOT DST (after Oct 27)
    124,    // 4. Dec 25, 2024 - NOT DST
    // Summer months - clearly IN DST
    124,    // 5. Apr 15, 2024 - IN DST
    124,    // 6. May 20, 2024 - IN DST
    124,    // 7. Jun 21, 2024 - IN DST
    124,    // 8. Jul 4, 2024 - IN DST
    124,    // 9. Aug 10, 2024 - IN DST
    124,    // 10. Sep 15, 2024 - IN DST
    // March 2024 - transition testing
    124,    // 11. Mar 29, 2024 (Friday) - NOT DST (before transition)
    124,    // 12. Mar 30, 2024 (Saturday) - NOT DST (before transition)
    124,    // 13. Mar 31, 2024 (Sunday) - IN DST (transition day - last Sunday)
    124,    // 14. Mar 1, 2024 (Friday) - NOT DST
    124,    // 15. Mar 15, 2024 (Friday) - NOT DST
    // October 2024 - transition testing (CRITICAL BUG TEST)
    124,    // 16. Oct 26, 2024 (Saturday) - IN DST (before transition)
    124,    // 17. Oct 27, 2024 (Sunday) - NOT DST (transition day - DST ends) *** BUG HERE ***
    124,    // 18. Oct 28, 2024 (Monday) - NOT DST (after transition)
    124,    // 19. Oct 1, 2024 (Tuesday) - IN DST
    124,    // 20. Oct 15, 2024 (Tuesday) - IN DST
    // 2023 DST transitions
    123,    // 21. Mar 25, 2023 (Saturday) - NOT DST
    123,    // 22. Mar 26, 2023 (Sunday) - IN DST (transition day)
    123,    // 23. Mar 27, 2023 (Monday) - IN DST
    123,    // 24. Oct 28, 2023 (Saturday) - IN DST
    123,    // 25. Oct 29, 2023 (Sunday) - NOT DST (transition day, DST ends) *** BUG HERE ***
    123,    // 26. Oct 30, 2023 (Monday) - NOT DST
    // 2025 DST transitions
    125,    // 27. Mar 29, 2025 (Saturday) - NOT DST
    125,    // 28. Mar 30, 2025 (Sunday) - IN DST (transition day)
    125,    // 29. Mar 31, 2025 (Monday) - IN DST
    125,    // 30. Oct 25, 2025 (Saturday) - IN DST
    125,    // 31. Oct 26, 2025 (Sunday) - NOT DST (transition day, DST ends) *** BUG HERE ***
    125     // 32. Oct 27, 2025 (Monday) - NOT DST
}

constant integer DST_TEST_MONTH[] = {
    0, 1, 10, 11,           // Winter months
    3, 4, 5, 6, 7, 8,       // Summer months
    2, 2, 2, 2, 2,          // March 2024
    9, 9, 9, 9, 9,          // October 2024
    2, 2, 2,                // March 2023
    9, 9, 9,                // October 2023
    2, 2, 2,                // March 2025
    9, 9, 9                 // October 2025
}

constant integer DST_TEST_DAY[] = {
    15, 20, 10, 25,         // Winter months
    15, 20, 21, 4, 10, 15,  // Summer months
    29, 30, 31, 1, 15,      // March 2024
    26, 27, 28, 1, 15,      // October 2024
    25, 26, 27,             // March 2023
    28, 29, 30,             // October 2023
    29, 30, 31,             // March 2025
    25, 26, 27              // October 2025
}

constant integer DST_TEST_WEEKDAY[] = {
    2, 3, 1, 4,             // Winter months (Mon, Tue, Sun, Wed)
    2, 2, 6, 5, 7, 1,       // Summer months
    6, 7, 1, 6, 6,          // March 2024 (Fri, Sat, Sun-LAST, Fri, Fri)
    7, 1, 2, 3, 3,          // October 2024 (Sat, Sun-LAST, Mon, Tue, Tue)
    7, 1, 2,                // March 2023 (Sat, Sun-LAST, Mon)
    7, 1, 2,                // October 2023 (Sat, Sun-LAST, Mon)
    7, 1, 2,                // March 2025 (Sat, Sun-LAST, Mon)
    7, 1, 2                 // October 2025 (Sat, Sun-LAST, Mon)
}

constant char DST_TEST_EXPECTED[] = {
    false, false, false, false,     // Winter months
    true, true, true, true, true, true,     // Summer months
    false, false, true, false, false,       // March 2024
    true, false, false, true, true,         // October 2024 (17=BUG TEST)
    false, true, true,                      // March 2023
    true, false, false,                     // October 2023 (25=BUG TEST)
    false, true, true,                      // March 2025
    true, false, false                      // October 2025 (31=BUG TEST)
}

define_function TestNAVDateTimeIsDst() {
    stack_var integer x

    NAVLog("'***************** NAVDateTimeIsDst *****************'")

    for (x = 1; x <= length_array(DST_TEST_YEAR); x++) {
        stack_var _NAVTimespec timespec
        stack_var char expected
        stack_var char result

        // Set up timespec
        timespec.Year = DST_TEST_YEAR[x]
        timespec.Month = DST_TEST_MONTH[x]
        timespec.MonthDay = DST_TEST_DAY[x]
        timespec.WeekDay = DST_TEST_WEEKDAY[x]
        timespec.Hour = 12  // Noon - middle of the day
        timespec.Minute = 0
        timespec.Seconds = 0

        expected = DST_TEST_EXPECTED[x]
        result = NAVDateTimeIsDst(timespec)

        if (!NAVAssertBooleanEqual('Should determine DST correctly', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
