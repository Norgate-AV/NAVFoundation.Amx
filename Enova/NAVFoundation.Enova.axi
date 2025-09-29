PROGRAM_NAME='NAVFoundation.Enova'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ENOVA__
#DEFINE __NAV_FOUNDATION_ENOVA__ 'NAVFoundation.Enova'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


DEFINE_CONSTANT
////////////////////////////////////////////////////////////////////
// General
////////////////////////////////////////////////////////////////////
constant integer NAV_ENOVA_MAX_INPUTS    =   81
constant integer NAV_ENOVA_MAX_OUTPUTS   =   80


////////////////////////////////////////////////////////////////////
// Channels
////////////////////////////////////////////////////////////////////
constant integer NAV_ENOVA_SWITCH_INPUT_1_VIDEO   =   31
constant integer NAV_ENOVA_SWITCH_INPUT_2_VIDEO   =   32
constant integer NAV_ENOVA_SWITCH_INPUT_3_VIDEO   =   33
constant integer NAV_ENOVA_SWITCH_INPUT_4_VIDEO   =   34
constant integer NAV_ENOVA_SWITCH_INPUT_5_VIDEO   =   35
constant integer NAV_ENOVA_SWITCH_INPUT_6_VIDEO   =   36
constant integer NAV_ENOVA_SWITCH_INPUT_7_VIDEO   =   37
constant integer NAV_ENOVA_SWITCH_INPUT_8_VIDEO   =   38
constant integer NAV_ENOVA_SWITCH_INPUT_VIDEO[]   =     {
                                                            NAV_ENOVA_SWITCH_INPUT_1_VIDEO,
                                                            NAV_ENOVA_SWITCH_INPUT_2_VIDEO,
                                                            NAV_ENOVA_SWITCH_INPUT_3_VIDEO,
                                                            NAV_ENOVA_SWITCH_INPUT_4_VIDEO,
                                                            NAV_ENOVA_SWITCH_INPUT_5_VIDEO,
                                                            NAV_ENOVA_SWITCH_INPUT_6_VIDEO,
                                                            NAV_ENOVA_SWITCH_INPUT_7_VIDEO,
                                                            NAV_ENOVA_SWITCH_INPUT_8_VIDEO
                                                        }

constant integer NAV_ENOVA_SWITCH_INPUT_1_AUDIO   =   41
constant integer NAV_ENOVA_SWITCH_INPUT_2_AUDIO   =   42
constant integer NAV_ENOVA_SWITCH_INPUT_3_AUDIO   =   43
constant integer NAV_ENOVA_SWITCH_INPUT_4_AUDIO   =   44
constant integer NAV_ENOVA_SWITCH_INPUT_5_AUDIO   =   45
constant integer NAV_ENOVA_SWITCH_INPUT_6_AUDIO   =   46
constant integer NAV_ENOVA_SWITCH_INPUT_7_AUDIO   =   47
constant integer NAV_ENOVA_SWITCH_INPUT_8_AUDIO   =   48
constant integer NAV_ENOVA_SWITCH_INPUT_9_AUDIO   =   49
constant integer NAV_ENOVA_SWITCH_INPUT_10_AUDIO  =   50
constant integer NAV_ENOVA_SWITCH_INPUT_11_AUDIO  =   51
constant integer NAV_ENOVA_SWITCH_INPUT_12_AUDIO  =   52
constant integer NAV_ENOVA_SWITCH_INPUT_13_AUDIO  =   53
constant integer NAV_ENOVA_SWITCH_INPUT_14_AUDIO  =   54
constant integer NAV_ENOVA_SWITCH_INPUT_AUDIO[]   =     {
                                                            NAV_ENOVA_SWITCH_INPUT_1_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_2_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_3_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_4_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_5_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_6_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_7_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_8_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_9_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_10_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_11_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_12_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_13_AUDIO,
                                                            NAV_ENOVA_SWITCH_INPUT_14_AUDIO
                                                        }

constant integer NAV_ENOVA_VIDEO_OUTPUT_ENABLE    =   70
constant integer NAV_ENOVA_MIC_ENABLE             =   71

