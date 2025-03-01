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

/**
 * @constant NAV_TIMELINE_INIT_ERROR_ID_ALREADY_IN_USE
 * @description Error code: The timeline ID is already in use
 */
constant integer NAV_TIMELINE_INIT_ERROR_ID_ALREADY_IN_USE              = 1

/**
 * @constant NAV_TIMELINE_INIT_ERROR_NOT_ARRAY_OF_LONG
 * @description Error code: The specified times parameter is not an array of long values
 */
constant integer NAV_TIMELINE_INIT_ERROR_NOT_ARRAY_OF_LONG              = 2

/**
 * @constant NAV_TIMELINE_INIT_ERROR_LENGTH_GREATER_THAN_ARRAY
 * @description Error code: The specified length is greater than the array size
 */
constant integer NAV_TIMELINE_INIT_ERROR_LENGTH_GREATER_THAN_ARRAY      = 3

/**
 * @constant NAV_TIMELINE_INIT_ERROR_OUT_OF_MEMORY
 * @description Error code: Out of memory when trying to create timeline
 */
constant integer NAV_TIMELINE_INIT_ERROR_OUT_OF_MEMORY                  = 4

/**
 * @constant NAV_TIMELINE_RUN_ERROR_INVALID_ID
 * @description Error code: The specified timeline ID is invalid
 */
constant integer NAV_TIMELINE_RUN_ERROR_INVALID_ID                      = 1

/**
 * @constant NAV_TIMELINE_RUN_ERROR_TIMER_VALUE_OUT_OF_RANGE
 * @description Error code: The specified timer value is out of range
 */
constant integer NAV_TIMELINE_RUN_ERROR_TIMER_VALUE_OUT_OF_RANGE        = 2


/**
 * @function NAVGetTimelineInitError
 * @public
 * @description Converts a timeline initialization error code to a human-readable error message.
 *
 * @param {integer} error - Error code from timeline initialization
 *
 * @returns {char[]} Human-readable error description
 *
 * @example
 * stack_var integer result
 * stack_var char errorMsg[NAV_MAX_BUFFER]
 *
 * result = NAVTimelineStart(TL_MY_TIMELINE, TL_MY_INTERVALS, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
 * if (result != 0) {
 *     errorMsg = NAVGetTimelineInitError(result)
 *     NAVLog("'Timeline initialization failed: ', errorMsg")
 * }
 */
define_function char[NAV_MAX_BUFFER] NAVGetTimelineInitError(integer error) {
    switch (error) {
        case NAV_TIMELINE_INIT_ERROR_ID_ALREADY_IN_USE:         { return 'Timeline ID already in use' }
        case NAV_TIMELINE_INIT_ERROR_NOT_ARRAY_OF_LONG:         { return 'Specified array is not an array of LONGs' }
        case NAV_TIMELINE_INIT_ERROR_LENGTH_GREATER_THAN_ARRAY: { return 'Specified length is greater than the length of the passed array' }
        case NAV_TIMELINE_INIT_ERROR_OUT_OF_MEMORY:             { return 'Out of memory' }
        default:                                                { return "'Unknown error: ', itoa(error)" }
    }
}


/**
 * @function NAVGetTimelineRunError
 * @public
 * @description Converts a timeline runtime error code to a human-readable error message.
 *
 * @param {integer} error - Error code from timeline runtime operation
 *
 * @returns {char[]} Human-readable error description
 *
 * @example
 * stack_var integer result
 * stack_var char errorMsg[NAV_MAX_BUFFER]
 *
 * result = NAVTimelineSetValue(TL_MY_TIMELINE, 5000)
 * if (result != 0) {
 *     errorMsg = NAVGetTimelineRunError(result)
 *     NAVLog("'Timeline operation failed: ', errorMsg")
 * }
 */
define_function char[NAV_MAX_BUFFER] NAVGetTimelineRunError(integer error) {
    switch (error) {
        case NAV_TIMELINE_RUN_ERROR_INVALID_ID:                 { return 'Specified timeline ID invalid' }
        case NAV_TIMELINE_RUN_ERROR_TIMER_VALUE_OUT_OF_RANGE:   { return 'Specified Timer value out of range' }
        default:                                                { return "'Unknown error: ', itoa(error)" }
    }
}


