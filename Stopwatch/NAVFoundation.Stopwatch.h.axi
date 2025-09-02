PROGRAM_NAME='NAVFoundation.Stopwatch.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_STOPWATCH_H__
#DEFINE __NAV_FOUNDATION_STOPWATCH_H__ 'NAVFoundation.Stopwatch.h'


DEFINE_CONSTANT

/**
 * @constant TL_STOPWATCH
 * @description Timeline ID for the stopwatch functionality.
 * This timeline is used to track elapsed time with millisecond precision.
 */
constant long TL_STOPWATCH = 1000

/**
 * @constant TL_STOPWATCH_INTERVAL
 * @description Interval for the stopwatch timeline in milliseconds.
 * Set to 1ms for precise time measurement.
 */
constant long TL_STOPWATCH_INTERVAL[] = { 1 }   // 1ms


#END_IF // __NAV_FOUNDATION_STOPWATCH_H__
