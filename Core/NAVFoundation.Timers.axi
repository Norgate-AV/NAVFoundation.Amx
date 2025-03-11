PROGRAM_NAME='NAVFoundation.Timers'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TIMERS__
#DEFINE __NAV_FOUNDATION_TIMERS__ 'NAVFoundation.Timers'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.TimelineUtils.axi'
#include 'NAVFoundation.Timers.h.axi'


DEFINE_VARIABLE

volatile integer NAVBlinker = false


define_function integer NAVGlobalFeedbackTimelineStart() {
    return NAVTimelineStart(TL_NAV_FEEDBACK,
                            TL_NAV_FEEDBACK_INTERVAL,
                            TIMELINE_ABSOLUTE,
                            TIMELINE_REPEAT)
}


define_function integer NAVGlobalFeedbackTimelineStop() {
    return NAVTimelineStop(TL_NAV_FEEDBACK)
}


define_function integer NAVGlobalFeedbackTimelineReset() {
    return NAVTimelineReset(TL_NAV_FEEDBACK)
}


define_function integer NAVGlobalFeedbackTimelineIsRunning() {
    return NAVTimelineIsRunning(TL_NAV_FEEDBACK)
}


define_function integer NAVGlobalBlinkerTimelineStart() {
    return NAVTimelineStart(TL_NAV_BLINKER,
                            TL_NAV_BLINKER_INTERVAL,
                            TIMELINE_ABSOLUTE,
                            TIMELINE_REPEAT)
}


define_function integer NAVGlobalBlinkerTimelineStop() {
    return NAVTimelineStop(TL_NAV_BLINKER)
}


define_function integer NAVGlobalBlinkerTimelineReset() {
    return NAVTimelineReset(TL_NAV_BLINKER)
}


define_function integer NAVGlobalBlinkerTimelineIsRunning() {
    return NAVTimelineIsRunning(TL_NAV_BLINKER)
}


DEFINE_EVENT

timeline_event[TL_NAV_BLINKER] {
    NAVBlinker = !NAVBlinker
}


#END_IF // __NAV_FOUNDATION_TIMERS__
