PROGRAM_NAME='NAVFoundation.Stopwatch'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_STOPWATCH__
#DEFINE __NAV_FOUNDATION_STOPWATCH__ 'NAVFoundation.Stopwatch'

#include 'NAVFoundation.TimelineUtils.axi'
#include 'NAVFoundation.Stopwatch.h.axi'


/**
 * @function NAVStopwatchStart
 * @public
 * @description Starts the stopwatch timer by initializing and starting a timeline.
 * If the stopwatch is already running, it will be reset and restarted.
 *
 * @returns {long} Always returns 0
 *
 * @example
 * NAVStopwatchStart()
 * // Perform operations to be timed
 * elapsed = NAVStopwatchStop()
 *
 * @note The stopwatch uses a 1ms precision timeline
 * @see NAVStopwatchStop
 * @see NAVStopwatchIsRunning
 */
define_function long NAVStopwatchStart() {
    NAVTimelineStart(
        TL_STOPWATCH,
        TL_STOPWATCH_INTERVAL,
        TIMELINE_ABSOLUTE,
        TIMELINE_REPEAT
    )
}


/**
 * @function NAVStopwatchStop
 * @public
 * @description Stops the stopwatch and returns the elapsed time in milliseconds.
 * If the stopwatch is not running, returns 0.
 *
 * @returns {long} Elapsed time in milliseconds since the stopwatch was started
 *
 * @example
 * NAVStopwatchStart()
 * // Perform operations to be timed
 * elapsed = NAVStopwatchStop()
 * NAVLog("'Operation took ', itoa(elapsed), ' ms to complete'")
 *
 * @see NAVStopwatchStart
 */
define_function long NAVStopwatchStop() {
    stack_var long elapsed

    elapsed = NAVTimelineGetValue(TL_STOPWATCH)
    NAVTimelineStop(TL_STOPWATCH)

    return elapsed
}


/**
 * @function NAVStopwatchIsRunning
 * @public
 * @description Checks if the stopwatch is currently running.
 *
 * @returns {char} True if the stopwatch is running, false otherwise
 *
 * @example
 * if (NAVStopwatchIsRunning()) {
 *     // Stopwatch is running
 *     elapsed = NAVStopwatchStop()
 * } else {
 *     // Stopwatch is not running
 *     NAVStopwatchStart()
 * }
 *
 * @see NAVStopwatchStart
 * @see NAVStopwatchStop
 */
define_function char NAVStopwatchIsRunning() {
    return timeline_active(TL_STOPWATCH) > 0
}


#END_IF // __NAV_FOUNDATION_STOPWATCH__
