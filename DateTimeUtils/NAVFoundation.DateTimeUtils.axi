PROGRAM_NAME='NAVFoundation.DateTimeUtils'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_DATETIMEUTILS__
#DEFINE __NAV_FOUNDATION_DATETIMEUTILS__ 'NAVFoundation.DateTimeUtils'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.DateTimeUtils.h.axi'

/**
 * @function NAVDateTimeGetTimespecNow
 * @public
 * @description Gets the current date and time and fills a timespec structure.
 *
 * @param {_NAVTimespec} timespec - Structure to fill with current date and time information
 *
 * @returns {char} True if successful, false otherwise
 *
 * @example
 * stack_var _NAVTimespec now
 * if (NAVDateTimeGetTimespecNow(now)) {
 *     // Use the current time values in the now structure
 *     NAVDateTimeTimespecLog('Current Time', now)
 * }
 */
define_function char NAVDateTimeGetTimespecNow(_NAVTimespec timespec) {
    return NAVDateTimeGetTimespec(timespec, ldate, time)
}


/**
 * @function NAVDateTimeGetTimespec
 * @public
 * @description Fills a timespec structure with date and time from the provided strings.
 *
 * @param {_NAVTimespec} timespec - Structure to fill with date and time information
 * @param {char[]} date - Date string in MM/DD/YYYY format
 * @param {char[]} time - Time string in HH:MM:SS format
 *
 * @returns {char} True if successful, false otherwise
 *
 * @example
 * stack_var _NAVTimespec customTime
 * if (NAVDateTimeGetTimespec(customTime, '11/23/2023', '14:30:00')) {
 *     // Use the values in the customTime structure
 * }
 */
define_function char NAVDateTimeGetTimespec(_NAVTimespec timespec, char date[], char time[]) {
    stack_var sinteger hours
    stack_var sinteger minutes
    stack_var sinteger seconds

    stack_var sinteger day
    stack_var sinteger month
    stack_var sinteger year
    stack_var sinteger dayOfWeek

    seconds = time_to_second(time)
    if (seconds < 0) {
        return false
    }

    minutes = time_to_minute(time)
    if (minutes < 0) {
        return false
    }

    hours = time_to_hour(time)
    if (hours < 0) {
        return false
    }

    day = date_to_day(date)
    if (day < 0) {
        return false
    }

    month = date_to_month(date)
    if (month < 0) {
        return false
    }

    year = date_to_year(date)
    if (year < 0) {
        return false
    }

    dayOfWeek = day_of_week(date)
    if (dayOfWeek < 0) {
        return false
    }

    timespec.Year = type_cast(year)
    timespec.Month = type_cast(month)
    timespec.MonthDay = type_cast(day)

    timespec.Hour = type_cast(hours)
    timespec.Minute = type_cast(minutes)
    timespec.Seconds = type_cast(seconds)

    timespec.WeekDay = type_cast(dayOfWeek)
    timespec.YearDay = NAVDateTimeGetYearDay(timespec)

    timespec.IsDst = NAVDateTimeIsDst(timespec)
}


DEFINE_CONSTANT

/**
 * @constant NAV_DATETIME_DST_START_MONTH
 * @description Month when Daylight Saving Time starts (March)
 */
constant integer NAV_DATETIME_DST_START_MONTH = 3

/**
 * @constant NAV_DATETIME_DST_START_DAY
 * @description Day when Daylight Saving Time starts (0 = last Sunday)
 */
constant integer NAV_DATETIME_DST_START_DAY = 0

/**
 * @constant NAV_DATETIME_DST_START_HOUR
 * @description Hour when Daylight Saving Time starts (2:00 AM)
 */
constant integer NAV_DATETIME_DST_START_HOUR = 2

/**
 * @constant NAV_DATETIME_DST_START_MINUTE
 * @description Minute when Daylight Saving Time starts
 */
constant integer NAV_DATETIME_DST_START_MINUTE = 0

/**
 * @constant NAV_DATETIME_DST_END_MONTH
 * @description Month when Daylight Saving Time ends (November)
 */
constant integer NAV_DATETIME_DST_END_MONTH = 11

/**
 * @constant NAV_DATETIME_DST_END_DAY
 * @description Day when Daylight Saving Time ends (0 = last Sunday)
 */
constant integer NAV_DATETIME_DST_END_DAY = 0

/**
 * @constant NAV_DATETIME_DST_END_HOUR
 * @description Hour when Daylight Saving Time ends (2:00 AM)
 */
constant integer NAV_DATETIME_DST_END_HOUR = 2

/**
 * @constant NAV_DATETIME_DST_END_MINUTE
 * @description Minute when Daylight Saving Time ends
 */
constant integer NAV_DATETIME_DST_END_MINUTE = 0


/**
 * @function NAVDateTimeGetGmtOffset
 * @public
 * @description Gets the current GMT offset based on timezone configuration.
 *
 * @returns {integer} GMT offset in minutes, or 0 if not available
 */
define_function integer NAVDateTimeGetGmtOffset() {

}


/**
 * @function NAVDateTimeGetLastSundayInMonth
 * @public
 * @description Calculates the date of the last Sunday in a given month and year.
 *
 * @param {integer} year - Year for the calculation
 * @param {integer} month - Month for the calculation (1-12)
 *
 * @returns {integer} Day of the month of the last Sunday (1-31)
 *
 * @example
 * stack_var integer lastSunday
 * lastSunday = NAVDateTimeGetLastSundayInMonth(2023, 11)  // Returns the day of last Sunday in November 2023
 */
define_function integer NAVDateTimeGetLastSundayInMonth(integer year, integer month) {
    stack_var integer x
    stack_var integer day
    stack_var integer count

    day = 0
    count = NAVDateTimeGetDaysInMonth(month)

    for (x = 1; x <= count; x++) {
        if (day_of_week("format('%02d', month), '/', format('%02d', x), '/', format('%04d', year)") == 1) {
            day = x
        }
    }

    return day
}


