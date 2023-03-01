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
    char ThrownByCommandHeader[NAV_MAX_BUFFER]
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


struct _NAVRmsMessage {
    char Type[NAV_MAX_CHARS]
    char Title[NAV_MAX_BUFFER]
    char Body[NAV_MAX_BUFFER]
    integer TimeOutSeconds
    char Modal
    char ResponseMessage[NAV_MAX_BUFFER]
}


struct _NAVRmsClient {
    _NAVRmsServerInformation ServerInformation
    _NAVRmsLocation Location
    _NAVRmsConnection Connection
    _NAVRmsConnectionState ConnectionState
    _NAVKeyValuePair ConfigChange
    _NAVRmsHotlist Hotlist
    _NAVRmsMessage Message
    _NAVRmsException Exception
    dev Device
    char IsOnline
    char IsRegistered
}


define_function NAVRmsConnectionCopy(_NAVRmsConnection source, _NAVRmsConnection destination) {
    destination.Name = source.Name
    destination.Url = source.Url
    destination.Password = source.Password
    destination.Enabled = source.Enabled
}


define_function NAVRmsServerInformationCopy(_NAVRmsServerInformation source, _NAVRmsServerInformation destination) {
    destination.AppVersion = source.AppVersion
    destination.DatabaseVersion = source.DatabaseVersion
    destination.TimesyncEnabled = source.TimesyncEnabled
    destination.SmtpEnabled = source.SmtpEnabled
    destination.MinPollTime = source.MinPollTime
    destination.MaxPollTime = source.MaxPollTime
}


define_function NAVRmsLocationCopy(_NAVRmsLocation source, _NAVRmsLocation destination) {
    destination.ClientDefaultLocation = source.ClientDefaultLocation
    destination.Id = source.Id
    destination.Name = source.Name
    destination.Owner = source.Owner
    destination.PhoneNumber = source.PhoneNumber
    destination.Occupancy = source.Occupancy
    destination.PrestigeName = source.PrestigeName
    destination.Timezone = source.Timezone
    destination.AssetLicensed = source.AssetLicensed
}


define_function NAVRmsMessageCopy(_NAVRmsMessage source, _NAVRmsMessage destination) {
    destination.Type = source.Type
    destination.Title = source.Title
    destination.Body = source.Body
    destination.TimeOutSeconds = source.TimeOutSeconds
    destination.Modal = source.Modal
    destination.ResponseMessage = source.ResponseMessage
}


define_function NAVRmsExceptionCopy(_NAVRmsException source, _NAVRmsException destination) {
    destination.Message = source.Message
    destination.ThrownByCommandHeader = source.ThrownByCommandHeader
}


define_function NAVRmsExceptionLog(_NAVRmsException exception, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                "'RMS Client ', NAVDeviceToString(args.device), ' Exception: ', exception.Message")

    if (!length_array(exception.ThrownByCommandHeader)) {
        return
    }

    NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                "'RMS Client ', NAVDeviceToString(args.device), ' Thrown By Command Header: ', exception.ThrownByCommandHeader")
}


define_function NAVRmsClientServerInformationLog(_NAVRmsServerInformation server, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), ' Server Info: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   App Version: ', server.AppVersion")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Database Version: ', server.DatabaseVersion")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Timesync Enabled: ', NAVBooleanToString(server.TimesyncEnabled)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Smtp Enabled: ', NAVBooleanToString(server.SmtpEnabled)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Min Poll Time: ', itoa(server.MinPollTime)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Max Poll Time: ', itoa(server.MaxPollTime)")
}


define_function NAVRmsClientLocationLog(_NAVRmsLocation location, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), ' Location: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Client Default Location: ', NAVBooleanToString(location.ClientDefaultLocation)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Id: ', location.Id")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Name: ', location.Name")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Owner: ', location.Owner")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Phone Number: ', location.PhoneNumber")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Occupancy: ', location.Occupancy")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Prestige Name: ', location.PrestigeName")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Timezone: ', location.Timezone")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Asset Licensed: ', NAVBooleanToString(location.AssetLicensed)")
}


define_function NAVRmsClientConnectionStateLog(_NAVRmsConnectionState state, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), ' Connection State Transition: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Old State: ', state.OldState")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   New State: ', state.NewState")
}


define_function NAVRmsClientConfigChangeLog(_NAVKeyValuePair config, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), ' Config Change: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Key: ', config.Key")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Value: ', config.Value")
}


define_function NAVRmsHotlistLog(_NAVRmsHotlist hotlist, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), ' Hotlist: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Client Default Location: ', NAVBooleanToString(hotlist.ClientDefaultLocation)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Location ID: ', itoa(hotlist.LocationId)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Count: ', itoa(hotlist.Count)")
}


define_function NAVRmsMessageDisplayLog(_NAVRmsMessage message, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), ' Message Display: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Type: ', message.Type")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Title: ', message.Title")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Body: ', message.Body")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Timeout seconds: ', itoa(message.TimeOutSeconds)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Modal: ', NAVBooleanToString(message.Modal)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client ', NAVDeviceToString(args.device), '   Response Message: ', message.ResponseMessage")
}


#END_IF // __NAV_FOUNDATION_RMSUTILS__
