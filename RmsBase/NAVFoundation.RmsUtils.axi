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
furnished to do so, subject to the following conditions:

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

#IF_NOT_DEFINED __NAV_FOUNDATION_RMSUTILS__
#DEFINE __NAV_FOUNDATION_RMSUTILS__ 'NAVFoundation.RmsUtils'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

// Client Exception Notifications
constant char NAV_RMS_CLIENT_EVENT_EXCEPTION[NAV_MAX_CHARS]                             = 'EXCEPTION'

// Client Event Notifications
constant char NAV_RMS_CLIENT_EVENT_CLIENT_ONLINE[NAV_MAX_CHARS]                         = 'CLIENT.ONLINE'
constant char NAV_RMS_CLIENT_EVENT_CLIENT_REGISTERED[NAV_MAX_CHARS]                     = 'CLIENT.REGISTERED'
constant char NAV_RMS_CLIENT_EVENT_CLIENT_OFFLINE[NAV_MAX_CHARS]                        = 'CLIENT.OFFLINE'
constant char NAV_RMS_CLIENT_EVENT_CLIENT_CONNECTION_STATE_TRANSITION[NAV_MAX_CHARS]    = 'CLIENT.CONNECTION.STATE.TRANSITION'
constant char NAV_RMS_CLIENT_EVENT_VERSIONS[NAV_MAX_CHARS]                              = 'VERSIONS'
constant char NAV_RMS_CLIENT_EVENT_SYSTEM_POWER_ON[NAV_MAX_CHARS]                       = 'SYSTEM.POWER.ON'
constant char NAV_RMS_CLIENT_EVENT_SYSTEM_POWER_OFF[NAV_MAX_CHARS]                      = 'SYSTEM.POWER.OFF'
constant char NAV_RMS_CLIENT_EVENT_SERVER_INFO[NAV_MAX_CHARS]                           = 'SERVER.INFO'

// Client Location Event Notifications
constant char NAV_RMS_CLIENT_EVENT_LOCATION[NAV_MAX_CHARS]                              = 'LOCATION'

// Client Config Change Event Notifications
constant char NAV_RMS_CLIENT_EVENT_CONFIG_CHANGE[NAV_MAX_CHARS]                         = 'CONFIG.CHANGE'

// Asset Registration Event Notifications
constant char NAV_RMS_CLIENT_EVENT_ASSET_REGISTER[NAV_MAX_CHARS]                        = 'ASSET.REGISTER'
constant char NAV_RMS_CLIENT_EVENT_ASSET_REGISTERED[NAV_MAX_CHARS]                      = 'ASSET.REGISTERED'
constant char NAV_RMS_CLIENT_EVENT_ASSET_LOCATION_CHANGE[NAV_MAX_CHARS]                 = 'ASSSET.LOCATION.CHANGE'

// Asset Parameter Event Notifications
constant char NAV_RMS_CLIENT_EVENT_ASSET_PARAM_UPDATE[NAV_MAX_CHARS]                    = 'ASSET.PARAM.UPDATE'
constant char NAV_RMS_CLIENT_EVENT_ASSET_PARAM_VALUE[NAV_MAX_CHARS]                     = 'ASSET.PARAM.VALUE'
constant char NAV_RMS_CLIENT_EVENT_ASSET_PARAM_RESET[NAV_MAX_CHARS]                     = 'ASSET.PARAM.RESET'

// Asset Control Methods Event Notifications
constant char NAV_RMS_CLIENT_EVENT_ASSET_CONTROL_METHOD_EXECUTE[NAV_MAX_CHARS]          = 'ASSET.METHOD.EXECUTE'

// Hotlist Event Notifications
constant char NAV_RMS_CLIENT_EVENT_HOTLIST_COUNT[NAV_MAX_CHARS]                         = 'HOTLIST.COUNT'

// Messaging Event Notifications
constant char NAV_RMS_CLIENT_EVENT_MESSAGE_DISPLAY[NAV_MAX_CHARS]                       = 'MESSAGE.DISPLAY'


DEFINE_TYPE

struct _NAVRmsServerInformation {
    char AppVersion[NAV_MAX_CHARS]
    char DatabaseVersion[NAV_MAX_CHARS]
    char TimesyncEnabled
    char SmtpEnabled
    integer MinPollTime
    integer MaxPollTime
}


struct _NAVRmsLocation {
    char ClientDefaultLocation
    char Id[NAV_MAX_CHARS]
    char Name[NAV_MAX_CHARS]
    char Owner[NAV_MAX_CHARS]
    char PhoneNumber[NAV_MAX_CHARS]
    char Occupancy[NAV_MAX_CHARS]
    char PrestigeName[NAV_MAX_CHARS]
    char Timezone[NAV_MAX_CHARS]
    char AssetLicensed
}


struct _NAVRmsConnection {
    char Name[NAV_MAX_CHARS]
    char Url[NAV_MAX_BUFFER]
    char Password[NAV_MAX_CHARS]
    char Enabled[NAV_MAX_CHARS]
}


struct _NAVRmsException {
    char Message[NAV_MAX_BUFFER]
    char Header[NAV_MAX_BUFFER]
}


struct _NAVRmsConnectionState {
    char OldState[NAV_MAX_CHARS]
    char NewState[NAV_MAX_CHARS]
}


struct _NAVRmsHotlist {
    char ClientDefaultLocation
    integer LocationId
    integer Count
}


struct _NAVRmsClient {
    _NAVRmsServerInformation ServerInformation
    _NAVRmsLocation Location
    _NAVRmsConnection Connection
}


define_function NAVRmsConnectionCopy(_NAVRmsConnection source, _NAVRmsConnection destination) {
    destination.Name = source.Name
    destination.Url = source.Url
    destination.Password = source.Password
    destination.Enabled = source.Enabled
}


#END_IF // __NAV_FOUNDATION_RMSUTILS__