/**
 * @function NAVDateTimeIsDst
 * @public
 * @description Determines if the specified time is in Daylight Saving Time.
 *
 * @param {_NAVTimespec} timespec - Timespec structure containing date and time information
 *
 * @returns {char} True if time is in DST, false otherwise
 *
 * @example
 * stack_var _NAVTimespec now
 * stack_var char isDst
 *
 * NAVDateTimeGetTimespecNow(now)
 * isDst = NAVDateTimeIsDst(now)
 */
define_function char NAVDateTimeIsDst(_NAVTimespec timespec) {
    // UK DST rules: last Sunday in March to last Sunday in October
    // Optimized mathematical calculation

    stack_var integer month
    stack_var integer day
    stack_var integer year
    stack_var integer lastDayOfMonth
    stack_var integer lastDayDOW
    stack_var integer transitionDay

    month = timespec.Month + 1  // Convert from 0-based to 1-based
    day = timespec.MonthDay
    year = timespec.Year + 1900 // Convert from years since 1900

    // Not in DST months
    if (month < 3 || month > 10) {
        return false
    }

    // April to September: always in DST
    if (month > 3 && month < 10) {
        return true
    }

    // Get days in month (handles leap years)
    lastDayOfMonth = NAVDateTimeGetDaysInMonth(month)

    // Calculate day of week for the last day of month
    // Using the current date as reference point
    lastDayDOW = (timespec.WeekDay + (lastDayOfMonth - day)) % 7

    // Last Sunday is lastDayOfMonth - lastDayDOW (adjusted for Sunday = 0)
    if (lastDayDOW == 0) {
        transitionDay = lastDayOfMonth
    } else {
        transitionDay = lastDayOfMonth - lastDayDOW
    }

    if (month == 3) {  // March - DST starts on transition day
        return (day >= transitionDay)
    } else { // October - DST ends on transition day
        return (day <= transitionDay)
    }
}


/**
 * @function NAVDateTimeGetYearDay
 * @public
 * @description Calculates the day of the year (1-366) for a given timespec.
 *
 * @param {_NAVTimespec} timespec - Timespec structure containing date and time information
 *
 * @returns {integer} Day of the year (1-366)
 *
 * @example
 * stack_var _NAVTimespec now
 * stack_var integer dayOfYear
 *
 * NAVDateTimeGetTimespecNow(now)
 * dayOfYear = NAVDateTimeGetYearDay(now)
 */
define_function integer NAVDateTimeGetYearDay(_NAVTimespec timespec) {
    stack_var integer x
    stack_var integer result

    for (x = 1; x < timespec.Month; x++) {
        result = result + NAVDateTimeGetDaysInMonth(x)

        if (x == NAV_DATETIME_MONTH_FEBRUARY && NAVDateTimeIsLeapYear(timespec.Year)) {
            result++
        }
    }

    result = result + timespec.MonthDay

    return result
}


/**
 * @function NAVDateTimeIsLeapYear
 * @public
 * @description Determines if the specified year is a leap year.
 *
 * @param {integer} year - Year to check
 *
 * @returns {char} True if leap year, false otherwise
 *
 * @example
 * stack_var char isLeap
 * isLeap = NAVDateTimeIsLeapYear(2024)  // Returns true
 */
define_function char NAVDateTimeIsLeapYear(integer year) {
    return (year % 400 == 0) || (year % 100 == 0) || (year % 4 == 0)
}


/**
 * @function NAVGetNextDate
 * @public
 * @description Returns the next date after the current date.
 *
 * @returns {char[]} String representation of the next date in MM/DD/YYYY format
 *
 * @example
 * stack_var char nextDay[20]
 * nextDay = NAVGetNextDate()  // If today is 12/31/2023, returns "01/01/2024"
 *
 * @note Handles month and year transitions, including leap years
 */
define_function char[NAV_MAX_BUFFER] NAVGetNextDate() {
    stack_var integer x
    stack_var integer daysInMonth[12]

    stack_var integer thisDay
    stack_var integer thisMonth
    stack_var integer thisYear

    for (x = 1; x <= max_length_array(daysInMonth); x++) {
        daysInMonth[x] = NAVDateTimeGetDaysInMonth(x)
    }

    thisDay = type_cast(date_to_day(ldate)) + 1
    thisMonth = type_cast(date_to_month(ldate))
    thisYear = type_cast(date_to_year(ldate))

    if (thisDay <= 0 || thisMonth <= 0 || thisYear <= 0) {
        NAVLog("'Error: NAVGetNextDate() - Failed to get the current date'")
        return ""
    }

    if ((thisMonth == 2) && (thisDay == 29)) {
        if (NAVDateTimeIsLeapYear(thisYear)) {
            daysInMonth[2] = 29
        }
    }

    if (thisDay > daysInMonth[thisMonth]) {
        thisDay = 1
        thisMonth++

        if (thisMonth > 12) {
            thisMonth = 1
            thisYear++
        }
    }

    return "format('%02d', thisDay), '/', format('%02d', thisMonth), '/', format('%04d', thisYear)"
}


/**
 * @function NAVDateTimeTimespecPast
 * @public
 * @description Checks if the specified timespec is in the past relative to the current time.
 *
 * @param {_NAVTimespec} timespec - Timespec to check
 *
 * @returns {char} True if the time is in the past, false otherwise
 *
 * @example
 * stack_var _NAVTimespec oldTime
 * stack_var char isPast
 *
 * // Populate oldTime with a past date
 * isPast = NAVDateTimeTimespecPast(oldTime)  // Returns true
 */
