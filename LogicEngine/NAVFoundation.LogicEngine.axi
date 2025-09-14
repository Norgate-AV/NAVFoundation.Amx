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

#include 'NAVFoundation.LogicEngine.h.axi'
#include 'NAVFoundation.TimelineUtils.axi'


// #DEFINE USING_NAV_LOGIC_ENGINE_EVENT_CALLBACK
// define_function NAVLogicEngineEventCallback(_NAVLogicEngineEvent args) {}

// !!! You must define the engine variable in your main .axs file !!!

// DEFINE_VARIABLE

// _NAVLogicEngine engine

// !!! You MUST define the event below in your main .axs file !!!

// DEFINE_EVENT

// timeline_event[TL_NAV_LOGIC_ENGINE] {
//     NAVLogicEngineDrive(engine, timeline) <-- <-- MUST MATCH THE VARIABLE NAME DECLARED FOR THE ENGINE
// }


define_function NAVLogicEngineStart(_NAVLogicEngine engine) {
    if (engine.IsRunning) {
        return
    }

    if (NAVTimelineStart(TL_NAV_LOGIC_ENGINE,
                            engine.Ticks,
                            TIMELINE_RELATIVE,
                            TIMELINE_REPEAT) != 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LOGICENGINE__,
                                    'NAVLogicEngineStart',
                                    'Failed to start LogicEngine')

        return
    }

    engine.IsRunning = true
}


define_function NAVLogicEngineStop(_NAVLogicEngine engine) {
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


define_function NAVLogicEngineRestart(_NAVLogicEngine engine) {
    if (!engine.IsRunning) {
        return
    }

    NAVTimelineSetValue(TL_NAV_LOGIC_ENGINE, 0)
}


define_function NAVLogicEngineCopyEvent(_NAVLogicEngineEvent source, _NAVLogicEngineEvent destination) {
    destination.Id = source.Id
    destination.Name = source.Name
}


define_function char[NAV_MAX_CHARS] NAVLogicEngineGetEventName(_NAVLogicEngine engine, integer id) {
    return engine.EventNames[id]
}


define_function integer NAVLogicEngineGetEventId(ttimeline args) {
    return NAV_LOGIC_ENGINE_EVENT_IDS[args.sequence]
}


define_function NAVLogicEngineDrive(_NAVLogicEngine engine, ttimeline args) {
    stack_var _NAVLogicEngineEvent event

    event.Id = NAVLogicEngineGetEventId(args)
    event.Name = NAVLogicEngineGetEventName(engine, event.Id)

    #IF_DEFINED USING_NAV_LOGIC_ENGINE_EVENT_CALLBACK
    NAVLogicEngineEventCallback(event)
    #END_IF

    engine.PreviousEventId = event.Id
}


define_function NAVLogicEngineInit(_NAVLogicEngine engine) {
    stack_var integer x

    engine.IsRunning = false
    engine.PreviousEventId = 0
    engine.EventNames[NAV_LOGIC_ENGINE_EVENT_ID_QUERY] = NAV_LOGIC_ENGINE_EVENT_QUERY
    engine.EventNames[NAV_LOGIC_ENGINE_EVENT_ID_ACTION] = NAV_LOGIC_ENGINE_EVENT_ACTION
    engine.EventNames[NAV_LOGIC_ENGINE_EVENT_ID_IDLE] = NAV_LOGIC_ENGINE_EVENT_IDLE

    for (x = 1; x <= length_array(NAV_LOGIC_ENGINE_EVENT_IDS); x++) {
        engine.Ticks[x] = NAV_LOGIC_ENGINE_TICK
    }

    set_length_array(engine.Ticks, length_array(NAV_LOGIC_ENGINE_EVENT_IDS))
}


#END_IF // __NAV_FOUNDATION_LOGICENGINE__
