PROGRAM_NAME='NAVFoundation.DateTimeUtils'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2022 Norgate AV Solutions Ltd

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


DEFINE_CONSTANT

constant integer NAV_DAYS_IN_MONTH[12] = {
    31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
}


define_function integer NAVIsLeapYear(integer year) {
    return (year % 400 == 0) || (year % 100 == 0) || (year % 4 == 0)
}


define_function char[NAV_MAX_BUFFER] NAVGetNextDate() {
    stack_var integer x
    stack_var integer daysInMonth[12]

    stack_var integer thisDay
    stack_var integer thisMonth
    stack_var integer thisYear

    for (x = 1; x <= max_length_array(daysInMonth); x++) {
        daysInMonth[x] = NAV_DAYS_IN_MONTH[x]
    }

    thisDay = type_cast(date_to_day(ldate)) + 1
    thisMonth = type_cast(date_to_month(ldate))
    thisYear = type_cast(date_to_year(ldate))

    if (thisDay <= 0 || thisMonth <= 0 || thisYear <= 0) {
        NAVLog("'Error: NAVGetNextDate() - Failed to get the current date'")
        return ""
    }

    if ((thisMonth == 2) && (thisDay == 29)) {
        if (NAVIsLeapYear(thisYear)) {
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


define_function char[NAV_MAX_BUFFER] NAVDateTimeGetCurrentTodDate() {
    stack_var char result[NAV_MAX_CHARS]

    // makestring(result, "%04u%02u%02u", getyearnum(), getmonthnum(), getdatenum())

    return result
}


define_function char[NAV_MAX_BUFFER] NAVDateTimeGetCurrentTodTime() {
    stack_var char result[NAV_MAX_CHARS]

    // makestring(result, "%02u%02u%02u", gethournum(), getminutesnum(), getsecondsnum())

    return result
}


define_function char[NAV_MAX_BUFFER] NAVDateTimeGetCurrentTod() {
    stack_var char result[NAV_MAX_CHARS]

    // makestring(result, "%s%s", NAVDateTimeGetCurrentTodDate(), NAVDateTimeGetCurrentTodTime())

    return result
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

#END_IF // __NAV_FOUNDATION_DATETIMEUTILS__