define_function char NAVDateTimeTimespecPast(_NAVTimespec timespec) {
    stack_var _NAVTimespec now

    NAVDateTimeGetTimespecNow(now)

    return (NAVDateTimeGetEpoch(timespec) < NAVDateTimeGetEpoch(now))
}


/**
 * @function NAVDateTimeEpochToTimespec
 * @public
 * @description Converts a Unix epoch timestamp to a timespec structure.
 *
 * @param {long} epoch - Unix timestamp in seconds since Jan 1, 1970
 * @param {_NAVTimespec} timespec - Timespec structure to populate (modified in-place)
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVTimespec time
 * stack_var long epochTime
 *
 * epochTime = 1672531200  // Jan 1, 2023 00:00:00 UTC
 * NAVDateTimeEpochToTimespec(epochTime, time)
 */
define_function NAVDateTimeEpochToTimespec(long epoch, _NAVTimespec timespec) {
    stack_var long daysSinceEpoch
    stack_var long secondsToday
    stack_var integer year
    stack_var integer month
    stack_var integer daysInMonth
    stack_var long remainingDays

    // Extract time components (these are simple modulo operations)
    secondsToday = epoch % NAV_DATETIME_SECONDS_IN_1_DAY
    timespec.Hour = type_cast(secondsToday / NAV_DATETIME_SECONDS_IN_1_HOUR)
    timespec.Minute = type_cast((secondsToday % NAV_DATETIME_SECONDS_IN_1_HOUR) / NAV_DATETIME_SECONDS_IN_1_MINUTE)
    timespec.Seconds = type_cast(secondsToday % NAV_DATETIME_SECONDS_IN_1_MINUTE)

    // Calculate total days since epoch
    daysSinceEpoch = epoch / NAV_DATETIME_SECONDS_IN_1_DAY

    // Calculate day of week (Jan 1, 1970 was Thursday = 5 in 1-based system where Sunday = 1)
    timespec.WeekDay = type_cast(((daysSinceEpoch + 4) % 7) + 1)

    // Approximate year (will be exact or off by 1)
    year = type_cast(1970 + (daysSinceEpoch / 365))

    // Calculate exact days since Jan 1, 1970 to Jan 1 of calculated year
    // Days = (year - 1970) * 365 + leap days
    remainingDays = daysSinceEpoch - (((year - 1970) * 365) + ((year - 1969) / 4) - ((year - 1901) / 100) + ((year - 1601) / 400))

    // Adjust if we went too far
    if (remainingDays < 0) {
        year--
        remainingDays = daysSinceEpoch - (((year - 1970) * 365) + ((year - 1969) / 4) - ((year - 1901) / 100) + ((year - 1601) / 400))
    }

    // Store year as years since 1900
    timespec.Year = year - 1900
    timespec.YearDay = type_cast(remainingDays + 1)  // YearDay is 1-based (1-366)

    // Calculate month and day from remaining days
    month = 0  // Month is 0-based (0 = January)
    while (month < 12 && remainingDays >= 0) {
        daysInMonth = NAVDateTimeGetDaysInMonth(month + 1, year)

        if (remainingDays < daysInMonth) {
            break
        }

        remainingDays = remainingDays - daysInMonth
        month++
    }

    timespec.Month = month
    timespec.MonthDay = type_cast(remainingDays + 1)  // MonthDay is 1-based (1-31)
}


/**
 * @function NAVDateTimeGetEpochNow
 * @public
 * @description Gets the current Unix epoch timestamp.
 *
 * @returns {long} Current Unix timestamp in seconds since Jan 1, 1970
 *
 * @example
 * stack_var long currentEpoch
 * currentEpoch = NAVDateTimeGetEpochNow()
 */
define_function long NAVDateTimeGetEpochNow() {
    stack_var _NAVTimespec timespec

    NAVDateTimeGetTimespecNow(timespec)

    return NAVDateTimeGetEpoch(timespec)
}


/**
 * @function NAVDateTimeGetEpoch
 * @public
 * @description Converts a timespec structure to a Unix epoch timestamp.
 *
 * @param {_NAVTimespec} timespec - Timespec structure to convert
 *
 * @returns {long} Unix timestamp in seconds since Jan 1, 1970
 *
 * @example
 * stack_var _NAVTimespec time
 * stack_var long epochTime
 *
 * NAVDateTimeGetTimespecNow(time)
 * epochTime = NAVDateTimeGetEpoch(time)
 */
define_function long NAVDateTimeGetEpoch(_NAVTimespec timespec) {
    stack_var long result
    stack_var integer year
    stack_var long daysSinceEpoch

    // Convert year from "years since 1900" to full year
    year = timespec.Year + 1900

    // Calculate days from Jan 1, 1970 to Jan 1 of the given year
    // Formula: (year - 1970) * 365 + leap day adjustments
    daysSinceEpoch = (year - 1970) * 365
    daysSinceEpoch = daysSinceEpoch + ((year - 1969) / 4)      // Add leap years divisible by 4
    daysSinceEpoch = daysSinceEpoch - ((year - 1901) / 100)    // Subtract century years
    daysSinceEpoch = daysSinceEpoch + ((year - 1601) / 400)    // Add back 400-year leap years

    // Add days within the current year (YearDay is 1-based, so subtract 1)
    daysSinceEpoch = daysSinceEpoch + (timespec.YearDay - 1)

    // Convert days to seconds
    result = daysSinceEpoch * NAV_DATETIME_SECONDS_IN_1_DAY

    // Add time of day
    result = result + (timespec.Hour * NAV_DATETIME_SECONDS_IN_1_HOUR)
    result = result + (timespec.Minute * NAV_DATETIME_SECONDS_IN_1_MINUTE)
    result = result + timespec.Seconds

    return result
}


