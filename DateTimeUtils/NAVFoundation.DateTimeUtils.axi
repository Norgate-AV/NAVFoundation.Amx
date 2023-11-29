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


define_function char NAVDateTimeGetTimespecNow(_NAVTimespec timespec) {
    return NAVDateTimeGetTimespec(timespec, ldate, time)
}


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

    // timespec.IsDst = NAVDateTimeIsDst(timespec)
}


DEFINE_CONSTANT

constant integer NAV_DATETIME_DST_START_MONTH = 3
constant integer NAV_DATETIME_DST_START_DAY = 8
constant integer NAV_DATETIME_DST_START_HOUR = 2
constant integer NAV_DATETIME_DST_START_MINUTE = 0

constant integer NAV_DATETIME_DST_END_MONTH = 11
constant integer NAV_DATETIME_DST_END_DAY = 1
constant integer NAV_DATETIME_DST_END_HOUR = 2
constant integer NAV_DATETIME_DST_END_MINUTE = 0

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
    dstStartDay = NAV_DATETIME_DST_START_DAY
    dstStartHour = NAV_DATETIME_DST_START_HOUR
    dstStartMinute = NAV_DATETIME_DST_START_MINUTE

    dstEndMonth = NAV_DATETIME_DST_END_MONTH
    dstEndDay = NAV_DATETIME_DST_END_DAY
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


define_function char NAVDateTimeIsLeapYear(integer year) {
    return (year % 400 == 0) || (year % 100 == 0) || (year % 4 == 0)
}


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


define_function integer NAVDateTimePast(char date[], char time[]) {
    // stack_var char dateElements[3][4]
    // stack_var char timeElements[3][2]

    // stack_var char todDate[NAV_MAX_CHARS]
    // stack_var long todDate
    // stack_var char todTime[NAV_MAX_CHARS]
    // stack_var long todTime

    // stack_var char currentTodDate[NAV_MAX_CHARS]
    // stack_var long currentTodDate
    // stack_var char currentTodTime[NAV_MAX_CHARS]
    // stack_var long currentTodTime

    // stack_var integer day
    // stack_var integer month
    // stack_var integer year

    // stack_var integer hour
    // stack_var integer minutes
    // stack_var integer seconds

    // stack_var integer datePast
    // stack_var integer timePast

    // NAVSplitString(date, '/', dateElements)
    // NAVSplitString(time, ':', timeElements)

    // day = atoi(dateElements[1])
    // month = atoi(dateElements[2])
    // year = atoi(dateElements[3])

    // hour = atoi(timeElements[1])
    // minutes = atoi(timeElements[2])
    // seconds = atoi(timeElements[3])

    // makestring(todDate, "%04u%02u%02u", year, month, day)
    // makestring(todTime, "%02u%02u%02u", hour, minutes, seconds)

    // todDate = atoi(todDate)
    // todTime = atoi(todTime)

    // currentTodDate = atoi(NAVDateTimeGetCurrentTodDate())
    // currentTodTime = atoi(NAVDateTimeGetCurrentTodTime())

    // datePast = (currentTodDate > todDate)
    // timePast = (currentTodTime > todTime)

    // return (datePast || timePast)
}


define_function NAVDateTimeEpochToTimespec(long epoch, _NAVTimespec timespec) {
    timespec.Year = type_cast((epoch / NAV_DATETIME_SECONDS_IN_1_YEAR) + 1970)
    timespec.Month = type_cast(((epoch % NAV_DATETIME_SECONDS_IN_1_YEAR_AVG) / NAV_DATETIME_SECONDS_IN_1_MONTH_AVG)) + 1
    timespec.MonthDay = type_cast((((epoch % NAV_DATETIME_SECONDS_IN_1_YEAR_AVG) % NAV_DATETIME_SECONDS_IN_1_MONTH_AVG) / NAV_DATETIME_SECONDS_IN_1_DAY)) + 1
    timespec.WeekDay = type_cast(((epoch / NAV_DATETIME_SECONDS_IN_1_DAY) + 4) % 7) + 1
    timespec.YearDay = type_cast((epoch % NAV_DATETIME_SECONDS_IN_1_YEAR_AVG) / NAV_DATETIME_SECONDS_IN_1_DAY) + 1
    timespec.Hour = type_cast((epoch % NAV_DATETIME_SECONDS_IN_1_DAY) / NAV_DATETIME_SECONDS_IN_1_HOUR)
    timespec.Minute = type_cast((epoch % NAV_DATETIME_SECONDS_IN_1_HOUR) / NAV_DATETIME_SECONDS_IN_1_MINUTE)
    timespec.Seconds = type_cast(epoch % NAV_DATETIME_SECONDS_IN_1_MINUTE)
}


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


