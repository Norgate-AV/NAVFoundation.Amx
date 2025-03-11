PROGRAM_NAME='NAVFoundation.DateTime.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_DATETIMEUTILS_H__
#DEFINE __NAV_FOUNDATION_DATETIMEUTILS_H__ 'NAVFoundation.DateTimeUtils.h'


DEFINE_CONSTANT

/**
 * @constant NAV_DATETIME_SECONDS_IN_1_MINUTE
 * @description Number of seconds in one minute
 */
constant long NAV_DATETIME_SECONDS_IN_1_MINUTE     = 60

/**
 * @constant NAV_DATETIME_SECONDS_IN_1_HOUR
 * @description Number of seconds in one hour
 */
constant long NAV_DATETIME_SECONDS_IN_1_HOUR       = 3600

/**
 * @constant NAV_DATETIME_SECONDS_IN_1_DAY
 * @description Number of seconds in one day
 */
constant long NAV_DATETIME_SECONDS_IN_1_DAY        = 86400

/**
 * @constant NAV_DATETIME_SECONDS_IN_1_WEEK
 * @description Number of seconds in one week
 */
constant long NAV_DATETIME_SECONDS_IN_1_WEEK       = 604800

/**
 * @constant NAV_DATETIME_SECONDS_IN_1_MONTH_AVG
 * @description Average number of seconds in one month (30.44 days)
 */
constant long NAV_DATETIME_SECONDS_IN_1_MONTH_AVG  = 2629743    // 30.44 days

/**
 * @constant NAV_DATETIME_SECONDS_IN_1_YEAR
 * @description Number of seconds in one year (365 days)
 */
constant long NAV_DATETIME_SECONDS_IN_1_YEAR       = 31536000   // 365 days

/**
 * @constant NAV_DATETIME_SECONDS_IN_1_YEAR_AVG
 * @description Average number of seconds in one year (365.24 days)
 */
constant long NAV_DATETIME_SECONDS_IN_1_YEAR_AVG   = 31556926   // 365.24 days

/**
 * @constant NAV_DATETIME_SECONDS_IN_1_LEAP_YEAR
 * @description Number of seconds in one leap year (366 days)
 */
constant long NAV_DATETIME_SECONDS_IN_1_LEAP_YEAR  = 31622400   // 366 days

// constant long NAV_DATETIME_MILLISECONDS_IN_1_SECOND    = 1000
// constant long NAV_DATETIME_MILLISECONDS_IN_1_MINUTE    = 60000
// constant long NAV_DATETIME_MILLISECONDS_IN_1_HOUR      = 3600000
// constant long NAV_DATETIME_MILLISECONDS_IN_1_DAY       = 86400000
// constant long NAV_DATETIME_MILLISECONDS_IN_1_WEEK      = 604800000
// constant long NAV_DATETIME_MILLISECONDS_IN_1_MONTH_AVG = 2629743000    // 30.44 days
// constant double NAV_DATETIME_MILLISECONDS_IN_1_YEAR      = 31536000000   // 365 days
// constant double NAV_DATETIME_MILLISECONDS_IN_1_YEAR_AVG  = 31556926000   // 365.24 days
// constant double NAV_DATETIME_MILLISECONDS_IN_1_LEAP_YEAR = 31622400000   // 366 days

/**
 * @constant NAV_DATETIME_DAY_SUNDAY
 * @description Day of week identifier for Sunday
 */
constant integer NAV_DATETIME_DAY_SUNDAY           = 1

/**
 * @constant NAV_DATETIME_DAY_MONDAY
 * @description Day of week identifier for Monday
 */
constant integer NAV_DATETIME_DAY_MONDAY           = 2

/**
 * @constant NAV_DATETIME_DAY_TUESDAY
 * @description Day of week identifier for Tuesday
 */
constant integer NAV_DATETIME_DAY_TUESDAY          = 3

/**
 * @constant NAV_DATETIME_DAY_WEDNESDAY
 * @description Day of week identifier for Wednesday
 */
constant integer NAV_DATETIME_DAY_WEDNESDAY        = 4

/**
 * @constant NAV_DATETIME_DAY_THURSDAY
 * @description Day of week identifier for Thursday
 */
constant integer NAV_DATETIME_DAY_THURSDAY         = 5

/**
 * @constant NAV_DATETIME_DAY_FRIDAY
 * @description Day of week identifier for Friday
 */
constant integer NAV_DATETIME_DAY_FRIDAY           = 6

/**
 * @constant NAV_DATETIME_DAY_SATURDAY
 * @description Day of week identifier for Saturday
 */
constant integer NAV_DATETIME_DAY_SATURDAY         = 7

/**
 * @constant NAV_DATETIME_DAY
 * @description Array of day names indexed by day of week identifiers
 */
