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
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DATETIMEUTILS__,
                                    'NAVDateTimeGetTimespec',
                                    'Failed to get seconds from time')

        return false
    }

    minutes = time_to_minute(time)
    if (minutes < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DATETIMEUTILS__,
                                    'NAVDateTimeGetTimespec',
                                    'Failed to get minutes from time')

        return false
    }

    hours = time_to_hour(time)
    if (hours < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DATETIMEUTILS__,
                                    'NAVDateTimeGetTimespec',
                                    'Failed to get hours from time')

        return false
    }

    day = date_to_day(date)
    if (day < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DATETIMEUTILS__,
                                    'NAVDateTimeGetTimespec',
                                    'Failed to get day from date')

        return false
    }

    month = date_to_month(date)
    if (month < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DATETIMEUTILS__,
                                    'NAVDateTimeGetTimespec',
                                    'Failed to get month from date')

        return false
    }

    year = date_to_year(date)
    if (year < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DATETIMEUTILS__,
                                    'NAVDateTimeGetTimespec',
                                    'Failed to get year from date')

        return false
    }

    dayOfWeek = day_of_week(date)
    if (dayOfWeek < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DATETIMEUTILS__,
                                    'NAVDateTimeGetTimespec',
                                    'Failed to get day of week from date')

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
    stack_var integer year
    stack_var integer month
    stack_var integer day
    stack_var integer hour
    stack_var integer minute
    stack_var integer second

    stack_var integer dayOfWeek
    stack_var integer dayOfYear

    stack_var integer dstStartMonth
    stack_var integer dstStartDay
    stack_var integer dstStartHour
    stack_var integer dstStartMinute

    stack_var integer dstEndMonth
    stack_var integer dstEndDay
    stack_var integer dstEndHour
    stack_var integer dstEndMinute

    stack_var integer dstStartDayOfYear
    stack_var integer dstEndDayOfYear

    stack_var integer dstStartEpoch
    stack_var integer dstEndEpoch

    stack_var integer currentEpoch

    year = timespec.Year
    month = timespec.Month
    day = timespec.MonthDay
    hour = timespec.Hour
    minute = timespec.Minute
    second = timespec.Seconds

    dayOfWeek = timespec.WeekDay
    dayOfYear = timespec.YearDay

    dstStartMonth = NAV_DATETIME_DST_START_MONTH
    dstStartDay = NAVDateTimeGetLastSundayInMonth(year, dstStartMonth)
    dstStartHour = NAV_DATETIME_DST_START_HOUR
    dstStartMinute = NAV_DATETIME_DST_START_MINUTE

    dstEndMonth = NAV_DATETIME_DST_END_MONTH
    dstEndDay = NAVDateTimeGetLastSundayInMonth(year, dstEndMonth)
    dstEndHour = NAV_DATETIME_DST_END_HOUR
    dstEndMinute = NAV_DATETIME_DST_END_MINUTE

    // dstStartDayOfYear = NAVDateTimeGetYearDay(year, dstStartMonth, dstStartDay)
    // dstEndDayOfYear = NAVDateTimeGetYearDay(year, dstEndMonth, dstEndDay)

    // dstStartEpoch = NAVDateTimeGetEpoch(year, dstStartMonth, dstStartDay, dstStartHour, dstStartMinute, 0)
    // dstEndEpoch = NAVDateTimeGetEpoch(year, dstEndMonth, dstEndDay, dstEndHour, dstEndMinute, 0)

    // currentEpoch = NAVDateTimeGetEpoch(year, month, day, hour, minute, second)

    // if (currentEpoch >= dstStartEpoch && currentEpoch <= dstEndEpoch) {
    //     return true
    // }

    return false
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
    timespec.Year = type_cast((epoch / NAV_DATETIME_SECONDS_IN_1_YEAR_AVG) + 1970)
    timespec.Month = type_cast(((epoch % NAV_DATETIME_SECONDS_IN_1_YEAR_AVG) / NAV_DATETIME_SECONDS_IN_1_MONTH_AVG)) + 1
    timespec.MonthDay = type_cast((((epoch % NAV_DATETIME_SECONDS_IN_1_YEAR_AVG) % NAV_DATETIME_SECONDS_IN_1_MONTH_AVG) / NAV_DATETIME_SECONDS_IN_1_DAY)) + 1
    timespec.WeekDay = type_cast(((epoch / NAV_DATETIME_SECONDS_IN_1_DAY) + 4) % 7) + 1
    timespec.YearDay = type_cast((epoch % NAV_DATETIME_SECONDS_IN_1_YEAR_AVG) / NAV_DATETIME_SECONDS_IN_1_DAY) + 1
    timespec.Hour = type_cast((epoch % NAV_DATETIME_SECONDS_IN_1_DAY) / NAV_DATETIME_SECONDS_IN_1_HOUR)
    timespec.Minute = type_cast((epoch % NAV_DATETIME_SECONDS_IN_1_HOUR) / NAV_DATETIME_SECONDS_IN_1_MINUTE)
    timespec.Seconds = type_cast(epoch % NAV_DATETIME_SECONDS_IN_1_MINUTE)
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

    result = result + timespec.Seconds
    result = result + (timespec.Minute * NAV_DATETIME_SECONDS_IN_1_MINUTE)
    result = result + (timespec.Hour * NAV_DATETIME_SECONDS_IN_1_HOUR)
    result = result + ((timespec.YearDay - 1) * NAV_DATETIME_SECONDS_IN_1_DAY)
    result = result + (((timespec.Year - 1900) - 70) * (NAV_DATETIME_SECONDS_IN_1_YEAR))
    result = result + ((((timespec.Year - 1900) - 69) / 4) * NAV_DATETIME_SECONDS_IN_1_DAY)
    result = result - ((((timespec.Year - 1900) - 1) / 100) * NAV_DATETIME_SECONDS_IN_1_DAY)
    result = result + ((((timespec.Year - 1900) + 299) / 400) * NAV_DATETIME_SECONDS_IN_1_DAY)

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
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "sender, ' => Year: ', NAVStringSurround(itoa(timespec.Year), '[', ']')")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "sender, ' => Month: ', NAVStringSurround(itoa(timespec.Month), '[', ']'), '-', NAVStringSurround(NAVDateTimeGetMonthString(timespec.Month), '[', ']')")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "sender, ' => Day: ', NAVStringSurround(itoa(timespec.MonthDay), '[', ']')")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "sender, ' => Day Of Week: ', NAVStringSurround(itoa(timespec.WeekDay), '[', ']'), '-', NAVStringSurround(NAVDateTimeGetDayString(timespec.WeekDay), '[', ']')")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "sender, ' => Day Of Year: ', NAVStringSurround(itoa(timespec.YearDay), '[', ']')")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "sender, ' => Hour: ', NAVStringSurround(itoa(timespec.Hour), '[', ']')")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "sender, ' => Minute: ', NAVStringSurround(itoa(timespec.Minute), '[', ']')")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "sender, ' => Second: ', NAVStringSurround(itoa(timespec.Seconds), '[', ']')")
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
define_function char[NAV_MAX_CHARS] NAVDateTimeGetMonthString(integer month) {
    return NAV_DATETIME_MONTH[month]
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
define_function char[NAV_MAX_CHARS] NAVDateTimeGetShortMonthString(integer month) {
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
define_function char[NAV_MAX_CHARS] NAVDateTimeGetDayString(integer day) {
    return NAV_DATETIME_DAY[day]
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
define_function char[NAV_MAX_CHARS] NAVDateTimeGetShortDayString(integer day) {
    return left_string(NAVDateTimeGetDayString(day), 3)
}


/**
 * @function NAVDateTimeGetDaysInMonth
 * @public
 * @description Gets the number of days in the specified month.
 *
 * @param {integer} month - Month number (1-12)
 *
 * @returns {integer} Number of days in the month (28-31)
 *
 * @example
 * stack_var integer days
 * days = NAVDateTimeGetDaysInMonth(2)  // Returns 28 (or 29 in leap years)
 *
 * @note Does not automatically adjust for leap years, use in conjunction with NAVDateTimeIsLeapYear
 */
define_function integer NAVDateTimeGetDaysInMonth(integer month) {
    return NAV_DAYS_IN_MONTH[month]
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
                format('%02d', timespec.Month),
                '/',
                format('%02d', timespec.MonthDay),
                '/',
                format('%04d', timespec.Year),
                ' @ ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                NAVDateTimeGetAmPm(timespec)
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_ATOM: {
            return "
                format('%04d', timespec.Year),
                '-',
                format('%02d', timespec.Month),
                '-',
                format('%02d', timespec.MonthDay),
                'T',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                '+00:00'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_COOKIE: {
            return "
                NAVDateTimeGetDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                '-',
                NAVDateTimeGetShortMonthString(timespec.Month),
                '-',
                format('%04d', timespec.Year),
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
                format('%04d', timespec.Year),
                '-',
                format('%02d', timespec.Month),
                '-',
                format('%02d', timespec.MonthDay),
                'T',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                '+0000'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC822: {
            return "
                NAVDateTimeGetShortDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                ' ',
                NAVDateTimeGetShortMonthString(timespec.Month),
                ' ',
                right_string(format('%04d', timespec.Year), 2),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' +0000'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC850: {
            return "
                NAVDateTimeGetDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                '-',
                NAVDateTimeGetShortMonthString(timespec.Month),
                '-',
                right_string(format('%04d', timespec.Year), 2),
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
                NAVDateTimeGetShortMonthString(timespec.Month),
                '-',
                right_string(format('%04d', timespec.Year), 2),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' +0000'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC1123: {
            return "
                NAVDateTimeGetShortDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                ' ',
                NAVDateTimeGetShortMonthString(timespec.Month),
                ' ',
                format('%04d', timespec.Year),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' +0000'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC7231: {
            return "
                NAVDateTimeGetShortDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                ' ',
                NAVDateTimeGetShortMonthString(timespec.Month),
                ' ',
                format('%04d', timespec.Year),
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
                NAVDateTimeGetShortMonthString(timespec.Month),
                ' ',
                format('%04d', timespec.Year),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' +0000'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339: {
            return "
                format('%04d', timespec.Year),
                '-',
                format('%02d', timespec.Month),
                '-',
                format('%02d', timespec.MonthDay),
                'T',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                '+00:00'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339EXT: {
            return "
                format('%04d', timespec.Year),
                '-',
                format('%02d', timespec.Month),
                '-',
                format('%02d', timespec.MonthDay),
                'T',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                '.000+00:00'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_RSS: {
            return "
                NAVDateTimeGetShortDayString(timespec.WeekDay),
                ', ',
                format('%02d', timespec.MonthDay),
                ' ',
                NAVDateTimeGetShortMonthString(timespec.Month),
                ' ',
                format('%04d', timespec.Year),
                ' ',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                ' +0000'
            "
        }
        case NAV_DATETIME_TIMESTAMP_FORMAT_W3C: {
            return "
                format('%04d', timespec.Year),
                '-',
                format('%02d', timespec.Month),
                '-',
                format('%02d', timespec.MonthDay),
                'T',
                format('%02d', timespec.Hour),
                ':',
                format('%02d', timespec.Minute),
                ':',
                format('%02d', timespec.Seconds),
                '+00:00'
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
    NAVCommand(dvNAVMaster, "'CLOCK ', date, ' ', time")
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
 * @param {_NAVTimespec} timespecResult - Result timespec (modified in-place)
 *
 * @returns {long} Time difference in seconds
 *
 * @example
 * stack_var _NAVTimespec time1
 * stack_var _NAVTimespec time2
 * stack_var _NAVTimespec diff
 * stack_var long seconds
 *
 * // Populate time1 and time2
 * seconds = NAVDateTimeGetDifference(time1, time2, diff)
 *
 * @note The result is timespec1 - timespec2
 */
define_function long NAVDateTimeGetDifference(_NAVTimespec timespec1, _NAVTimespec timespec2, _NAVTimespec timespecResult) {
    stack_var long epoch1
    stack_var long epoch2
    stack_var long epochResult

    epoch1 = NAVDateTimeGetEpoch(timespec1)
    epoch2 = NAVDateTimeGetEpoch(timespec2)

    epochResult = epoch1 - epoch2

    NAVDateTimeEpochToTimespec(epochResult, timespecResult)
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
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timezone => ', clkmgr_get_timezone()")
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
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Is Network Sourced => ', itoa(clkmgr_is_network_sourced())")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Clock Resync Period => ', itoa(clkmgr_get_resync_period())")
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
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Daylight Savings Time Offset => Failed to get daylight savings time offset'")
        return
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Daylight Savings Time Offset => Hours :: ', itoa(offset.hours)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Daylight Savings Time Offset => Minutes :: ', itoa(offset.minutes)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Daylight Savings Time Offset => Seconds :: ', itoa(offset.seconds)")

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Daylight Savings Start Rule => ', clkmgr_get_start_daylightsavings_rule()")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Daylight Savings End Rule => ', clkmgr_get_end_daylightsavings_rule()")

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Daylight Savings Is On => ', itoa(clkmgr_is_daylightsavings_on())")
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
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Active Time Server => Failed to get active time server'")
        return
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Active Time Server => Is Selected :: ', itoa(server.is_selected)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Active Time Server => Is User Defined :: ', itoa(server.is_user_defined)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Active Time Server => IP Address :: ', server.ip_address_string")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Active Time Server => URL :: ', server.url_string")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Active Time Server => Location :: ', server.location_string")
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

    result = clkmgr_get_timeservers(servers)

    if (result < 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Time Server => Failed to get time servers'")
        return
    }

    count = type_cast(result)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Time Server => Count :: ', itoa(count)")

    for (x = 1; x <= count; x++) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Time Server => Is Selected :: ', itoa(servers[x].is_selected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Time Server => Is User Defined :: ', itoa(servers[x].is_user_defined)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Time Server => IP Address :: ', servers[x].ip_address_string")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Time Server => URL :: ', servers[x].url_string")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Time Server => Location :: ', servers[x].location_string")
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
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp UTC => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_UTC)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp Atom => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_ATOM)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp Cookie => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_COOKIE)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp ISO8601 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp RFC822 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC822)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp RFC850 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC850)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp RFC1036 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC1036)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp RFC1123 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC1123)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp RFC7231 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC7231)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp RFC2822 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC2822)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp RFC3339 => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp RFC3339EXT => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339EXT)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp RSS => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RSS)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Timestamp W3C => ', NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_W3C)")
}


/**
 * @function NAVSetupNetworkTime
 * @public
 * @description Configures the system to use network time with predefined settings.
 *
 * @returns {void}
 *
 * @example
 * NAVSetupNetworkTime()
 *
 * @note Sets up NTP synchronization, timezone, DST rules, and uses the default timeserver
 * @note Requires master control rights
 */
define_function NAVSetupNetworkTime() {
    clkmgr_timeoffset_struct offset

    offset.hours = 1
    offset.minutes = 0
    offset.seconds = 0

    clkmgr_set_timezone('UTC+00:00')
    clkmgr_set_clk_source(CLKMGR_MODE_NETWORK)
    clkmgr_set_resync_period(5)
    clkmgr_add_userdefined_timeserver(timeserver.Ip, timeserver.Hostname, timeserver.Description)
    clkmgr_set_active_timeserver(timeserver.Ip)
    clkmgr_set_daylightsavings_mode(true)
    clkmgr_set_daylightsavings_offset(offset)
    clkmgr_set_start_daylightsavings_rule('occurrence:5,1,3,02:00:00')
    clkmgr_set_end_daylightsavings_rule('occurrence:5,1,10,02:00:00')
}


#END_IF // __NAV_FOUNDATION_DATETIMEUTILS__