/**
 * @function NAVDateTimeTimespecLog
 * @public
 * @description Logs all fields of a timespec structure to the debug log.
 *
 * @param {char[]} sender - Name of the calling component/function for log attribution
 * @param {_NAVTimespec} timespec - Timespec structure to log
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVTimespec now
 * NAVDateTimeGetTimespecNow(now)
 * NAVDateTimeTimespecLog('MyFunction', now)
 */
define_function NAVDateTimeTimespecLog(char sender[], _NAVTimespec timespec) {
    NAVLog("sender, ' => Year: ', itoa(timespec.Year)")
    NAVLog("sender, ' => Month: ', itoa(timespec.Month), '-', NAVDateTimeGetMonthString(timespec.Month)")
    NAVLog("sender, ' => Day: ', itoa(timespec.MonthDay)")
    NAVLog("sender, ' => Day Of Week: ', itoa(timespec.WeekDay), '-', NAVDateTimeGetDayString(timespec.WeekDay)")
    NAVLog("sender, ' => Day Of Year: ', itoa(timespec.YearDay)")
    NAVLog("sender, ' => Hour: ', itoa(timespec.Hour)")
    NAVLog("sender, ' => Minute: ', itoa(timespec.Minute)")
    NAVLog("sender, ' => Second: ', itoa(timespec.Seconds)")
}


/**
 * @function NAVDateTimeGetMonthString
 * @public
 * @description Gets the full name of a month.
 *
 * @param {integer} month - Month number (1-12)
 *
 * @returns {char[]} Full month name (e.g., "January")
 *
 * @example
 * stack_var char monthName[20]
 * monthName = NAVDateTimeGetMonthString(3)  // Returns "March"
 */
define_function char[10] NAVDateTimeGetMonthString(integer month) {
    switch (month) {
        case 1:  return 'January'
        case 2:  return 'February'
        case 3:  return 'March'
        case 4:  return 'April'
        case 5:  return 'May'
        case 6:  return 'June'
        case 7:  return 'July'
        case 8:  return 'August'
        case 9:  return 'September'
        case 10: return 'October'
        case 11: return 'November'
        case 12: return 'December'
    }

    return ''
}


/**
 * @function NAVDateTimeGetShortMonthString
 * @public
 * @description Gets the abbreviated name of a month (first 3 characters).
 *
 * @param {integer} month - Month number (1-12)
 *
 * @returns {char[]} Abbreviated month name (e.g., "Jan")
 *
 * @example
 * stack_var char shortMonth[4]
 * shortMonth = NAVDateTimeGetShortMonthString(3)  // Returns "Mar"
 */
define_function char[3] NAVDateTimeGetShortMonthString(integer month) {
    return left_string(NAVDateTimeGetMonthString(month), 3)
}


/**
 * @function NAVDateTimeGetDayString
 * @public
 * @description Gets the full name of a day of the week.
 *
 * @param {integer} day - Day number (1-7, where 1 is Sunday)
 *
 * @returns {char[]} Full day name (e.g., "Monday")
 *
 * @example
 * stack_var char dayName[20]
 * dayName = NAVDateTimeGetDayString(2)  // Returns "Monday"
 */
define_function char[10] NAVDateTimeGetDayString(integer day) {
    switch (day) {
        case 1: return 'Sunday'
        case 2: return 'Monday'
        case 3: return 'Tuesday'
        case 4: return 'Wednesday'
        case 5: return 'Thursday'
        case 6: return 'Friday'
        case 7: return 'Saturday'
    }

    return ''
}


/**
 * @function NAVDateTimeGetShortDayString
 * @public
 * @description Gets the abbreviated name of a day of the week (first 3 characters).
 *
 * @param {integer} day - Day number (1-7, where 1 is Sunday)
 *
 * @returns {char[]} Abbreviated day name (e.g., "Mon")
 *
 * @example
 * stack_var char shortDay[4]
 * shortDay = NAVDateTimeGetShortDayString(2)  // Returns "Mon"
 */
define_function char[3] NAVDateTimeGetShortDayString(integer day) {
    return left_string(NAVDateTimeGetDayString(day), 3)
}


/**
 * @function NAVDateTimeGetDaysInMonth
 * @public
 * @description Gets the number of days in the specified month.
 *
 * @param {integer} month - Month number (1-12)
 * @param {integer} year - Full year (e.g., 2024) to check for leap year
 *
 * @returns {integer} Number of days in the month (28-31), or 0 if month is invalid
 *
 * @example
 * stack_var integer days
 * days = NAVDateTimeGetDaysInMonth(2, 2024)  // Returns 29 (leap year)
 * days = NAVDateTimeGetDaysInMonth(2, 2023)  // Returns 28 (non-leap year)
 * days = NAVDateTimeGetDaysInMonth(13, 2024) // Returns 0 (invalid month)
 *
 */
define_function integer NAVDateTimeGetDaysInMonth(integer month, integer year) {
    // Validate month range
    if (month < 1 || month > 12) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                __NAV_FOUNDATION_DATETIMEUTILS__,
                                'NAVDateTimeGetDaysInMonth',
                                'Invalid month value (must be 1-12)')
        return 0
    }

    // Validate year (must be non-zero)
    if (year < 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                __NAV_FOUNDATION_DATETIMEUTILS__,
                                'NAVDateTimeGetDaysInMonth',
                                'Invalid year value (year must be >= 1)')
        return 0
    }

    switch (month) {
        case 1:  return 31  // January
        case 2:  {  // February
            if (NAVDateTimeIsLeapYear(year)) {
        return 29
    }

            return 28
        }
        case 3:  return 31  // March
        case 4:  return 30  // April
        case 5:  return 31  // May
        case 6:  return 30  // June
        case 7:  return 31  // July
        case 8:  return 31  // August
        case 9:  return 30  // September
        case 10: return 31  // October
        case 11: return 30  // November
        case 12: return 31  // December
    }

    // Should never reach here due to validation above
    return 0
}


