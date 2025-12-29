PROGRAM_NAME='NAVFoundation.LogicEngine.h'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

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

#IF_NOT_DEFINED __NAV_FOUNDATION_LOGICENGINE_H__
#DEFINE __NAV_FOUNDATION_LOGICENGINE_H__ 'NAVFoundation.LogicEngine.h'

#include 'NAVFoundation.Core.h.axi'


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


DEFINE_TYPE

struct _NAVLogicEngine {
    long Ticks[MAX_NAV_LOGIC_ENGINE_TICKS]      // 24 bytes (offset 0, 6 * 4)

    char IsRunning                              // 1 byte (offset 24)
    integer PreviousEventId                     // 2 bytes (offset 25)

    char EventNames[NAV_LOGIC_ENGINE_NUMBER_OF_EVENTS][NAV_MAX_CHARS] // 150 bytes (offset 27, 3 * 50)
}                                               // Total: 177 bytes (no padding needed)


struct _NAVLogicEngineEvent {
    integer Id                                  // 2 bytes (offset 0)
    char Name[NAV_MAX_CHARS]                    // 50 bytes (offset 2)
}                                               // Total: 52 bytes (no padding needed)


#END_IF // __NAV_FOUNDATION_LOGICENGINE_H__
