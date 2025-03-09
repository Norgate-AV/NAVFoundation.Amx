PROGRAM_NAME='NAVFoundation.LogicEngine'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_LOGICENGINE__
#DEFINE __NAV_FOUNDATION_LOGICENGINE__ 'NAVFoundation.LogicEngine'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.ArrayUtils.axi'
#include 'NAVFoundation.TimelineUtils.axi'


DEFINE_CONSTANT

constant long TL_NAV_LOGIC_ENGINE                   = 301

constant long NAV_LOGIC_ENGINE_TICK                 = 200

constant integer NAV_LOGIC_ENGINE_NUMBER_OF_EVENTS  = 3
constant integer NAV_LOGIC_ENGINE_EVENT_ID_QUERY    = 1
constant integer NAV_LOGIC_ENGINE_EVENT_ID_ACTION   = 2
constant integer NAV_LOGIC_ENGINE_EVENT_ID_IDLE     = 3

constant char NAV_LOGIC_ENGINE_EVENT_QUERY[]        = 'query'
constant char NAV_LOGIC_ENGINE_EVENT_ACTION[]       = 'action'
constant char NAV_LOGIC_ENGINE_EVENT_IDLE[]         = 'idle'

constant integer MAX_NAV_LOGIC_ENGINE_TICKS         = 6

constant integer NAV_LOGIC_ENGINE_EVENT_IDS[]       =   {
                                                            NAV_LOGIC_ENGINE_EVENT_ID_QUERY,
                                                            NAV_LOGIC_ENGINE_EVENT_ID_ACTION,
                                                            NAV_LOGIC_ENGINE_EVENT_ID_ACTION,
                                                            NAV_LOGIC_ENGINE_EVENT_ID_ACTION,
                                                            NAV_LOGIC_ENGINE_EVENT_ID_ACTION,
                                                            NAV_LOGIC_ENGINE_EVENT_ID_IDLE
                                                        }


// #DEFINE USING_NAV_LOGIC_ENGINE_EVENT_CALLBACK
// define_function NAVLogicEngineEventCallback(_NAVLogicEngineEvent args) {}


DEFINE_TYPE

struct _NAVLogicEngineRuntime {
    double Milliseconds
    char TimespanString[NAV_MAX_BUFFER]
}


struct _NAVLogicEngineTimer {
    double Duration
    long Ticks[MAX_NAV_LOGIC_ENGINE_TICKS]
}


struct _NAVLogicEngine {
    _NAVLogicEngineTimer Timer
    _NAVLogicEngineRuntime Runtime

    char IsRunning
    integer PreviousEventId

    char EventNames[NAV_LOGIC_ENGINE_NUMBER_OF_EVENTS][NAV_MAX_CHARS]
}


struct _NAVLogicEngineEvent {
    _NAVLogicEngine Engine
    ttimeline Timeline
    integer Id
    char Name[NAV_MAX_CHARS]
}


DEFINE_VARIABLE

volatile _NAVLogicEngine engine


define_function NAVLogicEngineStart() {
    if (engine.IsRunning) {
        return
    }

    if (NAVTimelineStart(TL_NAV_LOGIC_ENGINE, engine.Timer.Ticks, TIMELINE_RELATIVE, TIMELINE_REPEAT) != 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LOGICENGINE__,
                                    'NAVLogicEngineStart',
                                    'Failed to start LogicEngine')

        return
    }

    engine.IsRunning = true
}


define_function NAVLogicEngineStop() {
    if (!engine.IsRunning) {
        return
    }

    if (NAVTimelineStop(TL_NAV_LOGIC_ENGINE) != 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LOGICENGINE__,
                                    'NAVLogicEngineStop',
                                    'Failed to stop LogicEngine')

        return
    }

    engine.IsRunning = false
}


define_function NAVLogicEngineRestart() {
    if (!engine.IsRunning) {
        return
    }

    NAVTimelineSetValue(TL_NAV_LOGIC_ENGINE, 0)
}


define_function NAVLogicEngineCopyEvent(_NAVLogicEngineEvent source, _NAVLogicEngineEvent destination) {
    destination.Id = source.Id
    destination.Name = source.Name
    destination.Timeline = source.Timeline
    destination.Engine = source.Engine
}


define_function char[NAV_MAX_CHARS] NAVLogicEngineGetEventName(_NAVLogicEngine engine, integer id) {
    return engine.EventNames[id]
}


define_function integer NAVLogicEngineGetEventId(ttimeline args) {
    return NAV_LOGIC_ENGINE_EVENT_IDS[args.sequence]
}


define_function double NAVLogicEngineGetRuntime(_NAVLogicEngineTimer timer, ttimeline args) {
    return (timer.Duration * args.Repetition) + args.Time
}


define_function NAVLogicEngineDrive(_NAVLogicEngine engine, ttimeline args) {
    stack_var _NAVLogicEngineEvent event

    engine.Runtime.Milliseconds = NAVLogicEngineGetRuntime(engine.Timer, args)
    engine.Runtime.TimespanString = NAVGetTimeSpan(engine.Runtime.Milliseconds)

    event.Id = NAVLogicEngineGetEventId(args)
    event.Name = NAVLogicEngineGetEventName(engine, event.Id)
    event.Timeline = args
    event.Engine = engine

    #IF_DEFINED USING_NAV_LOGIC_ENGINE_EVENT_CALLBACK
    NAVLogicEngineEventCallback(event)
    #END_IF

    engine.PreviousEventId = event.Id
}


define_function NAVLogicEngineInit(_NAVLogicEngine engine) {
    stack_var integer x

    engine.IsRunning = false
    engine.Runtime.Milliseconds = 0
    engine.Runtime.TimespanString = ''
    engine.PreviousEventId = 0
    engine.EventNames[NAV_LOGIC_ENGINE_EVENT_ID_QUERY] = NAV_LOGIC_ENGINE_EVENT_QUERY
    engine.EventNames[NAV_LOGIC_ENGINE_EVENT_ID_ACTION] = NAV_LOGIC_ENGINE_EVENT_ACTION
    engine.EventNames[NAV_LOGIC_ENGINE_EVENT_ID_IDLE] = NAV_LOGIC_ENGINE_EVENT_IDLE

    for (x = 1; x <= length_array(NAV_LOGIC_ENGINE_EVENT_IDS); x++) {
        engine.Timer.Ticks[x] = NAV_LOGIC_ENGINE_TICK
    }

    set_length_array(engine.Timer.Ticks, length_array(NAV_LOGIC_ENGINE_EVENT_IDS))
    engine.Timer.Duration = NAVArraySumLong(engine.Timer.Ticks)
}


DEFINE_START {
    NAVLogicEngineInit(engine)
}


DEFINE_EVENT

timeline_event[TL_NAV_LOGIC_ENGINE] {
    NAVLogicEngineDrive(engine, timeline)
}


#END_IF // __NAV_FOUNDATION_LOGICENGINE__
