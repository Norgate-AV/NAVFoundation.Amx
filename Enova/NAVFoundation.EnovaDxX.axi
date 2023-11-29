PROGRAM_NAME='NAVFoundation.EnovaDxX'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ENOVA_DXX__
#DEFINE __NAV_FOUNDATION_ENOVA_DXX__ 'NAVFoundation.EnovaDxX'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT


////////////////////////////////////////////////////////////////////
// Channels
////////////////////////////////////////////////////////////////////
constant integer ENOVA_DXX_SWITCH_INPUT_1_VIDEO   =   31
constant integer ENOVA_DXX_SWITCH_INPUT_2_VIDEO   =   32
constant integer ENOVA_DXX_SWITCH_INPUT_3_VIDEO   =   33
constant integer ENOVA_DXX_SWITCH_INPUT_4_VIDEO   =   34
constant integer ENOVA_DXX_SWITCH_INPUT_5_VIDEO   =   35
constant integer ENOVA_DXX_SWITCH_INPUT_6_VIDEO   =   36
constant integer ENOVA_DXX_SWITCH_INPUT_7_VIDEO   =   37
constant integer ENOVA_DXX_SWITCH_INPUT_8_VIDEO   =   38
constant integer ENOVA_DXX_SWITCH_INPUT_VIDEO[]   =     {
                                                            ENOVA_DXX_SWITCH_INPUT_1_VIDEO,
                                                            ENOVA_DXX_SWITCH_INPUT_2_VIDEO,
                                                            ENOVA_DXX_SWITCH_INPUT_3_VIDEO,
                                                            ENOVA_DXX_SWITCH_INPUT_4_VIDEO,
                                                            ENOVA_DXX_SWITCH_INPUT_5_VIDEO,
                                                            ENOVA_DXX_SWITCH_INPUT_6_VIDEO,
                                                            ENOVA_DXX_SWITCH_INPUT_7_VIDEO,
                                                            ENOVA_DXX_SWITCH_INPUT_8_VIDEO
                                                        }

constant integer ENOVA_DXX_SWITCH_INPUT_1_AUDIO   =   41
constant integer ENOVA_DXX_SWITCH_INPUT_2_AUDIO   =   42
constant integer ENOVA_DXX_SWITCH_INPUT_3_AUDIO   =   43
constant integer ENOVA_DXX_SWITCH_INPUT_4_AUDIO   =   44
constant integer ENOVA_DXX_SWITCH_INPUT_5_AUDIO   =   45
constant integer ENOVA_DXX_SWITCH_INPUT_6_AUDIO   =   46
constant integer ENOVA_DXX_SWITCH_INPUT_7_AUDIO   =   47
constant integer ENOVA_DXX_SWITCH_INPUT_8_AUDIO   =   48
constant integer ENOVA_DXX_SWITCH_INPUT_9_AUDIO   =   49
constant integer ENOVA_DXX_SWITCH_INPUT_10_AUDIO  =   50
constant integer ENOVA_DXX_SWITCH_INPUT_11_AUDIO  =   51
constant integer ENOVA_DXX_SWITCH_INPUT_12_AUDIO  =   52
constant integer ENOVA_DXX_SWITCH_INPUT_13_AUDIO  =   53
constant integer ENOVA_DXX_SWITCH_INPUT_14_AUDIO  =   54
constant integer ENOVA_DXX_SWITCH_INPUT_AUDIO[]   =     {
                                                            ENOVA_DXX_SWITCH_INPUT_1_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_2_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_3_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_4_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_5_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_6_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_7_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_8_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_9_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_10_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_11_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_12_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_13_AUDIO,
                                                            ENOVA_DXX_SWITCH_INPUT_14_AUDIO
                                                        }

constant integer ENOVA_DXX_VIDEO_OUTPUT_ENABLE    =   70
constant integer ENOVA_DXX_MIC_ENABLE             =   71

constant integer ENOVA_DXX_VIDEO_MUTE_STATE             =   210
constant integer ENOVA_DXX_DXLINK_VIDEO_MUTE_STATE      =   211
constant integer ENOVA_DXX_VIDEO_FREEZE_STATE           =   213
constant integer ENOVA_DXX_DXLINK_VIDEO_FREEZE_STATE    =   214

constant integer ENOVA_DXX_FAN_ALARM                    =   216
constant integer ENOVA_DXX_TEMPERATURE_ALARM            =   217