constant integer NAV_ENOVA_VIDEO_MUTE_STATE             =   210
constant integer NAV_ENOVA_DXLINK_VIDEO_MUTE_STATE      =   211
constant integer NAV_ENOVA_VIDEO_FREEZE_STATE           =   213
constant integer NAV_ENOVA_DXLINK_VIDEO_FREEZE_STATE    =   214

constant integer NAV_ENOVA_FAN_ALARM                    =   216
constant integer NAV_ENOVA_TEMPERATURE_ALARM            =   217


////////////////////////////////////////////////////////////////////
// Levels
////////////////////////////////////////////////////////////////////
constant integer NAV_ENOVA_OUTPUT_VOLUME            =   1   // (0-100)
constant integer NAV_ENOVA_AUDIO_OUTPUT_BALANCE     =   2   // (-20 - 20)
constant integer NAV_ENOVA_AUDIO_INPUT_GAIN         =   3   // (-24 - 24)

constant integer NAV_ENOVA_TEMPERATURE              =   8

constant integer NAV_ENOVA_VIDEO_OUTPUT_BRIGHTNESS          =   20  // (0-100)
constant integer NAV_ENOVA_DXLINK_VIDEO_OUTPUT_BRIGHTNESS   =   21  // (0-100)
constant integer NAV_ENOVA_VIDEO_OUTPUT_CONTRAST            =   22  // (0-100)
constant integer NAV_ENOVA_DXLINK_VIDEO_OUTPUT_CONTRAST     =   23  // (0-100)

constant integer NAV_ENOVA_AUDIO_EQ_BAND_1      =   31  // (-12 - 12)
constant integer NAV_ENOVA_AUDIO_EQ_BAND_2      =   32  // (-12 - 12)
constant integer NAV_ENOVA_AUDIO_EQ_BAND_3      =   33  // (-12 - 12)
constant integer NAV_ENOVA_AUDIO_EQ_BAND_4      =   34  // (-12 - 12)
constant integer NAV_ENOVA_AUDIO_EQ_BAND_5      =   35  // (-12 - 12)
constant integer NAV_ENOVA_AUDIO_EQ_BAND_6      =   36  // (-12 - 12)
constant integer NAV_ENOVA_AUDIO_EQ_BAND_7      =   37  // (-12 - 12)
constant integer NAV_ENOVA_AUDIO_EQ_BAND_8      =   38  // (-12 - 12)
constant integer NAV_ENOVA_AUDIO_EQ_BAND_9      =   39  // (-12 - 12)
constant integer NAV_ENOVA_AUDIO_EQ_BAND_10     =   40  // (-12 - 12)

constant integer NAV_ENOVA_AUDIO_PROGRAM_SOURCE_MIX    =   41  // (-100 - 0)
constant integer NAV_ENOVA_AUDIO_LINE_MIC_1_MIX        =   42  // (-100 - 0)
constant integer NAV_ENOVA_AUDIO_LINE_MIC_2_MIX        =   43  // (-100 - 0)
constant integer NAV_ENOVA_AUDIO_LINE_MIC_3_MIX        =   44  // (-100 - 0)
constant integer NAV_ENOVA_AUDIO_LINE_MIC_4_MIX        =   45  // (-100 - 0)
constant integer NAV_ENOVA_AUDIO_LINE_MIC_5_MIX        =   46  // (-100 - 0)
constant integer NAV_ENOVA_AUDIO_LINE_MIC_6_MIX        =   47  // (-100 - 0)

constant integer NAV_ENOVA_VIDEO_SWITCH       =   50  // (1 - 8)
constant integer NAV_ENOVA_AUDIO_SWITCH       =   51  // (1 - 14)

constant integer NAV_ENOVA_AUDIO_MIC_PREAMP_GAIN   =   52  // (0 - 60)
constant integer NAV_ENOVA_AUDIO_MIC_GAIN          =   53  // (-24 - 24)

constant integer NAV_ENOVA_AUDIO_MIC_EQ_BAND_1     =   61  // (-12 - 12)
constant integer NAV_ENOVA_AUDIO_MIC_EQ_BAND_2     =   62  // (-12 - 12)
constant integer NAV_ENOVA_AUDIO_MIC_EQ_BAND_3     =   63  // (-12 - 12)

