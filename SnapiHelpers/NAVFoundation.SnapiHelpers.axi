PROGRAM_NAME='NAVFoundation.SnapiHelpers'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_SNAPIHELPERS__
#DEFINE __NAV_FOUNDATION_SNAPIHELPERS__ 'NAVFoundation.SnapiHelpers'

#include 'NAVFoundation.Core.axi'


define_function NAVSwitch(dev device, integer input, integer output, integer level) {
    if(output > 0) {
        NAVCommand(device, "'SWITCH-', itoa(input), ',', itoa(output), ',', NAV_SWITCH_LEVELS[level]")
    }
    else {
        NAVCommand(device, "'SWITCH-', itoa(input), ',', NAV_SWITCH_LEVELS[level]")
    }
}


define_function NAVInput(dev device, char input[]) {
    NAVCommand(device, "'INPUT-', input")
}


define_function NAVInputArray(dev device[], char input[]) {
    NAVCommandArray(device, "'INPUT-', input")
}


define_function integer NAVGetPower(dev device) {
    return [device, POWER_FB]
}


define_function integer NAVGetVolumeMute(dev device) {
    return [device, VOL_MUTE_FB]
}


define_function NAVParseSnapiMessage(char data[], _NAVSnapiMessage message) {
    stack_var char dataCopy[NAV_MAX_BUFFER]
    stack_var integer count

    if (!length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SNAPIHELPERS__,
                                    'NAVParseSnapiMessage',
                                    'Invalid argument. The provided argument "data" is an empty string')

        return
    }

    dataCopy = data

    if (!NAVContains(dataCopy, '-')) {
        message.Header = dataCopy
        return
    }

    message.Header = NAVStripRight(remove_string(dataCopy, '-', 1), 1)

    if (!length_array(dataCopy)) {
        return
    }

    count = 0
    while (length_array(dataCopy)) {
        stack_var char byte
        stack_var char parameter[255]

        byte = get_buffer_char(dataCopy)

        switch (byte) {
            case '"': {
                parameter = NAVParseEscapedSnapiMessageParameter(dataCopy)
            }
            case ',': {
                parameter = ''
            }
            default: {
                dataCopy = "byte, dataCopy"
                parameter = NAVParseSnapiMessageParamter(dataCopy)
            }
        }

        count++
        set_length_array(message.Parameter, count)
        message.Parameter[count] = parameter
        message.ParameterCount = count
    }
}


define_function char[255] NAVParseSnapiMessageParamter(char data[]) {
    if (NAVContains(data, ',')) {
        return NAVStripRight(remove_string(data, ',', 1), 1)
    }

    return get_buffer_string(data, length_array(data))
}


define_function char[255] NAVParseEscapedSnapiMessageParameter(char data[]) {
    stack_var integer x
    stack_var char endings[2][3]

    endings[1] = '"",'
    endings[2] = '",'

    for (x = 1; x <= max_length_array(endings); x++) {
        stack_var integer index

        index = NAVIndexOf(data, endings[x], 1)

        if (index) {
            stack_var integer end

            end = index + length_array(endings[x])

            return NAVStripRight(get_buffer_string(data, end), 2)
        }
    }

    return NAVStripRight(get_buffer_string(data, length_array(data)), 1)
}


define_function NAVSnapiMessageLog(_NAVSnapiMessage message) {
    stack_var integer count

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                __NAV_FOUNDATION_SNAPIHELPERS__,
                                'NAVSnapiMessageLog',
                                "'Parsed SNAPI Message:'")

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                __NAV_FOUNDATION_SNAPIHELPERS__,
                                'NAVSnapiMessageLog',
                                "'  Header: ', message.Header")

    count = length_array(message.Parameter)
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                __NAV_FOUNDATION_SNAPIHELPERS__,
                                'NAVSnapiMessageLog',
                                "'  Parameter Count: ', itoa(count)")
    if (count) {
        stack_var integer x

        for (x = 1; x <= count; x++) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                        __NAV_FOUNDATION_SNAPIHELPERS__,
                                        'NAVSnapiMessageLog',
                                        "'    Parameter ', itoa(x), ': ', message.Parameter[x]")
        }
    }
}


#END_IF // __NAV_FOUNDATION_SNAPIHELPERS__
