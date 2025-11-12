PROGRAM_NAME='NAVDateTimeGetTimestampFormat'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data for GetTimestampFormat function
// Using a known date/time for consistent testing:
// Year: 2023 (123 since 1900)
// Month: November (10, 0-based)
// Day: 23
// Hour: 21 (9 PM)
// Minute: 30
// Second: 45
// WeekDay: Thursday (5)

constant integer TIMESTAMP_FORMAT_TEST[] = {
    NAV_DATETIME_TIMESTAMP_FORMAT_UTC,
    NAV_DATETIME_TIMESTAMP_FORMAT_ATOM,
    NAV_DATETIME_TIMESTAMP_FORMAT_COOKIE,
    NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601,
    NAV_DATETIME_TIMESTAMP_FORMAT_RFC822,
    NAV_DATETIME_TIMESTAMP_FORMAT_RFC850,
    NAV_DATETIME_TIMESTAMP_FORMAT_RFC1036,
    NAV_DATETIME_TIMESTAMP_FORMAT_RFC1123,
    NAV_DATETIME_TIMESTAMP_FORMAT_RFC7231,
    NAV_DATETIME_TIMESTAMP_FORMAT_RFC2822,
    NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339,
    NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339EXT,
    NAV_DATETIME_TIMESTAMP_FORMAT_RSS,
    NAV_DATETIME_TIMESTAMP_FORMAT_W3C,
    NAV_DATETIME_TIMESTAMP_FORMAT_DEFAULT,
    999  // Invalid format - should default to ISO8601
}

constant char TIMESTAMP_FORMAT_EXPECTED[][NAV_MAX_BUFFER] = {
    '11/23/2023 @ 21:30pm',                         // UTC
    '2023-11-23T21:30:45+00:00',                    // ATOM
    'Thursday, 23-Nov-2023 21:30:45 GMT',           // COOKIE
    '2023-11-23T21:30:45+0000',                     // ISO8601
    'Thu, 23 Nov 23 21:30:45 +0000',                // RFC822
    'Thursday, 23-Nov-23 21:30:45 GMT',             // RFC850
    'Thursday, 23-Nov-23 21:30:45 +0000',           // RFC1036
    'Thu, 23 Nov 2023 21:30:45 +0000',              // RFC1123
    'Thu, 23 Nov 2023 21:30:45 GMT',                // RFC7231
    'Thu, 23 Nov 2023 21:30:45 +0000',              // RFC2822
    '2023-11-23T21:30:45+00:00',                    // RFC3339
    '2023-11-23T21:30:45.000+00:00',                // RFC3339EXT
    'Thu, 23 Nov 2023 21:30:45 +0000',              // RSS
    '2023-11-23T21:30:45+00:00',                    // W3C
    '2023-11-23T21:30:45+0000',                     // DEFAULT (ISO8601)
    '2023-11-23T21:30:45+0000'                      // Invalid format defaults to ISO8601
}

define_function TestNAVDateTimeGetTimestampFormat() {
    stack_var integer x

    NAVLog("'***************** NAVDateTimeGetTimestampFormat *****************'")

    for (x = 1; x <= length_array(TIMESTAMP_FORMAT_TEST); x++) {
        stack_var _NAVTimespec timespec
        stack_var integer timestampformat
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        // Create a known timespec for testing
        // November 23, 2023, 21:30:45 (Thursday)
        timespec.Year = 123          // 2023 (years since 1900)
        timespec.Month = 10          // November (0-based)
        timespec.MonthDay = 23
        timespec.Hour = 21
        timespec.Minute = 30
        timespec.Seconds = 45
        timespec.WeekDay = 5         // Thursday
        timespec.YearDay = 327       // 327th day of year
        timespec.IsLeapYear = false
        timespec.IsDst = false
        timespec.GmtOffset = 0
        timespec.Timezone = 'UTC+00:00'

        timestampformat = TIMESTAMP_FORMAT_TEST[x]
        expected = TIMESTAMP_FORMAT_EXPECTED[x]
        result = NAVDateTimeGetTimestampFormat(timespec, timestampformat)

        if (!NAVAssertStringEqual('Should format timestamp correctly', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    // Additional test with positive timezone offset (GMT+01:00)
    TestNAVDateTimeGetTimestampFormatWithOffset()
}


define_function TestNAVDateTimeGetTimestampFormatWithOffset() {
    stack_var _NAVTimespec timespec
    stack_var char result[NAV_MAX_BUFFER]
    stack_var char expected[NAV_MAX_BUFFER]
    stack_var integer testNum

    NAVLog("'***************** NAVDateTimeGetTimestampFormat (With Offset) *****************'")

    // Test with GMT+01:00 (60 minutes)
    timespec.Year = 123
    timespec.Month = 10
    timespec.MonthDay = 23
    timespec.Hour = 21
    timespec.Minute = 30
    timespec.Seconds = 45
    timespec.WeekDay = 5
    timespec.YearDay = 327
    timespec.IsLeapYear = false
    timespec.IsDst = false
    timespec.GmtOffset = 60  // +01:00
    timespec.Timezone = 'UTC+01:00'

    testNum = 1

    // Test ISO8601 with +01:00
    expected = '2023-11-23T21:30:45+0100'
    result = NAVDateTimeGetTimestampFormat(timespec, NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601)
    if (!NAVAssertStringEqual('ISO8601 with +01:00', expected, result)) {
        NAVLogTestFailed(testNum, expected, result)
    }
    else {
        NAVLogTestPassed(testNum)
    }
    testNum++

    // Test RFC3339 with +01:00
    expected = '2023-11-23T21:30:45+01:00'
    result = NAVDateTimeGetTimestampFormat(timespec, NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339)
    if (!NAVAssertStringEqual('RFC3339 with +01:00', expected, result)) {
        NAVLogTestFailed(testNum, expected, result)
    }
    else {
        NAVLogTestPassed(testNum)
    }
    testNum++

    // Test with GMT-05:00 (New York, -300 minutes)
    timespec.GmtOffset = -300  // -05:00

    // Test ISO8601 with -05:00
    expected = '2023-11-23T21:30:45-0500'
    result = NAVDateTimeGetTimestampFormat(timespec, NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601)
    if (!NAVAssertStringEqual('ISO8601 with -05:00', expected, result)) {
        NAVLogTestFailed(testNum, expected, result)
    }
    else {
        NAVLogTestPassed(testNum)
    }
    testNum++

    // Test RFC3339 with -05:00
    expected = '2023-11-23T21:30:45-05:00'
    result = NAVDateTimeGetTimestampFormat(timespec, NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339)
    if (!NAVAssertStringEqual('RFC3339 with -05:00', expected, result)) {
        NAVLogTestFailed(testNum, expected, result)
    }
    else {
        NAVLogTestPassed(testNum)
    }
    testNum++

    // Test with GMT+05:30 (India, 330 minutes)
    timespec.GmtOffset = 330  // +05:30

    // Test RFC3339 with +05:30
    expected = '2023-11-23T21:30:45+05:30'
    result = NAVDateTimeGetTimestampFormat(timespec, NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339)
    if (!NAVAssertStringEqual('RFC3339 with +05:30', expected, result)) {
        NAVLogTestFailed(testNum, expected, result)
    }
    else {
        NAVLogTestPassed(testNum)
    }
}

