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
#DEFINE __NAV_FOUNDATION_INTERMODULE_API__ 'NAVFoundation.InterModuleApi.h'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

#IF_NOT_DEFINED MAX_OBJECTS
constant integer MAX_OBJECTS	= 100
#END_IF

#IF_NOT_DEFINED MAX_OBJECT_TAGS
constant integer MAX_OBJECT_TAGS	= 10
#END_IF

constant char OBJECT_COMMAND_MESSAGE_HEADER[] = 'COMMAND_MSG'
constant char OBJECT_RESPONSE_MESSAGE_HEADER[] = 'RESPONSE_MSG'
constant char OBJECT_QUERY_MESSAGE_HEADER[] = 'POLL_MSG'
constant char OBJECT_INIT_MESSAGE_HEADER[] = 'INIT'
constant char OBJECT_INIT_DONE_MESSAGE_HEADER[] = 'INIT_DONE'
constant char OBJECT_REGISTRATION_MESSAGE_HEADER[] = 'REGISTER'
constant char OBJECT_START_POLLING_MESSAGE_HEADER[] = 'START_POLLING'
constant char OBJECT_RESPONSE_OK_MESSAGE_HEADER[] = 'RESPONSE_OK'


DEFINE_TYPE

struct _ModuleObject {
    integer Id
    integer IsInitialized
    integer IsRegistered
    char Tag[MAX_OBJECT_TAGS][NAV_MAX_CHARS]
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiBuildCommand(char header[], char body[]) {
    return "header, '-<', body, '>'"
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetRegisterCommand(integer id) {
    return NAVInterModuleApiBuildCommand(OBJECT_REGISTRATION_MESSAGE_HEADER, itoa(id))
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetInitCommand(integer id) {
    return NAVInterModuleApiBuildCommand(OBJECT_INIT_MESSAGE_HEADER, itoa(id))
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetInitDoneCommand(integer id) {
    return NAVInterModuleApiBuildCommand(OBJECT_INIT_DONE_MESSAGE_HEADER, itoa(id))
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetCommandMessageCommand(char payload[]) {
    return NAVInterModuleApiBuildCommand(OBJECT_COMMAND_MESSAGE_HEADER, payload)
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetPollMessageCommand(char payload[]) {
    return NAVInterModuleApiBuildCommand(OBJECT_QUERY_MESSAGE_HEADER, payload)
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetResponseOkCommand(integer id) {
    return NAVInterModuleApiBuildCommand(OBJECT_RESPONSE_OK_MESSAGE_HEADER, itoa(id))
}


define_function NAVInterModuleApiInit(_ModuleObject object) {
    object.Id = 0
    object.IsInitialized = false
    object.IsRegistered = false
}


define_function integer NAVInterModuleApiGetObjectId(char buffer[]) {
    if (!NAVContains(buffer, '|')) {
        return atoi(NAVGetStringBetween(buffer, '<', '>'))
    }

    return atoi(NAVGetStringBetween(buffer, '<', '|'))
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetObjectMessage(char buffer[]) {
    return NAVGetStringBetween(buffer, '|', '>')
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetObjectFullMessage(char buffer[]) {
    return NAVGetStringBetween(buffer, '<', '>')
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiBuildObjectMessage(char header[], integer id, char payload[]) {
    if (!length_array(payload)) {
        return "header, '-<', itoa(id), '>'"
    }

    return "header, '-<', itoa(id), '|', payload, '>'"
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiBuildObjectResponseMessage(char data[]) {
    return "OBJECT_RESPONSE_MESSAGE_HEADER, '-<', data, '>'"
}


define_function char[NAV_MAX_BUFFER] NAVInterModuleApiGetObjectTagList(_ModuleObject object) {
    return NAVArrayJoinString(object.Tag, ',')
}


define_function NAVInterModuleApiSendObjectMessage(dev device, char payload[]) {
    NAVCommand(device, "payload")
}


define_function integer NAVInterModuleApiGetObjectRegistrationCount(_ModuleObject object[], integer maxCount) {
    stack_var integer x
    stack_var integer count

    count = 0

    for (x = 1; x <= maxCount; x++) {
        if (object[x].IsRegistered) {
            count++
        }
    }

    return count
}


#END_IF     // __NAV_FOUNDATION_INTERMODULE_API__
