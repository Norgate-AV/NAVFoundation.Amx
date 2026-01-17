PROGRAM_NAME='NAVFoundation.ErrorLogToFile'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ERRORLOGTOFILE__
#DEFINE __NAV_FOUNDATION_ERRORLOGTOFILE__ 'NAVFoundation.ErrorLogToFile'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.DateTimeUtils.axi'
#include 'NAVFoundation.FileUtils.axi'


/**
 * @function NAVFormatLogToFile
 * @public
 * @description Formats a log message for file output with timestamp and level information.
 *
 * @param {long} level - The log level [NAV_LOG_LEVEL_*]
 * @param {char[]} value - Log message content
 *
 * @returns {char[]} Formatted log message with timestamp and level
 *
 * @example
 * stack_var char fileLogMsg[NAV_MAX_BUFFER]
 * fileLogMsg = NAVFormatLogToFile(NAV_LOG_LEVEL_INFO, 'System startup complete')
 *
 * @note Returns empty string if value is empty
 */
define_function char[NAV_MAX_BUFFER] NAVFormatLogToFile(long level, char value[]) {
    stack_var char timestamp[NAV_MAX_CHARS]
    stack_var char date[10]
    stack_var char time[8]

    if (!length_array(value)) {
        return ''
    }

    timestamp = NAVDateTimeGetTimestampNow()
    date = left_string(timestamp, 10)
    time = NAVStringSubstring(timestamp, 12, 8)

    return "date, ' (', time, '):: ', NAVFormatLog(level, value)"
}


/**
 * @function NAVErrorLogToFile
 * @public
 * @description Writes a log message to the specified log file, handling log rotation if needed.
 *
 * @param {char[]} file - Log filename
 * @param {long} level - The log level [NAV_LOG_LEVEL_*]
 * @param {char[]} value - Log message content
 *
 * @returns {slong} 0 on success, or a negative error code on failure
 *
 * @example
 * stack_var slong result
 * result = NAVErrorLogToFile('application.log', NAV_LOG_LEVEL_ERROR, 'Failed to connect to database')
 *
 * @note Creates log directory and file if they don't exist
 * @note Automatically rotates log files when they exceed NAV_MAX_LOG_FILE_SIZE
 */
define_function slong NAVErrorLogToFile(char file[], long level, char value[]) {
    stack_var char log[NAV_MAX_BUFFER]
    stack_var slong result
    stack_var long size

    if (!length_array(value)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_ERRORLOGUTILS__,
                                    'NAVErrorLogToFile',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_PARAMETER), ' : No value provided to log'")

        return NAV_FILE_ERROR_INVALID_PARAMETER
    }

    log = NAVFormatLogToFile(level, value)

    if (!length_array(log)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_ERRORLOGUTILS__,
                                    'NAVErrorLogToFile',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_PARAMETER), ' : Unable to format log message'")

        return NAV_FILE_ERROR_INVALID_PARAMETER
    }

    // Check if the logs directory exists, if not create it
    if (!NAVDirectoryExists(NAV_LOGS_DIRECTORY)) {
        result = NAVDirectoryCreate(NAV_LOGS_DIRECTORY)

        if (result < 0) {
            return result
        }
    }

    // If the file does not exist, create it and write the message
    if (!NAVFileExists("NAV_LOGS_DIRECTORY, '/', file")) {
        return NAVFileWriteLine("NAV_LOGS_DIRECTORY, '/', file", log)
    }

    result = NAVFileGetSize("NAV_LOGS_DIRECTORY, '/', file")

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_ERRORLOGUTILS__,
                                    'NAVErrorLogToFile',
                                    "NAVGetFileError(result), ' : Unable to get the size of the log file'")

        return result
    }

    size = type_cast(result)

    // Check the size to see if we first need to rotate the log file
    if ((size + length_array(log)) > NAV_MAX_LOG_FILE_SIZE) {
        NAVErrorLogFileRotate(file)
        return NAVErrorLogToFile(file, level, value)
    }

    // Finally, append the current log message
    return NAVFileAppendLine("NAV_LOGS_DIRECTORY, '/', file", log)
}


/**
 * @function NAVErrorLogFileRotate
 * @public
 * @description Rotates log files by renaming them with incrementing suffixes.
 * Moves current log to .old.1, .old.1 to .old.2, etc., and deletes the oldest.
 *
 * @param {char[]} file - Base log filename to rotate
 *
 * @returns {slong} 0 on success, or a negative error code on failure
 *
 * @example
 * NAVErrorLogFileRotate('system.log')
 *
 * @note Will maintain up to NAV_MAX_OLD_LOG_FILES rotated log files
 */
define_function slong NAVErrorLogFileRotate(char file[]) {
    stack_var integer count

    if (NAVFileExists("NAV_LOGS_DIRECTORY, '/', file, '.old.', itoa(NAV_MAX_OLD_LOG_FILES)")) {
        NAVFileDelete("NAV_LOGS_DIRECTORY, '/', file, '.old.', itoa(NAV_MAX_OLD_LOG_FILES)")
    }

    for (count = (NAV_MAX_OLD_LOG_FILES - 1); count > 0; count--) {
        if (!NAVFileExists("NAV_LOGS_DIRECTORY, '/', file, '.old.', itoa(count)")) {
            continue
        }

        NAVFileRename("NAV_LOGS_DIRECTORY, '/', file, '.old.', itoa(count)", "NAV_LOGS_DIRECTORY, '/', file, '.old.', itoa(count + 1)")
    }

    return NAVFileRename("NAV_LOGS_DIRECTORY, '/', file", "NAV_LOGS_DIRECTORY, '/', file, '.old.1'")
}


#END_IF // __NAV_FOUNDATION_ERRORLOGTOFILE__