define_function char[NAV_MAX_CHARS] NAVDateTimeGetMonthString(integer month) {
    return NAV_DATETIME_MONTH[month]
}


define_function char[NAV_MAX_CHARS] NAVDateTimeGetShortMonthString(integer month) {
    return left_string(NAVDateTimeGetMonthString(month), 3)
}


define_function char[NAV_MAX_CHARS] NAVDateTimeGetDayString(integer day) {
    return NAV_DATETIME_DAY[day]
}


define_function char[NAV_MAX_CHARS] NAVDateTimeGetShortDayString(integer day) {
    return left_string(NAVDateTimeGetDayString(day), 3)
}


define_function integer NAVDateTimeGetDaysInMonth(integer month) {
    return NAV_DAYS_IN_MONTH[month]
}


define_function char[NAV_MAX_BUFFER] NAVDateTimeGetTimestampNow() {
    stack_var _NAVTimespec timespec

    NAVDateTimeGetTimespecNow(timespec)

    return NAVDateTimeGetTimestamp(timespec, NAV_DATETIME_TIMESTAMP_FORMAT_DEFAULT)
}


define_function char[NAV_MAX_BUFFER] NAVDateTimeGetTimestampFromEpoch(long epoch) {
    stack_var _NAVTimespec timespec

    NAVDateTimeEpochToTimespec(epoch, timespec)

    return NAVDateTimeGetTimestamp(timespec, NAV_DATETIME_TIMESTAMP_FORMAT_DEFAULT)
}


define_function char[NAV_MAX_BUFFER] NAVDateTimeGetTimestamp(_NAVTimespec timespec, integer timestampFormat) {
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
            return NAVDateTimeGetTimestamp(timespec, NAV_DATETIME_TIMESTAMP_FORMAT_DEFAULT)
        }
    }
}


define_function char[2] NAVDateTimeGetAmPm(_NAVTimespec timespec) {
    if (timespec.Hour < 12) {
        return 'am'
    } else {
        return 'pm'
    }
}


define_function NAVDateTimeSetClock(char date[], char time[]) {
    NAVCommand(dvNAVMaster, "'CLOCK ', date, ' ', time")
}


define_function NAVDateTimeSetClockFromTimespec(_NAVTimespec timespec) {
    stack_var char date[NAV_MAX_CHARS]
    stack_var char time[NAV_MAX_CHARS]

    date = "format('%02d', timespec.Month), '/', format('%02d', timespec.MonthDay), '/', format('%04d', timespec.Year)"
    time = "format('%02d', timespec.Hour), ':', format('%02d', timespec.Minute), ':', format('%02d', timespec.Seconds)"

    NAVDateTimeSetClock(date, time)
}


define_function NAVDateTimeSetClockFromEpoch(long epoch) {
    stack_var _NAVTimespec timespec

    NAVDateTimeEpochToTimespec(epoch, timespec)
    NAVDateTimeSetClockFromTimespec(timespec)
}


define_function long NAVDateTimeGetDifference(_NAVTimespec timespec1, _NAVTimespec timespec2, _NAVTimespec timespecResult) {
    stack_var long epoch1
    stack_var long epoch2
    stack_var long epochResult

    epoch1 = NAVDateTimeGetEpoch(timespec1)
    epoch2 = NAVDateTimeGetEpoch(timespec2)

    epochResult = epoch1 - epoch2

    NAVDateTimeEpochToTimespec(epochResult, timespecResult)
}


#END_IF // __NAV_FOUNDATION_DATETIMEUTILS__
