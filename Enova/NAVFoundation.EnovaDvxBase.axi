PROGRAM_NAME='NAVFoundation.EnovaDvxBase'

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
                                    5002:15:0,
                                    5002:16:0,
                                    5002:17:0,
                                    5002:18:0,
                                    5002:19:0,
                                    5002:20:0,
                                    5002:21:0,
                                    5002:22:0,
                                    5002:23:0,
                                    5002:24:0,
                                    5002:25:0,
                                    5002:26:0,
                                    5002:27:0,
                                    5002:28:0,
                                    5002:29:0,
                                    5002:30:0,
                                    5002:31:0,
                                    5002:32:0,
                                    5002:33:0,
                                    5002:34:0,
                                    5002:35:0,
                                    5002:36:0,
                                    5002:37:0,
                                    5002:38:0,
                                    5002:39:0,
                                    5002:40:0,
                                    5002:41:0,
                                    5002:42:0,
                                    5002:43:0,
                                    5002:44:0,
                                    5002:45:0,
                                    5002:46:0,
                                    5002:47:0,
                                    5002:48:0,
                                    5002:49:0,
                                    5002:50:0,
                                    5002:51:0,
                                    5002:52:0,
                                    5002:53:0,
                                    5002:54:0,
                                    5002:55:0,
                                    5002:56:0,
                                    5002:57:0,
                                    5002:58:0,
                                    5002:59:0,
                                    5002:60:0,
                                    5002:61:0,
                                    5002:62:0,
                                    5002:63:0,
                                    5002:64:0,
                                    5002:65:0,
                                    5002:66:0,
                                    5002:67:0,
                                    5002:68:0,
                                    5002:69:0,
                                    5002:70:0,
                                    5002:71:0,
                                    5002:72:0,
                                    5002:73:0,
                                    5002:74:0,
                                    5002:75:0,
                                    5002:76:0,
                                    5002:77:0,
                                    5002:78:0,
                                    5002:79:0,
                                    5002:80:0,
                                    5002:81:0
                                }
#END_IF


#include 'NAVFoundation.Enova.axi'
#include 'NAVFoundation.EnovaEvents.axi'


define_module 'mEnovaDVX' mEnovaDvxComm(vdvEnovaDvx, DVA_ENOVA[1])


#END_IF // __NAV_FOUNDATION_ENOVA_DVX_BASE__