constant char NAV_DATETIME_DAY[][NAV_MAX_CHARS] =   {
                                                        'Sunday',
                                                        'Monday',
                                                        'Tuesday',
                                                        'Wednesday',
                                                        'Thursday',
                                                        'Friday',
                                                        'Saturday'
                                                    }

/**
 * @constant NAV_DATETIME_MONTH_JANUARY
 * @description Month identifier for January (0-based)
 */
constant integer NAV_DATETIME_MONTH_JANUARY        = 0

/**
 * @constant NAV_DATETIME_MONTH_FEBRUARY
 * @description Month identifier for February (0-based)
 */
constant integer NAV_DATETIME_MONTH_FEBRUARY       = 1

/**
 * @constant NAV_DATETIME_MONTH_MARCH
 * @description Month identifier for March (0-based)
 */
constant integer NAV_DATETIME_MONTH_MARCH          = 2

/**
 * @constant NAV_DATETIME_MONTH_APRIL
 * @description Month identifier for April (0-based)
 */
constant integer NAV_DATETIME_MONTH_APRIL          = 3

/**
 * @constant NAV_DATETIME_MONTH_MAY
 * @description Month identifier for May (0-based)
 */
constant integer NAV_DATETIME_MONTH_MAY            = 4

/**
 * @constant NAV_DATETIME_MONTH_JUNE
 * @description Month identifier for June (0-based)
 */
constant integer NAV_DATETIME_MONTH_JUNE           = 5

/**
 * @constant NAV_DATETIME_MONTH_JULY
 * @description Month identifier for July (0-based)
 */
constant integer NAV_DATETIME_MONTH_JULY           = 6

/**
 * @constant NAV_DATETIME_MONTH_AUGUST
 * @description Month identifier for August (0-based)
 */
constant integer NAV_DATETIME_MONTH_AUGUST         = 7

/**
 * @constant NAV_DATETIME_MONTH_SEPTEMBER
 * @description Month identifier for September (0-based)
 */
constant integer NAV_DATETIME_MONTH_SEPTEMBER      = 8

/**
 * @constant NAV_DATETIME_MONTH_OCTOBER
 * @description Month identifier for October (0-based)
 */
constant integer NAV_DATETIME_MONTH_OCTOBER        = 9

/**
 * @constant NAV_DATETIME_MONTH_NOVEMBER
 * @description Month identifier for November (0-based)
 */
constant integer NAV_DATETIME_MONTH_NOVEMBER       = 10

/**
 * @constant NAV_DATETIME_MONTH_DECEMBER
 * @description Month identifier for December (0-based)
 */
constant integer NAV_DATETIME_MONTH_DECEMBER       = 11

/**
 * @constant NAV_DATETIME_MONTH
 * @description Array of month names indexed by month identifiers
 */
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

/**
 * @constant NAV_DAYS_IN_MONTH
 * @description Array containing the number of days in each month (non-leap year)
 */
constant integer NAV_DAYS_IN_MONTH[12] = {
    31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
}


/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_UTC
 * @description Format timestamp as "MM/DD/YYYY @ HH:MMam/pm"
 * @example 11/23/2023 @ 09:30pm
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_UTC          = 1

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_ATOM
 * @description Format timestamp using Atom standard
 * @example 2023-11-23T21:30:00+00:00
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_ATOM         = 2

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_COOKIE
 * @description Format timestamp as used in HTTP cookies
 * @example Friday, 23-Nov-2023 21:30:00 GMT
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_COOKIE       = 3

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601
 * @description Format timestamp using ISO 8601 standard
 * @example 2023-11-23T21:30:00+0000
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601      = 4

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_RFC822
 * @description Format timestamp according to RFC 822
 * @example Thu, 23 Nov 23 21:30:00 +0000
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC822       = 5

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_RFC850
 * @description Format timestamp according to RFC 850
 * @example Thursday, 23-Nov-23 21:30:00 GMT
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC850       = 6

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_RFC1036
 * @description Format timestamp according to RFC 1036
 * @example Thu, 23 Nov 23 21:30:00 +0000
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC1036      = 7

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_RFC1123
 * @description Format timestamp according to RFC 1123
 * @example Thu, 23 Nov 2023 21:30:00 +0000
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC1123      = 8

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_RFC7231
 * @description Format timestamp according to RFC 7231
 * @example Thu, 23 Nov 2023 21:30:00 GMT
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC7231      = 9

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_RFC2822
 * @description Format timestamp according to RFC 2822
 * @example Thu, 23 Nov 2023 21:30:00 +0000
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC2822      = 10

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339
 * @description Format timestamp according to RFC 3339
 * @example 2023-11-23T21:30:00+00:00
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339      = 11

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339EXT
 * @description Format timestamp according to RFC 3339 with milliseconds
 * @example 2023-11-23T21:30:00.000+00:00
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339EXT   = 12

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_RSS
 * @description Format timestamp as used in RSS feeds
 * @example Thu, 23 Nov 2023 21:30:00 +0000
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_RSS          = 13

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_W3C
 * @description Format timestamp as defined by W3C standards
 * @example 2023-11-23T21:30:00+00:00
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_W3C          = 14

