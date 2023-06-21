PROGRAM_NAME='NAVFoundation.ErrorLogUtils.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ERRORLOGUTILS_H__
#DEFINE __NAV_FOUNDATION_ERRORLOGUTILS_H__ 'NAVFoundation.ErrorLogUtils.h'


DEFINE_CONSTANT

constant long NAV_LOG_LEVEL_ERROR     = AMX_ERROR
constant long NAV_LOG_LEVEL_WARNING   = AMX_WARNING
constant long NAV_LOG_LEVEL_INFO      = AMX_INFO
constant long NAV_LOG_LEVEL_DEBUG     = AMX_DEBUG

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