constant integer NAV_ENOVA_DANTE_MIC_1_MIX         =   71  // (-100 - 0)
constant integer NAV_ENOVA_DANTE_MIC_2_MIX         =   72  // (-100 - 0)
constant integer NAV_ENOVA_DANTE_MIC_3_MIX         =   73  // (-100 - 0)
constant integer NAV_ENOVA_DANTE_MIC_4_MIX         =   74  // (-100 - 0)
constant integer NAV_ENOVA_DANTE_MIC_5_MIX         =   75  // (-100 - 0)
constant integer NAV_ENOVA_DANTE_MIC_6_MIX         =   76  // (-100 - 0)
constant integer NAV_ENOVA_DANTE_MIC_7_MIX         =   77  // (-100 - 0)
constant integer NAV_ENOVA_DANTE_MIC_8_MIX         =   78  // (-100 - 0)


////////////////////////////////////////////////////////////////////
// XPoints
////////////////////////////////////////////////////////////////////
constant sinteger NAV_ENOVA_AUDIO_XPOINT_LEVEL_MAX    =   0
constant sinteger NAV_ENOVA_AUDIO_XPOINT_LEVEL_MIN    =   -99
constant sinteger NAV_ENOVA_AUDIO_XPOINT_LEVEL_MUTE   =   -100

constant integer NAV_ENOVA_AUDIO_XPOINT_INPUT_PROGRAM       =   1
constant integer NAV_ENOVA_AUDIO_XPOINT_INPUT_LINE_MIC_1    =   2
constant integer NAV_ENOVA_AUDIO_XPOINT_INPUT_LINE_MIC_2    =   3
constant char NAV_ENOVA_AUDIO_XPOINT_INPUTS[][NAV_MAX_CHARS]    =   {
                                                                        'Source',
                                                                        'Line/Mic 1',
                                                                        'Line/Mic 2'
                                                                    }

constant integer NAV_ENOVA_AUDIO_XPOINT_OUTPUT_1    =   1
constant integer NAV_ENOVA_AUDIO_XPOINT_OUTPUT_2    =   2
constant integer NAV_ENOVA_AUDIO_XPOINT_OUTPUT_3    =   3
constant integer NAV_ENOVA_AUDIO_XPOINT_OUTPUT_4    =   4
constant char NAV_ENOVA_AUDIO_XPOINT_OUTPUTS[][NAV_MAX_CHARS]   =   {
                                                                        'Output 1 (AMP)',
                                                                        'Output 2',
                                                                        'Output 3',
                                                                        'Output 4'
                                                                    }


////////////////////////////////////////////////////////////////////
// Commands
////////////////////////////////////////////////////////////////////
constant integer NAV_ENOVA_SWITCH_LEVEL_COUNT   = 3
constant char NAV_ENOVA_SWITCH_LEVEL_VIDEO[]    = 'VIDEO'
constant char NAV_ENOVA_SWITCH_LEVEL_AUDIO[]    = 'AUDIO'
constant char NAV_ENOVA_SWITCH_LEVEL_ALL[]      = 'ALL'
constant char NAV_ENOVA_SWITCH_LEVELS[][NAV_MAX_CHARS]	=   {
                                                                NAV_ENOVA_SWITCH_LEVEL_VIDEO,
                                                                NAV_ENOVA_SWITCH_LEVEL_AUDIO,
                                                                NAV_ENOVA_SWITCH_LEVEL_ALL
                                                            }


////////////////////////////////////////////////////////////////////
// Video Input
////////////////////////////////////////////////////////////////////
constant char NAV_ENOVA_VIDIN_STATUS_GET[]              = '?VIDIN_STATUS'
constant char NAV_ENOVA_VIDIN_STATUS_NO_SIGNAL[]        = 'NO SIGNAL'
constant char NAV_ENOVA_VIDIN_STATUS_VALID_SIGNAL[]     = 'VALID SIGNAL'

constant char NAV_ENOVA_VIDIN_PREF_EDID[]               = 'VIDIN_PREF_EDID'
constant char NAV_ENOVA_VIDIN_PREF_EDID_GET[]           = '?VIDIN_PREF_EDID'

constant char NAV_ENOVA_VIDIN_EDID[]                    = 'VIDIN_EDID'
constant char NAV_ENOVA_VIDIN_EDID_GET[]                = '?VIDIN_EDID'