/**
 * @constant NAV_DATETIME_TIMESTAMP_FORMAT_DEFAULT
 * @description Default timestamp format (ISO 8601)
 * @example 2023-11-23T21:30:00+0000
 */
constant integer NAV_DATETIME_TIMESTAMP_FORMAT_DEFAULT      = NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601


/**
 * @constant NAV_DATETIME_TIMEZONE_ALPHA_TIME_ZONE
 * @description Timezone identifier for Alpha Time Zone
 */
constant integer NAV_DATETIME_TIMEZONE_ALPHA_TIME_ZONE                              = 1

/**
 * @constant NAV_DATETIME_TIMEZONE_AUSTRALIAN_CENTRAL_DAYLIGHT_TIME
 * @description Timezone identifier for Australian Central Daylight Time
 */
constant integer NAV_DATETIME_TIMEZONE_AUSTRALIAN_CENTRAL_DAYLIGHT_TIME             = 2

/**
 * @constant NAV_DATETIME_TIMEZONE_AUSTRALIAN_CENTRAL_STANDARD_TIME
 * @description Timezone identifier for Australian Central Standard Time
 */
constant integer NAV_DATETIME_TIMEZONE_AUSTRALIAN_CENTRAL_STANDARD_TIME             = 3

/**
 * @constant NAV_DATETIME_TIMEZONE_ACRE_TIME
 * @description Timezone identifier for Acre Time
 */
constant integer NAV_DATETIME_TIMEZONE_ACRE_TIME                                    = 4

/**
 * @constant NAV_DATETIME_TIMEZONE_AUSTRALIAN_CENTRAL_TIME
 * @description Timezone identifier for Australian Central Time
 */
constant integer NAV_DATETIME_TIMEZONE_AUSTRALIAN_CENTRAL_TIME                      = 5

/**
 * @constant NAV_DATETIME_TIMEZONE_AUSTRALIAN_CENTRAL_WESTERN_STANDARD_TIME
 * @description Timezone identifier for Australian Central Western Standard Time
 */
constant integer NAV_DATETIME_TIMEZONE_AUSTRALIAN_CENTRAL_WESTERN_STANDARD_TIME     = 6

/**
 * @constant NAV_DATETIME_TIMEZONE_AUSTRALIAN_EASTERN_DAYLIGHT_TIME
 * @description Timezone identifier for Australian Eastern Daylight Time
 */
constant integer NAV_DATETIME_TIMEZONE_AUSTRALIAN_EASTERN_DAYLIGHT_TIME             = 9



DEFINE_TYPE

/**
 * @struct _NAVTimespec
 * @description Time specification structure containing date and time components.
 * Similar to the C standard library's struct tm.
 *
 * @property {integer} Year - Years since 1900
 * @property {integer} Month - Months since January (0-11)
 * @property {integer} MonthDay - Day of the month (1-31)
 * @property {integer} Hour - Hours since midnight (0-23)
 * @property {integer} Minute - Minutes after the hour (0-59)
 * @property {integer} Seconds - Seconds after the minute (0-59)
 * @property {integer} WeekDay - Days since Sunday (0-6)
 * @property {integer} YearDay - Days since January 1 (0-365)
 * @property {char} IsDst - Daylight Saving Time flag (positive if DST in effect, zero if not, negative if unknown)
 *
 * @example
 * stack_var _NAVTimespec timespec
 * NAVDateTimeGetTimespecNow(timespec)
 * // timespec now contains the current date and time information
 */
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


/**
 * @struct _NAVTimeserver
 * @description Structure representing an NTP time server configuration.
 *
 * @property {char[15]} Ip - IP address of the time server
 * @property {char[255]} Hostname - Hostname of the time server
 * @property {char[255]} Description - Human readable description of the time server
 *
 * @example
 * stack_var _NAVTimeserver customServer
 * customServer.Ip = '132.163.97.2'
 * customServer.Hostname = 'time-a.nist.gov'
 * customServer.Description = 'NIST Internet Time Service'
 */
struct _NAVTimeserver {
    char Ip[15]
    char Hostname[255]
    char Description[255]
}


DEFINE_VARIABLE

/**
 * @constant timeserver
 * @description Default time server configuration for Windows time service
 */
constant _NAVTimeserver timeserver = { '51.145.123.29', 'time.windows.com', 'Windows Timeserver' }


#END_IF // __NAV_FOUNDATION_DATETIME_H__
