PROGRAM_NAME='NAVFoundation.Redis.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_REDIS_H__
#DEFINE __NAV_FOUNDATION_REDIS_H__ 'NAVFoundation.Redis.h'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

#IF_NOT_DEFINED NAV_REDIS_PORT
constant integer NAV_REDIS_PORT = 6379
#END_IF

constant integer NAV_REDIS_SUCCESS              = 0
constant integer NAV_REDIS_ERROR_INCORRECT_TYPE = 1

#IF_NOT_DEFINED NAV_REDIS_MAX_COMMAND_LENGTH
constant integer NAV_REDIS_MAX_COMMAND_LENGTH = 16000
#END_IF

#IF_NOT_DEFINED NAV_REDIS_MAX_COMMAND_ARG_LENGTH
constant integer NAV_REDIS_MAX_COMMAND_ARG_LENGTH = 1024
#END_IF


#END_IF // __NAV_FOUNDATION_REDIS_H__