////////////////////////////////////////////////////////////////////
// Levels
////////////////////////////////////////////////////////////////////
constant integer ENOVA_DXX_OUTPUT_VOLUME            =   1   // (0-100)
constant integer ENOVA_DXX_AUDIO_OUTPUT_BALANCE     =   2   // (-20 - 20)
constant integer ENOVA_DXX_AUDIO_INPUT_GAIN         =   3   // (-24 - 24)

constant integer ENOVA_DXX_TEMPERATURE              =   8

constant integer ENOVA_DXX_VIDEO_OUTPUT_BRIGHTNESS          =   20  // (0-100)
constant integer ENOVA_DXX_DXLINK_VIDEO_OUTPUT_BRIGHTNESS   =   21  // (0-100)
constant integer ENOVA_DXX_VIDEO_OUTPUT_CONTRAST            =   22  // (0-100)
constant integer ENOVA_DXX_DXLINK_VIDEO_OUTPUT_CONTRAST     =   23  // (0-100)

constant integer ENOVA_DXX_AUDIO_EQ_BAND_1      =   31  // (-12 - 12)
constant integer ENOVA_DXX_AUDIO_EQ_BAND_2      =   32  // (-12 - 12)
constant integer ENOVA_DXX_AUDIO_EQ_BAND_3      =   33  // (-12 - 12)
constant integer ENOVA_DXX_AUDIO_EQ_BAND_4      =   34  // (-12 - 12)
constant integer ENOVA_DXX_AUDIO_EQ_BAND_5      =   35  // (-12 - 12)
constant integer ENOVA_DXX_AUDIO_EQ_BAND_6      =   36  // (-12 - 12)
constant integer ENOVA_DXX_AUDIO_EQ_BAND_7      =   37  // (-12 - 12)
constant integer ENOVA_DXX_AUDIO_EQ_BAND_8      =   38  // (-12 - 12)
constant integer ENOVA_DXX_AUDIO_EQ_BAND_9      =   39  // (-12 - 12)
constant integer ENOVA_DXX_AUDIO_EQ_BAND_10     =   40  // (-12 - 12)

constant integer ENOVA_DXX_AUDIO_PROGRAM_SOURCE_MIX    =   41  // (-100 - 0)
constant integer ENOVA_DXX_AUDIO_LINE_MIC_1_MIX        =   42  // (-100 - 0)
constant integer ENOVA_DXX_AUDIO_LINE_MIC_2_MIX        =   43  // (-100 - 0)
constant integer ENOVA_DXX_AUDIO_LINE_MIC_3_MIX        =   44  // (-100 - 0)
constant integer ENOVA_DXX_AUDIO_LINE_MIC_4_MIX        =   45  // (-100 - 0)
constant integer ENOVA_DXX_AUDIO_LINE_MIC_5_MIX        =   46  // (-100 - 0)
constant integer ENOVA_DXX_AUDIO_LINE_MIC_6_MIX        =   47  // (-100 - 0)

constant integer ENOVA_DXX_VIDEO_SWITCH       =   50  // (1 - 8)
constant integer ENOVA_DXX_AUDIO_SWITCH       =   51  // (1 - 14)

constant integer ENOVA_DXX_AUDIO_MIC_PREAMP_GAIN   =   52  // (0 - 60)
constant integer ENOVA_DXX_AUDIO_MIC_GAIN          =   53  // (-24 - 24)

constant integer ENOVA_DXX_AUDIO_MIC_EQ_BAND_1     =   61  // (-12 - 12)
constant integer ENOVA_DXX_AUDIO_MIC_EQ_BAND_2     =   62  // (-12 - 12)
constant integer ENOVA_DXX_AUDIO_MIC_EQ_BAND_3     =   63  // (-12 - 12)

constant integer ENOVA_DXX_DANTE_MIC_1_MIX         =   71  // (-100 - 0)
constant integer ENOVA_DXX_DANTE_MIC_2_MIX         =   72  // (-100 - 0)
constant integer ENOVA_DXX_DANTE_MIC_3_MIX         =   73  // (-100 - 0)
constant integer ENOVA_DXX_DANTE_MIC_4_MIX         =   74  // (-100 - 0)
constant integer ENOVA_DXX_DANTE_MIC_5_MIX         =   75  // (-100 - 0)
constant integer ENOVA_DXX_DANTE_MIC_6_MIX         =   76  // (-100 - 0)
constant integer ENOVA_DXX_DANTE_MIC_7_MIX         =   77  // (-100 - 0)
constant integer ENOVA_DXX_DANTE_MIC_8_MIX         =   78  // (-100 - 0)


