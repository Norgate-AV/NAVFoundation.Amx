PROGRAM_NAME='NAVFoundation.DateTime.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_DATETIMEUTILS_H__
#DEFINE __NAV_FOUNDATION_DATETIMEUTILS_H__ 'NAVFoundation.DateTimeUtils.h'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

constant long NAV_DATETIME_SECONDS_IN_1_MINUTE     = 60
constant long NAV_DATETIME_SECONDS_IN_1_HOUR       = 3600
constant long NAV_DATETIME_SECONDS_IN_1_DAY        = 86400
constant long NAV_DATETIME_SECONDS_IN_1_WEEK       = 604800
constant long NAV_DATETIME_SECONDS_IN_1_MONTH_AVG  = 2629743    // 30.44 days
constant long NAV_DATETIME_SECONDS_IN_1_YEAR       = 31536000   // 365 days
constant long NAV_DATETIME_SECONDS_IN_1_YEAR_AVG   = 31556926   // 365.24 days
constant long NAV_DATETIME_SECONDS_IN_1_LEAP_YEAR  = 31622400   // 366 days

constant integer NAV_DATETIME_DAY_SUNDAY           = 0
constant integer NAV_DATETIME_DAY_MONDAY           = 1
constant integer NAV_DATETIME_DAY_TUESDAY          = 2
constant integer NAV_DATETIME_DAY_WEDNESDAY        = 3
constant integer NAV_DATETIME_DAY_THURSDAY         = 4
constant integer NAV_DATETIME_DAY_FRIDAY           = 5
constant integer NAV_DATETIME_DAY_SATURDAY         = 6
constant char NAV_DATETIME_DAY[][NAV_MAX_CHARS] =   {
                                                        'Sunday',
                                                        'Monday',
                                                        'Tuesday',
                                                        'Wednesday',
                                                        'Thursday',
                                                        'Friday',
                                                        'Saturday'
                                                    }

constant integer NAV_DATETIME_MONTH_JANUARY        = 0
constant integer NAV_DATETIME_MONTH_FEBRUARY       = 1
constant integer NAV_DATETIME_MONTH_MARCH          = 2
constant integer NAV_DATETIME_MONTH_APRIL          = 3
constant integer NAV_DATETIME_MONTH_MAY            = 4
constant integer NAV_DATETIME_MONTH_JUNE           = 5
constant integer NAV_DATETIME_MONTH_JULY           = 6
constant integer NAV_DATETIME_MONTH_AUGUST         = 7
constant integer NAV_DATETIME_MONTH_SEPTEMBER      = 8
constant integer NAV_DATETIME_MONTH_OCTOBER        = 9
constant integer NAV_DATETIME_MONTH_NOVEMBER       = 10
constant integer NAV_DATETIME_MONTH_DECEMBER       = 11
constant char NAV_DATETIME_MONTH[][NAV_MAX_CHARS]   =   {
                                                            'January',
                                                            'February',
                                                            'March',
                                                            'April',
                                                            'May',
                                                            'June',
                                                            'July',
                                                            'August',
                                                            'September',
                                                            'October',
                                                            'November',
                                                            'December'
                                                        }

constant integer NAV_DAYS_IN_MONTH[12] = {
    31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
}


constant integer NAV_DATETIME_TIMESTAMP_FORMAT_UTC          = 1         // 11/23/2023 @ 09:30pm
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_ATOM         = 2         // 2023-11-23T21:30:00+00:00
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_COOKIE       = 3         // Friday, 23-Nov-2023 21:30:00 GMT
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601      = 4         // 2023-11-23T21:30:00+0000
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC822       = 5         // Thu, 23 Nov 23 21:30:00 +0000
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC850       = 6         // Thursday, 23-Nov-23 21:30:00 GMT
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC1036      = 7         // Thu, 23 Nov 23 21:30:00 +0000
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC1123      = 8         // Thu, 23 Nov 2023 21:30:00 +0000
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC7231      = 9         // Thu, 23 Nov 2023 21:30:00 GMT
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC2822      = 10        // Thu, 23 Nov 2023 21:30:00 +0000
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339      = 11        // 2023-11-23T21:30:00+00:00
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339EXT   = 12        // 2023-11-23T21:30:00.000+00:00
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RSS          = 13        // Thu, 23 Nov 2023 21:30:00 +0000
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_W3C          = 14        // 2023-11-23T21:30:00+00:00

constant integer NAV_DATETIME_TIMESTAMP_FORMAT_DEFAULT      = NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601



DEFINE_TYPE

struct _NAVTimespec {
    integer Year                        // Years since 1900
    integer Month                       // Months since January - [0,11]
    integer MonthDay                    // Day of the month - [1,31]

    integer Hour                        // Hours since midnight - [0,23]
    integer Minute                      // Minutes after the hour - [0,59]
    integer Seconds                     // Seconds after the minute - [0,59]

    integer WeekDay                     // Days since Sunday - [0,6]
    integer YearDay                     // Days since January 1 - [0,365]

    // char IsLeapYear

    char IsDst                       // Daylight Saving Time flag. The value is positive if DST is in effect, zero if not and negative if no information is available
    // integer GmtOffset
    // char  TimeZone[NAV_MAX_CHARS]
}


#END_IF // __NAV_FOUNDATION_DATETIME_H__