constant char NAV_ENOVA_VIDIN_HDCP[]                    = 'VIDIN_HDCP'
constant char NAV_ENOVA_VIDIN_HDCP_GET[]                = '?VIDIN_HDCP'

constant char NAV_ENOVA_VIDIN_RES_REF_GET[]             = '?VIDIN_RES_REF'

constant char NAV_ENOVA_VIDIN_NAME[]                    = 'VIDIN_NAME'
constant char NAV_ENOVA_VIDIN_NAME_GET[]                = '?VIDIN_NAME'

constant char NAV_ENOVA_VIDIN_HDR[]                     = 'VIDIN_HDR'
constant char NAV_ENOVA_VIDIN_HDR_GET[]                 = '?VIDIN_HDR'

constant char NAV_ENOVA_AUDIO_XPOINT[]                  = 'XPOINT'
constant char NAV_ENOVA_AUDIO_XPOINT_GET[]              = '?XPOINT'

constant char NAV_ENOVA_SWITCH_EVENT[]                  = 'SWITCH'


DEFINE_TYPE

struct _NAVEnovaInput {
    char Name[NAV_MAX_CHARS]
    char Status[NAV_MAX_CHARS]
    char Resolution[NAV_MAX_CHARS]
    char HDCP[NAV_MAX_CHARS]
    char HDR[NAV_MAX_CHARS]
    char EDID[NAV_MAX_BUFFER]
    char PreferredEDID[NAV_MAX_BUFFER]
    char XPoint[NAV_MAX_BUFFER]
}


struct _NAVEnovaOutput {
    char Name[NAV_MAX_CHARS]
    char Status[NAV_MAX_CHARS]
    char Resolution[NAV_MAX_CHARS]
    char HDCP[NAV_MAX_CHARS]
    char HDR[NAV_MAX_CHARS]
    char EDID[NAV_MAX_BUFFER]
    char PreferredEDID[NAV_MAX_BUFFER]
    char XPoint[NAV_MAX_BUFFER]
}


struct _NAVEnova {
    char HardwareVersion[NAV_MAX_CHARS]

    char SwitcherFirmwareVersion[NAV_MAX_CHARS]
    char FirmwareVersion[NAV_MAX_CHARS]

    char Temperature[NAV_MAX_CHARS]
    char AmpTemperature[NAV_MAX_CHARS]
    char TemperatureAlarm[NAV_MAX_CHARS]

    char FanSpeed[NAV_MAX_CHARS]
    char FanAlarm[NAV_MAX_CHARS]

    char StackInfo[NAV_MAX_BUFFER]
}


struct _NAVEnovaAudioXpointEventArgs {
    integer Input
    integer Output
    sinteger Level
}


struct _NAVEnovaSwitchEventArgs {
    integer Input
    integer Output
    integer Level
}


struct _NAVEnovaIOCount {
    integer Video
    integer Audio
}


struct _NAVEnovaPortInfo {
    integer PortCount

    _NAVEnovaIOCount InputCount
    _NAVEnovaIOCount OutputCount
}


define_function char[NAV_MAX_CHARS] NAVEnovaGetSwitchLevel(integer level) {
    switch (level) {
        case 0: {
            return NAV_ENOVA_SWITCH_LEVEL_ALL
        }
        case 1: {
            return NAV_ENOVA_SWITCH_LEVEL_VIDEO
        }
        case 2: {
            return NAV_ENOVA_SWITCH_LEVEL_AUDIO
        }
        default: {
            return NAV_ENOVA_SWITCH_LEVEL_ALL
        }
    }
}


define_function char[NAV_MAX_BUFFER] NAVEnovaBuildSwitch(integer input, integer output, integer level) {
    return "'CL', NAVEnovaGetSwitchLevel(level), 'I', itoa(input), 'O', itoa(output)"
}


define_function char[NAV_MAX_BUFFER] NAVEnovaBuildSwitchAll(integer input, integer output) {
    return NAVEnovaBuildSwitch(input, output, 0)
}


define_function char[NAV_MAX_BUFFER] NAVEnovaBuildSwitchVideo(integer input, integer output) {
    return NAVEnovaBuildSwitch(input, output, 1)
}


