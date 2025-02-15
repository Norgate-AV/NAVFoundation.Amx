PROGRAM_NAME='NAVFoundation.TimelineUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TIMELINEUTILS__
#DEFINE __NAV_FOUNDATION_TIMELINEUTILS__ 'NAVFoundation.TimelineUtils'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

constant integer NAV_TIMELINE_INIT_ERROR_ID_ALREADY_IN_USE              = 1
constant integer NAV_TIMELINE_INIT_ERROR_NOT_ARRAY_OF_LONG              = 2
constant integer NAV_TIMELINE_INIT_ERROR_LENGTH_GREATER_THAN_ARRAY      = 3
constant integer NAV_TIMELINE_INIT_ERROR_OUT_OF_MEMORY                  = 4

constant integer NAV_TIMELINE_RUN_ERROR_INVALID_ID                      = 1
constant integer NAV_TIMELINE_RUN_ERROR_TIMER_VALUE_OUT_OF_RANGE        = 2


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


define_function integer NAVTimelineStart(long id, long times[], long relative, long mode) {
    stack_var integer result

    result = timeline_active(id)

    if (result > 0) {
        return result
    }

    result = timeline_create(id, times, length_array(times), relative, mode)

    if (result != 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_TIMELINEUTILS__,
                                    'NAVTimelineStart',
                                    "'Failed to create Timeline with ID ', itoa(id), ' : ', NAVGetTimelineInitError(result)")

        return result
    }

    return result
}


define_function integer NAVTimelineReload(long id, long times[]) {
    stack_var integer result

    result = timeline_active(id)

    if (result == 0) {
        return result
    }

    result = timeline_reload(id, times, length_array(times))

    if (result != 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_TIMELINEUTILS__,
                                    'NAVTimelineReload',
                                    "'Failed to reload Timeline with ID ', itoa(id), ' : ', NAVGetTimelineInitError(result)")

        return result
    }

    return result
}


define_function integer NAVTimelineStop(long id) {
    stack_var integer result

    result = timeline_active(id)

    if (result == 0) {
        return result
    }

    result = timeline_kill(id)

    if (result != 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_TIMELINEUTILS__,
                                    'NAVTimelineStop',
                                    "'Failed to kill Timeline with ID ', itoa(id), ' : ', NAVGetTimelineRunError(result)")

        return result
    }

    return result
}


define_function integer NAVTimelinePause(long id) {
    stack_var integer result

    result = timeline_active(id)

    if (result == 0) {
        return result
    }

    result = timeline_pause(id)

    if (result != 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_TIMELINEUTILS__,
                                    'NAVTimelinePause',
                                    "'Failed to pause Timeline with ID ', itoa(id), ' : ', NAVGetTimelineRunError(result)")

        return result
    }

    return result
}


define_function integer NAVTimelineSetValue(long id, long value) {
    stack_var integer result

    result = timeline_active(id)

    if (result == 0) {
        return result
    }

    result = timeline_set(id, value)

    if (result != 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_TIMELINEUTILS__,
                                    'NAVTimelineSetValue',
                                    "'Failed to set Timeline with ID ', itoa(id), ' to value ', itoa(value),' : ', NAVGetTimelineRunError(result)")

        return result
    }

    return result
}


define_function long NAVTimelineGetValue(long id) {
    stack_var integer result

    result = timeline_active(id)

    if (result == 0) {
        return result
    }

    return timeline_get(id)
}


#END_IF // __NAV_FOUNDATION_TIMELINEUTILS__
