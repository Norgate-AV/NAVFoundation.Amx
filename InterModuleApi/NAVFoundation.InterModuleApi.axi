PROGRAM_NAME='NAVFoundation.InterModuleApi'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_INTERMODULE_API__
#DEFINE __NAV_FOUNDATION_INTERMODULE_API__ 'NAVFoundation.Http.h'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

constant char OBJECT_COMMAND_MESSAGE_HEADER[] = 'COMMAND_MSG'
constant char OBJECT_RESPONSE_MESSAGE_HEADER[] = 'RESPONSE_MSG'
constant char OBJECT_QUERY_MESSAGE_HEADER[] = 'POLL_MSG'
constant char OBJECT_INIT_MESSAGE_HEADER[] = 'INIT'
constant char OBJECT_INIT_DONE_MESSAGE_HEADER[] = 'INIT_DONE'
constant char OBJECT_REGISTRATION_MESSAGE_HEADER[] = 'REGISTER'


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiBuildCommand(char header[], char body[]) {
    return "header, '<', body, '>'"
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetRegisterCommand(integer id) {
    return NAVInterModuleApiBuildCommand('REGISTER', itoa(id))
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetInitCommand(integer id) {
    return NAVInterModuleApiBuildCommand('INIT', itoa(id))
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetInitDoneCommand() {
    return NAVInterModuleApiBuildCommand('INIT_DONE', '')
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetCommandMessageCommand() {
    return NAVInterModuleApiBuildCommand('COMMAND_MSG', '')
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetPollMessageCommand() {
    return NAVInterModuleApiBuildCommand('POLL_MSG', '')
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetResponseOkCommand() {
    return NAVInterModuleApiBuildCommand('RESPONSE_OK', '')
}


define_function integer GetObjectId(char buffer[]) {
    if (!NAVContains(buffer, '|')) {
        return atoi(NAVGetStringBetween(buffer, '<', '>'))
    }

    return atoi(NAVGetStringBetween(buffer, '<', '|'))
}


define_function char[NAV_MAX_BUFFER] GetObjectMessage(char buffer[]) {
    return NAVGetStringBetween(buffer, '|', '>')
}


define_function char[NAV_MAX_BUFFER] GetObjectFullMessage(char buffer[]) {
    return NAVGetStringBetween(buffer, '<', '>')
}


define_function char[NAV_MAX_BUFFER] BuildObjectMessage(char header[], integer id, char payload[]) {
    if (!length_array(payload)) {
        return "header, '-<', itoa(id), '>'"
    }

    return "header, '-<', itoa(id), '|', payload, '>'"
}


define_function char[NAV_MAX_BUFFER] BuildObjectResponseMessage(char data[]) {
    return "OBJECT_RESPONSE_MESSAGE_HEADER, '<', data, '>'"
}



#END_IF     // __NAV_FOUNDATION_INTERMODULE_API__
