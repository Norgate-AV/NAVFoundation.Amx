PROGRAM_NAME='NAVFoundation.LogicEngine'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Solutions Ltd

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

#IF_NOT_DEFINED __NAV_FOUNDATION_LOGICENGINE__
#DEFINE __NAV_FOUNDATION_LOGICENGINE__ 'NAVFoundation.LogicEngine'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


DEFINE_CONSTANT

constant long TL_NAV_LOGIC_ENGINE                   = 301

constant long NAV_LOGIC_ENGINE_TICK                 = 200

constant long NAV_LOGIC_ENGINE_EVENT_ID_QUERY       = 1
constant long NAV_LOGIC_ENGINE_EVENT_ID_ACTION      = 2
constant long NAV_LOGIC_ENGINE_EVENT_ID_IDLE        = 3

constant char NAV_LOGIC_ENGINE_EVENT_QUERY[]        = 'query'
constant char NAV_LOGIC_ENGINE_EVENT_ACTION[]       = 'action'
constant char NAV_LOGIC_ENGINE_EVENT_IDLE[]         = 'idle'
constant char NAV_LOGIC_ENGINE_EVENT_NAMES[]        =   {
                                                            NAV_LOGIC_ENGINE_EVENT_QUERY,
                                                            NAV_LOGIC_ENGINE_EVENT_ACTION,
                                                            NAV_LOGIC_ENGINE_EVENT_IDLE
                                                        }

constant long NAV_LOGIC_ENGINE_EVENTS[]             =   {
                                                            NAV_LOGIC_ENGINE_EVENT_QUERY,
                                                            NAV_LOGIC_ENGINE_EVENT_ACTION,
                                                            NAV_LOGIC_ENGINE_EVENT_ACTION,
                                                            NAV_LOGIC_ENGINE_EVENT_ACTION,
                                                            NAV_LOGIC_ENGINE_EVENT_ACTION,
                                                            NAV_LOGIC_ENGINE_EVENT_IDLE
                                                        }


// #DEFINE USING_NAV_LOGIC_ENGINE_EVENT_CALLBACK
// define_function NAVLogicEngineEventCallback(_NAVLogicEngineEvent args) {}


DEFINE_TYPE

struct _NAVLogicEngineEvent {
    integer Id
    char Name[NAV_MAX_CHARS]
    ttimeline Timeline
}


DEFINE_VARIABLE

volatile long navLogicEngineTicks[] =   {
                                            NAV_LOGIC_ENGINE_TICK,
                                            NAV_LOGIC_ENGINE_TICK,
                                            NAV_LOGIC_ENGINE_TICK,
                                            NAV_LOGIC_ENGINE_TICK,
                                            NAV_LOGIC_ENGINE_TICK,
                                            NAV_LOGIC_ENGINE_TICK
                                        }


define_function NAVLogicEngineStart() {
    NAVTimelineStart(TL_NAV_LOGIC_ENGINE, navLogicEngineTicks, TIMELINE_RELATIVE, TIMELINE_REPEAT)
}


define_function NAVLogicEngineStop() {
    NAVTimelineStop(TL_NAV_LOGIC_ENGINE)
}


define_function NAVLogicEngineRestart() {
    timeline_set(TL_NAV_LOGIC_ENGINE, 0)
}


define_function NAVLogicEngineDrive(ttimeline args) {
    stack_var _NAVLogicEngineEvent event

    event.Id = NAV_LOGIC_ENGINE_EVENTS[args.sequence]
    event.Name = NAV_LOGIC_ENGINE_EVENT_NAMES[event.Id]
    event.Timeline = args

    #IF_DEFINED USING_NAV_LOGIC_ENGINE_EVENT_CALLBACK
    NAVLogicEngineEventCallback(event)
    #END_IF
}


DEFINE_EVENT

timeline_event[TL_NAV_LOGIC_ENGINE] {
    NAVLogicEngineDrive(timeline)
}


#END_IF // __NAV_FOUNDATION_LOGICENGINE__
