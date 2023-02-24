PROGRAM_NAME='NAVFoundation.ErrorLogUtils'

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
#DEFINE __NAV_FOUNDATION_ERRORLOGUTILS__

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

constant long NAV_LOG_TYPE_ERROR     = AMX_ERROR
constant long NAV_LOG_TYPE_WARNING   = AMX_WARNING
constant long NAV_LOG_TYPE_INFO      = AMX_INFO
constant long NAV_LOG_TYPE_DEBUG     = AMX_DEBUG


define_function char[NAV_MAX_CHARS] NAVGetLogType(long type) {
    switch (type) {
        case NAV_LOG_TYPE_ERROR: {
            return 'Error'
        }
        case NAV_LOG_TYPE_WARNING: {
            return 'Warning'
        }
        case NAV_LOG_TYPE_INFO: {
            return 'Info'
        }
        case NAV_LOG_TYPE_DEBUG: {
            return 'Debug'
        }
        default: {
            return NAVGetLogType(NAV_LOG_TYPE_INFO)
        }
    }
}

define_function char[NAV_MAX_BUFFER] NAVFormatFunction(char libraryName[], char functionName[]) {
    return "libraryName, '.', functionName, '()'"
}


define_function char[NAV_MAX_BUFFER] NAVFormatLog(char moduleName[], char value[]) {
    return "'Module ', moduleName, ': ', value"
}


define_function NAVErrorLog(long type, char moduleName[], char value[]) {    
    switch (type) {
        case NAV_LOG_TYPE_ERROR: 
        case NAV_LOG_TYPE_WARNING:
        case NAV_LOG_TYPE_INFO:
        case NAV_LOG_TYPE_DEBUG: {
            amx_log(type, NAVFormatLog(moduleName, value))
        }
        default: {
            NAVErrorLog(NAV_LOG_TYPE_ERROR, moduleName, value)
        }
    }
}


#END_IF // __NAV_FOUNDATION_ERRORLOGUTILS__