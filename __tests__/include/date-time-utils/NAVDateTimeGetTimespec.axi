PROGRAM_NAME='NAVDateTimeGetTimespec'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test dates in MM/DD/YYYY format
constant char DST_TEST_DATES[][10] = {
    '01/15/2024',   // 1. January 15, 2024 (Monday)
    '02/29/2020',   // 2. February 29, 2020 (Saturday) - leap day
    '03/31/2024',   // 3. March 31, 2024 (Sunday) - DST starts
    '07/04/2024',   // 4. July 4, 2024 (Thursday)
    '10/27/2024',   // 5. October 27, 2024 (Sunday) - DST ends
    '12/25/2024',   // 6. December 25, 2024 (Wednesday)
    '01/01/2000',   // 7. January 1, 2000 (Saturday)
    '06/15/2023',   // 8. June 15, 2023 (Thursday)
    '11/30/2025',   // 9. November 30, 2025 (Sunday)
    '05/01/2021'    // 10. May 1, 2021 (Saturday)
}

// Test times in HH:MM:SS format
constant char DST_TEST_TIMES[][8] = {
    '00:00:00',     // 1. Midnight
    '12:30:45',     // 2. 12:30:45 PM
    '01:00:00',     // 3. 1:00 AM (DST transition time)
    '14:30:00',     // 4. 2:30 PM
    '23:59:59',     // 5. One second before midnight
    '08:15:30',     // 6. 8:15:30 AM
    '00:00:00',     // 7. Midnight
    '18:45:22',     // 8. 6:45:22 PM
    '09:00:00',     // 9. 9:00 AM
    '16:20:10'      // 10. 4:20:10 PM
}

// Expected year (years since 1900)
constant integer EXPECTED_YEAR[] = {
    124,    // 2024
    120,    // 2020
    124,    // 2024
    124,    // 2024
    124,    // 2024
    124,    // 2024
    100,    // 2000
    123,    // 2023
    125,    // 2025
    121     // 2021
}

// Expected month (0-11, 0 = January)
constant integer EXPECTED_MONTH[] = {
    0,      // January
    1,      // February
    2,      // March
    6,      // July
    9,      // October
    11,     // December
    0,      // January
    5,      // June
    10,     // November
    4       // May
}

// Expected day of month (1-31)
constant integer EXPECTED_DAY[] = {
    15,     // 15th
    29,     // 29th (leap day)
    31,     // 31st
    4,      // 4th
    27,     // 27th
    25,     // 25th
    1,      // 1st
    15,     // 15th
    30,     // 30th
    1       // 1st
}

// Expected hour (0-23)
constant integer EXPECTED_HOUR[] = {
    0,      // 00:00
    12,     // 12:30
    1,      // 01:00
    14,     // 14:30
    23,     // 23:59
    8,      // 08:15
    0,      // 00:00
    18,     // 18:45
    9,      // 09:00
    16      // 16:20
}

// Expected minute (0-59)
constant integer EXPECTED_MINUTE[] = {
    0,      // :00
    30,     // :30
    0,      // :00
    30,     // :30
    59,     // :59
    15,     // :15
    0,      // :00
    45,     // :45
    0,      // :00
    20      // :20
}

// Expected seconds (0-59)
constant integer EXPECTED_SECONDS[] = {
    0,      // :00
    45,     // :45
    0,      // :00
    0,      // :00
    59,     // :59
    30,     // :30
    0,      // :00
    22,     // :22
    0,      // :00
    10      // :10
}

// Expected weekday (1=Sun, 2=Mon, ..., 7=Sat)
constant integer EXPECTED_WEEKDAY[] = {
    2,      // Monday
    7,      // Saturday
    1,      // Sunday
    5,      // Thursday
    1,      // Sunday
    4,      // Wednesday
    7,      // Saturday
    5,      // Thursday
    1,      // Sunday
    7       // Saturday
}

// Expected year day (1-366)
constant integer EXPECTED_YEARDAY[] = {
    15,     // Jan 15 = 15
    60,     // Feb 29 (leap year) = 31 + 29 = 60
    91,     // Mar 31 = 31 + 29 + 31 = 91 (2024 is leap year)
    186,    // Jul 4 = 31+29+31+30+31+30+4 = 186 (2024 is leap year)
    301,    // Oct 27 = 31+29+31+30+31+30+31+31+30+27 = 301 (2024 is leap year)
    360,    // Dec 25 = 31+29+31+30+31+30+31+31+30+31+30+25 = 360 (2024 is leap year)
    1,      // Jan 1 = 1
    166,    // Jun 15 = 31+28+31+30+31+15 = 166 (2023 not leap year)
    334,    // Nov 30 = 31+28+31+30+31+30+31+31+30+31+30 = 334 (2025 not leap year)
    121     // May 1 = 31+28+31+30+1 = 121 (2021 not leap year)
}

