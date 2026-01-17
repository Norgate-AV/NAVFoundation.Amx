PROGRAM_NAME='NAVFoundation.Redis'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_REDIS__
#DEFINE __NAV_FOUNDATION_REDIS__ 'NAVFoundation.Redis'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Redis.h.axi'


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildCommand(char args[][]) {
    stack_var char payload[NAV_REDIS_MAX_COMMAND_LENGTH]
    stack_var integer x
    stack_var integer count

    payload = ''
    count = max_length_array(args)

    if (count <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REDIS__,
                                    'NAVRedisBuildCommand',
                                    'Received empty array of arguments')

        return payload
    }

    payload = "'*', itoa(count), NAV_CR, NAV_LF"

    for (x = 1; x <= count; x++) {
        payload = "payload, '$', itoa(length_array(args[x])), NAV_CR, NAV_LF"
        payload = "payload, args[x], NAV_CR, NAV_LF"
    }

    return payload
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildGetCommand(char key[]) {
    stack_var char args[2][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'GET'
    args[2] = key

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildSetCommand(char key[], char value[]) {
    stack_var char args[3][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'SET'
    args[2] = key
    args[3] = value

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildSubscribeCommand(char channel[]) {
    stack_var char args[2][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'SUBSCRIBE'
    args[2] = channel

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildPublishCommand(char channel[], char message[]) {
    stack_var char args[3][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'PUBLISH'
    args[2] = channel
    args[3] = message

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildUnsubscribeCommand(char channel[]) {
    stack_var char args[2][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'UNSUBSCRIBE'
    args[2] = channel

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildUnsubscribeAllCommand() {
    stack_var char args[1][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'UNSUBSCRIBE'

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildPingCommand() {
    stack_var char args[1][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'PING'

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildWatchCommand(char key[]) {
    stack_var char args[2][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'WATCH'
    args[2] = key

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildUnwatchCommand() {
    stack_var char args[1][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'UNWATCH'

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildMultiCommand() {
    stack_var char args[1][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'MULTI'

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildExecCommand() {
    stack_var char args[1][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'EXEC'

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildDiscardCommand() {
    stack_var char args[1][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'DISCARD'

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildQuitCommand() {
    stack_var char args[1][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'QUIT'

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildAuthCommand(char password[]) {
    stack_var char args[2][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'AUTH'
    args[2] = password

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildPatternSubscribeCommand(char pattern[]) {
    stack_var char args[2][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'PSUBSCRIBE'
    args[2] = pattern

    return NAVRedisBuildCommand(args)
}


define_function char[NAV_REDIS_MAX_COMMAND_LENGTH] NAVRedisBuildPatternUnsubscribeCommand(char pattern[]) {
    stack_var char args[2][NAV_REDIS_MAX_COMMAND_ARG_LENGTH]

    args[1] = 'PUNSUBSCRIBE'
    args[2] = pattern

    return NAVRedisBuildCommand(args)
}


#END_IF // __NAV_FOUNDATION_REDIS__
