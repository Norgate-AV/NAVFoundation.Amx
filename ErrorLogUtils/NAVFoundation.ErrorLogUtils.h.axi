PROGRAM_NAME='NAVFoundation.ErrorLogUtils.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ERRORLOGUTILS_H__
#DEFINE __NAV_FOUNDATION_ERRORLOGUTILS_H__ 'NAVFoundation.ErrorLogUtils.h'


DEFINE_CONSTANT

/**
 * @constant NAV_MAX_LOG_FILE_SIZE
 * @description Maximum size of a log file in bytes before rotation occurs
 * @default 1,000,000 bytes (1MB)
 */
#IF_NOT_DEFINED NAV_MAX_LOG_FILE_SIZE
constant long NAV_MAX_LOG_FILE_SIZE     = 1000000 // 1MB
#END_IF

/**
 * @constant NAV_MAX_OLD_LOG_FILES
 * @description Maximum number of rotated log files to keep
 * @default 5 files
 */
#IF_NOT_DEFINED NAV_MAX_OLD_LOG_FILES
constant long NAV_MAX_OLD_LOG_FILES     = 5
#END_IF

/**
 * @constant NAV_LOGS_DIRECTORY
 * @description Directory where log files are stored
 * @default "/logs"
 */
#IF_NOT_DEFINED NAV_LOGS_DIRECTORY
constant char NAV_LOGS_DIRECTORY[] = '/logs'
#END_IF

/**
 * @constant NAV_LOG_FILE_NAME
 * @description Default filename for the log file
 * @default "system.log"
 */
#IF_NOT_DEFINED NAV_LOG_FILE_NAME
constant char NAV_LOG_FILE_NAME[] = 'system.log'
#END_IF

/**
 * @constant NAV_LOG_FILE_QUEUE_SIZE
 * @description Size of the queue for log messages waiting to be written to file
 * @default 100 messages
 */
#IF_NOT_DEFINED NAV_LOG_FILE_QUEUE_SIZE
constant long NAV_LOG_FILE_QUEUE_SIZE = 100
#END_IF

/**
 * @constant NAV_LOG_LEVEL_ERROR
 * @description Log level for error messages (highest severity)
 * @note Mapped to AMX_ERROR
 */
constant long NAV_LOG_LEVEL_ERROR       = AMX_ERROR

/**
 * @constant NAV_LOG_LEVEL_WARNING
 * @description Log level for warning messages
 * @note Mapped to AMX_WARNING
 */
constant long NAV_LOG_LEVEL_WARNING     = AMX_WARNING

/**
 * @constant NAV_LOG_LEVEL_INFO
 * @description Log level for informational messages
 * @note Mapped to AMX_INFO
 */
constant long NAV_LOG_LEVEL_INFO        = AMX_INFO

/**
 * @constant NAV_LOG_LEVEL_DEBUG
 * @description Log level for debug messages (lowest severity)
 * @note Mapped to AMX_DEBUG
 */
constant long NAV_LOG_LEVEL_DEBUG       = AMX_DEBUG

/**
 * @constant NAV_LOG_LEVELS
 * @description Array of string representations for each log level
 */
constant char NAV_LOG_LEVELS[][NAV_MAX_CHARS]   =   {
                                                        'ERROR',
                                                        'WARNING',
                                                        'INFO',
                                                        'DEBUG'
                                                    }

/**
 * @constant NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_TO
 * @description Type identifier for outgoing command messages
 */
constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_TO           = 1

/**
 * @constant NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_FROM
 * @description Type identifier for incoming command messages
 */
constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_FROM         = 2

/**
 * @constant NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_TO
 * @description Type identifier for outgoing string messages
 */
constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_TO            = 3

/**
 * @constant NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_FROM
 * @description Type identifier for incoming string messages
 */
constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_FROM          = 4

/**
 * @constant NAV_STANDARD_LOG_MESSAGE_TYPE_PARSING_COMMAND_FROM
 * @description Type identifier for parsing incoming command messages
 */
constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_PARSING_COMMAND_FROM = 5

/**
 * @constant NAV_STANDARD_LOG_MESSAGE_TYPE_PARSING_STRING_FROM
 * @description Type identifier for parsing incoming string messages
 */
constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_PARSING_STRING_FROM  = 6

/**
 * @constant NAV_STANDARD_LOG_MESSAGE_TYPE
 * @description Array of string representations for each standard log message type
 */
constant char NAV_STANDARD_LOG_MESSAGE_TYPE[][NAV_MAX_CHARS]    =   {
                                                                        'Command To',
                                                                        'Command From',
                                                                        'String To',
                                                                        'String From',
                                                                        'Parsing Command From',
                                                                        'Parsing String From'
                                                                    }


#END_IF // __NAV_FOUNDATION_ERRORLOGUTILS_H__
