PROGRAM_NAME='NAVFoundation.EnovaDvxBase'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ENOVA_DVX_BASE__
#DEFINE __NAV_FOUNDATION_ENOVA_DVX_BASE__ 'NAVFoundation.EnovaDvxBase'


// #DEFINE USING_NAV_ENOVA_LEVEL_EVENT_CALLBACK
// define_function NAVEnovaLevelEventCallback(tlevel level) {}

// #DEFINE USING_NAV_ENOVA_CHANNEL_EVENT_CALLBACK
// define_function NAVEnovaChannelEventCallback(tchannel channel) {}

// #DEFINE USING_NAV_ENOVA_ONLINE_DATA_EVENT_CALLBACK
// define_function NAVEnovaOnlineDataEventCallback(tdata data) {}


DEFINE_DEVICE

#IF_NOT_DEFINED vdvEnovaDvx
vdvEnovaDvx       = 33101:1:0
#END_IF


DEFINE_CONSTANT

#IF_NOT_DEFINED DVA_ENOVA
constant dev DVA_ENOVA[]    =   {
                                    5002:1:0,
                                    5002:2:0,
                                    5002:3:0,
                                    5002:4:0,
                                    5002:5:0,
                                    5002:6:0,
                                    5002:7:0,
                                    5002:8:0,
                                    5002:9:0,
                                    5002:10:0,
                                    5002:11:0,
                                    5002:12:0,
                                    5002:13:0,
                                    5002:14:0,
                                    5002:15:0
                                }
#END_IF


DEFINE_VARIABLE


#include 'NAVFoundation.Enova.axi'
#include 'NAVFoundation.EnovaEvents.axi'


DEFINE_START {

}


define_module 'mEnovaDVX' mEnovaDvxComm(vdvEnovaDvx, DVA_ENOVA[1])


DEFINE_EVENT


#END_IF // __NAV_FOUNDATION_ENOVA_DVX_BASE__