/**
 * @function NAVDateTimeGetTimestampNow
 * @public
 * @description Gets a timestamp string for the current date and time using the default format.
 *
 * @returns {char[]} Formatted timestamp string
 *
 * @example
 * stack_var char timestamp[50]
 * timestamp = NAVDateTimeGetTimestampNow()  // Returns timestamp in default format
 *
 * @see NAVDateTimeGetTimestamp
 */
define_function char[NAV_MAX_BUFFER] NAVDateTimeGetTimestampNow() {
    stack_var _NAVTimespec timespec

    NAVDateTimeGetTimespecNow(timespec)

    return NAVDateTimeGetTimestamp(timespec)
}


/**
 * @function NAVDateTimeGetTimestampNowFormat
 * @public
 * @description Gets a timestamp string for the current date and time using the specified format.
 *
 * @param {integer} timestampFormat - Format constant (e.g., NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601)
 *
 * @returns {char[]} Formatted timestamp string
 *
 * @example
 * stack_var char timestamp[50]
 * timestamp = NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339)
 *
 * @see NAVDateTimeGetTimestampFormat
 */
define_function char[NAV_MAX_BUFFER] NAVDateTimeGetTimestampNowFormat(integer timestampFormat) {
    stack_var _NAVTimespec timespec

    NAVDateTimeGetTimespecNow(timespec)

    return NAVDateTimeGetTimestampFormat(timespec, timestampFormat)
}


/**
 * @function NAVDateTimeGetTimestampFromEpoch
 * @public
 * @description Converts a Unix epoch timestamp to a formatted timestamp string using the default format.
 *
 * @param {long} epoch - Unix timestamp in seconds since Jan 1, 1970
 *
 * @returns {char[]} Formatted timestamp string
 *
 * @example
 * stack_var char timestamp[50]
 * timestamp = NAVDateTimeGetTimestampFromEpoch(1672531200)  // Jan 1, 2023 00:00:00 UTC
 */
define_function char[NAV_MAX_BUFFER] NAVDateTimeGetTimestampFromEpoch(long epoch) {
    stack_var _NAVTimespec timespec

    NAVDateTimeEpochToTimespec(epoch, timespec)

    return NAVDateTimeGetTimestamp(timespec)
}


/**
 * @function NAVDateTimeFormatOffset
 * @private
 * @description Formats a GMT offset in minutes to a timezone string.
 *
 * @param {sinteger} offsetMinutes - GMT offset in minutes (positive for east, negative for west)
 * @param {char} useColon - If true, format as +HH:MM, otherwise +HHMM
 *
 * @returns {char[]} Formatted timezone string (e.g., "+01:00" or "+0100")
 *
 * @example
 * stack_var char tz[10]
 * tz = NAVDateTimeFormatOffset(60, true)  // Returns "+01:00"
 * tz = NAVDateTimeFormatOffset(-300, false)  // Returns "-0500"
 */
define_function char[10] NAVDateTimeFormatOffset(sinteger offsetMinutes, char useColon) {
    stack_var char sign[1]
    stack_var sinteger hours
    stack_var sinteger minutes
    stack_var sinteger absOffset

    if (offsetMinutes >= 0) {
        sign = '+'
        absOffset = offsetMinutes
    }
    else {
        sign = '-'
        absOffset = -offsetMinutes
    }

    hours = absOffset / 60
    minutes = absOffset % 60

    if (useColon) {
        return "sign, format('%02d', hours), ':', format('%02d', minutes)"
    }
    else {
        return "sign, format('%02d', hours), format('%02d', minutes)"
    }
}


/**
 * @function NAVDateTimeGetTimestamp
 * @public
 * @description Gets a formatted timestamp string for the specified timespec using the default format.
 *
 * @param {_NAVTimespec} timespec - Timespec structure with date and time information
 *
 * @returns {char[]} Formatted timestamp string
 *
 * @example
 * stack_var _NAVTimespec time
 * stack_var char timestamp[50]
 *
 * NAVDateTimeGetTimespecNow(time)
 * timestamp = NAVDateTimeGetTimestamp(time)
 *
 * @see NAVDateTimeGetTimestampFormat
 */
define_function char[NAV_MAX_BUFFER] NAVDateTimeGetTimestamp(_NAVTimespec timespec) {
    return NAVDateTimeGetTimestampFormat(timespec, NAV_DATETIME_TIMESTAMP_FORMAT_DEFAULT)
}


/**
 * @function NAVDateTimeGetTimestampFormat
 * @public
 * @description Gets a formatted timestamp string for the specified timespec using the specified format.
 *
 * @param {_NAVTimespec} timespec - Timespec structure with date and time information
 * @param {integer} timestampFormat - Format constant (e.g., NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601)
 *
 * @returns {char[]} Formatted timestamp string
 *
 * @example
 * stack_var _NAVTimespec time
 * stack_var char timestamp[50]
 *
 * NAVDateTimeGetTimespecNow(time)
 * timestamp = NAVDateTimeGetTimestampFormat(time, NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339)
 */
