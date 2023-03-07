/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2022 Norgate AV Solutions Ltd

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TIMELINEUTILS__
#DEFINE __NAV_FOUNDATION_TIMELINEUTILS__ 'NAVFoundation.TimelineUtils'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


DEFINE_CONSTANT

constant integer NAV_TIMELINE_INIT_ERROR_ID_ALREADY_IN_USE              = 1
constant integer NAV_TIMELINE_INIT_ERROR_NOT_ARRAY_OF_LONG              = 2
constant integer NAV_TIMELINE_INIT_ERROR_LENGTH_GREATER_THAN_ARRAY      = 3
constant integer NAV_TIMELINE_INIT_ERROR_OUT_OF_MEMORY                  = 4

constant integer NAV_TIMELINE_RUN_ERROR_INVALID_ID                      = 1
constant integer NAV_TIMELINE_RUN_ERROR_TIMER_VALUE_OUT_OF_RANGE        = 2


define_function NAVTimelineUtilsErrorLog(integer level, char functionName[], char message[]) {
    stack_var char log[NAV_MAX_BUFFER]

    log = NAVFormatLibraryFunctionLog(__NAV_FOUNDATION_TIMELINEUTILS__, functionName, message)
    NAVErrorLog(level, log)
}


define_function char[NAV_MAX_BUFFER] NAVGetTimelineInitError(integer error) {
    switch (error) {
        case NAV_TIMELINE_INIT_ERROR_ID_ALREADY_IN_USE:         { return 'Timeline ID already in use' }
        case NAV_TIMELINE_INIT_ERROR_NOT_ARRAY_OF_LONG:         { return 'Specified array is not an array of LONGs' }
        case NAV_TIMELINE_INIT_ERROR_LENGTH_GREATER_THAN_ARRAY: { return 'Specified length is greater than the length of the passed array' }
        case NAV_TIMELINE_INIT_ERROR_OUT_OF_MEMORY:             { return 'Out of memory' }
        default:                                                { return "'Unknown error: ', itoa(error)" }
    }
}


define_function char[NAV_MAX_BUFFER] NAVGetTimelineRunError(integer error) {
    switch (error) {
        case NAV_TIMELINE_RUN_ERROR_INVALID_ID:                 { return 'Specified timeline ID invalid' }
        case NAV_TIMELINE_RUN_ERROR_TIMER_VALUE_OUT_OF_RANGE:   { return 'Specified Timer value out of range' }
        default:                                                { return "'Unknown error: ', itoa(error)" }
    }
}


define_function NAVTimelineStart(long id, long times[], long relative, long mode) {
    stack_var integer result

    if (timeline_active(id)) {
        return
    }

    result = timeline_create(id, times, length_array(times), relative, mode)

    if (result != 0) {
        NAVTimelineUtilsErrorLog(NAV_LOG_LEVEL_ERROR,
                                'NAVTimelineStart',
                                "'Failed to create Timeline with ID ', itoa(id), ' : ', NAVGetTimelineInitError(result)")

        return
    }

    NAVTimelineUtilsErrorLog(NAV_LOG_LEVEL_DEBUG,
                            'NAVTimelineStart',
                            "'Created Timeline with ID ', itoa(id)")
}


define_function NAVTimelineReload(long id, long times[]) {
    stack_var integer result

    if (!timeline_active(id)) {
        return
    }

    result = timeline_reload(id, times, length_array(times))

    if (result != 0) {
        NAVTimelineUtilsErrorLog(NAV_LOG_LEVEL_ERROR,
                                'NAVTimelineReload',
                                "'Failed to reload Timeline with ID ', itoa(id), ' : ', NAVGetTimelineInitError(result)")

        return
    }

    NAVTimelineUtilsErrorLog(NAV_LOG_LEVEL_DEBUG,
                            'NAVTimelineReload',
                            "'Reloaded Timeline with ID ', itoa(id)")
}


define_function NAVTimelineStop(long id) {
    stack_var integer result

    if (!timeline_active(id)) {
        return
    }

    result = timeline_kill(id)

    if (result != 0) {
        NAVTimelineUtilsErrorLog(NAV_LOG_LEVEL_ERROR,
                                'NAVTimelineStop',
                                "'Failed to kill Timeline with ID ', itoa(id), ' : ', NAVGetTimelineRunError(result)")

        return
    }

    NAVTimelineUtilsErrorLog(NAV_LOG_LEVEL_DEBUG,
                            'NAVTimelineStop',
                            "'Killed Timeline with ID ', itoa(id)")
}


#END_IF // __NAV_FOUNDATION_TIMELINEUTILS__
