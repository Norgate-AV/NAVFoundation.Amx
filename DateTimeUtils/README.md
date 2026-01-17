# NAVFoundation.DateTimeUtils

A comprehensive date and time utility library for NAVFoundation providing functions for time manipulation, formatting, timezone handling, and Unix epoch conversions.

## Table of Contents

- [Installation](#installation)
- [Data Structures](#data-structures)
- [Constants](#constants)
  - [Time Constants](#time-constants)
  - [Day Constants](#day-constants)
  - [Month Constants](#month-constants)
  - [Timestamp Format Constants](#timestamp-format-constants)
- [Core Functions](#core-functions)
  - [Timespec Operations](#timespec-operations)
  - [Epoch Conversions](#epoch-conversions)
  - [Date Calculations](#date-calculations)
  - [Timestamp Formatting](#timestamp-formatting)
  - [System Clock Management](#system-clock-management)
  - [Timezone and DST](#timezone-and-dst)
  - [Time Server Management](#time-server-management)
  - [Utility Functions](#utility-functions)
- [Examples](#examples)

## Installation

Include the library in your NetLinx project:

```netlinx
#include 'NAVFoundation.DateTimeUtils.axi'
```

## Data Structures

### `_NAVTimespec`

Time specification structure containing date and time components. Similar to the C standard library's `struct tm`.

**Properties:**

- `integer Year` - Years since 1900
- `integer Month` - Months since January (0-11)
- `integer MonthDay` - Day of the month (1-31)
- `integer Hour` - Hours since midnight (0-23)
- `integer Minute` - Minutes after the hour (0-59)
- `integer Seconds` - Seconds after the minute (0-59)
- `integer WeekDay` - Days since Sunday (1-7, where 1 is Sunday)
- `integer YearDay` - Days since January 1 (1-366)
- `char IsLeapYear` - Leap year flag
- `char IsDst` - Daylight Saving Time flag
- `sinteger GmtOffset` - GMT offset in minutes (positive for east of UTC, negative for west)
- `char Timezone[15]` - Timezone string (e.g., "UTC+01:00")

**Example:**

```netlinx
stack_var _NAVTimespec timespec
NAVDateTimeGetTimespecNow(timespec)
// timespec now contains the current date and time information
```

### `_NAVTimeServer`

Structure representing an NTP time server configuration.

**Properties:**

- `char Ip[15]` - IP address of the time server
- `char Hostname[255]` - Hostname of the time server
- `char Description[255]` - Human readable description of the time server

**Example:**

```netlinx
stack_var _NAVTimeServer customServer
customServer.Ip = '132.163.97.2'
customServer.Hostname = 'time-a.nist.gov'
customServer.Description = 'NIST Internet Time Service'
```

## Constants

### Time Constants

```netlinx
NAV_DATETIME_SECONDS_IN_1_MINUTE     = 60
NAV_DATETIME_SECONDS_IN_1_HOUR       = 3600
NAV_DATETIME_SECONDS_IN_1_DAY        = 86400
NAV_DATETIME_SECONDS_IN_1_WEEK       = 604800
NAV_DATETIME_SECONDS_IN_1_MONTH_AVG  = 2629743    // 30.44 days
NAV_DATETIME_SECONDS_IN_1_YEAR       = 31536000   // 365 days
NAV_DATETIME_SECONDS_IN_1_YEAR_AVG   = 31556926   // 365.24 days
NAV_DATETIME_SECONDS_IN_1_LEAP_YEAR  = 31622400   // 366 days
```

### Day Constants

```netlinx
NAV_DATETIME_DAY_SUNDAY     = 1
NAV_DATETIME_DAY_MONDAY     = 2
NAV_DATETIME_DAY_TUESDAY    = 3
NAV_DATETIME_DAY_WEDNESDAY  = 4
NAV_DATETIME_DAY_THURSDAY   = 5
NAV_DATETIME_DAY_FRIDAY     = 6
NAV_DATETIME_DAY_SATURDAY   = 7
```

### Month Constants

```netlinx
NAV_DATETIME_MONTH_JANUARY    = 0
NAV_DATETIME_MONTH_FEBRUARY   = 1
NAV_DATETIME_MONTH_MARCH      = 2
NAV_DATETIME_MONTH_APRIL      = 3
NAV_DATETIME_MONTH_MAY        = 4
NAV_DATETIME_MONTH_JUNE       = 5
NAV_DATETIME_MONTH_JULY       = 6
NAV_DATETIME_MONTH_AUGUST     = 7
NAV_DATETIME_MONTH_SEPTEMBER  = 8
NAV_DATETIME_MONTH_OCTOBER    = 9
NAV_DATETIME_MONTH_NOVEMBER   = 10
NAV_DATETIME_MONTH_DECEMBER   = 11
```

### Timestamp Format Constants

```netlinx
NAV_DATETIME_TIMESTAMP_FORMAT_UTC         // MM/DD/YYYY @ HH:MMam/pm
NAV_DATETIME_TIMESTAMP_FORMAT_ATOM        // 2023-11-23T21:30:00+00:00
NAV_DATETIME_TIMESTAMP_FORMAT_COOKIE      // Friday, 23-Nov-2023 21:30:00 GMT
NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601     // 2023-11-23T21:30:00+0000
NAV_DATETIME_TIMESTAMP_FORMAT_RFC822      // Thu, 23 Nov 23 21:30:00 +0000
NAV_DATETIME_TIMESTAMP_FORMAT_RFC850      // Thursday, 23-Nov-23 21:30:00 GMT
NAV_DATETIME_TIMESTAMP_FORMAT_RFC1036     // Thu, 23 Nov 23 21:30:00 +0000
NAV_DATETIME_TIMESTAMP_FORMAT_RFC1123     // Thu, 23 Nov 2023 21:30:00 +0000
NAV_DATETIME_TIMESTAMP_FORMAT_RFC7231     // Thu, 23 Nov 2023 21:30:00 GMT
NAV_DATETIME_TIMESTAMP_FORMAT_RFC2822     // Thu, 23 Nov 2023 21:30:00 +0000
NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339     // 2023-11-23T21:30:00+00:00
NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339EXT  // 2023-11-23T21:30:00.000+00:00
NAV_DATETIME_TIMESTAMP_FORMAT_RSS         // Thu, 23 Nov 2023 21:30:00 +0000
NAV_DATETIME_TIMESTAMP_FORMAT_W3C         // 2023-11-23T21:30:00+00:00
NAV_DATETIME_TIMESTAMP_FORMAT_DEFAULT     // ISO8601
```

## Core Functions

### Timespec Operations

#### `NAVDateTimeGetTimespecNow`

Gets the current date and time and fills a timespec structure.

**Signature:**

```netlinx
char NAVDateTimeGetTimespecNow(_NAVTimespec timespec)
```

**Parameters:**

- `timespec` - Structure to fill with current date and time information

**Returns:** `char` - True if successful, false otherwise

**Example:**

```netlinx
stack_var _NAVTimespec now
if (NAVDateTimeGetTimespecNow(now)) {
    // Use the current time values in the now structure
    NAVDateTimeTimespecLog('Current Time', now)
}
```

#### `NAVDateTimeGetTimespec`

Fills a timespec structure with date and time from the provided strings.

**Signature:**

```netlinx
char NAVDateTimeGetTimespec(_NAVTimespec timespec, char date[], char time[])
```

**Parameters:**

- `timespec` - Structure to fill with date and time information
- `date` - Date string in MM/DD/YYYY format
- `time` - Time string in HH:MM:SS format

**Returns:** `char` - True if successful, false otherwise

**Example:**

```netlinx
stack_var _NAVTimespec customTime
if (NAVDateTimeGetTimespec(customTime, '11/23/2023', '14:30:00')) {
    // Use the values in the customTime structure
}
```

#### `NAVDateTimeTimespecLog`

Logs all fields of a timespec structure to the debug log.

**Signature:**

```netlinx
void NAVDateTimeTimespecLog(char sender[], _NAVTimespec timespec)
```

**Parameters:**

- `sender` - Name of the calling component/function for log attribution
- `timespec` - Timespec structure to log

**Example:**

```netlinx
stack_var _NAVTimespec now
NAVDateTimeGetTimespecNow(now)
NAVDateTimeTimespecLog('MyFunction', now)
```

#### `NAVDateTimeTimespecPast`

Checks if the specified timespec is in the past relative to the current time.

**Signature:**

```netlinx
char NAVDateTimeTimespecPast(_NAVTimespec timespec)
```

**Parameters:**

- `timespec` - Timespec to check

**Returns:** `char` - True if the time is in the past, false otherwise

**Example:**

```netlinx
stack_var _NAVTimespec oldTime
stack_var char isPast

// Populate oldTime with a past date
isPast = NAVDateTimeTimespecPast(oldTime)  // Returns true
```

### Epoch Conversions

#### `NAVDateTimeGetEpochNow`

Gets the current Unix epoch timestamp.

**Signature:**

```netlinx
long NAVDateTimeGetEpochNow()
```

**Returns:** `long` - Current Unix timestamp in seconds since Jan 1, 1970

**Example:**

```netlinx
stack_var long currentEpoch
currentEpoch = NAVDateTimeGetEpochNow()
```

#### `NAVDateTimeGetEpoch`

Converts a timespec structure to a Unix epoch timestamp.

**Signature:**

```netlinx
long NAVDateTimeGetEpoch(_NAVTimespec timespec)
```

**Parameters:**

- `timespec` - Timespec structure to convert

**Returns:** `long` - Unix timestamp in seconds since Jan 1, 1970

**Example:**

```netlinx
stack_var _NAVTimespec time
stack_var long epochTime

NAVDateTimeGetTimespecNow(time)
epochTime = NAVDateTimeGetEpoch(time)
```

#### `NAVDateTimeEpochToTimespec`

Converts a Unix epoch timestamp to a timespec structure.

**Signature:**

```netlinx
void NAVDateTimeEpochToTimespec(long epoch, _NAVTimespec timespec)
```

**Parameters:**

- `epoch` - Unix timestamp in seconds since Jan 1, 1970
- `timespec` - Timespec structure to populate (modified in-place)

**Example:**

```netlinx
stack_var _NAVTimespec time
stack_var long epochTime

epochTime = 1672531200  // Jan 1, 2023 00:00:00 UTC
NAVDateTimeEpochToTimespec(epochTime, time)
```

### Date Calculations

#### `NAVDateTimeIsLeapYear`

Determines if the specified year is a leap year.

**Signature:**

```netlinx
char NAVDateTimeIsLeapYear(integer year)
```

**Parameters:**

- `year` - Year to check

**Returns:** `char` - True if leap year, false otherwise

**Example:**

```netlinx
stack_var char isLeap
isLeap = NAVDateTimeIsLeapYear(2024)  // Returns true
```

#### `NAVDateTimeGetDaysInMonth`

Gets the number of days in the specified month.

**Signature:**

```netlinx
integer NAVDateTimeGetDaysInMonth(integer month, integer year)
```

**Parameters:**

- `month` - Month number (1-12)
- `year` - Full year (e.g., 2024) to check for leap year

**Returns:** `integer` - Number of days in the month (28-31), or 0 if month is invalid

**Example:**

```netlinx
stack_var integer days
days = NAVDateTimeGetDaysInMonth(2, 2024)  // Returns 29 (leap year)
days = NAVDateTimeGetDaysInMonth(2, 2023)  // Returns 28 (non-leap year)
days = NAVDateTimeGetDaysInMonth(13, 2024) // Returns 0 (invalid month)
```

#### `NAVDateTimeGetYearDay`

Calculates the day of the year (1-366) for a given timespec.

**Signature:**

```netlinx
integer NAVDateTimeGetYearDay(_NAVTimespec timespec)
```

**Parameters:**

- `timespec` - Timespec structure containing date and time information

**Returns:** `integer` - Day of the year (1-366)

**Example:**

```netlinx
stack_var _NAVTimespec now
stack_var integer dayOfYear

NAVDateTimeGetTimespecNow(now)
dayOfYear = NAVDateTimeGetYearDay(now)
```

#### `NAVDateTimeGetNextDate`

Returns the next date after the specified date.

**Signature:**

```netlinx
char[10] NAVDateTimeGetNextDate(char date[])
```

**Parameters:**

- `date` - Date string in MM/DD/YYYY format

**Returns:** `char[10]` - String representation of the next date in MM/DD/YYYY format

**Example:**

```netlinx
stack_var char nextDay[20]
nextDay = NAVDateTimeGetNextDate('12/31/2023')  // Returns "01/01/2024"
nextDay = NAVDateTimeGetNextDate(ldate)  // Returns tomorrow's date
```

**Note:** Handles month and year transitions, including leap years

#### `NAVGetNextDate`

Alias for `NAVDateTimeGetNextDate`.

**Signature:**

```netlinx
char[10] NAVGetNextDate(char date[])
```

#### `NAVDateTimeGetLastSundayInMonth`

Calculates the date of the last Sunday in a given month and year.

**Signature:**

```netlinx
integer NAVDateTimeGetLastSundayInMonth(integer year, integer month)
```

**Parameters:**

- `year` - Year for the calculation
- `month` - Month for the calculation (1-12)

**Returns:** `integer` - Day of the month of the last Sunday (1-31)

**Example:**

```netlinx
stack_var integer lastSunday
lastSunday = NAVDateTimeGetLastSundayInMonth(2023, 11)  // Returns the day of last Sunday in November 2023
```

**Note:** This function relies on the NetLinx built-in `day_of_week()` function, which only supports years >= 1901. The NetLinx epoch starts on January 1, 1901, and attempting to use years before 1901 will produce incorrect results. This is a platform limitation due to the embedded system's simplified date/time implementation.

#### `NAVDateTimeGetDifference`

Calculates the time difference between two timespec structures.

**Signature:**

```netlinx
slong NAVDateTimeGetDifference(_NAVTimespec timespec1, _NAVTimespec timespec2)
```

**Parameters:**

- `timespec1` - First timespec
- `timespec2` - Second timespec

**Returns:** `slong` - Time difference in seconds (signed to support negative values when timespec1 < timespec2)

**Example:**

```netlinx
stack_var _NAVTimespec time1
stack_var _NAVTimespec time2
stack_var slong seconds

// Populate time1 and time2
seconds = NAVDateTimeGetDifference(time1, time2)
// Returns positive if time1 > time2, negative if time1 < time2
```

**Note:** The result is timespec1 - timespec2. Returns a signed value to properly represent both positive and negative time differences.

### Timestamp Formatting

#### `NAVDateTimeGetTimestampNow`

Gets a timestamp string for the current date and time using the default format.

**Signature:**

```netlinx
char[NAV_MAX_BUFFER] NAVDateTimeGetTimestampNow()
```

**Returns:** `char[]` - Formatted timestamp string

**Example:**

```netlinx
stack_var char timestamp[50]
timestamp = NAVDateTimeGetTimestampNow()  // Returns timestamp in default format
```

#### `NAVDateTimeGetTimestampNowFormat`

Gets a timestamp string for the current date and time using the specified format.

**Signature:**

```netlinx
char[NAV_MAX_BUFFER] NAVDateTimeGetTimestampNowFormat(integer timestampFormat)
```

**Parameters:**

- `timestampFormat` - Format constant (e.g., NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339)

**Returns:** `char[]` - Formatted timestamp string

**Example:**

```netlinx
stack_var char timestamp[50]
timestamp = NAVDateTimeGetTimestampNowFormat(NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339)
```

#### `NAVDateTimeGetTimestamp`

Gets a formatted timestamp string for the specified timespec using the default format.

**Signature:**

```netlinx
char[NAV_MAX_BUFFER] NAVDateTimeGetTimestamp(_NAVTimespec timespec)
```

**Parameters:**

- `timespec` - Timespec structure with date and time information

**Returns:** `char[]` - Formatted timestamp string

**Example:**

```netlinx
stack_var _NAVTimespec time
stack_var char timestamp[50]

NAVDateTimeGetTimespecNow(time)
timestamp = NAVDateTimeGetTimestamp(time)
```

#### `NAVDateTimeGetTimestampFormat`

Gets a formatted timestamp string for the specified timespec using the specified format.

**Signature:**

```netlinx
char[NAV_MAX_BUFFER] NAVDateTimeGetTimestampFormat(_NAVTimespec timespec, integer timestampFormat)
```

**Parameters:**

- `timespec` - Timespec structure with date and time information
- `timestampFormat` - Format constant (e.g., NAV_DATETIME_TIMESTAMP_FORMAT_ISO8601)

**Returns:** `char[]` - Formatted timestamp string

**Example:**

```netlinx
stack_var _NAVTimespec time
stack_var char timestamp[50]

NAVDateTimeGetTimespecNow(time)
timestamp = NAVDateTimeGetTimestampFormat(time, NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339)
```

#### `NAVDateTimeGetTimestampFromEpoch`

Converts a Unix epoch timestamp to a formatted timestamp string using the default format.

**Signature:**

```netlinx
char[NAV_MAX_BUFFER] NAVDateTimeGetTimestampFromEpoch(long epoch)
```

**Parameters:**

- `epoch` - Unix timestamp in seconds since Jan 1, 1970

**Returns:** `char[]` - Formatted timestamp string

**Example:**

```netlinx
stack_var char timestamp[50]
timestamp = NAVDateTimeGetTimestampFromEpoch(1672531200)  // Jan 1, 2023 00:00:00 UTC
```

### System Clock Management

#### `NAVDateTimeSetClock`

Sets the system clock to the specified date and time.

**Signature:**

```netlinx
void NAVDateTimeSetClock(char date[], char time[])
```

**Parameters:**

- `date` - Date string in MM/DD/YYYY format
- `time` - Time string in HH:MM:SS format

**Example:**

```netlinx
NAVDateTimeSetClock('01/01/2023', '12:00:00')
```

**Note:** Requires master control rights

#### `NAVDateTimeSetClockFromTimespec`

Sets the system clock using a timespec structure.

**Signature:**

```netlinx
void NAVDateTimeSetClockFromTimespec(_NAVTimespec timespec)
```

**Parameters:**

- `timespec` - Timespec structure with date and time information

**Example:**

```netlinx
stack_var _NAVTimespec time

// Populate time with desired date and time
NAVDateTimeSetClockFromTimespec(time)
```

**Note:** Requires master control rights

#### `NAVDateTimeSetClockFromEpoch`

Sets the system clock using a Unix epoch timestamp.

**Signature:**

```netlinx
void NAVDateTimeSetClockFromEpoch(long epoch)
```

**Parameters:**

- `epoch` - Unix timestamp in seconds since Jan 1, 1970

**Example:**

```netlinx
NAVDateTimeSetClockFromEpoch(1672531200)  // Sets to Jan 1, 2023 00:00:00 UTC
```

**Note:** Requires master control rights

### Timezone and DST

#### `NAVDateTimeGetGmtOffset`

Gets the current GMT offset based on timezone configuration.

**Signature:**

```netlinx
sinteger NAVDateTimeGetGmtOffset()
```

**Returns:** `sinteger` - GMT offset in minutes, or 0 if not available (positive for east of UTC, negative for west)

**Example:**

```netlinx
stack_var sinteger offset
offset = NAVDateTimeGetGmtOffset()  // Returns offset in minutes (e.g., 60 for UTC+01:00, -300 for UTC-05:00)
```

#### `NAVDateTimeIsDst`

Determines if the specified time is in Daylight Saving Time.

**Signature:**

```netlinx
char NAVDateTimeIsDst(_NAVTimespec timespec)
```

**Parameters:**

- `timespec` - Timespec structure containing date and time information

**Returns:** `char` - True if time is in DST, false otherwise

**Example:**

```netlinx
stack_var _NAVTimespec now
stack_var char isDst

NAVDateTimeGetTimespecNow(now)
isDst = NAVDateTimeIsDst(now)
```

**Note:** Uses UK DST rules: last Sunday in March to last Sunday in October

#### `NAVDateTimeTimezonePrint`

Logs the current system timezone information to the debug log.

**Signature:**

```netlinx
void NAVDateTimeTimezonePrint()
```

**Example:**

```netlinx
NAVDateTimeTimezonePrint()
```

#### `NAVDateTimeDaylightSavingsInfoPrint`

Logs the current system DST settings to the debug log.

**Signature:**

```netlinx
void NAVDateTimeDaylightSavingsInfoPrint()
```

**Example:**

```netlinx
NAVDateTimeDaylightSavingsInfoPrint()
```

### Time Server Management

#### `NAVSetupNetworkTime`

Configures the system to use network time with the specified time server.

**Signature:**

```netlinx
void NAVSetupNetworkTime(_NAVTimeServer timeserver)
```

**Parameters:**

- `timeserver` - Time server configuration structure. If `Ip`, `Hostname`, or `Description` fields are empty, default values will be used (Windows time server).

**Example:**

```netlinx
// Use with custom time server
stack_var _NAVTimeServer server
server.Ip = '132.163.97.2'
server.Hostname = 'time-a.nist.gov'
server.Description = 'NIST Internet Time Service'
NAVSetupNetworkTime(server)

// Use with default values
stack_var _NAVTimeServer defaultServer
NAVSetupNetworkTime(defaultServer)  // Uses Windows time server defaults
```

**Note:**
- Sets up NTP synchronization, timezone (UTC+00:00), DST rules (Europe/London)
- Default timeserver: `51.145.123.29` (time.windows.com)
- Requires master control rights

#### `NAVGetTimeServers`

Retrieves the list of time servers configured on the system.

**Signature:**

```netlinx
slong NAVGetTimeServers(clkmgr_timeserver_struct servers[])
```

**Parameters:**

- `servers` - Array to store the time server information

**Returns:** `slong` - Number of time servers retrieved

**Example:**

```netlinx
stack_var clkmgr_timeserver_struct servers[20]
stack_var slong count

count = NAVGetTimeServers(servers)
```

#### `NAVFindTimeServer`

Searches for a time server by IP address or hostname in the provided array.

**Signature:**

```netlinx
integer NAVFindTimeServer(clkmgr_timeserver_struct servers[], char ip[], char hostname[])
```

**Parameters:**

- `servers` - The array of time servers to search
- `ip` - The IP address of the time server to find
- `hostname` - The hostname of the time server to find

**Returns:** `integer` - The index of the found time server, or 0 if not found

#### `NAVDateTimeActiveTimeServerPrint`

Logs information about the active time server to the debug log.

**Signature:**

```netlinx
void NAVDateTimeActiveTimeServerPrint()
```

**Example:**

```netlinx
NAVDateTimeActiveTimeServerPrint()
```

#### `NAVDateTimeTimeServersPrint`

Logs information about all available time servers to the debug log.

**Signature:**

```netlinx
void NAVDateTimeTimeServersPrint()
```

**Example:**

```netlinx
NAVDateTimeTimeServersPrint()
```

#### `NAVDateTimeClockSourcePrint`

Logs the current system clock source information to the debug log.

**Signature:**

```netlinx
void NAVDateTimeClockSourcePrint()
```

**Example:**

```netlinx
NAVDateTimeClockSourcePrint()
```

### Utility Functions

#### `NAVDateTimeGetMonthString`

Gets the full name of a month.

**Signature:**

```netlinx
char[10] NAVDateTimeGetMonthString(integer month)
```

**Parameters:**

- `month` - Month number (1-12)

**Returns:** `char[10]` - Full month name (e.g., "January")

**Example:**

```netlinx
stack_var char monthName[20]
monthName = NAVDateTimeGetMonthString(3)  // Returns "March"
```

#### `NAVDateTimeGetShortMonthString`

Gets the abbreviated name of a month (first 3 characters).

**Signature:**

```netlinx
char[3] NAVDateTimeGetShortMonthString(integer month)
```

**Parameters:**

- `month` - Month number (1-12)

**Returns:** `char[3]` - Abbreviated month name (e.g., "Jan")

**Example:**

```netlinx
stack_var char shortMonth[4]
shortMonth = NAVDateTimeGetShortMonthString(3)  // Returns "Mar"
```

#### `NAVDateTimeGetDayString`

Gets the full name of a day of the week.

**Signature:**

```netlinx
char[10] NAVDateTimeGetDayString(integer day)
```

**Parameters:**

- `day` - Day number (1-7, where 1 is Sunday)

**Returns:** `char[10]` - Full day name (e.g., "Monday")

**Example:**

```netlinx
stack_var char dayName[20]
dayName = NAVDateTimeGetDayString(2)  // Returns "Monday"
```

#### `NAVDateTimeGetShortDayString`

Gets the abbreviated name of a day of the week (first 3 characters).

**Signature:**

```netlinx
char[3] NAVDateTimeGetShortDayString(integer day)
```

**Parameters:**

- `day` - Day number (1-7, where 1 is Sunday)

**Returns:** `char[3]` - Abbreviated day name (e.g., "Mon")

**Example:**

```netlinx
stack_var char shortDay[4]
shortDay = NAVDateTimeGetShortDayString(2)  // Returns "Mon"
```

#### `NAVDateTimeGetAmPm`

Gets the AM/PM indicator for the specified time.

**Signature:**

```netlinx
char[2] NAVDateTimeGetAmPm(_NAVTimespec timespec)
```

**Parameters:**

- `timespec` - Timespec structure with time information

**Returns:** `char[2]` - "am" or "pm" string

**Example:**

```netlinx
stack_var _NAVTimespec time
stack_var char ampm[2]

NAVDateTimeGetTimespecNow(time)
ampm = NAVDateTimeGetAmPm(time)
```

#### `NAVDateTimeTimestampsPrint`

Logs the current time in all supported timestamp formats to the debug log.

**Signature:**

```netlinx
void NAVDateTimeTimestampsPrint()
```

**Example:**

```netlinx
NAVDateTimeTimestampsPrint()
```

## Examples

### Getting Current Time

```netlinx
stack_var _NAVTimespec now

// Get current time
if (NAVDateTimeGetTimespecNow(now)) {
    NAVLog("'Current year: ', itoa(now.Year + 1900)")
    NAVLog("'Current month: ', itoa(now.Month + 1)")
    NAVLog("'Current day: ', itoa(now.MonthDay)")
    NAVLog("'Current hour: ', itoa(now.Hour)")
    NAVLog("'Current minute: ', itoa(now.Minute)")
}
```

### Working with Unix Epoch Time

```netlinx
stack_var long epoch
stack_var _NAVTimespec time

// Get current epoch time
epoch = NAVDateTimeGetEpochNow()
NAVLog("'Current epoch: ', itoa(epoch)")

// Convert epoch to timespec
NAVDateTimeEpochToTimespec(1672531200, time)

// Convert timespec back to epoch
epoch = NAVDateTimeGetEpoch(time)
```

### Formatting Timestamps

```netlinx
stack_var _NAVTimespec now
stack_var char timestamp[100]

NAVDateTimeGetTimespecNow(now)

// Default format (ISO8601)
timestamp = NAVDateTimeGetTimestamp(now)
NAVLog("'ISO8601: ', timestamp")

// RFC3339 format
timestamp = NAVDateTimeGetTimestampFormat(now, NAV_DATETIME_TIMESTAMP_FORMAT_RFC3339)
NAVLog("'RFC3339: ', timestamp")

// Cookie format
timestamp = NAVDateTimeGetTimestampFormat(now, NAV_DATETIME_TIMESTAMP_FORMAT_COOKIE)
NAVLog("'Cookie: ', timestamp")
```

### Date Calculations

```netlinx
stack_var integer days
stack_var char isLeap
stack_var char nextDay[20]

// Check if year is leap year
isLeap = NAVDateTimeIsLeapYear(2024)

// Get days in February
days = NAVDateTimeGetDaysInMonth(2, 2024)  // Returns 29 in leap year

// Get next date
nextDay = NAVDateTimeGetNextDate('12/31/2023')  // Returns "01/01/2024"
```

### Time Difference Calculation

```netlinx
stack_var _NAVTimespec time1
stack_var _NAVTimespec time2
stack_var slong secondsDiff

// Get two different times
NAVDateTimeGetTimespec(time1, '01/01/2024', '12:00:00')
NAVDateTimeGetTimespec(time2, '01/01/2024', '10:00:00')

// Calculate difference
secondsDiff = NAVDateTimeGetDifference(time1, time2)
NAVLog("'Difference in seconds: ', itoa(secondsDiff)")  // 7200 seconds (2 hours)
```

### Setting Up Network Time

```netlinx
stack_var _NAVTimeServer server

// Configure custom time server
server.Ip = '132.163.97.2'
server.Hostname = 'time-a.nist.gov'
server.Description = 'NIST Internet Time Service'

// Setup network time synchronization
NAVSetupNetworkTime(server)
```

### Timezone and DST Operations

```netlinx
stack_var _NAVTimespec now
stack_var sinteger offset
stack_var char isDst

NAVDateTimeGetTimespecNow(now)

// Get GMT offset
offset = NAVDateTimeGetGmtOffset()
NAVLog("'GMT Offset (minutes): ', itoa(offset)")

// Check if in DST
isDst = NAVDateTimeIsDst(now)
if (isDst) {
    NAVLog("'Currently in Daylight Saving Time'")
}
else {
    NAVLog("'Not in Daylight Saving Time'")
}
```

### Checking if Time is in the Past

```netlinx
stack_var _NAVTimespec pastTime
stack_var char isPast

// Create a past time
NAVDateTimeGetTimespec(pastTime, '01/01/2020', '12:00:00')

// Check if it's in the past
isPast = NAVDateTimeTimespecPast(pastTime)
if (isPast) {
    NAVLog("'Time is in the past'")
}
```

### Logging Detailed Time Information

```netlinx
stack_var _NAVTimespec now

NAVDateTimeGetTimespecNow(now)

// Log complete timespec information
NAVDateTimeTimespecLog('Main', now)

// Log all timestamp formats
NAVDateTimeTimestampsPrint()

// Log timezone information
NAVDateTimeTimezonePrint()

// Log DST information
NAVDateTimeDaylightSavingsInfoPrint()

// Log time server information
NAVDateTimeActiveTimeServerPrint()
NAVDateTimeTimeServersPrint()
```

## License

MIT License - Copyright (c) 2010-2026 Norgate AV
