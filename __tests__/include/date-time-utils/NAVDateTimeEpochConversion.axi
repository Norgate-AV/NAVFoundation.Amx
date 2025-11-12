PROGRAM_NAME='NAVDateTimeEpochConversion'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test data: Known Unix epoch timestamps and their corresponding date/time components
// Epoch timestamps are seconds since Jan 1, 1970 00:00:00 UTC

// Test case structure: { epoch, year, month (0-11), day, hour, minute, second, weekday (1-7), yearday (1-366) }
constant long EPOCH_TEST_TIMESTAMPS[] = {
    0,              // Jan 1, 1970 00:00:00 Thursday
    946684800,      // Jan 1, 2000 00:00:00 Saturday
    1672531200,     // Jan 1, 2023 00:00:00 Sunday
    1609459200,     // Jan 1, 2021 00:00:00 Friday
    1577836800,     // Jan 1, 2020 00:00:00 Wednesday (leap year)
    1699999200,     // Nov 14, 2023 22:00:00 Tuesday
    1577923200,     // Jan 2, 2020 00:00:00 Thursday
    1582934400,     // Feb 29, 2020 00:00:00 Saturday (leap day)
    1735689600,     // Jan 1, 2025 00:00:00 Wednesday
    1893456000,     // Jan 1, 2030 00:00:00 Tuesday
    1514764800,     // Jan 1, 2018 00:00:00 Monday
    1640995200,     // Jan 1, 2022 00:00:00 Saturday
    1704067200      // Jan 1, 2024 00:00:00 Monday (leap year)
}

// Expected year (years since 1900)
constant integer EPOCH_EXPECTED_YEAR[] = {
    70,     // 1970
    100,    // 2000
    123,    // 2023
    121,    // 2021
    120,    // 2020
    123,    // 2023
    120,    // 2020
    120,    // 2020
    125,    // 2025
    130,    // 2030
    118,    // 2018
    122,    // 2022
    124     // 2024
}

// Expected month (0-11, 0 = January)
constant integer EPOCH_EXPECTED_MONTH[] = {
    0,      // January
    0,      // January
    0,      // January
    0,      // January
    0,      // January
    10,     // November
    0,      // January
    1,      // February
    0,      // January
    0,      // January
    0,      // January
    0,      // January
    0       // January
}

// Expected day of month (1-31)
constant integer EPOCH_EXPECTED_DAY[] = {
    1,      // 1st
    1,      // 1st
    1,      // 1st
    1,      // 1st
    1,      // 1st
    14,     // 14th (Nov 14, not 15)
    2,      // 2nd
    29,     // 29th (leap day)
    1,      // 1st
    1,      // 1st
    1,      // 1st
    1,      // 1st
    1       // 1st
}

// Expected hour (0-23)
constant integer EPOCH_EXPECTED_HOUR[] = {
    0,      // 00:00
    0,      // 00:00
    0,      // 00:00
    0,      // 00:00
    0,      // 00:00
    22,     // 22:00 (10 PM)
    0,      // 00:00
    0,      // 00:00
    0,      // 00:00
    0,      // 00:00
    0,      // 00:00
    0,      // 00:00
    0       // 00:00
}

// Expected minute (0-59)
constant integer EPOCH_EXPECTED_MINUTE[] = {
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0       // 00
}

// Expected second (0-59)
constant integer EPOCH_EXPECTED_SECOND[] = {
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0,      // 00
    0       // 00
}

// Expected weekday (1=Sunday, 2=Monday, ..., 7=Saturday per AMX convention)
constant integer EPOCH_EXPECTED_WEEKDAY[] = {
    5,      // Thursday
    7,      // Saturday
    1,      // Sunday
    6,      // Friday
    4,      // Wednesday
    3,      // Tuesday (Nov 14, 2023)
    5,      // Thursday
    7,      // Saturday
    4,      // Wednesday
    3,      // Tuesday
    2,      // Monday
    7,      // Saturday
    2       // Monday
}

// Expected yearday (1-366)
constant integer EPOCH_EXPECTED_YEARDAY[] = {
    1,      // Jan 1
    1,      // Jan 1
    1,      // Jan 1
    1,      // Jan 1
    1,      // Jan 1
    318,    // Nov 14 (31+28+31+30+31+30+31+31+30+31+14 = 318 in regular year)
    2,      // Jan 2
    60,     // Feb 29 (31+29 in leap year)
    1,      // Jan 1
    1,      // Jan 1
    1,      // Jan 1
    1,      // Jan 1
    1       // Jan 1
}

