PROGRAM_NAME='NAVFoundation.ErrorLogUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ERRORLOGUTILS__
#DEFINE __NAV_FOUNDATION_ERRORLOGUTILS__ 'NAVFoundation.ErrorLogUtils'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.DateTimeUtils.axi'
#include 'NAVFoundation.FileUtils.axi'


define_function char[NAV_MAX_CHARS] NAVGetLogLevel(long level) {
    switch (level) {
        case NAV_LOG_LEVEL_ERROR: {
            return 'ERROR'
        }
        case NAV_LOG_LEVEL_WARNING: {
            return 'WARNING'
        }
        case NAV_LOG_LEVEL_INFO: {
            return 'INFO'
        }
        case NAV_LOG_LEVEL_DEBUG: {
            return 'DEBUG'
        }
        default: {
            return NAVGetLogLevel(NAV_LOG_LEVEL_INFO)
        }
    }
}


define_function NAVLibraryFunctionErrorLog(long level, char libraryName[], char functionName[], char message[]) {
    stack_var char log[NAV_MAX_BUFFER]

    log = NAVFormatLibraryFunctionLog(libraryName, functionName, message)
    NAVErrorLog(level, log)
}


define_function char[NAV_MAX_BUFFER] NAVFormatLibraryFunction(char libraryName[], char functionName[]) {
    return "libraryName, '.', functionName, '()'"
}


define_function char[NAV_MAX_BUFFER] NAVFormatLibraryFunctionLog(char libraryName[], char functionName[], char value[]) {
    return "NAVFormatLibraryFunction(libraryName, functionName), ' => ', __FILE__, ':: ', value"
}


define_function char[NAV_MAX_BUFFER] NAVFormatLog(long level, char value[]) {
    return "NAVGetLogLevel(level), ':: ', NAVFormatHex(value)"
}


define_function NAVErrorLog(long level, char value[]) {
    switch (level) {
        case NAV_LOG_LEVEL_ERROR:
        case NAV_LOG_LEVEL_WARNING:
        case NAV_LOG_LEVEL_INFO:
        case NAV_LOG_LEVEL_DEBUG: {
            amx_log(level, NAVFormatLog(level, value))

            #IF_DEFINED __NAV_FOUNDATION_DEBUGCONSOLE__
            NAVDebugConsoleLog(NAVFormatLog(level, value))
            #END_IF
        }
        default: {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, value)
        }
    }
}


define_function char[NAV_MAX_CHARS] NAVGetStandardLogMessageType(integer type) {
    return NAV_STANDARD_LOG_MESSAGE_TYPE[type]
}


define_function char[NAV_MAX_BUFFER] NAVFormatStandardLogMessage(integer type, dev device, char message[]) {
    return "NAVGetStandardLogMessageType(type), ' ', NAVStringSurroundWith(NAVDeviceToString(device), '[', ']'), '-', NAVStringSurroundWith(NAVFormatHex(message), '[', ']')"
}


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

    // Check if the logs directory exists, if not create it
    if (!NAVDirectoryExists(NAV_LOGS_DIRECTORY)) {
        NAVDirectoryCreate(NAV_LOGS_DIRECTORY)
    }

    // If the file does not exist, create it and write the message
    if (!NAVFileExists(NAV_LOGS_DIRECTORY, file)) {
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

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                    __NAV_FOUNDATION_ERRORLOGUTILS__,
                                    'NAVErrorLogToFile',
                                    "'Current log file size: ', itoa(size)")

    // Check the size to see if we first need to rotate the log file
    if ((size + length_array(log)) > NAV_MAX_LOG_FILE_SIZE) {
        NAVErrorLogFileRotate(file)
        return NAVErrorLogToFile(file, level, value)
    }

    // Finally, append the current log message
    return NAVFileAppendLine("NAV_LOGS_DIRECTORY, '/', file", log)
}


define_function slong NAVErrorLogFileRotate(char file[]) {
    stack_var integer count

    if (NAVFileExists(NAV_LOGS_DIRECTORY, "file, '.old.', itoa(NAV_MAX_OLD_LOG_FILES)")) {
        NAVFileDelete("NAV_LOGS_DIRECTORY, '/', file, '.old.', itoa(NAV_MAX_OLD_LOG_FILES)")
    }

    for (count = 1; count < NAV_MAX_OLD_LOG_FILES; count++) {
        if (!NAVFileExists(NAV_LOGS_DIRECTORY, "file, '.old.', itoa(count)")) {
            continue
        }

        NAVFileRename("NAV_LOGS_DIRECTORY, '/', file, '.old.', itoa(count)", "file, '.old.', itoa(count + 1)")
    }

    return NAVFileRename("NAV_LOGS_DIRECTORY, '/', file", "file, '.old.1'")
}


#END_IF // __NAV_FOUNDATION_ERRORLOGUTILS__