define_function char[NAV_MAX_BUFFER] NAVEnovaBuildSwitchAudio(integer input, integer output) {
    return NAVEnovaBuildSwitch(input, output, 2)
}


define_function char[NAV_MAX_BUFFER] NAVEnovaBuildSetXpointLevel(integer input, integer output, sinteger level) {
    return "NAV_ENOVA_AUDIO_XPOINT, '-', itoa(level), ',', itoa(input), ',', itoa(output)"
}


define_function char[NAV_MAX_BUFFER] NAVEnovaBuildGetXpointLevel(integer input, integer output) {
    return "NAV_ENOVA_AUDIO_XPOINT_GET, '-', itoa(input), ',', itoa(output)"
}


define_function NAVEnovaSetXpointLevel(dev device[], integer input, integer output, sinteger level) {
    NAVCommand(device[1], "NAVEnovaBuildSetXpointLevel(input, output, level)")
}


define_function NAVEnovaGetXpointLevel(dev device[], integer input, integer output) {
    NAVCommand(device[1], "NAVEnovaBuildGetXpointLevel(input, output)")
}


define_function char NAVEnovaGetVideoMuteState(dev device[], integer output) {
    return [device[output], NAV_ENOVA_VIDEO_MUTE_STATE]
}


define_function NAVEnovaSetVideoMuteState(dev device[], integer output, integer state) {
    [device[output], NAV_ENOVA_VIDEO_MUTE_STATE] = state
}


define_function NAVEnovaSetVideoMuteStateAll(dev device[], char state) {
    stack_var integer x

    for (x = 1; x <= length_array(device); x++) {
        NAVEnovaSetVideoMuteState(device, x, state)
    }
}


define_function NAVEnovaSetVideoMuteStateArray(dev device[], integer output[], char state) {
    stack_var integer x

    for (x = 1; x <= length_array(output); x++) {
        NAVEnovaSetVideoMuteState(device, output[x], state)
    }
}


define_function NAVEnovaSetMicMuteState(dev device[], integer mic, integer state) {
    [device[mic], NAV_ENOVA_MIC_ENABLE] = !state
}


define_function char NAVEnovaGetMicMuteState(dev device[], integer mic) {
    return ![device[mic], NAV_ENOVA_MIC_ENABLE]
}


define_function char NAVEnovaIsReady(dev device[]) {
    return NAVDeviceIsOnline(device[length_array(device)])
}


define_function char[NAV_MAX_CHARS] NAVEnovaGetModel() {
    stack_var _NAVController controller

    NAVGetControllerInformation(controller)

    if (!controller.Switcher.Device_Id) {
        // No Switcher Device
        return ''
    }

    return controller.Switcher.Device_Id_String
}