/**
 * @function NAVTimelineStart
 * @public
 * @description Creates and starts a timeline with the specified parameters.
 * If the timeline is already running, returns the active state without restarting.
 *
 * @param {long} id - Timeline ID to use
 * @param {long[]} times - Array of time intervals in milliseconds
 * @param {long} relative - Timeline mode: TIMELINE_ABSOLUTE or TIMELINE_RELATIVE
 * @param {long} mode - Timeline repeat mode: TIMELINE_ONCE or TIMELINE_REPEAT
 *
 * @returns {integer} 0 on success, >0 if already running, or error code on failure
 *
 * @example
 * stack_var long intervals[2] = {500, 1000}  // 500ms, then 1000ms
 * stack_var integer result
 *
 * result = NAVTimelineStart(TL_BLINK, intervals, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
 * if (result < 0) {
 *     NAVLog("'Failed to start timeline: ', NAVGetTimelineInitError(result)")
 * }
 *
 * @see NAVTimelineStop
 * @see NAVTimelinePause
 */
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


/**
 * @function NAVTimelineReload
 * @public
 * @description Reloads the time intervals for an active timeline.
 * If the timeline is not active, returns 0 without doing anything.
 *
 * @param {long} id - Timeline ID to reload
 * @param {long[]} times - New array of time intervals in milliseconds
 *
 * @returns {integer} 0 on success, or error code on failure
 *
 * @example
 * stack_var long newIntervals[1] = {250}  // Change to faster 250ms interval
 * stack_var integer result
 *
 * result = NAVTimelineReload(TL_BLINK, newIntervals)
 * if (result != 0) {
 *     NAVLog("'Failed to reload timeline: ', NAVGetTimelineInitError(result)")
 * }
 *
 * @see NAVTimelineStart
 */
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


/**
 * @function NAVTimelineStop
 * @public
 * @description Stops and removes a running timeline.
 * If the timeline is not active, returns 0 without doing anything.
 *
 * @param {long} id - Timeline ID to stop
 *
 * @returns {integer} 0 on success, or error code on failure
 *
 * @example
 * stack_var integer result
 *
 * result = NAVTimelineStop(TL_BLINK)
 * if (result != 0) {
 *     NAVLog("'Failed to stop timeline: ', NAVGetTimelineRunError(result)")
 * }
 *
 * @see NAVTimelineStart
 * @see NAVTimelinePause
 */
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


/**
 * @function NAVTimelinePause
 * @public
 * @description Pauses a running timeline without removing it.
 * If the timeline is not active, returns 0 without doing anything.
 *
 * @param {long} id - Timeline ID to pause
 *
 * @returns {integer} 0 on success, or error code on failure
 *
 * @example
 * stack_var integer result
 *
 * result = NAVTimelinePause(TL_BLINK)
 * if (result != 0) {
 *     NAVLog("'Failed to pause timeline: ', NAVGetTimelineRunError(result)")
 * }
 *
 * @see NAVTimelineStart
 * @see NAVTimelineStop
 */
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


/**
 * @function NAVTimelineSetValue
 * @public
 * @description Sets the current tick value of an active timeline.
 * If the timeline is not active, returns 0 without doing anything.
 *
 * @param {long} id - Timeline ID to modify
 * @param {long} value - New tick value to set
 *
 * @returns {integer} 0 on success, or error code on failure
 *
 * @example
 * stack_var integer result
 *
 * // Reset the timeline to 0
 * result = NAVTimelineSetValue(TL_COUNTER, 0)
 * if (result != 0) {
 *     NAVLog("'Failed to set timeline value: ', NAVGetTimelineRunError(result)")
 * }
 *
 * @see NAVTimelineGetValue
 */
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


/**
 * @function NAVTimelineGetValue
 * @public
 * @description Gets the current tick value of an active timeline.
 * If the timeline is not active, returns 0.
 *
 * @param {long} id - Timeline ID to query
 *
 * @returns {long} Current tick value, or 0 if timeline is not active
 *
 * @example
 * stack_var long currentTick
 *
 * currentTick = NAVTimelineGetValue(TL_COUNTER)
 * NAVLog("'Current timeline value: ', itoa(currentTick)")
 *
 * @see NAVTimelineSetValue
 */
define_function long NAVTimelineGetValue(long id) {
    stack_var integer result

    result = timeline_active(id)

    if (result == 0) {
        return result
    }

    return timeline_get(id)
}


#END_IF // __NAV_FOUNDATION_TIMELINEUTILS__
