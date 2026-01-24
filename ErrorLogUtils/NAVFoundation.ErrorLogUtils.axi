PROGRAM_NAME='NAVFoundation.ErrorLogUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ERRORLOGUTILS__
#DEFINE __NAV_FOUNDATION_ERRORLOGUTILS__ 'NAVFoundation.ErrorLogUtils'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.h.axi'


/**
 * @function NAVGetLogLevel
 * @public
 * @description Converts a numeric log level to its string representation.
 *
 * @param {long} level - The numeric log level [NAV_LOG_LEVEL_*]
 *
 * @returns {char[]} String representation of the log level (ERROR, WARNING, INFO, DEBUG)
 *
 * @example
 * stack_var char levelStr[NAV_MAX_CHARS]
 * levelStr = NAVGetLogLevel(NAV_LOG_LEVEL_WARNING)  // Returns 'WARNING'
 *
 * @note Returns INFO as default for unrecognized levels
 */
define_function char[NAV_MAX_CHARS] NAVGetLogLevel(long level) {
    switch (level) {
        case NAV_LOG_LEVEL_ERROR:
        case NAV_LOG_LEVEL_WARNING:
        case NAV_LOG_LEVEL_INFO:
        case NAV_LOG_LEVEL_DEBUG: {
            return NAV_LOG_LEVELS[level]
        }
        default: {
            return NAVGetLogLevel(NAV_LOG_LEVEL_INFO)
        }
    }
}


/**
 * @function NAVLibraryFunctionErrorLog
 * @public
 * @description Logs an error message with library and function context.
 *
 * @param {long} level - The log level [NAV_LOG_LEVEL_*]
 * @param {char[]} libraryName - Name of the library
 * @param {char[]} functionName - Name of the function
 * @param {char[]} message - Log message content
 *
 * @returns {void}
 *
 * @example
 * NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
 *                           'MyLibrary',
 *                           'MyFunction',
 *                           'An error occurred')
 */
define_function NAVLibraryFunctionErrorLog(long level, char libraryName[], char functionName[], char message[]) {
    stack_var char log[NAV_MAX_BUFFER]

    log = NAVFormatLibraryFunctionLog(libraryName, functionName, message)
    NAVErrorLog(level, log)
}


/**
 * @function NAVFormatLibraryFunction
 * @public
 * @description Formats a library name and function name into a standard format.
 *
 * @param {char[]} libraryName - Name of the library
 * @param {char[]} functionName - Name of the function
 *
 * @returns {char[]} Formatted string in the form "LibraryName.FunctionName()"
 *
 * @example
 * stack_var char funcStr[NAV_MAX_BUFFER]
 * funcStr = NAVFormatLibraryFunction('MyLibrary', 'MyFunction')  // Returns "MyLibrary.MyFunction()"
 */
define_function char[NAV_MAX_BUFFER] NAVFormatLibraryFunction(char libraryName[], char functionName[]) {
    return "libraryName, '.', functionName, '()'"
}


/**
 * @function NAVFormatLibraryFunctionLog
 * @public
 * @description Formats a full library function log message with file information.
 *
 * @param {char[]} libraryName - Name of the library
 * @param {char[]} functionName - Name of the function
 * @param {char[]} value - Log message content
 *
 * @returns {char[]} Formatted log message with library, function, and file context
 *
 * @example
 * stack_var char logMsg[NAV_MAX_BUFFER]
 * logMsg = NAVFormatLibraryFunctionLog('MyLibrary', 'MyFunction', 'An error occurred')
 */
define_function char[NAV_MAX_BUFFER] NAVFormatLibraryFunctionLog(char libraryName[], char functionName[], char value[]) {
    return "NAVFormatLibraryFunction(libraryName, functionName), ' => ', __FILE__, ':: ', value"
}


/**
 * @function NAVFormatLog
 * @public
 * @description Formats a log message with its level indicator.
 *
 * @param {long} level - The log level [NAV_LOG_LEVEL_*]
 * @param {char[]} value - Log message content
 *
 * @returns {char[]} Formatted log message with level indicator
 *
 * @example
 * stack_var char formatted[NAV_MAX_BUFFER]
 * formatted = NAVFormatLog(NAV_LOG_LEVEL_WARNING, 'Low disk space')  // Returns 'WARNING:: Low disk space'
 */
define_function char[NAV_MAX_BUFFER] NAVFormatLog(long level, char value[]) {
    return "NAVGetLogLevel(level), ':: ', NAVFormatHex(value)"
}


/**
 * @function NAVErrorLog
 * @public
 * @description Main logging function that handles dispatching to different output methods.
 * Sends logs to AMX log system, debug console (if enabled), and log files (if enabled).
 *
 * @param {long} level - The log level [NAV_LOG_LEVEL_*]
 * @param {char[]} value - Log message content
 *
 * @returns {void}
 *
 * @example
 * NAVErrorLog(NAV_LOG_LEVEL_INFO, 'System starting up')
 *
 * @note Using invalid log levels will default to NAV_LOG_LEVEL_ERROR
 */
define_function NAVErrorLog(long level, char value[]) {
    switch (level) {
        case NAV_LOG_LEVEL_ERROR:
        case NAV_LOG_LEVEL_WARNING:
        case NAV_LOG_LEVEL_INFO:
        case NAV_LOG_LEVEL_DEBUG: {
            amx_log(level, NAVFormatLog(level, value))

            #IF_DEFINED USING_NAV_ERRORLOG_EVENT_CALLBACK
            NAVErrorLogEventCallback(level, value)
            #END_IF

            #IF_DEFINED __NAV_FOUNDATION_LOGTOFILE__
            NAVErrorLogToFile(NAV_LOG_FILE_NAME, level, value)
            #END_IF
        }
        default: {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, value)
        }
    }
}


/**
 * @function NAVGetStandardLogMessageType
 * @public
 * @description Gets the string representation of a standard log message type.
 *
 * @param {integer} type - The message type identifier [NAV_STANDARD_LOG_MESSAGE_TYPE_*]
 *
 * @returns {char[]} String representation of the message type
 *
 * @example
 * stack_var char typeStr[NAV_MAX_CHARS]
 * typeStr = NAVGetStandardLogMessageType(NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_FROM)  // Returns 'String From'
 */
define_function char[NAV_MAX_CHARS] NAVGetStandardLogMessageType(integer type) {
    return NAV_STANDARD_LOG_MESSAGE_TYPE[type]
}


/**
 * @function NAVFormatStandardLogMessage
 * @public
 * @description Formats a standard log message with device information and message content.
 *
 * @param {integer} type - The message type identifier [NAV_STANDARD_LOG_MESSAGE_TYPE_*]
 * @param {dev} device - Device associated with the message
 * @param {char[]} message - Message content
 *
 * @returns {char[]} Formatted standard log message
 *
 * @example
 * stack_var char formattedMsg[NAV_MAX_BUFFER]
 * formattedMsg = NAVFormatStandardLogMessage(
 *                    NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_TO,
 *                    dvProjector,
 *                    'PWR ON')
 */
define_function char[NAV_MAX_BUFFER] NAVFormatStandardLogMessage(integer type, dev device, char message[]) {
    return "NAVGetStandardLogMessageType(type), ' [', NAVDeviceToString(device), ']-[', NAVFormatHex(message), ']'"
}


#END_IF // __NAV_FOUNDATION_ERRORLOGUTILS__
