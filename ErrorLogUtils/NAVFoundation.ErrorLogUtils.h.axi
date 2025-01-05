PROGRAM_NAME='NAVFoundation.ErrorLogUtils.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ERRORLOGUTILS_H__
#DEFINE __NAV_FOUNDATION_ERRORLOGUTILS_H__ 'NAVFoundation.ErrorLogUtils.h'


DEFINE_CONSTANT

#IF_NOT_DEFINED NAV_MAX_LOG_FILE_SIZE
constant long NAV_MAX_LOG_FILE_SIZE     = 1000000 // 1MB
#END_IF

#IF_NOT_DEFINED NAV_MAX_OLD_LOG_FILES
constant long NAV_MAX_OLD_LOG_FILES     = 5
#END_IF

#IF_NOT_DEFINED NAV_LOGS_DIRECTORY
constant char NAV_LOGS_DIRECTORY[] = '/logs'
#END_IF

#IF_NOT_DEFINED NAV_LOG_FILE_NAME
constant char NAV_LOG_FILE_NAME[] = 'system.log'
#END_IF

#IF_NOT_DEFINED NAV_LOG_FILE_QUEUE_SIZE
constant long NAV_LOG_FILE_QUEUE_SIZE = 100
#END_IF

constant long NAV_LOG_LEVEL_ERROR       = AMX_ERROR
constant long NAV_LOG_LEVEL_WARNING     = AMX_WARNING
constant long NAV_LOG_LEVEL_INFO        = AMX_INFO
constant long NAV_LOG_LEVEL_DEBUG       = AMX_DEBUG

constant char NAV_LOG_LEVELS[][NAV_MAX_CHARS]   =   {
                                                        'ERROR',
                                                        'WARNING',
                                                        'INFO',
                                                        'DEBUG'
                                                    }

constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_TO           = 1
constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_FROM         = 2
constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_TO            = 3
constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_FROM          = 4
constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_PARSING_COMMAND_FROM = 5
constant integer NAV_STANDARD_LOG_MESSAGE_TYPE_PARSING_STRING_FROM  = 6

constant char NAV_STANDARD_LOG_MESSAGE_TYPE[][NAV_MAX_CHARS]    =   {
                                                                        'Command To',
                                                                        'Command From',
                                                                        'String To',
                                                                        'String From',
                                                                        'Parsing Command From',
                                                                        'Parsing String From'
                                                                    }


#END_IF // __NAV_FOUNDATION_ERRORLOGUTILS_H__