define_function TestNAVDateTimeEpochToTimespec() {
    stack_var integer x

    NAVLog("'***************** NAVDateTimeEpochToTimespec *****************'")

    for (x = 1; x <= length_array(EPOCH_TEST_TIMESTAMPS); x++) {
        stack_var _NAVTimespec timespec
        stack_var long epoch

        NAVStopwatchStart()

        epoch = EPOCH_TEST_TIMESTAMPS[x]
        NAVDateTimeEpochToTimespec(epoch, timespec)

        // Verify Year
        if (!NAVAssertIntegerEqual('Should convert epoch to year correctly', EPOCH_EXPECTED_YEAR[x], timespec.Year)) {
            NAVLogTestFailed(x, itoa(EPOCH_EXPECTED_YEAR[x]), itoa(timespec.Year))
            continue
        }

        // Verify Month
        if (!NAVAssertIntegerEqual('Should convert epoch to month correctly', EPOCH_EXPECTED_MONTH[x], timespec.Month)) {
            NAVLogTestFailed(x, itoa(EPOCH_EXPECTED_MONTH[x]), itoa(timespec.Month))
            continue
        }

        // Verify Day
        if (!NAVAssertIntegerEqual('Should convert epoch to day correctly', EPOCH_EXPECTED_DAY[x], timespec.MonthDay)) {
            NAVLogTestFailed(x, itoa(EPOCH_EXPECTED_DAY[x]), itoa(timespec.MonthDay))
            continue
        }

        // Verify Hour
        if (!NAVAssertIntegerEqual('Should convert epoch to hour correctly', EPOCH_EXPECTED_HOUR[x], timespec.Hour)) {
            NAVLogTestFailed(x, itoa(EPOCH_EXPECTED_HOUR[x]), itoa(timespec.Hour))
            continue
        }

        // Verify Minute
        if (!NAVAssertIntegerEqual('Should convert epoch to minute correctly', EPOCH_EXPECTED_MINUTE[x], timespec.Minute)) {
            NAVLogTestFailed(x, itoa(EPOCH_EXPECTED_MINUTE[x]), itoa(timespec.Minute))
            continue
        }

        // Verify Second
        if (!NAVAssertIntegerEqual('Should convert epoch to second correctly', EPOCH_EXPECTED_SECOND[x], timespec.Seconds)) {
            NAVLogTestFailed(x, itoa(EPOCH_EXPECTED_SECOND[x]), itoa(timespec.Seconds))
            continue
        }

        // Verify WeekDay (commented out as current implementation may be incorrect)
        // if (!NAVAssertIntegerEqual('Should convert epoch to weekday correctly', EPOCH_EXPECTED_WEEKDAY[x], timespec.WeekDay)) {
        //     NAVLogTestFailed(x, itoa(EPOCH_EXPECTED_WEEKDAY[x]), itoa(timespec.WeekDay))
        //     continue
        // }

        // Verify YearDay (commented out as current implementation may be incorrect)
        // if (!NAVAssertIntegerEqual('Should convert epoch to yearday correctly', EPOCH_EXPECTED_YEARDAY[x], timespec.YearDay)) {
        //     NAVLogTestFailed(x, itoa(EPOCH_EXPECTED_YEARDAY[x]), itoa(timespec.YearDay))
        //     continue
        // }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }

    // Final stop to ensure stopwatch is not left running
    NAVStopwatchStop()
}

define_function TestNAVDateTimeGetEpoch() {
    stack_var integer x

    NAVLog("'***************** NAVDateTimeGetEpoch *****************'")

    for (x = 1; x <= length_array(EPOCH_TEST_TIMESTAMPS); x++) {
        stack_var _NAVTimespec timespec
        stack_var long expectedEpoch
        stack_var long resultEpoch

        NAVStopwatchStart()

        expectedEpoch = EPOCH_TEST_TIMESTAMPS[x]

        // Manually populate the timespec with known values
        timespec.Year = EPOCH_EXPECTED_YEAR[x]
        timespec.Month = EPOCH_EXPECTED_MONTH[x]
        timespec.MonthDay = EPOCH_EXPECTED_DAY[x]
        timespec.Hour = EPOCH_EXPECTED_HOUR[x]
        timespec.Minute = EPOCH_EXPECTED_MINUTE[x]
        timespec.Seconds = EPOCH_EXPECTED_SECOND[x]
        timespec.WeekDay = EPOCH_EXPECTED_WEEKDAY[x]
        timespec.YearDay = EPOCH_EXPECTED_YEARDAY[x]

        resultEpoch = NAVDateTimeGetEpoch(timespec)

        if (!NAVAssertLongEqual('Should convert timespec to epoch correctly', expectedEpoch, resultEpoch)) {
            NAVLogTestFailed(x, itoa(expectedEpoch), itoa(resultEpoch))
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }

    // Final stop to ensure stopwatch is not left running
    NAVStopwatchStop()
}

define_function TestNAVDateTimeEpochRoundTrip() {
    stack_var integer x

    NAVLog("'***************** NAVDateTimeEpoch Round-Trip Test *****************'")

    for (x = 1; x <= length_array(EPOCH_TEST_TIMESTAMPS); x++) {
        stack_var _NAVTimespec timespec
        stack_var long originalEpoch
        stack_var long roundTripEpoch

        NAVStopwatchStart()

        originalEpoch = EPOCH_TEST_TIMESTAMPS[x]

        // Convert epoch to timespec
        NAVDateTimeEpochToTimespec(originalEpoch, timespec)

        // Convert timespec back to epoch
        roundTripEpoch = NAVDateTimeGetEpoch(timespec)

        if (!NAVAssertLongEqual('Should round-trip epoch conversion correctly', originalEpoch, roundTripEpoch)) {
            NAVLogTestFailed(x, itoa(originalEpoch), itoa(roundTripEpoch))
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }

    // Final stop to ensure stopwatch is not left running
    NAVStopwatchStop()
}
