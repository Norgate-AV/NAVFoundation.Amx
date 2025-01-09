PROGRAM_NAME='NAVFoundation.EnovaEvents'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ENOVA_EVENTS__
#DEFINE __NAV_FOUNDATION_ENOVA_EVENTS__ 'NAVFoundation.EnovaEvents'


// #DEFINE USING_NAV_ENOVA_AUDIO_XPOINT_EVENT_CALLBACK
// define_function NAVEnovaAudioXPointEventCallback(_NAVEnovaAudioXpointEventArgs args) {}


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


DEFINE_EVENT

data_event[DVA_ENOVA] {
    online: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'Enova => OnLine: ', NAVDeviceToString(data.device)")

        #IF_DEFINED USING_NAV_ENOVA_ONLINE_DATA_EVENT_CALLBACK
        NAVEnovaOnlineDataEventCallback(data)
        #END_IF

        if (data.device.port == NAVEnovaGetPortCount()) {
            NAVErrorLog(NAV_LOG_LEVEL_INFO,
                        "'Enova => Ready: ', NAVDeviceToString(data.device)")

            #IF_DEFINED USING_NAV_ENOVA_READY_DATA_EVENT_CALLBACK
            NAVEnovaReadyDataEventCallback(data)
            #END_IF
        }
    }
    offline: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'Enova => OffLine: ', NAVDeviceToString(data.device)")

        #IF_DEFINED USING_NAV_ENOVA_OFFLINE_DATA_EVENT_CALLBACK
        NAVEnovaOfflineDataEventCallback(data)
        #END_IF
    }
    onerror: {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                    "'Enova => OnError: ', NAVDeviceToString(data.device), ': ', NAVGetSocketError(type_cast(data.number))")

        #IF_DEFINED USING_NAV_ENOVA_ONERROR_DATA_EVENT_CALLBACK
        NAVEnovaOnErrorDataEventCallback(data)
        #END_IF
    }
    string: {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_FROM,
                                                data.device,
                                                data.text))

        #IF_DEFINED USING_NAV_ENOVA_STRING_DATA_EVENT_CALLBACK
        NAVEnovaStringDataEventCallback(data)
        #END_IF
    }
    command: {
        stack_var _NAVSnapiMessage message

        NAVParseSnapiMessage(data.text, message)

        switch (message.Header) {
            case NAV_ENOVA_AUDIO_XPOINT: {
                stack_var _NAVEnovaAudioXpointEventArgs args

                args.Input = atoi(message.Parameter[2])
                args.Output = atoi(message.Parameter[3])
                args.Level = atoi(message.Parameter[1])

                #IF_DEFINED USING_NAV_ENOVA_AUDIO_XPOINT_EVENT_CALLBACK
                NAVEnovaAudioXPointEventCallback(args)
                #END_IF
            }
            case 'AUDMIC_GAIN': {}
            case 'AUDMIC_PREAMP_GAIN': {}
        }
    }
}


level_event[DVA_ENOVA, 0] {
    #IF_DEFINED USING_NAV_ENOVA_LEVEL_EVENT_CALLBACK
    NAVEnovaLevelEventCallback(level)
    #END_IF
}


channel_event[DVA_ENOVA, 0] {
    on: {
        #IF_DEFINED USING_NAV_ENOVA_CHANNEL_EVENT_CALLBACK
        NAVEnovaChannelEventCallback(channel)
        #END_IF
    }
    off: {
        #IF_DEFINED USING_NAV_ENOVA_CHANNEL_EVENT_CALLBACK
        NAVEnovaChannelEventCallback(channel)
        #END_IF
    }
}


#END_IF // __NAV_FOUNDATION_ENOVA_EVENTS__
