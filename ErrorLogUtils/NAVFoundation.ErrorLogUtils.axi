/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Solutions Ltd

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


DEFINE_CONSTANT

constant integer NAV_LOG_LEVEL_ERROR     = AMX_ERROR
constant integer NAV_LOG_LEVEL_WARNING   = AMX_WARNING
constant integer NAV_LOG_LEVEL_INFO      = AMX_INFO
constant integer NAV_LOG_LEVEL_DEBUG     = AMX_DEBUG


define_function char[NAV_MAX_CHARS] NAVGetLogLevel(integer level) {
    switch (level) {
        case NAV_LOG_LEVEL_ERROR: {
            return 'Error'
        }
        case NAV_LOG_LEVEL_WARNING: {
            return 'Warning'
        }
        case NAV_LOG_LEVEL_INFO: {
            return 'Info'
        }
        case NAV_LOG_LEVEL_DEBUG: {
            return 'Debug'
        }
        default: {
            return NAVGetLogLevel(NAV_LOG_LEVEL_INFO)
        }
    }
}


define_function char[NAV_MAX_BUFFER] NAVFormatLibraryFunction(char libraryName[], char functionName[]) {
    return "libraryName, '.', functionName, '()'"
}


define_function char[NAV_MAX_BUFFER] NAVFormatLibraryFunctionLog(char libraryName[], char functionName[], char value[]) {
    return "NAVFormatLibraryFunction(libraryName, functionName), ' => ', value"
}


define_function char[NAV_MAX_BUFFER] NAVFormatLog(integer level, char value[]) {
    return "NAVGetLogLevel(level), ':: ', NAVFormatHex(value)"
}


define_function NAVErrorLog(integer level, char value[]) {
    switch (level) {
        case NAV_LOG_LEVEL_ERROR:
        case NAV_LOG_LEVEL_WARNING:
        case NAV_LOG_LEVEL_INFO:
        case NAV_LOG_LEVEL_DEBUG: {
            amx_log(level, NAVFormatLog(level, value))
        }
        default: {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, value)
        }
    }
}


#END_IF // __NAV_FOUNDATION_ERRORLOGUTILS__