define_function char[NAV_MAX_BUFFER] NAVDateTimeGetTimestampFormat(_NAVTimespec timespec, integer timestampFormat) {
    switch (timestampFormat) {
        case NAV_DATETIME_TIMESTAMP_FORMAT_UTC: {
            return "
                format('%02d', timespec.Month + 1),
                '/',
                format('%02d', timespec.MonthDay),
                '/',
                format('%04d', timespec.Year + 1900),
                ' @ ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                NAVDateTimeGetAmPm(timespec)
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_ATOM: {
            return "
                format('%04d', timespec.Year + 1900),
                '-',
                format('%02d', timespec.Month + 1),
                '-',
                format('%02d', timespec.MonthDay),
                'T',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                NAVDateTimeFormatOffset(timespec.GmtOffset, true)
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_COOKIE: {
            return "
                NAVDateTimeGetDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                '-',
                NAVDateTimeGetShortMonthString(timespec.Month + 1),
                '-',
                format('%04d', timespec.Year + 1900),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' GMT'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601: {
            return "
                format('%04d', timespec.Year + 1900),
                '-',
                format('%02d', timespec.Month + 1),
                '-',
                format('%02d', timespec.MonthDay),
                'T',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                NAVDateTimeFormatOffset(timespec.GmtOffset, false)
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC822: {
            return "
                NAVDateTimeGetShortDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                ' ',
                NAVDateTimeGetShortMonthString(timespec.Month + 1),
                ' ',
                right_string(format('%04d', timespec.Year + 1900), 2),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' ',
                NAVDateTimeFormatOffset(timespec.GmtOffset, false)
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC850: {
            return "
                NAVDateTimeGetDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                '-',
                NAVDateTimeGetShortMonthString(timespec.Month + 1),
                '-',
                right_string(format('%04d', timespec.Year + 1900), 2),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' GMT'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC1036: {
            return "
                NAVDateTimeGetDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                '-',
                NAVDateTimeGetShortMonthString(timespec.Month + 1),
                '-',
                right_string(format('%04d', timespec.Year + 1900), 2),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' ',
                NAVDateTimeFormatOffset(timespec.GmtOffset, false)
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC1123: {
            return "
                NAVDateTimeGetShortDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                ' ',
                NAVDateTimeGetShortMonthString(timespec.Month + 1),
                ' ',
                format('%04d', timespec.Year + 1900),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' ',
                NAVDateTimeFormatOffset(timespec.GmtOffset, false)
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC7231: {
            return "
                NAVDateTimeGetShortDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                ' ',
                NAVDateTimeGetShortMonthString(timespec.Month + 1),
                ' ',
                format('%04d', timespec.Year + 1900),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' GMT'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC2822: {
            return "
                NAVDateTimeGetShortDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                ' ',
                NAVDateTimeGetShortMonthString(timespec.Month + 1),
                ' ',
                format('%04d', timespec.Year + 1900),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' ',
                NAVDateTimeFormatOffset(timespec.GmtOffset, false)
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339: {
            return "
                format('%04d', timespec.Year + 1900),
                '-',
                format('%02d', timespec.Month + 1),
                '-',
                format('%02d', timespec.MonthDay),
                'T',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                NAVDateTimeFormatOffset(timespec.GmtOffset, true)
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339EXT: {
            return "
                format('%04d', timespec.Year + 1900),
                '-',
                format('%02d', timespec.Month + 1),
                '-',
                format('%02d', timespec.MonthDay),
                'T',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                '.000',
                NAVDateTimeFormatOffset(timespec.GmtOffset, true)
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RSS: {
            return "
                NAVDateTimeGetShortDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                ' ',
                NAVDateTimeGetShortMonthString(timespec.Month + 1),
                ' ',
                format('%04d', timespec.Year + 1900),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' ',
                NAVDateTimeFormatOffset(timespec.GmtOffset, false)
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_W3C: {
            return "
                format('%04d', timespec.Year + 1900),
                '-',
                format('%02d', timespec.Month + 1),
                '-',
                format('%02d', timespec.MonthDay),
                'T',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                NAVDateTimeFormatOffset(timespec.GmtOffset, true)
            "
        }
        default: {
            return NAVDateTimeGetTimestampFormat(timespec, NAV_DATETIME_TIMESTAMP_FORMAT_DEFAULT)
        }
    }
}


/**
 * @function NAVDateTimeGetAmPm
 * @public
 * @description Gets the AM/PM indicator for the specified time.
 *
 * @param {_NAVTimespec} timespec - Timespec structure with time information
 *
 * @returns {char[2]} "am" or "pm" string
 *
 * @example
 * stack_var _NAVTimespec time
 * stack_var char ampm[2]
 *
 * NAVDateTimeGetTimespecNow(time)
 * ampm = NAVDateTimeGetAmPm(time)
 */
define_function char[2] NAVDateTimeGetAmPm(_NAVTimespec timespec) {
    if (timespec.Hour < 12) {
        return 'am'
    } else {
        return 'pm'
    }
}


/**
 * @function NAVDateTimeSetClock
 * @public
 * @description Sets the system clock to the specified date and time.
 *
 * @param {char[]} date - Date string in MM/DD/YYYY format
 * @param {char[]} time - Time string in HH:MM:SS format
 *
 * @returns {void}
 *
 * @example
 * NAVDateTimeSetClock('01/01/2023', '12:00:00')
 *
 * @note Requires master control rights
 */
define_function NAVDateTimeSetClock(char date[], char time[]) {
    NAVCommand(0:1:0, "'CLOCK ', date, ' ', time")
}


/**
 * @function NAVDateTimeSetClockFromTimespec
 * @public
 * @description Sets the system clock using a timespec structure.
 *
 * @param {_NAVTimespec} timespec - Timespec structure with date and time information
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVTimespec time
 *
 * // Populate time with desired date and time
 * NAVDateTimeSetClockFromTimespec(time)
 *
 * @note Requires master control rights
 * @see NAVDateTimeSetClock
 */
define_function NAVDateTimeSetClockFromTimespec(_NAVTimespec timespec) {
    stack_var char date[NAV_MAX_CHARS]
    stack_var char time[NAV_MAX_CHARS]

    date = "format('%02d', timespec.Month), '/', format('%02d', timespec.MonthDay), '/', format('%04d', timespec.Year)"
    time = "format('%02d', timespec.Hour), ':', format('%02d', timespec.Minute), ':', format('%02d', timespec.Seconds)"

    NAVDateTimeSetClock(date, time)
}


/**
 * @function NAVDateTimeSetClockFromEpoch
 * @public
 * @description Sets the system clock using a Unix epoch timestamp.
 *
 * @param {long} epoch - Unix timestamp in seconds since Jan 1, 1970
 *
 * @returns {void}
 *
 * @example
 * NAVDateTimeSetClockFromEpoch(1672531200)  // Sets to Jan 1, 2023 00:00:00 UTC
 *
 * @note Requires master control rights
 * @see NAVDateTimeSetClock
 */
define_function NAVDateTimeSetClockFromEpoch(long epoch) {
    stack_var _NAVTimespec timespec

    NAVDateTimeEpochToTimespec(epoch, timespec)
    NAVDateTimeSetClockFromTimespec(timespec)
}


/**
 * @function NAVDateTimeGetDifference
 * @public
 * @description Calculates the time difference between two timespec structures.
 *
 * @param {_NAVTimespec} timespec1 - First timespec
 * @param {_NAVTimespec} timespec2 - Second timespec
 *
 * @returns {slong} Time difference in seconds (positive if timespec1 is later, negative if earlier)
 *
 * @example
 * stack_var _NAVTimespec time1
 * stack_var _NAVTimespec time2
 * stack_var slong seconds
 *
 * // Populate time1 and time2
 * seconds = NAVDateTimeGetDifference(time1, time2)
 *
 * @note The result is timespec1 - timespec2
 */
define_function slong NAVDateTimeGetDifference(_NAVTimespec timespec1, _NAVTimespec timespec2) {
    stack_var long epoch1
    stack_var long epoch2
    stack_var slong epochResult

    epoch1 = NAVDateTimeGetEpoch(timespec1)
    epoch2 = NAVDateTimeGetEpoch(timespec2)

    epochResult = type_cast(epoch1 - epoch2)

    return epochResult
}


/**
 * @function NAVDateTimeTimezonePrint
 * @public
 * @description Logs the current system timezone information to the debug log.
 *
 * @returns {void}
 *
 * @example
 * NAVDateTimeTimezonePrint()
 */
define_function NAVDateTimeTimezonePrint() {
    NAVLog("'Timezone => ', clkmgr_get_timezone()")
}


/**
 * @function NAVDateTimeClockSourcePrint
 * @public
 * @description Logs the current system clock source information to the debug log.
 *
 * @returns {void}
 *
 * @example
 * NAVDateTimeClockSourcePrint()
 */
define_function NAVDateTimeClockSourcePrint() {
    NAVLog("'Is Network Sourced => ', itoa(clkmgr_is_network_sourced())")
    NAVLog("'Clock Resync Period => ', itoa(clkmgr_get_resync_period())")
}


/**
 * @function NAVDateTimeDaylightSavingsInfoPrint
 * @public
 * @description Logs the current system DST settings to the debug log.
 *
 * @returns {void}
 *
 * @example
 * NAVDateTimeDaylightSavingsInfoPrint()
 */
define_function NAVDateTimeDaylightSavingsInfoPrint() {
    stack_var clkmgr_timeoffset_struct offset
    stack_var slong result

    result = clkmgr_get_daylightsavings_offset(offset)

    if (result < 0) {
        NAVLog("'Daylight Savings Time Offset => Failed to get daylight savings time offset'")
        return
    }

    NAVLog("'Daylight Savings Time Offset => Hours :: ', itoa(offset.hours)")
    NAVLog("'Daylight Savings Time Offset => Minutes :: ', itoa(offset.minutes)")
    NAVLog("'Daylight Savings Time Offset => Seconds :: ', itoa(offset.seconds)")

    NAVLog("'Daylight Savings Start Rule => ', clkmgr_get_start_daylightsavings_rule()")
    NAVLog("'Daylight Savings End Rule => ', clkmgr_get_end_daylightsavings_rule()")

    NAVLog("'Daylight Savings Is On => ', itoa(clkmgr_is_daylightsavings_on())")
}


/**
 * @function NAVDateTimeActiveTimeServerPrint
 * @public
 * @description Logs information about the active time server to the debug log.
 *
 * @returns {void}
 *
 * @example
 * NAVDateTimeActiveTimeServerPrint()
 */
define_function NAVDateTimeActiveTimeServerPrint() {
    stack_var clkmgr_timeserver_struct server
    stack_var slong result

    result = clkmgr_get_active_timeserver(server)

    if (result < 0) {
        NAVLog("'Active Time Server => Failed to get active time server'")
        return
    }

    NAVLog("'Active Time Server => Is Selected :: ', itoa(server.is_selected)")
    NAVLog("'Active Time Server => Is User Defined :: ', itoa(server.is_user_defined)")
    NAVLog("'Active Time Server => IP Address :: ', server.ip_address_string")
    NAVLog("'Active Time Server => URL :: ', server.url_string")
    NAVLog("'Active Time Server => Location :: ', server.location_string")
}


/**
 * @function NAVDateTimeTimeServersPrint
 * @public
 * @description Logs information about all available time servers to the debug log.
 *
 * @returns {void}
 *
 * @example
 * NAVDateTimeTimeServersPrint()
 */
define_function NAVDateTimeTimeServersPrint() {
    stack_var clkmgr_timeserver_struct servers[20]
    stack_var slong result
    stack_var long count
    stack_var integer x

    result = NAVGetTimeServers(servers)

    if (result < 0) {
        NAVLog("'Time Server => Failed to get time servers'")
        return
    }

    count = type_cast(result)

    if (count <= 0) {
        NAVLog("'Time Server => No time servers found'")
        return
    }

    NAVLog("'Time Server => Count :: ', itoa(count)")

    for (x = 1; x <= count; x++) {
        NAVLog("'Time Server => Is Selected :: ', itoa(servers[x].is_selected)")
        NAVLog("'Time Server => Is User Defined :: ', itoa(servers[x].is_user_defined)")
        NAVLog("'Time Server => IP Address :: ', servers[x].ip_address_string")
        NAVLog("'Time Server => URL :: ', servers[x].url_string")
        NAVLog("'Time Server => Location :: ', servers[x].location_string")
    }
}


/**
 * @function NAVDateTimeTimestampsPrint
 * @public
 * @description Logs the current time in all supported timestamp formats to the debug log.
 *
 * @returns {void}
 *
 * @example
 * NAVDateTimeTimestampsPrint()
 */
define_function NAVDateTimeTimestampsPrint() {
    NAVLog("'Timestamp UTC => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_UTC)")
    NAVLog("'Timestamp Atom => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_ATOM)")
    NAVLog("'Timestamp Cookie => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_COOKIE)")
    NAVLog("'Timestamp ISO8601 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601)")
    NAVLog("'Timestamp RFC822 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC822)")
    NAVLog("'Timestamp RFC850 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC850)")
    NAVLog("'Timestamp RFC1036 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC1036)")
    NAVLog("'Timestamp RFC1123 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC1123)")
    NAVLog("'Timestamp RFC7231 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC7231)")
    NAVLog("'Timestamp RFC2822 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC2822)")
    NAVLog("'Timestamp RFC3339 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339)")
    NAVLog("'Timestamp RFC3339EXT => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339EXT)")
    NAVLog("'Timestamp RSS => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RSS)")
    NAVLog("'Timestamp W3C => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_W3C)")
}


/**
 * @function NAVGetTimeServers
 * @public
 * @description Retrieves the list of time servers configured on the system.
 *
 * @param {clkmgr_timeserver_struct[]} servers - Array to store the time server information
 *
 * @returns {slong} Number of time servers retrieved
 *
 * @example
 * stack_var clkmgr_timeserver_struct servers[20]
 * stack_var slong count
 *
 * count = NAVGetTimeServers(servers)
 */
define_function slong NAVGetTimeServers(clkmgr_timeserver_struct servers[]) {
    stack_var slong result

    result = clkmgr_get_timeservers(servers)

    if (result > 0) {
        set_length_array(servers, type_cast(result))
    }
    else {
        set_length_array(servers, 0)
    }

    return result
}


/**
 * @function NAVFindTimeServer
 * @public
 * @description Searches for a time server by IP address or hostname in the provided array.
 *
 * @param {clkmgr_timeserver_struct[]} servers - The array of time servers to search.
 * @param {char[]} ip - The IP address of the time server to find.
 * @param {char[]} hostname - The hostname of the time server to find.
 *
 * @returns {integer} The index of the found time server, or 0 if not found.
 */
define_function integer NAVFindTimeServer(clkmgr_timeserver_struct servers[], char ip[], char hostname[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(servers)

    if (!length) {
        return 0
    }

    for (x = 1; x <= length; x++) {
        if (servers[x].ip_address_string == ip || servers[x].url_string == hostname) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVSetupNetworkTime
 * @public
 * @description Configures the system to use network time with the specified time server.
 *
 * @param {_NAVTimeServer} timeserver - Time server configuration structure.
 *                                       If Ip, Hostname, or Description fields are empty,
 *                                       default values will be used (Windows time server).
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVTimeServer server
 * server.Ip = '132.163.97.2'
 * server.Hostname = 'time-a.nist.gov'
 * server.Description = 'NIST Internet Time Service'
 * NAVSetupNetworkTime(server)
 *
 * @example
 * // Use with default values
 * stack_var _NAVTimeServer server
 * NAVSetupNetworkTime(server)  // Uses Windows time server defaults
 *
 * @note Sets up NTP synchronization, timezone (UTC+00:00), DST rules (Europe/London)
 * @note Default timeserver: 51.145.123.29 (time.windows.com)
 * @note Requires master control rights
 */
define_function NAVSetupNetworkTime(_NAVTimeServer timeserver) {
    stack_var clkmgr_timeoffset_struct offset
    stack_var clkmgr_timeserver_struct servers[20]

    NAVGetTimeServers(servers)

    offset.hours = 1
    offset.minutes = 0
    offset.seconds = 0

    clkmgr_set_timezone('UTC+00:00')
    clkmgr_set_clk_source(CLKMGR_MODE_NETWORK)
    clkmgr_set_resync_period(5)
    clkmgr_set_daylightsavings_mode(true)
    clkmgr_set_daylightsavings_offset(offset)
    clkmgr_set_start_daylightsavings_rule('occurrence:5,1,3,02:00:00')
    clkmgr_set_end_daylightsavings_rule('occurrence:5,1,10,02:00:00')

    if (timeserver.Ip == '') {
        timeserver.Ip = '51.145.123.29'
    }

    if (timeserver.Hostname == '') {
        timeserver.Hostname = 'time.windows.com'
    }

    if (timeserver.Description == '') {
        timeserver.Description = 'Windows Timeserver'
    }

    // Check if the timeserver is already in the list
    // Seems to cause issues if the timeserver already exists
    if (!NAVFindTimeServer(servers, timeserver.Ip, timeserver.Hostname)) {
        clkmgr_add_userdefined_timeserver(timeserver.Ip, timeserver.Hostname, timeserver.Description)
        clkmgr_set_active_timeserver(timeserver.Ip)
    }
}


#END_IF // __NAV_FOUNDATION_DATETIMEUTILS__