////////////////////////////////////////////////////////////////////
// Commands
////////////////////////////////////////////////////////////////////
constant char ENOVA_DXX_SWITCH_LEVEL_ALL[]      = 'ALL'
constant char ENOVA_DXX_SWITCH_LEVEL_VIDEO[]    = 'VIDEO'
constant char ENOVA_DXX_SWITCH_LEVEL_AUDIO[]    = 'AUDIO'
constant char ENOVA_DXX_SWITCH_LEVELS[][NAV_MAX_CHARS]	=   {
                                                                ENOVA_DXX_SWITCH_LEVEL_ALL,
                                                                ENOVA_DXX_SWITCH_LEVEL_VIDEO,
                                                                ENOVA_DXX_SWITCH_LEVEL_AUDIO
                                                            }


define_function char[NAV_MAX_BUFFER] NAVEnovaDxXBuildSwitch(integer input, integer output, integer level) {
    return "'CL', ENOVA_DXX_SWITCH_LEVELS[level], 'I', itoa(input), 'O', itoa(output)"
}


DEFINE_START {

}


DEFINE_EVENT

data_event[5002:1:0]
data_event[5002:2:0]
data_event[5002:3:0]
data_event[5002:4:0]
data_event[5002:5:0]
data_event[5002:6:0]
data_event[5002:7:0]
data_event[5002:8:0]
data_event[5002:9:0]
data_event[5002:10:0]
data_event[5002:11:0]
data_event[5002:12:0]
data_event[5002:13:0]
data_event[5002:14:0] {
    online: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'EnovaDxX => OnLine: ', NAVDeviceToString(data.device)")

        #IF_DEFINED USING_ENOVA_DXX_ONLINE_DATA_EVENT_CALLBACK
        NAVEnovaDxXOnlineDataEventCallback(data)
        #END_IF
    }
    offline: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'EnovaDxX => OffLine: ', NAVDeviceToString(data.device)")

        #IF_DEFINED USING_ENOVA_DXX_OFFLINE_DATA_EVENT_CALLBACK
        NAVEnovaDxXOfflineDataEventCallback(data)
        #END_IF
    }
    onerror: {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'EnovaDxX => OnError: ', NAVDeviceToString(data.device), ': ', data.text")

        #IF_DEFINED USING_ENOVA_DXX_ONERROR_DATA_EVENT_CALLBACK
        NAVEnovaDxXOnErrorDataEventCallback(data)
        #END_IF
    }
    string: {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_FROM, data.device, data.text))

        #IF_DEFINED USING_ENOVA_DXX_STRING_DATA_EVENT_CALLBACK
        NAVEnovaDxXStringDataEventCallback(data)
        #END_IF
    }
    command: {
        stack_var _NAVSnapiMessage message

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_FROM, data.device, data.text))

        #IF_DEFINED USING_ENOVA_DXX_COMMAND_DATA_EVENT_CALLBACK
        NAVEnovaDxXCommandDataEventCallback(data)
        #END_IF

        NAVParseSnapiMessage(data.text, message)

        switch (message.Header) {
            default: {

            }
        }
    }
}


level_event[5002:1:0, 0]
level_event[5002:2:0, 0]
level_event[5002:3:0, 0]
level_event[5002:4:0, 0]
level_event[5002:5:0, 0]
level_event[5002:6:0, 0]
level_event[5002:7:0, 0]
level_event[5002:8:0, 0]
level_event[5002:9:0, 0]
level_event[5002:10:0, 0]
level_event[5002:11:0, 0]
level_event[5002:12:0, 0]
level_event[5002:13:0, 0]
level_event[5002:14:0, 0] {
    #IF_DEFINED USING_ENOVA_DXX_LEVEL_EVENT_CALLBACK
    NAVEnovaDxXLevelEventCallback(level)
    #END_IF
}


channel_event[5002:1:0, 0]
channel_event[5002:2:0, 0]
channel_event[5002:3:0, 0]
channel_event[5002:4:0, 0]
channel_event[5002:5:0, 0]
channel_event[5002:6:0, 0]
channel_event[5002:7:0, 0]
channel_event[5002:8:0, 0]
channel_event[5002:9:0, 0]
channel_event[5002:10:0, 0]
channel_event[5002:11:0, 0]
channel_event[5002:12:0, 0]
channel_event[5002:13:0, 0]
channel_event[5002:14:0, 0] {
    on: {
        #IF_DEFINED USING_ENOVA_DXX_CHANNEL_EVENT_CALLBACK
        NAVEnovaDxXChannelEventCallback(channel)
        #END_IF
    }
    off: {
        #IF_DEFINED USING_ENOVA_DXX_CHANNEL_EVENT_CALLBACK
        NAVEnovaDxXChannelEventCallback(channel)
        #END_IF
    }
}

#END_IF