define_function char NAVEnovaGetPortInfo(_NAVEnovaPortInfo info) {
    stack_var char model[NAV_MAX_CHARS]

    model = NAVEnovaGetModel()

    if (!length_array(model)) {
        return false
    }

    select {
        active (NAVStartsWith(model, 'DVX-2210')): {
            // DVX-2210HD
            info.PortCount = 6
            info.InputCount.Video = 4
            info.InputCount.Audio = 6
            info.OutputCount.Video = 2
            info.OutputCount.Audio = 3
        }
        active (NAVStartsWith(model, 'DVX-22') && !NAVContains(model, '4K')): {
            // DVX-2250HD, DVX2255HD
            info.PortCount = 9
            info.InputCount.Video = 6
            info.InputCount.Audio = 8
            info.OutputCount.Video = 3
            info.OutputCount.Audio = 3
        }
        active (NAVStartsWith(model, 'DVX-22') && NAVContains(model, '4K')): {
            // DVX-2265-4K
            info.PortCount = 14
            info.InputCount.Video = 6
            info.InputCount.Audio = 14
            info.OutputCount.Video = 2
            info.OutputCount.Audio = 4
        }
        active (NAVStartsWith(model, 'DVX-32') && !NAVContains(model, '4K')): {
            // DVX-3250HD, DVX-3255HD, DVX-3256HD
            info.PortCount = 14
            info.InputCount.Video = 10
            info.InputCount.Audio = 14
            info.OutputCount.Video = 4
            info.OutputCount.Audio = 4
        }
        active (NAVStartsWith(model, 'DVX-32') && NAVContains(model, '4K')): {
            // DVX-3266-4K
            info.PortCount = 14
            info.InputCount.Video = 8
            info.InputCount.Audio = 14
            info.OutputCount.Video = 4
            info.OutputCount.Audio = 4
        }
        active (NAVStartsWith(model, 'DGX-8')): {
            // DGX-8, DGX-800
            info.PortCount = 17
            info.InputCount.Video = 8
            info.InputCount.Audio = 17
            info.OutputCount.Video = 8
            info.OutputCount.Audio = 16
        }
        active (NAVStartsWith(model, 'DGX-16')): {
            // DGX-16, DGX-1600
            info.PortCount = 25
            info.InputCount.Video = 16
            info.InputCount.Audio = 25
            info.OutputCount.Video = 16
            info.OutputCount.Audio = 24
        }
        active (NAVStartsWith(model, 'DGX-32')): {
            // DGX-32, DGX-3200
            info.PortCount = 41
            info.InputCount.Video = 32
            info.InputCount.Audio = 41
            info.OutputCount.Video = 32
            info.OutputCount.Audio = 40
        }
        active (NAVStartsWith(model, 'DGX-64')): {
            // DGX-64, DGX-6400
            info.PortCount = 81
            info.InputCount.Video = 64
            info.InputCount.Audio = 81
            info.OutputCount.Video = 64
            info.OutputCount.Audio = 80
        }
        active (true): {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_ENOVA__,
                                        'NAVEnovaGetPortInfo',
                                        "'Unknown Model : ', model")

            return false
        }
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_INFO,
                                __NAV_FOUNDATION_ENOVA__,
                                'NAVEnovaGetPortInfo',
                                "'It`s a ', NAVGetStringBefore(model, ' ')")

    return true
}


define_function integer NAVEnovaGetPortCount() {
    stack_var _NAVEnovaPortInfo info

    if (!NAVEnovaGetPortInfo(info)) {
        return 0
    }

    return info.PortCount
}


define_function char NAVEnovaGetInputCount(_NAVEnovaIOCount count) {
    stack_var _NAVEnovaPortInfo info

    if (!NAVEnovaGetPortInfo(info)) {
        return false
    }

    count.Video = info.InputCount.Video
    count.Audio = info.InputCount.Audio

    return true
}


define_function char NAVEnovaGetOutputCount(_NAVEnovaIOCount count) {
    stack_var _NAVEnovaPortInfo info

    if (!NAVEnovaGetPortInfo(info)) {
        return false
    }

    count.Video = info.OutputCount.Video
    count.Audio = info.OutputCount.Audio

    return true
}


define_function char[NAV_MAX_CHARS] NAVEnovaGetXPointInput(integer input) {
    switch (input) {
        case NAV_ENOVA_AUDIO_XPOINT_INPUT_PROGRAM:
        case NAV_ENOVA_AUDIO_XPOINT_INPUT_LINE_MIC_1:
        case NAV_ENOVA_AUDIO_XPOINT_INPUT_LINE_MIC_2: {
            return NAV_ENOVA_AUDIO_XPOINT_INPUTS[input]
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_ENOVA__,
                                        'NAVEnovaGetXPointInput',
                                        "'Index out of range : ', itoa(input)")

            return ''
        }
    }
}


define_function char[NAV_MAX_CHARS] NAVEnovaGetXPointOutput(integer output) {
    switch (output) {
        case NAV_ENOVA_AUDIO_XPOINT_OUTPUT_1:
        case NAV_ENOVA_AUDIO_XPOINT_OUTPUT_2:
        case NAV_ENOVA_AUDIO_XPOINT_OUTPUT_3:
        case NAV_ENOVA_AUDIO_XPOINT_OUTPUT_4: {
            return NAV_ENOVA_AUDIO_XPOINT_OUTPUTS[output]
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_ENOVA__,
                                        'NAVEnovaGetXPointOutput',
                                        "'Index out of range : ', itoa(output)")

            return ''
        }
    }
}


#END_IF // __NAV_FOUNDATION_ENOVA__