// Expected DST status
constant char EXPECTED_DST[] = {
    false,  // Jan 15, 2024 - not DST
    false,  // Feb 29, 2020 - not DST
    true,   // Mar 31, 2024 - DST starts (last Sunday in March)
    true,   // Jul 4, 2024 - DST
    false,  // Oct 27, 2024 - DST ends (last Sunday in October)
    false,  // Dec 25, 2024 - not DST
    false,  // Jan 1, 2000 - not DST
    true,   // Jun 15, 2023 - DST
    false,  // Nov 30, 2025 - not DST
    true    // May 1, 2021 - DST
}

// Expected leap year status
constant char EXPECTED_LEAP_YEAR[] = {
    true,   // 2024 - leap year (divisible by 4, not by 100)
    true,   // 2020 - leap year (divisible by 4, not by 100)
    true,   // 2024 - leap year
    true,   // 2024 - leap year
    true,   // 2024 - leap year
    true,   // 2024 - leap year
    true,   // 2000 - leap year (divisible by 400)
    false,  // 2023 - not leap year
    false,  // 2025 - not leap year
    false   // 2021 - not leap year
}

define_function TestNAVDateTimeGetTimespec() {
    stack_var integer x

    NAVLog("'***************** NAVDateTimeGetTimespec *****************'")

    for (x = 1; x <= length_array(DST_TEST_DATES); x++) {
        stack_var _NAVTimespec timespec
        stack_var char result

        // Test the function
        result = NAVDateTimeGetTimespec(timespec, DST_TEST_DATES[x], DST_TEST_TIMES[x])

        // Check return value
        if (!NAVAssertBooleanEqual('Should parse date/time successfully', true, result)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Validate Year
        if (!NAVAssertIntegerEqual('Should parse year correctly', EXPECTED_YEAR[x], timespec.Year)) {
            NAVLogTestFailed(x, itoa(EXPECTED_YEAR[x]), itoa(timespec.Year))
            continue
        }

        // Validate Month
        if (!NAVAssertIntegerEqual('Should parse month correctly', EXPECTED_MONTH[x], timespec.Month)) {
            NAVLogTestFailed(x, itoa(EXPECTED_MONTH[x]), itoa(timespec.Month))
            continue
        }

        // Validate Day
        if (!NAVAssertIntegerEqual('Should parse day correctly', EXPECTED_DAY[x], timespec.MonthDay)) {
            NAVLogTestFailed(x, itoa(EXPECTED_DAY[x]), itoa(timespec.MonthDay))
            continue
        }

        // Validate Hour
        if (!NAVAssertIntegerEqual('Should parse hour correctly', EXPECTED_HOUR[x], timespec.Hour)) {
            NAVLogTestFailed(x, itoa(EXPECTED_HOUR[x]), itoa(timespec.Hour))
            continue
        }

        // Validate Minute
        if (!NAVAssertIntegerEqual('Should parse minute correctly', EXPECTED_MINUTE[x], timespec.Minute)) {
            NAVLogTestFailed(x, itoa(EXPECTED_MINUTE[x]), itoa(timespec.Minute))
            continue
        }

        // Validate Seconds
        if (!NAVAssertIntegerEqual('Should parse seconds correctly', EXPECTED_SECONDS[x], timespec.Seconds)) {
            NAVLogTestFailed(x, itoa(EXPECTED_SECONDS[x]), itoa(timespec.Seconds))
            continue
        }

        // Validate WeekDay
        if (!NAVAssertIntegerEqual('Should calculate weekday correctly', EXPECTED_WEEKDAY[x], timespec.WeekDay)) {
            NAVLogTestFailed(x, itoa(EXPECTED_WEEKDAY[x]), itoa(timespec.WeekDay))
            continue
        }

        // Validate YearDay
        if (!NAVAssertIntegerEqual('Should calculate yearday correctly', EXPECTED_YEARDAY[x], timespec.YearDay)) {
            NAVLogTestFailed(x, itoa(EXPECTED_YEARDAY[x]), itoa(timespec.YearDay))
            continue
        }

        // Validate DST
        if (!NAVAssertBooleanEqual('Should calculate DST correctly', EXPECTED_DST[x], timespec.IsDst)) {
            NAVLogTestFailed(x, NAVBooleanToString(EXPECTED_DST[x]), NAVBooleanToString(timespec.IsDst))
            continue
        }

        // Validate IsLeapYear
        if (!NAVAssertBooleanEqual('Should calculate leap year correctly', EXPECTED_LEAP_YEAR[x], timespec.IsLeapYear)) {
            NAVLogTestFailed(x, NAVBooleanToString(EXPECTED_LEAP_YEAR[x]), NAVBooleanToString(timespec.IsLeapYear))
            continue
        }

        // Validate GmtOffset (should be valid range)
        if (!NAVAssertTrue('GMT offset should be within valid range',
                          (timespec.GmtOffset >= -720 && timespec.GmtOffset <= 840))) {
            NAVLogTestFailed(x, '-720 to +840', itoa(timespec.GmtOffset))
            continue
        }

        // Validate Timezone (should not be empty)
        if (!NAVAssertTrue('Timezone should be populated',
                          (length_array(timespec.Timezone) > 0))) {
            NAVLogTestFailed(x, 'non-empty string', timespec.Timezone)
            continue
        }

        NAVLogTestPassed(x)
    }
}
